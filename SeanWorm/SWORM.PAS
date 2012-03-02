{$M 30000,0,15000}
Program SeAnWorm;
Uses Crt,Graph,SeAnHelp,Maus,Dos;
Var Driver,Mode : Integer;

Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C:\DOS\BORLAND\BGI');
 Button(Off,000,000,520,020,'SEAN WORM');
 Button(Off,520,000,639,040,'');
 Button(Off,520,040,639,080,'');
 Button(Off,520,080,639,120,'');
 Button(Off,520,120,639,160,'');
 Button(Off,520,160,639,439,'');
 Button(Off,520,439,639,479,'');
{ PutIcon(540,020,'START');
 PutIcon(540,060,'OPTIONS');
 PutIcon(540,100,'STATS');
 PutIcon(540,140,'HIGH');
 PutIcon(540,459,'QUIT');}
 Area(LightGray,560,010,630,030,'START');
 Area(LightGray,560,050,630,070,'OPTIONS');
 Area(LightGray,560,090,630,110,'STATS');
 Area(LightGray,560,130,630,150,'VIEW HIGH');
 Area(LightGray,560,449,630,469,'EXIT');
 ReadLn;
End.