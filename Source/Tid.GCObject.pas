{------------------------------------------------------------------------------}
{                                                                              }
{                       标记-回收式垃圾回收器简易框架                          }
{                                                                              }
{    作者: 忘忧北萱草                                                          }
{    Github 主页: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    版本: v1.1.1 dev 0310                                                     }
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
{       6) 公有GC根:    默认的 GCRoot, 是 LocalGCRoots 的第一个元素.           }
{       7) (*friend*):  表示此 private/protected 内的成员可以被本单元的其他对象}
{                       访问.                                                  }
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
    procedure GarbageCollectStep;
    procedure GarbageCollectRestart;
  public
    GCObjects: TGCObjectList;
    GCRoots: TGCObjectList;
    GCUnscanned: TGCObjectList;
    GCGarbage: TGCObjectList;
    /// <summary>添加子对象.</summary>
    procedure AddObject(const AGCObject: TGCObject);
    procedure AddRoot(const AGCRoot: TGCObject);
    procedure GarbageCollectFull;
    procedure GarbageCollectSteps; inline;
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
    procedure Init; {$IFNDEF DEBUG} inline;{$ENDIF}
  {$IFDEF DEBUG}
  public
    Name: string;
  {$ENDIF}
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
      LocalGCRoots: TGCObjectList;
      GCStep, GCStepCount: Integer;
      MarkFlag: TGCMark;
    class constructor CreateGCManager;
    class destructor DestroyGCManager;
    class function LocalBegin: TGCObject; inline; static;
    class procedure LocalEnd; inline; static;
    // 公有方法:
    constructor Create(Owner: TGCObject);
    destructor Destroy; override; final;
    function GetHashCode: Integer; override;
    /// <summary> 子对象列表. </summary>
    property GCRefObjects: TGCObjectList read GetGCRefObjects;
  end;

  /// <remarks>不含子对象的 GCObject.</remarks>
  TGCUnitObject = class(TGCObject)
  strict protected
    function GetGCRefObjects: TGCObjectList; override;
  public
    constructor Create(const Owner: TGCObject = nil);
  end;

  /// <remarks>可能含有较多子对象的 GCObject.</remarks>
  TGCTableObject = class(TGCObject)
  strict protected
    FObjects: TGCObjectList;
    function GetGCRefObjects: TGCObjectList; override;
  public
    constructor Create(Owner: TGCObject);
    procedure Finalize; override;
  end;

  /// <remarks>公有GC根.</remarks>
  TGCRootObject = class(TGCTableObject)
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
  private {friend}                                                              {*)}
    DisableListen: Boolean;
    {$IFDEF DEBUG}
    ID: Integer;
    {$ENDIF}
  // 列表通用方法:
  public
    Head, Tail: PNode;
    constructor Create(const Linstening: Boolean = True);
    destructor Destroy; override;
    procedure Add(const AObj: TGCObject); overload; inline;
      /// <param name="List">TGCObjectList</param>
      /// <param name="CanModify">操作类型: 0: 复制(默认值); 1: 直接连接; 2: 连接且释放原链表.</param>
    procedure Add(List: TGCObjectList; const CanModify: Byte = 0); overload;
    procedure Clear;
    procedure Delete(const Obj: TGCObject);
    function IsEmpty: Boolean; inline;
    function Pop: TGCObject; inline;
    function ExtractFirst: TGCObject; inline;
  // 内存管理特有方法:                                                          {(*}
  {$IFDEF DEBUG}
  public
  {$ELSE}private (*friend*){$ENDIF}                                             {*)}
    function GCExtractObjects(const Marked: Boolean; const AutoFinalize: Boolean = True): TGCObjectList;
    procedure GCFinalize;
    procedure GCFree;
  end;

function GCManager: TGCManager; inline;

function LocalBegin: TGCObject; inline;

procedure LocalEnd; inline;

implementation

uses
  System.SysUtils, System.Classes;

type
  EGCUnit = class(Exception)
  end;

function GCManager: TGCManager; inline;
begin
  Result := TGCObject.GCManager;
end;

function LocalBegin: TGCObject; inline;
begin
  Result := TGCObject.LocalBegin;
end;

procedure LocalEnd; inline;
begin
  TGCObject.LocalEnd;
end;

{ TGCObject }

constructor TGCObject.Create(Owner: TGCObject);
var
  RefOfOwner: TGCObjectList;
