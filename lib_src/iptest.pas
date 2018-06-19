(* ======================================================================== *)
(* PeopleRelay: iptest.pas Version: 0.3.5.3                                 *)
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

unit iptest;

{$mode objfpc}{$H+}

{$define _INDY_LIB}
{$define _Sc_Thread}

interface

uses
  SysUtils
  {$Ifdef Sc_Thread}
  ,Classes
  {$endIf}
  {$Ifdef INDY_LIB}
  ,IdGlobal,IdTCPClient
  {$else},blcksock{$endIf};

{$Ifdef Sc_Thread}
type TSThread = class(TThread)
private
  FHost       : string;
  FPort,
  FTimeOut    : Integer;
public
  procedure Execute; override;
end;
{$endIf}

function CanConnect(const Host: PChar; const Port,TimeOut: PInteger): Integer; cdecl; export;

implementation

function IsIP6(const Value: string): Boolean;
begin
  Result:=Pos(':',Value) > 0;
end;
{$Ifdef Sc_Thread}
procedure TSThread.Execute;
var
  tcp: {$Ifdef INDY_LIB}TIdTCPClient{$else}TTCPBlockSocket{$endIf};
begin
  try
    {$Ifdef INDY_LIB}
    tcp:=TIdTCPClient.Create(nil);
    try
      if IsIP6(FHost) then tcp.IPVersion:=Id_IPv6;
      tcp.ConnectTimeout:=FTimeOut;
      tcp.Connect(FHost,FPort);
      ReturnValue:=Ord(tcp.Connected);
      {$else}
      tcp:=TTCPBlockSocket.Create;
      try
        if IsIP6(FHost) then tcp.Family:=SF_IP6;
        tcp.ConnectionTimeout:=FTimeOut;
        tcp.Connect(FHost,IntToStr(FPort));
        ReturnValue:=Ord(tcp.LastError=0);
      {$endIf}
    finally
      try tcp.Free; except end;
    end;
  except
    ReturnValue:=0;
  end;
end;
{$endIf}
function CanConnect(const Host: PChar; const Port,TimeOut: PInteger): Integer; cdecl; export;
var
  {$Ifdef Sc_Thread}
  s: String;
  t: TSThread;
  {$endIf}
  tcp: {$Ifdef INDY_LIB}TIdTCPClient{$else}TTCPBlockSocket{$endIf};
begin
  if (Host = '')
    or (Port^ <= 0)
    or (TimeOut^ < 0)
  then
    begin
      Result:=0;
      exit;
    end;
{$Ifdef Sc_Thread}
  try
    t:=TSThread.Create(True);
    s:=Host; UniqueString(s);
    t.FHost:=s;
    t.FPort:=Port^;
    t.FTimeOut:=TimeOut^;
    t.FreeOnTerminate := True;
    t.Start;
    t.WaitFor;
    Result:=t.ReturnValue;
  except
    Result:=0;
  end;
{$else}
  try
    {$Ifdef INDY_LIB}
    tcp:=TIdTCPClient.Create(nil);
    try
      if IsIP6(Host) then tcp.IPVersion:=Id_IPv6;
      tcp.ConnectTimeout:=Timeout^;
      tcp.Connect(Host,Port^);
      Result:=Ord(tcp.Connected);
    {$else}
    tcp:=TTCPBlockSocket.Create;
    try
      if IsIP6(Host) then tcp.Family:=SF_IP6;
      tcp.ConnectionTimeout:=TimeOut^;
      tcp.Connect(Host,IntToStr(Port^));
      Result:=Ord(tcp.LastError=0);
    {$endIf}
    finally
      try tcp.Free; except end;
    end;
  except
    Result:=0;
  end;
{$endIf}
end;

END.

