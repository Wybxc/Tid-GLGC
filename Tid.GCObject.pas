{------------------------------------------------------------------------------}
{                                                                              }
{                       标记-回收式垃圾回收器简易框架                          }
{                                                                              }
{    作者: 忘忧北萱草                                                          }
{    Github 主页: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    Licence: GNU Lesser General Public License v3.0 (LGPLv3)                  }
{                                                                              }
{    术语解释:                                                                 }
{       1) GCObject:    TGCObject 或其子类的一个实例.                          }
{       2) 子对象:      在 GCObject 中被引用的对象.                            }
{       3) 可达对象:    直接或间接被 GCRoot 引用的对象, 不会被回收.            }
{       4) GC标记:      在 GCObject 中表示 GCObject 状态的 Byte 值. 其最后一位 }
{                       用于垃圾回收中标记可达对象.                            }
{       5) GC根/GCRoot: 在垃圾回收时的默认可达对象.                            }
{       6) 公有GC根:    默认的 GCRoot                                          }
{       7) (*friend*):  表示此 private/protected 内的成员是友元属性.           }
{       8) 析构器:      指 TGCObject.Finalize.                                 }
{------------------------------------------------------------------------------}

unit Tid.GCObject;

interface

type                                                                            {(*}
  /// <remarks>支持自动内存管理的对象.</remarks>
  TGCObject = class;

  /// <remarks>GCObject 的动态数组. </remarks>
  TGCObjects = array of TGCObject;
  /// <remarks>GCObject 的链表.</remarks>
  TGCObjectList = class;

  /// <remarks>GCObject 的状态标记.</remarks>
  TGCMark = Byte;

  /// <remarks>全局内存管理器.</remarks>
  TGCManager = class                                                            {*)}
  private
    /// <summary>释放一系列 GCObject.</summary>
    /// <param name="Objects">TGCObjectList.(内容可能被更改)</param>
    class procedure FreeObjects(Objects: TGCObjectList); static;
  public
    GCObjects: TGCObjectList;
    GCRoots: TGCObjectList;
    /// <summary>添加子对象.</summary>
    procedure AddObject(const AGCObject: TGCObject);
    procedure AddRoot(const AGCRoot: TGCObject);
    procedure GarbageCollect;
    constructor Create;
    destructor Destroy; override;
  end;

  /// <remarks>支持自动内存管理的对象.</remarks>
  TGCObject = class
  private (*friend*) // GC标记:
    /// <summary>标记内容.</summary>
    GCMark: TGCMark;
    /// <summary>是否被标记.</summary>
    function IsMarked: Boolean; inline;
    /// <summary>设置为标记状态.</summary>
    procedure SetMarked; inline;
    { 注意到没有取消标记的方法, 因为这里用了一个神奇的小方法.
      在这一次检测时, 把 GCMark 最后一位为 1 记作被标记, 那么下一次只要反转 MarkFlag,
      检测就会变为 GCMark 最后一位为 0 记作被标记. }
  strict protected // 子对象支持:
    function GetGCRefObjects: TGCObjectList; virtual;
  protected (*friend*) // 需拓展/抽象方法:
    { 析构器的内容要写在这里.
      在 GCObject 被回收时, 要统一执行 Finalize 方法, 然后再 Free.
      这样可以避免因为释放的顺序而引起的问题. }
    procedure Finalize; virtual;
  public
    class var // GCManager 支持:
      GCManager: TGCManager;
      GlobalGCRoot: TGCObject;
      MarkFlag: TGCMark;
    class constructor CreateGCManager;
    class destructor DestroyGCManager;
    // 公有方法:
    constructor Create(Owner: TGCObject);
    destructor Destroy; override; final;
    /// <summary> 子对象列表. </summary>
    property GCRefObjects: TGCObjectList read GetGCRefObjects;
  end;

  /// <remarks>不含子对象的 GCObject.</remarks>
  TGCUnitObject = class(TGCObject)
  strict protected
    function GetGCRefObjects: TGCObjectList; override;
  end;

  /// <remarks>可能含有较多子对象的 GCObject.</remarks>
  TGCTableObject = class(TGCObject)
  strict protected
    FObjects: TGCObjectList;
    function GetGCRefObjects: TGCObjectList; override;
  protected
    constructor Create(AOwner: TGCObject);
    procedure Finalize; override;
  end;

  /// <remarks>公有GC根.</remarks>
  TGlobalGCRoot = class(TGCTableObject)
    constructor Create;
  end;

  /// <remarks>GCObject 的链表.</remarks>
  TGCObjectList = class
    type                                                                        {(*}
      PNode = ^TNode;
      TNode = record
        Data: TGCObject;
        Next: PNode;
      end;
  // 列表通用方法:                                                              {*)}
  public
    Head, Tail: PNode;
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AObj: TGCObject); inline;
    procedure Clear;
    procedure Delete(const Obj: TGCObject);
    function IsEmpty: Boolean; inline;
  // 内存管理特有方法:                                                          {(*}
  {$IFDEF DEBUG}public
  {$ELSE}private (*friend*){$ENDIF}                                             {*)}
    procedure GCMarkAllObjects;
    procedure GCMarkRefObjects;
    function GCExtractObjects(const Marked: Boolean; const AutoFinalize: Boolean = True): TGCObjectList;
    procedure GCFinalize;
    procedure GCFree;
  end;

