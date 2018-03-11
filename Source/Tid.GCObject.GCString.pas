{------------------------------------------------------------------------------}
{                                                                              }
{                          基于垃圾回收框架的字符串                            }
{                                                                              }
{    作者: 忘忧北萱草                                                          }
{    Github 主页: https://github.com/Wybxc/Tid-GLGC                            }
{                                                                              }
{    版本: v1.1.1 dev 0310                                                     }
{                                                                              }
{    Licence: GNU Lesser General Public License v3.0 (LGPLv3)                  }
{                                                                              }
{    为什么要有这个单元:                                                       }
{        Delphi 的 string 本身就有引用计数的内存管理, 本来不需要额外的内存管理.}
{    但是 string 不能用在 record 的 case 部分, 就像这样:                       }
{           type r = record                                                    }
{             case Byte of                                                     }
{              0:(a:string;);                                                  }
{           end;                                                               }
{      这样编译不通过. 一个方法就是把字符串封装成为普通的类, 再借助其他工具进行}
{      内存管理. 这就是本单元的内容.                                           }
{------------------------------------------------------------------------------}

unit Tid.GCObject.GCString;

interface

uses
  Tid.GCObject, System.SysUtils;

type
  /// <remarks>支持自动内存管理的 string.</remarks>
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
    type
      TStringEnumerator = record
      private
        FStr: string;
        FIndex: Integer;
        function GetCurrent: Char; inline;
      public
        function MoveNext: Boolean; inline;
        property Current: Char read GetCurrent;
      end;
  private
    FStr: TStringObject;
    function GetStr: string; inline;
    procedure SetStr(const Value: string); inline;
    function GetChars(const index: Integer): Char; inline;
    procedure SetChars(const index: Integer; const Value: Char); inline;
  public
    constructor Create(const AStr: string);
    function GetEnumerator: TStringEnumerator; inline;
      /// <summary>对象中管理的 string.</summary>
    property Str: string read GetStr write SetStr;
      /// <summary>索引访问 string 中的字符, 方法同string.</summary>
    property Chars[const index: Integer]: Char read GetChars write SetChars; Default;
    {$REGION 'Operator Overload'}
    class operator Implicit(const s: string): TGCString; overload; inline;
    class operator Implicit(const s: TGCString): string; overload; inline;
    class operator Explicit(const s: string): TGCString; overload; inline;
    class operator Explicit(const s: TGCString): string; overload; inline;
    class operator Equal(const a, b: TGCString): Boolean; inline;
    class operator NotEqual(const a, b: TGCString): Boolean; inline;
    class operator GreaterThan(const a, b: TGCString): Boolean; inline;
    class operator GreaterThanOrEqual(const a, b: TGCString): Boolean; inline;
    class operator LessThan(const a, b: TGCString): Boolean; inline;
    class operator LessThanOrEqual(const a, b: TGCString): Boolean; inline;
    class operator Add(const a, b: TGCString): string; inline;
    {$ENDREGION}
  end;

type
  TGCStringHelper = record helper for TGCString
  public
    function Append(const s: string): TGCString; inline;
    function GetHashCode: Integer;
  end;

type
  /// <remarks>支持自动内存管理的 TStringBuilder, 用法同 TstringBuilder.</remarks>
  TGCStringBuilder = class(TGCUnitObject)
  private
    FStringBuilder: TStringBuilder;
    function GetCapacity: Integer; inline;
    function GetChars(index: Integer): Char; inline;
    function GetLength: Integer; inline;
    function GetMaxCapacity: Integer; inline;
    procedure SetCapacity(const Value: Integer); inline;
    procedure SetChars(index: Integer; const Value: Char); inline;
    procedure SetLength(const Value: Integer); inline;
  protected
    procedure Finalize; override;
  public
    constructor Create; overload;
    constructor Create(aCapacity: Integer); overload;
    constructor Create(const Value: string); overload;
    constructor Create(aCapacity: Integer; aMaxCapacity: Integer); overload;
    constructor Create(const Value: string; aCapacity: Integer); overload;
    constructor Create(const Value: string; StartIndex: Integer; Length: Integer; aCapacity: Integer); overload;
    function Append(const Value: Boolean): TStringBuilder; overload; inline;
    function Append(const Value: Byte): TStringBuilder; overload; inline;
    function Append(const Value: Char): TStringBuilder; overload; inline;
    function Append(const Value: Currency): TStringBuilder; overload; inline;
    function Append(const Value: Double): TStringBuilder; overload; inline;
    function Append(const Value: SmallInt): TStringBuilder; overload; inline;
    function Append(const Value: Integer): TStringBuilder; overload; inline;
    function Append(const Value: Int64): TStringBuilder; overload; inline;
    function Append(const Value: TObject): TStringBuilder; overload; inline;
    function Append(const Value: ShortInt): TStringBuilder; overload; inline;
    function Append(const Value: Single): TStringBuilder; overload; inline;
    function Append(const Value: string): TStringBuilder; overload; inline;
    function Append(const Value: UInt64): TStringBuilder; overload; inline;
    function Append(const Value: TCharArray): TStringBuilder; overload; inline;
    function Append(const Value: Word): TStringBuilder; overload; inline;
    function Append(const Value: Cardinal): TStringBuilder; overload; inline;
    function Append(const Value: PAnsiChar): TStringBuilder; overload; inline;
    function Append(const Value: RawByteString): TStringBuilder; overload; inline;
    function Append(const Value: Char; RepeatCount: Integer): TStringBuilder; overload; inline;
    function Append(const Value: TCharArray; StartIndex: Integer; CharCount: Integer): TStringBuilder; overload; inline;
    function Append(const Value: string; StartIndex: Integer; Count: Integer): TStringBuilder; overload; inline;
    function AppendFormat(const Format: string; const Args: array of const): TStringBuilder; overload;
    function AppendLine: TStringBuilder; overload; inline;
    function AppendLine(const Value: string): TStringBuilder; overload; inline;
    procedure Clear; inline;
    procedure CopyTo(SourceIndex: Integer; const Destination: TCharArray; DestinationIndex: Integer;
      Count: Integer); inline;
    function EnsureCapacity(aCapacity: Integer): Integer; inline;
    function Equals(StringBuilder: TStringBuilder): Boolean; reintroduce; inline;
    function Insert(index: Integer; const Value: Boolean): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Byte): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Char): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Currency): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Double): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: SmallInt): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Integer): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: TCharArray): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Int64): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: TObject): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: ShortInt): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Single): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: string): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Word): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: Cardinal): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: UInt64): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: string; Count: Integer): TStringBuilder; overload; inline;
    function Insert(index: Integer; const Value: TCharArray; StartIndex: Integer; charCount: Integer):
      TStringBuilder; overload; inline;
    function Remove(StartIndex: Integer; RemLength: Integer): TStringBuilder; inline;
    function Replace(const OldChar: Char; const NewChar: Char): TStringBuilder; overload; inline;
    function Replace(const OldValue: string; const NewValue: string): TStringBuilder; overload; inline;
    function Replace(const OldChar: Char; const NewChar: Char; StartIndex: Integer; Count: Integer):
      TStringBuilder; overload; inline;
    function Replace(const OldValue: string; const NewValue: string; StartIndex: Integer; Count:
      Integer): TStringBuilder; overload; inline;
    function ToString: string; overload; override;
    function ToString(StartIndex: Integer; StrLength: Integer): string; reintroduce; overload;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Chars[index: Integer]: Char read GetChars write SetChars; Default;
    property Length: Integer read GetLength write SetLength;
    property MaxCapacity: Integer read GetMaxCapacity;
  end;

