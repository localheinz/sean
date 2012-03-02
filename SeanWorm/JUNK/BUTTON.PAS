Program TestButton;
Uses Graph, SeAnHelp;
Var Driver, Mode : Integer;

 Procedure WButton(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Var Color : Word;
         Y : Integer;
 Begin
  SetTextStyle(2,0,5);
  S:=Gross(S);
  Color:=GetColor;
  SetColor(Lightgray);
  For Y:=LY+2 To RY-3 Do Line(LX+2,Y,RX-4,Y);
  SetColor(Black);
  Line(LX+1,LY,RX-1,LY);
  Line(LX+1,RY,RX-1,RY);
  Line(LX,LY+1,LX,RY-1);
  Line(RX,LY+1,RX,RY-1);
  If Not Switch Then SetColor(White) Else
  If Switch Then SetColor(DarkGray);
  Line(LX+1,LY+1,RX-1,LY+1);
  Line(LX+1,LY+2,RX-2,LY+2);
  Line(LX+1,LY+1,LX+1,RY-1);
  If Switch Then SetColor(DarkGray) Else
  If Not Switch Then  Begin;
   SetColor(DarkGray);
   Line(LX+2,RY-2,RX-2,RY-2);
   Line(RX-2,LY+2,RX-2,RY-2);
   Line(LX+1,RY-1,RX-1,RY-1);
   Line(RX-1,LY+1,RX-1,RY-1);
  End;

  SetColor(Black);
  OutTextXY(Round((RX-LX)/2)-Round(TextWidth(S)/2)+LX+2,Round((RY-LY)/2)-Round(TextHeight(S)/2)+LY-2,S);
  SetColor(Color);
 End;


 Begin
  DetectGraph(Driver,Mode);
  InitGraph(Driver,Mode,'C:\Dos\Pascal\Bgi');
  WButton(Off,0,0,400,300,'');
  WButton(On,10,10,100,40,'ERIN');
  ReadLn;
 End.