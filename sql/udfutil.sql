/* ************************************************************************ */
/* PeopleRelay: udfutil.sql Version: see version.sql                        */
/*                                                                          */
/* Copyright 2017 Aleksei Ilin & Igor Ilin                                  */
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
/* ************************************************************************ */

/*-----------------------------------------------------------------------------------------------*/
declare external function GetMutex
  cstring(128) CHARACTER SET WIN1252,
  integer
  returns integer by value
  entry_point 'GetMutex' module_name 'hudf';

declare external function FreeMutex
  integer
  returns integer by value
  entry_point 'FreeMutex' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function CanConnect
  cstring(128) CHARACTER SET WIN1252, /* see the TIPV6str domain */
  integer,
  integer
  returns integer by value
  entry_point 'CanConnect' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function sha_blob
  blob,
  cstring(64) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'sha256' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsasig
  cstring(1024) CHARACTER SET WIN1252,
  cstring(64) CHARACTER SET WIN1252,
  cstring(256) CHARACTER SET WIN1252
  returns parameter 3
  entry_point 'rsasig' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function sigver
  cstring(1024) CHARACTER SET WIN1252,
  cstring(64) CHARACTER SET WIN1252,
  cstring(256) CHARACTER SET WIN1252
  returns integer by value
  entry_point 'sigver' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsakey
  cstring(1024) CHARACTER SET WIN1252
  returns parameter 1
  entry_point 'rsakey' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToUTF_256
  cstring(256) CHARACTER SET WIN1252,
  cstring(1024)
  returns parameter 2
  entry_point 'StrToUTF' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToUTF
  cstring(1024) CHARACTER SET WIN1252,
  cstring(4096)
  returns parameter 2
  entry_point 'StrToUTF' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToAnsi_256
  cstring(1024),
  cstring(256) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'StrToAnsi' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function StrToAnsi
  cstring(4096),
  cstring(1024) CHARACTER SET WIN1252
  returns parameter 2
  entry_point 'StrToAnsi' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function BlobToUTF
  blob,
  blob
  returns parameter 2
  entry_point 'BlobToUTF' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function BlobToAnsi
  blob,
  blob
  returns parameter 2  
  entry_point 'BlobToAnsi' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaEncrypt
  cstring(4024) CHARACTER SET WIN1252,
  cstring(4096) CHARACTER SET NONE,
  cstring(4096) CHARACTER SET WIN1252
  returns parameter 3
  entry_point 'rsaEncrypt' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaDecrypt
  cstring(4024) CHARACTER SET WIN1252,
  cstring(4096) CHARACTER SET WIN1252,
  cstring(4096) CHARACTER SET NONE
  returns parameter 3
  entry_point 'rsaDecrypt' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaEncBlob
  cstring(4024) CHARACTER SET WIN1252,
  blob,
  blob
  returns parameter 3
  entry_point 'rsaEncBlob' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function rsaDecBlob
  cstring(4024) CHARACTER SET WIN1252,
  blob,
  blob
  returns parameter 3
  entry_point 'rsaDecBlob' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function Encrypt
  cstring(512) CHARACTER SET NONE,
  cstring(4096),
  cstring(4096) CHARACTER SET WIN1252
  returns parameter 3
  entry_point 'Encrypt' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function Decrypt
  cstring(512) CHARACTER SET NONE,
  cstring(4096) CHARACTER SET WIN1252,
  cstring(4096)
  returns parameter 3
  entry_point 'Decrypt' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function EncBlob
  cstring(512) CHARACTER SET NONE,
  blob,
  blob
  returns parameter 3
  entry_point 'EncBlob' module_name 'hudf';
/*-----------------------------------------------------------------------------------------------*/
declare external function DecBlob
  cstring(512) CHARACTER SET NONE,
  blob,
  blob
  returns parameter 3
  entry_point 'DecBlob' module_name 'hudf';    
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CalcHash(AData TMemo)
returns
  (Result TChHash)
as
begin
  if (AData is not null) then Result = sha_blob(AData);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CalcSig(AHash TChHash, PvtKey TKey)
returns
  (Result TSig)
as
begin
  if (PvtKey is not null and AHash is not null) then Result = rsasig(PvtKey,AHash);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsSigValid(AHash TChHash, ASig TSig, PubKey TKey)
returns
  (Result TBoolean)
as
begin
  Result = sigver(PubKey,AHash,ASig);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_RsaKey
returns
  (PvtKey TSysStr1K,
   PubKey TSysStr1K)
as
  declare p1 TInt32;
  declare p2 TInt32;
  declare s TSysStr4K;
  declare sM1 TSysStr1K;
  declare sX1 TSysStr1K;
  declare sX2 TSysStr1K;
begin
  s = rsakey();
  if (s is not null and s <> '') then
  begin
    p1 = Position(',',s);
    if (p1 > 0) then
    begin
      p2 = Position(',',s,p1 + 1);
      if (p1 > 0 and p2 > 0) then
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
grant execute on procedure P_StrToUTF to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/

