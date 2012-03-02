
unit mcga;

interface
uses dos;
const xmax=319;
      ymax=199;
      farbmax=255;
var   winx1,winx2,winy1,winy2,
      winxmax,winymax,
      segwert,faktor,
      grapherror256,
      zwei,vier,
      dummy1,dummy2,dummy3,dummy4:word;
      oldmode:byte;
	 procedure initgraph256(palette:word);
	 procedure closegraph256;
	 procedure bar256(x1,y1,x2,y2:word;farbe:byte);
	 procedure linie256(x1,y1,x2,y2:word;farbe:byte);
	 procedure setwindow256(x1,y1,x2,y2:word);
	 procedure setup_palette256;
	 procedure setup_palette2_256;
	 procedure getmode(var mode:byte);
	 procedure setmode(mode:word);
	 procedure putpixel256(x,y:word;farbe:byte);
	 procedure setpal(n:word;rot,gruen,blau:byte);
	 procedure putimage256(x1,y1,image256seg:word);
	 procedure getimage256(var image256seg:word;x1,y1,x2,y2:word);
	 procedure disposemem(segmentwert:word);
	 procedure getimage256_disk(dateiname:string;x1,y1,x2,y2:word);
	 procedure putimage256_disk(x1,y1:word;dateiname:string);
	 procedure getimage256_PCX_disk(dateiname:string;x1,y1,x2,y2:word);
	 procedure putimage256_PCX_disk(x1,y1:word;dateiname:string);
	 procedure getimage256_IFF_disk(dateiname:string;x1,y1,x2,y2:word);
	 procedure putimage256_IFF_disk(x1,y1:word;dateiname:string);
         procedure getimage256_BMP_disk(dateiname:string;x1,y1,x2,y2:word);
	 procedure putimage256_BMP_disk(x1,y1:word;dateiname:string);


implementation

procedure bar256(x1,y1,x2,y2:word;farbe:byte);
begin
asm
   mov es,segwert
   mov ax,y1
   add ax,winy1
   mov bx,y2
   add bx,winy1
   mov cx,x1
   add cx,winx1
   mov dx,x2
   add dx,winx1
   cmp ax,bx
   jbe @bar256_weiter1
    xchg ax,bx
  @bar256_weiter1:
   cmp cx,dx
   jbe @bar256_weiter2
    xchg cx,dx
  @bar256_weiter2:
   cmp bx,winy2
   jbe @bar256_weiter3
    mov bx,winy2
  @bar256_weiter3:
   cmp dx,winx2
   jbe @bar256_weiter4
    mov dx,winx2
  @bar256_weiter4:
   cmp ax,winy2
   jb @bar256_weiter5
    mov ax,winy2
  @bar256_weiter5:
   cmp cx,winx2
   jb @bar256_weiter6
    mov cx,winx2
  @bar256_weiter6:
   mov si,cx
   sub dx,cx
   inc dx
   sub bx,ax
   inc bx
   xchg dx,bx
   xchg bx,cx
   push cx
   push dx
   mov cx,si
   mul faktor
   add ax,cx
   mov si,ax
   mov bl,farbe
   cmp bl,farbmax
   pop dx
   pop cx
   ja @bar256_ende
  @bar256_schleife1:
    push si
    push cx
    mov cx,dx
   @bar256_schleife2:
     mov es:[si],bl
     add si,faktor
     loop @bar256_schleife2
    pop cx
    pop si
    inc si
    loop @bar256_schleife1
  @bar256_ende:
end;
end;

procedure linie256(x1,y1,x2,y2:word;farbe:byte);
var x,y,x1neu,x2neu,y1neu,y2neu,
    dummy,dummy1,dummy2,
    xlaenge,ylaenge:word;
    anstieg:byte;
