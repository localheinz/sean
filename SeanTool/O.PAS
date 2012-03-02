Program FindDoubles;
Uses Crt,Dos,SeAnHelp;
Const Info         = 'O.Pas written by Andreas M”ller (02ù10ù96)';
Type  FileDataType = Record
                      Name : String[12];
                      Size : LongInt;
                      Time : LongInt;
                     End;
Var   FileData     : FileDataType;
      Files,Dirs   : LongInt;
      Dir          : String;
      F            : File;

Procedure FindFiles(Dir : DirStr);
Type DRec = Record
             Time: Longint;
             Size: Longint;
             Name: String[12];
            End;
Var  D    : DRec;
     S    : SearchRec;
     C    : Char;
Begin
 FindFirst(Dir+'\*.*',AnyFile,S);
 While (DosError=0) Do
 Begin;
  If (S.Attr<>$10) Then
  Begin;
   D.Name:=S.Name;
   D.Time:=S.Time;
   D.Size:=S.Size;
   Write(F,D);
   Inc(Files);
  End Else
  If (S.Attr=$10) And (S.Name[1]<>'.') Then Inc(Dirs);
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

Procedure Dupliziere;
Var OrgF,NewF : File;
    NumRead   : Word;
    NumWritten: Word;
    Buffer    : Array[1..10000] Of Char;
Begin
 Assign(OrgF,'\FILES.ORG');
 ReSet(OrgF);
 Assign(NewF,'\FILES.NEW');
 Repeat;
  BlockRead(OrgF,Buffer,SizeOf(Buffer),NumRead);
  BlockWrite(NewF,Buffer,NumRead,NumWritten);
 Until (NumRead = 0) or (NumWritten <> NumRead);
 Close(OrgF);
 Close(NewF);
End;

Function Kleiner(R,S : ExtStr) : Boolean; {True when R<S}
Var B : Boolean;
Begin
 B:=False;
 If Ord(R[1])<Ord(S[1]) Then B:=True Else
 If Ord(R[1])=Ord(S[1]) Then
 Begin;
  If Ord(R[2])<Ord(S[2]) Then B:=True Else
  If Ord(R[2])=Ord(S[2]) Then
  Begin;
   If Ord(R[3])<Ord(S[3]) Then B:=True;
  End;
 End;
 Kleiner:=B;
End;

Procedure Sort;
Type DRec        = Record
                    Time: Longint;
                    Size: Longint;
                    Name: String[12];
                   End;
Var  DataA,DataB : DRec;
     OrgF,NewF   : File;
     A,B,C       : Integer;
Begin
 Dupliziere;
{ For A:=1 To Files Do
 Begin;
  For B:=A+1 To Files Do
  Begin;
   Seek(OrgF,(A-1)*SizeOf(DataA));
   Read(OrgF,DataA);
   Seek(OrgF,(B-1)*SizeOf(DataB));
   Read(OrgF,DataB);
   If Not (Kleiner(DataA.Name,DataB.Name)) Then
   Begin;
    Seek(NewF,(A-1)*SizeOf(DataA));
    Write
    Dummy[A]:=ExtData[B];
    For C:=A+1 To B Do Dummy[C]:=ExtData[C-1];
    ExtData:=Dummy;
   End;
  End;
 End;}
End;



 Begin
  Files :=0;
  Dirs  :=0;
  GetDir(0,Dir);
  ClrScr;
  WriteLn(Info);
  Write('Please hold on while scanning disk...');
  Assign(F,'\FILES.ORG');
  ReWrite(F);
  FindFiles(Dir[1]+':');
  Close(F);
  WriteLn('Ok.');
  WriteLn('Found ',BigSize(Files),' files.');
  WriteLn('Found ',BigSize(Dirs),' directories.');
  ChDir(Dir);
 End.
