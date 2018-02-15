unit _Test.LinkedList;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  System.SysUtils, TestFramework, Tid.LinkedList;

type
  // Test methods for class TLinkedList

  TestTLinkedList = class(TTestCase)
  strict private
    FLinkedList: TLinkedList<Integer>;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAdd;
    procedure Testcontains;
  end;

implementation

type
  T = Integer;

procedure TestTLinkedList.SetUp;
begin
  FLinkedList := TLinkedList<Integer>.Create;
end;

procedure TestTLinkedList.TearDown;
begin
  FLinkedList.Free;
  FLinkedList := nil;
end;

procedure TestTLinkedList.TestAdd;
var
  Value: T;
  i: Integer;
begin
  for Value := 1 to 10 do
    FLinkedList.Add(Value);
  i := 1;
  for Value in FLinkedList do
  begin
    Check(Value = i, 'error at' + IntToStr(i));
    Inc(i);
  end;
end;

procedure TestTLinkedList.Testcontains;
var
  ReturnValue: Boolean;
  Value: T;
begin
  for Value := 1 to 10 do
    FLinkedList.Add(Value);
  ReturnValue := FLinkedList.contains(5);
  CheckTrue(ReturnValue, '5 error');
  ReturnValue := FLinkedList.contains(11);
  CheckFalse(ReturnValue, '11 error');
end;

initialization

// Register any test cases with the test runner
  RegisterTest(TestTLinkedList.Suite);

end.
