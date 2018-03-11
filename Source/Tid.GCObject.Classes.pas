{------------------------------------------------------------------------------}
{                                                                              }
{                          �����������տ�ܵ��ַ���                            }
{                                                                              }
{    ����: ���Ǳ����                                                          }
{    Github ��ҳ: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    �汾: v1.1.1 dev 0310                                                     }
{------------------------------------------------------------------------------}

unit Tid.GCObject.Classes;

interface

uses
  Tid.GCObject;

type
  GC<T: class> = class(TGCUnitObject)
  private
    FObj: T;
  protected
    procedure Finalize; override;
  public
    constructor Create(const AObj: T; const Owner: TGCObject = nil);
    property Obj: T read FObj;
  end;

implementation

{ GC<T> }

constructor GC<T>.Create(const AObj: T; const Owner: TGCObject);
begin
  FObj := AObj;
end;

procedure GC<T>.Finalize;
begin
  FObj.Free;
  inherited;
end;

end.

