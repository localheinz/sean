{$D-,A-,I-,L-,N+,E-,O-,R-,S-}
Program SeanChangeDirectory;
Uses Crt,Dos,SeAnHelp;
Const Info    = 'J.Pas written by Andreas M”ller (02ù03ù96).';
Var   DirName : DirStr;
      Found   : Boolean;
      R       : Registers;
      Drive   : String;
      Y       : Byte;

Procedure FindDir(Dir : DirStr);
Var S : SearchRec;

Begin
 FindFirst(Dir+'\*.*',$10,S);
 While (DosError=0) And (Not Found) Do
 Begin;
  If (S.Attr=$10) And (S.Name[1]<>'.') Then
  Begin;
   GoToXY(1,WhereY);
   Write(Dir+'\'+S.Name);
   ClrEol;
   If S.Name=DirName Then
   Begin;
    ChDir(Drive[1]+':\');
    ChDir(Dir+'\'+S.Name);
    Found:=True;
   End Else ChDir(Dir+'\'+S.Name);
   FindDir(Dir+'\'+S.Name);
  End;
  FindNext(S);
 End;
End;

 Begin
  R.Ah:=$19;
  MsDos(R);
  GetDir(0,Drive);
  Found:=False;
  WriteLn;
  WriteLn(Info);
  If ParamCount=0 Then
  Begin;
   WriteLn('Startup Directory       : ',Drive);
   Writeln('Flipped to Directory    : ',Drive[1]+':\');
   ChDir(Drive[1]+':\');
  End Else
  If ParamCount>0 Then
  Begin;
   If Gross(ParamStr(1))='/?' Then
   Begin;
    WriteLn('This program is supposed to help you jump faster from one directory to another.');
    WriteLn('It''ll make changing directories easier for you in so far as you''ve only got to');
    WriteLn('enter the directory name (e.g. GAMES) instead of the whole path and the program');
    WriteLn('will change right into it.');
    WriteLn('J.EXE [DirName] [/?]');
    WriteLn('       DirName  Name of the directory you want to change to');
    WriteLn('       /?       Displays this message');
   End Else
   Begin;
    DirName:=Gross(ParamStr(1));
    WriteLn('Startup Directory       : ',Drive);
    Writeln('Searching for Directory : ',DirName);
    If DirName='' Then ChDir(Drive[1]+':\') Else
    Begin;
     Found:=False;
     FindDir(Drive[1]+':');
    End;
    If Not Found Then
    Begin;
     GoToXY(1,WhereY);
     WriteLn('Could not find directory specified.');
     WriteLn('Try again . . .');
     ChDir(Drive);
    End Else
    If Found Then
    Begin;
     GoToXY(1,WhereY);
     GetDir(0,DirName);
     WriteLn('Flipped to ',DirName,'.');
    End;
   End;
  End;
 End.