implementation

{$REGION 'TGCString'}
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

constructor TGCString.Create(const AStr: string);
begin
  Str := AStr;
end;

class operator TGCString.Equal(const a, b: TGCString): Boolean;
begin
  Result := a.Str = b.Str;
end;

class operator TGCString.Explicit(const s: string): TGCString;
begin
  inherited;
  Result := s;
end;

class operator TGCString.Explicit(const s: TGCString): string;
begin
  Result := s;
end;

function TGCString.GetChars(const Index: Integer): Char;
begin
  Result := Str[Index];
end;

function TGCString.GetEnumerator: TStringEnumerator;
begin
  Result.FStr := Str;
  Result.FIndex := 0;
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

{ TGCStringHelper }

function TGCStringHelper.Append(const s: string): TGCString;
begin
  Str := Str + s;
  Result := Self;
end;

function TGCStringHelper.GetHashCode: Integer;
const
  Magic = 131;
var
  c: Char;
begin
  Result := 0;
  for c in Str do
    Result := Result * Magic + Integer(c);
end;

{ TGCString.TStringEnumerator }

function TGCString.TStringEnumerator.GetCurrent: Char;
begin
  Result := FStr[FIndex];
end;

function TGCString.TStringEnumerator.MoveNext: Boolean;
begin
  if FIndex < Length(FStr) then
  begin
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;
{$ENDREGION}

{$REGION 'TGCStringBuilder'}
{ TGCStringBuilder }

function TGCStringBuilder.Append(const Value: Word): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Cardinal): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: TCharArray): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: string): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: UInt64): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: TCharArray; StartIndex, CharCount: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value, StartIndex, CharCount);
end;

function TGCStringBuilder.Append(const Value: string; StartIndex, Count: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value, StartIndex, Count);
end;

