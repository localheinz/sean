Program SeanIcon;
Uses  Graph,Crt,SeanHelp,Dos,Maus,Bits;
Const IconExt            = '.'+#255+'SN';
      MaxIcons           : Byte = 0;
Type  IconType           = Record
                            Description : String40;
                            Pixel       : Array[1..25] Of Array[1..25] Of Byte;
                           End;
      PtrIconType        = ^IconType;
      DriveType          = Array[1..5] Of
                           Record
                            Number : Byte;
                            Kind   : Byte;
                           End;
      ListType           = Array[1..250] Of String[12];
Var   Driver,Mode        : Integer;
      MButtons           : Integer;
      NButtons           : Integer;
      X,Y,Z              : Word;
      CurrentColor       : Word;
      Dirs,Files         : Word;
      CPosF,CPosD        : Byte;
      CDir,CFile         : Byte;
      Drives             : Byte;
      IconLoaded         : Boolean;
      IconSaved          : Boolean;
      IconNamed          : Boolean;
      Done               : Boolean;
      Locked             : Array[1..4] Of Boolean;
      CDirectory         : String;
      StartUpDir         : String;
      LastIcon           : IconType;
      Icon               : IconType;
      IconFile           : File Of IconType;
      IconDir            : ListType;
      IconName           : ListType;
      DriveData          : DriveType;
      CurrentIcon        : String40;
      PtrIcon            : Array[1..250] Of PtrIconType;

Procedure SetPixel(XP,YP : Byte; Color : Word);
Begin
 SetColor(Color);
 If GetPixel(XP+206,YP+037)<>Color Then
 Begin;
  Icon.Pixel[XP][YP]:=Color;
  IconSaved:=False;
  Ms_Hide;
  SetColor(Color);
  Area(Color,XP*7+011,YP*7+031,XP*7+016,YP*7+036,'');
  PutPixel(XP+206,YP+037,Color);
  Ms_Show;
 End;
End;

Procedure Screen(Icon : IconType);
Var DoneYet : Array[1..25,1..25] Of Boolean;
    W       : Word;
Begin
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do DoneYet[X,Y]:=False;
 End;
 W:=0;
 Randomize;
 Repeat;
  X:=Random(25)+1;
  Y:=Random(25)+1;
  If DoneYet[X,Y]=False Then
  Begin;
   SetPixel(X,Y,Icon.Pixel[X][Y]);
   DoneYet[X,Y]:=True;
   Inc(W);
  End;
 Until W=625;
End;

Procedure SetCurrentColor(Color : Word);
Var A,B : Byte;
Begin
 If CurrentColor<>Color Then
 Begin;
  Ms_Hide;
  A:=CurrentColor Div 8;
  B:=CurrentColor-A*8;
  ButtonFrame(Off,204+A*20,094+B*15,224+A*20,109+B*15,'');
  A:=Color Div 8;
  B:=Color-A*8;
  ButtonFrame(On,204+A*20,094+B*15,224+A*20,109+B*15,'');
  CurrentColor:=Color;
  Ms_Show;
 End;
End;

Procedure ResetIcon;
Var X,Y : Word;
Begin
 IconLoaded:=False;
 IconSaved:=False;
 IconNamed:=False;
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do
  Begin;
   Icon.Pixel[X][Y]:=LightGray;
  End;
 End;
{ Circle(219,055,12);
 SetColor(White);
 Circle(219,055,11);
 SetColor(Green);
 Circle(219,055,9);
 Circle(219,055,7);
 SetColor(White);
 Circle(219,055,6);
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do
  Begin;
   Icon.Pixel[X][Y]:=GetPixel(X+206,Y+037);
  End;
 End;}
 Screen(Icon);
 CurrentIcon:='NONAME';
 LastIcon:=Icon;
End;

Procedure SaveIcon;
Var IconFile : File Of IconType;
Begin
 Assign(IconFile,CurrentIcon+IconExt);
 Rewrite(IconFile);
 Write(IconFile,Icon);
 Close(IconFile);
 IconSaved:=True;
 LastIcon:=Icon;
End;

Procedure ExportIcon;
Var TextFile : Text;
    B        : Byte;
    S        : String;
Begin
 Assign(TextFile,CurrentIcon+'.TXT');
 Rewrite(TextFile);
 Write(TextFile,'Const '+CurrentIcon+' : IconArea = (');
 B:=Length('Const '+CurrentIcon+' : IconArea = (');
 For X:=1 To 25 Do
 Begin;
  If X=1 Then Write(TextFile,'(') Else Write(TextFile,' ':B,'(');
  For Y:=1 To 25 Do
  Begin;
   Str(Icon.Pixel[X][Y],S);
   While Length(S)<2 Do S:='0'+S;
   Write(TextFile,S);
   If Y<25 Then Write(TextFile,',');
  End;
  If X<25 Then WriteLn(TextFile,'),') Else WriteLn(TextFile,'));');
 End;
 Close(TextFile);
