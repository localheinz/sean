Unit SEANDOS;

 { **************************** DOS Functions ****************************
   Fehlercodes
   $00 = Kein Fehler
   $01 = ungÅltige Funktionsnummer
   $02 = keine Adress-Markierung
   $03 = Diskette ist schreibgeschÅtzt
   $04 = Sector nicht gefunden
   $05 = Reset war erfolglos
   $07 = fehlerhafte Initialisierung
   $08 = öberlauf des DMA
   $09 = Segmentgrenzen-öberlauf
   $10 = Lesefehler
   $11 = Daten trotz falscher PrÅfsumme gelesen
   $20 = Fehler des Controllers
   $40 = Spur nicht gefunden
   $80 = Laufwerk reagiert nicht
   $BB = BIOS-Fehler
   $FF = nicht aufschlÅsselbarer Fehler                                   }

InterFace

 Uses Dos;

 Var BIOSResult : Word;

 Type BufferType = Array[1..18*512] Of Char;

 Procedure InitDrives;
 Function  GetFDStatus : Word;
 Function  GetHDStatus ( HDrive : Word ) : Word;
 Procedure ReadSectors ( Drive,Side,Track,Sector,Sectors : Word; Var Buffer : BufferType);
 Procedure WriteSectors ( Drive,Side,Track,Sector,Sectors : Word; Var Buffer );
 Procedure VerifySectors ( Drive,Side,Track,Sector,Sectors : Word; Var VerifyBuffer );
 Procedure FormatTrack ( Drive,Side,Track,Sectors : Word );
 Procedure MarkHDTrack ( HDrive,Head,Cylinder : Word );
 Procedure GetHDFormat ( HDrive : Word; Var HDrives,Heads,Cylinders,Sectors : Word );
 Procedure ParkHD ( HDrive : Word );
 Procedure CheckHDSector0 ( HDrive : Word );
 Procedure CheckHDController ( HDrive : Word );
 Function  GetHDType ( HDrive : Word ) : Word;

Implementation

 Procedure InitDrives;
 Var R : Registers;
 Begin
  R.Ah:=$00;
  R.Dl:=$00;
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Function  GetFDStatus : Word;
 Var R : Registers;
 Begin
  R.Ah:=$01;
  R.Dl:=$00;
  Intr($13,R);
  GetFDStatus:=R.Ah;
 End;

 Function  GetHDStatus ( HDrive : Word ) : Word;
 Var R : Registers;
 Begin
  R.Ah:=$01;
  R.Dl:=HDrive;
  Intr($13,R);
  GetHDStatus:=R.Ah;
 End;

 Procedure ReadSectors ( Drive,Side,Track,Sector,Sectors : Word; Var Buffer : BufferType);
 Var R : Registers;
 Begin
  R.Ah:=$02;
  R.Dl:=Drive;
  R.Dh:=Side;
  R.Ch:=Track;
  R.Cl:=Sector;
  R.Al:=Sectors;
  R.Es:=Seg(Buffer);
  R.Bx:=Ofs(Buffer);
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure WriteSectors ( Drive,Side,Track,Sector,Sectors : Word; Var Buffer );
 Var R : Registers;
 Begin
  R.Ah:=$03;
  R.Dl:=Drive;
  R.Dh:=Side;
  R.Ch:=Track;
  R.Cl:=Sector;
  R.Al:=Sectors;
  R.Es:=Seg(Buffer);
  R.Bx:=Ofs(Buffer);
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure VerifySectors ( Drive,Side,Track,Sector,Sectors : Word; Var VerifyBuffer );
 Var R : Registers;
 Begin
  R.Ah:=$04;
  R.Dl:=Drive;
  R.Dh:=Side;
  R.Ch:=Track;
  R.Cl:=Sector;
  R.Al:=Sectors;
  R.Es:=Seg(VerifyBuffer);
  R.Bx:=Ofs(VerifyBuffer);
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure FormatTrack ( Drive,Side,Track,Sectors : Word );
 Var R      : Registers;
     B      : Byte;
     Buffer : Array[1..18] Of Array[0..3] Of Byte;
 Begin
  For B:=1 To Sectors Do
  Begin;
   Buffer[B][$00]:=Track;
   Buffer[B][$01]:=Side;
   Buffer[B][$02]:=B;
   Buffer[B][$03]:=2;    { 0 =  128 Bytes }
  End;                   { 1 =  256 Bytes }
  R.Ah:=$05;             { 2 =  512 Bytes }
  R.Dl:=Drive;           { 3 = 1024 Bytes }
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure MarkHDTrack ( HDrive,Head,Cylinder : Word );
 Var R : Registers;
 Begin
  R.Ah:=$06;
  R.Dl:=HDrive;
  R.Dh:=Head;
  R.Ch:=Cylinder;
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure GetHDFormat ( HDrive : Word; Var HDrives,Heads,Cylinders,Sectors : Word );
 Var R : Registers;
 Begin
  R.Ah:=$08;
  R.Dl:=HDrive;
  Intr($13,R);
  HDrives:=R.Dl;
  Heads:=R.Dh;
  Cylinders:=R.Ch;
  Sectors:=R.Cl;
  BIOSResult:=R.Ah;
 End;

 Procedure ParkHD ( HDrive : Word );
 Var R : Registers;
 Begin
  R.Ah:=$11;
  R.Dl:=HDrive;
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure CheckHDSector0 ( HDrive : Word );
 Var R : Registers;
 Begin
  R.Ah:=$13;
  R.Dl:=HDrive;
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Procedure CheckHDController ( HDrive : Word );
 Var R : Registers;
 Begin
  R.Ah:=$14;
  R.Dl:=HDrive;
  Intr($13,R);
  BIOSResult:=R.Ah;
 End;

 Function  GetHDType ( HDrive : Word ) : Word;
 Var R : Registers;
 Begin
  R.Ah:=$15;              { 0 = nicht vorhanden                }
  R.Dl:=HDrive;           { 1 = erkennt Diskettenwechsel nicht }
  Intr($13,R);            { 2 = erkennt Diskettenwechsel       }
  GetHDType:=R.Ah;        { 3 = Festplatte                     }
 End;

 Begin
 End.