function TGCStringBuilder.Append(const Value: Char; RepeatCount: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: PAnsiChar): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: RawByteString): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Single): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Currency): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Double): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Char): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Boolean): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Byte): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: TObject): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: ShortInt): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Int64): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: SmallInt): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.Append(const Value: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Append(Value);
end;

function TGCStringBuilder.AppendFormat(const Format: string; const Args: array of const): TStringBuilder;
begin
  Result := FStringBuilder.AppendFormat(Format, Args);
end;

function TGCStringBuilder.AppendLine: TStringBuilder;
begin
  Result := FStringBuilder.AppendLine;
end;

function TGCStringBuilder.AppendLine(const Value: string): TStringBuilder;
begin
  Result := FStringBuilder.AppendLine(Value);
end;

procedure TGCStringBuilder.Clear;
begin
  FStringBuilder.Clear;
end;

procedure TGCStringBuilder.CopyTo(SourceIndex: Integer; const Destination: TCharArray;
  DestinationIndex, Count: Integer);
begin
  FStringBuilder.CopyTo(SourceIndex, Destination, DestinationIndex, Count);
end;

constructor TGCStringBuilder.Create;
begin
  inherited Create;
  FStringBuilder := TStringBuilder.Create;
end;

constructor TGCStringBuilder.Create(const Value: string; StartIndex, Length, aCapacity: Integer);
begin
  inherited Create;
  FStringBuilder := TStringBuilder.Create(Value, StartIndex, Length, aCapacity);
end;

constructor TGCStringBuilder.Create(const Value: string);
begin
  inherited Create;
  FStringBuilder := TStringBuilder.Create(Value);
end;

constructor TGCStringBuilder.Create(aCapacity: Integer);
begin
  inherited Create;
  FStringBuilder := TStringBuilder.Create(aCapacity);
end;

constructor TGCStringBuilder.Create(aCapacity, aMaxCapacity: Integer);
begin
  inherited Create;
  FStringBuilder := TStringBuilder.Create(aCapacity, aMaxCapacity);
end;

constructor TGCStringBuilder.Create(const Value: string; aCapacity: Integer);
begin
  FStringBuilder := TStringBuilder.Create(Value, aCapacity);
end;

function TGCStringBuilder.EnsureCapacity(aCapacity: Integer): Integer;
begin
  Result := FStringBuilder.EnsureCapacity(aCapacity);
end;

function TGCStringBuilder.Equals(StringBuilder: TStringBuilder): Boolean;
begin
  Result := FStringBuilder.Equals(StringBuilder);
end;

procedure TGCStringBuilder.Finalize;
begin
  FStringBuilder.Free;
  inherited;
end;

function TGCStringBuilder.GetCapacity: Integer;
begin
  Result := FStringBuilder.Capacity;
end;

function TGCStringBuilder.GetChars(index: Integer): Char;
begin
  Result := FStringBuilder.Chars[index];
end;

function TGCStringBuilder.GetLength: Integer;
begin
  Result := FStringBuilder.Length;
end;

function TGCStringBuilder.GetMaxCapacity: Integer;
begin
  Result := FStringBuilder.MaxCapacity;
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: ShortInt): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: TObject): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Single): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Cardinal): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Word): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: string): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: SmallInt): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Double): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Currency): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Int64): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: TCharArray): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: UInt64): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Char): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Byte): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: Boolean): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: string; count: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value, count);
end;

function TGCStringBuilder.Insert(Index: Integer; const Value: TCharArray; startIndex, charCount:
  Integer): TStringBuilder;
begin
  Result := FStringBuilder.Insert(Index, Value, startIndex, charCount);
end;

function TGCStringBuilder.Remove(StartIndex, RemLength: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Remove(StartIndex, RemLength);
end;

function TGCStringBuilder.Replace(const OldChar, NewChar: Char; StartIndex, Count: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Replace(OldChar, NewChar, StartIndex, Count);
end;

function TGCStringBuilder.Replace(const OldValue, NewValue: string; StartIndex, Count: Integer): TStringBuilder;
begin
  Result := FStringBuilder.Replace(OldValue, NewValue, StartIndex, Count);
end;

function TGCStringBuilder.Replace(const OldChar, NewChar: Char): TStringBuilder;
begin
  Result := FStringBuilder.Replace(OldChar, NewChar);
end;

function TGCStringBuilder.Replace(const OldValue, NewValue: string): TStringBuilder;
begin
  Result := FStringBuilder.Replace(OldValue, NewValue);
end;

procedure TGCStringBuilder.SetCapacity(const Value: Integer);
begin
  FStringBuilder.Capacity := Value;
end;

procedure TGCStringBuilder.SetChars(index: Integer; const Value: Char);
begin
  FStringBuilder.Chars[index] := Value;
end;

procedure TGCStringBuilder.SetLength(const Value: Integer);
begin
  FStringBuilder.Length := Value;
end;

function TGCStringBuilder.ToString(StartIndex, StrLength: Integer): string;
begin
  Result := FStringBuilder.ToString(StartIndex, StrLength);
end;

function TGCStringBuilder.ToString: string;
begin
  Result := FStringBuilder.ToString;
end;
{$ENDREGION}

end.

