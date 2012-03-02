{$M 30000,0,200000}
Program SeanMouse;
Uses Graph,Crt,SeanHelp,Dos,Maus,Bits;
Const MouseExt           = '.'+#255+'SM';
      ConvertExt         = '.TXT';
      Mask               = $FF;
Type  MouseType          = Record
                            Description : String40;
                            Pixel       : Array[1..16] Of Array[1..16] Of Byte;
                            HotSpot     : Array[1..2] Of Byte;
                           End;
      DriveType          = Array[1..5] Of
                           Record
                            Number : Byte;
                            Kind   : Byte;
                           End;
Var   Driver,Mode        : Integer;
      CurrentColor       : Word;
      MButtons           : Integer;
      MouseLoaded        : Boolean;
      MouseSaved         : Boolean;
      MouseNamed         : Boolean;
      CDirectory         : String;
      Mouse              : MouseType;
      LastMouse          : MouseType;
      Dirs,Files         : Byte;
      MouseDir           : Array[1..50] Of String[12];
      MouseName          : Array[1..100] Of String[12];
      CPosF,CPosD        : Byte;
      CDir,CFile         : Byte;
      DriveData          : DriveType;
      Drives             : Byte;
      X,Y,Z              : Word;
      NButtons           : Integer;
      CurrentMouse       : String40;
      RedCross           : IconArea;


Procedure SetPixel(XP,YP : Byte; Color : Word);
Var X,Y : Integer;
Begin
 SetColor(Color);
 Case Color Of
  Black,White,
  LightGray  : Begin
                If GetPixel(XP+196,YP+042)<>Color Then
                Begin;
                 Mouse.Pixel[XP][YP]:=Color;
                 MouseSaved:=False;
                 Ms_Hide;
                 SetColor(Color);
                 Area(Color,XP*10+013,YP*10+033,XP*10+021,YP*10+041,'');
                 PutPixel(XP+196,YP+042,Color);
                 Ms_Show;
                End;
               End;
  Red        : Begin
                If (Mouse.HotSpot[1]<>XP) Or (Mouse.HotSpot[2]<>YP) Then
                Begin;
                 Ms_Hide;
                 SetColor(LightGray);
                 RectAngle(Mouse.HotSpot[1]*10+012,Mouse.HotSpot[2]*10+032,Mouse.HotSpot[1]*10+022,Mouse.HotSpot[2]*10+042);
                 Mouse.HotSpot[1]:=XP;
                 Mouse.HotSpot[2]:=YP;
                 SetColor(Color);
                 RectAngle(Mouse.HotSpot[1]*10+012,Mouse.HotSpot[2]*10+032,Mouse.HotSpot[1]*10+022,Mouse.HotSpot[2]*10+042);
                 Ms_Show;
                End;
               End;
  Mask : Begin
          If GetPixel(XP+196,YP+042)<>Red Then
          Begin;
           Mouse.Pixel[XP][YP]:=Color;
           MouseSaved:=False;
           Ms_Hide;
           SetColor(LightGray);
           Area(LightGray,XP*10+013,YP*10+033,XP*10+021,YP*10+041,'');
           PutPixel(XP+196,YP+042,Red);
              PushIconNoGray(XP*10+017,YP*10+037,RedCross);
                 Ms_Show;
                End;
               End;
 End;
End;

Procedure SetCurrentColor(Color : Word);
Var A,B : Byte;
Begin
 If CurrentColor<>Color Then
 Begin;
  Case Color Of
   Mask       : A:=0;    { Mask }
   Red        : A:=1;    { HotSpot  }
   LightGray  : A:=2;    { Guess what?}
   White      : A:=3;    { Well, duh ? }
   Black      : A:=4;    { ditto }
  End;
  Case CurrentColor Of
   Mask       : B:=0;
   Red        : B:=1;
   LightGray  : B:=2;
   White      : B:=3;
   Black      : B:=4;
  End;
  Ms_Hide;
  ButtonFrame(Off,194,129+B*15,215,144+B*15,'');
  ButtonFrame(On,194,129+A*15,215,144+A*15,'');
  Ms_Show;
  CurrentColor:=Color;
 End;
