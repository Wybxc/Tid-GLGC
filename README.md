# Tid GLGC

一款小巧的自动垃圾回收框架。采用"标记-回收"的方法，有效避免循环引用的问题。

## 使用方法

在单元的 `uses` 区中加入 `Tid.GCObject` 单元，声明 `TGCObject` 的子类，子类的实例就会被自动内存管理。注意：不能手动释放一个 `TGCObject` 类型的量。

```Delphi
program Demo1;

uses Tid.GCObject;

type TMyClass = class(TGCObject)
protected
  procedure Finalize; override; // 析构器的代码写在这里
public
  Data: Integer;
  Obj: TObject;
  AutoObj: TGCObject;
  constructor Create(Owner: TGCObject);
end;

constructor TMyClass.Create(Owner: TGCObject);
begin
  inherited Create(Owner);
  Data := 1314;
  Obj := TObject.Create;
  AutoObj := TGCObject.Create;
end;

procedure TMyClass.Finalize; override;
begin
  Obj.Free; // 类内部的非自动内存管理对象要在析构时释放
  // AutoObj 是自动内存管理对象, 不需要释放
end;

var
  MyObject: TMyClass;
begin
  TGCObject.LocalBegin; // 在 LocalBegin 与 LocalEnd 之间创建的的对象如果
                        // 没有被之外的对象引用, 会在 LocalEnd 结束后释放
  MyObject := TMyClass.Create;
  Writeln(MyObject.Data);
  TGCObject.LocalEnd;
  // MyObject 将在 LocalEnd 之后被释放
end.
```

在单元的 `uses` 区中加入 `Tid.GCObject.SmartPointer` 单元，就可以使用智能指针。

```Delphi
program Demo2;

uses System.SysUtils, Tid.GCObject.SmartPointer;

var
  p1: TSmartPointer；// Pointer 类型的智能指针
  p2: P<Integer>; // ^Integer 类型的智能指针
  p3: P<Double>; // ^Double 类型的智能指针
begin
  TGCObject.LocalBegin;
  p1 := TSmartPointer.Create(GetMemory(8)); // 传入一个 Pointer 类型的指针
  p2 := P<Integer>.Create(1314); // 传入一个 Integer 类型
  p3 := P<Double>.Create(13.14); // 传入一个 Double 类型
  p2 := P<Integer>.Create(GetMemory(4)); // 自动内存管理的变量可以重新赋值
                                         // 传入一个已有的指针
  p2.Value := 3;
  Writeln(p2.Value); // 通过 Value 属性访问指针指向的内容
  Writeln(Format('%p',[p1.Ptr])); // 通过 Ptr 属性访问其中的指针
  TGCObject.LocalEnd;
end.
```

## 更新日志

### v1.1.1
 - 封装了`TGCString`。
 - `TGCObject.LocalBegin`和`TGCObject.LocalEnd`可以嵌套调用了。
 - 移除了`TGCObject.GlobalGCRoot`

### v1.1.0
 - 智能指针支持，`TSmartPointer`和`P<T>`类型。
 - 增量式垃圾回收支持，自动垃圾回收支持。
 - `TGCObject.LocalBegin`和`TGCObject.LocalEnd`方法表示作用域。
 
### v1.0.0
 - 基本内容构建，包括`TGCObject`和`TGCManager`类型。
 - 手动垃圾回收，程序结束时垃圾回收。
 