implementation

uses
  System.SysUtils;

type
  EGCUnit = class(Exception)
  end;

{ TGCObject }

constructor TGCObject.Create(Owner: TGCObject);
var
  RefOfOwner: TGCObjectList;
begin
  // 默认添加为公有GC根的子对象.
  if not Assigned(Owner) then
    Owner := GlobalGCRoot;

  // 添加为 Owner 的子对象.
  RefOfOwner := Owner.GCRefObjects;
  if Assigned(RefOfOwner) then
    RefOfOwner.Add(Self)
  else
    raise EGCUnit.CreateFmt('TGCObject/TGCUnit 对象 %p 不能添加子对象 %p!', [Pointer(Owner), Pointer(Self)]);

  // 交由 GCManager 管理.
  GCManager.GCObjects.Add(Self);

  GCMark := not MarkFlag;
end;

class constructor TGCObject.CreateGCManager;
begin
  // 初始化 GCManager.
  TGCObject.GCManager := TGCManager.Create;
  TGCObject.MarkFlag := $01;
  // 初始化公有GC根.
  TGCObject.GlobalGCRoot := TGlobalGCRoot.Create;
  TGCObject.GCManager.AddRoot(TGCObject.GlobalGCRoot);
end;

destructor TGCObject.Destroy;
begin
  // 这个 Distroy 只是为了防止子类在 Destroy 中执行操作.
  // 所以设置为 final.
  // 不执行任何实际操作.
  // 子类的析构应写在 Finalize 中.
  inherited;
end;

class destructor TGCObject.DestroyGCManager;
begin
  TGCObject.GCManager.Free;
end;

procedure TGCObject.Finalize;
begin
  // Do Nothing.
end;

function TGCObject.GetGCRefObjects: TGCObjectList;
begin
  Result := nil;
end;

function TGCObject.IsMarked: Boolean;
//const
//  MarkMask = $FE;
begin
  Result := (GCMark and 1) = (MarkFlag and 1);
end;

procedure TGCObject.SetMarked;
const
  MarkMask = $FE;
begin
  GCMark := (GCMark and MarkMask) or (MarkFlag and (not MarkMask));
  Assert(IsMarked);
end;

{ TGCManager }

procedure TGCManager.AddObject(const AGCObject: TGCObject);
begin
  GCObjects.Add(AGCObject);
end;

procedure TGCManager.AddRoot(const AGCRoot: TGCObject);
begin
  GCRoots.Add(AGCRoot);
end;

constructor TGCManager.Create;
begin
  GCObjects := TGCObjectList.Create;
  GCRoots := TGCObjectList.Create;
end;

destructor TGCManager.Destroy;
begin
  GarbageCollect;
  FreeObjects(GCObjects);
  inherited;
end;

{ 这里讲一下下面的过程的原理.
  在释放对象时, 要考虑对象之间的引用关系, 否则可能会出现对象在析构器中访问已经释放的对象的情况.
  这里使用了类似于 GarbageCollect 的方法, 标记所有被其他对象引用的对象.
  然后释放掉没有被引用的对象, 反复循环直到所有对象都被标记.
  剩余的对象是含有循环引用的对象, 最后释放. }
class procedure TGCManager.FreeObjects(Objects: TGCObjectList);

  function Step(Objects: TGCObjectList): Boolean; inline; // 一次扫描&释放, 返回是否继续扫描.
  var
    Deleted: TGCObjectList;
  begin
    Result := True;
    // 标记所有被引用的对象
    Objects.GCMarkRefObjects;
    // 检查未标记的对象
    Deleted := Objects.GCExtractObjects(False);
    if Deleted.IsEmpty then
      Exit(False);
    // 释放
    Deleted.GCFinalize;
    Deleted.GCFree;
    Deleted.Free;
  end;

var
  mFlag: Byte;
begin
  if not Assigned(Objects) then
    Exit;
  mFlag := TGCObject.MarkFlag;
  while Step(Objects) do
    // 重设已标记对象为未标记.
    TGCObject.MarkFlag := not TGCObject.MarkFlag;
  // 释放剩余的对象.
  Objects.GCFinalize;
  Objects.GCFree;
  // 恢复 MarkFlag.
  TGCObject.MarkFlag := mFlag;
end;

procedure TGCManager.GarbageCollect;
var
  Deleted: TGCObjectList;