End;

Procedure ResetMouse;
Var X,Y,Z : Word;
Begin
 MouseLoaded:=False;
 MouseSaved:=False;
 MouseNamed:=False;
 For X:=1 To 16 Do
 Begin;
  For Y:=1 To 16 Do SetPixel(X,Y,LightGray);
 End;
 For X:=1 To 16 Do
 Begin;
  For Y:=1 To 16 Do Mouse.Pixel[X][Y]:=LightGray;
 End;
 CurrentMouse:='NONAME';
 If Mouse.HotSpot[1]=0 Then
 Begin;
  Mouse.HotSpot[1]:=2;
  Mouse.HotSpot[2]:=2;
 End;
 SetPixel(1,1,Red);
 LastMouse.Pixel:=Mouse.Pixel;
 LastMouse.HotSpot:=Mouse.HotSpot;
 LastMouse.Description:=Mouse.Description;
End;

Procedure SaveMouse;
Var MouseFile : File Of MouseType;
Begin
 Assign(MouseFile,CurrentMouse+MouseExt);
 Rewrite(MouseFile);
 Write(MouseFile,Mouse);
 Close(MouseFile);
 MouseSaved:=True;
 LastMouse.Pixel:=Mouse.Pixel;
 LastMouse.HotSpot:=Mouse.HotSpot;
 LastMouse.Description:=Mouse.Description;
End;

Procedure PreView(MouseName : String; YP : Word);
Var MFile : File Of MouseType;
    MData : MouseType;
Begin
 If MouseName<>'' Then
 Begin;
  Assign(MFile,MouseName+MouseExt);
  ReSet(MFile);
  Read(MFile,MData);
  Close(MFile);
  For X:=1 To 16 Do
  Begin;
   For Y:=1 To 16 Do
   Begin;
    If (MData.Pixel[X][Y]<>Mask) Then Area(MData.Pixel[X][Y],X*3+447,Y*3+YP,X*3+449,Y*3+2+YP,'') Else
    Begin;
     Area(LightGray,X*3+447,Y*3+YP,X*3+449,Y*3+2+YP,'');
     PutPixel(X*3+448,Y*3+1+YP,Red);
    End;
   End;
  End;
 End;
End;

Procedure GetNShowFiles(LoadMode : Boolean;Dir : PathStr);
Var S : SearchRec;
    B : Byte;
Begin
 Ms_Show;
 Ms_Set_GraphPointer(0,0,@Busy);
 CPosF:=1;
 CPosD:=1;
 CDir:=0;
 CFile:=0;
 For B:=1 To  50 Do MouseDir [B]:='';
 For B:=1 To 100 Do MouseName[B]:='';
 Dirs:=0;
 Files:=0;
 If CDirectory[Length(CDirectory)]='\' Then Delete(CDirectory,Length(CDirectory),1);
 FindFirst(CDirectory+'\*.*',AnyFile,S);
 While DosError=0 Do
 Begin;
  If (GetBit(S.Attr,$04)) And (S.Name<>'.') Then
  Begin;
   Inc(Dirs);
   MouseDir[Dirs]:=S.Name;
  End Else
  If (Copy(S.Name,Pos('.',S.Name),4)=MouseExt) And (S.Size=SizeOf(MouseType)) Then
  Begin;
   Inc(Files);
   MouseName[Files]:=Copy(S.Name,1,Pos('.',S.Name)-1);
  End;
  FindNext(S);
 End;
 If LoadMode=On Then X:=308 Else X:=353;
 Ms_Hide;
 SetColor(Red);
 RectAngle(030,X+20*(CPosD-1),160,X+20*CPosD);
 RectAngle(220,X+20*(CPosF-1),350,X+20*CPosF);
 Ms_Show;
 For B:=1 To Drives Do
 Begin;
  Inc(Dirs);
  MouseDir[Dirs]:=Chr(DriveData[B].Number+Ord('A'))+':';
 End;
 Ms_Hide;
 If LoadMode=On Then
 Begin;
  For B:=1 To 7 Do Area(LightGray,031,309+20*(B-1),159,327+20*(B-1),MouseDir[B]);
  For B:=1 To 7 Do Area(LightGray,221,309+20*(B-1),349,327+20*(B-1),MouseName[B]);
  X:=268;
 End Else
 If LoadMode=False Then
 Begin;
  For B:=1 To 5 Do Area(LightGray,031,354+20*(B-1),159,372+20*(B-1),MouseDir[B]);
  For B:=1 To 5 Do Area(LightGray,221,354+20*(B-1),349,372+20*(B-1),MouseName[B]);
  X:=318;
 End;
 If Files>0 Then PreView(MouseName[1],X) Else Area(LightGray,450,321,497,368,'');
 Ms_Set_GraphPointer(0,0,@Arrow);
