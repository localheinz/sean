Program Test;
Uses Graph,SeAnHelp;
Const GuyOne         = 1;
      GuyTwo         = 2;
      GuyTwoNo       = 3;
      GuyTwOff       = 4;
      Heart          = 5;
      Money          = 6;
      Slow           = 7;
      Fast           = 8;
      Life           = 9;
      Point          = 10;
      Extra          = 11;
      SeanWorm       = 12;
      Key            = 13;
      LeftPlayer     = 1;
      RightPlayer    = 2;
      Constant       = 1;
      LevelDependent = 2;
      Adjustable     = 3;

Type  String10       = String[10];
      OptionsType    = Record
                        Players     : Byte;
                        PlayerName  : Array[$01..$02] Of String10;
                        PlayerColor : Array[$01..$02] Of Integer;
                        SpeedChange : Byte;
                        SpeedValue  : Byte;
                       End;
Var   Icon           : Array[1..13] Of IconArea;
      Options        : OptionsType;
      OptionsFile    : File Of OptionsType;

Procedure PlayingScreen;
Begin
 Button(Off,000,001,520,020,'SEANWORMS VER 3.0');
 
 Button(Off,125,020,395,040,'LEVEL 1 - THE BEGINNING');
 Button(Off,125,040,395,479,'');
 ButtonFrame(On,131,46,389,302,'');
 ButtonFrame(On,131,308,389,328,'');

 Button(Off,000,020,125,479,'');
 PushIcon(062,050,Icon[GuyOne]);
 Flaeche(006,070,119,090,Options.PlayerName[LeftPlayer]);
 PushIcon(031,450,Icon[Heart]);
 ButtonFrame(On,021,100,041,430,'');
 PushIcon(062,450,Icon[Money]);
 ButtonFrame(On,052,100,072,430,'');
 PushIcon(094,450,Icon[Key]);
 ButtonFrame(On,084,100,104,430,'');
 If Options.Players=2 Then
 Begin;
  Button(Off,395,020,520,479,'');
  PushIcon(457,50,Icon[GuyTwo]);
  Flaeche(401,70,514,90,Options.PlayerName[RightPlayer]);
  PushIcon(426,450,Icon[Heart]);
  ButtonFrame(On,416,100,436,430,'');
  PushIcon(457,450,Icon[Money]);
  ButtonFrame(On,447,100,467,430,'');
  PushIcon(489,450,Icon[Key]);
  ButtonFrame(On,479,100,499,430,'');
 End;
End;


 Begin
  DetectGraph(Treiber,Modus);
  InitGraph(Treiber,Modus,'C:\Dos\Pascal\Bgi');
  If Exist('SEANWORM.OPT') And (Size('SEANWORM.OPT')=29) Then
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
   Options. SpeedChange      :=Constant;
   Options. SpeedValue       :=$05;
   Assign(OptionsFile,'SEANWORM.OPT');
   ReWrite(OptionsFile);
   Write(OptionsFile,Options);
   Close(OptionsFile);
  End;
  LoadIcon('SEANWORM',Icon[SeanWorm]);
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
  LoadIcon('KEY',Icon[Key]);
  PlayingScreen;
  ReadLn;
 End.