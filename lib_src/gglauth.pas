unit gglauth;

{
  Google Authenticator for Delphi (c)2014 by Execute SARL
  http://www.execute.re

  Licensed under the GPL license.

  see http://en.wikipedia.org/wiki/Google_Authenticator

  v1 2014-01-15

}

interface
{/////////////////////////////////////////////////////////////////////////////////////////////////}
uses
  SysUtils;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
type
  PIBDateTime = ^TIBDateTime;
  TIBDateTime = record
    Days,                           // Date: Days since 17 November 1858
    MSec10 : Integer;               // Time: Millisecond * 10 since midnigth
  end;
{-------------------------------------------------------------------------------------------------}
const                               // Date translation constants
  MSecsPerDay10 = MSecsPerDay * 10; // Milliseconds per day * 10
  IBDateDelta = 15018;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
procedure AuthCode(Secret,Key: PChar); cdecl; export;
procedure UTCTime(var IBDateTime: TIBDateTime); cdecl; export;
function UTCUnixTime: Int64; cdecl; export;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
implementation
{/////////////////////////////////////////////////////////////////////////////////////////////////}
uses
  DateUtils;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
{
uses
  Windows

function GetUnixTime: Int64;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  with SystemTime do
    Result := Round((EncodeDate(wYear, wMonth, wDay) - UnixDateDelta
      + EncodeTime(wHour, wMinute, wSecond, wMilliseconds)) * SecsPerDay);
end;
}

procedure UTCTime(var IBDateTime: TIBDateTime); cdecl; export;
var
  ADays : Integer;
  DT: TDateTime;
begin
  DT:=LocalTimeToUniversal(Now);
  ADays := Trunc(DT);
  with IBDateTime do begin
    Days := ADays + IBDateDelta;
    MSec10 := Trunc((DT - ADays) * MSecsPerDay10);
  end;
end;
{-------------------------------------------------------------------------------------------------}
function UTCUnixTime: Int64; cdecl; export;
begin
  Result:=DateTimeToUnix(LocalTimeToUniversal(Now));
end;
{-------------------------------------------------------------------------------------------------}
function GetUnixTime: Int64;
begin
  Result:=DateTimeToUnix(LocalTimeToUniversal(Now));
end;
{-------------------------------------------------------------------------------------------------}
type
  TBytes = array of Byte;
{-------------------------------------------------------------------------------------------------}
function Base32ToBin(const Str: string): TBytes;
const
  Base32Chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';  // RFC 4648/3548
var
  Index: Integer;
  Count: Integer;
  Bits : Integer;
  Val  : Integer;
  Ofs  : Integer;
begin
  Count := (5 * Length(Str)) div 8;
  SetLength(Result, Count);
  bits := 0;
  val  := 0;
  ofs  := 1;
  for Index := 0 to Count - 1 do
  begin
    while Bits < 8 do
    begin
      Val := (Val shl 5) or (Pos(UpCase(Str[ofs]), Base32Chars) - 1);
      Inc(Ofs);
      Inc(Bits, 5);
    end;
    Dec(Bits, 8);
    Result[Index] := Byte(Val shr Bits);
    Val := Val and ((1 shl Bits) - 1);
  end;
end;
{-------------------------------------------------------------------------------------------------}
function IntToBytes(Value, Len: Integer): TBytes;
var
  Index: Integer;
begin
  SetLength(Result, Len);
  for Index := Len - 1 downto 0 do
  begin
    Result[Index] := Byte(Value);
    Value := Value shr 8;
  end;
end;
{-------------------------------------------------------------------------------------------------}
type
  TSHA1Context = record
    Size : Integer;
    Hash : array[0..4] of Cardinal; // 20 bytes
    Index: Integer;
    Block: array[0..63] of Byte;
  end;
{-------------------------------------------------------------------------------------------------}
procedure SHA1Reset(var Context: TSHA1Context);
begin
  Context.Size := 0;
  Context.Hash[0] := $67452301;
  Context.Hash[1] := $EFCDAB89;
  Context.Hash[2] := $98BADCFE;
  Context.Hash[3] := $10325476;
  Context.Hash[4] := $C3D2E1F0;
  Context.Index := 0;
end;
{-------------------------------------------------------------------------------------------------}
function SHA1CircularShift(bits, data: Cardinal): Cardinal;
begin
  Result := (data shl bits) or (data shr (32 - bits));
end;
{-------------------------------------------------------------------------------------------------}
procedure SHA1ProcessBlock(var Context: TSHA1Context);
const
  K: array[0..3] of Cardinal = ($5A827999, $6ED9EBA1, $8F1BBCDC, $CA62C1D6);
var
  W: array[0..79] of Cardinal;
  t: Integer;
  index: Integer;
  A, B, C, D, E: Cardinal;
  temp: Cardinal;
begin
 // Initialize the first 16 words in the array W
  for t := 0 to 15 do
  begin
    index := 4 * t;
    W[t] := Context.Block[index] shl 24
      or Context.Block[index + 1] shl 16
      or Context.Block[index + 2] shl 8
      or Context.Block[index + 3];
  end;
  for t := 16 to 79 do
    W[t] := SHA1CircularShift(1, W[t - 3] xor W[t - 8] xor W[t - 14] xor W[t - 16]);
  A := Context.Hash[0];
  B := Context.Hash[1];
  C := Context.Hash[2];
  D := Context.Hash[3];
  E := Context.Hash[4];
  for t := 0 to 19 do
  begin
    temp := SHA1CircularShift(5, A) + ((B and C) or ((not B) and D)) + E + W[t] + K[0];
    E := D;
    D := C;
    C := SHA1CircularShift(30, B);
    B := A;
    A := temp;
  end;
  for t := 20 to 39 do
  begin
    temp := SHA1CircularShift(5, A) + (B xor C xor D) + E + W[t] + K[1];
    E := D;
    D := C;
    C := SHA1CircularShift(30, B);
    B := A;
    A := temp;
  end;
  for t := 40 to 59 do
  begin
    temp := SHA1CircularShift(5, A) + ((B and C) or (B and D) or (C and D)) + E + W[t] + K[2];
    E := D;
    D := C;
    C := SHA1CircularShift(30, B);
    B := A;
    A := temp;
  end;
  for t := 60 to 79 do
  begin
    temp := SHA1CircularShift(5, A) + (B xor C xor D) + E + W[t] + K[3];
    E := D;
    D := C;
    C := SHA1CircularShift(30, B);
    B := A;
    A := temp;
  end;
  Inc(Context.Hash[0], A);
  Inc(Context.Hash[1], B);
  Inc(Context.Hash[2], C);
  Inc(Context.Hash[3], D);
  Inc(Context.Hash[4], E);
  Context.Index := 0;
end;
{-------------------------------------------------------------------------------------------------}
procedure SHA1Input(var Context: TSHA1Context; const Data: TBytes);
var
  i: Integer;
begin
  for i := 0 to Length(Data) - 1 do
  begin
    Context.Block[Context.Index] := Data[i];
    Inc(Context.Size);
    Inc(Context.Index);
    if Context.Index = 64 then
      SHA1ProcessBlock(Context);
  end;
end;
{-------------------------------------------------------------------------------------------------}
procedure SHA1PadMessage(var Context: TSHA1Context);
var
  i: Integer;
begin
  i := Context.Index;
  Context.Block[i] := $80;
  Inc(i);
  if i > 56
  then
    begin
      FillChar(Context.Block[i], 64 - i, 0);
      Context.Index := 64;
      SHA1ProcessBlock(Context);
      FillChar(Context.Block[0], 56, 0);
    end
  else
    FillChar(Context.Block[i], 56 - i, 0);
  Context.Index := 56;
 // Store the message length as the last 8 bytes
  Context.Block[56] := 0;
  Context.Block[57] := 0;
  Context.Block[58] := 0;
  Context.Block[59] := Context.Size shr 29;
  Context.Block[60] := Context.Size shr 21;
  Context.Block[61] := Context.Size shr 13;
  Context.Block[62] := Context.Size shr 5;
  Context.Block[63] := Context.Size shl 3;
  SHA1ProcessBlock(Context);
end;
{-------------------------------------------------------------------------------------------------}
function SHA1Result(var Context: TSHA1Context): TBytes;
var
  i: Integer;
begin
  SHA1PadMessage(Context);
  SetLength(Result, 20);
  for i := 0 to 19 do
    Result[i] := Byte(Context.Hash[i shr 2] shr (8 * (3 - (i and 3))));
end;
{-------------------------------------------------------------------------------------------------}
function XorBytes(const Src: TBytes; Value: Byte): TBytes;
var
  Len  : Integer;
  Index: Integer;
begin
  SetLength(Result, 64);
  Len := Length(Src);
  if Len > 64
  then
    Len := 64
  else
    FillChar(Result[Len], 64 - Len, Value);
  for Index := 0 to Len - 1 do
    Result[Index] := Src[Index] xor Value;
end;
{-------------------------------------------------------------------------------------------------}
function HMAC_SHA1(const Key, Value: TBytes): TBytes;
var
  opad: TBytes;
  ipad: TBytes;
  sha1: TSHA1Context;
begin
  opad := XorBytes(key, $5C);
  ipad := XorBytes(key, $36);
// Result := SHA1(opad + SHA1(ipad + Value))
  SHA1Reset(sha1);
  SHA1Input(sha1, ipad);
  SHA1Input(sha1, Value);
  Result := SHA1Result(sha1);
  SHA1Reset(sha1);
  SHA1Input(sha1, opad);
  SHA1Input(sha1, Result);
  Result := SHA1Result(sha1);
end;
{-------------------------------------------------------------------------------------------------}
function BytesToHex(const Value: TBytes): string;
const
  hx: array[0..$F] of Char = '0123456789abcdef';
var
  Len: Integer;
  Idx: Integer;
  b  : Byte;
begin
  Len := Length(Value);
  SetLength(Result, 2 * Len);
  for Idx := 0 to Len - 1 do
  begin
    b := Value[Idx];
    Result[2 * Idx + 1] := Hx[b shr 4];
    Result[2 * Idx + 2] := Hx[b and $F];
  end;
end;
{-------------------------------------------------------------------------------------------------}
function GoogleAuthCode(const Secret: string): string;
var
  key   : TBytes;
  epoch : TBytes;
  hmac  : TBytes;
  offset: Integer;
  index : Integer;
  otp   : Cardinal;
begin
  key := Base32ToBin(Secret);
//WriteLn('Key = ', BytesToHex(key));
  epoch := IntToBytes(GetUnixTime div 30, 8);
//WriteLn('Epoch = ', BytesToHex(epoch));
  hmac := HMAC_SHA1(key, epoch);
//WriteLn('HMac = ', BytesToHex(hmac));
  offset := hmac[19] and $F;
  otp := 0;
  for Index := 0 to 3 do
    otp := otp shl 8 + hmac[Offset + Index];
  otp := otp and $7fffffff;
  Result := IntToStr(otp mod 1000000);
  if Length(Result) < 6 then
    Result := StringOfChar('0', 6 - Length(Result)) + Result;
end;
{-------------------------------------------------------------------------------------------------}
procedure AuthCode(Secret,Key: PChar); cdecl; export;
begin
  StrPCopy(Key,GoogleAuthCode(Secret));
end;
{-------------------------------------------------------------------------------------------------}
END.