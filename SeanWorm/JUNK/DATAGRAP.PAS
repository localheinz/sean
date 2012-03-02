Program DataGraph;
Uses Crt,Graph,SeAnHelp;
Var Driver,Mode : Integer;

Procedure SetArrowUp(X,Y : Integer);
Begin
 SetColor(DarkGray);
 Line(X,Y-5,X+2,Y);
 Line(X-2,Y,X+2,Y);
 SetColor(White);
 Line(X,Y-5,X-2,Y);
End;

Procedure SetArrowRight(X,Y : Integer);
Begin
 SetColor(White);
 Line(X,Y-2,X+5,Y);
 SetColor(DarkGray);
 Line(X,Y+2,X+5,Y);
 SetColor(White);
 Line(X,Y-2,X,Y+2);
End;

Procedure SetCPixel(X,Y : Integer);
Begin
 PutPixel(X,Y,White);
 PutPixel(X+1,Y,DarkGray);
 PutPixel(X+1,Y+1,DarkGray);
 PutPixel(X,Y+1,DarkGray);
End;

Procedure SetCYBar(X,Y : Integer; Value : Integer);
Var S : String;
Begin
 SetColor(White);
 Line(X-5,Y,X-1,Y);
 SetColor(DarkGray);
 Line(X-5,Y+1,X,Y+1);
 PutPixel(X,Y,DarkGray);
 Str(Value,S);
 OutTextXY(X-30+Round(TextWidth(S)/2),Y-7,S);
End;

Procedure SetCXBar(X,Y : Integer; Value : Real);
Begin
 SetColor(White);
 Line(X,Y,X,Y+4);
 SetColor(DarkGray);
 Line(X+1,Y,X+1,Y+5);
 PutPixel(X,Y+5,DarkGray);
End;

Procedure CoordinateSystem(LX,LY,RX,RY,Distance : Integer);
Var X,Y   : Integer;
Begin
 For X:=0 To Round((RX-LX)/Distance) Do
 Begin;
  For Y:=0 To Round((RY-LY)/Distance) Do
  Begin;
   SetCPixel(X*Distance+LX,Y*Distance+LY);
  End;
 End;
 SetArrowUp(LX,LY-Distance);
 SetArrowRight(RX+Distance,RY);
End;


Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C;\Dos\Pascal\Bgi');
 Button(Off,10,10,300,300,'');
 SetColor(Black);
 CoordinateSystem(100,100,200,200,20);
 ReadLn;
 CloseGraph;
End.

