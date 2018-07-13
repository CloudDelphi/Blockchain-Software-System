/* ======================================================================== */
/* PeopleRelay: udfutil.sql Version: 0.4.3.6                                */
/*                                                                          */
/* Copyright 2017-2018 Aleksei Ilin & Igor Ilin                             */
/*                                                                          */
/* Licensed under the Apache License, Version 2.0 (the "License");          */
/* you may not use this file except in compliance with the License.         */
/* You may obtain a copy of the License at                                  */
/*                                                                          */
/*     http://www.apache.org/licenses/LICENSE-2.0                           */
/*                                                                          */
/* Unless required by applicable law or agreed to in writing, software      */
/* distributed under the License is distributed on an "AS IS" BASIS,        */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. */
/* See the License for the specific language governing permissions and      */
/* limitations under the License.                                           */
/* ======================================================================== */

/*-----------------------------------------------------------------------------------------------*/
declare external function GetMutex
  cstring(128) CHARACTER SET WIN1252,
  integer
  returns BigInt by value
  entry_point 'GetMutex' module_name 'pr_udf';

declare external function FreeMutex
  BigInt
  returns integer by value
  entry_point 'FreeMutex' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function CanConnect
  cstring(128) CHARACTER SET WIN1252, /* see the TIPV6str domain */
  integer,
  integer
  returns integer by value
  entry_point 'CanConnect' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function sha1_blob
  blob,
  cstring(28) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'sha1' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function sha_blob
  blob,
  cstring(64) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'sha256' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function sha_blob2
  blob,
  cstring(64) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'sha256x2' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsasig
  integer, -- keysize
  cstring(2048) CHARACTER SET WIN1252,
  cstring(64) CHARACTER SET WIN1252,
  cstring(512) CHARACTER SET WIN1252
  returns parameter 4
  entry_point 'rsasig' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function sigver
  integer, -- keysize
  cstring(2048) CHARACTER SET WIN1252,
  cstring(64) CHARACTER SET WIN1252,
  cstring(512) CHARACTER SET WIN1252
  returns integer by value
  entry_point 'sigver' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsakey
  integer, -- keysize
  cstring(4024) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'rsakey' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaEncrypt
  integer, -- keysize
  cstring(4024) CHARACTER SET WIN1252,
  cstring(4096) CHARACTER SET NONE,
  cstring(4096) CHARACTER SET WIN1252
  returns parameter 4
  entry_point 'rsaEncrypt' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaDecrypt
  integer, -- keysize
  cstring(4024) CHARACTER SET WIN1252,
  cstring(4096) CHARACTER SET WIN1252,
  cstring(4096) CHARACTER SET NONE
  returns parameter 4
  entry_point 'rsaDecrypt' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaEncBlob
  integer, -- keysize
  cstring(4024) CHARACTER SET WIN1252,
  blob,
  blob
  returns parameter 4
  entry_point 'rsaEncBlob' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaDecBlob
  integer, -- keysize
  cstring(4024) CHARACTER SET WIN1252,
  blob,
  blob
  returns parameter 4
  entry_point 'rsaDecBlob' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToUTF_256
  cstring(256) CHARACTER SET WIN1252,
  cstring(1024)
  returns parameter 2
  entry_point 'StrToUTF' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToUTF
  cstring(1024) CHARACTER SET WIN1252,
  cstring(4096)
  returns parameter 2
  entry_point 'StrToUTF' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToAnsi_256
  cstring(1024),
  cstring(256) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'StrToAnsi' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToAnsi
  cstring(4096),
  cstring(1024) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'StrToAnsi' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function BlobToUTF
  blob,
  blob
  returns parameter 2
  entry_point 'BlobToUTF' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function BlobToAnsi
  blob,
  blob
  returns parameter 2
  entry_point 'BlobToAnsi' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function Encrypt
  cstring(512) CHARACTER SET NONE,
  cstring(4096),
  cstring(4096) CHARACTER SET WIN1252
  returns parameter 3
  entry_point 'Encrypt' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function Decrypt
  cstring(512) CHARACTER SET NONE,
  cstring(4096) CHARACTER SET WIN1252,
  cstring(4096)
  returns parameter 3
  entry_point 'Decrypt' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function EncBlob
  cstring(512) CHARACTER SET NONE,
  blob,
  blob
  returns parameter 3
  entry_point 'EncBlob' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function DecBlob
  cstring(512) CHARACTER SET NONE,
  blob,
  blob
  returns parameter 3
  entry_point 'DecBlob' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function UTCTime
  TimeStamp
  returns parameter 1
  entry_point 'UTCTime' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function UTCUnixTime
  returns BigInt by value
  entry_point 'UTCUnixTime' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function AuthCode
  cstring(1024),
  cstring(16) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'AuthCode' module_name 'pr_udf';