begin
  // 默认添加为公有GC根的子对象.
  if not Assigned(Owner) then
    Owner := LocalGCRoots.Tail^.Data;

  // 添加为 Owner 的子对象.
  RefOfOwner := Owner.GCRefObjects;
  if Assigned(RefOfOwner) then
    RefOfOwner.Add(Self)
  else
    raise EGCUnit.CreateFmt('TGCObject/TGCUnit 对象 %p 不能添加子对象 %p!', [Pointer(Owner), Pointer(Self)]);

  Init;
end;

class constructor TGCObject.CreateGCManager;
begin
  // 初始化 GCManager.
  GCManager := TGCManager.Create;
  MarkFlag := $01;
  // 初始化局部GC根
  LocalGCRoots := TGCObjectList.Create(False);
  // 初始化公有GC根.
  LocalBegin;
  // 初始化GC步长.
  GCStep := 200;
  GCStepCount := 0;
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
  // 释放公有GC根.
  LocalEnd;
  // 释放内存管理器.
  TGCObject.GCManager.Free;
  // 我 TM 当时怎么忘了写这一句...
  LocalGCRoots.Free;
end;

procedure TGCObject.Finalize;
begin
  // Do Nothing.
end;

function TGCObject.GetGCRefObjects: TGCObjectList;
begin
  Result := nil;
end;

function TGCObject.GetHashCode: Integer;
const
  magic = 131;
var
  i: Integer;
  arr: PByteArray;
begin
  Result := NativeInt(Self);
  arr := Pointer(Self);
  for i := 0 to InstanceSize - 1 do
    Result := Result * magic + arr[InstanceSize - i - 1];
end;

{$IFDEF DEBUG}
var
  FC: Integer = 0;
{$ENDIF}

procedure TGCObject.Init;
begin
  {$IFDEF DEBUG}
  Inc(FC);
  Name := ClassName + IntToStr(FC);
  {$ENDIF}

  // 增量垃圾清理
  Inc(GCStepCount, GCStep);
  GCManager.GarbageCollectSteps;
  // 交由 GCManager 管理.
  GCManager.GCObjects.Add(Self);
  GCManager.GCUnscanned.Add(Self);

  GCMark := 0;
  SetMarked;
end;

function TGCObject.IsMarked: Boolean;
//const
//  MarkMask = $FE;
begin
  Result := (GCMark and 1) = (MarkFlag and 1);
end;

class function TGCObject.LocalBegin: TGCObject;
begin
  Result := TGCRootObject.Create;
  LocalGCRoots.Add(Result);
end;

class procedure TGCObject.LocalEnd;
begin
  GCManager.GCRoots.Delete(LocalGCRoots.Pop);
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
  GCObjects := TGCObjectList.Create(False);
  GCRoots := TGCObjectList.Create(False);
  GCUnscanned := TGCObjectList.Create(False);
  GCGarbage := TGCObjectList.Create(False);

  GCUnscanned.Add(GCRoots);
end;

destructor TGCManager.Destroy;
begin
  // 垃圾回收.
  GarbageCollectFull;

  // 释放 GCObjects.
  GCGarbage.GCFree;
  GCObjects.GCFinalize;
  GCObjects.GCFree;

  // 释放内部对象.
  GCUnscanned.Free;
  GCGarbage.Free;
  GCObjects.Free;
  GCRoots.Free;

  inherited;
end;

procedure TGCManager.GarbageCollectFull;
begin
  // 扫描全部对象.
  while not GCUnscanned.IsEmpty do
    GarbageCollectStep;
  // 初始化.
  GarbageCollectRestart;
end;

procedure TGCManager.GarbageCollectRestart;
begin
  // 提取为标记的对象为垃圾.
  GCGarbage.Add(GCObjects.GCExtractObjects(False), 2);
  // 初始化.
  GCUnscanned.Add(GCRoots);
  TGCObject.MarkFlag := not TGCObject.MarkFlag;
end;

procedure TGCManager.GarbageCollectStep;
var
  i: Integer;
  Obj: TGCObject;
  RefOfObj: TGCObjectList;
begin
  // 取出没有被标记的下一个对象.
  Obj := GCUnscanned.ExtractFirst;
  // 如果已经访问过, 那么跳过.
  if Obj.IsMarked then
    Exit;
  // 添加对象的所有子对象到待扫描列表中.
  RefOfObj := Obj.GCRefObjects;
  if Assigned(RefOfObj) then
    GCUnscanned.Add(RefOfObj);
  // 标记对象.
  Obj.SetMarked;
  // 清理垃圾对象.
  for i := 1 to 3 do
    if not GCGarbage.IsEmpty then
    begin
      Obj := GCGarbage.Pop;
      Obj.Free;
    end;
end;

