program _Test_Futures;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  winapi.Windows,
  winapi.PsAPI;

type
  TLiteClass = class
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;

{ TLiteClass }

procedure TLiteClass.FreeInstance;
begin
  FreeMemory(Pointer(Self));
end;

class function TLiteClass.NewInstance: TObject;
//  GetMem(Pointer(Result), InstanceSize - 4);
//  PPointer(Result)^ := Pointer(Self);
asm
        PUSH    EAX
        MOV     EAX, [EAX].vmtInstanceSize
        SUB     EAX, 4                          // EAX := InstanceSize - 4;
        PUSH    EAX
        CALL    GetMemory
        ADD     ESP, 4                          // EAX := GetMemory(EAX);
        POP     [EAX]
end;

type
  TMyClass = class(TLiteClass)
    Data: Integer;
    Next: TMyClass;
    function GetData: Integer;
  end;

{ TMyClass }

function TMyClass.GetData;
begin
  Result := Data;
end;

var
  s: string;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    s := '123456789';
    Writeln(s[1]);
    Writeln(Length(s));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

