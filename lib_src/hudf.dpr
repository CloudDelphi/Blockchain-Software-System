(* ************************************************************************ *
 * PeopleRelay: hudf.dpr Version: see lib_ver.txt                           *
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

library hudf;
{$MODE DELPHI}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils,
  hutils,
  iptest,
  mutex;
//{$R *.RES}
{/////////////////////////////////////////////////////////////////////////////////////////////////}
exports
  rsakey,
  sha256,
  rsasig,
  sigver,
  StrToUTF,
  StrToAnsi,
  BlobToUTF,
  BlobToAnsi,
  rsaEncrypt,
  rsaDecrypt,
  rsaEncBlob,
  rsaDecBlob,
  Encrypt,
  Decrypt,
  EncBlob,
  DecBlob,
  CanConnect,
  GetMutex,
  FreeMutex;
{/////////////////////////////////////////////////////////////////////////////////////////////////}
BEGIN
  IsMultithread := True;
END.
