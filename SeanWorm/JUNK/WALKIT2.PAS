Program Walk;
Uses Crt,Graph,SeAnHelp;
Const MaxPoints   = 3;  {25}
      WormSegment = 15;
Var   Driver,Mode : Integer;
      XPos        : Array[1..2] Of Integer;
      YPos        : Array[1..2] Of Integer;
      XOldPos     : Array[1..2] Of Array[1..(MaxPoints+1)*WormSegment] Of Word;
      YOldPos     : Array[1..2] Of Array[1..(MaxPoints+1)*WormSegment] Of Word;
      XDir        : Array[1..2] Of ShortInt;
      YDir        : Array[1..2] Of ShortInt;
      Z           : Integer;
      Runner      : Array[1..2] Of Integer;
      Head        : Array[1..2] Of Integer;
      Points         : Array[1..2] Of Byte;
      Lives          : Array[1..2] Of Byte;

Procedure Reset;
Begin;
 XPos[1]:=135;
 YPos[1]:=55;
 XDir[1]:=1;
 YDir[1]:=0;
 For Z:=WormSegment*MaxPoints DownTo 1 Do
 Begin;
  XOldPos[1][Z]:=114;
  YOldPos[1][Z]:=34;
 End;
 Runner[1]:=1;
 Runner[2]:=1;
 Lives[1]:=10;
 Points[1]:=3;
 Randomize;
End;

Procedure WalkIt;
Const Left     = 1;
      Right    = 2;
      Ahead    = 3;
      XAbs     = 230;
      YAbs     =  15;
Var   Color    : Array[1..3] Of Byte;
      Turn     : Byte;
      Sign     : Byte;
      NoReturn : Boolean;

Begin
 If (XAbs-XPos[1])<0 Then
 Begin;
  XDir[1]:=-1;
  YDir[1]:=0;
 End Else
 Begin;
  XDir[1]:=+1;
  YDir[1]:=0;
 End;
 Turn:=2; {Random(10);}
 Color[Ahead]:=GetPixel(XPos[1]+XDir[1],YPos[1]+YDir[1]);
 If XDir[1]<>0 Then
 Begin;
  Color[Left]:=GetPixel(XPos[1],YPos[1]-XDir[1]);
  Color[Right]:=GetPixel(XPos[1],YPos[1]+XDir[1]);
 End Else
 If YDir[1]<>0 Then
 Begin;
  Color[Left]:=GetPixel(XPos[1]-YDir[1],YPos[1]);
  Color[Right]:=GetPixel(XPos[1]+YDir[1],YPos[1]);
 End;
 If (Color[Left]<>LightGray) And
    (Color[Right]<>LightGray) And
    (Color[Ahead]<>LightGray) Then NoReturn:=True Else NoReturn:=False;
 
 If Color[Ahead]<>LightGray Then {(NoReturn=True) Or (Turn=3) Then}
 Begin;
  Repeat;
   If XDir[1]<>0 Then
   Begin;
    XDir[1]:=0;
    YDir[1]:=1;
   End Else
   If YDir[1]<>0 Then
   Begin;
    XDir[1]:=1;
    YDir[1]:=0;
   End;
   Sign:=Random(10);
   If Sign=3 Then
   Begin;
    YDir[1]:=-YDir[1];
    XDir[1]:=-XDir[1];
   End;
   Color[Ahead]:=GetPixel(XPos[1]+XDir[1],YPos[1]+YDir[1]);
  Until (Color[Ahead]=LightGray);
 End;
End;


Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C:\Dos\Pascal\Bgi');
 Reset;
 Button(Off,100,20,400,300,'');
 Rectangle(150,30,350,250);
 Repeat;
  PutPixel(XPos[1],YPos[1],Red);
  Delay(20);
  If GetPixel(XOldPos[1][Runner[1]],YOldPos[1][Runner[1]])<>LightGray Then
     PutPixel(XOldPos[1][Runner[1]],YOldPos[1][Runner[1]],LightGray);
  XOldPos[1][Runner[1]]:=XPos[1];
  YOldPos[1][Runner[1]]:=YPos[1];
  Inc(XPos[1],XDir[1]);
  Inc(YPos[1],YDir[1]);
  {Head[1]:=GetPixel(XPos[1]+XDir[1],YPos[1]+YDir[1]);}
  Inc(Runner[1]);
  If (Runner[1]>(Points[1]+1)*WormSegment) Then Runner[1]:=1;
  WalkIt;
 Until (Lives[1]<1) Or {(Head[1]<>LightGray) Or} KeyPressed;
End.
