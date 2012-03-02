Program Maus256;
Uses SeAnHelp,Graph,Maus,Crt;
Var P   : Pointer;


Begin
 Driver:=InstallUserDriver('SUPERVGA.BGI',P);
 Mode:=19;
 InitGraph(Driver,Mode,'C:\DOS\BORLAND\BGI');
 For X:=0 To 255 Do
 Begin;
  SetColor(X);
  Line(X,000,X,100);
 End;
 If Ms_Init(MButtons) Then
 Begin;
  Ms_Show;
  Ms_Set_GraphPointer(0,0,@Arrow);
  Repeat;
   Ms_Read(X,Y,Z);
   PutPixel(X,Y,Z)
  Until KeyPressed;
 End;
 ReadLn;
End.