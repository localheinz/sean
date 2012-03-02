{$D-,A-,I-,L-,E-,O-,R-,S-}
Program SearchFiles;
Uses Crt,Dos,SeAnHelp;
Const Info         = 'S.Pas written by Andreas M”ller (02ù03ù96)';
Var FileName       : String;
    Files          : Integer;
    Dirs           : Integer;
    Dir            : DirStr;
    TSize          : LongInt;
    SSize          : String;
    S              : String;
    Mega           : Integer;
    Kilo           : Integer;
    Bytes          : Integer;
    FirstTimerHigh : Word;
    FirstTimerLow  : Word;
    R              : Registers;
    Time           : LongInt;
    Paused         : Boolean;
    Suppressed     : Boolean;
    Report         : Boolean;
    ThisDir        : Boolean;
    Invalid        : Boolean;
    FText          : Text;

Function ModName(Path : String) : String;
Const MaxLength = 50;
Var   S         : String;
      R         : String;
Begin
 S:=Path;
 R:=S;
 If Length(S)>MaxLength Then
 Begin;
  R:=Copy(S,1,Pos('\',S))+'...';
  While Length(S)+Length(R)>MaxLength Do
  Begin;
   Delete(S,1,Pos('\',S));
  End;
  R:=R+'\'+S;
 End;
{ If Length(R)<MaxLength Then
 Begin;
  While Length(R)<MaxLength Do R:=R+' ';
 End;}
 ModName:=R;
End;


Procedure FindFiles(Dir : DirStr);
Var S : SearchRec;
    F : File;
    C : Char;
Begin
 FindFirst(Dir+'\'+FileName,AnyFile,S);
 While (DosError=0) Do
 Begin;
  If (S.Attr<>$10) Then
  Begin;
   Inc(Files);
   Inc(TSize,S.Size);
   If Not Suppressed Then
   Begin;
    If Report=True Then WriteLn(FText,ModName(Dir+'\'+S.Name),'   (',BigSize(S.Size),' Bytes)') Else
    If Report=False Then WriteLn(ModName(Dir+'\'+S.Name),'   (',BigSize(S.Size),' Bytes)');
    If Paused=True Then
    Begin;
     If ((Files+Dirs)/24=Int((Files+Dirs)/24)) And (Files+Dirs>1) Then
     Begin;
      Write('Paused. Press Space to resume!');
      Repeat
       C:=ReadKey;
      Until C=#32;
      GoToXY(1,WhereY);
      DelLine;
      GoToXY(1,WhereY);
     End;
    End;
   End;
  End Else
  If (S.Attr=$10) And (S.Name[1]<>'.') Then
  Begin;
   Inc(Dirs);
   If Not Suppressed Then
   Begin;
    If Report=True Then WriteLn(FText,ModName(Dir+'\'+S.Name),'   (Dir)') Else
    If Report=False Then WriteLn(ModName(Dir+'\'+S.Name),'   (Dir)');
    If Paused=True Then
    Begin;
     If ((Files+Dirs)/24=Round(Files+Dirs)/24) And (Files+Dirs>0) Then
     Begin;
      Write('Paused. Press Space to resume!');
      Repeat
       C:=ReadKey;
      Until C=#32;
      GoToXY(1,WhereY);
      DelLine;
      GoToXY(1,WhereY);
     End;
    End;
   End;
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
  Files :=0;
  Dirs  :=0;
  TSize :=0;
  GetDir(0,Dir);
  Paused     :=False;
  Suppressed :=False;
  Report     :=False;
  ThisDir    :=False;
  Invalid    :=False;
  If ParamCount=2 Then
  Begin;
   If Gross(ParamStr(2))='/P' Then Paused     :=True Else
   If Gross(ParamStr(2))='/S' Then Suppressed :=True Else
   If Gross(ParamStr(2))='/R' Then Report     :=True Else
   If Gross(ParamStr(2))='/T' Then ThisDir    :=True;
  End Else
  If ParamCount=3 Then
  Begin;
   If Gross(ParamStr(2))='/P' Then Paused     :=True Else
   If Gross(ParamStr(2))='/S' Then Suppressed :=True Else
   If Gross(ParamStr(2))='/R' Then Report     :=True;
   If Gross(ParamStr(3))='/T' Then ThisDir:=True;
  End Else Invalid:=True;
  If (ParamCount=1) Or Paused Or Suppressed Or Report Or ThisDir Then
  Begin;
   FileName:=Gross(ParamStr(1));
   WriteLn(Info);
   If ThisDir=True Then WriteLn('Startup Directory : ',Dir) Else
   If ThisDir=False Then WriteLn('Startup Directory : ',Dir[1],':\');
   Writeln('Searching for file: ',FileName);
   If Report=True Then
   Begin;
    Assign(FText,'\REPORT.SRC');
    ReWrite(FText);
    WriteLn(FText,Info);
    If ThisDir=True Then WriteLn(FText,'Startup Directory : ',Dir) Else
    If ThisDir=False Then WriteLn(FText,'Startup Directory : ',Dir[1],':\');
    Writeln(FText,'Searching for file: ',FileName);
   End Else
   R.Ah:=$00;
   Intr($1A,R);
   FirstTimerHigh:=R.Cx;
   FirstTimerLow:=R.Dx;
   R.Ah:=$01;
   R.Cx:=$00;
   R.Dx:=$00;
   Intr($1A,R);
   If ThisDir=True Then FindFiles(Dir) Else
   If ThisDir=False Then FindFIles(Dir[1]+':');
   R.Ah:=$00;
   Intr($1A,R);
   Time:=R.Cx*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2+R.Dx;
   R.Ah:=$00;
   Intr($1A,R);
   R.Ah:=$01;
   R.Cx:=R.Cx+FirstTimerHigh;
   R.Dx:=R.Dx+FirstTimerLow;
   Intr($1A,R);
   WriteLn('Found ',BigSize(Files),' files with a total size of ',BigSize(TSize),' Bytes (',(TSize/DiskSize(0)*100):2:2,'%).');
   WriteLn('Found ',BigSize(Dirs),' directories.');
   If Paused=False Then WriteLn('Elapsed time is ',(Time/18.2):5:2,'s.');
   If Report=True Then
   Begin;
    WriteLn(FText,'Found ',BigSize(Files),' files with a total size of ',BigSize(TSize),' Bytes (',(TSize/DiskSize(0)*100):2:2,
                  '%).');
    WriteLn(FText,'Found ',BigSize(Dirs),' directories.');
    If Paused=False Then WriteLn(FText,'Elapsed time is ',(Time/18.2):5:2,'s.');
    Close(FText);
   End;
  End Else
  Begin;
   WriteLn(Info);
   WriteLn('Seeks and finds files or dirctories everywhere on your disk. Specify filename');
   WriteLn('plus extension of file/s you want find. Choose your options as you wish.');
   WriteLn('S.EXE filename.ext [/P] [/S] [/R] [/T]');
   WriteLn('                    /P  Pause after each screen');
   WriteLn('                    /S  Suppress messages');
   WriteLn('                    /R  Report to file \REPORT.SRC');
   WriteLn('                    /T  Start search from here instead of root directory.');
  End;
  WriteLn;
  ChDir(Dir);
 End.
