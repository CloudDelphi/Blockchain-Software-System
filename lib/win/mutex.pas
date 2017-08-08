(* ************************************************************************ *
 * PeopleRelay: mutex.pas Version: see lib_ver.txt                          *
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

unit mutex;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, DateUtils,
  {$IFDEF MSWINDOWS}
  Windows
  {$ENDIF};
 
type
  TMutex = class
  private
    FFileHandle: integer;
  public
    constructor Create(const AName: string; const WaitForMSec: integer = 10000);
    destructor Destroy; override;
  end;

function GetMutex(const Name: PChar; const WaitForMSec: PInteger): Longint;
function FreeMutex(const Mutex: PLongint): Integer;
implementation

function GetTempDir: string;
begin
{$IFDEF MSWINDOWS}
  SetLength(Result, 255);
  SetLength(Result, GetTempPath(255, (PChar(Result))));
{$ENDIF}
{$IFDEF LINUX}
  Result := GetEnv('TMPDIR');
  if Result = '' then
    Result := '/tmp/'
  else if Result[Length(Result)] <> PathDelim then
    Result := Result + PathDelim;
{$ENDIF}
end;
 
constructor TMutex.Create(const AName: string; const WaitForMSec: integer);
  function NextAttempt(const MaxTime: TDateTime): boolean;
  begin
    Sleep(1);
    Result := Now < MaxTime;
  end;
 
var
  MaxTime: TDateTime;
  LockFileName: string;
begin
  inherited Create;
  LockFileName := IncludeTrailingPathDelimiter(GetTempDir) + AName + '.tmp';
  MaxTime := IncMillisecond(Now, WaitForMSec);
  repeat
    if FileExists(LockFileName) then
      FFileHandle := FileOpen(LockFileName, fmShareExclusive)
    else
      FFileHandle := FileCreate(LockFileName, fmShareExclusive);
  until (FFileHandle <> -1) or not NextAttempt(MaxTime);
  if FFileHandle = -1 then
    raise Exception.CreateFmt('Unable to lock mutex (File: %s; waiting: %d msec)', [LockFileName, WaitForMSec]);
end;
 
destructor TMutex.Destroy;
begin
  if FFileHandle <> -1 then
    FileClose(FFileHandle);
  inherited;
end;

function GetMutex(const Name: PChar; const WaitForMSec: PInteger): Longint;
begin
  try
    Result:=PtrUint(TMutex.Create(Name,WaitForMSec^));
  except
    Result:=0;
  end;
end;
function FreeMutex(const Mutex: PLongint): Integer;
begin
  if Mutex^ > 0
  then
    try
      TMutex(PtrUint(Mutex^)).Free;
      Result:=1;
    except
      Result:=0;
    end
  else
    Result:=0;
end;

END.
