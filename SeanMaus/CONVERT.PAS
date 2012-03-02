Program Convert; { Converts SeanMaus 1.0 To higher }
Uses Crt,Dos,SeAnHelp;
Const MouseExt     = '.'+#255+'SM';
Type  OldMouseType = Record
                      Description : String40;
                      Pixel       : Array[1..16] Of Array[1..16] Of Byte;
                     End;
      NewMouseType = Record
                      Remark  : String40;
                      Pixel   : Array[1..16] Of Array[1..16] Of Byte;
                      HotSpot : Array[1..2] Of Byte;
                     End;
Var   OldMouse     : OldMouseType;
      NewMouse     : NewMouseType;
      OldMFile     : File Of OldMouseType;
      NewMFile     : File Of NewMouseType;
      S            : SearchRec;
      X,Y          : Integer;

Begin
 FindFirst('*'+MouseExt,AnyFile,S);
 While DosError=0 Do
 Begin;
  If (S.Size=SizeOf(OldMouse)) Then
  Begin;
   Write(Gross(S.Name),'...');
   Assign(OldMFile,S.Name);
   ReSet(OldMFile);
   Read(OldMFile,OldMouse);
   Close(OldMFile);
   For X:=1 To 16 Do
   Begin;
    For Y:=1 To 16 Do NewMouse.Pixel[X][Y]:=OldMouse.Pixel[X][Y];
   End;
   NewMouse.ReMark:=OldMouse.Description;
   NewMouse.HotSpot[1]:=1;
   NewMouse.HotSpot[2]:=1;
   Assign(NewMFile,S.Name);
   ReWrite(NewMFile);
   Write(NewMFile,NewMouse);
   Close(NewMFile);
   WriteLn('Done.');
  End;
  FindNext(S);
 End;
End.


