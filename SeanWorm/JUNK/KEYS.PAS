Program Keys;
Uses Crt;
Var Key : Char;

Begin
 Repeat;
  Key:=ReadKey;
  WriteLn('Key :  #',Ord(Key));
 Until Key=#27;
End.