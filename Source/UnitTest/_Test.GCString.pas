unit _Test.GCString;

interface

uses
  TestFramework, Tid.GCObject, Tid.GCObject.GCString;

type
  TestGCString = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
  end;

implementation

{ TestGCString }

procedure TestGCString.SetUp;
begin
  inherited;
end;

procedure TestGCString.TearDown;
begin
  inherited;
end;

procedure TestGCString.Test;
var
  s: TGCString;
  c: string;
begin
  TGCObject.LocalBegin;
  s.Str := '2';
  CheckTrue(s.Str = '2');
  CheckTrue(s <> '3');
  CheckTrue(s > '1');
  CheckTrue(s <= '4');
  c := s;
  s := c;
  CheckTrue(c = s);
  TGCObject.LocalEnd;
end;

initialization
  RegisterTest(TestGCString.Suite);

end.

