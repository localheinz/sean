Program Test;
Uses Graph,Crt,SeAnHelp;
Var   Driver,Mode : Integer;
      X,Y,Z       : Integer;
Const TextStr     = 'This is supposed to be a little program that helped me checking out if I could do formatting text';
Type  TextType    = Record
                     WordContent : String;
                     WordLength  : Integer;
                    End;
Var   TextData  : Array[1..100] Of TextType;
      STemp     : String;



Procedure ShowText(LX,LY,RX,RY : Integer;S : String);
Var LineLength   : Integer;
    LengthOWords : Integer;
    Spacing      : Integer;
    X,Y          : Integer;
    Words : Integer;
    A,B : Integer;

Begin
 For A:=1 To 100 Do TextData[A].WordLength:=0;
 For A:=1 To 100 Do TextData[A].WordContent:='';
 LineLength:=RX-LX;
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
 LengthOWords:=0;
 A:=1;
 While (LengthOWords+TextData[A].WordLength+TextWidth(' ')<=LineLength) And (A<Words) Do
 Begin;
  Inc(LengthOWords,TextData[A].WordLength+TextWidth(' '));
  Inc(A);
 End;
 LengthOWords:=0;
 For B:=1 To Words Do Inc(LengthOWords,TextData[B].WordLength);
 Spacing:=Round((LineLength-LengthOWords)/(A-1));
 X:=LX;
 Y:=LY;
 For B:=1 To A Do
 Begin;
  OutTextXY(X,Y,TextData[B].WordContent);
  Inc(X,TextData[B].WordLength+Spacing);
 End;
End;
 

Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C:\DOS\PASCAl\BGI');
 Button(Off,0,0,640,220,'');
 ShowText(10,10,450,200,'This stupid program is supposed to show how one');
 ShowText(10,30,450,200,'can solve problems on the computer. Here, we have');
 ShowText(10,50,450,200,'the problem of formatting text in a compact form.');
 ReadLn;
 CloseGraph;
End.


{ Words:=1;
 For A:=1 To Length(S) Do
 Begin;
  If S[A]=' ' Then Inc(Words);
 End;}