End;

Procedure SaveMouseAs;
Var B    : Byte;
    Done : Boolean;
Begin
 Button(Off,000,228,520,248,'SAVE MOUSE');
 Button(Off,000,248,520,479,'');
 TextOut(020,268,'FILE NAME');
 InsRectAngle(020,288,120,308,CurrentMouse);
 TextOut(130,268,'REMARK/DESCRIPTION');
 InsRectAngle(130,288,500,308,Mouse.Description);
 InsRectAngle(020,318,200,338,'DIRECTORY');
 InsRectAngle(020,348,170,459,'');
 ButtonFrame(Off,180,348,200,368,'');
 InsRectAngle(180,378,200,429,'');
 ButtonFrame(Off,180,439,200,459,'');
 InsRectAngle(210,318,390,338,'FILE');
 InsRectAngle(210,348,360,459,'');
 ButtonFrame(Off,370,348,390,368,'');
 InsRectAngle(370,378,390,429,'');
 ButtonFrame(Off,370,439,390,459,'');
 InsRectAngle(447,318,500,371,'');

 ButtonFrame(Off,400,409,500,429,'SAVE');
 ButtonFrame(Off,400,439,500,459,'CANCEL');
 GetDir(0,CDirectory);
 GetNShowFiles(Off,CDirectory);
 Ms_Show;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case Y Of
   288..308: Case X Of
             020..120: EditText(CurrentMouse,0,8,020,288,120,308);
             130..500: EditText(Mouse.Description,0,40,130,288,500,308);
             End;
   End;
   Case X Of
   031..159: Case Y Of
             354..453: Begin;
                        B:=((Y-354) Div 20)+1;
                        If (CPosD<>B) And (B<=Dirs) Then
                        Begin;
                         Ms_Hide;
                         SetColor(LightGray);
                         RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                         CPosD:=B;
                         SetColor(Red);
                         RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                         PreView(MouseName[1],318);
                         Ms_Show;
                        End;
                       End;
             End;
   180..200: Case Y Of
             348..368: If MouseDelay(180,348,200,368) Then
                       Begin;
                        If CPosD>1 Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                         Dec(CPosD);
                         SetColor(Red);
                         RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                        End Else
                        If CDir>0 Then
                        Begin;
                         Dec(CDir);
                         For B:=5 DownTo 1 Do Area(LightGray,051,354+20*(B-1),139,372+20*(B-1),MouseDir[B+CDir]);
                        End;
                        Ms_Show;
                       End;
             439..459: If MouseDelay(180,439,200,459) Then
                       Begin;
                        If (CPosD<5) And (CPosD<Dirs) Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                         Inc(CPosD);
                         SetColor(Red);
                         RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                        End Else
                        If (CDir+CPosD)<Dirs Then
                        Begin;
                         Inc(CDir);
                         For B:=1 To 5 Do Area(LightGray,51,354+20*(B-1),139,372+20*(B-1),MouseDir[B+CDir]);
                        End;
                       End;
             End;
   221..349: Case Y Of
             354..453: Begin;
                        B:=((Y-354) Div 20)+1;
                        If (CPosF<>B) And (B<=Files) Then
                        Begin;
                         Ms_Hide;
                         SetColor(LightGray);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         CPosF:=B;
                         SetColor(Red);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         Ms_Show;
                         PreView(MouseName[CPosF+CFile],318);
                        End;
                       End;
             End;
   370..390: Case Y Of
             348..368: If MouseDelay(370,348,390,368) Then
                       Begin;
                        If CPosF>1 Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         Dec(CPosF);
                         SetColor(Red);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         PreView(MouseName[CPosF+CFile],318);
                        End Else
                        If CFile>0 Then
                        Begin;
                         Dec(CFile);
                         For B:=5 DownTo 1 Do Area(LightGray,241,354+20*(B-1),329,372+20*(B-1),MouseName[B+CFile-1]);
                         PreView(MouseName[CPosF+CFile],318);
                        End;
                        Ms_Show;
                       End;
             439..459: If MouseDelay(370,439,390,459) Then
                       Begin;
                        If (CPosF<5) And (CPosF<Files) Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         Inc(CPosF);
                         SetColor(Red);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         PreView(MouseName[CPosF+CFile],318);
                        End Else
                        If (CFile+CPosF)<Files Then
                        Begin;
                         Inc(CFile);
                         For B:=1 To 5 Do Area(LightGray,241,354+20*(B-1),329,372+20*(B-1),MouseName[B+CFile]);
                         PreView(MouseName[CPosF+CFile],318);
                        End;
                        Ms_Show;
                       End;
             End;
   400..500: Case Y Of
             410..430: If MouseDelay(400,410,500,430) Then
                       Begin;
                        SaveMouse;
                        Done:=True;
                        MouseNamed:=True;
                       End;
             439..459: If MouseDelay(400,439,500,459) Then Done:=True;
             End;
   End;
  End Else
  If Z=$0002 Then
  Begin;
   Case X Of
   031..159: Case Y Of
             354..453: Begin;
                        B:=((Y-354) Div 20)+1;
                        If (CPosD=B) Then
                        Begin;
                         Ms_Hide;
                         SetColor(LightGray);
                         If CPosD<>1 Then RectAngle(030,353+20*(CPosD-1),160,373+20*(CPosD-1));
                         If CPosF<>1 Then RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         ChDir(MouseDir[CPosD+CDir]);
                         GetDir(0,CDirectory);
                         GetNShowFiles(Off,CDirectory);
                         Ms_Show;
                        End
                       End;
             End;
   221..349: Case Y Of
             354..453: Begin;
                        B:=((Y-354) Div 20)+1;
                        If (CPosF=B) And (CurrentMouse<>MouseName[CPosF+CFile]) Then
                        Begin;
                         Ms_Hide;
                         CurrentMouse:=MouseName[CPosF+CFile];
                         Area(LightGray,023,291,117,305,CurrentMouse);
                         Ms_Show;
                         PreView(MouseName[CPosF+CFile],318);
                        End;
                       End;
             End;
   End;
  End;
 Until Done=True;
 ClearButton(000,248,520,479);
 ClearButton(000,228,520,248);
