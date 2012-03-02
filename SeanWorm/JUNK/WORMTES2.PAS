{$M 30000,0,15000}
Program SeAnTestNibbles;
Uses Crt,Graph,SeAnHelp,Maus,Dos;
Type  String10       = String[10];
      LivesStatType  = Record
                        Lives : Array[1..255] Of Byte;
                        Time  : Array[1..255] Of LongInt;
                       End;
      PointsStatType = Record
                        Points : Array[1..255] Of Byte;
                        Time   : Array[1..255] Of LongInt;
                       End;
      LevelType      = Record
                        LevelValue    : Byte;
                        LevelTitle    : TitleString;
                        Area          : Array[1..25] Of Array[1..25] Of Byte;
                        RelativeSpeed : Byte;
                        DecidingBit   : Byte;                { Setted Bit will be looked at in following 9 Bytes }
                        AttemptCode   : Array[0..7] Of Byte; { Bits make an AttemptCode-Byte ($77=SuperUser)     }
                        BitSequence   : Byte;                { Setted/Cleared Bit defines Up-Down/Down-Up Order  }
                       End;
      OptionsType    = Record
                        Players     : Byte;
                        PlayerName  : Array[$01..$02] Of String10;
                        PlayerColor : Array[$01..$02] Of Integer;
                        PlayerIcon : Array[$01..$02] Of Integer;
                        SpeedChange : Byte;
                        SpeedValue  : Byte;
                       End;
Const MaxLevels      : Byte = 1;
      AttrButton     =  1;
      AttrFree       =  2;
      AttrRestriced  =  3;
      MaxLives       = 35;
      MaxPoints      =  5;
      MaxBags        = 35;
      WormSegment    = 15;
      LeftPlayer     =  1;
      RightPlayer    =  2;
      GuyOne         =  1;
      GuyTwo         =  2;
      GuyTwoNo       =  3;
      GuyTwOff       =  4;
      Heart          =  5;
      Money          =  6;
      Slow           =  7;
      Fast           =  8;
      Life           =  9;
      Point          = 10;
      Extra          = 11;
      SeanWorm       = 12;
      LotsOPoints    = 13;
      Computer       = 14;
      Constant       =  1;
      LevelDependent =  2;
      Adjustable     =  3;
      MaxPlayerIcons = 10;
      PlayerIconName : Array[1..MaxPlayerIcons] Of String = ('ANDREAS' ,'BASTEL'  ,'BERND'   ,'DETLEV'  ,'ELVIS'   ,
                                                             'ERWIN'   ,'FRITZI'  ,'JAKE'    ,'ROBERT'  ,'TOUGHY'  );
Var   Opa            : String[10];
      Driver,Mode    : Integer;
      Options        : OptionsType;
      OldOptions     : OptionsType;
      OptionsFile    : File Of OptionsType;
      R              : Registers;
      Lives          : Array[1..2] Of Integer;
      Points         : Array[1..2] Of Integer;
      Bags           : Array[1..2] Of Integer;
      Levels         : Array[1..2] Of Byte;
      WormLength     : Array[1..2] Of Integer;
      Head           : Array[1..2] Of Integer;
      XPos           : Array[1..2] Of Integer;
      YPos           : Array[1..2] Of Integer;
      XOldPos        : Array[1..2] Of Array[1..(MaxPoints+1)*WormSegment] Of Word;
      YOldPos        : Array[1..2] Of Array[1..(MaxPoints+1)*WormSegment] Of Word;
      XDir           : Array[1..2] Of ShortInt;
      YDir           : Array[1..2] Of ShortInt;
      Dir            : Array[1..2] Of ShortInt;
      PlayerPoints   : Array[1..2] Of Integer;
      PlayerLives    : Array[1..2] Of Integer;
      LivesStats     : Array[1..2] Of LivesStatType;
      PointsStats    : Array[1..2] Of PointsStatType;
      LivesCount     : Array[1..2] Of Byte;
      PointsCount    : Array[1..2] Of Byte;
      Runner        : Array[1..2] Of Integer;
      Level          : Integer;
      Key            : Char;
      X,Y,Z          : Word;
      I              : Integer;
      MButtons       : Integer;
      Strng          : String;
      Ready          : Boolean;
      PlayAgain      : Boolean;
      CircleColor    : Integer;
      LastX,LastY    : Integer;
      Setted         : Boolean;
      CakeSet        : Boolean;
      LeftColor      : Integer;
      RightColor     : Integer;

      FirstTimerLow  : Word;
      FirstTimerHigh : Word;
      Icon           : Array[1..14] Of IconArea;
      PlayerIcons    : Array[1..MaxPlayerIcons] Of IconArea;
      GamePlayed     : Boolean;
      LastPlayer     : Byte;
      What           : Integer;
      LevelData      : LevelType;
      LevelFile      : File Of LevelType;
      TColor         : Array[0..10] Of Integer;

Procedure MouseDelay;
Begin
 While Z<>$0000 Do
 Begin;
  Ms_Read(X,Y,Z);
 End;
End;

Procedure ResetTColor;
Begin
 TColor[00]:=Black;
 TColor[01]:=DarkGray;
 TColor[02]:=White;
 TColor[03]:=Yellow;
 TColor[04]:=LightMagenta;
 TColor[05]:=Red;
 TColor[06]:=LightGreen;
 TColor[07]:=Cyan;
 TColor[08]:=LightCyan;
 TColor[09]:=LightBlue;
 TColor[10]:=Blue;
End;


Procedure SetLevel(Level : Integer);
Var S     : String;
    X,Y,Z : Integer;
Begin
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do
  Begin;
   If LevelData.Area[X][Y]=AttrButton Then Flaeche(X*10+125,Y*10+45,X*10+135,Y*10+55,'');
  End;
 End;
 Str(Level,S);
 While Length(S)<3 Do S:='0'+S;
 S:=LevelName+S;
 If Exist(S) Then
 Begin;
  Assign(LevelFile,S);
  ReSet(LevelFile);
  Read(LevelFile,LevelData);
  Close(LevelFile);
  S:=LevelData.LevelTitle;
  Flaeche(130,025,390,035,S);
  For X:=1 To 25 Do
  Begin;
   For Y:=1 To 25 Do
   Begin;
    If LevelData.Area[X][Y]=AttrButton Then ButtonFrame(Off,X*10+125,Y*10+45,X*10+135,Y*10+55,'');
   End;
  End;
  MaxLevels:=Level;
 End Else MaxLevels:=Level-1;
End;

Procedure LoadIcon(IconName : NameStr; Var LoadedIcon : IconArea);
Var IconFile  : File Of IconType;
    IconDummy : IconType;
    X,Y       : Integer;
Begin
 Assign(IconFile,IconName+IconExt);
 Reset(IconFile);
 Read(IconFile,IconDummy);
 Close(IconFile);
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do LoadedIcon[X][Y]:=BinToDec(IconDummy.Pixel[X][Y]);
 End;
End;

Procedure PushIcon(SetX,SetY : Word; LoadedIcon : IconArea);
Var X,Y : Word;
 Begin
  For X:=1 To 25 Do
  Begin;
   For Y:=1 To 25 Do PutPixel(X+SetX-12,Y+SetY-12,LoadedIcon[X][Y]);
  End;
 End;

Procedure PushIconNoGray(SetX,SetY : Word; LoadedIcon : IconArea);
Var X,Y : Word;
 Begin
  For X:=1 To 25 Do
  Begin;
   For Y:=1 To 25 Do
   Begin;
    If LoadedIcon[X][Y]<>LightGray Then PutPixel(X+SetX-12,Y+SetY-12,LoadedIcon[X][Y]);
   End;
  End;
 End;


