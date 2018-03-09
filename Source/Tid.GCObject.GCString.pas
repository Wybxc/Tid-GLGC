{------------------------------------------------------------------------------}
{                                                                              }
{                          �����������տ�ܵ��ַ���                            }
{                                                                              }
{    ����: ���Ǳ����                                                          }
{    Github ��ҳ: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    �汾: v1.1.0 dev 0223                                                     }
{                                                                              }
{    Licence: GNU Lesser General Public License v3.0 (LGPLv3)                  }
{                                                                              }
{    ΪʲôҪ�������Ԫ:                                                       }
{        Delphi �� string ����������ü������ڴ����, ��������Ҫ������ڴ����.}
{    ���� string �������� record �� case ����, ��������:                       }
{           type r = record                                                    }
{             case Byte of                                                     }
{              0:(a:string;);                                                  }
{           end;                                                               }
{      �������벻ͨ��. һ���������ǰ��ַ�����װ��Ϊ��ͨ����, �ٽ����������߽���}
{      �ڴ����. ����Ǳ���Ԫ������.                                           }
{------------------------------------------------------------------------------}
unit Tid.GCObject.GCString;

interface

uses
  Tid.GCObject;

type
  /// <remarks>֧���Զ��ڴ����� string.</remarks>
  TGCString = record
  public
    type
      TStringObject = class(TGCUnitObject)
      private
        FStr: string;
      public
        constructor Create(const AStr: string; const Owner: TGCObject = nil);
        property Str: string read FStr write FStr;
      end;
  private
    FStr: TStringObject;
    function GetStr: string; inline;
    procedure SetStr(const Value: string); inline;
    function GetChars(const index: Integer): Char; inline;
    procedure SetChars(const index: Integer; const Value: Char); inline;
  public
    property Str: string read GetStr write SetStr;
    property Chars[const index: Integer]: Char read GetChars write SetChars; Default;
    {$REGION 'Operator Overload'}
    class operator Implicit(const s: string): TGCString; overload; inline;
    class operator Implicit(const s: TGCString): string; overload; inline;
    class operator Equal(const a, b: TGCString): Boolean; inline;
    class operator NotEqual(const a, b: TGCString): Boolean; inline;
    class operator GreaterThan(const a, b: TGCString): Boolean; inline;
    class operator GreaterThanOrEqual(const a, b: TGCString): Boolean; inline;
    class operator LessThan(const a, b: TGCString): Boolean; inline;
    class operator LessThanOrEqual(const a, b: TGCString): Boolean; inline;
    class operator Add(const a, b: TGCString): string; inline;
    {$ENDREGION}
  end;

implementation

uses
  System.SysUtils;

{ TGCString.TStringObject }

constructor TGCString.TStringObject.Create(const AStr: string; const Owner: TGCObject);
begin
  inherited Create(Owner);
  FStr := AStr;
end;

{ TGCString }

class operator TGCString.Add(const a, b: TGCString): string;
begin
  Result := a.Str + b.Str;
end;

class operator TGCString.Equal(const a, b: TGCString): Boolean;
begin
  Result := a.Str = b.Str;
end;

function TGCString.GetChars(const Index: Integer): Char;
begin
  Result := Str[Index];
end;

function TGCString.GetStr: string;
begin
  if not Assigned(FStr) then
    FStr := TStringObject.Create('');
  Result := FStr.Str;
end;

class operator TGCString.GreaterThan(const a, b: TGCString): Boolean;
begin
  Result := a.Str > b.Str;
end;

class operator TGCString.GreaterThanOrEqual(const a, b: TGCString): Boolean;
begin
  Result := a.Str >= b.Str;
end;

class operator TGCString.Implicit(const s: string): TGCString;
begin
  inherited;
  Result.Str := s;
end;

class operator TGCString.Implicit(const s: TGCString): string;
begin
  Result := s.Str;
end;

class operator TGCString.LessThan(const a, b: TGCString): Boolean;
begin
  Result := a.Str < b.Str;
end;

class operator TGCString.LessThanOrEqual(const a, b: TGCString): Boolean;
begin
  Result := a.Str <= b.Str;
end;

class operator TGCString.NotEqual(const a, b: TGCString): Boolean;
begin
  Result := a.Str <> b.Str;
end;

procedure TGCString.SetChars(const Index: Integer; const Value: Char);
begin
  FStr.FStr[Index] := Value;
end;

procedure TGCString.SetStr(const Value: string);
begin
  FStr := TStringObject.Create(Value);
end;

end.

