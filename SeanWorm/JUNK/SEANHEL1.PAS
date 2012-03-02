{$M 20000,0,655360}
Unit SeanHelp;

InterFace

 Uses Graph,Crt,Maus,Dos,Bits;

 Const On             = True;
       Off            = False;
       CapAllUp       = 1;
       CapAllDown     = 2;
       CapReg         = 3;
       StartCursor    : Integer=6;
       EndCursor      : Integer=7;
       SymbolExt      = '.'+#255+'SL';
       IconExt        = '.'+#255+'SN';
       LevelName           : String = ('SEANWORM.');
       AttrButton          = 1;
       AttrFree            = 2;
       AttrRestricted      = 3;
       WinIconExt     = '.ICO';
       CompIconExt    = '.CSN';
       MouseExt       = '.'+#255+'SM';
       ColorName      : Array[0..15] Of String=('A','A','A','A','A','A','A','A','A','A','A','A','A','A','A','A');
       WinColor       : Array[0..15] Of Byte = (0,4,2,3,1,5,6,8,7,12,10,14,9,13,11,15);
       DosColor       : Array[0..15] Of Byte = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
       ForeGround     = $FE;
       BackGround     = $FF;
       Arrow          : Array[1..2,1..16] Of Word=(($3FFF,$1FFF,$0FFF,$07FF,
                                                    $03FF,$01FF,$00FF,$007F,
                                                    $03FF,$03FF,$31FF,$F1FF,
                                                    $F8FF,$F8FF,$FFFF,$FFFF),
                                                   ($8000,$C000,$E000,$F000,
                                                    $F800,$FC00,$FE00,$FF00,
                                                    $F800,$d800,$8C00,$0C00,
                                                    $0600,$0600,$0000,$0000));
       BLASE          : Array[1..2,1..16] Of Word=(($F07F,$CF9F,$806F,$0037,
                                                    $0017,$0017,$0013,$8025,
                                                    $C005,$F063,$FFD3,$FF93,
                                                    $FF07,$FF2F,$FF9F,$FFFF),
                                                   ($0000,$0000,$3F80,$43C0,
                                                    $7420,$6F60,$42E0,$3C08,
                                                    $0F88,$0000,$0008,$0008,
                                                    $0060,$0040,$0000,$0000));
       BUSY           : Array[1..2,1..16] Of Word=(($E00F,$F7DF,$F7DF,$F41F,
                                                    $F41F,$F41F,$FA3F,$FD7F,
                                                    $FC7F,$FBBF,$F6DF,$F7DF,
                                                    $F6DF,$F45F,$F01F,$E00F),
                                                   ($0000,$0000,$0000,$03C0,
                                                    $03C0,$03C0,$0180,$0000,
                                                    $0100,$0000,$0100,$0000,
                                                    $0100,$0380,$07C0,$0000));
       DISKCOPY       : Array[1..2,1..16] Of Word=(($0000,$4022,$4022,$4022,
                                                    $4022,$4002,$4002,$4002,
                                                    $4002,$4002,$4002,$4002,
                                                    $4002,$4002,$7FFE,$0000),
                                                   ($0000,$304C,$304C,$304C,
                                                    $304C,$300C,$3FFC,$3FFC,
                                                    $3FFC,$3FFC,$3FFC,$3FF4,
                                                    $3FF4,$3FFC,$0000,$0000));

 Type ExplanationType     = String[40];
      AttributeType       = Array[1..4] Of Array[1..32] Of Byte;
      ExtString           = String[3];
      TitleString         = String[15];
      FileString          = String[12];
      LongString          = String[8];
      LevelArea           = Array[1..25] Of Array[1..25] Of Byte;
      LevelType           = Record
                             LevelValue    : Byte;
                             LevelTitle    : TitleString;
                             Area          : Array[1..25] Of Array[1..25] Of Byte;
                             RelativeSpeed : Byte;
                             AttemptCode   : Byte;  { Either SeAnBuiltLevel ($77) Or UserBuiltLevel (Randomized<>$77) }
                            End;
      IconArea        = Array[1..25] Of Array[1..25] Of Byte;
      IconType        = Record
                         Explanation : ExplanationType;
                         Pixel       : Array[1..25] Of Array[1..25] Of Byte;
                        End;
      SymbolArea      = Array[1..25] Of Array[1..16] Of Byte;
      SymbolType      = Record
                         Explanation : ExplanationType;
                         Pixel       : Array[1..25] Of Array[1..16] Of Byte;
                        End;
      WinIconArea     = Array[1..32] Of Array[1..32] Of Byte;
      WinIconType     = Record
                         Unknown     : Array[1..6] Of Byte;
                         SizeX       : Byte;
                         SizeY       : Byte;
                         Colors      : Byte;
                         UnKnown2    : Array[1..117] Of Byte;
                         Pixel       : Array[1..32] Of Array[1..16] Of Byte;  { PixelaufschlÅsselung       }
                         BkGrMask    : AttributeType;                         { Maske fÅr Icon-Hintergrund }
                        End;
      ColorType       = Array[0..15] Of Word;
      CDSType         = Record
                         Directory          : Array[1..67] Of Char;
                         Attribute          : Word;
                         DPBAdress          : Pointer;
                         StartCluster       : Word;
                         Nothing1           : Word;
                         Nothing2           : Word;
                         Index              : Word;
                         Nothing3           : Byte;
                         ZeroOrDriver       : Pointer;
                         Nothing4           : Word;
                        End;
      DOSType         = Record
                         FirstDPB             : Pointer;
                         SFTAdress            : Pointer;
                         ClockAdress          : Pointer;
                         MaxBlockSize         : Word;
                         HashTableAdress      : Pointer;
                         CDSAdress            : Pointer;
                         FCBTableAdress       : Pointer;
                         FCBSAfter            : Word;
                         Drives               : Byte;
                         LastDrive            : Byte;
                         NULDriverHead        : Array[1..9] Of Word;
                         DrivesByJOIN         : Byte;
                         Constant             : Word;
                         IFSFunctionAdress    : Pointer;
                         FirstIFSDevice       : Pointer;
                         BuffersBefore        : Word;
                         BuffersAfter         : Word;
                         UnKnown              : Byte;
                         ExtendedMem          : Word;
                        End;
      BootRecordType =  Record
                         BootJump          : Array[$00..$02] Of Byte;
                         Producer          : Array[$00..$08] Of Byte;
                         BytesPSector      : Word;
                         SectorsPCluster   : Byte;                    { Power of 2                }
                         ReservedSectors   : Word;
                         FATs              : Byte;
                         RootDirEntries    : Word;
                         TotalSectors      : Word;
                         MediaDescriptor   : Byte;
                         SectorsPFAT       : Word;
                         SectorsPTrack     : Word;
                         ReadWriteHeads    : Word;
                         HiddenSectors     : LongInt;
                         TotalBigSectors   : LongInt;                 { Valid if TotalSectors=$00 }
                         PhysicalDrive     : Byte;
                         Reserved1         : Byte;
                         ExtendedPartition : Byte;
                         SerialNumber      : Array[$00..$04] Of Byte;
                         VolumeLabeL       : Array[$00..$0B] Of Char;
                         Reserved2         : Array[$00..$08] Of Byte;
                         Rest              : Array[$00..$01C3] Of Byte;
                        End;
      ExeHeaderType   = Record
                         Byte4Dh           : Byte; { 4D-hex                                       }
                         Byte5Ah           : Byte; { 55-hex                                       }
                         BytesLastPage     : Word; { Number of Bytes on last Page                 }
                         TotalPages        : Word; { Number of Pages in EXE-File (Page=512 Bytes  }
                         RelozEntries      : Word; { Number of Entires in Relozierungs-Tabelle    }
                         HeaderSize        : Word; { Size of Header as a factor of 16             }
                         MinSizeOfPages    : Word; { Number of Pages required free upon program   }
                         MaxSizeOfPages    : Word; { Number of Pages required free upon program   }
                         SSRegister        : Word;
                         SPRegister        : Word;
                         CodeWord          : Word; { Negative Sum of all Bytes in EXE-File        }
                         IPRegister        : Word;
                         CSRegister        : Word;
                         RelOffSet         : Word; { OffSet from Relozierungs-Tabell to EXE-Begin }
                         OverLay           : Word; { Generated by MS-Link                         }
                        End;
      MCBRecord       = Record
                         Flag     : Char;
                         OwnerPSP : Word;
                         Size     : Word;
                         Reserved : Array[1..3] Of Byte;
                         OwnerID  : Array[1..8] Of Char;
                        End;
      PSPRecord       = Record
                         Int20          : Array[1..2] Of Byte;
                         MemEnd         : Word;
                         Nothing1       : Byte;
                         CPMJump        : Array[1..5] Of Byte;
                         OrgInt22       : Pointer;
                         OrgInt23       : Pointer;
                         OrgInt24       : Pointer;
                         ParentPSPSeg   : Word;
                         JFT            : Array[1..20] Of Byte;
                         EnvironmentSeg : Word;
                         LastSSSP       : Pointer;
                         JFTSize        : Word;
                         JFTAddress     : Pointer;
                         PreviousPSP    : Pointer;
                         Nothing2       : Array[1..20] Of Byte;
                         DOSJump        : Array[1..3] Of Byte;
                         Nothing3       : Array[1..2] Of Byte;
                         ExtFCBPart1    : Array[1..7] Of Byte;
                         FCBPart1       : Array[1..16] Of Byte;
                         FCBPart2       : Array[1..16] Of Byte;
                         Nothing4       : Array[1..4] Of Byte;
                         CmdLineDTA     : Array[1..128] Of Char; { Command-Line (ProgramName and Parameters)        }
                        End;
     MCBPointer = ^MCBRecord;
     PSPPointer = ^PSPRecord;
     TextOptionsType = Record
                        Capital : Byte;
                       End;
 Var Treiber,Modus : Integer;
     Timer         : Integer;
     KeyStatus     : Byte Absolute $0000:$0417;
     VideoModeS    : Byte;
     VideoMode     : Byte;
     CurrentFont   : Byte;

 Procedure ShowText(LX,LY,RX,RY : Integer;S : String);
 Procedure SeAnWinInfo(ProgramName,Version,Year : String;WinIcon : WinIconArea);
 Procedure SeAnInfo(ProgramName,Version,Year : String;Icon : IconArea);
 Procedure Button(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Procedure SpecialButton(LX,LY,RX,RY : Integer; S : String);
 Procedure Switcher(LX,LY,RX,RY : Integer;S : String);
 Procedure Flaeche(LX,LY,RX,RY : Integer;S : String);
 Procedure Frame(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Procedure DoubleFrame(Switch : Boolean;LX1,LY1,RX1,RY1,RX2 : Integer;S : String);
 Procedure Window(Switch : Boolean;LX,LY,RX,RY : Integer);
 Procedure SenkrechtScroller(Switch : Boolean;LX,LY,RX,RY : Integer);
 Procedure WaagrechtScroller(Switch : Boolean;LX,LY,RX,RY : Integer);
 Procedure EingabeZeile(Switch : Boolean;LX,LY,RX : Integer;S1,S2 : String);
 Procedure ScreenSaver(XC,YC,ZC : Word);
 Procedure ClearButton(LX,LY,RX,RY : Integer);
 Procedure ButtonFrame(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Procedure PutString(LX,RX,Y : Word;S : String);
 Procedure SetString(Switch : Boolean;X,LY,RY : Word;S : String);
 Procedure PutIcon(SetX,SetY : Word; IconName : NameStr );
 Procedure LoadLevel(LevelExt : ExtString; Var LoadedLevel : LevelArea);
 Procedure PushLevel(SetX,SetY : Word; LoadedLevel : LevelArea);
 Procedure LoadIcon(IconName : NameStr; Var LoadedIcon : IconArea);
 Procedure PushIcon(SetX,SetY : Word; LoadedIcon : IconArea);
 Procedure PushIconNoGray(SetX,SetY : Word; LoadedIcon : IconArea);
 Procedure PutWinIcon(SetX,SetY : Word; WinIconName : NameStr );
 Procedure LoadWinIcon(WinIconName : NameStr; Var LoadedWinIcon : WinIconArea);
 Procedure PushWinIcon(SetX,SetY : Word; LoadedWinIcon : WinIconArea);
 Procedure PushWinIconNoGray(SetX,SetY : Word; LoadedWinIcon : WinIconArea);
 Procedure BkGrMaskToAttributes(BkGrMask : AttributeType; Var NewAttr : WinIconArea);
 Procedure AttributesToBkGrMask(Attr : WinIconArea; Var BkGrMask : AttributeType);
 Procedure DosColorToWinColor(OrgData : WinIconArea; Var NewData : WinIconArea);
 Procedure WinColorToDosColor(OrgData : WinIconArea; Var NewData : WinIconArea);
 Procedure PutSymbol(SetX,SetY : Word; SymbolName : NameStr );
 Procedure LoadSymbol(SymbolName : NameStr; Var LoadedSymbol : SymbolArea);
 Procedure PushSymbol(SetX,SetY : Word; LoadedSymbol : SymbolArea);
 Procedure PushSymbolNoGray(SetX,SetY : Word; LoadedSymbol : SymbolArea);
 Procedure RadioButton(Switch : Boolean; LX,Y,RX : Integer; S : String);
 Procedure CheckBox(Switch,Switched : Boolean; X,Y : Integer; S : String);
 Procedure Cursor;
 Procedure CursorOff;
 Procedure CursorOn;
 Procedure MonitorOff;
 Procedure MonitorOn;
 Procedure Beep;
 Procedure GraphMode ( Driver, Mode : Integer );
 Procedure TextMode;
 Procedure Font ( Size, Direction : Integer );
 Procedure Check;
 Function Gross(S : String)                    : String;
 Function Klein(S : String)                    : String;
 Function BinToDec(Bin : Byte)                 : Word;
 Function DecToBin(Dec : Word)                 : Byte;
 Function InsertString(X,Y : Word; MaxLength : Word;Parameter : String; CurrentString : String) : String;
 Function BCD(High,Low : Byte) : Byte;
 Function HighBCDToDec(BCD : Byte)             : Byte;
 Function LowBCDToDec(BCD : Byte)              : Byte;
 Function DecToHex(Decimal : Word)             : String;
 Function RightShift                           : Boolean;
 Function LeftShift                            : Boolean;
 Function Ctrl                                 : Boolean;
 Function Alt                                  : Boolean;
 Function ScrollLock                           : Boolean;
 Function NumLock                              : Boolean;
 Function CapsLock                             : Boolean;
 Function Ins                                  : Boolean;
 Function ShiftPressed                         : Boolean;
 Function SpecKeyPressed                       : Boolean;
 Function Exist(FileName : String)             : Boolean;
 Function DirExist(Dir : String)               : Boolean;
 Function Size(FileName : String)              : LongInt;
 Function Dif(X,Y : Integer)                   : Integer;
 Function MakeLongInt(W : Word)                : LongInt;
 Function ProgramChanged(ExeName : FileString) : Boolean;
 Function OrgExeSize(ExeName : FileString)     : LongInt;
 Function CurrentProgram                       : String;
 Function CurrentCMDLine                       : String;
 Function SeAnProgramChanged(ExeName : FileString) : Boolean;



Implementation

 Function Gross(S : String) : String;
 Var Z : Integer;
 Begin
  For Z:=1 To Length(S) Do
  Begin;
   Case S[Z] Of
    'a'..'z': S[Z]:=UpCase(S[Z]);
         'Ñ': S[Z]:='é';
         'Å': S[Z]:='ö';
         'î': S[Z]:='ô';
   End;
  End;
  Gross:=S;
 End;

 Function Klein(S : String) : String;
 Var Z : Integer;
 Begin
  For Z:=1 To Length(S) Do
  Begin;
   Case S[Z] Of
    'A'..'Z': S[Z]:=Chr(Ord(S[Z])+32);
         'é': S[Z]:='Ñ';
         'ö': S[Z]:='Å';
         'ô': S[Z]:='î';
   End;
  End;
  Klein:=S;
 End;

 Procedure Button(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Var Color : Word;
         Y : Integer;
 Begin
  SetTextStyle(2,0,5);
  S:=Gross(S);
  Color:=GetColor;
  SetColor(Lightgray);
  For Y:=LY+3 To RY-3 Do Line(LX+3,Y,RX-3,Y);
  SetColor(Black);
  Rectangle(LX,LY,RX,RY);
  If Switch Then SetColor(White) Else
  If Not Switch Then SetColor(DarkGray);
  Line(LX+1,RY-1,RX-1,RY-1);
  Line(LX+2,RY-2,RX-2,RY-2);
  Line(RX-1,LY+1,RX-1,RY-1);
  Line(RX-2,LY+2,RX-2,RY-2);
  If Switch Then SetColor(DarkGray) Else
  If Not Switch Then SetColor(White);
  Line(LX+2,LY+2,LX+2,RY-2);
{  Line(LX+1,LY+1,LX+1,RY-1);}
  Line(LX+2,LY+2,RX-2,LY+2);
{  Line(LX+1,LY+1,RX-1,LY+1);}
  {If Switch Then SetColor(DarkGray) Else
  If Not Switch Then SetColor(White);}
  SetColor(Black);
  OutTextXY(Round((RX-LX)/2)-Round(TextWidth(S)/2)+LX+2,Round((RY-LY)/2)-Round(TextHeight(S)/2)+LY-2,S);
  SetColor(Color);
 End;


 Procedure SpecialButton(LX,LY,RX,RY : Integer;S : String);
 Var Color : Word;
       X,Y : Integer;
       M,Z : Real;
 Begin
  SetTextStyle(2,0,5);
  S:=Gross(S);
  Color:=GetColor;
  SetColor(Lightgray);
  X:=RX-LX;
  Y:=RY-LY;
  M:=Y/X;
  X:=Round((RX-LX)/2);
  Z:=X;
  Repeat;
   RectAngle(Round(LX+Z),Round(M*Z+LY),Round(RX-Z),Round(RY-M*Z));
   Z:=Z-1;
  Until Z=0;
  Line(LX,LY,RX,LY);
  SetColor(Black);
  Rectangle(LX,LY,RX,RY);
  SetColor(DarkGray);
  Line(LX+1,RY-1,RX-1,RY-1);
  Line(LX+2,RY-2,RX-2,RY-2);
  Line(RX-1,LY+1,RX-1,RY-1);
  Line(RX-2,LY+2,RX-2,RY-2);
  SetColor(White);
  Line(LX+2,LY+2,LX+2,RY-2);
{  Line(LX+1,LY+1,LX+1,RY-1);}
  Line(LX+2,LY+2,RX-2,LY+2);
{  Line(LX+1,LY+1,RX-1,LY+1);}
  SetColor(Black);
  OutTextXY(Round((RX-LX)/2)-Round(TextWidth(S)/2)+LX+2,Round((RY-LY)/2)-Round(TextHeight(S)/2)+LY-2,S);
  SetColor(Color);
 End;

 Procedure ButtonFrame(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Var Color : Word;
         Y : Integer;
 Begin
  S:=Gross(S);
  SetColor(Black);
  Rectangle(LX,LY,RX,RY);
  If Switch Then SetColor(White) Else
  If Not Switch Then SetColor(DarkGray);
  Line(LX+1,RY-1,RX-1,RY-1);
  Line(LX+2,RY-2,RX-2,RY-2);
  Line(RX-1,LY+1,RX-1,RY-1);
  Line(RX-2,LY+2,RX-2,RY-2);
  If Switch Then SetColor(DarkGray) Else
  If Not Switch Then SetColor(White);
  Line(LX+2,LY+2,LX+2,RY-2);
{  Line(LX+1,LY+1,LX+1,RY-1);}
  Line(LX+2,LY+2,RX-2,LY+2);
{  Line(LX+1,LY+1,RX-1,LY+1);}
  SetColor(Black);
  OutTextXY(Round((RX-LX)/2)-Round(TextWidth(S)/2)+LX+2,Round((RY-LY)/2)-Round(TextHeight(S)/2)+LY-2,S);
 End;


 Procedure Flaeche(LX,LY,RX,RY : Integer;S : String);
 Var Y : Integer;
 Begin
  S:=Gross(S);
  SetColor(Lightgray);
  For Y:=LY To RY Do Line(LX,Y,RX,Y);
  SetColor(Black);
  OutTextXY(Round((RX-LX)/2)-Round(TextWidth(S)/2)+LX+2,Round((RY-LY)/2)-Round(TextHeight(S)/2)+LY-2,S);
 End;

 Procedure Switcher(LX,LY,RX,RY : Integer;S : String);
 Begin
  S:=Gross(S);
  ButtonFrame(On,LX,LY,RX,RY,'');
  ButtonFrame(Off,LX+6,LY+6,RX-6,RY-6,S);
 End;


 Procedure Frame(Switch : Boolean;LX,LY,RX,RY : Integer;S : String);
 Begin
  S:=Gross(S);
  Button(Switch,LX,LY,RX,RY,'');
  Flaeche(LX+4,LY+4,RX-4,LY+18,S);
  ButtonFrame(Not Switch,LX+6,LY+21,RX-6,RY-6,'');
 End;

 Procedure DoubleFrame(Switch : Boolean;LX1,LY1,RX1,RY1,RX2 : Integer;S : String);
 Begin;
  S:=Gross(S);
  Button(Switch,LX1,LY1,RX2,RY1,'');
  Flaeche(LX1,LY1,RX1,LY1+21,S);
  ButtonFrame(Not Switch,LX1+6,LY1+20,RX1-2,RY1-6,'');
  ButtonFrame(Not Switch,RX1+2,LY1+20,RX2-6,RY1-6,'');
 End;


 Procedure Window(Switch : Boolean;LX,LY,RX,RY : Integer);
 Begin
  Button(Switch,LX,LY,RX,RY,'');
  ButtonFrame(Not Switch,LX+6,LY+6,RX-6,RY-6,'');
 End;

 Procedure SenkrechtScroller(Switch : Boolean;LX,LY,RX,RY : Integer);
 Begin
  Button(Switch,LX,LY,RX,RY,'');
  ButtonFrame(Not Switch,LX+6,LY+(RX-LX),RX-6,RY-(RX-LX),'');
 End;

 Procedure WaagrechtScroller(Switch : Boolean;LX,LY,RX,RY : Integer);
 Begin
  Button(Switch,LX,LY,RX,RY,'');
  ButtonFrame(Not Switch,LX+(RY-LY),LY+6,RX-(RY-LY),RY-6,'');
 End;

 Procedure EingabeZeile(Switch : Boolean;LX,LY,RX : Integer;S1,S2 : String);
 Begin
  S1:=Gross(S1);
  S2:=Gross(S2);
  Button(Off,LX,LY,RX,LY+56,'');
  If TextWidth(S2)>TextWidth(S1) Then
  Begin;
   Button(On,LX+12+TextWidth(S2),LY+6,RX-6,LY+26,'');
   Button(On,LX+12+TextWidth(S2),LY+30,RX-6,LY+50,'');
  End Else
  If TextWidth(S2)<TextWidth(S1) Then
  Begin;
   Button(On,LX+12+TextWidth(S1),LY+6,RX-6,LY+26,'');
   Button(On,LX+12+TextWidth(S1),LY+30,RX-6,LY+50,'');
  End;
  MoveTo(LX+9,LY+9);
  OutText(S1);
  MoveTo(LX+9,LY+33);
  OutText(S2);
 End;


 Procedure ScreenSaver(XC,YC,ZC : Word);
 Type PixelType=Array[1..2] Of Word;
 Var Pixel : Array[1..50] Of PixelType;
     Color : Word;
         W : Word;
     X,Y,Z : Word;
 Begin
  Ms_Hide;
  ClearDevice;
  Randomize;
  For W:=1 To 50 Do
  Begin;
   Color:=Random(1)+1;
   Case Color Of
    1: Color:=White;
    2: Color:=LightGray;
   End;
   Pixel[W][1]:=Random(640);
   Pixel[W][2]:=Random(480);
   PutPixel(Pixel[W][1],Pixel[W][2],Color);
  End;
  Repeat;
   Color:=Random(1)+1;
   Case Color Of
    1: Color:=White;
    2: Color:=LightGray;
   End;
   Delay(Random(100)+100);
   W:=Random(49)+1;
   PutPixel(Pixel[W][1],Pixel[W][2],Black);
   Pixel[W][1]:=Random(640);
   Pixel[W][2]:=Random(480);
   PutPixel(Pixel[W][1],Pixel[W][2],Color);
   Ms_Read(X,Y,Z);
  Until (X<>XC) Or (Y<>YC) Or (Z<>ZC) Or KeyPressed;
  ClearDevice;
  Ms_Show;
  Timer:=0;
 End;


 Procedure ClearButton(LX,LY,RX,RY : Integer);
 Var M     : Real;
     X,Y,Z : Integer;
 Begin
  X:=Dif(RX,LX);
  Y:=Dif(RY,LY);
  If X>Y Then
  Begin;
   M:=Y/X;
   X:=Round((RX-LX)/2);
   SetColor(GetBKColor);
   For Z:=0 To X Do
   Begin;
    SetColor(GetBKColor);
    RectAngle(LX+Z,Round(M*Z+LY),RX-Z,Round(RY-M*Z));
    End;
  End Else
  If X<=Y Then
  Begin;
   M:=X/Y;
   Y:=Round((RY-LY)/2);
   SetColor(GetBKColor);
   For Z:=0 To Y Do
   Begin;
    SetColor(GetBKColor);
    RectAngle(Round(M*Z+LX),LY+Z,Round(RX-M*Z),RY-Z);
   End;
  End;
  PutPixel(Round(LX+(RX-LX)/2),Round(LY+(RY-LY)/2),GetBkColor);
 End;

 Function BinToDec(Bin : Byte) : Word;
 Var Dummy : Word;
         I : Integer;
 Begin
  Dummy:=0;
  For I:=0 To 7 Do
  Begin;
   If GetBit(Bin,I) Then
   Begin;
    Case I Of
           0: Dummy:=Dummy+1;
           1: Dummy:=Dummy+2;
           2: Dummy:=Dummy+4;
           3: Dummy:=Dummy+8;
           4: Dummy:=Dummy+16;
           5: Dummy:=Dummy+32;
           6: Dummy:=Dummy+64;
           7: Dummy:=Dummy+128;
    End;
   End;
  End;
  BinToDec:=Dummy;
 End;

 Function DecToBin(Dec : Word) : Byte;
 Var B     : Byte;
     Dummy : Byte;
 Begin
  For B:=0 To 7 Do ClearBit(Dummy,B);
  For B:=0 To 7 Do
  Begin;
   If (Dec-2*(Dec Div 2))=1 Then SetBit(Dummy,B) Else
   If (Dec-2*(Dec Div 2))=0 Then ClearBit(Dummy,B);
   Dec:=Dec Div 2;
  End;
  DecToBin:=Dummy;
 End;

 Procedure Cursor;
 Var Count : Integer;
     X,Y   : Integer;
 Begin
  X:=GetX;
 Y:=GetY;
 While Not KeyPressed Do
 Begin;
  Count:=0;
  MoveTo(X,Y);
  SetColor(Black);
  OutText('|');
  While (Not KeyPressed) And (Count<>500) Do
  Begin;
   Delay(1);
   Inc(Count);
  End;
  Count:=0;
  MoveTo(X,Y);
  SetColor(LightGray);
  OutText('|');
  While (Not KeyPressed) And (Count<>500) Do
  Begin;
   Delay(1);
   Inc(Count);
  End;
 End;
 MoveTo(X,Y);
 SetColor(LightGray);
 OutText('|');
 MoveTo(X,Y);
End;

Function InsertString(X,Y : Word; MaxLength : Word;Parameter : String; CurrentString : String) : String;
Var InsertStringDummy : String;
    Key               : Char;
    MomLength         : Integer;
    Z                 : Integer;
    XD,YD             : Integer;

Begin
 MoveTo(X,Y);
 SetColor(Black);
 For Z:=1 To Length(CurrentString) Do OutText(CurrentString[Z]);
 InsertStringDummy:=CurrentString;
 MomLength:=Length(InsertStringDummy);
 Repeat;
  Cursor;
  If KeyPressed Then Key:=ReadKey;
  Case Key Of
    'a'..'z': Key:=UpCase(Key);
         'Ñ': Key:='é';
         'Å': Key:='ö';
         'î': Key:='ô';
  End;
  If Parameter='File' Then
  Begin;
   If Key In ['A'..'Z','é','ô','ö','0'..'9'] Then
   Begin;
    If MomLength<MaxLength Then
    Begin;
     SetColor(Black);
     OutText(Key);
     InsertStringDummy:=InsertStringDummy+Key;
     Inc(MomLength);
    End Else Beep;
   End Else
   If (Key=#8) And (MomLength>0) Then
   Begin;
    SetColor(Black);
    MoveTo(X,Y);
    For Z:=1 To Length(InsertStringDummy)-1 Do OutText(InsertStringDummy[Z]);
    XD:=GetX;
    YD:=GetY;
    SetColor(LightGray);
    OutText(InsertStringDummy[MomLength]);
    Dec(MomLength);
    InsertStringDummy:=Copy(InsertStringDummy,1,MomLength);
    MoveTo(XD,YD);
   End Else
   If (Key<>#13) Or (MomLength<1) Then
   Begin;
    Beep;
    Key:=#0;
   End;
  End Else
  If Parameter='Text' Then
  Begin;
   If Key In ['é','ô','ö','!'..'Z',' ','\'] Then
   Begin;
    If MomLength<MaxLength Then
    Begin;
     SetColor(Black);
     OutText(Key);
     InsertStringDummy:=InsertStringDummy+Key;
     Inc(MomLength);
    End Else Beep;
   End Else
   If (Key=#8) And (MomLength>0) Then
   Begin;
    SetColor(Black);
    MoveTo(X,Y);
    For Z:=1 To Length(InsertStringDummy)-1 Do OutText(InsertStringDummy[Z]);
    XD:=GetX;
    YD:=GetY;
    SetColor(LightGray);
    OutText(InsertStringDummy[MomLength]);
    Dec(MomLength);
    InsertStringDummy:=Copy(InsertStringDummy,1,MomLength);
    MoveTo(XD,YD);
   End Else If Key<>#13 Then Beep;
  End;
 Until Key=#13;
 InsertString:=InsertStringDummy;
End;

Procedure Beep;
Begin
 Sound(60);
 Delay(100);
 Sound(30);
 Delay(100);
 NoSound;
End;

Procedure PutString(LX,RX,Y : Word;S : String);
Begin
 S:=Gross(S);
 SetColor(Black);
 OutTextXY(Round((RX-LX)/2)-Round(TextWidth(S)/2)+2+LX,Y-Round(TextHeight(S)/2),S);
End;

Procedure SetString(Switch : Boolean;X,LY,RY : Word;S : String);
Begin
 S:=Gross(S);
 If Switch Then SetColor(DarkGray) Else
 If Not Switch Then SetColor(White);
 OutTextXY(X,Round((RY-LY)/2)-Round(TextHeight(S)/2)+LY-2,S);
End;



Procedure PutIcon(SetX,SetY : Word; IconName : NameStr );
Var Icon     : IconArea;
    X,Y      : Word;
Begin
 LoadIcon(IconName,Icon);
 PushIcon(SetX,SetY,Icon);
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


Procedure PutLevel(SetX,SetY : Word; LevelExt : ExtString );
Var Level     : LevelArea;
    X,Y      : Word;
Begin
 LoadLevel(LevelName+LevelExt,Level);
 PushLevel(SetX,SetY,Level);
End;

Procedure LoadLevel(LevelExt : ExtString; Var LoadedLevel : LevelArea);
Var LevelFile : File Of LevelType;
    Level     : LevelType;
    X,Y       : Integer;
Begin
 Assign(LevelFile,LevelName+LevelExt);
 Reset(LevelFile);
 Read(LevelFile,Level);
 Close(LevelFile);
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do LoadedLevel[X][Y]:=Level.Area[X][Y];
 End;
End;

Procedure PushLevel(SetX,SetY : Word; LoadedLevel : LevelArea);
Var X,Y : Word;
Begin
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do
  Begin;
   Case LoadedLevel[X][Y] Of
    AttrFree      : PutPixel(X+SetX-12,Y+SetY-12,LightGray);
    AttrRestricted: PutPixel(X+SetX-12,Y+SetY-12,Red);
    AttrButton    : PutPixel(X+SetX-12,Y+SetY-12,DarkGray);
   End;
  End;
 End;
End;


Procedure PutWinIcon(SetX,SetY : Word; WinIconName : NameStr );
Var WinIcon : WinIconArea;
    X,Y     : Word;
Begin
 LoadWinIcon(WinIconName,WinIcon);
 PushWinIcon(SetX,SetY,WinIcon);
End;



Procedure LoadWinIcon(WinIconName : NameStr; Var LoadedWinIcon : WinIconArea);
Var WinIconFile  : File Of WinIconType;
    WinIconDummy : WinIconType;
    X,Y          : Integer;
    Attributes   : WinIconArea;

Begin
 Assign(WinIconFile,WinIconName+WinIconExt);
 Reset(WinIconFile);
 Read(WinIconFile,WinIconDummy);
 Close(WinIconFile);
 For Y:=1 To 32 Do
 Begin;
  For X:=1 To 16 Do
  Begin;
   LoadedWinIcon[2*X][33-Y]:=WinColor[LowBCDToDec(WinIconDummy.Pixel[Y][X])];
   LoadedWinIcon[2*X-1][33-Y]:=WinColor[HighBCDToDec(WinIconDummy.Pixel[Y][X])];
  End;
 End;
 BkGrMaskToAttributes(WinIconDummy.BkGrMask,Attributes);
 For X:=1 To 32 Do
 Begin;
  For Y:=1 To 32 Do
  Begin;
   If Attributes[X][Y]=BackGround Then LoadedWinIcon[X][Y]:=LightGray;
  End;
 End;
End;

Procedure PushWinIcon(SetX,SetY : Word; LoadedWinIcon : WinIconArea);
Var X,Y : Word;
 Begin
  For X:=1 To 32 Do
  Begin;
   For Y:=1 To 32 Do
   Begin;
    PutPixel(X+SetX-16,Y+SetY-16,LoadedWinIcon[X][Y]);
   End;
  End;
 End;


Procedure PushWinIconNoGray(SetX,SetY : Word; LoadedWinIcon : WinIconArea);
Var X,Y : Word;
 Begin
  For X:=1 To 32 Do
  Begin;
   For Y:=1 To 32 Do
   Begin;
    If LoadedWinIcon[X][Y]<>LightGray Then PutPixel(X+SetX-12,Y+SetY-12,LoadedWinIcon[X][Y]);
   End;
  End;
 End;

Procedure BkGrMaskToAttributes(BkGrMask : AttributeType; Var NewAttr : WinIconArea);
Var X,Y,Z,A,B : Integer;
Begin
 A:=1;
 B:=1;
 For Z:=1 To 4 Do
 Begin;
  For X:=1 To 32 Do
  Begin;
   For Y:=7 DownTo 0 Do
   Begin;
    If GetBit(BkGrMask[Z][X],Y) Then NewAttr[A][33-B]:=BackGround Else NewAttr[A][33-B]:=ForeGround;
    Inc(A);
   End;
   If (X/4)=Round(X/4) Then
   Begin;
    Inc(B);
    A:=1;
   End;
  End;
 End;
End;

Procedure AttributesToBkGrMask(Attr : WinIconArea; Var BkGrMask : AttributeType);
Var X,Y,Z,A,B : Integer;
Begin
 A:=1;
 B:=1;
 For Z:=1 To 4 Do
 Begin;
  For X:=1 To 32 Do
  Begin;
   For Y:=7 DownTo 0 Do
   Begin;
    If Attr[A][33-B]=ForeGround Then ClearBit(BkGrMask[Z][X],Y) Else
    If Attr[A][33-B]=BackGround Then SetBit(BkGrMask[Z][X],Y);
    Inc(A);
   End;
   If (X/4)=Round(X/4) Then
   Begin;
    Inc(B);
    A:=1;
   End;
  End;
 End;
End;

Procedure DosColorToWinColor(OrgData : WinIconArea; Var NewData : WinIconArea);
Var X,Y : Integer;
Begin
 For X:=1 To 32 Do
 Begin;
  For Y:=1 To 32 Do
  Begin;
   Case OrgData[X][Y] Of
    00: NewData[X][Y]:=0;
    04: NewData[X][Y]:=1;
    02: NewData[X][Y]:=2;
    03: NewData[X][Y]:=3;
    01: NewData[X][Y]:=4;
    05: NewData[X][Y]:=5;
    06: NewData[X][Y]:=6;
    08: NewData[X][Y]:=7;
    07: NewData[X][Y]:=8;
    12: NewData[X][Y]:=9;
    10: NewData[X][Y]:=10;
    14: NewData[X][Y]:=11;
    09: NewData[X][Y]:=12;
    13: NewData[X][Y]:=13;
    11: NewData[X][Y]:=14;
    15: NewData[X][Y]:=15;
   End;
  End;
 End;
End;

Procedure WinColorToDosColor(OrgData : WinIconArea; Var NewData : WinIconArea);
Var X,Y : Integer;
Begin
 For X:=1 To 32 Do
 Begin;
  For Y:=1 To 32 Do
  Begin;
   Case OrgData[X][Y] Of
    00: NewData[X][Y]:=0;
    01: NewData[X][Y]:=4;
    02: NewData[X][Y]:=2;
    03: NewData[X][Y]:=3;
    04: NewData[X][Y]:=1;
    05: NewData[X][Y]:=5;
    06: NewData[X][Y]:=6;
    07: NewData[X][Y]:=8;
    08: NewData[X][Y]:=7;
    09: NewData[X][Y]:=12;
    10: NewData[X][Y]:=10;
    11: NewData[X][Y]:=14;
    12: NewData[X][Y]:=09;
    13: NewData[X][Y]:=13;
    14: NewData[X][Y]:=11;
    15: NewData[X][Y]:=15;
   End;
  End;
 End;
End;


Procedure PutSymbol(SetX,SetY : Word; SymbolName : NameStr );
Var SymbolFile : File Of SymbolType;
    Symbol     : SymbolType;
    X,Y        : Word;
Begin
 Assign(SymbolFile,SymbolName+SymbolExt);
 Reset(SymbolFile);
 Read(SymbolFile,Symbol);
 Close(SymbolFile);
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 16 Do
  Begin;
   PutPixel(X+SetX-12,Y+SetY-8,BinToDec(Symbol.Pixel[X][Y]));
  End;
 End;
End;


Procedure LoadSymbol(SymbolName : NameStr; Var LoadedSymbol : SymbolArea);
Var SymbolFile  : File Of SymbolType;
    SymbolDummy : SymbolType;
    X,Y         : Integer;
Begin
 Assign(SymbolFile,SymbolName+SymbolExt);
 Reset(SymbolFile);
 Read(SymbolFile,SymbolDummy);
 Close(SymbolFile);
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 16 Do LoadedSymbol[X][Y]:=BinToDec(SymbolDummy.Pixel[X][Y]);
 End;
End;

Procedure PushSymbol(SetX,SetY : Word; LoadedSymbol : SymbolArea);
Var X,Y : Word;
 Begin
  For X:=1 To 25 Do
  Begin;
   For Y:=1 To 16 Do PutPixel(X+SetX-12,Y+SetY-8,LoadedSymbol[X][Y]);
  End;
 End;

Procedure PushSymbolNoGray(SetX,SetY : Word; LoadedSymbol : SymbolArea);
Var X,Y : Word;
 Begin
  For X:=1 To 25 Do
  Begin;
   For Y:=1 To 16 Do
   Begin;
    If LoadedSymbol[X][Y]<>LightGray Then PutPixel(X+SetX-12,Y+SetY-8,LoadedSymbol[X][Y]);
   End;
  End;
 End;

Function BCD(High,Low : Byte) : Byte;
Var B : Byte;
    W : Word;
Begin
 For W:=0 To 3 Do
 Begin;
  If GetBit(Low,W) Then SetBit(B,W) Else ClearBit(B,W);
  If GetBit(High,W) Then SetBit(B,W+4) Else ClearBit(B,W+4);
 End;
 BCD:=B;
End;


Function HighBCDToDec(BCD : Byte) : Byte;
Var I : Integer;
    B : Byte;
Begin
 B:=0;
 For I:=4 To 7 Do
 Begin;
  If GetBit(BCD,I) Then SetBit(B,I-4) Else ClearBit(B,I-4);
 End;
 HighBCDToDec:=B;
End;


Function LowBCDToDec(BCD : Byte) : Byte;
Var I : Integer;
    B : Byte;
Begin
 B:=0;
 For I:=0 To 3 Do
 Begin;
  If GetBit(BCD,I) Then SetBit(B,I) Else ClearBit(B,I);
 End;
 LowBCDToDec:=B;
End;

Function DecToHex(Decimal : Word) : String;
Const HexaNumbers : String='0123456789ABCDEF';
Var   HexaDecimal : String[4];
Begin
 HexaDecimal:='0000';
 Repeat;
  If Decimal>=4096 Then
  Begin;
   HexaDecimal[1]:=HexaNumbers[(Decimal Div 4096)+1];
   Decimal:=Decimal-(Decimal Div 4096)*4096;
  End;
  If Decimal>=256 Then
  Begin;
   HexaDecimal[2]:=HexaNumbers[(Decimal Div 256)+1];
   Decimal:=Decimal-(Decimal Div 256)*256;
  End;
  If Decimal>=16 Then
  Begin;
   HexaDecimal[3]:=HexaNumbers[(Decimal Div 16)+1];
   Decimal:=Decimal-(Decimal Div 16)*16;
  End;
  If Decimal<16 Then
  Begin;
   HexaDecimal[4]:=HexaNumbers[Decimal+1];
   Decimal:=0;
  End;
 Until Decimal=0;
 DecToHex:=HexaDecimal;
End;

Procedure CursorOff;
Var R : Registers;
Begin
 R.Ah:=$01;
 R.Al:=$00;
 R.Ch:=50;
 R.Cl:=50;
 Intr($10,R);
End;

Procedure CursorOn;
Var R : Registers;
Begin
 R.Ah:=$01;
 R.Al:=$00;
 R.Ch:=StartCursor;
 R.Cl:=EndCursor;
 Intr($10,R);
End;

Procedure MonitorOff;
Var R : Registers;
Begin
 R.Ah:=$12;
 R.Bl:=$36;
 R.Al:=$01;
 Intr($10,R);
End;

Procedure MonitorOn;
Var R : Registers;
Begin
 R.Ah:=$12;
 R.Bl:=$36;
 R.Al:=$00;
 Intr($10,R);
End;

Function RightShift : Boolean;
Begin
 RightShift:=GetBit(KeyStatus,$00);
End;

Function LeftShift : Boolean;
Begin
 LeftShift:=GetBit(KeyStatus,$01);
End;

Function Ctrl : Boolean;
Begin
 Ctrl:=GetBit(KeyStatus,$02);
End;

Function Alt : Boolean;
Begin
 Alt:=GetBit(KeyStatus,$03);
End;

Function ScrollLock : Boolean;
Begin
 ScrollLock:=GetBit(KeyStatus,$04);
End;

Function NumLock : Boolean;
Begin
 NumLock:=GetBit(KeyStatus,$05);
End;

Function CapsLock : Boolean;
Begin
 CapsLock:=GetBit(KeyStatus,$06);
End;

Function Ins : Boolean;
Begin
 Ins:=GetBit(KeyStatus,$07);
End;

Function ShiftPressed : Boolean;
Begin
 ShiftPressed:=LeftShift Or RightShift;
End;

Function SpecKeyPressed : Boolean;
Begin
 SpecKeyPressed:=RightShift Or LeftShift Or Ctrl Or Alt;
End;

Function Exist(FileName : String) : Boolean;
Var F : File;
Begin
 {$I-}
 Assign(F,FileName);
 Reset(F);
 Close(F);
 {$I+}
 Exist:=(IOResult=0);
End;

Function DirExist(Dir : String) : Boolean;
Var S : SearchRec;
Begin
 FindFirst(Dir,Directory,S);
 DirExist:=DosError=0;
End;


 Procedure EgaVgaGraphics;
 External;
 {$L EGAVGA.OBJ}

 Procedure LittFont;
 External;
 {$L LITT.OBJ}

 Procedure NoGraphDriver;
 Begin
  WriteLn('Sorry, driver not available...');
  Halt;
 End;

 Procedure GraphMode ( Driver, Mode : Integer );
 Begin
  If RegisterBGIDriver(@EgaVgaGraphics)<0 Then NoGraphDriver;
  VideoModeS:=VideoMode;
  InitGraph(Driver,Mode,'');
  If GraphResult<>GrOk Then Halt;
  If VideoMode=7 Then VideoMode:=6;   { To avoid errors under Hercules-Graphics when using a mouse }
 End;

 Procedure TextMode;
 Begin
  VideoMode:=VideoModeS;
  CloseGraph;
 End;

 Procedure Font ( Size, Direction : Integer);
 Begin
  CurrentFont:=RegisterBGIFont(@LittFont);
  SetTextStyle(2,Direction,Size);
 End;

 Procedure SeAnWinInfo(ProgramName,Version,Year : String;WinIcon : WinIconArea);
 Begin
  Button(Off,210,150,430,320,'');
  PutString(210,430,175,ProgramName+' VER '+Version);
  PushWinIcon(320,220,WinIcon);
  PutString(210,430,265,'BY SEAN');
  PutString(210,430,295,'(C) '+Year+' SEAN COMPANY');
  Delay(5000);
  ClearButton(210,150,430,320);
 End;

 Procedure SeAnInfo(ProgramName,Version,Year : String;Icon : IconArea);
 Begin
  Button(Off,210,150,430,320,'');
  PutString(210,430,175,ProgramName+' VER '+Version);
  PushIcon(320,220,Icon);
  PutString(210,430,265,'BY ASM (94) S4E');
  PutString(210,430,295,Year+' SEAN SOFT');
  Delay(5000);
  ClearButton(210,150,430,320);
 End;

Procedure RadioButton(Switch : Boolean; LX,Y,RX : Integer; S : String);
Begin
 If Switch=True Then SetColor(DarkGray) Else
 If Switch=False Then SetColor(White);
 Line(LX-6,Y,LX,Y-6);
 Line(LX-6,Y,LX,Y+6);
 If Switch=False Then SetColor(DarkGray) Else
 If Switch=True Then SetColor(White);
 Line(LX+6,Y,LX,Y-6);
 Line(LX+6,Y,LX,Y+6);
 If Switch=False Then SetColor(LightGray) Else
 If Switch=True Then SetColor(Black);
 Line(LX-3,Y,LX,Y-3);
 Line(LX-3,Y,LX,Y+3);
 Line(LX+3,Y,LX,Y-3);
 Line(LX+3,Y,LX,Y+3);
 SetFillStyle(SolidFill,GetColor);
 FloodFill(LX,Y,GetColor);
 SetColor(Black);
 S:=Gross(S);
 ShowText(LX+10,Y-8,RX,Y-8,S);
{ OutTextXY(X+10,6-Round(TextHeight(S)/2)+Y-8,S);}
End;

Procedure CheckBox(Switch,Switched : Boolean; X,Y : Integer; S : String);
Var A,B  : Integer;
    Icon : IconArea;
Begin
 If Switched=True Then SetColor(DarkGray) Else
 If Switched=False Then SetColor(White);
 Line(X-5,Y-5,X+5,Y-5);
 Line(X-5,Y-5,X-5,Y+5);
 If Switched=False Then SetColor(DarkGray) Else
 If Switched=True Then SetColor(White);
 Line(X+5,Y-5,X+5,Y+5);
 Line(X-5,Y+5,X+5,Y+5);
 If Switch=False Then
 Begin;
  SetColor(LightGray);
  For A:=Y-4 To Y+4 Do Line(X-4,A,X+4,A);
  SetColor(LightRed);
  Line(X-3,Y-3,X+3,Y+3);
  SetColor(Red);
  Line(X+3,Y-3,X-3,Y+3);
  Line(X-2,Y-3,X+4,Y+3);
  SetColor(LightRed);
  Line(X+2,Y-3,X-3,Y+2);
 End Else
 Begin;
  SetColor(LightGray);
  For A:=Y-4 To Y+4 Do Line(X-4,A,X+4,A);
  SetColor(LightGreen);
  Line(X-3,Y,X-1,Y+3);
  SetColor(Green);
  Line(X-2,Y,X,Y+3);
  SetColor(LightGreen);
  Line(X,Y+3,X+2,Y-3);
  SetColor(Green);
  Line(X+1,Y+3,X+3,Y-3);
 End;
 SetColor(Black);
 S:=Gross(S);
 OutTextXY(X+10,Y-8,S);
End;


 Function Size ( FileName : String ) : LongInt;
 Var S : SearchRec;
 Begin
  If Exist(FileName) Then
  Begin;
   FindFirst(FileName,Archive,S);
   If DosError=$00 Then Size:=S.Size Else Size:=$00;
  End Else Size:=$00;
 End;

 Function Dif(X,Y : Integer) : Integer;
 Begin
  Dif:=Abs(X-Y);
 End;

 Function MakeLongInt(W : Word) : LongInt;
 Var B : Byte;
     L : LongInt;
 Begin
  L:=$00;
  For B:=$00 To $15 Do
  Begin;
   If GetWBit(W,B) Then SetLBit(L,B);
  End;
  MakeLongInt:=L;
 End;

 Function OrgExeSize(ExeName : FileString) : LongInt;
 Var CalcSize  : LongInt;
     ExeFile   : File Of ExeHeaderType;
     ExeHeader : ExeHeaderType;
     X,Y       : LongInt;
 Begin
  Assign(ExeFile,ExeName);
  ReSet(ExeFile);
  Read(ExeFile,ExeHeader);
  Close(ExeFile);
  X:=MakeLongInt(ExeHeader.TotalPages);
  Y:=MakeLongInt(ExeHeader.BytesLastPage);
  CalcSize:=(512*(X-1)+Y);
  OrgExeSize:=CalcSize;
 End;


Function Hex(Decimal : LongInt) : String;
Const HexaNumbers : String='0123456789ABCDEF';
Var   HexaDecimal : String[8];
Begin
 HexaDecimal:='00000000';
 Decimal:=Abs(Decimal);
 Repeat;
  If Decimal>=268435456 Then
  Begin;
   HexaDecimal[1]:=HexaNumbers[(Decimal Div 268435456)+1];
   Decimal:=Decimal-(Decimal Div 268435456)*268435456;
  End;
  If Decimal>=16777216 Then
  Begin;
   HexaDecimal[2]:=HexaNumbers[(Decimal Div 16777216)+1];
   Decimal:=Decimal-(Decimal Div 16777216)*16777216;
  End;
  If Decimal>=1048576 Then
  Begin;
   HexaDecimal[3]:=HexaNumbers[(Decimal Div 1048576)+1];
   Decimal:=Decimal-(Decimal Div 1048576)*1048576;
  End;
  If Decimal>=65536 Then
  Begin;
   HexaDecimal[4]:=HexaNumbers[(Decimal Div 65536)+1];
   Decimal:=Decimal-(Decimal Div 65536)*65536;
  End;
  If Decimal>=4096 Then
  Begin;
   HexaDecimal[5]:=HexaNumbers[(Decimal Div 4096)+1];
   Decimal:=Decimal-(Decimal Div 4096)*4096;
  End;
  If Decimal>=256 Then
  Begin;
   HexaDecimal[6]:=HexaNumbers[(Decimal Div 256)+1];
   Decimal:=Decimal-(Decimal Div 256)*256;
  End;
  If Decimal>=16 Then
  Begin;
   HexaDecimal[7]:=HexaNumbers[(Decimal Div 16)+1];
   Decimal:=Decimal-(Decimal Div 16)*16;
  End;
  If Decimal<16 Then
  Begin;
   HexaDecimal[8]:=HexaNumbers[Decimal+1];
   Decimal:=0;
  End;
 Until Decimal=0;
 Hex:=HexaDecimal;
End;

Procedure Decimal(Hex : LongString;Var DecimalLong : LongInt);
Const HexaNumbers : String='0123456789ABCDEF';
Var   X,Y         : Integer;
      Factor      : LongInt;
Begin
 DecimalLong:=0;
 For X:=1 To 8 Do
 Begin;
  Case X Of
   1: Factor:=16*16*16*16*16*16*16;
   2: Factor:=16*16*16*16*16*16;
   3: Factor:=16*16*16*16*16;
   4: Factor:=16*16*16*16;
   5: Factor:=16*16*16;
   6: Factor:=16*16;
   7: Factor:=16;
   8: Factor:=1;
  End;
  Case Hex[X] Of
  '0': DecimalLong:=DecimalLong;
  '1': DecimalLong:=DecimalLong+factor;
  '2': DecimalLong:=DecimalLong+2*factor;
  '3': DecimalLong:=DecimalLong+3*factor;
  '4': DecimalLong:=DecimalLong+4*factor;
  '5': DecimalLong:=DecimalLong+5*factor;
  '6': DecimalLong:=DecimalLong+6*factor;
  '7': DecimalLong:=DecimalLong+7*factor;
  '8': DecimalLong:=DecimalLong+8*factor;
  '9': DecimalLong:=DecimalLong+9*factor;
  'A': DecimalLong:=DecimalLong+10*factor;
  'B': DecimalLong:=DecimalLong+11*factor;
  'C': DecimalLong:=DecimalLong+12*factor;
  'D': DecimalLong:=DecimalLong+13*factor;
  'E': DecimalLong:=DecimalLong+14*factor;
  'F': DecimalLong:=DecimalLong+15*factor;
  End;
 End;
End;

Function ProgramCoded(ExeName : FileString) : Boolean;   { Processes succesfully }
Var ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
Begin
 Assign(ExeFile,ExeName);
 ReSet(ExeFile);
 Read(ExeFile,ExeHeader);
 Close(ExeFile);
 If (OrgExeSize(ExeName)+8=Size(ExeName)) Then ProgramCoded:=True Else
 If (OrgExeSize(ExeName)+8<>Size(ExeName)) Then ProgramCoded:=False;
End;

Function CodeAdded(ExeName : FileString) : Boolean;                 { Processes successfully }
Var F         : Text;
    ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
    ExeSize   : LongInt;
    ExeCode   : LongInt;
    ExePos    : LongInt;
    C         : Char;
Begin
 If (ProgramCoded(ExeName)=False) And (OrgExeSize(ExeName)=Size(ExeName)) Then
 Begin;
  ExeCode:=0;
  ExeSize:=OrgExeSize(ExeName);
  Assign(F,ExeName);
  ReSet(F);
  For ExePos:=1 To ExeSize Do
  Begin;
   Read(F,C);                           { Reads successfully ExeSize Bytes }
   Inc(ExeCode,Ord(C));
  End;
  Close(F);
  Append(F);
  Write(F,Hex(ExeCode));
  Close(F);
  CodeAdded:=True;
 End Else CodeAdded:=False;
End;

Function CodesAreEqual(ExeName : String) : Boolean;
Var F         : Text;
    ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
    ExeSize   : LongInt;
    ExeCode   : LongInt;
    FileCode  : LongInt;
    ExePos    : LongInt;
    C         : Char;
    S         : LongString;
Begin
 ExeCode:=0;
 ExeSize:=OrgExeSize(ExeName);
 Assign(F,ExeName);
 ReSet(F);
 For ExePos:=1 To ExeSize Do
 Begin;
  Read(F,C);
  Inc(ExeCode,Ord(C));
 End;
 FileCode:=0;
 Read(F,S);
 Close(F);
 Decimal(S,FileCode);
 If (FileCode=ExeCode) Then CodesAreEqual:=True Else CodesAreEqual:=False;
End;

Function ProgramChanged(ExeName : FileString) : Boolean;
Var CalcSize  : LongInt;
    ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
    X,Y       : LongInt;
Begin
 If ProgramCoded(ExeName) Then
 Begin;
  Assign(ExeFile,ExeName);
  ReSet(ExeFile);
  Read(ExeFile,ExeHeader);
  Close(ExeFile);
  X:=MakeLongInt(ExeHeader.TotalPages);
  Y:=MakeLongInt(ExeHeader.BytesLastPage);
  CalcSize:=(512*(X-1)+Y);
  If Size(ExeName)<>CalcSize+8 Then
  Begin;
   ProgramChanged:=True;
   Exit;
  End Else
  If Size(ExeName)=CalcSize+8 Then
  Begin;
   If CodesAreEqual(ExeName) Then ProgramChanged:=False Else ProgramChanged:=True;
  End;
 End Else
 Begin;
  If CodeAdded(ExeName) Then ProgramChanged:=False Else ProgramChanged:=True;
 End;
End;

Function GetFirstMCB : MCBPointer;
Var R : Registers;
Begin
 R.Ah:=$52;
 Intr($21,R);
 GetFirstMCB:=Ptr(MemW[R.Es-1:R.Bx+14],0);
End;

Function CurrentProgram : String;
Var CurrentMCB : MCBPointer;
    LastMCB    : Boolean;
    S          : String;
    B          : Byte;
Begin
 S:='';
 CurrentMCB:=GetFirstMCB;
 LastMCB:=False;
 Repeat;
  If (CurrentMCB^.OwnerPSP=PrefixSeg) Then
  Begin;
   For B:=1 To 8 Do
   Begin;
    If CurrentMCB^.OwnerID[B] In ['A'..'Z','0'..'9','é','ô','ö'] Then S:=S+CurrentMCB^.OwnerID[B];
   End;
  End;
  LastMCB:=CurrentMCB^.Flag='Z';
  CurrentMCB:=Ptr(Seg(CurrentMCB^)+CurrentMCB^.Size+1,0);
 Until LastMCB;
 CurrentProgram:=Gross(S+'.EXE');
End;

Function CurrentCMDLine : String;
Var R       : Registers;
    S       : String;
    B       : Byte;
    Segment : Word;
    PSP     : PSPPointer;
Begin
 R.Ah:=$62;
 Intr($21,R);
 Segment:=R.Bx;
 PSP:=Ptr(R.Bx,$0000);
 S:='';
 B:=3;
 Repeat;
  S:=S+PSP^.CmdLineDTA[B];
  Inc(B);
 Until PSP^.CmdLineDTA[B]=#13;
 CurrentCMDLine:=Gross(S);
End;

Function SeAnCodeAdded(ExeName : FileString) : Boolean;                 { Processes successfully }
Var F         : Text;
    ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
    ExeSize   : LongInt;
    ExeCode   : LongInt;
    ExePos    : LongInt;
    C         : Char;
Begin
 If (ProgramCoded(ExeName)=False) And (OrgExeSize(ExeName)=Size(ExeName)) Then
 Begin;
  SpecialButton(0,423,118,479,'');
  ButtonFrame(On,6,429,112,449,'');
  Flaeche(6,455,112,475,'CALCULATING...');
  SetColor(LightGreen);
  ExeCode:=0;
  ExeSize:=OrgExeSize(ExeName);
  Assign(F,ExeName);
  ReSet(F);
  For ExePos:=1 To ExeSize Do
  Begin;
   Read(F,C);                           { Reads successfully ExeSize Bytes }
   Inc(ExeCode,Ord(C));
   If Round(ExePos/ExeSize*100)<>Round((ExePos-1)/ExeSize*100) Then
   Line(9+Round(ExePos/ExeSize*100),432,9+Round(ExePos/ExeSize*100),446);
  End;
  Close(F);
  Append(F);
  Write(F,Hex(ExeCode));
  Close(F);
  SeAnCodeAdded:=True;
  Delay(2000);
  ClearButton(000,423,118,479);
 End Else SeAnCodeAdded:=False;
End;

Function SeAnCodesAreEqual(ExeName : String) : Boolean;
Var F         : Text;
    ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
    ExeSize   : LongInt;
    ExeCode   : LongInt;
    FileCode  : LongInt;
    ExePos    : LongInt;
    C         : Char;
    S         : LongString;
    X,Y       : Integer;
Begin
 SpecialButton(0,423,118,479,'');
 ButtonFrame(On,6,429,112,449,'');
 Flaeche(6,455,112,475,'CHECKING...');
 SetColor(LightGreen);
 ExeCode:=0;
 ExeSize:=OrgExeSize(ExeName);
 Assign(F,ExeName);
 ReSet(F);
 For ExePos:=1 To ExeSize Do
 Begin;
  Read(F,C);
  Inc(ExeCode,Ord(C));
  X:=Round(ExePos/ExeSize*100);
  Y:=Round((ExePos-1)/ExeSize*100);
  If X<>Y Then
  Line(9+X,432,9+X,446);
 End;
 FileCode:=0;
 Read(F,S);
 Close(F);
 Decimal(S,FileCode);
 If (FileCode=ExeCode) Then
 Begin;
  SeAnCodesAreEqual:=True;
  Flaeche(6,455,112,475,'PROGRAM OK.');
  Delay(20000);
  ClearButton(000,423,118,479);
 End Else
 Begin;
  SeAnCodesAreEqual:=False;
  Flaeche(6,455,112,475,'PROGRAM CHANGED.');
  Delay(20000);
  ClearButton(000,423,118,479);
  Delay(1000);
 End;
End;



Function SeAnProgramChanged(ExeName : FileString) : Boolean;
Var CalcSize  : LongInt;
    ExeFile   : File Of ExeHeaderType;
    ExeHeader : ExeHeaderType;
    X,Y       : LongInt;
Begin
 If ProgramCoded(ExeName) Then
 Begin;
  Assign(ExeFile,ExeName);
  ReSet(ExeFile);
  Read(ExeFile,ExeHeader);
  Close(ExeFile);
  X:=MakeLongInt(ExeHeader.TotalPages);
  Y:=MakeLongInt(ExeHeader.BytesLastPage);
  CalcSize:=(512*(X-1)+Y);
  If Size(ExeName)<>CalcSize+8 Then
  Begin;
   SeAnProgramChanged:=True;
   Exit;
  End Else
  If Size(ExeName)=CalcSize+8 Then
  Begin;
   If SeAnCodesAreEqual(ExeName) Then SeAnProgramChanged:=False Else SeAnProgramChanged:=True;
  End;
 End Else
 Begin;
  If SeAnCodeAdded(ExeName) Then SeAnProgramChanged:=False Else SeAnProgramChanged:=True;
 End;
End;

Function MouseAvailable : Boolean;
Var P : Pointer;
Begin
 GetIntVec($33,P);
 If P=Nil Then MouseAvailable:=False Else
 If Byte(P^)=$CF Then MouseAvailable:=False Else MouseAvailable:=True;
End;

Function VGAAvailable : Boolean;
Var R : Registers;
Begin
 R.Ah:=$1A;
 R.Al:=$00;
 Intr($10,R);
 If R.Bl In [$07,$08] Then VGAAvailable:=True Else VGAAvailable:=False;
End;

Procedure Check;
Var ProgramOk : Boolean;
    MouseOk   : Boolean;
    VGAOk     : Boolean;
    Ok        : Boolean;
Begin
 Button(Off,210,150,430,170,'SYSTEM CHECK');
 Button(Off,210,170,430,300,'');
 CheckBox(Off,On,230,190,'PROGRAM CODE IS OK.');
 CheckBox(Off,On,230,210,'MOUSE IS AVAILABLE.');
 CheckBox(Off,On,230,230,'VGA CARD IS AVAILABLE.');
 ProgramOk:=ProgramChanged(CurrentProgram)=False;
 CheckBox(ProgramOk,On,230,190,'PROGRAM CODE IS OK.');
 MouseOk:=MouseAvailable;
 CheckBox(MouseOk,On,230,210,'MOUSE IS AVAILABLE.');
 VGAOk:=VGAAvailable;
 CheckBox(VGAOk,On,230,230,'VGA CARD IS AVAILABLE.');
 If (ProgramOk=MouseOk) And (MouseOk=VGAOk) And (VGAOk=True) Then Ok:=True Else Ok:=False;
 If Ok=False Then PutIcon(320,260,'CAUTION') Else
 If Ok=True  Then PutIcon(320,260,'ALLRIGHT');
 Delay(2000);
 ClearButton(210,150,430,300);
 If Ok=False Then
 Begin;
  CloseGraph;
  Halt;
 End;
End;

Procedure ShowText(LX,LY,RX,RY : Integer;S : String);
Type  TextType    = Record
                     WordContent : String;
                     WordLength  : Integer;
                     Line        : Byte;
                    End;
      SpacingType = Record
                     WordsInLine : Byte;
                    End;
Var   TextData     : Array[1..20] Of TextType;
      Spacing      : Array[1..20] Of SpacingType;
      TextSpacing  : Integer;
      STemp        : String;
      LineLength   : Integer;
      LengthOWords : Array[1..20] Of Integer;
      LengthOLine  : Array[1..20] Of Integer;
      X,Y,Z        : Integer;
      Words        : Integer;
      Lines        : Integer;
      A,B          : Integer;
      WordsTemp    : Integer;
      SpacingInLine : Real;
      ATemp,BTemp   : Integer;
Begin
 Words:=0;
 Lines:=1;
 LineLength:=RX-LX;
 For A:=1 To 20 Do
 Begin;
  TextData[A].WordLength:=0;
  TextData[A].WordContent:='';
  TextData[A].Line:=1;
  Spacing[A].WordsInLine:=0;
  LengthOWords[A]:=0;
  LengthOLine[A]:=0;
 End;
 S:=S+' ';
 While Pos('  ',S)<>0 Do
 Begin;
  Delete(S,Pos('  ',S)-1,1);
 End;
 Words:=0;
 While Length(S)>0 Do
 Begin;
  STemp:='';
  For A:=1 To Pos(' ',S) Do
  Begin;
   If S[A]<>' ' Then STemp:=STemp+S[A];
  End;
  Inc(Words);
  TextData[Words].WordContent:=STemp;
  TextData[Words].WordLength:=TextWidth(STemp);
  Delete(S,1,Length(STemp)+1);
 End;
 WordsTemp:=Words;
 A:=0;
 While WordsTemp>1 Do
 Begin;
  ATemp:=A+1;
  While (LengthOLine[Lines]+TextData[A].WordLength+TextWidth(' ')<=LineLength) And (A<Words) Do
  Begin;
   Inc(LengthOLine[Lines],TextData[A].WordLength+TextWidth(' '));
   Inc(A);
   Dec(WordsTemp);
  End;
  LengthOLine[Lines]:=0;
  For B:=ATemp To A Do Inc(LengthOLine[Lines],TextData[B].WordLength);
  Spacing[Lines].WordsInLine:=A-ATemp;
  If A<Words Then Inc(Lines);
 End;
 TextSpacing:=Round((RY-LY)/Lines);
 X:=LX;
 Y:=LY;
 B:=0;
 For A:=1 To Lines Do
 Begin;
  If Spacing[A].WordsInLine>0 Then SpacingInLine:=(LineLength-LengthOLine[A])/(Spacing[A].WordsInLine) Else
  SpacingInLine:=TextWidth(' ');
  BTemp:=B+1;
  For B:=BTemp To Spacing[A].WordsInLine+BTemp Do
  Begin;
   OutTextXY(X,Y,TextData[B].WordContent);
   Inc(X,Round(TextData[B].WordLength+SpacingInLine));
  End;
  X:=LX;
  Inc(Y,TextSpacing);
 End;
End;


 Begin
 End.