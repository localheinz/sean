Uses Graph,Maus,SeAnHelp;
Var X,Y : Integer;
Const NONAME : Array[1..2,1..16] Of Word = (($0000,$7FFE,$7FFE,$6006,
                                             $6006,$6006,$6006,$6006,
                                             $6006,$6006,$6006,$6006,
                                             $6006,$7FFE,$7FFE,$0000),
                                            ($0000,$0000,$0000,$0000,
                                             $0000,$0000,$0000,$0000,
                                             $0000,$0000,$0000,$0000,
                                             $0000,$0000,$0000,$0000));

Begin
 InitGraph(X,Y,'C:\DOS\BORLAND\BGI');
 If Ms_Init(X) Then Ms_Show;
 Button(Off,100,100,300,200,'OPOA');
 Ms_Set_GRaphPointer(0,0,@Noname);
 ReadLn;
 CloseGraph;
End.