End;

Procedure GetMouse(Var Mouse : MouseType; MouseName : String);
Var MouseFile : File Of MouseType;
    X,Y       : Integer;
Begin
 If Exist(MouseName+MouseExt) Then
 Begin;
  MouseLoaded:=True;
  MouseSaved:=True;
  MouseNamed:=True;
  Assign(MouseFile,MouseName+MouseExt);
  ReSet(MouseFile);
  Read(MouseFile,Mouse);
  Close(MouseFile);
  For X:=1 To 16 Do
  Begin;
   For Y:=1 To 16 Do SetPixel(X,Y,Mouse.Pixel[X][Y]);
  End;
  CurrentMouse:=MouseName;
  SetPixel(Mouse.HotSpot[1],Mouse.HotSpot[2],Red);
  LastMouse.Pixel:=Mouse.Pixel;
  LastMouse.HotSpot:=Mouse.HotSpot;
  LastMouse.Description:=Mouse.Description;
 End;
End;

Procedure GetDrives(Var DriveData : DriveType);
Type DPBType = Record
                DriveNumber          : Byte;
                DeviceNumber         : Byte;
                Dummy1               : Array[1..21] Of Byte;
                MediaDescriptor      : Byte;
                VerifyFlag           : Byte;
                NextDPB              : Pointer;
               End;
