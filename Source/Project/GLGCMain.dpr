//-------------------------------------------------------------------------------------------------//
//                                                                                                 //
//   ,ggg,              ,ggo,,ggg,         gg   ,gggggggggg,     ,ggg,          ,gg"     ,gggg,    //
//  dP""Y8a     88     ,8P  dP""Y8a        88  dP"""88"""""Y8,  dP"""Y8,      ,dP'     ,88"""Y8b,  //
//  Yb, `88     88     d8'  Yb, `88        88  Yb,  88     `8b  Yb,_  "8b,   d8"      d8"     `Y8  //
//   `"  88     88     88    `"  88        88   `"  88     ,8P   `""    Y8,,8P'      d8'       d8  //
//       88     88     88        88        88       88aaad8P"            Y88"       ,8I      d8P'  //
//       88     88     88        88        88       88""""Y8ba,         ,888b       I8'            //
//       88     88     88        88       ,88       88      `88b       d8" "8b,     d8             //
//       Y8    ,88,    8P        Y8b,___,d888       88      ,88P     ,8P'    Y8,    Y8,            //
//        Yb,,d8""8b,,dP          "Y88888P"88,     ,88_____,d8"'    d8"       "Yb,  `Yba,,_____,.. //
//         "88"    "88"                ,ad8888bood888888888P"'   od8P'          "Y88b `"Y8888888P' //
//------------------------------------d8P"-88------------------------------------------------------//
//                                  ,d8'   88                                                      //
//                                  d8'    88                                                      //
//                                  88     88                                                      //
//                                  Y8,_ _,88                                                      //
//                                   "Y888P"                                 ---- For My Love.     //
//-------------------------------------------------------------------------------------------------//
program GLGCMain;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Tid.GCObject in '..\Tid.GCObject.pas',
  Tid.GCObject.SmartPointer in '..\Tid.GCObject.SmartPointer.pas',
  Tid.GCObject.GCString in '..\Tid.GCObject.GCString.pas',
  Tid.GCObject.Classes in '..\Tid.GCObject.Classes.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    Writeln('GLGC Ver 1.1.1');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

