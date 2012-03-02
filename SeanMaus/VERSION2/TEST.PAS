Program Test;
Uses SeAnHelp,Maus,Graph;
Const TEST1 : Array[1..2,1..16] Of Word = (($0000,$0000,$0000,$0000,
                                            $0000,$0600,$0600,$0000,
                                            $0000,$0000,$0000,$0000,
                                            $0000,$0000,$0000,$0000),
                                           ($0000,$0000,$3FC0,$3FC0,
                                            $30C0,$30C0,$30C0,$30C0,
                                            $3FC0,$3FC0,$30C0,$30C0,
                                            $30C0,$30C0,$0000,$0000));
Const TEST2 : Array[1..2,1..16] Of Word = (($003F,$003F,$3F3F,$3F3F,
                                            $3F3F,$3F3F,$3F3F,$003F,
                                            $3F3F,$3F3F,$3F3F,$3F3F,
                                            $3F3F,$003F,$003F,$FFFF),
                                           ($0000,$7F80,$7F80,$7F80,
                                            $7F80,$7F80,$7F80,$7F80,
                                            $4080,$4080,$4080,$4080,
                                            $4080,$7F80,$0000,$0000));

Begin
 GraphMode(Driver,Mode);
 Button(Off,000,000,639,479,'');
 Button(Off,100,100,200,200,'');
 If Ms_Init(MButtons) Then Ms_Show;
 Ms_Set_GraphPointer(0,0,@Test2);
 ReadLn;
End.