End;

Procedure PreView(Icon : IconType; YP : Word);
Var A,B : Word;
Begin
 For A:=1 To 25 Do
 Begin;
  For B:=1 To 25 Do
  Begin;
   If GetPixel(A*2+447,B*2+YP+1)<>Icon.Pixel[A][B] Then Area(Icon.Pixel[A][B],A*2+446,B*2+YP,A*2+447,B*2+1+YP,'');
  End;
 End;
End;

Procedure SortList(Var Data : ListType; Entries : Word);
Var Dummy : ListType;
    A,B,C : Integer;
Begin
 Dummy:=Data;
 For A:=1 To Entries Do
 Begin;
  For B:=A+1 To Entries Do
  Begin;
   If (Data[A]>Data[B]) Then
   Begin;
    Dummy[A]:=Data[B];
    For C:=A+1 To B Do Dummy[C]:=Data[C-1];
    Data:=Dummy;
   End;
  End;
 End;
End;

Procedure GetNShowFiles(LoadMode : Boolean;Dir : PathStr);
Var S        : SearchRec;
    B        : Byte;
Begin
 Ms_Show;
 Ms_Set_GraphPointer(0,0,@Busy);
 CPosF:=1;
 CPosD:=1;
 CDir:=0;
 CFile:=0;
 For B:=1 To  50 Do IconDir [B]:='';
 For B:=1 To 250 Do IconName[B]:='';
 Dirs:=0;
 Files:=0;
 If Dir[Length(Dir)]='\' Then Delete(Dir,Length(Dir),1);
 FindFirst(Dir+'\*.*',AnyFile,S);
 While (DosError=0) Do
 Begin;
  If (GetBit(S.Attr,$04)) And (S.Name<>'.') Then
  Begin;
   Inc(Dirs);
   IconDir[Dirs]:=S.Name;
  End Else
  If (Copy(S.Name,Pos('.',S.Name),4)=IconExt) And (S.Size=SizeOf(IconType)) Then
  Begin;
   Inc(Files);
   IconName[Files]:=Copy(S.Name,1,Pos('.',S.Name)-1);
  End;
  FindNext(S);
 End;
 SortList(IconName,Files);
 SortList(IconDir,Dirs);
 SetColor(Red);
 If LoadMode=On Then X:=308 Else X:=353;
 Ms_Hide;
 RectAngle(030,X+20*(CPosD-1),160,X+20+20*(CPosD-1));
 RectAngle(220,X+20*(CPosF-1),350,X+20+20*(CPosF-1));
 Ms_Show;
 For B:=1 To Files Do
 Begin;
  If Files<=MaxIcons Then
  Begin;
   Assign(IconFile,Dir+'\'+IconName[B]+IconExt);
   Reset(IconFile);
   Read(IconFile,PtrIcon[B]^);
   Close(IconFile);
  End;
 End;
 For B:=1 To Drives Do
 Begin;
  Inc(Dirs);
  IconDir[Dirs]:=Chr(DriveData[B].Number+Ord('A'))+':';
 End;
 Ms_Hide;
 If LoadMode=On Then
 Begin;
  For B:=1 To 7 Do
  Begin;
   Area(LightGray,031,309+20*(B-1),159,327+20*(B-1),IconDir[B]);
   Area(LightGray,221,309+20*(B-1),349,327+20*(B-1),IconName[B]);
  End;
 End Else
 If LoadMode=False Then
 Begin;
  For B:=1 To 5 Do Area(LightGray,031,354+20*(B-1),159,372+20*(B-1),IconDir[B]);
  For B:=1 To 5 Do Area(LightGray,221,354+20*(B-1),349,372+20*(B-1),IconName[B]);
 End;
 If LoadMode=On Then X:=268 Else X:=318;
 If Files>0 Then Preview(PtrIcon[1]^,X) Else Area(LightGray,448,X+2,497,X+51,'');
 Ms_Set_GraphPointer(0,0,@Arrow);
End;

Procedure SaveIconAs;
Var B    : Byte;
Begin
 Done:=False;
 Button(Off,000,228,520,248,'SAVE Icon');
 Button(Off,000,248,520,479,'');
 TextOut(020,268,'FILE NAME');
 InsRectAngle(020,288,120,308,CurrentIcon);
 TextOut(130,268,'REMARK/DESCRIPTION');
 InsRectAngle(130,288,500,308,Icon.Description);
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
 InsRectAngle(446,318,500,372,''); { For da Icons }
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
             020..120: EditText(CurrentIcon,0,8,020,288,120,308);
             130..500: EditText(Icon.Description,0,40,130,288,500,308);
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
                         PreView(PtrIcon[1]^,318);
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
                         For B:=5 DownTo 1 Do Area(LightGray,051,354+20*(B-1),139,372+20*(B-1),IconDir[B+CDir]);
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
                         For B:=1 To 5 Do Area(LightGray,51,354+20*(B-1),139,372+20*(B-1),IconDir[B+CDir]);
                        End;
                        Ms_Show;
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
                         PreView(PtrIcon[CPosF+CFile]^,318);
                        End;
                       End;
             End;
   370..390: Case Y Of
             348..369: If MouseDelay(370,348,390,369) Then
                       Begin;
                        If CPosF>1 Then
                        Begin;
                         SetColor(LightGray);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         Dec(CPosF);
                         SetColor(Red);
                         RectAngle(220,353+20*(CPosF-1),350,373+20*(CPosF-1));
                         PreView(PtrIcon[CPosF+CFile]^,318);
                        End Else
                        If CFile>0 Then
                        Begin;
                         Dec(CFile);
                         For B:=5 DownTo 1 Do Area(LightGray,241,354+20*(B-1),329,372+20*(B-1),IconName[B+CFile-1]);
                         PreView(PtrIcon[CPosF+CFile]^,318);
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
                         Preview(PtrIcon[CPosF+CFile]^,318);
                        End Else
                        If (CFile+CPosF)<Files Then
                        Begin;
                         Inc(CFile);
                         For B:=1 To 5 Do Area(LightGray,241,354+20*(B-1),329,372+20*(B-1),IconName[B+CFile]);
                         Preview(PtrIcon[CPosF+CFile]^,318);
                        End;
                        Ms_Show;
                       End;
             End;
   400..500: Case Y Of
             409..429: If MouseDelay(400,409,500,429) Then
                       Begin;
                        SaveIcon;
                        Done:=True;
                        IconNamed:=True;
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
                         ChDir(IconDir[CPosD+CDir]);
                         GetDir(0,CDirectory);
                         GetNShowFiles(Off,CDirectory);
                         Ms_Show;
                        End
                       End;
             End;
   221..349: Case Y Of
             354..453: Begin;
                        B:=((Y-354) Div 20)+1;
                        If (CPosF=B) And (CurrentIcon<>IconName[CPosF+CFile]) Then
                        Begin;
                         Ms_Hide;
                         CurrentIcon:=IconName[CPosF+CFile];
                         Area(LightGray,023,291,117,305,CurrentIcon);
                         Ms_Show;
                         Preview(PtrIcon[CPosF+CFile]^,318);
                        End;
                       End;
             End;
   End;
  End;
 Until Done=True;
 ClearButton(000,248,520,479);
 ClearButton(000,228,520,248);
End;

Procedure GetIcon(Var Icon : IconType; IconName : String);
Var IconFile : File Of IconType;
    X,Y       : Integer;
Begin
 If Exist(IconName+IconExt) Then
 Begin;
  IconLoaded:=True;
  IconSaved:=True;
  IconNamed:=True;
  Assign(IconFile,IconName+IconExt);
  ReSet(IconFile);
  Read(IconFile,Icon);
  Close(IconFile);
  Screen(Icon);
  CurrentIcon:=IconName;
  LastIcon:=Icon;
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

Function IconChanged : Boolean;
Begin
 IconChanged:=False;
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do
  Begin;
   If Icon.Pixel[X][Y]<>LastIcon.Pixel[X][Y] Then IconChanged:=True;
  End;
 End;
 If Icon.Description<>LastIcon.Description Then IconChanged:=True;
End;

Procedure SaveFirst;
Var SaveAs : Boolean;
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
                        If IconNamed Then SaveIcon;
                        If Not IconNamed Then
                        Begin;
                         ClearButton(180,299,340,419);
                         SaveIconAs;
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

Procedure LoadIcon;
Var B    : Byte;
Begin
 Done:=False;
 Button(Off,000,228,520,248,'LOAD Icon');
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
 InsRectAngle(446,268,500,322,'');
 ButtonFrame(Off,400,439,500,459,'CANCEL');
 {***************** Init **********************}
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
                         For B:=7 DownTo 1 Do Area(LightGray,051,309+20*(B-1),139,327+20*(B-1),IconDir[B+CDir]);
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
                         For B:=1 To 7 Do Area(LightGray,51,309+20*(B-1),139,327+20*(B-1),IconDir[B+CDir]);
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
                         Preview(PtrIcon[CPosF+CFile]^,268);
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
                         Preview(PtrIcon[CPosF+CFile]^,268);
                        End Else
                        If CFile>0 Then
                        Begin;
                         Dec(CFile);
                         For B:=7 DownTo 1 Do Area(LightGray,241,309+20*(B-1),329,327+20*(B-1),IconName[B+CFile]);
                         Preview(PtrIcon[CPosF+CFile]^,268);
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
                         Preview(PtrIcon[CPosF+CFile]^,268);
                        End Else
                        If (CFile+CPosF)<Files Then
                        Begin;
                         Inc(CFile);
                         For B:=1 To 7 Do Area(LightGray,241,309+20*(B-1),329,327+20*(B-1),IconName[B+CFile]);
                         Preview(PtrIcon[CPosF+CFile]^,268);
                        End;
                        Ms_Show;
                       End;
             End;
   400..500: Case Y Of
             440..459: If MouseDelay(400,440,500,459) Then Done:=True;
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
                         ChDir(IconDir[CPosD+CDir]);
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
                         GetIcon(Icon,IconName[CPosF+CFile]);
{                         ChDir(StartUpDir);}
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

Procedure Rotate;
Var Dummy : IconType;
Begin
 Dummy:=Icon;
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do Icon.Pixel[26-Y][X]:=Dummy.Pixel[X][Y];
 End;
 Screen(Icon);
End;

Procedure Mirror;
Var Dummy : IconType;
Begin
 Dummy:=Icon;
 For X:=1 To 25 Do
 Begin;
  For Y:=1 To 25 Do Icon.Pixel[26-X][Y]:=Dummy.Pixel[X][Y];
 End;
 Screen(Icon);
End;

Procedure Filter;
Begin
 Button(Off,000,228,520,248,'FILTER');
 Button(Off,000,248,520,479,'');
 Frame('REPLACE COLORS',020,268,160,448);
 For Y:=0 To 7 Do
 Begin;
  For X:=0 To 1 Do
  Begin;
   If (X*8+Y<>CurrentColor) Then ButtonFrame(Off,030+X*20,288+Y*15,050+X*20,303+Y*15,'') Else
   If (X*8+Y=CurrentColor) Then ButtonFrame(On,030+X*20,288+Y*15,050+X*20,303+Y*15,'');
   Area(X*8+Y,034+X*20,292+Y*15,046+X*20,299+Y*15,'');
   If (X*8+Y<>CurrentColor) Then ButtonFrame(Off,110+X*20,288+Y*15,130+X*20,303+Y*15,'') Else
   If (X*8+Y=CurrentColor) Then ButtonFrame(On,110+X*20,288+Y*15,130+X*20,303+Y*15,'');
   Area(X*8+Y,114+X*20,292+Y*15,126+X*20,299+Y*15,'');
  End;
 End;
 ButtonFrame(Off,030,418,150,438,'DO IT');
End;

Function KeyHit(Key : Char) : Boolean;
Var C : Char;
Begin
 KeyHit:=False;
 If KeyPressed Then
 Begin;
  C:=UpCase(ReadKey);
  Key:=UpCase(Key);
  If C=Key Then KeyHit:=True;
 End;
End;

Begin
 GetDir(0,StartUpDir);
 GraphMode(Driver,Mode);
 Font(0,5);
 { allocating memory for icons }
 MaxIcons:=0;
 While (MaxAvail>SizeOf(Icon)) And (MaxIcons<250) Do
 Begin;
  Inc(MaxIcons);
  New(PtrIcon[MaxIcons]);
 End;
 { screen }
 Button(Off,000,000,520,020,'SEAN ICON');
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
 PutIcon(540,459,'QUIT');
 Area(LightGray,560,010,630,030,'NEW');
 Area(LightGray,560,050,630,070,'LOAD');
 Area(LightGray,560,090,630,110,'SAVE');
 Area(LightGray,560,130,630,150,'SAVE AS');
 Area(LightGray,560,170,630,190,'EXPORT');
 Area(LightGray,560,449,630,469,'EXIT');
{ PutIcon(580,320,'SEANICON');}
 Button(Off,000,020,255,228,'');
 InsRectAngle(015,035,194,214,'');
 InsRectAngle(204,035,234,065,'');
 For Y:=0 To 7 Do
 Begin;
  For X:=0 To 1 Do
  Begin;
   If (X*8+Y<>CurrentColor) Then ButtonFrame(Off,204+X*20,094+Y*15,224+X*20,109+Y*15,'') Else
   If (X*8+Y=CurrentColor) Then ButtonFrame(On,204+X*20,094+Y*15,224+X*20,109+Y*15,'');
   Area(X*8+Y,208+X*20,098+Y*15,220+X*20,105+Y*15,'');
  End;
 End;
 Button(Off,255,020,520,228,'');
 InsRectAngle(270,035,325,214,'');
 ButtonFrame(Off,280,045,315,080,'');
 PutIcon(297,062,'DRAW');
 ButtonFrame(Off,280,080,315,115,'Line');
 {PutIcon(297,097,'LINE');}
 ButtonFrame(Off,280,115,315,150,'Circle');
 {PutIcon(297,132,'CIRCLE');}
 ButtonFrame(Off,280,150,315,185,'');
 PutIcon(297,167,'Fill');
 InsRectAngle(335,035,389,214,'');
 {ButtonFrame(Off,265,178,305,218,'');
 PutIcon(284,197,'ROTATE');
 ButtonFrame(Off,315,178,355,218,'');
 PutIcon(334,197,'FILL');
 ButtonFrame(Off,365,178,405,218,'');
 PutIcon(384,197,'MIRROR');}
 ReSetIcon;
 CurrentColor:=Black;
 GetDrives(DriveData);
 SetCurrentColor(Black);
 If Ms_Init(MButtons) Then Ms_Show;
 Ms_Set_GraphPointer(0,0,@Arrow);
 Repeat;
  Ms_Read(X,Y,Z);
  If Z=$0001 Then
  Begin;
   Case X Of
   018..192: Case Y Of
             038..212: SetPixel(Trunc((X-18)/7)+1,Trunc((Y-38)/7)+1,CurrentColor);
             End;
   207..242: Case Y Of
             097..213: Begin
                        X:=Trunc((X-207)/20);
                        Y:=Trunc((Y-097)/15);
                        Z:=X*8+Y;
                        SetCurrentColor(Z);
                       End;
             End;
   265..305: Case Y Of
             178..218: If MouseDelay(265,178,305,218) Then
                       Begin;
                        Rotate;
                        Ms_Show;
                       End;
             End;
   315..355: Case Y Of
             178..218: If MouseDelay(315,178,355,218) Then
                       Begin;
                        Filter;
                        Ms_Show;
                       End;
             End;
   365..405: Case Y Of
             178..218: If MouseDelay(365,178,405,218) Then
                       Begin;
                        Mirror;
                        Ms_Show;
                       End;
             End;
   520..639: Case Y Of
             000..040: If MouseDelay(520,000,639,040) Then
                       Begin;
                        If (IconChanged=True) And (IconSaved=False) Then SaveFirst;
                        ResetIcon;
                        Ms_Show;
                       End;
             040..080: If MouseDelay(520,040,639,080) Then
                       Begin;
                        If (IconChanged=True) And (IconSaved=False) Then SaveFirst;
                        LoadIcon;  { Ok! }
                        Ms_Show;
                       End;
             080..120: If MouseDelay(520,080,639,120) Then
                       Begin;
                        If IconNamed Then SaveIcon Else SaveIconAs;
                        Ms_Show;
                       End;
             120..160: If MouseDelay(520,120,639,160) Then
                       Begin;
                        SaveIconAs;
                        Ms_Show;
                       End;
             160..200: If MouseDelay(520,160,639,200) Then
                       Begin;
                        ExportIcon;
                        Ms_Show;
                       End;
             439..479: If MouseDelay(520,439,639,479) Then
                       Begin;
                        If (IconChanged=True) And (IconSaved=False) Then SaveFirst; {Else MouseDelay;}
                        For X:=1 To MaxIcons Do Dispose(PtrIcon[X]);
                        CloseGraph;
                        ChDir(StartUpDir);
                        Halt;
                       End;
             End;
   End;
  End Else If Z=$0002 Then
  Begin;
   Case X Of
   018..192: Case Y Of
             038..212: If (Ctrl=True) And (Alt=True) Then
                       Begin;
                        Ms_Hide;
                        For X:=1 To 25 Do
                        Begin;
                         For Y:=1 To 25 Do Icon.Pixel[X][Y]:=CurrentColor;
                        End;
                        Screen(Icon);
                        Ms_Show;
                       End Else SetPixel(Trunc((X-18)/7)+1,Trunc((Y-38)/7)+1,LightGray);
             End;
   End;
  End;
 Until False;
End.