begin
  // 标记所有可达对象.
  GCRoots.GCMarkAllObjects;
  // 检查未标记的对象, 不进行 Finalize.
  Deleted := GCObjects.GCExtractObjects(False, False);
  // 释放.
  FreeObjects(Deleted);
  Deleted.Free;
  // 重设已标记对象为未标记.
  TGCObject.MarkFlag := not TGCObject.MarkFlag;
end;

{ TGCTableObject }

constructor TGCTableObject.Create(AOwner: TGCObject);
begin
  inherited;
  FObjects := TGCObjectList.Create;
end;

procedure TGCTableObject.Finalize;
begin
  FObjects.Free;
end;

function TGCTableObject.GetGCRefObjects: TGCObjectList;
begin
  Result := FObjects;
end;

{ TGCObjectList }

procedure TGCObjectList.Add(const AObj: TGCObject);
var
  p: PNode;
begin
  // 新建节点.
  New(p);
  p^.Data := AObj;
  p^.Next := nil;
  // 连接到表尾.
  Tail^.Next := p;
  // 维护 Tail.
  Tail := p;
end;

procedure TGCObjectList.Clear;
var
  p, q: PNode;
begin
  // p: 当前访问节点.
  // q: p 的下一个节点.
  p := Head^.Next;
  while Assigned(p) do
  begin
    q := p^.Next;
    // 释放.
    Dispose(p);
    // 下移
    p := q;
  end;
  // 维护 Head 和 Tail.
  Head^.Next := nil;
  Tail := Head;
end;

constructor TGCObjectList.Create;
begin
  New(Head);
  Head^.Data := nil;
  Head^.Next := nil;
  Tail := Head;
end;

destructor TGCObjectList.Destroy;
begin
  Clear;
  inherited;
end;

function TGCObjectList.GCExtractObjects(const Marked: Boolean; const AutoFinalize: Boolean): TGCObjectList;
var
  p, q: PNode;
begin
  // p: 当前访问节点的上一个节点.
  // q: 当前访问节点.
  p := Head;
  q := p^.Next;
  Result := TGCObjectList.Create;
  while q <> nil do
  begin
    if not (q^.Data.IsMarked xor Marked) then
    begin
      // 将 q 从链表中断开.
      p^.Next := q^.Next;
      // 连接到新链表.
      q^.Next := nil;
      Result.Tail^.Next := q;
      Result.Tail := q;
      // 自动 Finalize.
      if AutoFinalize then
        q^.Data.Finalize;
    end;
    // 下一个.
    p := p^.Next;
    q := p^.Next;
  end;
end;

procedure TGCObjectList.GCFinalize;
var
  p: PNode;
begin
  // p: 当前访问的节点.
  p := Head^.Next;
  while p <> nil do
  begin
    p^.Data.Finalize;
    p := p^.Next;
  end;
end;

procedure TGCObjectList.GCFree;
var
  p: PNode;
begin
  // p: 当前访问的节点.
  p := Head^.Next;
  while p <> nil do
  begin
    p^.Data.Free;
    p := p^.Next;
  end;
end;

procedure TGCObjectList.GCMarkAllObjects;
var
  p: PNode;
  Objects: TGCObjectList;
begin
  // p: 当前访问的节点.
  p := Head^.Next;
  while p <> nil do
  begin
    with p^.Data do
    begin
      // 标记列表中的对象自身.
      SetMarked;
      // 递归标记被引用的列表.
      Objects := GCRefObjects;
      if Assigned(Objects) then
        Objects.GCMarkAllObjects;
    end;
    p := p^.Next;
  end;
end;

procedure TGCObjectList.GCMarkRefObjects;
var
  p: PNode;
  Objects: TGCObjectList;
begin
  p := Head^.Next;
  while p <> nil do
  begin
    with p^.Data do
    begin
      // 没有标记列表中的对象自身.
      // 递归标记被引用的列表.
      Objects := GCRefObjects;
      if Assigned(Objects) then
        Objects.GCMarkRefObjects;
    end;
    p := p^.Next;
  end;
end;

function TGCObjectList.IsEmpty: Boolean;
begin
  Result := Head^.Next = nil;
end;

procedure TGCObjectList.Delete(const Obj: TGCObject);
var
  p, q: PNode;
begin
  // p: 当前访问节点的上一个节点.
  // q: 当前访问节点.
  p := Head;
  while Assigned(p^.Next) do
  begin
    q := p^.Next;
    if q^.Data = Obj then
    begin
      // 将 q 从链表中断开.
      p^.Next := q^.Next;
      // 释放, 没有释放 Obj.
      Dispose(q);
    end
    else
    // 下一个.
      p := p^.Next;
  end;
  // 维护 Tail.
  Tail := p;
end;

{ TGCUnitObject }

function TGCUnitObject.GetGCRefObjects: TGCObjectList;
begin
  Result := nil;
end;

{ TGlobalGCRoot }

constructor TGlobalGCRoot.Create;
begin
  FObjects := TGCObjectList.Create;
  GCMark := not MarkFlag;
end;

end.