/*-----------------------------------------------------------------------------------------------*/
declare external function LibVer
  cstring(16) CHARACTER SET WIN1252
  returns parameter 1
  entry_point 'Version' module_name 'pr_udf';    
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
/*
  256
  512
  768
  1024
--  2048 too long for TSig domain
--  3072 too long for TSig domain
*/
create procedure P_SKeySz
returns
  (Result Integer)
as
begin
  Result = 256;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BKeySz
returns
  (Result Integer)
as
begin
  Result = 256;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CalcSha1(AData TBlob)
returns
  (Result TSha1)
as
begin
  if (AData is not null) then Result = sha1_blob(AData);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure StdSha1(AText TString4K)
returns
  (Result TSha1)
as
  declare AData TMemo;
begin
  execute procedure StdStr(AText) returning_values AData;
  execute procedure P_CalcSha1(AData) returning_values Result;
  Result = Replace(Result,'=','');
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CalcHash(AData TBlob)
returns
  (Result TChHash)
as
begin
  if (AData is not null) then Result = sha_blob2(AData);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsSysSig(AHash TChHash, ASig TSig, PubKey TKey)
returns
  (Result TBoolean)
as
begin
  Result = sigver((select Result from P_SKeySz),PubKey,AHash,ASig);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BlockSig(AHash TChHash, PvtKey TKey)
returns
  (Result TSig)
as
begin
  if (PvtKey is not null and AHash is not null) then
    Result = rsasig((select Result from P_BKeySz),PvtKey,AHash);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsBlockSig(AHash TChHash, ASig TSig, PubKey TKey)
returns
  (Result TBoolean)
as
begin
  Result = sigver((select Result from P_BKeySz),PubKey,AHash,ASig);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_RsaKey(Ask Integer)
returns
  (PvtKey TSysStr2K,
   PubKey TSysStr2K)
as
  declare p1 TInt32;
  declare p2 TInt32;
  declare s TSysStr4K;
  declare sM1 TSysStr2K;
  declare sX1 TSysStr2K;
  declare sX2 TSysStr2K;
begin
  s = rsakey(Ask);
  if (s is not null and s <> '') then
  begin
    p1 = Position(',',s);
    if (p1 > 0) then
    begin
      p2 = Position(',',s,p1 + 1);
      if (p2 > 0) then
      begin
        sM1 = Substring(s from 1 for p1 - 1);
        sX1 = Substring(s from p1 + 1 for p2 - p1 - 1);
        sX2 = Substring(s from p2 + 1);
        PvtKey = sM1 || ',' || sX1;
        PubKey = sM1 || ',' || sX2;
      end
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SysKey
returns
  (PvtKey TSysStr2K,
   PubKey TSysStr2K)
as
begin
  execute procedure P_RsaKey(
    (select Result from P_SKeySz)) returning_values PvtKey,PubKey;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BlockKey
returns
  (PvtKey TSysStr2K,
   PubKey TSysStr2K)
as
begin
  execute procedure P_RsaKey(
    (select Result from P_BKeySz)) returning_values PvtKey,PubKey;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_StrToUTF(s VarChar(1024))
returns
  (Result VarChar(4096))
as
  declare n Integer;
begin
  if (s is not null and s <> '') then
  begin
    n = char_length(s);
    if (n < 257)
    then
      Result = StrToUTF_256(s);
    else
      if (n < 1025) then
        Result = StrToUTF(s);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_StrToAnsi(s VarChar(4096))
returns
  (Result VarChar(1024))
as
  declare n Integer;
begin
  if (s is not null and s <> '') then
  begin
    n = char_length(s);
    if (n < 1025)
    then
      Result = StrToAnsi_256(s);
    else
      if (n < 4097) then
        Result = StrToAnsi(s);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure P_RsaKey to procedure P_SysKey;
grant execute on procedure P_SKeySz to procedure P_SysKey;

grant execute on procedure P_RsaKey to procedure P_BlockKey;
grant execute on procedure P_BKeySz to procedure P_BlockKey;

grant execute on procedure P_SKeySz to procedure P_IsSysSig;

grant execute on procedure P_BKeySz to procedure P_BlockSig;
grant execute on procedure P_BKeySz to procedure P_IsBlockSig;

grant execute on procedure StdStr to procedure StdSha1;
grant execute on procedure P_CalcSha1 to procedure StdSha1;

grant execute on procedure P_StrToUTF to PUBLIC;

/*-----------------------------------------------------------------------------------------------*/

