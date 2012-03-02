Program CleanDisk;
Uses Crt,Dos,SeAnHelp,Bits;
Type  LogDataType    = Record
                        ClndBts : LongInt;
                        ClndFls : LongInt;
                        SpentTime    : LongInt;
                        Executed     : Word;
                       End;
Var   DirName        : DirStr;
      Files          : Integer;
      Dirs           : Integer;
      Bytes          : LongInt;
      Dir            : DirStr;
      Clean          : Boolean;
      FirstTimerHigh : Word;
      FirstTimerLow  : Word;
      R              : Registers;
      Time           : LongInt;
      I              : Integer;
      LogFile        : File Of LogDataType;
      LogData        : LogDataType;
      S              : String;
      F              : Text;
Const NumOfExt       = 6;
      Extensions     : Array[1..NumOfExt] Of ExtString = ('BAK','OLD','TMP','SIK','$$$','MS');
      Info           = 'C.Pas written by Andreas M”ller (02ù03ù96)';

Function Ext(FName : FileString) : ExtString;
Var S : ExtStr;
    B : Byte;
Begin
 S:='';
 For B:=Pos('.',FName)+1 To Length(FName) Do S:=S+FName[B];
 Ext:=S;
End;

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




Procedure CleanFiles(Dir : DirStr);
Var S          : SearchRec;
    F          : File;
    Attr       : Word;
    CurrentExt : ExtString;
    Key        : Char;
