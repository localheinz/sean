Program DoubleOccurancies;
Uses  Crt,Dos,SeanHelp;
Const Info      = 'D.Pas written by Andreas M”ller (02ù18ù96)';
      Files     : Word = 0;
      Dirs      : Word = 0;
Var   FRep,FFil : Text;
      Dir       : String;
      S         : String;
      FName     : Array[1..2] Of String;
      FPos,X    : LongInt;
      Lines     : LongInt;
      TFiles    : Word;

Procedure FindFiles(Dir : String);
Var S : SearchRec;
    F : File;
    C : Char;
Begin
 FindFirst(Dir+'\*.*',AnyFile,S);
 While (DosError=0) Do
 Begin;
  If (S.Attr<>$10) Then
  Begin;
   Inc(TFiles);
   WriteLn(FRep,Dir+'\'+S.Name,', ',S.Size);
  End Else
  If (S.Attr=$10) And (S.Name[1]<>'.') Then
  Begin;
   Inc(Dirs);
  End;
  FindNext(S);
 End;
 FindFirst(Dir+'\*.*',$10,S);
 While (DosError=0) Do
 Begin;
  If (S.Attr=$10) And (S.Name[1]<>'.') Then
  Begin;
   ChDir(Dir+'\'+S.Name);
   FindFiles(Dir+'\'+S.Name);
  End;
  FindNext(S);
 End;
End;

Begin
 ClrScr;
 GetDir(0,Dir);
 Assign(FRep,'\REPORT.DBL');
 ReWrite(FRep);
 WriteLn(Info);
 Write('Scanning Disk...');
 FindFiles(Dir[1]+':');
 Close(FRep);
 WriteLn('Ok.');
 Write('Checking...');
 ChDir(Dir);
 Assign(FFil,'\FILES.DBL');
 ReWrite(FFil);
 Assign(FRep,'\REPORT.DBL');
 Reset(FRep);
 FPos:=1;
 Lines:=0;
 While Not Eof(FRep) Do
 Begin;
  ReadLn(FRep,S);
  Inc(Lines);
 End;
 Close(FRep);
 While FPos<=Lines Do
 Begin;
  Assign(FRep,'\REPORT.DBL');
  Reset(FRep);
  Files:=1;
  For X:=1 To FPos Do ReadLn(FRep,S);
  FName[1]:=S;
  While Pos('\',FName[1])<>0 Do Delete(FName[1],1,Pos('\',FName[1]));
  While Not Eof(FRep) Do
  Begin;
   ReadLn(FRep,S);
   FName[2]:=S;
   While Pos('\',FName[2])<>0 Do Delete(FName[2],1,Pos('\',FName[2]));
   If FName[1]=FName[2] Then Inc(Files);
   GoToXY(12,WhereY);
   WriteLn(FName[1],'=',FName[2],'?');
  End;
  If Files>1 Then WriteLn(FFil,FName[1],Files:4,' Files');
  Inc(FPos);
  Close(FRep);
 End;
 Close(FRep);
 Close(FFil);
End.