program cdr2svg;

{$mode delphi}

// Console converter: CorelDRAW (.cdr) -> SVG, using XelCdr.
// Usage: cdr2svg input.cdr [output.svg]
// Author: xelitan.com
// License: MIT
// Requires: XelImageFormats package

uses
  SysUtils, Classes, XelCdr;

function ReadFileBytes(const FileName: string): TBytes;
var
  Str: TFileStream;
begin
  Str := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Result, Str.Size);
    if Length(Result) > 0 then
      Str.ReadBuffer(Result[0], Length(Result));
  finally
    Str.Free;
  end;
end;

procedure WriteFileText(const FileName: string; const Text: string);
var
  Str: TFileStream;
begin
  Str := TFileStream.Create(FileName, fmCreate);
  try
    if Length(Text) > 0 then
      Str.WriteBuffer(Text[1], Length(Text));
  finally
    Str.Free;
  end;
end;

var
  InName, OutName, Svg: string;
  Data: TBytes;
  W, H: Integer;
begin
  if (ParamCount < 1) or (ParamCount > 2) then
  begin
    WriteLn('cdr2svg - converts a CorelDRAW drawing to SVG');
    WriteLn('Usage: cdr2svg input.cdr [output.svg]');
    ExitCode := 1;
    Exit;
  end;

  InName := ParamStr(1);
  if ParamCount = 2 then OutName := ParamStr(2)
  else OutName := ChangeFileExt(InName, '.svg');

  try
    Data := ReadFileBytes(InName);
    if not IsCdr(Data) then
      raise ECdrError.Create('not a CorelDRAW 6+ file');

    Svg := CdrToSvg(Data, W, H);
    WriteFileText(OutName, Svg);
    WriteLn(Format('%s -> %s (%d x %d px)', [InName, OutName, W, H]));
  except
    on E: Exception do
    begin
      WriteLn(ErrOutput, 'Error: ', InName, ': ', E.Message);
      ExitCode := 2;
    end;
  end;
end.
