Program Test;
Uses Graph,Crt,SeAnHelp;
Var   Driver,Mode : Integer;
      X,Y,Z       : Integer;




Procedure ShowText(LX,LY,RX,RY : Integer;S : String);
Type  TextType    = Record
                     WordContent : String;
                     WordLength  : Integer;
                     Line        : Byte;
                    End;
      SpacingType = Record
                     WordsInLine : Integer;
                    End;
Var   TextData     : Array[1..40] Of TextType;
      Spacing      : Array[1..40] Of SpacingType;
      TextSpacing  : Integer;
      STemp        : String;
      LineLength   : Integer;
      LengthOWords : Array[1..40] Of Integer;
      LengthOLine  : Array[1..40] Of Integer;
      X,Y,Z        : Integer;
      Words        : Integer;
      Lines        : Integer;
      A,B          : Integer;
      Diff         : Real;
      WordsTemp    : Integer;
      SpacingInLine : Real;
      ATemp,BTemp   : Integer;
Begin
 Words:=0;
 Lines:=1;
 LineLength:=RX-LX;
 For A:=1 To 40 Do
 Begin;
  TextData[A].WordLength:=0;
  TextData[A].WordContent:='';
  TextData[A].Line:=1;
  Spacing[A].WordsInLine:=0;
  LengthOWords[A]:=0;
  LengthOLine[A]:=0;
 End;
 S:=S+' ';
 While Pos('  ',S)<>0 Do
 Begin;
  Delete(S,Pos('  ',S)-1,1);
 End;
 Words:=0;
 While Length(S)>0 Do
 Begin;
  STemp:='';
  For A:=1 To Pos(' ',S) Do
  Begin;
   If S[A]<>' ' Then STemp:=STemp+S[A];
  End;
  Inc(Words);
  TextData[Words].WordContent:=STemp;
  TextData[Words].WordLength:=TextWidth(STemp);
  Delete(S,1,Length(STemp)+1);
 End;
 WordsTemp:=Words;
 A:=0;
 While WordsTemp>1 Do
 Begin;
  ATemp:=A+1;
  While (LengthOLine[Lines]+TextData[A].WordLength+TextWidth(' ')<=LineLength) And (A<Words) Do
  Begin;
   Inc(LengthOLine[Lines],TextData[A].WordLength+TextWidth(' '));
   Inc(A);
   Dec(WordsTemp);
  End;
  LengthOLine[Lines]:=0;
  For B:=ATemp To A Do Inc(LengthOLine[Lines],TextData[B].WordLength);
  Spacing[Lines].WordsInLine:=A-ATemp;
  If A<Words Then Inc(Lines);
 End;
 TextSpacing:=Round((RY-LY)/Lines);
 X:=LX;
 Y:=LY;
 B:=0;
 For A:=1 To Lines Do
 Begin;
  If A<Lines Then SpacingInLine:=(LineLength-LengthOLine[A])/(Spacing[A].WordsInLine) Else SpacingInLine:=TextWidth(' ');
  BTemp:=B+1;
  For B:=BTemp To Spacing[A].WordsInLine+BTemp Do
  Begin;
   OutTextXY(X,Y,TextData[B].WordContent);
   Inc(X,Round(TextData[B].WordLength+SpacingInLine));
  End;
  X:=LX;
  Inc(Y,TextSpacing);
 End;
End;


Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C:\DOS\PASCAl\BGI');
 Button(Off,0,0,640,220,'');

 ShowText(10,10,317,100,'This program is really stupid, so do not worry if you do not understand what''s going on '+
                        'or whatever else. But do not complain.');
 Line(317,10,317,100);
   
 ReadLn;
 CloseGraph;
End.


