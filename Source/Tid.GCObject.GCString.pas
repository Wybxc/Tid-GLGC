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
{      ���� string �������� record �� case ����, ��������:                     }
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
    function GetChars(const Index: Integer): Char; inline;
    procedure SetChars(const Index: Integer; const Value: Char); inline;
  public
    property Str: string read GetStr write SetStr;
    property Chars[const Index: Integer]: Char read GetChars write SetChars; Default;
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

function TGCString.GetChars(const Index: Integer): Char;
begin
  Result := Str[Index];
end;

function TGCString.GetStr: string;
begin
  Result := FStr.Str;
end;

procedure TGCString.SetChars(const Index: Integer; const Value: Char);
begin
  FStr.FStr[Index] := Value;
end;

procedure TGCString.SetStr(const Value: string);
begin
  FStr.Str := Value;
end;

end.

