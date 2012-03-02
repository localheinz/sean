{ Checks out type of and time of system starts. Written by Andreas M”ller}
Program LastBoot;
Uses Dos,SeAnHelp;
Type  LogType = Record
                 BootType  : Boolean;
                 Time      : LongInt;
                End;
Const Info    = 'L.PAS written by Andreas M”ller (02ù03ù96)';
      Warm    = True;
      Hard    = False;
      DoneYet : Boolean = False;
      Months  : Array[1..12] Of String[3] = ('Jan',
                                            'Feb',
                                            'Mar',
                                            'Apr',
                                            'May',
                                            'Jun',
                                            'Jul',
                                            'Aug',
                                            'Sep',
                                            'Oct',
                                            'Nov',
                                            'Dec');
Var   LogFile : Text;
      LogData : LogType;
      Report  : Boolean;
      F       : Text;
      S       : String;

Function BootType : Boolean;
Begin
 Case MemW[$0000:$0472] Of
  $0000: BootType:=Hard;
    Else BootType:=Warm;
 End;
End;

Procedure WriteLogData;
Var B : Byte;
Begin
 GetFTime(OutPut,LogData.Time);
 LogData.BootType:=BootType;
 Assign(LogFile,'C:\DOS\LASTBOOT.LOG');
 If Not Exist('C:\DOS\LASTBOOT.LOG') Then ReWrite(LogFile) Else Append(LogFile);
 For B:=0 To SizeOf(LogData)-1 Do Write(LogFile,Chr(Mem[Seg(LogData):Ofs(LogData)+B]));
 Close(LogFile);
End;


Function BootTime(LogTData : LogType) : String;
Var STime  : DateTime;
    Time,S : String;
    Pm     : Boolean;
Begin
 UnPackTime(LogTData.Time,STime);
 If LogTData.BootType=Warm Then Time:='Warm Boot on ' Else Time:='Hard Boot on ';
 Str(STime.Day,S);
 If STime.Day<10 Then Time:=Time+'0'+S Else Time:=Time+S;
 Time:=Time+' '+Months[STime.Month]+' ';
 Str(STime.Year,S);
 While Length(S)<2 Do S:='0'+S;
 Time:=Time+S+', at ';
 Str(STime.Hour,S);
 While Length(S)<2 Do S:='0'+S;
 Time:=Time+S+':';
 Str(STime.Min,S);
 While Length(S)<2 Do S:='0'+S;
 Time:=Time+S+':';
 Str(STime.Sec,S);
 While Length(S)<2 Do S:='0'+S;
 Time:=Time+S+'.';
 BootTime:=Time;
End;


Procedure ShowLogData;
Var LogFile : File;
    Count   : Word;
    Result  : Word;
    Counter : Word;
Begin
 If Exist('C:\DOS\LASTBOOT.LOG') Then
 Begin;
  Assign(LogFile,'C:\DOS\LASTBOOT.LOG');
  ReSet(LogFile,5);
  If Report=False Then
  Begin;
   WriteLn;
   WriteLn(Info);
   Counter:=0;
   Count:=1;
   While Not Eof(LogFile) Do
   Begin;
    BlockRead(LogFile,LogData,Count,Result);
    WriteLn(BootTime(LogData));
    Inc(Counter);
   End;
   WriteLn('Total number of boots: ',Counter);
  End Else If Report=True Then
  Begin;
   Assign(F,'\REPORT.LOG');
   ReWrite(F);
   WriteLn(F,Info);
   Counter:=0;
   Count:=1;
   While Not Eof(LogFile) Do
   Begin;
    BlockRead(LogFile,LogData,Count,Result);
    WriteLn(F,BootTime(LogData));
    Inc(Counter);
   End;
   WriteLn(F,'Total number of boots: ',Counter);
   Close(F);
  End;
 End Else
 Begin;
  WriteLn;
  WriteLn(Info);
  WriteLn('No Log file available.');
  WriteLn;
 End;
End;


Begin
 If ParamCount>0 Then
 Begin;
  S:=Gross(ParamStr(1));
  If (S[1]='/') And (S[2] In ['S','R']) Then
  Begin;
   Report:=S[2]='R';
   ShowLogData;
  End Else If (S='/?') Then
  Begin;
   WriteLn;
   WriteLn(Info);
   WriteLn('This program is meant to help you keep track of when your computer has been');
   WriteLn('used. It saves a couple of things about when and how your computer was started.');
   WriteLn('However, it can not protect your system from being worked on by people who use');
   WriteLn('a boot disk to avoid being stopped by L.EXE or other fine utils.');
   WriteLn('L.EXE [/R] [/S] [/?]');
   WriteLn('       /R  Creates \REPORT.LOG with contents of LASTBOOT.LOG');
   WriteLn('       /S  Shows Contents of LASTBOOT.LOG on screen');
   WriteLn('       /?  Displays this message');
  End;
 End Else
 Begin;
  DoneYet:=GetEnv('DONE')='YES';
  If Not DoneYet Then WriteLogData;
 End;
End.

