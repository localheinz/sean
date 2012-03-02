Program ReSet;
Uses Dos,Crt,SeAnHelp;
Var R : Registers;


Begin
 MemW[$0000:$0472]:=$0000;
 Intr($15,R);
End.
