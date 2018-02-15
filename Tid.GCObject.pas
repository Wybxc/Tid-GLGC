unit Tid.GCObject;

interface

uses
  Tid.LinkedList;

type
  /// <remarks>
  /// ֧���Զ��ڴ����Ķ���.
  /// </remarks>
  TGCObject = class;

  /// <remarks>
  /// <see cref="Tid.GCObject.TGCObject">TGCObject</see> ������.
  /// </remarks>
  TGCObjects = array of TGCObject;

  TGCMark = Byte;

  /// <remarks>
  /// ȫ���ڴ������.
  /// </remarks>
  TGCManager = class
  public
    GCObjects: TLinkedList<TGCObject>;
    GCRoots: TLinkedList<TGCObject>;
      /// <summary>
      /// ����Ӷ���.
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
      /// ���������õ���������.
      /// </summary>
    GCObjects: TGCObjects;
      /// <summary>
      /// �������
      /// </summary>
    GCMark: TGCMark;
      /// <summary>
      /// �Ƿ񱻱��.
      /// </summary>
    function IsMarked: Boolean; inline;
      /// <summary>
      /// ����Ϊ���״̬.
      /// </summary>
    procedure SetMarked; inline;
    // ע�⵽û��ȡ����ǵķ���,
    // ��Ϊ��������һ�������С����.
    // ����һ�μ��ʱ, �� GCMark ���һλΪ 1 ���������,
    // ��ô��һ��ֻҪ��ת MarkFlag,
    // ��һ�εļ��ͻ��Ϊ GCMark ���һλΪ 0 ���������.
  public
    class var
      GCManager: TGCManager;
      MarkFlag: TGCMark;
    class constructor CreateGCManager;
    class destructor DestroyGCManager;
  public
    constructor Create(AOwner: TGCObject);
      /// <summary>
      /// ����Ӷ���.
      /// </summary>
    procedure AddObject(const AGCObject: TGCObject); virtual;
  end;

implementation

{ TGCObject }

procedure TGCObject.AddObject(const AGCObject: TGCObject);
(*
  AddObject ��Ĭ��ʵ��.
  ��ʵ�ֲ���֤Ч��, ����ʹ��ʱ��ʹ�������е���Գ����Ż��İ汾.
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
    // ������� Root ����
    Root.SetMarked;
    // ���ÿ�� Root �����ڲ��Ķ���
    for Obj in Root.GCObjects do
      Obj.SetMarked;
  end;
  // ���δ��ǵĶ���
  for Obj in GCObjects do
  begin
    if not Obj.IsMarked then
      Obj.Free;
  end;
end;

end.

