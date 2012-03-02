Uses Dos,Crt,SeAnHelp,Graph;
Var Driver,Mode : Integer;
    X,Y         : Integer;
    Icon        : IconType;
    IconFile    : File Of IconType;
    FName       : String;


Begin
 FName:=ParamStr(1);
 If Exist(FName) And (Size(FName)=SizeOf(Icon)) Then
 Begin;
  GraphMode(Driver,Mode);
  Font(0,5);
  Assign(IconFile,FName);
  ReSet(IconFile);
  Read(IconFile,Icon);
  Close(IconFile);
  For X:=1 To 25 Do
  Begin;
   For Y:=1 To 25 Do
   Begin;
    Area(Icon.Pixel[X][Y],X*10+185,Y*10+105,X*10+193,Y*10+113,'');
   End;
  End;
  Area(Black,250,370,390,390,FName);
  Repeat Until KeyPressed;
  CloseGraph;
 End;
End.