Var DPB      : ^DPBType;
    R        : Registers;
    B        : Byte;
    S        : String;
Begin
 Drives:=0;
 R.Ah:=$52;
 Intr($21,R);
 DPB:=Pointer(MemL[R.Es:R.Bx]);
 While Seg(DPB^.NextDPB)<>$FFFF Do
 Begin;
  Inc(Drives);
  DriveData[Drives].Number:=DPB^.DriveNumber;
  DriveData[Drives].Kind  :=DPB^.MediaDescriptor;
  DPB:=Pointer(MemL[Seg(DPB^):Ofs(DPB^)+$19]);
 End;
End;

Function MouseChanged : Boolean;
Var B : Boolean;
Begin
 B:=False;
 For X:=1 To 16 Do
 Begin;
  For Y:=1 To 16 Do
  Begin;
   If Mouse.Pixel[X][Y]<>LastMouse.Pixel[X][Y] Then B:=True;
  End;
 End;
 If (Mouse.HotSpot[1]<>LastMouse.HotSpot[1]) Or
    (Mouse.HotSpot[2]<>LastMouse.HotSpot[2]) Then B:=True;
 If Mouse.Description<>LastMouse.Description Then B:=True;
 MouseChanged:=B;
End;

Procedure SaveFirst;
Var SaveAs : Boolean;
    Done : Boolean;
Begin
 SaveAs:=False;
 Done:=False;
 Button(Off,180,299,340,419,'');
 InsRectAngle(190,309,330,329,'SAVE CHANGES');
 PutIcon(260,359,'HELP');
 ButtonFrame(Off,190,389,255,409,'YES');
 ButtonFrame(Off,265,389,330,409,'NO');
 Ms_Show;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case Y Of
   389..409: Case X Of
             190..255: If MouseDelay(190,389,255,409) Then
                       Begin;
                        If MouseNamed Then SaveMouse;
                        If Not MouseNamed Then
                        Begin;
                         ClearButton(180,299,340,419);
                         SaveMouseAs;
                         SaveAs:=True;
                        End;
                        Done:=True;
                       End;
             265..330: If MouseDelay(265,389,330,409) Then Done:=True;
             End;
   End;
  End;
 Until Done;
 If SaveAs=False Then ClearButton(180,299,340,419);
End;

Procedure LoadMouse;
Var B    : Byte;
    Done : Boolean;