begin
asm
    mov es,segwert
    xor si,si
    mov ax,y1
    add ax,winy1
    mov bx,y2
    add bx,winy1
    mov cx,x1
    add cx,winx1
    mov dx,x2
    add dx,winx1
    cmp bx,winy2
    jbe @linie256_vergleich1_weiter1
     mov bx,winy2
   @linie256_vergleich1_weiter1:
    cmp dx,winx2
    jbe @linie256_vergleich1_weiter2
     mov dx,winx2
   @linie256_vergleich1_weiter2:
    cmp ax,winy2
    jb @linie256_vergleich1_weiter3
     mov ax,winy2
   @linie256_vergleich1_weiter3:
    cmp cx,winx2
    jb @linie256_vergleich1_weiter4
     mov cx,winx2
   @linie256_vergleich1_weiter4:
    cmp ax,bx
    jbe @linie256_vergleich1
     xchg ax,bx
     xchg cx,dx
   @linie256_vergleich1:
    mov x1neu,cx
    mov x2neu,dx
    mov y1neu,ax
    mov y2neu,bx
    ja @linie256_vergleich2
    jb @linie256_vergleich2
     jmp @linie256_waagerecht
   @linie256_vergleich2:
    cmp cx,dx
    jb @linie256_vergleich3
    je @linie256_vergleich4
   @linie256_vergleich5:
    jmp @linie256_fallend
   @linie256_vergleich4:
    jmp @linie256_senkrecht
   @linie256_vergleich3:
     jmp @linie256_steigend

 @linie256_senkrecht:
    @linie256_senkrecht_weiter1:
     mov cx,bx
     sub cx,ax
     mul faktor
     add ax,x2neu
     mov si,ax
     mov bl,farbe
    @linie256_senkrecht_schleife1:
      mov es:[si],bl
      add si,faktor
     loop @linie256_senkrecht_schleife1
     jmp @linie256_line_ende

 @linie256_waagerecht:
     cmp cx,dx
     jbe @linie256_waagerecht_weiter1
      xchg cx,dx
    @linie256_waagerecht_weiter1:
     push cx
     push dx
     cmp ax,bx
     jb @linie256_waagerecht_weiter2
      xchg ax,bx
    @linie256_waagerecht_weiter2:
     mul faktor
     add ax,cx
     mov si,ax
     pop dx
     pop cx
     sub dx,cx
     xchg dx,cx
     inc cx
     cmp cx,0
     ja @linie256_waagerecht_weiter3
      inc cx
    @linie256_waagerecht_weiter3:
     mov bl,farbe
    @linie256_waagerecht_schleife1:
      mov es:[si],bl
      inc si
     loop @linie256_waagerecht_schleife1
     jmp @linie256_line_ende

 @linie256_fallend:
     mov ax,y1neu
     mov bx,y2neu
     mov dx,x1neu
     mov cx,x2neu
     sub bx,ax
     sub dx,cx
     mov ylaenge,bx
     mov xlaenge,dx
     mov cx,1
     mov ax,ylaenge
     mul cx
     div xlaenge
     cmp ax,1
     jb @linie256_fallend_anstieg0
     jae @linie256_fallend_anstieg1
    @linie256_fallend_anstieg0:
      mov ax,0
      mov x,ax
      mov cl,farbe
     @linie256_fallend_anstieg0_schleife1:
      mov ax,x
      mul ylaenge
      div xlaenge
      mov y,ax
      mov bx,x1neu
      sub bx,x
      cmp bx,x2neu
      jb @linie256_line_ende
      mov ax,y1neu
      add ax,y
      cmp ax,y2neu
      ja @linie256_line_ende
      mov es,segwert
      mul faktor
      add ax,bx
      mov si,ax
      mov es:[si],cl
      inc x
      jmp @linie256_fallend_anstieg0_schleife1
    @linie256_fallend_anstieg1:
      mov ax,0
      mov y,ax
      mov cl,farbe
     @linie256_fallend_anstieg1_schleife1:
       mov ax,y
       mul xlaenge
       div ylaenge
       mov x,ax
       mov bx,x1neu
       sub bx,x
       cmp bx,x2neu
       jb @linie256_line_ende
       mov ax,y1neu
       add ax,y
       cmp ax,y2neu
       ja @linie256_line_ende
       mov es,segwert
       mul faktor
       add ax,bx
       mov si,ax
       mov es:[si],cl
       inc y
       jmp @linie256_fallend_anstieg1_schleife1
     jmp @linie256_line_ende

 @linie256_steigend:
     mov ax,y1neu
     mov bx,y2neu
     mov cx,x1neu
     mov dx,x2neu
     sub bx,ax
     sub dx,cx
     mov ylaenge,bx
     mov xlaenge,dx
     mov cx,1
     mov ax,ylaenge
     mul cx
     div xlaenge
     cmp ax,1
     jb @linie256_steigend_anstieg0
     jae @linie256_steigend_anstieg1
    @linie256_steigend_anstieg0:
      mov ax,0
      mov x,ax
      mov cl,farbe
     @linie256_steigend_anstieg0_schleife1:
      mov ax,x
      mul ylaenge
      div xlaenge
      mov y,ax
      mov bx,x1neu
      add bx,x
      cmp bx,x2neu
      ja @linie256_line_ende
      mov ax,y1neu
      add ax,y
      cmp ax,y2neu
      ja @linie256_line_ende
      mov es,segwert
      mul faktor
      add ax,bx
      mov si,ax
      mov es:[si],cl
      inc x
      jmp @linie256_steigend_anstieg0_schleife1
    @linie256_steigend_anstieg1:
      mov ax,0
      mov y,ax
      mov cl,farbe
     @linie256_steigend_anstieg1_schleife1:
       mov ax,y
       mul xlaenge
       div ylaenge
       mov x,ax
       mov bx,x1neu
       add bx,x
       cmp bx,x2neu
       ja @linie256_line_ende
       mov ax,y1neu
       add ax,y
       cmp ax,y2neu
       ja @linie256_line_ende
       mov es,segwert
       mul faktor
       add ax,bx
       mov si,ax
       mov es:[si],cl
       inc y
       jmp @linie256_steigend_anstieg1_schleife1

 @linie256_line_ende:

end;
end;

procedure setwindow256(x1,y1,x2,y2:word);
begin
asm
   mov ax,x1
   mov bx,x2
   mov cx,y1
   mov dx,y2
   cmp ax,bx
   jb @setwindow256_weiter1
    xchg ax,bx
  @setwindow256_weiter1:
   cmp cx,dx
   jb @setwindow256_weiter2
    xchg cx,dx
  @setwindow256_weiter2:
   cmp ax,xmax
   jbe @setwindow256_weiter3
    mov ax,1
  @setwindow256_weiter3:
   cmp ax,0
   ja @setwindow256_weiter4
    mov ax,1
  @setwindow256_weiter4:
   cmp bx,xmax
   jbe @setwindow256_weiter5
    mov bx,xmax
  @setwindow256_weiter5:
   cmp bx,0
   ja @setwindow256_weiter6
    mov bx,xmax
  @setwindow256_weiter6:
   cmp cx,ymax
   jbe @setwindow256_weiter7
    mov cx,1
  @setwindow256_weiter7:
   cmp cx,0
   ja @setwindow256_weiter8
    mov cx,1
  @setwindow256_weiter8:
   cmp dx,xmax
   jbe @setwindow256_weiter9
    mov dx,ymax
  @setwindow256_weiter9:
   cmp dx,0
   ja @setwindow256_weiter10
    mov dx,ymax
  @setwindow256_weiter10:
   mov winx1,ax
   mov winx2,bx
   mov winy1,cx
   mov winy2,dx
   sub bx,ax
   inc bx
   mov winxmax,bx
   sub dx,cx
   inc bx
   mov winymax,dx
end;
end;

procedure setup_palette2_256;
var rot,gruen,blau,fak:integer;
    i,a:integer;
begin
blau:=0;gruen:=0;rot:=0;a:=0;fak:=2;
for i:=1 to 255 do
 begin
 a:=a+1;
 if a>32 then a:=1;
 if i<224 then
  begin
  if i<192 then
   begin
   if i<160 then
    begin
    if i<128 then
     begin
     if i<96 then
      begin
      if i<64 then
       begin
       if i<32 then
	begin
	blau:=blau+fak;
	end
       end
	      else
       begin
       gruen:=gruen+fak;
       blau:=blau-fak;
       end;
      end
	     else
      begin
      gruen:=gruen;
      blau:=blau+fak;
      end;
     end
	    else
     begin
     blau:=blau-fak;
     gruen:=gruen-fak;
     rot:=rot+fak;
     end;
    end
	   else
    begin
    rot:=rot;
    blau:=blau+fak;
    end;
   end
	  else
   begin
   rot:=rot;
   gruen:=gruen+fak;
   blau:=blau-fak;
   end;
  end
	 else
  begin
  rot:=rot;
  gruen:=gruen;
  blau:=blau+fak;
  end;
 if rot<0 then rot:=0;
 if blau<0 then blau:=0;
 if gruen<0 then gruen:=0;
 if blau>63 then blau:=63;
 if gruen>63 then gruen:=63;
 if rot>63 then rot:=63;
 setpal(i,rot,gruen,blau);
 end;
end;

procedure setup_palette256;
var blau,gruen,rot:byte;
begin
asm
   xor bx,bx
   mov al,0
   mov blau,al
   mov gruen,al
   mov rot,al
   mov cx,255
   mov ax,1010h
   inc bx
  @setup_palette256_schleife1:
    push cx
    mov ch,gruen
    mov cl,blau
    mov dh,rot
    int 10h
    pop cx
    cmp bx,64
    jb @setup_palette256_weiter1
    cmp bx,127
    jb @setup_palette256_weiter2
    cmp bx,190
    jb @setup_palette256_weiter3
    dec rot
    cmp bx,253
    jae @setup_palette256_weiter5
    jmp @setup_palette256_weiter4
   @setup_palette256_weiter1:
    inc blau
    jmp @setup_palette256_weiter4
   @setup_palette256_weiter2:
    inc gruen
    dec blau
    jmp @setup_palette256_weiter4
   @setup_palette256_weiter3:
    inc rot
    dec gruen
    jmp @setup_palette256_weiter4
   @setup_palette256_weiter5:
    mov rot,0
   @setup_palette256_weiter4:
    inc bx
   loop @setup_palette256_schleife1
