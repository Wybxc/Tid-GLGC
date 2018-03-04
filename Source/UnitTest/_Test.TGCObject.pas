{------------------------------------------------------------------------------}
{

  测试结果: (循环1次, 步进倍率200时的内存占用记作1)
     +-----+------+-----+-----+-----+------+
     |     |  200 | 250 | 300 | 400 |  500 |
     +-----+------+-----+-----+-----+------+
     |  10 |  2.3 | 1.6 | 1.2 | 1.1 | 1.01 |
     +-----+------+-----+-----+-----+------+
     |  20 |  3.8 | 1.8 | 1.4 | 1.1 | 1.02 |
     +-----+------+-----+-----+-----+------+
     |  50 |  8.1 | 2.0 | 1.4 | 1.1 | 1.03 |
     +-----+------+-----+-----+-----+------+
     | 100 | 15.4 | 2.0 | 1.4 | 1.1 | 1.03 |
     +-----+------+-----+-----+-----+------+
  测试时间分析:
    1) 当步进倍率为200时, 用时不超过2秒.
    2) 循环数量为10或20时, 用时随步进倍率增长而增长.
    3) 循环数量为50或100时, 步进倍率250(含)以上时, 用时随步进倍率增长而减少.

                                                                               }
{------------------------------------------------------------------------------}
unit _Test.TGCObject;

interface

uses
  TestFramework, Tid.GCObject, Tid.GCObject.SmartPointer;

type
  TestGC = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGC;
    procedure TestGCs;
  end;

implementation

{ TestGC }

procedure TestGC.SetUp;
begin
  Randomize;
  TGCObject.GCStep := 200;
end;

procedure TestGC.TearDown;
begin
end;

procedure TestGC.TestGC;
var
  Arr: TGCObjects;
  i: Integer;
begin
  SetLength(Arr, 1);
  Arr[0] := TGCObject.LocalBegin;
  begin
    for i := 1 to High(Arr) do
      Arr[i] := TGCTableObject.Create(Arr[Random(i)]);
  end;
  TGCObject.LocalEnd;
end;

procedure TestGC.TestGCs;
var
  i: Integer;
begin
  for i := 1 to 1 do
    TestGC;
end;

initialization
  RegisterTest(TestGC.Suite);

end.

