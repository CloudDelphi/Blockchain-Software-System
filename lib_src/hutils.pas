(* ======================================================================== *)
(* PeopleRelay: hutils.pas Version: 0.3.5.3                                 *)
(*                                                                          *)
(* Copyright 2017-2018 Aleksei Ilin & Igor Ilin                             *)
(*                                                                          *)
(* Licensed under the Apache License, Version 2.0 (the "License");          *)
(* you may not use this file except in compliance with the License.         *)
(* You may obtain a copy of the License at                                  *)
(*                                                                          *)
(*     http://www.apache.org/licenses/LICENSE-2.0                           *)
(*                                                                          *)
(* Unless required by applicable law or agreed to in writing, software      *)
(* distributed under the License is distributed on an "AS IS" BASIS,        *)
(* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *)
(* See the License for the specific language governing permissions and      *)
(* limitations under the License.                                           *)
(* ======================================================================== *)

unit hutils;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
interface
{/////////////////////////////////////////////////////////////////////////////////////////////////}
uses
  SysUtils,Classes,LbCipher,LbAsym,LbRSA,LbString,LbClass;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
type
PBlobHandle = ^Pointer;
TBlob = record
  GetSegment : function(Handle: PBlobHandle; Buffer: PChar; MaxLength: LongInt; var ReadLength: LongInt): WordBool; cdecl;
  Handle     : PBlobHandle;
  SegCount,
  MaxSegLen,
  TotalLen   : LongInt;
  PutSegment : procedure(Handle: PBlobHandle; Buffer: PChar; Length: Word); cdecl;
  Seek: procedure(Handle: PBlobHandle; Mode: Word; Offset: LongInt); cdecl;
//  blb_seek_relative: Word = 1; blb_seek_from_tail: Word = 2;
end;
PBlob = ^TBlob;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
function RDLEncryptStr(const Key,s: String; Encrypt: Boolean): String;
procedure StrToUTF(Src, Dest: PChar); cdecl; export;
procedure StrToAnsi(Src, Dest: PChar); cdecl; export;

procedure BlobToUTF(const Src, Dest: PBlob); cdecl; export;
procedure BlobToAnsi(const Src, Dest: PBlob); cdecl; export;

procedure sha1(const Blob: PBlob; CString: PChar); cdecl; export;
procedure sha256(const Blob: PBlob; CString: PChar); cdecl; export;
procedure sha256x2(const Blob: PBlob; CString: PChar); cdecl; export;

procedure rsakey(const Aks: PInteger; CString: PAnsiChar); cdecl; export;
procedure rsasig(const Aks: PInteger; Key,CHash,CString: PChar); cdecl; export;
function sigver(const Aks: PInteger; Key,CHash,CSig: PChar): integer; cdecl; export;
procedure rsaEncrypt(const Aks: PInteger; Key,InStr,OutStr: PChar); cdecl; export;
procedure rsaDecrypt(const Aks: PInteger; Key,InStr,OutStr: PChar); cdecl; export;
procedure rsaEncBlob(const Aks: PInteger; Key: PChar; const Src, Dest: PBlob); cdecl; export;
procedure rsaDecBlob(const Aks: PInteger; Key: PChar; const Src, Dest: PBlob); cdecl; export;

procedure Encrypt(Key,InStr,OutStr: PChar); cdecl; export;
procedure Decrypt(Key,InStr,OutStr: PChar); cdecl; export;
procedure EncBlob(Key: PChar; const Src, Dest: PBlob); cdecl; export;
procedure DecBlob(Key: PChar; const Src, Dest: PBlob); cdecl; export;

procedure Version(CString: PChar); cdecl; export;

const
  FVer = '0.3.5.3';
{/////////////////////////////////////////////////////////////////////////////////////////////////}
implementation
{-------------------------------------------------------------------------------------------------}
{/////////////////////////////////////////////////////////////////////////////////////////////////}
{-------------------------------------------------------------------------------------------------}
function SoltKey(const L: Integer; const Key: String): String;
begin
  if Key = ''
  then
    Result:=''
  else  
    begin
      Result:=Key;
      while Length(Result) < L do Result:=Result + Key;
      Result:=Copy(Result,1,L);
    end;
end;
{-------------------------------------------------------------------------------------------------}
function Base64Buf(const Buf; const Len: Integer; const Enc: Boolean): AnsiString;
var
  InStream: TMemoryStream;
  OutStream: TStringStream;
begin
  InStream:=TMemoryStream.Create;
  try
    InStream.Write(Buf,Len);
    InStream.Position:=0;
    OutStream:=TStringStream.Create('');
    try
      if Enc
      then
        LbEncodeBase64A(InStream,OutStream)
      else
        LbDecodeBase64A(InStream,OutStream);
      Result:=OutStream.DataString;
      finally
        OutStream.Free;
      end;
  finally
    InStream.Free;
  end;
end;
{-------------------------------------------------------------------------------------------------}
function BlobToStr(const ABlob: TBlob): AnsiString;
var
  EOB: Boolean;
  n,
  BlobLen,
  TotRead: LongInt;
begin
  Result:='';
  with ABlob do
    if Assigned(Handle) and (TotalLen > 0) then
    try
      TotRead:=0;
      BlobLen:=ABlob.TotalLen;
//      Result:=StringOfChar(#0,BlobLen + 1);
      Result:=StringOfChar(#0,BlobLen);
      repeat
        n:=0;
        EOB:= not GetSegment(Handle, PChar(Result) + TotRead, $FFFF, n);
        Inc(TotRead,n);
        Dec(BlobLen,n);
      until EOB or (BlobLen <= 0);
    except
      //nop
    end;
end;
{-------------------------------------------------------------------------------------------------}
procedure StrToBlob(S: AnsiString; const Blob: TBlob);
var
  n: Word;
  StrTail,
  TailPos: LongInt;
begin
  if Assigned(Blob.Handle) then
  try
    TailPos:=0;
    StrTail:=Length(S);
    repeat
      if StrTail > $FFFF then n:=$FFFF else n:=StrTail;
      Blob.PutSegment(Blob.Handle,PAnsiChar(S) + TailPos,n);
      Inc(TailPos,n);
      Dec(StrTail,n);
    until StrTail <= 0;
  except
    //nop
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure sha1(const Blob: PBlob; CString: PChar); cdecl; export;
var
  Hash: TSHA1Digest;
  s: String;
begin
  try
    CString[0] := #0;
    s:=BlobToStr(Blob^);
    HashSHA1(Hash,s[1],Length(s));
    StrPCopy(CString,Base64Buf(Hash,SizeOf(Hash),True));
  except
    CString[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure sha256(const Blob: PBlob; CString: PChar); cdecl; export;
var
  Hash: T256BitDigest;
begin
  try
    CString[0] := #0;
    Hash:=CalcSHA256(BlobToStr(Blob^));
    StrPCopy(CString,Base64Buf(Hash,SizeOf(Hash),True));
  except
    CString[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure sha256x2(const Blob: PBlob; CString: PChar); cdecl; export;
var
  Hash: T256BitDigest;
begin
  try
    CString[0] := #0;
    Hash:=CalcSHA256(BlobToStr(Blob^));
    Hash:=CalcSHA256(Hash,SizeOf(Hash));
    StrPCopy(CString,Base64Buf(Hash,SizeOf(Hash),True));
  except
    CString[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
function CalcKeySize(const Aks: Integer): TLbAsymKeySize;
begin
  case Aks of
    256  : Result:=aks256;
    512  : Result:=aks512;
    768  : Result:=aks768;
    2048 : Result:=aks2048;
    3072 : Result:=aks3072;
    else   Result:=aks1024;
  end;  
end;
{-------------------------------------------------------------------------------------------------}
// Key = Private Key or Public Key
function rsaCipher(const Aks: Integer; const Key,InStr: AnsiString; AFlag: Boolean): AnsiString;
var
  p: Integer;
  RSASSA: TLbRSASSA;
  md,ex: AnsiString;
begin
  Result:='';
  try
    p:=Pos(',',Key);
    md:=Trim(Copy(Key,1,p-1));
    ex:=Trim(Copy(Key,p+1,MaxInt));
    RSASSA:=TLbRSASSA.Create(nil);
    try
      RSASSA.KeySize:=CalcKeySize(Aks);
      RSASSA.PrivateKey.ModulusAsString:=md;
      RSASSA.PrivateKey.ExponentAsString:=ex;
      Result:=RSAEncryptString(InStr,RSASSA.PrivateKey,AFlag);
    finally
      RSASSA.Free;
    end;
  except
    //nop
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaEncrypt(const Aks: PInteger; Key,InStr,OutStr: PChar); cdecl; export;
begin
  StrPCopy(OutStr,rsaCipher(Aks^,Key,InStr,True));
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaDecrypt(const Aks: PInteger; Key,InStr,OutStr: PChar); cdecl; export;
begin
  StrPCopy(OutStr,rsaCipher(Aks^,Key,InStr,False));
end;
{-------------------------------------------------------------------------------------------------}
// Key = Private Key
procedure rsasig(const Aks: PInteger; Key,CHash,CString: PChar); cdecl; export;
var
  p: Integer;
  RSASSA: TLbRSASSA;
  md,ex: AnsiString;
begin
  try
    CString[0] := #0;
    p:=Pos(',',Key);
    md:=Trim(Copy(Key,1,p-1));
    ex:=Trim(Copy(Key,p+1,MaxInt));
    RSASSA:=TLbRSASSA.Create(nil);
    try
      RSASSA.KeySize:=CalcKeySize(Aks^);
      RSASSA.PrivateKey.ModulusAsString:=md;
      RSASSA.PrivateKey.ExponentAsString:=ex;
      StrPCopy(CString,RSAEncryptStringA(CHash,RSASSA.PrivateKey,True));
    finally
      RSASSA.Free;
    end;
  except
    CString[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
// Key = Public Key
function sigver(const Aks: PInteger; Key,CHash,CSig: PChar): integer; cdecl; export;
var
  p: Integer;
  RSASSA: TLbRSASSA;
  md,ex: AnsiString;
begin
  try
    Result:=0;
    p:=Pos(',',Key);
    md:=Trim(Copy(Key,1,p-1));
    ex:=Trim(Copy(Key,p+1,MaxInt));
    RSASSA:=TLbRSASSA.Create(nil);
    try
      RSASSA.KeySize:=CalcKeySize(Aks^);
      RSASSA.PublicKey.ModulusAsString:=md;
      RSASSA.PublicKey.ExponentAsString:=ex;
      if RSAEncryptStringA(CSig,RSASSA.PublicKey,False) = CHash then Result:=1;
    finally
      RSASSA.Free;
    end;
  except
    Result:=0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure rsakey(const Aks: PInteger; CString: PChar); cdecl; export;
var
  RSASSA: TLbRSASSA;
begin
  CString[0] := #0;
  RSASSA:=TLbRSASSA.Create(nil);
  try
    RSASSA.KeySize:=CalcKeySize(Aks^);
    RSASSA.GenerateKeyPair;
    StrPCopy(CString,
      RSASSA.PrivateKey.ModulusAsString + ',' +
      RSASSA.PrivateKey.ExponentAsString + ',' +
      RSASSA.PublicKey.ExponentAsString);
  finally
    RSASSA.Free;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure StrToUTF(Src, Dest: PChar); cdecl; export;
begin
  try
    StrPCopy(Dest,AnsiToUtf8(Src));
  except
    Dest[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure StrToAnsi(Src, Dest: PChar); cdecl; export;
begin
  try
    StrPCopy(Dest,UTF8ToAnsi(Src));
  except
    Dest[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure BlobToUTF(const Src, Dest: PBlob); cdecl; export;
begin
  try
    StrToBlob(AnsiToUtf8(BlobToStr(Src^)),Dest^);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure BlobToAnsi(const Src, Dest: PBlob); cdecl; export;
begin
  try
    StrToBlob(UTF8ToAnsi(BlobToStr(Src^)),Dest^);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaEncBlob(const Aks: PInteger; Key: PChar; const Src, Dest: PBlob); cdecl; export;
begin
  try
    StrToBlob(rsaCipher(Aks^,Key,BlobToStr(Src^),True),Dest^);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaDecBlob(const Aks: PInteger; Key: PChar; const Src, Dest: PBlob); cdecl; export;
begin
  try
    StrToBlob(rsaCipher(Aks^,Key,Trim(BlobToStr(Src^)),False),Dest^);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
function RDLEncryptStr(const Key,s: String; Encrypt: Boolean): String;
var
  r: TLbRijndael;
begin
  try
    if (s = '') 
      or (Key = '')
    then
      Result:=s
    else
      begin
        r:=TLbRijndael.Create(nil);
        try
          r.GenerateKey(Key);
          if Encrypt
          then
            Result:=r.EncryptString(s)
          else
            Result:=r.DecryptString(s);
        finally
          r.Free;
        end;
      end;
  except
    Result:='?';
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure Encrypt(Key,InStr,OutStr: PChar); cdecl; export;
begin
  StrPCopy(OutStr,RDLEncryptStr(Key,InStr,True));
end;
{-------------------------------------------------------------------------------------------------}
procedure Decrypt(Key,InStr,OutStr: PChar); cdecl; export;
begin
  StrPCopy(OutStr,RDLEncryptStr(Key,InStr,False));
end;
{-------------------------------------------------------------------------------------------------}
procedure EncBlob(Key: PChar; const Src, Dest: PBlob); cdecl; export;
begin
  try
    StrToBlob(RDLEncryptStr(Key,BlobToStr(Src^),True),Dest^);
//    StrToBlob(RDLEncryptStr(Key,Trim(BlobToStr(Src^)),True),Dest^);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure DecBlob(Key: PChar; const Src, Dest: PBlob); cdecl; export;
begin
  try
    StrToBlob(RDLEncryptStr(Key,Trim(BlobToStr(Src^)),False),Dest^);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure Version(CString: PChar); cdecl; export;
begin
  StrPCopy(CString,FVer);
end;
{-------------------------------------------------------------------------------------------------}
{$Warnings OFF}
END.

typedef struct blobcallback {
    short (*blob_get_segment)(void* hnd, ISC_UCHAR* buffer, ISC_USHORT buf_size, ISC_USHORT* result_len);
    void*		blob_handle;
    ISC_LONG	blob_number_segments;
    ISC_LONG	blob_max_segment;
    ISC_LONG	blob_total_length;
    void (*blob_put_segment)(void* hnd, const ISC_UCHAR* buffer, ISC_USHORT buf_size);
    ISC_LONG (*blob_lseek)(void* hnd, ISC_USHORT mode, ISC_LONG offset);
}  *BLOBCALLBACK;

void StringToblob(const paramdsc* v, blobcallback* outblob)
{
	if (internal::isnull(v))
	{
	    outblob->blob_handle = 0; // hint for the engine, null blob.
		return;
	}
	ISC_UCHAR* text = 0;
	const int len = internal::get_any_string_type(v, text);
	if (len < 0 && outblob)
		outblob->blob_handle = 0; // hint for the engine, null blob.
	if (!outblob || !outblob->blob_handle)
		return;
	outblob->blob_put_segment(outblob->blob_handle, text, len);
	return;
}

{-------------------------------------------------------------------------------------------------}
{-------------------------------------------------------------------------------------------------}
function GetUTTime: TDateTime;
{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
var
  st: TSystemTime;
begin
  GetSystemTime(st);
  result := SystemTimeToDateTime(st);
{$ELSE}
var
  st: SysUtils.TSystemTime;
  stw: Windows.TSystemTime;
begin
  GetSystemTime(stw);
  st.Year := stw.wYear;
  st.Month := stw.wMonth;
  st.Day := stw.wDay;
  st.Hour := stw.wHour;
  st.Minute := stw.wMinute;
  st.Second := stw.wSecond;
  st.Millisecond := stw.wMilliseconds;
  Result := SystemTimeToDateTime(st);
{$ENDIF}
{$ELSE}
{$IFNDEF FPC}
var
  TV: TTimeVal;
begin
  gettimeofday(TV, nil);
  Result := UnixDateDelta + (TV.tv_sec + TV.tv_usec / 1000000) / 86400;
{$ELSE}
var
  TV: TimeVal;
begin
  fpgettimeofday(@TV, nil);
  Result := UnixDateDelta + (TV.tv_sec + TV.tv_usec / 1000000) / 86400;
{$ENDIF}
{$ENDIF}
end;