Procedure ReFreshOptions(Options : OptionsType);
Begin
 If OldOptions.Players<>OldOptions.Players Then
 Begin;
  RadioButton(Options.Players=1,030,070,150,'THIS DUDE HERE');
  RadioButton(Options.Players=2,030,100,150,'THESE 2 GEEKS');
  If Options.Players=1 Then PushIcon(255,100,PlayerIcons[Options.PlayerIcon[1]]) Else
  If Options.Players=2 Then PushIcon(255,100,PlayerIcons[Options.PlayerIcon[2]]);
 End;
 If OldOptions.PlayerName[1]<>Options.PlayerName[1] Then Flaeche(343,063,427,077,Options.PlayerName[LeftPlayer]);
 If OldOptions.PlayerName[2]<>Options.PlayerName[2] Then Flaeche(343,093,427,107,Options.PlayerName[RightPlayer]);
 If OldOptions.SpeedChange<>Options.SpeedChange Then
 Begin;
  RadioButton(Options.SpeedChange=Constant,030,170,240,'SPEED CONSTANT THROUGH GAME');
  RadioButton(Options.SpeedChange=LevelDependent,030,200,240,'SPEED DEPENDING ON LEVEL');
  RadioButton(Options.SpeedChange=Adjustable,030,230,240,'SPEED ADJUSTABLE DURING GAME');
 End;
 For X:=0 To 10 Do
 Begin;
  ButtonFrame(TColor[X]=Options.PlayerColor[LeftPlayer],280+44+X*16,160,296+44+X*16,180,'');
  If TColor[X]=Options.PlayerColor[LeftPlayer] Then LeftColor:=X;
  ButtonFrame(TColor[X]=Options.PlayerColor[RightPlayer],280+44+X*16,190,296+44+X*16,210,'');
  If TColor[X]=Options.PlayerColor[RightPlayer] Then LeftColor:=X;
 End;
 If OldOptions.SpeedValue>Options.SpeedValue Then
 Begin;
  SetColor(LightGray);
  For X:=OldOptions.SpeedValue*11 DownTo Options.SpeedValue*11 Do
  Begin;
   Line(X+55,253,X+55,279);
  End;
 End Else
 If OldOptions.SpeedValue<Options.SpeedValue Then
 Begin;
  For X:=OldOptions.SpeedValue*11 To Options.SpeedValue*11 Do
  Begin;
   If X/11=Round(X/11) Then
   Begin;
    SetColor(LightGray);
    Line(X+55,253,X+55,279);
    SetColor(Black);
   End Else Line(X+55,254,X+55,278);
  End;
 End;
End;


Procedure InsertPlayerOne(Var PlayerOne : String10);
Var S       : String;
    Key     : Char;
    SLength : Byte;
    B       : Byte;
