unit _Test.TGCObjectList;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, Tid.GCObject;

type
  // Test methods for class TGCObjectList

  TestTGCObjectList = class(TTestCase)
  strict private
    FGCObjectList: TGCObjectList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAdd;
    procedure TestClear;
    procedure TestDelete;
    procedure TestIsEmpty;
  end;

implementation

procedure TestTGCObjectList.SetUp;
begin
  FGCObjectList := TGCObjectList.Create;
end;

procedure TestTGCObjectList.TearDown;
begin
  FGCObjectList.Free;
  FGCObjectList := nil;
end;

procedure TestTGCObjectList.TestAdd;
var
  Obj: TGCObject;
begin
  Obj := TGCObject.Create(nil);
  FGCObjectList.Add(Obj);

  CheckFalse(FGCObjectList.IsEmpty);
  CheckTrue(FGCObjectList.Head^.Next^.Data = Obj);
end;

procedure TestTGCObjectList.TestClear;
var
  Obj: TGCObject;
begin
  Obj := TGCObject.Create(nil);
  FGCObjectList.Add(Obj);

  CheckFalse(FGCObjectList.IsEmpty);
  FGCObjectList.Clear;
  CheckTrue(FGCObjectList.IsEmpty);

end;

procedure TestTGCObjectList.TestDelete;
var
  Obj: TGCObject;
begin
  Obj := TGCObject.Create(nil);
  FGCObjectList.Add(Obj);

  CheckFalse(FGCObjectList.IsEmpty);
  FGCObjectList.Delete(Obj);
  CheckTrue(FGCObjectList.IsEmpty);

end;

procedure TestTGCObjectList.TestIsEmpty;
var
  Obj: TGCObject;
begin
  CheckTrue(FGCObjectList.IsEmpty);

  Obj := TGCObject.Create(nil);
  FGCObjectList.Add(Obj);

  CheckFalse(FGCObjectList.IsEmpty);
  FGCObjectList.Clear;
  CheckTrue(FGCObjectList.IsEmpty);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTGCObjectList.Suite);

end.
