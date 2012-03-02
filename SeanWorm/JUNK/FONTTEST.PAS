Program FontTest;
Uses Dos,Crt,Graph;
Type FontType = Record
                 CopyRight : Array[1..00086] Of Char;
                 Const1    : Array[1..5] Of Char; {#13,#10,#26,#128,#0}
                 FontName  : Array[1..4] Of Char;
                 Data      : Array[1..16320] Of Byte;
                End;
Var  FontFile : File of FontType;
     FontData : FontType;
     Key      : Char;
     I        : Integer;

Begin
 Assign(FontFile,'Goth.CHR');
 ReSet(FontFile);
 Read(FontFile,FontData);
 Close(FontFile);
End.