{$M 30000,0,60000}
Program Test;
Uses Graph,SeAnHelp,Crt;
Var Driver,Mode : Integer;

Procedure Fill(X,Y : Integer; Color : Byte);
Var BackGround : Byte;
    A,B        : Integer;
Begin
 BackGround:=GetPixel(X,Y);
 PutPixel(X,Y,Color);
 For A:=-1 To 1 Do
 Begin;
  For B:=-1 To 1 Do
  Begin;
   If Not ((A=B) And ((A=-1) Or (A=1))) Then
   Begin;
    If (GetPixel(X+A,Y+B)=BackGround) And (X+A>=0) And (X+A<=GetMaxX) And (Y+B>=0) And (Y+B<=GetMaxY) Then
    Begin;
     Fill(X+A,Y+B,Color);
    End;
   End;
  End;
 End;
End;

Begin
 GraphMode(Driver,Mode);
 Font(0,5);
 Button(Off,000,000,639,479,'');
 SetColor(Black);
 Circle(75,75,10);
 Fill(74,74,Blue);
 Repeat Until KeyPressed;
End.
