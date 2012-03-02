Program SeanBank;
Uses Crt,Graph,SeanHelp,Maus,Dos;
Type EntryType   = Record
                    Datum   : DateTime;
                    Soll    : Real;
                    Haben   : Real;
                    Vermerk : String40;
                    KStelle : Byte;
                    ZahlArt : Byte;
                   End;
Var  Key         : Char;
     X,Y,Z       : Word;
     StartUpDir  : String;
     DataFile    : File;

Procedure Check4Errors;
Var CPU,M,K : Word;
Begin
 If Ms_Init(MButtons)=False Then
 Begin;
  SpecialButton(160,190,360,310,'');
  InsRectAngle(170,200,350,270,'');
  Area(LightGray,180,210,340,230,'OHNE MAUS GEHT NIX.');
  PutIcon(260,250,'MOUSE');
  ButtonFrame(Off,270,280,350,300,'ENTER');
  Repeat
   Key:=ReadKey;
  Until Key=#13;
  ButtonFrame(On,270,280,350,300,'');
  Delay(200);
  ButtonFrame(Off,270,280,350,300,'');
  CloseGraph;
  Halt;
 End Else Ms_Show;
End;

Procedure New;
Begin
 Button(Off,000,020,520,479,'');
 Frame('BUCHUNG',010,040,510,100);
 TextOut(020,050,'DATUM');
 TextOut(100,050,'WERT');
 TextOut(190,050,'VERMERK');
 TextOut(300,050,'KOSTENSTELLE');
 TextOut(420,050,'ZAHLUNGSART');
 InsRectAngle(020,070,090,090,'27.05.97');
 InsRectAngle(100,070,180,090,'30000,00');
 InsRectAngle(190,070,290,090,'TRINKGELD');
 InsRectAngle(300,070,400,090,'GEHALT');
 InsRectAngle(420,070,500,090,'UNBAR');
 Frame('ANSICHT',010,110,510,460);
 InsRectAngle(020,120,088,140,'');
 InsRectAngle(090,120,168,140,'');
 InsRectAngle(170,120,248,140,'');
 InsRectAngle(250,120,368,140,'');
 InsRectAngle(370,120,418,140,'');
 InsRectAngle(420,120,500,140,'');
 Area(LightBlue,023,123,085,137,'DATUM');
 Area(LightBlue,093,123,165,137,'SOLL');
 Area(LightBlue,173,123,245,137,'HABEN');
 Area(LightBlue,253,123,365,137,'BEMERKUNG');
 Area(LightBlue,373,123,415,137,'KS');
 Area(LightBlue,423,123,497,137,'STAND');
 SetColor(DarkGray);
 Line(020,142,020,442);
 Line(090,142,090,442);
 Line(090,142,090,442);
 Line(170,142,170,442);
 Line(250,142,250,442);
 Line(370,142,370,442);
 Line(420,142,420,442);
 Line(500,142,500,442);
 For X:=1 To 16 Do
 Begin;
  Line(020,X*20+122,500,X*20+122);
 End;








End;



Begin
 GetDir(0,StartUpDir);
 GraphMode(Driver,Mode);
 Font(0,5);
 Button(Off,000,000,639,020,'SEANBANK 1.0');
 Button(Off,520,020,639,060,'');
 Button(Off,520,060,639,100,'');
 Button(Off,520,100,639,140,'');
 Button(Off,520,140,639,180,'');
 Button(Off,520,180,639,439,'');
 Button(Off,520,439,639,479,'');
 PutIcon(540,040,'NEW');
 PutIcon(540,080,'LOAD');
 PutIcon(540,120,'SAVE');
 PutIcon(540,160,'SAVEAS');
 PutIcon(540,459,'QUIT');
 Area(LightGray,560,030,630,050,'NEW');
 Area(LightGray,560,070,630,090,'OPEN');
 Area(LightGray,560,110,630,130,'SAVE');
 Area(LightGray,560,150,630,170,'SAVE AS');
 Area(LightGray,560,449,630,469,'QUIT');
 New;
 Check4Errors;
 Repeat
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Case X Of
  520..639: Case Y Of
            020..060: If MouseDelay(520,020,639,060) Then
                      Begin;
                       {New;}
                       Ms_Show;
                      End;
            060..100: If MouseDelay(520,060,639,100) Then
                      Begin;
                       {Load;}
                       Ms_Show;
                      End;
            060..100: If MouseDelay(520,060,639,100) Then
                      Begin;
                       {Save;}
                       Ms_Show;
                      End;
            060..100: If MouseDelay(520,060,639,100) Then
                      Begin;
                       {Saveas;}
                       Ms_Show;
                      End;
            439..479: If MouseDelay(520,439,639,479) Then
                      Begin;
                       ChDir(StartUpDir);
                       CloseGraph;
                       Halt;
                      End;
            End;
  End;
 Until 1=2;
End.