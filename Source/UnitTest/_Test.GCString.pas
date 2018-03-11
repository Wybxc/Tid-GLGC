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

  TestGCStringBuilder = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
  end;

implementation

uses
  System.SysUtils;

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
  ch: Char;
  i: Integer;
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
  s.Append('1');
  CheckTrue('21' = s);
  c := '21';
  CheckTrue(s.GetHashCode = TGCString(c).GetHashCode);
  s := '11111111';
  i := 0;
  for ch in s do
  begin
    CheckTrue(ch = '1');
    Inc(i);
  end;
  CheckEquals(i, 8);
  TGCObject.LocalEnd;
end;

{ TestGCStringBuilder }

procedure TestGCStringBuilder.SetUp;
begin
  inherited;
  LocalBegin;
end;

procedure TestGCStringBuilder.TearDown;
begin
  inherited;
  LocalEnd;
end;

procedure TestGCStringBuilder.Test;
var
  s: TGCStringBuilder;
begin
  s := TGCStringBuilder.Create('1');
  s.Append(s);
  CheckTrue(s.ToString = '11');
  s.Replace('1', '2');
  CheckTrue(s.ToString = '22');
  s.Append(3);
  s[0] := '1';
  CheckTrue(s.ToString = '123');
end;

initialization
  RegisterTest(TestGCString.Suite);
  RegisterTest(TestGCStringBuilder.Suite);

end.

