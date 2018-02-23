{------------------------------------------------------------------------------}
{                                                                              }
{                         �����������տ�ܵ�����ָ��                           }
{                                                                              }
{    ����: ���Ǳ����                                                          }
{    Github ��ҳ: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    �汾: v1.1.0 dev 0223                                                     }
{                                                                              }
{    Licence: GNU Lesser General Public License v3.0 (LGPLv3)                  }
{                                                                              }
{------------------------------------------------------------------------------}
unit Tid.GCObject.SmartPointer;

interface

uses
  Tid.GCObject;

type
  /// <remarks><para>����ָ��(Pointer ����).</para>
  /// <para>������ָ��ָ������ݰ����������õ����.</para>
  /// <para>ָ�������ʹ�� New/GetMem/GetMemory ������ڴ�.</para>
  /// </remarks>
  TSmartPointer = class(TGCUnitObject)
  private
    FPtr: Pointer;
    procedure SetPtr(const Value: Pointer); inline;
  protected
    procedure Finalize; override;
  public
    constructor Create(const APtr: Pointer = nil; const Owner: TGCObject = nil);
    property Ptr: Pointer read FPtr write SetPtr;
  end;

  /// <remarks><para>����ָ��(����).</para>
  /// <para>������ָ��ָ������ݰ����������õ����.</para>
  /// <para>ָ�������ʹ�� New/GetMem/GetMemory ������ڴ�.</para>
  /// </remarks>
  P<T> = class(TGCUnitObject)
  private
    FPtr: Pointer;
    function GetValue: T;
    procedure SetPtr(const Value: Pointer); inline;
    procedure SetValue(const Value: T);
  protected
    procedure Finalize; override;
  public
    constructor Create(const APtr: Pointer = nil; const Owner: TGCObject = nil); overload;
    constructor Create(const AValue: T; const Owner: TGCObject = nil); overload;
    property Ptr: Pointer read FPtr write SetPtr;
    property Value: T read GetValue write SetValue;
  end;

implementation

{ TSmartPointer }

constructor TSmartPointer.Create(const APtr: Pointer; const Owner: TGCObject);
begin
  inherited Create(Owner);
  FPtr := APtr;
end;

procedure TSmartPointer.Finalize;
begin
  if Assigned(FPtr) then
    FreeMem(FPtr);
end;

procedure TSmartPointer.SetPtr(const Value: Pointer);
begin
  FPtr := Value;
end;

{ P<T> }

constructor P<T>.Create(const APtr: Pointer; const Owner: TGCObject);
begin
  inherited Create(Owner);
  FPtr := APtr;
  if not Assigned(FPtr) then
    GetMem(FPtr, SizeOf(T));
end;

constructor P<T>.Create(const AValue: T; const Owner: TGCObject);
begin
  inherited Create(Owner);
  GetMem(FPtr, SizeOf(T));
  Value := AValue;
end;

procedure P<T>.Finalize;
begin
  if Assigned(FPtr) then
    FreeMem(FPtr);
end;

function P<T>.GetValue: T;
begin
  // ����ʹ�� ^T ����, Ҫô IDE ����, Ҫô����������.
  // ���Բ��� Move.
  Result := Default(T);
  if Assigned(FPtr) then
    Move(FPtr^, Result, SizeOf(T));
end;

procedure P<T>.SetPtr(const Value: Pointer);
begin
  FPtr := Value;
end;

procedure P<T>.SetValue(const Value: T);
begin
  Move(Value, FPtr^, SizeOf(T));
end;

end.