Begin
 SetColor(Black);
 S:=PlayerOne;
 SLength:=Length(S);
 Key:=#0;
 Repeat;
  If KeyPressed Then
  Begin;
   Key:=ReadKey;
   Key:=UpCase(Key);
   If (Key In ['A'..'Z','0'..'9']) And (SLength<10) Then
   Begin;
    Inc(SLength);
    S:=S+Key;
    Flaeche(340,064,420,76,S);
   End Else
   If (Key=#8) And (SLength>0) Then
   Begin;
    Dec(SLength);
    S:=Copy(S,1,SLength);
    If SLength>0 Then
    Begin;
     Flaeche(340,064,420,76,S);
    End Else
    Begin;
     SLength:=0;
     S:='';
     Flaeche(340,064,420,76,'...');
    End;
   End Else
   If (Key<>#13) Or (SLength=0)Then Beep;
  End;
 Until (Key=#13) And (SLength>0);
 PlayerOne:=S;
End;

Procedure InsertPlayerTwo(Var PlayerTwo : String10);
Var S       : String;
    Key     : Char;
    SLength : Byte;
    B       : Byte;
Begin
 SetColor(Black);
 S:=PlayerTwo;
 SLength:=Length(S);
 Key:=#0;
 Repeat;
  If KeyPressed Then
  Begin;
   Key:=ReadKey;
   Key:=UpCase(Key);
   If (Key In ['A'..'Z','0'..'9']) And (SLength<10) Then
   Begin;
    Inc(SLength);
    S:=S+Key;
    Flaeche(340,094,420,106,S);
   End Else
   If (Key=#8) And (SLength>0) Then
   Begin;
    Dec(SLength);
    S:=Copy(S,1,SLength);
    If SLength>0 Then
    Begin;
     Flaeche(340,094,420,106,S);
    End Else
    Begin;
     SLength:=0;
     S:='';
     Flaeche(340,094,420,106,'...');
    End;
   End Else
   If (Key<>#13) Or (SLength=0)Then Beep;
  End;
 Until (Key=#13) And (SLength>0);
 PlayerTwo:=S;
End;



Procedure SetOneColor(Color : Integer);
Begin
 If Color<>LeftColor Then
 Begin;
  If Color<>RightColor Then
  Begin;
   Ms_Hide;
   ButtonFrame(On,280+44+16*Color,160,296+44+16*Color,180,'');
   Options.PlayerColor[LeftPlayer]:=TColor[Color];
   ButtonFrame(Off,280+44+16*LeftColor,160,296+44+16*LeftColor,180,'');
   LeftColor:=Color;
   Ms_Show;
  End;
 End;
End;

Procedure SetTwoColor(Color : Integer);
Begin
 If Color<>RightColor Then
 Begin;
  If Color<>LeftColor Then
  Begin;
   Ms_Hide;
   ButtonFrame(On,280+44+16*Color,190,296+44+16*Color,210,'');
   Options.PlayerColor[RightPlayer]:=TColor[Color];
   ButtonFrame(Off,280+44+16*RightColor,190,296+44+16*RightColor,210,'');
   RightColor:=Color;
   Ms_Show;
  End;
 End;
End;


Procedure About;
Var Ok : Boolean;
    T  : TextOptionsType;
Begin
 T.Capital:=CapAllUp;
 Button(Off,000,302,520,322,'ABOUT SEAN WORMS');
 Button(Off,000,322,520,479,'');
 PutIcon(020,342,'GUYONE');
 PutIcon(500,342,'GUYTWO');
{ ShowText(040,342,480,459, 'THERE WAS THIS DUDE WHO''S A FRIEND OF MINE, AND HE THOUGHT '+
                           'THAT WE COULD DO A BETTER JOB THAN THE GUYS AT MICROSOFT HAD '+
                           'DONE WHEN THEY ADDED ''NIBBLES'' TO THEIR MS-DOS PACKAGE. '+
                           'SO HIM AND ME STARTED WORKING ON THIS, BUT IT HAS NOT BEEN '+
                           'YET. STILL WORKING. THE MO''');}
 ButtonFrame(Off,400,453,514,473,'OK');
 Ms_Set_VMinMax(302,479);
 Ms_Set_HMinMax(000,520);
 Ms_Show;
 Ok:=False;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Case X Of
  403..511: Case Y Of
            456..470: Begin
                       Ms_Hide;
                       ButtonFrame(On,400,453,514,473,'OK');
                       MouseDelay;
                       ButtonFrame(Off,400,453,514,473,'OK');
                       Ok:=True;
                      End;
            End;
  End;
 Until Ok;
 ClearButton(000,302,520,479);
 Ms_Set_VMinMax(020,302);
 Ms_Set_HMinMax(000,520);
End;


Procedure SetOptions;
Var Ok : Boolean;
Begin
 Button(Off,000,020,520,302,'');
 ButtonFrame(Off,010,030,220,050,'PLAYERS');
 ButtonFrame(Off,010,050,220,120,'');
 RadioButton(Options.Players=1,030,070,150,'THIS DUDE HERE');
 PushIconNoGray(165,70,PlayerIcons[Options.PlayerIcon[1]]);
 RadioButton(Options.Players=2,030,100,150,'THESE 2 GEEKS');
 PushIconNoGray(165,100,PlayerIcons[Options.PlayerIcon[1]]);
 PushIconNoGray(195,100,PlayerIcons[Options.PlayerIcon[2]]);
 ButtonFrame(Off,230,030,510,050,'PLAYER NAMES');
 ButtonFrame(Off,230,050,510,120,'');
 PushIconNoGray(255,070,Icon[GuyOne]);
 ButtonFrame(Off,280,060,320,080,'ICON');
 ButtonFrame(On,330,060,430,080,Options.PlayerName[LeftPlayer]);
 If Options.Players=1 Then PushIconNoGray(255,100,PlayerIcons[Options.PlayerIcon[2]]) Else
 If Options.Players=2 Then PushIconNoGray(255,100,PlayerIcons[Options.PlayerIcon[2]]);
 ButtonFrame(Off,280,090,320,110,'ICON');
 ButtonFrame(On,330,090,430,110,Options.PlayerName[RightPlayer]);
 ButtonFrame(Off,440,060,500,080,'CHANGE');
 ButtonFrame(Off,440,090,500,110,'CHANGE');
 ButtonFrame(Off,010,130,265,150,'SPEED');
 ButtonFrame(Off,010,150,265,292,'');
 RadioButton(Options.SpeedChange=Constant,030,170,250,'SPEED CONSTANT THROUGH GAME');
 RadioButton(Options.SpeedChange=LevelDependent,030,200,250,'SPEED DEPENDING ON LEVEL');
 RadioButton(Options.SpeedChange=Adjustable,030,230,250,'SPEED ADJUSTABLE DURING GAME');
 ButtonFrame(Off,020,250,052,282,'');
 PushIconNoGray(36,266,Icon[Slow]);
 ButtonFrame(On,052,250,223,282,'');
 ButtonFrame(Off,223,250,255,282,'');
 PushIconNoGray(239,266,Icon[Fast]);
 For X:=1 To Options.SpeedValue*11 Do
 Begin;
  If X/11=Round(X/11) Then
  Begin;
   SetColor(LightGray);
   Line(X+55,253,X+55,279);
   SetColor(Black);
  End Else Line(X+55,254,X+55,278);
 End;
 ButtonFrame(Off,275,130,510,150,'COLORS');
 ButtonFrame(Off,275,150,510,222,'');
 PushIconNoGray(299,170,PlayerIcons[Options.PlayerIcon[1]]);
 PushIconNoGray(299,200,PlayerIcons[Options.PlayerIcon[2]]);
 ResetTColor;
 For X:=0 To 10 Do
 Begin;
  ButtonFrame(TColor[X]=Options.PlayerColor[LeftPlayer],280+44+X*16,160,296+44+X*16,180,'');
  If TColor[X]=Options.PlayerColor[LeftPlayer] Then LeftColor:=X;
  SetColor(TColor[X]);
  RectAngle(284+44+X*16,164,292+44+X*16,176);
  SetFillStyle(SolidFill,TColor[X]);
  FloodFill(288+44+X*16,170,TColor[X]);
  ButtonFrame(TColor[X]=Options.PlayerColor[RightPlayer],280+44+X*16,190,296+44+X*16,210,'');
  If TColor[X]=Options.PlayerColor[RightPlayer] Then RightColor:=X;
  SetColor(TColor[X]);
  RectAngle(284+44+X*16,194,292+44+X*16,206);
  SetFillStyle(SolidFill,TColor[X]);
  FloodFill(288+44+X*16,200,TColor[X]);
 End;
 ButtonFrame(Off,275,232,350,292,'');
 PutIcon(312,250,'SEANWORM');
 Flaeche(280,268,344,288,'ABOUT');
 ButtonFrame(Off,360,232,510,252,'SAVE OPTIONS');
 ButtonFrame(Off,360,252,510,272,'RESTORE OPTIONS');
 ButtonFrame(Off,360,272,510,292,'OK');
 Ms_Set_VMinMax(020,302);
 Ms_Set_HMinMax(000,520);
 Ms_Show;
 Ms_Set_GraphPointer(0,0,@Arrow);
 OK:=False;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case X Of
   024..036: Case Y Of
             064..076: If Options.Players=2 Then
                       Begin;
                        Ms_Hide;
                        Options.Players:=1;
                        RadioButton(Options.Players=1,030,070,150,'THIS DUDE HERE');
                        RadioButton(Options.Players=2,030,100,150,'THESE 2 GEEKS');
                        PushIconNoGray(255,100,PlayerIcons[Options.PlayerIcon[2]]);
                        Ms_Show;
                       End;
             094..106: If Options.Players=1 Then
                       Begin;
                        Ms_Hide;
                        Options.Players:=2;
                        RadioButton(Options.Players=1,030,070,150,'THIS DUDE HERE');
                        RadioButton(Options.Players=2,030,100,150,'THESE 2 GEEKS');
                        PushIcon(255,100,PlayerIcons[Options.PlayerIcon[2]]);
                        Ms_Show;
                       End;
             164..174: If Options.SpeedChange<>Constant Then
                       Begin;
                        Ms_Hide;
                        If Options.SpeedChange=LevelDependent Then RadioButton(Off,030,200,250,'SPEED DEPENDING ON LEVEL');
                        If Options.SpeedChange=Adjustable Then RadioButton(Off,030,230,250,'SPEED ADJUSTABLE DURING GAME');
                        RadioButton(On,030,170,250,'SPEED CONSTANT THROUGH GAME');
                        Options.SpeedChange:=Constant;
                        Ms_Show;
                       End;
             194..204: If Options.SpeedChange<>LevelDependent Then
                       Begin;
                        Ms_Hide;
                        If Options.SpeedChange=Constant Then RadioButton(Off,030,170,250,'CONSTANT SPEED THRU GAME') Else
                        If Options.SpeedChange=Adjustable Then RadioButton(Off,030,230,250,'ADJUSTABLE DURING GAME');
                        RadioButton(On,030,200,250,'DEPENDENT ON LEVEL');
                        Options.SpeedChange:=LevelDependent;
                        Ms_Show;
                       End;
             224..234: If Options.SpeedChange<>Adjustable Then
                       Begin;
                        Ms_Hide;
                        If Options.SpeedChange=Constant Then RadioButton(Off,030,170,250,'CONSTANT SPEED THRU GAME') Else
                        If Options.SpeedChange=LevelDependent Then RadioButton(Off,030,200,250,'DEPENDENT ON LEVEL');
                        RadioButton(On,030,230,250,'ADJUSTABLE DURING GAME');
                        Options.SpeedChange:=Adjustable;
                        Ms_Show;
                       End;
             End;
   End;
   Case Y Of
   163..177: Case X Of
             327..337: SetOneColor(0);
             343..353: SetOneColor(1);
             356..369: SetOneColor(2);
             375..385: SetOneColor(3);
             391..401: SetOneColor(4);
             407..417: SetOneColor(5);
             423..433: SetOneColor(6);
             439..449: SetOneColor(7);
             455..465: SetOneColor(8);
             471..481: SetOneColor(9);
             487..497: SetOneColor(10);
            End;
  193..207: Case X Of
             327..337: SetTwoColor(0);
             343..353: SetTwoColor(1);
             356..369: SetTwoColor(2);
             375..385: SetTwoColor(3);
             391..401: SetTwoColor(4);
             407..417: SetTwoColor(5);
             423..433: SetTwoColor(6);
             439..449: SetTwoColor(7);
             455..465: SetTwoColor(8);
             471..481: SetTwoColor(9);
             487..497: SetTwoColor(10);
            End;
  250..282: Case X Of
            020..052: If Options.SpeedValue>1 Then
                      Begin;
                       Dec(Options.SpeedValue);
                       Ms_Hide;
                       ButtonFrame(On,020,250,052,282,'');
                       MouseDelay;
                       SetColor(LightGray);
                       For X:=(Options.SpeedValue+1)*11 DownTo Options.SpeedValue*11 Do
                       Begin;
                        Line(X+55,253,X+55,279);
                       End;
                       ButtonFrame(Off,020,250,052,282,'');
                       Ms_Show;
                      End;
            222..254: If Options.SpeedValue<15 Then
                      Begin;
                       Inc(Options.SpeedValue);
                       Ms_Hide;
                       ButtonFrame(On,223,250,255,282,'');
                       MouseDelay;
                       For X:=(Options.SpeedValue-1)*11 To Options.SpeedValue*11 Do
                       Begin;
                        If X/11=Round(X/11) Then
                        Begin;
                         SetColor(LightGray);
                         Line(X+55,253,X+55,279);
                         SetColor(Black);
                        End Else Line(X+55,254,X+55,278);
                       End;
                       ButtonFrame(Off,223,250,255,282,'');
                       Ms_Show;
                      End;
            End;
  End;
  Case X Of
  443..497: Case Y Of
            063..077: Begin
                       Ms_Hide;
                       ButtonFrame(On,440,060,500,080,'CHANGE');
                       InsertPlayerOne(Options.PlayerName[LeftPlayer]);
                       ButtonFrame(Off,440,060,500,080,'CHANGE');
                       Ms_Show;
                      End;
            093..107: If Options.Players=2 Then
                      Begin;
                       Ms_Hide;
                       ButtonFrame(On,440,090,500,110,'CHANGE');
                       InsertPlayerTwo(Options.PlayerName[RightPlayer]);
                       ButtonFrame(Off,440,090,500,110,'CHANGE');
                       Ms_Show;
                      End Else Beep;
            End;
  End;
  Case X Of
  364..506: Case Y Of
            235..249: Begin
                       Ms_Hide;
                       ButtonFrame(On,360,232,510,252,'SAVE OPTIONS');
                       Assign(OptionsFile,'SEANWORM.OPT');
                       ReWrite(OptionsFile);
                       Write(OptionsFile,Options);
                       Close(OptionsFile);
                       MouseDelay;
                       ButtonFrame(Off,360,232,510,252,'SAVE OPTIONS');
                       Ms_Show;
                      End;
            255..269: If Size('SEANWORM.OPT')=30 Then
                      Begin;
                       Ms_Hide;
                       ButtonFrame(On,360,252,510,272,'RESTORE OPTIONS');
                       OldOptions:=Options;
                       Assign(OptionsFile,'SEANWORM.OPT');
                       ReSet(OptionsFile);
                       Read(OptionsFile,Options);
                       Close(OptionsFile);
                       MouseDelay;
                       ReFreshOptions(Options);
                       ButtonFrame(Off,360,252,510,272,'RESTORE OPTIONS');
                       Ms_Show;
                      End Else Beep;
            275..289: Begin
                       Ms_Hide;
                       ButtonFrame(On,360,272,510,292,'OK');
                       MouseDelay;
                       ButtonFrame(Off,360,272,510,292,'OK');
                       Ok:=True;
                      End;
            End;
   End;
   Case X Of
   277..347: Case Y Of
             235..289: Begin
                        Ms_Hide;
                        ButtonFrame(On,275,232,350,292,'');
                        MouseDelay;
                        About;
                        ButtonFrame(Off,275,232,350,292,'');
                        Ms_Show;
                       End;
             End;
   End;
  End;
 Until Ok=True;
 ClearButton(000,020,520,302);
 Ms_Set_HMinMax(000,639);
 Ms_Set_VMinMax(000,479);
End;



Procedure PlayingScreen;
Begin
 Button(Off,000,020,120,080,'');
 PushIcon(060,040,PlayerIcons[Options.PlayerIcon[1]]);
 Flaeche(010,060,110,070,Options.PlayerName[LeftPlayer]);
 Button(Off,000,080,120,324,'');
 ButtonFrame(On,012,090,036,271,'');
 ButtonFrame(On,048,090,072,271,'');
 ButtonFrame(On,084,090,108,271,'');
 PushIcon(25,300,Icon[Heart]);
 PushIcon(60,300,Icon[Money]);
 PushIcon(95,300,Icon[LotsOPoints]);
 If Options.Players=2 Then
 Begin;
  Button(Off,400,020,520,80,'');
  If Options.PlayerName[RightPlayer]<>'COMPUTER' Then PushIcon(460,42,PlayerIcons[Options.PlayerIcon[1]]) Else
  PushIcon(460,42,Icon[Computer]);
  Flaeche(410,060,510,070,Options.PlayerName[RightPlayer]);
  Button(Off,400,080,520,324,'');
  ButtonFrame(On,412,090,436,271,'');
  ButtonFrame(On,448,090,472,271,'');
  ButtonFrame(On,484,090,508,271,'');
  PushIcon(425,300,Icon[Heart]);
  PushIcon(460,300,Icon[Money]);
  PushIcon(495,300,Icon[LotsOPoints]);
 End;
 Button(Off,120,020,400,040,'');
 Button(Off,120,040,400,324,'');
 ButtonFrame(On,133,052,388,308,'');
End;

Procedure SetBags(Player : Integer;CurrentBags,NewBags : Integer);
Const BagsX      : Array[1..2] Of Integer = (054,452);
      BagsY      : Array[1..2] Of Integer = (268,268);
Var Y : Integer;
Begin
 If NewBags<=MaxBags Then
 Begin;
  If CurrentBags<NewBags Then
  Begin;
   SetColor(Options.PlayerColor[Player]);
   For Y:=CurrentBags*5 To NewBags*5 Do
   Begin;
    If Y/5=Round(Y/5) Then
    Begin;
     SetColor(LightGray);
     Line(BagsX[Player],BagsY[Player]-Y,BagsX[Player]+16,BagsY[Player]-Y);
     SetColor(Options.PlayerColor[Player]);
     Delay(50);
    End Else Line(BagsX[Player],BagsY[Player]-Y,BagsX[Player]+16,BagsY[Player]-Y);
   End;
  End Else
  If CurrentBags>NewBags Then
  Begin;
   SetColor(LightGray);
   For Y:=CurrentBags*5 DownTo NewBags*5 Do
   Begin;
    If Y/5=Round(Y/5) Then
    Begin;
     Delay(50);
    End;
    Line(BagsX[Player],BagsY[Player]-Y,BagsX[Player]+16,BagsY[Player]-Y);
   End;
  End;
 End;
End;




Procedure SetLives(Player : Integer;CurrentLives,NewLives : Integer);
Const LivesX       : Array[1..2] Of Integer = (016,416);
      LivesY       : Array[1..2] Of Integer = (268,268);
Var Y : Integer;
Begin
 If NewLives<=MaxLives Then
 Begin;
  If CurrentLives<NewLives Then
  Begin;
   SetColor(Options.PlayerColor[Player]);
   For Y:=CurrentLives*5 To NewLives*5 Do
   Begin;
    If Y/5=Round(Y/5) Then
    Begin;
     SetColor(LightGray);
     Line(LivesX[Player],LivesY[Player]-Y,LivesX[Player]+16,LivesY[Player]-Y);
     SetColor(Options.PlayerColor[Player]);
     Delay(50);
    End Else Line(LivesX[Player],LivesY[Player]-Y,LivesX[Player]+16,LivesY[Player]-Y);
   End;
  End Else
  If CurrentLives>NewLives Then
  Begin;
   SetColor(LightGray);
   For Y:=CurrentLives*5 DownTo NewLives*5 Do
   Begin;
    If Y/5=Round(Y/5) Then
    Begin;
     Delay(50);
    End;
    Line(LivesX[Player],LivesY[Player]-Y,LivesX[Player]+16,LivesY[Player]-Y);
   End;
  End;
 End;
End;


Procedure SetPoints(Player : Integer;CurrentPoints,NewPoints : Integer);
Const PointsX      : Array[1..2] Of Integer = (088,488);
      PointsY      : Array[1..2] Of Integer = (268,268);
Var Y : Integer;
Begin
 If NewPoints<=MaxPoints Then
 Begin;
  If CurrentPoints<NewPoints Then
  Begin;
   SetColor(Options.PlayerColor[Player]);
   For Y:=CurrentPoints*5 To NewPoints*5 Do
   Begin;
    If Y/5=Round(Y/5) Then
    Begin;
     SetColor(LightGray);
     Line(PointsX[Player],PointsY[Player]-Y,PointsX[Player]+16,PointsY[Player]-Y);
     SetColor(Options.PlayerColor[Player]);
     Delay(50);
    End Else Line(PointsX[Player],PointsY[Player]-Y,PointsX[Player]+16,PointsY[Player]-Y);
   End;
  End Else
  If CurrentPoints>NewPoints Then
  Begin;
   SetColor(LightGray);
   For Y:=CurrentPoints*5 DownTo NewPoints*5 Do
   Begin;
    If Y/5=Round(Y/5) Then
    Begin;
     Delay(50);
    End;
    Line(PointsX[Player],PointsY[Player]-Y,PointsX[Player]+16,PointsY[Player]-Y);
   End;
  End;
 End Else
 If NewPoints>MaxPoints Then
 Begin;
  SetBags(Player,Bags[Player],Bags[Player]+1);
  Points[Player]:=0;
  SetColor(LightGray);
  For Y:=MaxPoints*5 DownTo 0 Do
  Begin;
   If Y/5=Round(Y/5) Then
   Begin;
    Delay(50);
   End;
   Line(PointsX[Player],PointsY[Player]-Y,PointsX[Player]+16,PointsY[Player]-Y);
  End;
 End;
End;


Procedure EraseWorms;
Var X : Integer;
Begin
 For X:=1 To WormSegment*MaxPoints Do
 Begin;
  If X/3=Int(X/3) Then
  Begin;
   For Z:=1 To Options.Players Do If X<=(Points[Z]+1)*WormSegment Then PutPixel(XOldPos[Z][X],YOldPos[Z][X],LightGray);
  End;
 End;
 For X:=1 To WormSegment*MaxPoints Do
 Begin;
  If X/2=Int(X/2) Then
  Begin;
   For Z:=1 To Options.Players Do If X<=(Points[Z]+1)*WormSegment Then PutPixel(XOldPos[Z][X],YOldPos[Z][X],LightGray);
  End;
 End;
 For X:=1 To WormSegment*MaxPoints Do
 Begin;
  For Z:=1 To Options.Players Do If X<=(Points[Z]+1)*WormSegment Then PutPixel(XOldPos[Z][X],YOldPos[Z][X],LightGray);
 End;
End;

Function GetStatisticTime : LongInt;
Var R : Registers;
Begin
 R.Ah:=$00;
 Intr($1A,R);
 GetStatisticTime:=R.Cx*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2+R.Dx;
End;

Procedure GetLives(Player,Lives,Count : Byte);
Begin
 LivesStats[Player].Lives[Count]:=Lives;
 LivesStats[Player].Time[Count]:=GetStatisticTime;
End;

Procedure GetPoints(Player,Points,Count : Byte);
Begin
 PointsStats[Player].Points[Count]:=Points;
 PointsStats[Player].Time[Count]:=GetStatisticTime;
End;


Procedure SetNibbleCakes;
Begin
 If CakeSet Then
 Begin;
  SetColor(LightGray);
  SetFillStyle(SolidFill,LightGray);
  PieSlice(LastX*10+131,LastY*10+51,1,360,3);
 End;
 If (Points[LeftPlayer]<>MaxPoints) And (Points[RightPlayer]<>MaxPoints) Then
 Begin;
  Randomize;
  CakeSet:=True;
  Repeat;
   LastX:=Random(24)+1;
   LastY:=Random(24)+1;
   What:=Random(30);
  Until Not (LevelData.Area[LastX][LastY] In [AttrButton,AttrRestricted]);
  Case What Of
    5,19: PushIconNoGray(LastX*10+130,LastY*10+50,Icon[Extra]);
    1,15: PushIconNoGray(LastX*10+130,LastY*10+50,Icon[Life]);
     Else PushIconNoGray(LastX*10+130,LastY*10+50,Icon[Point]);
  End;
 End;
End;


Procedure ResetWorms;
Begin
 XPos[LeftPlayer]:=140;
 YPos[LeftPlayer]:=060;
 XPos[RightPlayer]:=370;
 YPos[RightPlayer]:=300;
 XDir[LeftPlayer]:=1;
 YDir[LeftPlayer]:=0;
 XDir[RightPlayer]:=-1;
 YDir[RightPlayer]:=0;
 For Z:=WormSegment*MaxPoints DownTo 1 Do
 Begin;
  XOldPos[LeftPlayer][Z]:=140;
  YOldPos[LeftPlayer][Z]:=060;
  XOldPos[RightPlayer][Z]:=380;
  YOldPos[RightPlayer][Z]:=310;
 End;
 If Options.Players=1 Then Head[RightPlayer]:=LightGray;
End;

{Procedure ControllHead;
Var R    : Registers;
    Time : LongInt;
Begin
 R.Ah:=$00;
 Intr($1A,R);
 Time:=R.Cx*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2+R.Dx;
 If ((Time/18.2)/10=Round((Time/18.2)/10)) And (Not Setted) Then
 Begin;
  PushIcon(195,105,Icon[GuyTwOff]);
  Delay(200);
  Setted:=True;
 End;
 If Setted Then
 Begin;
  PushIcon(195,105,Icon[GuyTwo]);
  Setted:=False;
 End;
End;}


Procedure BuildLevel(Level : Integer);
Begin

 Case Level Of
  2: Begin
      ButtonFrame(Off,140,171,368,181,'');
     End;
 End;
End;


Procedure Game;
Begin
 Ready:=False;
 Level:=1;
 Setted:=False;
 Lives[LeftPlayer]:=10;
 Lives[RightPlayer]:=10;
 LivesCount[LeftPlayer]:=1;
 LivesCount[RightPlayer]:=1;
 WormLength[LeftPlayer]:=1;
 WormLength[RightPlayer]:=1;
 PointsCount[LeftPlayer]:=1;
 PointsCount[RightPlayer]:=1;
 Points[LeftPlayer]:=0;
 Points[RightPlayer]:=0;
 Bags[LeftPlayer]:=0;
 Bags[RightPlayer]:=0;
 Levels[LeftPlayer]:=0;
 Levels[RightPlayer]:=0;
 ResetWorms;
 SetLives(LeftPlayer,0,Lives[LeftPlayer]);
 If Options.Players=2 Then SetLives(RightPlayer,0,Lives[RightPlayer]);
 LivesStats[LeftPlayer].Lives[LivesCount[LeftPlayer]]:=Lives[LeftPlayer];
 LivesStats[LeftPlayer].Time[LivesCount[LeftPlayer]]:=0;
 If Options.Players=2 Then LivesStats[RightPlayer].Lives[LivesCount[RightPlayer]]:=Lives[RightPlayer];
 If Options.Players=2 Then LivesStats[RightPlayer].Time[LivesCount[RightPlayer]]:=0;
 PointsStats[LeftPlayer].Points[PointsCount[LeftPlayer]]:=Points[LeftPlayer];
 PointsStats[LeftPlayer].Time[PointsCount[LeftPlayer]]:=0;
 If Options.Players=2 Then PointsStats[RightPlayer].Points[PointsCount[RightPlayer]]:=Points[RightPlayer];
 If Options.Players=2 Then PointsStats[RightPlayer].Time[PointsCount[RightPlayer]]:=0;
 R.Ah:=$00;
 Intr($1A,R);
 FirstTimerHigh:=R.Cx;
 FirstTimerLow:=R.Dx;
 R.Ah:=$01;
 R.Cx:=$00;
 R.Dx:=$00;
 Intr($1A,R);
 SetNibbleCakes;
 Repeat;
  Repeat;
   Repeat;
    For Z:=1 To Options.Players Do PutPixel(XPos[Z],YPos[Z],Options.PlayerColor[Z]);
    Delay(20-Options.SpeedValue);
    For Z:=1 To Options.Players Do
    Begin;
     If GetPixel(XOldPos[Z][Runner[Z]],YOldPos[Z][Runner[Z]])<>LightGray Then
     PutPixel(XOldPos[Z][Runner[Z]],YOldPos[Z][Runner[Z]],LightGray);
    End;
    For Z:=1 To Options.Players Do XOldPos[Z][Runner[Z]]:=XPos[Z];
    For Z:=1 To Options.Players Do YOldPos[Z][Runner[Z]]:=YPos[Z];
    For Z:=1 To Options.Players Do Inc(XPos[Z],XDir[Z]);
    For Z:=1 To Options.Players Do Inc(YPos[Z],YDir[Z]);
    For Z:=1 To Options.Players Do Head[Z]:=GetPixel(XPos[Z],YPos[Z]);
    For Z:=1 To Options.Players Do Inc(Runner[Z]);
    If (Runner[LeftPlayer]>(Points[LeftPlayer]+1)*WormSegment) Then Runner[LeftPlayer]:=1;
    If (Runner[RightPlayer]>(Points[RightPlayer]+1)*WormSegment) Then Runner[RightPlayer]:=1;
   Until (Lives[LeftPlayer]<1) Or (Lives[RightPlayer]<1) Or (Head[1]<>LightGray) Or (Head[2]<>LightGray) Or KeyPressed;
   If KeyPressed Then
   Begin;
    Key:=ReadKey;
    Case Key Of
           #72: Begin
                 If YDir[RightPlayer]<>1 Then YDir[RightPlayer]:=-1;
                 XDir[RightPlayer]:=0;
                End;
           #77: Begin;
                 If XDir[RightPlayer]<>-1 Then XDir[RightPlayer]:=1;
                 YDir[RightPlayer]:=0;
                End;
           #80: Begin;
                 If YDir[RightPlayer]<>-1 Then YDir[RightPlayer]:=1;
                 XDir[RightPlayer]:=0;
                End;
           #75: Begin;
                 If XDir[RightPlayer]<>1 Then XDir[RightPlayer]:=-1;
                 YDir[RightPlayer]:=0;
                End;
          #119: Begin
                 If YDir[LeftPlayer]<>1 Then YDir[LeftPlayer]:=-1;
                 XDir[LeftPlayer]:=0;
                End;
          #100: Begin;
                 If XDir[LeftPlayer]<>-1 Then XDir[LeftPlayer]:=1;
                 YDir[LeftPlayer]:=0;
                End;
          #115: Begin;
                 If YDir[LeftPlayer]<>-1 Then YDir[LeftPlayer]:=1;
                 XDir[LeftPlayer]:=0;
                End;
           #97: Begin;
                 If XDir[LeftPlayer]<>1 Then XDir[LeftPlayer]:=-1;
                 YDir[LeftPlayer]:=0;
                End;
    End;
   End Else If (Head[LeftPlayer]<>LightGray) Or (Head[RightPlayer]<>LightGray) Then
   Begin;
    For I:=1 To Options.Players Do
    Case Head[I] Of
     LightRed: Begin
                If Lives[I]<MaxLives Then
                Begin;
                 Inc(Lives[I]);
                 SetLives(I,Lives[I]-1,Lives[I]);
                 Sound(200);
                 Delay(50);
                 NoSound;
                 Inc(LivesCount[I]);
                 GetLives(I,Lives[I],LivesCount[I]);
                End;
                {EraseWorms;}
                SetNibbleCakes;
               End;
     Green   : Begin
                If Points[I]<MaxPoints Then
                Begin;
                 Inc(Points[I]);
                 Inc(WormLength[I]);
                 SetPoints(I,Points[I]-1,Points[I]);
                 Sound(200);
                 Delay(50);
                 NoSound;
                 Inc(PointsCount[I]);
                 GetPoints(I,Points[I],PointsCount[I]);
                End;
                SetNibbleCakes;
               End;
     Magenta : Begin
                Randomize;
                What:=0; {Random(2);}
                Case What Of
                 0: Begin
                     If Lives[I]<MaxLives Then
                     Begin;
                      Inc(Lives[I]);
                      SetLives(I,Lives[I]-1,Lives[I]);
                      Sound(200);
                      Delay(50);
                      NoSound;
                      Inc(LivesCount[I]);
                      GetLives(I,Lives[I],LivesCount[I]);
                     End Else If Points[I]=MaxLives Then
                     Begin;
                      If Points[I]<MaxPoints Then
                      Begin;
                       Inc(Points[I]);
                       Inc(WormLength[I]);
                       SetPoints(I,Points[I]-1,Points[I]);
                       Sound(200);
                       Delay(50);
                       NoSound;
                       Inc(PointsCount[I]);
                       GetPoints(I,Points[I],PointsCount[I]);
                      End;
                     End;
                     SetNibbleCakes;
                    End;
                 1: Begin
                     If Lives[I]+3<=MaxLives Then
                     Begin;
                      For I:=1 To 3 Do
                      Begin;
                       Inc(Lives[I]);
                       SetLives(I,Lives[I]-1,Lives[I]);
                       Sound(200);
                       Delay(50);
                       NoSound;
                       Inc(LivesCount[I]);
                       GetLives(I,Lives[I],LivesCount[I]);
                       Delay(200);
                      End;
                     End Else If Lives[I]+3>MaxLives Then
                     Begin;
                      For I:=1 To 3 Do
                      Begin;
                       Dec(Lives[I]);
                       SetLives(I,Lives[I]+1,Lives[I]);
                       Sound(200);
                       Delay(50);
                       NoSound;
                       Inc(LivesCount[I]);
                       GetLives(I,Lives[I],LivesCount[I]);
                       Delay(200);
                      End;
                      EraseWorms;
                     End;
                     SetNibbleCakes;
                    End;
                 2: Begin
                    If Points[I]>0 Then
                     Begin;
                      For I:=Points[I] DownTo 0 Do
                      Begin;
                       Dec(Points[I]);
                       SetPoints(I,Points[I]+1,Points[I]);
                       Dec(WormLength[I]);
                       Sound(200);
                       Delay(50);
                       NoSound;
                      End;
                      Inc(PointsCount[I]);
                      GetPoints(I,Points[I],PointsCount[I]);
                     End Else If Points[I]=0 Then
                     Begin;
                      Inc(Points[I]);
                      Inc(WormLength[I]);
                      SetPoints(I,Points[I]-1,Points[I]);
                      Sound(200);
                      Delay(50);
                      NoSound;
                      Inc(PointsCount[I]);
                      GetPoints(I,Points[I],PointsCount[I]);
                     End;
                     {EraseWorms;}
                     SetNibbleCakes;
                    End;
                   End;
                 End;
    End;
    If Head[I] In [Options.PlayerColor[1],Options.PlayerColor[2],Black,White,DarkGray] Then
    Begin;
     If Lives[I]>0 Then
     Begin;
      Dec(Lives[I]);
      SetLives(I,Lives[I]+1,Lives[I]);
      Inc(LivesCount[I]);
      GetLives(I,Lives[I],LivesCount[I]);
      If Lives[I]=0 Then LastPlayer:=I;
      If Points[I]>0 Then
      Begin;
       Dec(Points[I]);
       SetPoints(I,Points[I]+1,Points[I]);
       Dec(WormLength[I]);
      End;
      Sound(50);
      Delay(200);
      NoSound;
      Inc(PointsCount[I]);
      GetPoints(I,Points[I],PointsCount[I]);
     End;
     EraseWorms;
     ResetWorms;
     If Lives[I]>0 Then SetNibbleCakes;
    End;
   End;
  Until (Lives[1]<1) Or (Points[1]=MaxPoints) Or (Lives[2]<1) Or (Points[2]=MaxPoints);
  If (Points[LeftPlayer]=MaxPoints) Or (Points[RightPlayer]=MaxPoints) Then
  Begin;
   EraseWorms;
   Inc(Level);
   If Points[LeftPlayer]=MaxPoints Then Inc(Levels[LeftPlayer]) Else
   If Points[RightPlayer]=MaxPoints Then Inc(Levels[RightPlayer]);
   SetPoints(LeftPlayer,Points[LeftPlayer],0);
   If Options.Players=2 Then SetPoints(RightPlayer,Points[RightPlayer],0);
   SetLevel(Level);
   ReSetWorms;
   WormLength[LeftPlayer]:=1;
   WormLength[RightPlayer]:=1;
   Points[LeftPlayer]:=0;
   Points[RightPlayer]:=0;
   SetPoints(LeftPlayer,Points[LeftPlayer],0);
   If Options.Players=2 Then SetPoints(RightPlayer,Points[RightPlayer],0);
   If Level<=MaxLevels Then SetNibbleCakes;
   If Level>MaxLevels Then Lives[LeftPlayer]:=0;
  End;
 Until (Lives[LeftPlayer]<1) Or (Lives[RightPlayer]<1);
 R.Ah:=$00;
 Intr($1A,R);
 R.Ah:=$01;
 R.Cx:=R.Cx+FirstTimerHigh;
 R.Dx:=R.Dx+FirstTimerLow;
 Intr($1A,R);
 If Options.Players=2 Then ClearButton(0,20,520,324) Else
 If Options.Players=1 Then ClearButton(0,20,420,324);
End;

Procedure SetString(Color : Integer;LX,RX,Y : Word;Strng : String);
Begin
 Strng:=Gross(Strng);
 SetColor(Color);
 OutTextXY(Round((RX-LX)/2)-Round(TextWidth(Strng)/2)+2+LX,Y-Round(TextHeight(Strng)/2),Strng);
End;


Procedure ShowLivesStatistic;
Var S   : String;
    A,B : Integer;
Begin
 For A:=1 To Options.Players Do
 Begin;
  MoveTo(36,Round(404-284*PointsStats[A].Points[1]/MaxPoints));
  PutPixel(36,Round(404-284*PointsStats[A].Points[1]/MaxPoints),Black);
  SetColor(LightGray);
  For B:=2 To PointsCount[A] Do
  Begin;
   LineTo(Round(36+446*PointsStats[A].Time[B]/PointsStats[A].Time[PointsCount[A]]),
   Round(404-284*PointsStats[A].Points[B]/MaxPoints));
   If PointsStats[A].Points[B]=0 Then PutPixel(Round(36+446*PointsStats[A].Time[B]/PointsStats[A].Time[PointsCount[A]]),
                                               Round(404-284*PointsStats[A].Points[B]/MaxPoints),Black);
  End;
 End;
 SetColor(Black);
 Line(36,120,36,404+5);
 Line(36-5,404,482,404);
 Line(482,404,482,404+5);
 For A:=1 To Options.Players Do
 Begin;
  SetColor(Options.PlayerColor[A]);
  MoveTo(36,Round(404-284*LivesStats[A].Lives[1]/MaxLives));
  For B:=2 To LivesCount[A] Do
  Begin;
   LineTo(Round(36+446*LivesStats[A].Time[B]/LivesStats[A].Time[LivesCount[A]]),
   Round(404-284*LivesStats[A].Lives[B]/MaxLives));
  End;
 End;
End;

Procedure ShowPointsStatistic;
Var S   : String;
    A,B : Integer;
Begin
 For A:=1 To Options.Players Do
 Begin;
  MoveTo(36,Round(404-284*LivesStats[A].Lives[1]/MaxLives));
  PutPixel(36,Round(404-284*LivesStats[A].Lives[1]/MaxLives),Black);
  SetColor(LightGray);
  For B:=2 To LivesCount[A] Do
  Begin;
   LineTo(Round(36+446*LivesStats[A].Time[B]/LivesStats[A].Time[LivesCount[A]]),
          Round(404-284*LivesStats[A].Lives[B]/MaxLives));
   If LivesStats[A].Lives[B]=0 Then PutPixel(Round(36+446*LivesStats[A].Time[B]/LivesStats[A].Time[LivesCount[A]]),
                                               Round(404-284*LivesStats[A].Lives[B]/MaxLives),Black);
  End;
 End;
 SetColor(Black);
 Line(36-5,120,36,120);
 Line(36,120,36,404+5);
 Line(36-5,404,482,404);
 Line(482,404,482,404+5);
 For A:=1 To Options.Players Do
 Begin;
  SetColor(Options.PlayerColor[A]);
  MoveTo(36,Round(404-284*PointsStats[A].Points[1]/MaxPoints));
  For B:=2 To PointsCount[A] Do
  Begin;
   LineTo(Round(36+446*PointsStats[A].Time[B]/PointsStats[A].Time[PointsCount[A]]),
   Round(404-284*PointsStats[A].Points[B]/MaxPoints));
  End;
 End;
End;


Procedure ViewHallOfFame;
Begin
End;


Procedure Statistics;
Var S          : String;
    A,B        : Integer;
    I          : Integer;
    Ok         : Boolean;
    LivesShown : Boolean;
Begin
 Button(Off,000,020,300,040,'STATISTICS');
 Button(Off,000,040,300,300,'');
 Button(Off,300,020,520,040,'DATA');
 Button(Off,300,040,520,110,'');
 RadioButton(On,320,060,400,'LIVES VS');
 RadioButton(Off,320,090,400,'POINTS VS');
 RadioButton(On,410,060,505,'ACTUAL TIME');
 RadioButton(Off,410,090,505,'LEVEL');
 Button(Off,300,110,520,130,'GRAPH');
 Button(Off,300,130,520,190,'');
 RadioButton(On,320,150,500,'STANDARD GRAPH F(X)');
 RadioButton(Off,320,170,500,'FIRST DERIVATIVE F''(X)');
 Button(Off,300,190,520,210,'TYPE OF GRAPH');
 Button(Off,300,210,520,270,'');
 ButtonFrame(Off,310,220,350,260,'');
 PutIcon(330,240,'LINECHAR');
 ButtonFrame(Off,360,220,400,260,'');
 PutIcon(380,240,'BARCHART');
 ButtonFrame(Off,410,220,450,260,'');
 PutIcon(430,240,'PIECHART');
 Button(Off,300,270,520,290,'PLAYERS');
 Button(Off,300,290,520,400,'');
 ButtonFrame(Off,310,300,350,340,'');
 PushIcon(330,320,Icon[LeftPlayer]);
 SetColor(Options.PlayerColor[LeftPlayer]);
 RectAngle(315,305,345,335);
 ButtonFrame(Off,360,300,400,340,'');
 PushIcon(380,320,Icon[RightPlayer]);
 SetColor(Options.PlayerColor[RightPlayer]);
 RectAngle(365,305,395,335);




 ReadLn;

 Button(Off,120,040,400,080,'');
 Button(Off,400,020,520,80,'');
 If Options.PlayerName[RightPlayer]<>'COMPUTER' Then PushIcon(460,42,Icon[GuyTwo]) Else PushIcon(460,42,Icon[Computer]);
 Flaeche(410,060,510,070,Options.PlayerName[RightPlayer]);
 Button(Off,000,080,520,100,'');
 Button(Off,000,100,520,400,'');
 ButtonFrame(On,012,112,508,300,'');
 ReadLn;
End;

{Procedure Statistics;
Var S          : String;
    A,B        : Integer;
    I          : Integer;
    Ok         : Boolean;
    LivesShown : Boolean;
Begin
 Button(Off,
 Button(Off,0,22,518,480,'');
 PushIcon(50,42,Icon[GuyOne]);
 Flaeche(6,62,94,82,Options.PlayerName[LeftPlayer]);
 SetColor(Red);
 RectAngle(6,62,94,82);
 If Options.Players=2 Then PushIcon(468,42,Icon[GuyTwo]);
 If Options.Players=2 Then Flaeche(424,62,512,82,Options.PlayerName[RightPlayer]);
 If Options.Players=2 Then SetColor(Blue);
 If Options.Players=2 Then RectAngle(424,62,512,82);
 ButtonFrame(On,6,90,512,434,'');
 Switcher(176,440,284,474,'LIVES');
 ButtonFrame(On,182,446,278,468,'LIVES');
 Switcher(290,440,398,474,'POINTS');
 Switcher(404,440,512,474,'OK');

 SetColor(Black);
 Line(36-5,120,36,120);
 Line(36,120,36,404+5);
 Line(36-5,404,482,404);
 Line(482,404,482,404+5);
 Str(MaxLives,S);
 SetString(Black,20,25,120,S);
 SetString(Black,36,36,415,'0');
 SetString(Black,25,25,404,'0');
 If Round((LivesStats[LastPlayer].Time[LivesCount[LastPlayer]]/18.2)/60)>=1 Then
 Begin;
  Str(Round((LivesStats[LastPlayer].Time[LivesCount[LastPlayer]]/18.2)/60),S);
  PutString(482,482,415,S+' MIN');
 End Else
 If Round((LivesStats[LastPlayer].Time[LivesCount[LastPlayer]]/18.2)/60)=0 Then
 Begin;
  Str(Round(LivesStats[LastPlayer].Time[LivesCount[LastPlayer]]/18.2),S);
  PutString(482,482,415,S+' SEC');
 End;
 For A:=1 To Options.Players Do
 Begin;
  SetColor(Options.PlayerColor[A]);
  MoveTo(36,Round(404-284*LivesStats[A].Lives[1]/MaxLives));
  For B:=2 To LivesCount[A] Do
  Begin;
   LineTo(Round(36+446*LivesStats[A].Time[B]/LivesStats[A].Time[LivesCount[A]]),
   Round(404-284*LivesStats[A].Lives[B]/MaxLives));
  End;
 End;

 LivesShown:=True;
 Ok:=False;
 Ms_Show;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Case Y Of
  446..468: Case X Of
            182..278: If Not LivesShown Then
                      Begin;
                       Ms_Hide;
                       ButtonFrame(On,182,446,278,468,'LIVES');
                       ButtonFrame(Off,296,446,392,468,'POINTS');
                       ShowLivesStatistic;
                       LivesShown:=True;
                       Ms_Show;
                      End;
            296..392: If LivesShown Then
                      Begin;
                       Ms_Hide;
                       ButtonFrame(On,296,446,392,468,'POINTS');
                       ButtonFrame(Off,182,446,278,468,'LIVES');
                       ShowPointsStatistic;
                       LivesShown:=False;
                       Ms_Show;
                      End;
            410..506: Begin
                       Ms_Hide;
                       ButtonFrame(On,410,446,506,468,'OK');
                       MouseDelay;
                       ButtonFrame(Off,410,446,506,468,'OK');
                       Ok:=True;
                      End;
            End;
  End;
 Until Ok=True;
 ClearButton(0,22,518,480);
 Ms_Show;
End;}

Procedure LastSequence;
Begin
{ Button(Off,210,150,430,320,'');
 PutString(210,430,175,'ASK YOUR LOCAL DEALER');
 PutString(210,430,205,'FOR FURTHER DETAILS');
 PutString(210,430,235,'OR CALL 030 - 677 33 22');
 PutIcon(320,265,'PHONE');
 PutString(210,430,295,'(C) 1994 SEAN COMPANY');
 Delay(3000);
 ClearButton(210,150,430,320);}
End;

Procedure ClearEndScreen;
Begin
 ClearButton(520,130,639,479);
 ClearButton(520,110,639,130);
 ClearButton(520,100,639,110);
 ClearButton(520,080,639,100);
 ClearButton(520,070,639,080);
 ClearButton(520,050,639,070);
 ClearButton(520,030,639,050);
 ClearButton(520,020,639,030);
 ClearButton(520,001,639,020);
 ClearButton(000,001,520,020);
End;

Function FileDate(FName : String) : String;
Var S    : String;
    R    : String;
    Sr   : SearchRec;
    Time : DateTime;
Begin
 S:='';
 FindFirst(FName,AnyFile,Sr);
 If DosError=0 Then
 Begin;
  UnPackTime(Sr.Time,Time);
  Str(Time.Month,R);
  S:=S+R+'/';
  Str(Time.Day,R);
  S:=S+R+'/';
  Str(Time.Year,R);
  S:=S+R;
 End Else S:='N/A';
 FileDate:=S;
End;





 Begin
  DetectGraph(Driver,Mode);
  InitGraph(Driver,Mode,'C:\Dos\Pascal\Bgi');
{  Check;}
  If Not Ms_Init(MButtons) Then
  Begin;
   Delay(2500);
   Button(Off,210,150,430,320,'');
   PutString(210,430,175,'SORRY, TO RUN THIS');
   PutIcon(320,220,'TURTLE');
   PutString(210,430,265,'A MICROSOFT-COMPATIBLE');
   PutString(210,430,295,'MOUSE IS REQUIRED');
   Delay(5000);
   ClearButton(210,150,430,320);
   CloseGraph;
   Halt;
  End;
  LoadIcon('SEANWORM',Icon[SeanWorm]);
  If Exist('SEANWORM.OPT') And (Size('SEANWORM.OPT')=30) Then
  Begin;
   Assign(OptionsFile,'SEANWORM.OPT');
   Reset(OptionsFile);
   Read(OptionsFile,Options);
   Close(OptionsFile);
  End Else
  Begin;
   Options. Players          :=$01;
   Options. PlayerName[$01]  :='BEPPO';
   Options. PlayerName[$02]  :='DOEDEL';
   Options. PlayerColor[$01] :=Red;
   Options. PlayerColor[$02] :=Blue;
   Options. PlayerIcon[$01] :=$01;
   Options. PlayerIcon[$01] :=$02;
   Options. SpeedChange      :=Constant;
   Options. SpeedValue       :=$05;
   Assign(OptionsFile,'SEANWORM.OPT');
   ReWrite(OptionsFile);
   Write(OptionsFile,Options);
   Close(OptionsFile);
  End;
  {SeAnInfo('SEAN WORMS',FileDate('WORMTEST.PAS'),'1994',Icon[SeAnWorm]);}
  LoadIcon('GUYONE',Icon[GuyOne]);
  LoadIcon('GUYTWO',Icon[GuyTwo]);
  LoadIcon('GUYTWONO',Icon[GuyTwoNo]);
  LoadIcon('GUYTWOFF',Icon[GuyTwOff]);
  LoadIcon('HEART',Icon[Heart]);
  LoadIcon('MONEY',Icon[Money]);
  LoadIcon('SLOW',Icon[Slow]);
  LoadIcon('FAST',Icon[Fast]);
  LoadIcon('LIFE',Icon[Life]);
  LoadIcon('POINT',Icon[Point]);
  LoadIcon('EXTRA',Icon[Extra]);
  LoadIcon('Points',Icon[LotsOPoints]);
  LoadIcon('COMPUTER',Icon[Computer]);
  {SwapVectors;
  Exec('MP.COM','/q VGACOPY.MOD');
  SwapVectors;}

  Button(Off,520,001,639,020,'END');
  Button(Off,520,020,639,030,'');
  Button(Off,520,030,639,050,'START GAME');
  Button(Off,520,050,639,070,'OPTIONS');
  Button(Off,520,070,639,080,'');
  Button(Off,520,080,639,100,'STATISTICS');
  Button(Off,520,100,639,110,'');
  Button(Off,520,110,639,130,'HALL OF FAME');
  Button(Off,520,130,639,479,'');
  Button(Off,000,001,520,20,'SEAN WORMS VER '+FileDate('WORMTEST.PAS'));
  PushIcon(580,295,Icon[SeanWorm]);
  If Ms_Init(MButtons) Then Ms_Show;
  Ms_Set_GraphPointer(0,0,@Arrow);
  GamePlayed:=False;
  CakeSet:=False;
  SetOptions;
  Repeat;
   Ms_Read(X,Y,Z);
   If Z=$0001 Then
   Begin;
    Case X Of
    532..628: Case Y Of
              004..016: Begin
                         Ms_Hide;
                         ButtonFrame(On,520,001,639,020,'END');
                         MouseDelay;
                         ButtonFrame(On,520,001,639,020,'END');
                         ClearEndScreen;
                         LastSequence;
                         CloseGraph;
                         Halt;
                        End;
              034..046: Begin
                         Ms_Hide;
                         ButtonFrame(On,520,030,639,050,'START GAME');
                         MouseDelay;
                         PlayingScreen;
                         CakeSet:=False;
                         Game;
                         GamePlayed:=True;
                         ButtonFrame(Off,520,030,639,050,'START GAME');
                         Ms_Show;
                        End;
              054..066: Begin
                         Ms_Hide;
                         Button(On,520,050,639,070,'OPTIONS');
                         MouseDelay;
                         SetOptions;
                         Button(Off,520,050,639,070,'OPTIONS');
                         Ms_Show;
                        End;
              084..096: Begin
                         If GamePlayed Then
                         Begin;
                          Ms_Hide;
                          Button(On,520,080,639,100,'STATISTICS');
                          MouseDelay;
                          Statistics;
                          Button(Off,520,080,639,100,'STATISTICS');
                          Ms_Show;
                         End;
                        End;
              114..126: Begin
                         Ms_Hide;
                         ButtonFrame(On,520,110,639,130,'HALL OF FAME');
                         MouseDelay;
                         ViewHallOfFame;
                         ButtonFrame(Off,520,110,639,130,'HALL OF FAME');
                         Ms_Show;
                        End;
              End;
    End;
   End;
  Until False;
 End.