Begin
 FindFirst(Dir+'\*.*',AnyFile,S);
 While (DosError=0) Do
 Begin;
  If ((S.Attr<>$10) And (Odd(S.Attr And 1)=False)) Then
  Begin;
   CurrentExt:=Ext(S.Name);
   For I:=1 To NumOfExt Do
   Begin;
    If CurrentExt=Extensions[I] Then
    Begin;
     Inc(Files);
     Write('Wiping ',ModName(Dir+'\'+S.Name),' (',BigSize(S.Size),' Bytes)...');
     Assign(F,S.Name);
     Erase(F);
     Inc(Bytes,S.Size);
     WriteLn('Ok.');
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
   Inc(Dirs);
   ChDir(Dir+'\'+S.Name);
   CleanFiles(Dir+'\'+S.Name);
  End;
  FindNext(S);
 End;
End;

Function DoTime (HTime : LongInt) : String;
Var Hours, Minutes : Byte;
    Seconds        : Real;
    S,D            : String;
Begin
 Hours  :=Trunc(HTime/(18.2*3600));
 Minutes:=Trunc((HTime-Hours*18.2*3600)/(18.2*60));
 Seconds:=(HTime-Hours*18.2*3600-Minutes*18.2*60)/18.2;
 D:='';
 If Hours>0 Then
 Begin;
  Str(Hours,S);
  D:=S+':';
 End;
 If Minutes>0 Then
 Begin;
  Str(Minutes,S);
  If Hours>0 Then While Length(S)<2 Do S:='0'+S;
  D:=D+S+':';
 End;
 If Seconds>=0 Then
 Begin;
  Str(Seconds:3:1,S);
  If (Hours>0) Or (Minutes>0) Then While Length(S)<3 Do S:='0'+S;
  D:=D+S;
 End;
 If Hours>0 Then D:=D+'h';
 If (Hours=0) And (Minutes>0) Then D:=D+'m';
 If (Hours=0) And (Minutes=0) Then D:=D+'s';
 DoTime:=D;
End;

 Begin
  If ParamCount>0 Then
  Begin;
   S:=Gross(ParamStr(1));
   If S='/S' Then
   Begin;
    WriteLn;
    WriteLn(Info);
    If Not Exist('C:\DOS\CLEANDAT.LOG') Then WriteLn('No Log File available.') Else
    Begin;
     Assign(LogFile,'C:\DOS\CLEANDAT.LOG');
     ReSet(LogFile);
     Read(LogFile,LogData);
     Close(LogFile);
     Write('This program has been executed ');
     If LogData.Executed=1 Then WriteLn('once.') Else
     If LogData.Executed=2 Then WriteLn('twice.') Else WriteLn(BigSize(LogData.Executed),' times.');
     WriteLn('Wiping ',BigSize(LogData.ClndFls),' files, it has released a total of ',BigSize(LogData.ClndBts),' Bytes.');
     WriteLn('This has taken your computer a time of ',DoTime(LogData.SpentTime),'.');
    End;
    WriteLn;
   End Else
   If S='/R' Then
   Begin;
    Assign(F,'\REPORT.CLN');
    ReWrite(F);
    WriteLn(F,Info);
    If Not Exist('C:\DOS\CLEANDAT.LOG') Then WriteLn('No Log File available.') Else
    Begin;
     Assign(LogFile,'C:\DOS\CLEANDAT.LOG');
     ReSet(LogFile);
     Read(LogFile,LogData);
     Close(LogFile);
     Write(F,'This program has been executed ');
     If LogData.Executed=1 Then WriteLn(F,'once.') Else
     If LogData.Executed=2 Then WriteLn(F,'twice.') Else WriteLn(F,BigSize(LogData.Executed),' times.');
     WriteLn(F,'Wiping ',BigSize(LogData.ClndFls),' files, it has released a total of ',BigSize(LogData.ClndBts),' Bytes.');
     WriteLn(F,'This has taken your computer a time of ',DoTime(LogData.SpentTime),'.');
     Close(F);
    End;
   End Else
   If S='/?' Then
   Begin;
    WriteLn;
    WriteLn(Info);
    WriteLn('This program is designated to get your disk rid of unneeded and useless files.');
    WriteLn('Files having an extension like BAK, OLD, TMP, SIK, $$$, MS, that is. Just exe-');
    WriteLn('cute C.EXE without any parameters, and you will easily be freed of those annoy-');
    WriteLn('oing and space sucking files.');
    WriteLn('C.EXE [/R] [/S] [/?]');
    WriteLn('       /R  Creates \REPORT.CLN with contents of CLEANDAT.LOG');
    WriteLn('       /S  Shows Contents of CLEANDAT.LOG on screen');
    WriteLn('       /?  Displays this message');
    WriteLn;
   End;
  End Else
  Begin;
   Files:=0;
   Dirs:=0;
   Bytes:=0;
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
   WriteLn;
   WriteLn(Info);
   WriteLn('Searching for files...');
   CleanFiles(Dir[1]+':');
   R.Ah:=$00;
   Intr($1A,R);
   Time:=R.Cx*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2+R.Dx;
   R.Ah:=$00;
   Intr($1A,R);
   R.Ah:=$01;
   R.Cx:=R.Cx+FirstTimerHigh;
   R.Dx:=R.Dx+FirstTimerLow;
   Intr($1A,R);
   If Files>1 Then WriteLn('Cleaned ',BigSize(Files),' files and released ',BigSize(Bytes),' bytes of diskspace.') Else
   If Files=1 Then WriteLn('Cleaned only one file and released ',BigSize(Bytes),' bytes of diskspace.') Else
   If Files=0 Then
   Begin;
    GoToXY(23,WhereY-1);
    WriteLn('Could not find any.');
   End;
   WriteLn('Elapsed time is ',(Time/18.2):4:2,'s.');
   ChDir(Dir);
   WriteLn;
   If Files>0 Then
   Begin;
    If Exist('C:\DOS\CLEANDAT.LOG') Then
    Begin;
     Assign(LogFile,'C:\DOS\CLEANDAT.LOG');
     ReSet(LogFile);
     Read(LogFile,LogData);
     Close(LogFile);
     Assign(LogFile,'C:\DOS\CLEANDAT.LOG');
     ReWrite(LogFile);
     LogData.ClndBts:=LogData.ClndBts+Bytes;
     LogData.ClndFls:=LogData.ClndFls+Files;
     LogData.SpentTime:=LogData.SpentTime+Time;
     LogData.ExeCuted:=LogData.Executed+1;
     Write(LogFile,LogData);
     Close(LogFile);
    End Else
    Begin;
     Assign(LogFile,'C:\DOS\CLEANDAT.LOG');
     ReWrite(LogFile);
     LogData.ClndBts:=Bytes;
     LogData.ClndFls:=Files;
     LogData.SpentTime:=Time;
     LogData.Executed:=1;
     Write(LogFile,LogData);
     Close(LogFile);
    End;
   End;
  End;
 End.
