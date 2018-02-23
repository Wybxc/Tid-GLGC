program GLGCMain;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Tid.GCObject in '..\Tid.GCObject.pas',
  Tid.GCObject.SmartPointer in '..\Tid.GCObject.SmartPointer.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    Writeln('GLGC Ver 0.0');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

