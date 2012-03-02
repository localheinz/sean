Program AnalyzeIconStructure;
Uses Dos,Graph,Bits,SeAnHelp;
Var X,Y : Integer;
    S   : SearchRec;
    R   : String;

Begin
 DetectGraph(X,Y);
 InitGraph(X,Y,'C:\DOS\BORLAND\BGI');
 FindFirst('*.ÿSN',AnyFile,S);
 X:=0;
 Y:=0;
 While DosError=0 Do
 Begin;
  If (S.Size)=666 Then
  Begin;
   R:=Copy(S.Name,1,Pos('.',S.Name)-1);
   PutIcon(X*26+13,Y*26+13,R);
   Inc(X);
   If (X=24) Then
   Begin;
    X:=0;
    Inc(Y);
   End;
  End;
  FindNext(S);
 End;
 ReadLn;
 CloseGraph;
End.
