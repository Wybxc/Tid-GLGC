{------------------------------------------------------------------------------}
{

  ���Խ��: (ѭ��1��, ��������200ʱ���ڴ�ռ�ü���1)
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
  ����ʱ�����:
    1) ����������Ϊ200ʱ, ��ʱ������2��.
    2) ѭ������Ϊ10��20ʱ, ��ʱ�沽����������������.
    3) ѭ������Ϊ50��100ʱ, ��������250(��)����ʱ, ��ʱ�沽����������������.

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

