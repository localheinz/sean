Program AnalyzeIconStructure;
Uses Dos,Graph,Bits,SeAnHelp;
Type WinIcon766 = Record
                    Data1       : Array[1..3] Of Word;
                    Length      : Byte;
                    Width       : Byte;
                    Colors      : Byte;
                    Data        : Array[1..115] Of Byte;                { Uh? }
                    Pixel       : Array[1..16] Of Array[1..32] Of Byte; { PixelaufschlÅsselung }
                    BkGrMask    : Array[1..32] Of LongInt;              { Immer ein Bit fÅr Pixel=Durchsichtig? }
                   End;
Var  WinIcon     : Array[0..9] Of WinIcon766;
     WinFile     : File Of WinIcon766;
     F           : File;
     B           : Byte;
     S           : SearchRec;
     X,Y,Z       : Integer;

Procedure LoadWinIcon(WinIconName : String; Var LoadedWinIcon : WinIconArea);
Var WinIconFile  : File Of WinIconType;
    WinIconDummy : WinIconType;
    X,Y          : Integer;
    Attributes   : WinIconArea;

Begin
 Assign(WinIconFile,WinIconName);
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


Procedure PutWinIcon(SetX,SetY : Word; WinIconName : String );
Var WinIcon : WinIconArea;
    X,Y     : Word;
Begin
 LoadWinIcon(WinIconName,WinIcon);
 PushWinIcon(SetX,SetY,WinIcon);
End;





Function High(B : Byte) : Byte;
Var A,C : Byte;
Begin
 C:=0;
 For A:=0 To 3 Do
 Begin;
  If GetBit(B,A) Then SetBit(C,A);
 End;
 High:=C;
End;

Function Low(B : Byte) : Byte;
Var A,C : Byte;
Begin
 C:=0;
 For A:=4 To 7 Do
 Begin;
  If GetBit(B,A) Then SetBit(C,A-4);
 End;
 Low:=C;
End;

Begin
 DetectGraph(X,Y);
 InitGraph(X,Y,'C:\DOS\BORLAND\BGI');
 FindFirst('*.ICO',AnyFile,S);
 X:=0;
 Y:=0;
 While DosError=0 Do
 Begin;
  If (S.Size)=766 Then
  Begin;
   PutWinIcon(X*33+16,Y*33+16,S.Name);
   Inc(X);
   If (X=18) Then
   Begin;
    X:=0;
    Inc(Y);
   End;
  End;
  FindNext(S);
 End;
 ReadLn;
 CloseGraph;
End.
