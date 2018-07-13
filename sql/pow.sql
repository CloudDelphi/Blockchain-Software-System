/* ======================================================================== */
/* PeopleRelay: pow.sql Version: 0.4.3.6                                    */
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
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Handshake(
  PeerId TNodeId,
  HShake THandshake,
  Puzzle TSysStr255)
returns
  (Proof TSysStr255)
as
begin
  if (HShake = 0)
  then
    Proof = Puzzle;
  else
    if (HShake = 1)
    then
      Proof = rsaEncrypt(256,(select Result from P_GetPvtKey),Puzzle);

  when any do
  begin
    Proof = null;
    execute procedure P_LogErr(-600,sqlcode,gdscode,sqlstate,'P_Handshake',PeerId,null,null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NewHShake(PeerId TNodeId)
returns(
  HShake THandshake,
  Puzzle TSysStr255)
as
begin
  Puzzle = uuid_to_Char(gen_uuid());
  
  if (exists (select 1 from P_TPeer
    where NodeId = :PeerId and PubKey is not null))
  then
    select Handshake from P_TParams into :HShake; /* else leave HShake with default val = 0 */

  when any do
  begin
    HShake = 0;
    execute procedure P_LogErr(-601,sqlcode,gdscode,sqlstate,'P_NewHShake',PeerId,null,null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CheckHShake(
  PeerId TNodeId,
  HShake THandshake,
  Puzzle TSysStr255,
  Proof TSysStr255)
returns
  (Result TBoolean)
as
  declare AKey TKey;
begin
  if (Puzzle is not null
    and Proof is not null)
  then
    begin
      if (HShake = 0)
      then
        begin
          if (Proof = Puzzle) then Result = 1;
        end
      else
        if (HShake = 1)
        then
          begin
            select PubKey from P_TPeer where NodeId = :PeerId into :AKey;
            if (rsaDecrypt(256,AKey,Proof) = Puzzle) then Result = 1;
          end
      when any do
      begin
        Result = 0;
        execute procedure P_LogErr(-602,sqlcode,gdscode,sqlstate,'P_CheckHShake',PeerId,null,null);
      end
    end

  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FindHash(AData TBlob)
returns
  (Nonce TNonce,
   AHash TChHash)
as
begin
  execute procedure Rand32(2147483600) returning_values Nonce;
  execute procedure P_CalcHash(AData || '-' || Nonce) returning_values AHash;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsHash(AHash TChHash)
returns
  (Result TBoolean)
as
begin
/*
Do check leading zeros here.
*/
  Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to procedure P_Handshake;
grant execute on procedure P_LogErr to procedure P_Handshake;
grant execute on procedure P_GetPvtKey to procedure P_Handshake;

grant select on P_TPeer to procedure P_NewHShake;
grant select on P_TParams to procedure P_NewHShake;
grant execute on procedure P_LogErr to procedure P_NewHShake;

grant select on P_TPeer to procedure P_CheckHShake;
grant execute on procedure P_LogErr to procedure P_CheckHShake;

grant execute on procedure Rand32 to procedure P_FindHash;
grant execute on procedure P_CalcHash to procedure P_FindHash;
/*-----------------------------------------------------------------------------------------------*/

