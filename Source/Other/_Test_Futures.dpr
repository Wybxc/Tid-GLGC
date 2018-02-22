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

//// 取得当前进程占用内存
//function CurrentMemoryUsage: Cardinal;
//var
//  pmc: TProcessMemoryCounters;
//begin
//  pmc.cb := SizeOf(pmc);
//  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
//    Result := pmc.WorkingSetSize
//  else
//    RaiseLastOSError;
//end;

var
  p: Pointer;

const
  GCMark = 255;
  MarkFlag = 254;
  MarkMask = $FE;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    Writeln(TObject.InstanceSize);
    Writeln(TLiteClass.InstanceSize);
    Writeln(TMyClass.InstanceSize);
    Writeln(not Boolean((GCMark xor MarkFlag) or MarkMask));
//    Writeln(Format('New Instance in %p', [Pointer(@TLiteClass.NewInstance)]));
//    SetLength(Arr, 100000);
//    for i := Low(Arr) to High(Arr) do
//    begin
//      Arr[i] := TMyClass.Create;
//      Arr[i].Data := i;
//      Arr[i].Next := Arr[i];
//    end;
//    Writeln(CurrentMemoryUsage);
//    Writeln(Arr[0].ClassName);
//    for i := Low(Arr) to High(Arr) do
//    begin
//      Assert(Arr[i].GetData = i);
//      Assert(Arr[i].Next = Arr[i]);
//    end;
//    for i := Low(Arr) to High(Arr) do
//      Arr[i].Free;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

