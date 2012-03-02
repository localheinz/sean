Program DiskInfo;
Uses Crt,Dos,SeAnHelp,Bits;
Type  ExtType         = Record
                         NamOfExt : ExtString;
                         Files    : Integer;
                         SizOfExt : LongInt;
                        End;
      ExtDataType     = Array[1..1000] Of ExtType;
Var   NumOfExt        : Integer;
      ExtData         : ExtDataType;
      TotalFiles      : LongInt;
      TotalSize       : LongInt;
      Dirs            : LongInt;
      I               : Integer;
      Dir             : DirStr;
      R               : Registers;
      S               : String;
      FirstTimerHigh,
      FirstTimerLow,
      Time            : LongInt;
      DiskSiz         : LongInt;
      F               : Text;
Const Info            = 'I.Pas written by Andreas M”ller (02ù03ù96).';

Function Ext(FName : FileString) : ExtString;
Var S : ExtStr;
    B : Byte;
Begin
 S:='';
 For B:=Pos('.',FName)+1 To Length(FName) Do S:=S+FName[B];
 While Length(S)<3 Do S:=S+' ';
 Ext:=S;
End;

Procedure SearchDisk(Dir : DirStr);
Var S          : SearchRec;
    F          : File;
    C          : Char;
    I          : Integer;
    DoneSo     : Boolean;
    CurrentExt : ExtString;
Begin
 FindFirst(Dir+'\*.*',AnyFile,S);
 While (DosError=0) Do
 Begin;
  If (S.Attr<>$10) Then
  Begin;
   DoneSo:=False;
   Inc(TotalFiles);
   Inc(TotalSize,S.Size);
   CurrentExt:=Ext(S.Name);
   For I:=1 To NumOfExt Do
   Begin;
    If CurrentExt=ExtData[I].NamOfExt Then
    Begin;
     Inc(ExtData[I].Files);
     Inc(ExtData[I].SizOfExt,S.Size);
     DoneSo:=True;
    End;
   End;
   If Not DoneSo Then
   Begin;
    Inc(NumOfExt);
    ExtData[NumOfExt].NamOfExt:=CurrentExt;
    Inc(ExtData[NumOfExt].Files);
    Inc(ExtData[NumOfExt].SizOfExt,S.Size);
   End;
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
   SearchDisk(Dir+'\'+S.Name);
  End;
  FindNext(S);
 End;
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

Procedure Sort(Var ExtData : ExtDataType; NumOfExt : Integer);
Var Dummy : ExtDataType;
    A,B,C : Integer;
Begin
 Dummy:=ExtData;
 For A:=1 To NumOfExt Do
 Begin;
  For B:=A+1 To NumOfExt Do
  Begin;
   If Not (Kleiner(ExtData[A].NamOfExt,ExtData[B].NamOfExt)) Then
   Begin;
    Dummy[A]:=ExtData[B];
    For C:=A+1 To B Do Dummy[C]:=ExtData[C-1];
    ExtData:=Dummy;
   End;
  End;
 End;
End;




 Begin
  WriteLn;
  WriteLn(Info);
  If (((ParamCount>0) And (Gross(ParamStr(1))='/R')) Or (ParamCount=0)) Then
  Begin;
   Write('Scanning Disk . . .');
   DiskSiz:=DiskSize(0);
   TotalFiles:=0;
   TotalSize :=0;
   Dirs      :=0;
   NumOfExt  :=0;
   For I:=1 To 1000 Do
   Begin;
    ExtData[I].NamOfExt:='';
    ExtData[I].Files   :=0;
    ExtData[I].SizOfExt:=0;
   End;
   GetDir(0,Dir);
   ChDir('\');
   R.Ah:=$00;
   Intr($1A,R);
   FirstTimerHigh:=R.Cx;
   FirstTimerLow:=R.Dx;
   R.Ah:=$01;
   R.Cx:=$00;
   R.Dx:=$00;
   Intr($1A,R);
   SearchDisk(Dir[1]+':');
   R.Ah:=$00;
   Intr($1A,R);
   Time:=R.Cx*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2+R.Dx;
   R.Ah:=$00;
   Intr($1A,R);
   R.Ah:=$01;
   R.Cx:=R.Cx+FirstTimerHigh;
   R.Dx:=R.Dx+FirstTimerLow;
   Intr($1A,R);
   Sort(ExtData,NumOfExt);
  End;
  WriteLn;
  If (ParamCount=1) And (Gross(ParamStr(1))='/R') Then
  Begin;
   Assign(F,'\REPORT.INF');
   ReWrite(F);
   WriteLn(F,Info);
   WriteLn(F,'Extension Name....Files....Total Size....Average Size....Percentage');
   WriteLn(F);
   For I:=1 To NumOfExt Do
   Begin;
    Write(F,ExtData[I].NamOfExt:3);
    Write(F,ExtData[I].Files:20);
    Write(F,ExtData[I].SizOfExt:14);
    Write(F,(Round(ExtData[I].SizOfExt/ExtData[I].Files)):16);
    WriteLn(F,(ExtData[I].SizOfExt/DiskSiz*100):13:2,'%');
   End;
   WriteLn(F,'-------------------------------------------------------------------');
   Write(F,'TOTAL (',NumOfExt,')');
   Write(F,TotalFiles:12);
   Write(F,(DiskSize(0)-DiskFree(0)):14);
   Write(F,Round((DiskSize(0)-DiskFree(0))/TotalFiles):16);
   WriteLn(F,((1-DiskFree(0)/DiskSize(0))*100):13:2,'%');
   Close(F);
   ChDir(Dir);
  End Else
  If (ParamCount=1) And (Gross(ParamStr(1))='/?') Then
  Begin;
   WriteLn(Info);
   WriteLn('This program helps you to find out a little more about what''s on your disk. It');
   WriteLn('scans thru the directories on it, counts how many files of this or that type');
   WriteLn('it has found, and puts it either on your screen (when executed w/o parameters)');
   WriteLn('or into a file.');
   WriteLn('I.EXE [/R] [/?]');
   WriteLn('       /R  Creates \REPORT.INF with report on files on your disk');
   WriteLn('       /?  Displays this message');
   WriteLn;
  End Else
  Begin;
   WriteLn(Info);
   WriteLn('Extension Name....Files....Total Size....Average Size....Percentage');
   WriteLn;
   For I:=1 To NumOfExt Do
   Begin;
    Write(ExtData[I].NamOfExt:3);
    Write(ExtData[I].Files:20);
    Write(ExtData[I].SizOfExt:14);
    Write((Round(ExtData[I].SizOfExt/ExtData[I].Files)):16);
    WriteLn((ExtData[I].SizOfExt/DiskSiz*100):13:2,'%');
   End;
   WriteLn('-------------------------------------------------------------------');
   Write('TOTAL (',NumOfExt,')');
   Write(TotalFiles:12);
   Write((DiskSize(0)-DiskFree(0)):14);
   Write(Round((DiskSize(0)-DiskFree(0))/TotalFiles):16);
   WriteLn(((1-DiskFree(0)/DiskSize(0))*100):13:2,'%');
   WriteLn('Elapsed time is ',(Time/18.2):5:2,'s.');
   ChDir(Dir);
   WriteLn;
  End;
 End.
