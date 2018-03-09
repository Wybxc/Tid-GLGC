program _Test_GLGC;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DunitTestRunner,
  Winapi.Windows,
  Winapi.PsAPI,
  Tid.GCObject in '..\Tid.GCObject.pas',
  _Test.SmartPointer in '_Test.SmartPointer.pas',
  Tid.GCObject.SmartPointer in '..\Tid.GCObject.SmartPointer.pas',
  System.SysUtils,
  _Test.TGCObject in '_Test.TGCObject.pas',
  _Test.GCString in '_Test.GCString.pas',
  _Test.TGCObjectList in '_Test.TGCObjectList.pas',
  Tid.GCObject.GCString in '..\Tid.GCObject.GCString.pas';

{$R *.RES}

// 取得当前进程占用内存
function CurrentMemoryUsage: Cardinal;
var
  pmc: TProcessMemoryCounters;
begin
  Result := 0;
  pmc.cb := SizeOf(pmc);
  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
    Result := pmc.WorkingSetSize
  else
    RaiseLastOSError;
end;

var
  i1, i2: Integer;

begin
  ReportMemoryLeaksOnShutdown := True;
  i1 := CurrentMemoryUsage;
  Writeln(Format('Memory Use: %d', [i1]));
  DunitTestRunner.RunRegisteredTests;
  i2 := CurrentMemoryUsage;
  Writeln(Format('Memory Use: %d', [i2]));
  Writeln(Format('Memory Ration: %f', [i2 / i1 * 0.588235294]));
  Readln;
end.