procedure TGCManager.GarbageCollectSteps;
begin
  while TGCObject.GCStepCount >= 100 do
  begin
    if not GCUnscanned.IsEmpty then
      // 进行一步垃圾收集.
      GarbageCollectStep
    else
      GarbageCollectRestart;
    Dec(TGCObject.GCStepCount, 100);
  end;
end;

{ TGCTableObject }

constructor TGCTableObject.Create(Owner: TGCObject);
begin
  inherited Create(Owner);
  FObjects := TGCObjectList.Create(True);
end;

procedure TGCTableObject.Finalize;
begin
  FObjects.Free;
end;

function TGCTableObject.GetGCRefObjects: TGCObjectList;
begin
  Result := FObjects;
end;

{$REGION 'TGCObjectList'}

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
  // 通知垃圾处理器.
  if not DisableListen then
    TGCObject.GCManager.GCUnscanned.Add(AObj);
end;

procedure TGCObjectList.Add(List: TGCObjectList; const CanModify: Byte);
var
  p: PNode;
begin
  if Assigned(List) then
    case CanModify of
      0: // 复制.
        begin
          p := List.Head^.Next;
          while Assigned(p) do
          begin
            Add(p^.Data);
            p := p^.Next;
          end;
        end;
      1: // 直接连接.
        if not List.IsEmpty then
        begin
          Tail^.Next := List.Head^.Next;
          Tail := List.Tail;
        end;
      2: // 连接并释放原链表.
        begin
          if not List.IsEmpty then
          begin
            Tail^.Next := List.Head^.Next;
            Tail := List.Tail;
          end;
          List.Head^.Next := nil;
          List.Free;
        end;
    end;
  Assert(Tail^.Next = nil);
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

{$IFDEF DEBUG}
var
  IC: Integer = 0;
{$ENDIF}

constructor TGCObjectList.Create(const Linstening: Boolean);
begin
  New(Head);
  Head^.Data := nil;
  Head^.Next := nil;
  Tail := Head;

  DisableListen := not Linstening;

  {$IFDEF DEBUG}
  Inc(IC);
  ID := IC;
  {$ENDIF}
end;

destructor TGCObjectList.Destroy;
begin
  // 节点释放.
  Clear;
  // 释放 Head.
  Dispose(Head);
  inherited;
end;

function TGCObjectList.ExtractFirst: TGCObject;
var
  p: PNode;
begin
  // p: 第一个节点.
  p := Head^.Next;
  if Assigned(p) then
  begin
    Result := p^.Data;
    // 维护 Tail.
    if p = Tail then
      Tail := Head;
    // 释放.
    Head^.Next := p^.Next;
    Assert(p <> Head);
    Dispose(p);
  end
  else
    Result := nil;
end;

function TGCObjectList.GCExtractObjects(const Marked: Boolean; const AutoFinalize: Boolean): TGCObjectList;
var
  p, q: PNode;
begin
  // p: 当前访问节点的上一个节点.
  // q: 当前访问节点.
  p := Head;
  Result := TGCObjectList.Create(False);
  while p <> Tail do
  begin
    q := p^.Next;
    if (q^.Data.IsMarked <> False) = Marked then
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
    end
    else
      // 下一个
      p := p^.Next;
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
  // p: 当前访问节点.
  while Assigned(Head^.Next) do
  begin
    p := Head^.Next;
    // 将 p 从链表中断开.
    Head^.Next := p^.Next;
    // 释放.
    p^.Data.Free;
    Dispose(p);
  end;
  // 维护 Tail.
  Tail := Head;
end;

function TGCObjectList.IsEmpty: Boolean;
begin
  Result := Head^.Next = nil;
end;

function TGCObjectList.Pop: TGCObject;
var
  p: PNode;
begin
  if IsEmpty then
    Result := nil
  else
  begin
    // 获得倒数第二个节点.
    p := Head;
    while Assigned(p^.Next^.Next) do
      p := p^.Next;
    Assert(p^.Next = Tail);
    // 提取最后一个节点.
    Result := Tail^.Data;
    p^.Next := nil;
    Dispose(Tail);
    Tail := p;
  end;
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

{$ENDREGION}

{ TGCUnitObject }

constructor TGCUnitObject.Create(const Owner: TGCObject);
begin
  inherited Create(Owner);
end;

function TGCUnitObject.GetGCRefObjects: TGCObjectList;
begin
  Result := nil;
end;

{ TGCRootObject }

constructor TGCRootObject.Create;
begin
  // 初始化子对象列表.
  FObjects := TGCObjectList.Create(True);
  Init;
  GCManager.GCRoots.Add(Self);
  // 在 Init 方法中已经加入 GCObjects
  // GCManager.GCObjects.Add(Self);
end;

end.

