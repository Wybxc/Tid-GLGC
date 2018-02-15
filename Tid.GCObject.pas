unit Tid.GCObject;

interface

uses
  Tid.LinkedList;

type
  /// <remarks>
  /// 支持自动内存管理的对象.
  /// </remarks>
  TGCObject = class;

  /// <remarks>
  /// <see cref="Tid.GCObject.TGCObject">TGCObject</see> 的数组.
  /// </remarks>
  TGCObjects = array of TGCObject;

  TGCMark = Byte;

  /// <remarks>
  /// 全局内存管理器.
  /// </remarks>
  TGCManager = class
  public
    GCObjects: TLinkedList<TGCObject>;
    GCRoots: TLinkedList<TGCObject>;
      /// <summary>
      /// 添加子对象.
      /// </summary>
    procedure AddObject(const AGCObject: TGCObject);
    procedure AddRoot(const AGCRoot: TGCObject);
    procedure GarbageCollect;
    constructor Create;
    destructor Destroy; override;
  end;

  TGCObject = class
  private {friend}
      /// <summary>
      /// 对象中引用的其他对象.
      /// </summary>
    GCObjects: TGCObjects;
      /// <summary>
      /// 标记内容
      /// </summary>
    GCMark: TGCMark;
      /// <summary>
      /// 是否被标记.
      /// </summary>
    function IsMarked: Boolean; inline;
      /// <summary>
      /// 设置为标记状态.
      /// </summary>
    procedure SetMarked; inline;
    // 注意到没有取消标记的方法,
    // 因为这里用了一个神奇的小方法.
    // 在这一次检测时, 把 GCMark 最后一位为 1 记作被标记,
    // 那么下一次只要反转 MarkFlag,
    // 下一次的检测就会变为 GCMark 最后一位为 0 记作被标记.
  public
    class var
      GCManager: TGCManager;
      MarkFlag: TGCMark;
    class constructor CreateGCManager;
    class destructor DestroyGCManager;
  public
    constructor Create(AOwner: TGCObject);
      /// <summary>
      /// 添加子对象.
      /// </summary>
    procedure AddObject(const AGCObject: TGCObject); virtual;
  end;

implementation

{ TGCObject }

procedure TGCObject.AddObject(const AGCObject: TGCObject);
(*
  AddObject 的默认实现.
  此实现不保证效率, 具体使用时请使用子类中的针对场景优化的版本.
*)
var
  Len: Integer;
begin
  if not Assigned(GCObjects) then
    Len := 1
  else
    Len := Length(GCObjects) + 1;
  SetLength(GCObjects, Len);
  GCObjects[Len - 1] := AGCObject;
end;

constructor TGCObject.Create(AOwner: TGCObject);
begin
  AOwner.AddObject(Self);
end;

class constructor TGCObject.CreateGCManager;
begin
  TGCObject.GCManager := TGCManager.Create;
  TGCObject.MarkFlag := $01;
end;

class destructor TGCObject.DestroyGCManager;
begin
  TGCObject.GCManager.Free;
end;

function TGCObject.IsMarked: Boolean;
begin
  Result := not Boolean((GCMark xor MarkFlag) or $FE);
end;

procedure TGCObject.SetMarked;
begin
  GCMark := (GCMark and $FE) or (MarkFlag and $01);
end;

{ TGCManager }

procedure TGCManager.AddObject(const AGCObject: TGCObject);
begin
  GCObjects.Add(AGCObject);
end;

procedure TGCManager.AddRoot(const AGCRoot: TGCObject);
begin
  GCRoots.Add(AGCRoot);
  if not GCObjects.contains(AGCRoot) then
    GCObjects.Add(AGCRoot);
end;

constructor TGCManager.Create;
begin
  GCObjects := TLinkedList<TGCObject>.Create;
  GCRoots := TLinkedList<TGCObject>.Create;
end;

destructor TGCManager.Destroy;
begin
  GCObjects.Free;
  GCRoots.Free;
  inherited;
end;

procedure TGCManager.GarbageCollect;
var
  Root: TGCObject;
  Obj: TGCObject;
begin
  for Root in GCRoots do
  begin
    // 标记所有 Root 对象
    Root.SetMarked;
    // 标记每个 Root 对象内部的对象
    for Obj in Root.GCObjects do
      Obj.SetMarked;
  end;
  // 检查未标记的对象
  for Obj in GCObjects do
  begin
    if not Obj.IsMarked then
      Obj.Free;
  end;
end;

end.