Begin
 Button(Off,000,228,520,248,'LOAD MOUSE');
 Button(Off,000,248,520,479,'');
 InsRectAngle(020,268,200,288,'DIRECTORY');
 InsRectAngle(020,298,170,459,'');
 ButtonFrame(Off,180,298,200,318,'');
 InsRectAngle(180,328,200,429,'');
 ButtonFrame(Off,180,439,200,459,'');
 InsRectAngle(210,268,390,288,'FILE');
 InsRectAngle(210,298,360,459,'');
 ButtonFrame(Off,370,298,390,318,'');
 InsRectAngle(370,328,390,429,'');
 ButtonFrame(Off,370,439,390,459,'');
 InsRectAngle(447,268,500,321,'');
 ButtonFrame(Off,400,439,500,459,'CANCEL');
 {***************** Init **********************}
 Done:=False;
 GetDir(0,CDirectory);
 GetNShowFiles(On,CDirectory);
 Ms_Show;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case X Of
   031..159: Case Y Of
             309..447: Begin;
                        B:=((Y-308) Div 20)+1;
                        If (CPosD<>B) And (B<=Dirs) Then
                        Begin;
                         Ms_Hide;
                         SetColor(LightGray);
                         RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                         CPosD:=B;
                         SetColor(Red);
                         RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                         Ms_Show;
                        End;
                       End;
             End;
   180..200: Case Y Of
             298..318: If MouseDelay(180,298,200,318) Then
                       Begin;
                        If CPosD>1 Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                         Dec(CPosD);
                         SetColor(Red);
                         RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                        End Else
                        If CDir>0 Then
                        Begin;
                         Dec(CDir);
                         For B:=7 DownTo 1 Do Area(LightGray,051,309+20*(B-1),139,327+20*(B-1),MouseDir[B+CDir]);
                        End;
                        Ms_Show;
                       End;
             439..459: If MouseDelay(180,439,200,459) Then
                       Begin;
                        If (CPosD<7) And (CPosD<Dirs) Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                         Inc(CPosD);
                         SetColor(Red);
                         RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                        End Else
                        If (CDir+CPosD)<Dirs Then
                        Begin;
                         Inc(CDir);
                         For B:=1 To 7 Do Area(LightGray,51,309+20*(B-1),139,327+20*(B-1),MouseDir[B+CDir]);
                        End;
                        Ms_Show;
                       End;
             End;
   221..349: Case Y Of
             309..447: Begin;
                        B:=((Y-308) Div 20)+1;
                        If (CPosF<>B) And (B<=Files) Then
                        Begin;
                         Ms_Hide;
                         SetColor(LightGray);
                         RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         CPosF:=B;
                         SetColor(Red);
                         RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         Ms_Show;
                         PreView(MouseName[CPosF+CFile],268);
                        End;
                       End;
             End;
   370..390: Case Y Of
             298..318: If MouseDelay(370,298,390,318) Then
                       Begin;
                        If CPosF>1 Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         Dec(CPosF);
                         SetColor(Red);
                         RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         PreView(MouseName[CPosF+CFile],268);
                        End Else
                        If CFile>0 Then
                        Begin;
                         Dec(CFile);
                         For B:=7 DownTo 1 Do Area(LightGray,241,309+20*(B-1),329,327+20*(B-1),MouseName[B+CFile]);
                         PreView(MouseName[CPosF+CFile],268);
                        End;
                        Ms_Show;
                       End;
             439..459: If MouseDelay(370,439,390,459) Then
                       Begin;
                        If (CPosF<7) And (CPosF<Files) Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         Inc(CPosF);
                         SetColor(Red);
                         RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         PreView(MouseName[CPosF+CFile],268);
                        End Else
                        If (CFile+CPosF)<Files Then
                        Begin;
                         Inc(CFile);
                         For B:=1 To 7 Do Area(LightGray,241,309+20*(B-1),329,327+20*(B-1),MouseName[B+CFile]);
                         PreView(MouseName[CPosF+CFile],268);
                        End;
                        Ms_Show;
                       End;
             End;
   400..500: Case Y Of
             439..459: If MouseDelay(400,439,500,459) Then Done:=True;
             End;
   End;
  End Else
  If Z=$0002 Then
  Begin;
   Case X Of
   031..159: Case Y Of
             309..447: Begin;
                        B:=((Y-308) Div 20)+1;
                        If (CPosD=B) Then
                        Begin;
                         Ms_Hide;
                         SetColor(LightGray);
                         If CPosD<>1 Then RectAngle(030,308+20*(CPosD-1),160,328+20*(CPosD-1));
                         If CPosF<>1 Then RectAngle(220,308+20*(CPosF-1),350,328+20*(CPosF-1));
                         ChDir(MouseDir[CPosD+CDir]);
                         GetDir(0,CDirectory);
                         GetNShowFiles(On,CDirectory);
                         Ms_Show;
                        End
                       End;
             End;
   221..349: Case Y Of
             309..447: Begin;
                        B:=((Y-308) Div 20)+1;
                        If (CPosF=B) Then
                        Begin;
                         Ms_Hide;
                         GetMouse(Mouse,MouseName[CPosF+CFile]);
                         ChDir(CDirectory);
                         Done:=True;
                        End;
                       End;
             End;
   End;
  End;
 Until Done=True;
 ClearButton(000,248,520,479);
 ClearButton(000,228,520,248);
