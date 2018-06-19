(* ************************************************************************ *
 * PeopleRelay: hutils.pas Version: see lib_ver.txt                         *
 *                                                                          *
 * Copyright 2017 Aleksei Ilin & Igor Ilin                                  *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *     http://www.apache.org/licenses/LICENSE-2.0                           *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 * ************************************************************************ *)

unit hutils;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
interface
{/////////////////////////////////////////////////////////////////////////////////////////////////}
uses
  SysUtils,Classes,LbCipher,LbAsym,LbRSA,LbProc,LbString;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
type
TBlob = record
  GetSegment: function(Handle: Pointer; Buffer: PChar; MaxLength: Word; var ReadLength: Word): WordBool; cdecl;
  Handle: Pointer;
  SegCount,
  MaxSegLen,
  TotalLen: Integer;
  PutSegment: procedure(Handle: Pointer; Buffer: PChar; Length: Word); cdecl;
  Seek: procedure(Handle: Pointer; Mode: Word; Offset: Integer); cdecl;
//  blb_seek_relative: Word = 1; blb_seek_from_tail: Word = 2;
end;
PBlob = ^TBlob;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
procedure StrToUTF(Src, Dest: PChar); cdecl; export;
procedure StrToAnsi(Src, Dest: PChar); cdecl; export;

procedure BlobToUTF(const Src, Dest: TBlob); cdecl; export;
procedure BlobToAnsi(const Src, Dest: TBlob); cdecl; export;

procedure rsakey(CString: PAnsiChar); cdecl; export;
procedure sha256(const Blob: TBlob; CString: PChar); cdecl; export;
procedure rsasig(Key,CHash,CString: PChar); cdecl; export;
function sigver(Key,CHash,CSig: PChar): integer; cdecl; export;

procedure rsaEncrypt(Key,InStr,OutStr: PChar); cdecl; export;
procedure rsaDecrypt(Key,InStr,OutStr: PChar); cdecl; export;

procedure Encrypt(Key,InStr,OutStr: PChar); cdecl; export;
procedure Decrypt(Key,InStr,OutStr: PChar); cdecl; export;

procedure rsaEncBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
procedure rsaDecBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;

procedure EncBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
procedure DecBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
implementation
{-------------------------------------------------------------------------------------------------}
{/////////////////////////////////////////////////////////////////////////////////////////////////}
{-------------------------------------------------------------------------------------------------}
function Base64Str(const s: String; const Enc: Boolean): AnsiString;
var
  InStream,
  OutStream: TStringStream;
begin
  InStream:=TStringStream.Create(s);
  try
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
function Base64Str1(const InStream: TStream; const Enc: Boolean): AnsiString;
var
  OutStream: TStringStream;
begin
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
{
function EncodeBase64(const inStr: string): string;
  function Encode_Byte(b: Byte): char;
  const
    Base64Code: string[64] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  begin
    Result := Base64Code[(b and $3F)+1];
  end;
var i: Integer;
begin
  i := 1;
  Result := '';
  while i <= Length(InStr) do begin
    Result := Result + Encode_Byte(Byte(inStr[i]) shr 2);
    Result := Result + Encode_Byte((Byte(inStr[i]) shl 4) or (Byte(inStr[i+1]) shr 4));
    if i+1 <= Length(inStr)
      then Result := Result + Encode_Byte((Byte(inStr[i+1]) shl 2) or (Byte(inStr[i+2]) shr 6))
      else Result := Result + '=';
    if i+2 <= Length(inStr)
      then Result := Result + Encode_Byte(Byte(inStr[i+2]))
      else Result := Result + '=';
    Inc(i, 3);
  end;
end;
}
{-------------------------------------------------------------------------------------------------}
{
function DecodeBase64(const CinLine: string): string;
const
  RESULT_ERROR = -2;
var
  inLineIndex: Integer;
  c: Char;
  x: SmallInt;
  c4: Word;
  StoredC4: array[0..3] of SmallInt;
  InLineLength: Integer;
begin
  Result := '';
  inLineIndex := 1;
  c4 := 0;
  InLineLength := Length(CinLine);

  while inLineIndex <= InLineLength do begin
    while (inLineIndex <= InLineLength) and (c4 < 4) do begin
      c := CinLine[inLineIndex];
      case c of
        '+'     : x := 62;
        '/'     : x := 63;
        '0'..'9': x := Ord(c) - (Ord('0')-52);
        '='     : x := -1;
        'A'..'Z': x := Ord(c) - Ord('A');
        'a'..'z': x := Ord(c) - (Ord('a')-26);
      else
        x := RESULT_ERROR;
      end;
      if x <> RESULT_ERROR then begin
        StoredC4[c4] := x;
        Inc(c4);
      end;
      Inc(inLineIndex);
    end;
    if c4 = 4 then begin
      c4 := 0;
      Result := Result + Char((StoredC4[0] shl 2) or (StoredC4[1] shr 4));
      if StoredC4[2] = -1 then Exit;
      Result := Result + Char((StoredC4[1] shl 4) or (StoredC4[2] shr 2));
      if StoredC4[3] = -1 then Exit;
      Result := Result + Char((StoredC4[2] shl 6) or (StoredC4[3]));
    end;
  end;
end;
}


function BlobToStr(const ABlob: TBlob): AnsiString;
var
  EOB: Boolean;
  n: Word;
  BlobLen,
  TotRead: Integer;
begin
  Result:='';
  with ABlob do
    if Assigned(Handle) and (TotalLen > 0) then
    try
      TotRead:=0;
      BlobLen:=ABlob.TotalLen;
      Result:=StringOfChar(#0,BlobLen + 1);
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
  TailPos: Integer;
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
procedure sha256(const Blob: TBlob; CString: PChar); cdecl; export;
var
  Hash: T256BitDigest;
begin
  try
    CString[0] := #0;
    Hash:=CalcSHA256(BlobToStr(Blob));
//    StrPCopy(CString,EncodeBase64(Hash,SizeOf(Hash)));
    StrPCopy(CString,Base64Buf(Hash,SizeOf(Hash),True));
  except
    CString[0] := #0;
  end;
end;
{-------------------------------------------------------------------------------------------------}
// Key = Private Key or Public Key
function rsaCipher(const Key,InStr: AnsiString; AFlag: Boolean): AnsiString;
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
      RSASSA.KeySize:=aks1024;
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
procedure rsaEncrypt(Key,InStr,OutStr: PChar); cdecl; export;
begin
  StrPCopy(OutStr,rsaCipher(Key,InStr,True));
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaDecrypt(Key,InStr,OutStr: PChar); cdecl; export;
begin
  StrPCopy(OutStr,rsaCipher(Key,InStr,False));
end;
{-------------------------------------------------------------------------------------------------}
// Key = Private Key
procedure rsasig(Key,CHash,CString: PChar); cdecl; export;
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
      RSASSA.KeySize:=aks1024;
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
function sigver(Key,CHash,CSig: PChar): integer; cdecl; export;
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
      RSASSA.KeySize:=aks1024;
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
procedure rsakey(CString: PChar); cdecl; export;
var
  RSASSA: TLbRSASSA;
begin
  CString[0] := #0;
  RSASSA:=TLbRSASSA.Create(nil);
  try
    RSASSA.KeySize:=aks1024;
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
procedure BlobToUTF(const Src, Dest: TBlob); cdecl; export;
begin
  try
    StrToBlob(AnsiToUtf8(BlobToStr(Src)),Dest);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure BlobToAnsi(const Src, Dest: TBlob); cdecl; export;
begin
  try
    StrToBlob(UTF8ToAnsi(BlobToStr(Src)),Dest);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaEncBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
begin
  try
    StrToBlob(rsaCipher(Key,BlobToStr(Src),True),Dest);
//    StrToBlob(rsaCipher(Key,Trim(BlobToStr(Src)),True),Dest);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure rsaDecBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
begin
  try
    StrToBlob(rsaCipher(Key,Trim(BlobToStr(Src)),False),Dest);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
function RDLEncryptStr(const Key,s: String; Encrypt: Boolean): String;
var
  InStream,
  OutStream: TStringStream;
  AData: String;
begin
  Result:='';
  try
    if Encrypt
    then
      AData:=s
    else
      AData:=Base64Str(s,False);
    InStream:=TStringStream.Create(AData);
    try
      OutStream:=TStringStream.Create('');
      try
        RDLEncryptStreamCBC(InStream,OutStream,Key[1],Length(Key),Encrypt);
        if Encrypt
        then
          Result:=Base64Str1(OutStream,True)
        else
          Result:=OutStream.DataString;
      finally
        OutStream.Free;
      end;
    finally
      InStream.Free;
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
procedure EncBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
begin
  try
    StrToBlob(RDLEncryptStr(Key,BlobToStr(Src),True),Dest);
//    StrToBlob(RDLEncryptStr(Key,Trim(BlobToStr(Src)),True),Dest);
  except
    // nop;
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure DecBlob(Key: PChar; const Src, Dest: TBlob); cdecl; export;
begin
  try
    StrToBlob(RDLEncryptStr(Key,Trim(BlobToStr(Src)),False),Dest);
  except
    // nop;
  end;
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
