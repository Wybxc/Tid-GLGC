{------------------------------------------------------------------------------}
{                                                                              }
{                          基于垃圾回收框架的字符串                            }
{                                                                              }
{    作者: 忘忧北萱草                                                          }
{    Github 主页: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    版本: v1.1.1 dev 0310                                                     }
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