End;

Procedure ConvertMouse;
Var X,Y         : Integer;
    S           : Array[0..15] Of String[5];
    ConvertFile : Text;
    MouseWord   : Word;
    CFile       : Integer;
    Dummy       : String;
Begin
 Assign(ConvertFile,CurrentMouse+ConvertExt);
 ReWrite(ConvertFile);
 For Y:=1 To 16 Do
 Begin;
  S[Y-1]:='';
  For X:=15 DownTo 0 Do
  Begin;
   Case Mouse.Pixel[16-X][Y] Of
    White,Black   : If Odd(MouseWord Shr X) Then Dec(MouseWord,1 Shl X);
    LightGray,Mask: MouseWord:=MouseWord Or 1 Shl X;
   End;
  End;
  S[Y-1]:='$'+DecToHex(MouseWord);
 End;
 Dummy:='';
 For X:=1 To 38+Length(CurrentMouse) Do Dummy:=Dummy+' ';
 WriteLn(ConvertFile,'Const '+CurrentMouse+' : Array[1..2,1..16] Of Word = (('+S[0]+','+S[1]+','+S[2]+','+S[3]+',');
 WriteLn(ConVertFile,Dummy+' '+S[4]+','+S[5]+','+S[6]+','+S[7]+',');
 WriteLn(ConVertFile,Dummy+' '+S[8]+','+S[9]+','+S[10]+','+S[11]+',');
 WriteLn(ConVertFile,Dummy+' '+S[12]+','+S[13]+','+S[14]+','+S[15]+'),');
 For Y:=1 To 16 Do
 Begin;
  S[Y-1]:='';
  For X:=15 DownTo 0 Do
  Begin;
   Case Mouse.Pixel[16-X][Y] Of
    Black,LightGray: If Odd(MouseWord Shr X) Then Dec(MouseWord,1 Shl X);
    White,Mask     : MouseWord:=MouseWord Or 1 Shl X;
   End;
  End;
  S[Y-1]:='$'+DecToHex(MouseWord);
 End;
 WriteLn(ConvertFile,Dummy+'('+S[00]+','+S[01]+','+S[02]+','+S[03]+',');
 WriteLn(ConVertFile,Dummy+' '+S[04]+','+S[05]+','+S[06]+','+S[07]+',');
 WriteLn(ConVertFile,Dummy+' '+S[08]+','+S[09]+','+S[10]+','+S[11]+',');
 WriteLn(ConVertFile,Dummy+' '+S[12]+','+S[13]+','+S[14]+','+S[15]+'));');
 Close(ConvertFile);
End;

