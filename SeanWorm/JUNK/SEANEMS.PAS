Unit SEANEMS;


{ **************************** EMM Functions ****************************
   Fehlercodes
   $00 = Kein Fehler
   $80 = Fehler in der Software-Schnittstelle
   $81 = Fehler in der EMS-Hardware
   $83 = ungÅltige Handle-Nummer
   $84 = ungÅltige Funktionsnummer
   $85 = Alle Handle schon belegt
   $87 = zu wenig freie Seiten
   $88 = ungÅltige Seitenanzahl
   $8A = ungÅltige Seitennummer
   $8C = Mapping kann nicht gesichert werden
   $8D = Mapping ist bereits gesichert
   $8E = Mapping ist nicht gesichert gewesen                            }

InterFace

 Uses Dos;

 Var EMMResult : Word;

 Function  HexStr ( Number : Word) : String;
 Function  EMMInstalled : Boolean;
 Function  GetEMMStatus : Word;
 Function  GetEMMFrame  : Word;
 Function  GetAllocatedHandles : Word;
 Function  GetAllocatedPages ( Handle : Word ) : Word;
 Function  Message ( Result : Word ) : String;
 Procedure GetAvailablePages ( Var AvailablePages,TotalPages : Word );
 Procedure AllocatePages ( Pages : Word; Var Handle : Word );
 Procedure ReleasePages ( Handle : Word );
 Procedure MapPages ( Handle,LogicalPage,PhysicalPage : Word );
 Procedure EMMVersion ( Var High,Low : Word );
 

Implementation

 Function HexChr ( Number : Word ) : Char;
 Begin
  If Number<10 Then HexChr:=Char(Number+48) Else
  HexChr:=Char(Number+55);
 End;

 Function HexStr ( Number : Word ) : String;
 Var S : String;
 Begin
  S:='';
  S:=HexChr((Number Shr 1) Div 2048);
  Number:=(((Number Shr 1) Mod 2048) Shl 1)+ (Number And 1) ;
  S:=S+HexChr(Number div 256);
  Number:=Number Mod 256;
  S:=S+HexChr(Number div 16);
  Number:=Number Mod 16;
  S:=S+HexChr(Number);
  HexStr:=S+'h';
 End;

 Function GetBit(B : Byte;Nummer : Byte) : Boolean;
 Begin
  GetBit:=Odd(B Shr Nummer);
 End;

 Procedure SetBit(Var B : Byte;Nummer : Byte);
 Begin
  B:=B Or 1 Shl Nummer;
 End;

 Procedure ClearBit(Var B : Byte;Nummer : Byte);
 Begin
  If GetBit(B,Nummer) Then Dec(B,1 Shl Nummer);
 End;

 Function HighBCDToDec(BCD : Byte) : Byte;
 Var I : Integer;
     B : Byte;
 Begin
  B:=0;
  For I:=4 To 7 Do
  Begin;
   If GetBit(BCD,I) Then
   Begin;
    Case I Of
          4: B:=B+1;
          5: B:=B+2;
          6: B:=B+4;
          7: B:=B+8;
    End;
   End;
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
   If GetBit(BCD,I) Then
   Begin;
    Case I Of
           0: B:=B+1;
           1: B:=B+2;
           2: B:=B+4;
           3: B:=B+8;
    End;
   End;
  End;
  LowBCDToDec:=B;
 End;

 Function EMMInstalled : Boolean;
 Var F : File;
 Begin
  {$I-}
  Assign(F,'EMMXXXX0');
  ReSet(F);
  {$I+}
  If IOResult=0 Then
  Begin;
   EMMInstalled:=True;
   Close(F);
  End Else EMMInstalled:=False;
 End;

 Function GetEMMStatus : Word;
 Var R : Registers;
 Begin
  R.Ah:=$40;
  Intr($67,R);
  GetEMMStatus:=R.Ah;
 End;

 Function GetEMMFrame  : Word;
 Var R : Registers;
 Begin
  R.Ah:=$41;
  Intr($67,R);
  GetEMMFrame:=R.Bx;
  EMMResult:=R.Ah;
 End;

 Procedure GetAvailablePages ( Var AvailablePages,TotalPages : Word );
 Var R : Registers;
 Begin
  R.Ah:=$42;
  Intr($67,R);
  AvailablePages:=R.Bx;
  TotalPages:=R.Dx;
  EMMResult:=R.Ah;
 End;

 Procedure AllocatePages ( Pages : Word; Var Handle : Word );
 Var R : Registers;
 Begin
  R.Ah:=$43;
  R.Bx:=Pages;
  Intr($67,R);
  Handle:=R.Dx;
  EMMResult:=R.Ah;
 End;

 Procedure ReleasePages ( Handle : Word );
 Var R : Registers;
 Begin
  R.Ah:=$45;
  R.Dx:=Handle;
  Intr($67,R);
  EMMResult:=R.Ah;
 End;

 Procedure MapPages ( Handle,LogicalPage,PhysicalPage : Word );
 Var R : Registers;
 Begin
  R.Ah:=$44;
  R.Al:=PhysicalPage;
  R.Bx:=LogicalPage;
  R.Dx:=Handle;
  Intr($67,R);
  EMMResult:=R.Ah;
 End;

 Procedure EMMVersion ( Var High,Low : Word );
 Var R : Registers;
     B : Byte;
 Begin
  R.Ah:=$46;
  Intr($67,R);
  High:=HighBCDToDec(R.Al);
  Low:=LowBCDToDec(R.Al);
  EMMResult:=R.Ah;
 End;

 Function GetAllocatedHandles : Word;
 Var R : Registers;
 Begin
  R.Ah:=$4B;
  Intr($67,R);
  GetAllocatedHandles:=R.Bx;
  EMMResult:=R.Ah;
 End;

 Function  GetAllocatedPages ( Handle : Word ) : Word;
 Var R : Registers;
 Begin
  R.Ah:=$4C;
  R.Dx:=Handle;
  Intr($67,R);
  GetAllocatedPages:=R.Bx;
  EMMResult:=R.Ah;
 End;

 Function Message ( Result : Word ) : String;
 Begin
  Case Result Of
   $00: Message:='no error';
   $80: Message:='error with your EMM';
   $81: Message:='error with your EMS-Hardware';
   $83: Message:='invalid handle';
   $84: Message:='invalid function';
   $85: Message:='no free handle';
   $87: Message:='no free pages';
   $88: Message:='invalid page amount';
   $8A: Message:='invalid page nr';
   $8C: Message:='unable to save mapping';
   $8D: Message:='mapping already saved';
   $8E: Message:='mapping has not been saved';
   Else Message:='unknown error';
  End;
 End;



 Begin
 End.