end;
end;

procedure getmode(var mode:byte);
var dum:byte;
begin
asm
    mov ax,0f00h
    int 10h
    mov dum,al
end;
mode:=dum;
end;

procedure setmode(mode:word);
begin
asm
    mov ax,mode
    int 10h
end;
end;

procedure putpixel256(x,y:word;farbe:byte);
begin
asm
     mov ax,y
     add ax,winy1
     mov bx,x
     add bx,winx1
     cmp ax,winy2
     ja @putpixel256_ende
     cmp bx,winx2
     ja @putpixel256_ende
     mov es,segwert
     mul faktor
     add ax,bx
     mov si,ax
     mov al,farbe
     mov es:[si],al
    @putpixel256_ende:
end;
end;

procedure setpal(n:word;rot,gruen,blau:byte);
begin
asm
    mov ax,1010h
    mov bx,n
    mov ch,gruen
    mov cl,blau
    mov dh,rot
    int 10h
end;
end;

procedure initgraph256(palette:word);
begin
segwert:=$A000;faktor:=320;
zwei:=2;vier:=4;
getmode(oldmode);
setmode($13);
setwindow256(1,1,xmax,ymax);
case palette of
 1: setup_palette256;
 2: setup_palette2_256;
 else setup_palette256;
 end;
end;

procedure closegraph256;
begin
setmode(oldmode);
end;

procedure getimage256(var image256seg:word;x1,y1,x2,y2:word);
var imageseg,imageoffs,vgaoffs:word;
begin
asm
   mov ax,y1
   add ax,winy1
   mov bx,y2
   add bx,winy1
   mov cx,x1
   add cx,winx1
   mov dx,x2
   add dx,winx1
   cmp ax,bx
   jb @getimage256_weiter1
    xchg ax,bx
  @getimage256_weiter1:
   cmp cx,dx
   jb @getimage256_weiter2
    xchg cx,dx
  @getimage256_weiter2:
   cmp bx,winy2
   ja @getimage256_ende
   cmp dx,winx2
   ja @getimage256_ende
   push ax
   push bx
   push cx
   push dx
   sub bx,ax
   sub dx,cx
   xchg ax,bx
   mov bx,dx
   mul faktor
   {
   div zwei
   }
   add ax,bx
   add ax,vier
   mov bx,ax
   mov ah,48h
   int 21
{   jc @getimage256_ende}
   mov imageseg,ax
   pop dx
   pop cx
   pop bx
   pop ax
   sub bx,ax
   inc bx
   sub dx,cx
   inc dx
   mov es,imageseg
   mov si,0
   mov es:[si],bx
   mov si,2
   mov es:[si],dx
   push bx
   push dx
   mul faktor
   add ax,cx
   mov vgaoffs,ax
   pop dx
   pop bx
   mov cx,bx
   mov imageoffs,4
   mov bx,vgaoffs
  @getimage256_schleife1:
    push cx
    mov cx,dx
    mov vgaoffs,bx
   @getimage256_schleife2:
     mov es,segwert
     mov si,vgaoffs
     mov ah,es:[si]
     inc vgaoffs
     mov es,imageseg
     mov si,imageoffs
     mov es:[si],ah
     inc imageoffs
    loop @getimage256_schleife2
    add bx,faktor   
    pop cx
   loop @getimage256_schleife1
  @getimage256_ende:
end;
image256seg:=imageseg;
end;

procedure putimage256(x1,y1,image256seg:word);
var imageseg,imageoffs,vgaoffs:word;
begin
imageseg:=image256seg;
asm
   mov ax,y1
   add ax,winy1
   mov bx,x1
   add bx,winx1
   mov es,imageseg
   mov si,0
   mov cx,es:[si]
   mov si,2
   mov dx,es:[si]
   push cx
   push dx
   push ax
   push bx
   add ax,cx
   add bx,dx
   cmp ax,winy2
   ja @putimage256_ende
   cmp bx,winx2
   ja @putimage256_ende
   pop bx
   pop ax
   mul faktor
   add ax,bx
   mov vgaoffs,ax
   mov imageoffs,4
   mov bx,ax
   pop dx
   pop cx
  @putimage256_schleife1:
    push cx
    mov cx,dx
    mov vgaoffs,bx
   @putimage256_schleife2:
     mov es,imageseg
     mov si,imageoffs
     mov ah,es:[si]
     inc imageoffs
     mov es,segwert
     mov si,vgaoffs
     mov es:[si],ah
     inc vgaoffs
    loop @putimage256_schleife2
    add bx,faktor   
    pop cx
   loop @putimage256_schleife1
  @putimage256_ende:
end;
end;


procedure disposemem(segmentwert:word);
begin
asm
   mov ah,49h
   mov es,segmentwert
   int 21
end;
end;

procedure getimage256_disk(dateiname:string;x1,y1,x2,y2:word);
var datei:file;
    dirinfo:searchrec;
    datpos:longint;
    offswert,yoffs,farbindex:word;
    farbwert:array[1..320] of word;
    farbe:byte;
label ende;
begin
findfirst(dateiname,$3f,dirinfo);
assign(datei,dateiname);
rewrite(datei);
if doserror=0 then
 begin
 if x2<x1 then
  begin
  dummy1:=x1;x1:=x2;x2:=dummy1
  end;
 if y2<y1 then
  begin
  dummy1:=y1;y1:=y2;y2:=dummy1
  end;
 if y2>winymax then
  begin
  grapherror256:=2;
  goto ende;
  end;
 if x2>winxmax then
  begin
  grapherror256:=1;
  goto ende;
  end;
 dummy1:=x2-x1+1;
 dummy2:=y2-y1+1;
 datpos:=1;
 seek(datei,datpos);
 blockwrite(datei,dummy1,1);
 inc(datpos);
 seek(datei,datpos);
 blockwrite(datei,dummy2,1);
 yoffs:=(y1*faktor)+x1;
 for dummy3:=1 to dummy1 do
  begin
  offswert:=yoffs;
  farbindex:=1;
  for dummy4:=1 to dummy2 do
   begin
   farbe:=mem[segwert:offswert];
   farbwert[farbindex]:=farbe;
   inc(offswert);
   inc(farbindex);
   end;
  inc(datpos);
  seek(datei,datpos);
  blockwrite(datei,farbwert,dummy2);
  datpos:=datpos+dummy2;
  yoffs:=yoffs+faktor;
  end;
 close(datei);
 if doserror<>0 then grapherror256:=3;
 end;
ende:
end;

procedure putimage256_disk(x1,y1:word;dateiname:string);
var datei:file;
    dirinfo:searchrec;
    datpos:longint;
    offswert,yoffs,x2,y2,farbindex:word;
    farbwert:array[1..320] of word;
    farbe:byte;
label ende;
begin
findfirst(dateiname,$3f,dirinfo);
if doserror<>0 then
 begin
 grapherror256:=3;
 goto ende;
 end;
assign(datei,dateiname);
reset(datei);
if doserror=0 then
 begin
 datpos:=1;
 seek(datei,datpos);
 blockread(datei,dummy1,1);
 inc(datpos);
 seek(datei,datpos);
 blockread(datei,dummy2,1);
 y2:=y1+dummy1;
 x2:=x1+dummy1;
 if y2>winymax then
  begin
  grapherror256:=2;
  goto ende;
  end;
 if x2>winxmax then
  begin
  grapherror256:=1;
  goto ende;
  end;
 yoffs:=(y1*faktor)+x1;
 for dummy3:=1 to dummy1 do
  begin
  offswert:=yoffs;
  farbindex:=1;
  inc(datpos);
  seek(datei,datpos);
  blockread(datei,farbwert,dummy2);
  for dummy4:=1 to dummy2 do
   begin
   farbe:=farbwert[farbindex];
   mem[segwert:offswert]:=farbe;
   inc(offswert);
   inc(farbindex);
   end;
  yoffs:=yoffs+faktor;
  datpos:=datpos+dummy2;
  end;
 close(datei);
 if doserror<>0 then grapherror256:=3;
 end;
ende:
end;


procedure getimage256_PCX_disk(dateiname:string;x1,y1,x2,y2:word);
begin
end;


procedure putimage256_PCX_disk(x1,y1:word;dateiname:string);
begin
end;


procedure getimage256_IFF_disk(dateiname:string;x1,y1,x2,y2:word);
begin
end;


procedure putimage256_IFF_disk(x1,y1:word;dateiname:string);
begin
end;


procedure getimage256_BMP_disk(dateiname:string;x1,y1,x2,y2:word);
begin
end;


procedure putimage256_BMP_disk(x1,y1:word;dateiname:string);
begin
end;


begin
end.