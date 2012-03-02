Program MouseTest;
Uses Crt,Graph,Maus,SeAnHelp;
Var MButtons    : Integer;
    X,Y,Z       : Word;
    Count       : Word;
    Driver,Mode : Integer;
    Result      : Word;

Procedure MouseDelay;
Begin
 While Z<>$0000 Do
 Begin;
  Ms_Read(X,Y,Z);
 End;
End;


Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C:\Dos\Pascal\Bgi');
 Button(Off,020,020,220,040,'PRESS HERE');
 If Ms_Init(MButtons) Then Ms_Show;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case X Of
   023..217: Case Y Of
             023..037: Begin
                        Ms_Hide;
                        ButtonFrame(On,020,020,220,040,'PRESS HERE');
                        MouseDelay;
                        ButtonFrame(Off,020,020,220,040,'PRESS HERE');
                        Ms_Show;
                       End;
             End;
   End;
  End;
 Until KeyPressed;
 CloseGraph;
End.

