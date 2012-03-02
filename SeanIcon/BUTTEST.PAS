Program Test;
Uses SeanHelp,Maus,Crt,Graph;
Var Driver,Mode : Integer;
    X,Y,Z       : Word;
    Buttons     : Integer;
Function MouseDelay(LX,LY,RX,RY : Word) : Boolean;
Var A,B,C   : Word;
    Out     : Boolean;
Begin
 Ms_Hide;
 ButtonFrame(On,LX,LY,RX,RY,'');
 Ms_Show;
 Out:=False;
 Repeat;
  Ms_Read(A,B,C);
  If (Out=False) And  (Not ((A In [LX..RX]) And (B In [LY..RY]))) Then
  Begin;
   Ms_Hide;
   ButtonFrame(Off,LX,LY,RX,RY,'');
   Delay(30);
   Ms_Show;
   Out:=True;
  End Else
  If (Out=True) And (LX<=A) And (A<=RX) And (LY<=B) And (B<=RY) Then
  Begin;
   Ms_Hide;
   ButtonFrame(On,LX,LY,RX,RY,'');
   Ms_Show;
   Out:=False;
  End;
 Until C=$0000;
 If (LX<=A) And (A<=RX) And (LY<=B) And (B<=RY) Then
 Begin;
  MouseDelay:=True;
  Ms_Hide;
  ButtonFrame(Off,LX,LY,RX,RY,'');
{  Ms_Show;}
 End Else MouseDelay:=False;
End;


{Function MouseDelay(LX,LY,RX,RY : Word) : Boolean;
Var A,B,C   : Word;
    Out     : Boolean;
Begin
 Ms_Hide;
 ButtonFrame(On,LX,LY,RX,RY,'');
 Ms_Show;
 Out:=False;
 Repeat;
  Ms_Read(A,B,C);
  If (Out=False) And  (Not ((A In [LX..RX]) And (B In [LY..RY]))) Then
  Begin;
   Ms_Hide;
   ButtonFrame(Off,LX,LY,RX,RY,'');
   Delay(30);
   Ms_Show;
   Out:=True;
  End Else
  If (Out=True) And (LX<=A) And (A<=RX) And (LY<=B) And (B<=RY) Then
  Begin;
   Ms_Hide;
   ButtonFrame(On,LX,LY,RX,RY,'');
   Ms_Show;
   Out:=False;
  End;
 Until C=$0000;
 If (LX<=A) And (A<=RX) And (LY<=B) And (B<=RY) Then
 Begin;
  MouseDelay:=True;
  Ms_Hide;
  ButtonFrame(Off,LX,LY,RX,RY,'');
  Ms_Show;
 End Else MouseDelay:=False;
End;}

Begin
 GraphMode(Driver,Mode);
 Font(0,5);
 Button(Off,000,000,639,479,'');
 ButtonFrame(Off,100,100,250,140,'PUSH ME');
 If Ms_Init(Buttons) Then Ms_Show;
 Ms_Set_GraphPointer(0,0,@Arrow);
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Case X Of
  100..250: Case Y Of
            100..140: Begin
                       If MouseDelay(100,100,250,140) Then Beep;
                      End;
            End;
  End;
 Until KeyPressed;
 CloseGraph;
End.
