unit Tid.LinkedList;

interface

type
  /// <remarks>
  /// Á´±í.
  /// </remarks>
  TLinkedList<T> = class
  public
    type
      PNode = ^TNode;

      TNode = record
        Data: T;
        Next: PNode;
      end;
  public
    Head, Tail: PNode;
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Value: T);
    function contains(const Value: T): Boolean;
  public
    type
      TEnumerator = record
      private
        p: PNode;
        function GetCurrent: T;
      public
        function MoveNext: Boolean;
        property Current: T read GetCurrent;
      end;
    function GetEnumerator: TEnumerator;
  end;

implementation

uses
  System.Generics.Defaults, System.Generics.collections;

{ TLinkedList<T> }

procedure TLinkedList<T>.Add(const Value: T);
var
  p: PNode;
begin
  New(p);
  p^.Data := Value;
  p^.Next := nil;
  Tail^.Next := p;
  Tail := p;
end;

function TLinkedList<T>.contains(const Value: T): Boolean;
var
  Data: T;
  Comparer: IComparer<T>;
begin
  Comparer := TComparer<T>.Default;
  for Data in Self do
    if Comparer.Compare(Data, Value) = 0 then
      Exit(True);
  Result := False;
end;

constructor TLinkedList<T>.Create;
begin
  New(Head);
  Head^.Next := nil;
  Tail := Head;
end;

destructor TLinkedList<T>.Destroy;
var
  p, q: PNode;
begin
  p := Head;
  q := p^.Next;
  while q <> nil do
  begin
    Dispose(p);
    p := q;
    q := p^.Next;
  end;
  inherited;
end;

function TLinkedList<T>.GetEnumerator: TEnumerator;
begin
  Result.p := Head;
end;

{ TLinkedList<T>.TEnumerator }

function TLinkedList<T>.TEnumerator.GetCurrent: T;
begin
  Result := p^.Data;
end;

function TLinkedList<T>.TEnumerator.MoveNext: Boolean;
begin
  if p = nil then
    Exit(False);
  p := p^.Next;
  Result := (p <> nil);
end;

end.