Begin
 DetectGraph(Driver,Mode);
 InitGraph(Driver,Mode,'C:\DOS\BORLAND\BGI');
 Button(Off,000,000,520,020,'SEAN MOUSE');
 Button(Off,520,000,639,040,'');
 Button(Off,520,040,639,080,'');
 Button(Off,520,080,639,120,'');
 Button(Off,520,120,639,160,'');
 Button(Off,520,160,639,200,'');
 Button(Off,520,200,639,439,'');
 Button(Off,520,439,639,479,'');
 PutIcon(540,020,'NEW');
 PutIcon(540,060,'LOAD');
 PutIcon(540,100,'SAVE');
 PutIcon(540,140,'SAVEAS');
 PutIcon(540,180,'CONVERT');
 PutIcon(540,459,'QUIT');
 Area(LightGray,560,010,630,030,'NEW');
 Area(LightGray,560,050,630,070,'LOAD');
 Area(LightGray,560,090,630,110,'SAVE');
 Area(LightGray,560,130,630,150,'SAVE AS');
 Area(LightGray,560,170,630,190,'CONVERT');
 Area(LightGray,560,449,630,469,'EXIT');
 Button(Off,000,020,239,228,'');
 InsRectAngle(020,040,184,204,'');
 InsRectAngle(194,040,215,061,'');
 ButtonFrame(Off,194,129,215,144,'');
 LoadIcon('REDCROSS',RedCross);
 PushIconNoGray(204,136,RedCross);
 ButtonFrame(Off,194,144,215,159,'');
 ButtonFrame(On ,194,159,215,174,'');
 ButtonFrame(Off,194,174,215,189,'');
 ButtonFrame(Off,194,189,215,204,'');
 Area(Red  ,198,148,211,155,'');
 Area(White,198,178,211,185,'');
 Area(Black,198,193,211,200,'');
 Button(Off,239,020,520,228,'');
 ReSetMouse;
 CurrentColor:=LightGray;
 GetDrives(DriveData);
 If Ms_Init(MButtons) Then Ms_Show;
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case X Of
   024..182: Case Y Of
             044..202: SetPixel(Trunc((X-24)/10)+1,Trunc((Y-44)/10)+1,CurrentColor); { ok! }
             End;
   194..215: Case Y Of
             129..144: SetCurrentColor(Mask);
             144..159: SetCurrentColor(Red);
             159..174: SetCurrentColor(LightGray);
             174..189: SetCurrentColor(White);
             189..204: SetCurrentColor(Black);     { Ok ! }
             End;
   520..639: Case Y Of
             000..040: If MouseDelay(520,000,639,040) Then
                       Begin;
                        If (MouseChanged=True) And (MouseSaved=False) Then SaveFirst;
                        ReSetMouse; { Ok! }
                        Ms_Show;
                       End;
             040..080: If MouseDelay(520,040,639,080) Then
                       Begin;
                        If (MouseChanged=True) And (MouseSaved=False) Then SaveFirst;
                        LoadMouse;  { Ok! }
                        Ms_Show;
                       End;
             080..120: If MouseDelay(520,080,639,120) Then
                       Begin;
                        If MouseNamed Then SaveMouse Else SaveMouseAs;
                        Ms_Show;
                       End;
             120..160: If MouseDelay(520,120,639,160) Then
                       Begin;
                        SaveMouseAs;
                        Ms_Show;
                       End;
             160..200: If MouseDelay(520,160,639,200) Then
                       Begin;
                        If MouseNamed Then ConvertMouse Else
                        Begin;
                         SaveMouseAs;
                         If MouseNamed Then ConvertMouse;
                        End;
                        Ms_Show;
                       End;
             439..479: If MouseDelay(520,439,639,479) Then
                       Begin;
                        If (MouseChanged=True) And (MouseSaved=False) Then SaveFirst;
                        CloseGraph;
                        Halt;
                       End;
             End;
   End;
  End Else
  If Z=$0002 Then
  Begin;
   Case X Of
   024..182: Case Y Of
             044..202: SetPixel(Trunc((X-24)/10)+1,Trunc((Y-44)/10)+1,LightGray); { ok! }
             End;
   End;
  End;
 Until False;
End.