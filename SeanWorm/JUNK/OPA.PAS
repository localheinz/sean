Program MCBMine;
Uses Dos,Crt,SeAnHelp;
Type MCBRecord  = Record
                   Flag     : Char;
                   OwnerPSP : Word;
                   Size     : Word;
                   Reserved : Array[1..3] Of Byte;
                   OwnerID  : Array[1..8] Of Char;
                  End;
     PSPRecord  = Record
                   Int20          : Array[1..2] Of Byte;
                   MemEnd         : Word;
                   Nothing1       : Byte;
                   CPMJump        : Array[1..5] Of Byte;
                   OrgInt22       : Pointer;
                   OrgInt23       : Pointer;
                   OrgInt24       : Pointer;
                   ParentPSPSeg   : Word;
                   JFT            : Array[1..20] Of Byte;
                   EnvironmentSeg : Word;
                   LastSSSP       : Pointer;
                   JFTSize        : Word;
                   JFTAddress     : Pointer;
                   PreviousPSP    : Pointer;
                   Nothing2       : Array[1..20] Of Byte;
                   DOSJump        : Array[1..3] Of Byte;
                   Nothing3       : Array[1..2] Of Byte;
                   ExtFCBPart1    : Array[1..7] Of Byte;
                   FCBPart1       : Array[1..16] Of Byte;
                   FCBPart2       : Array[1..16] Of Byte;
                   Nothing4       : Array[1..4] Of Byte;
                   CmdLineDTA     : Array[1..128] Of Char;
                  End;
     MCBPointer = ^MCBRecord;
     PSPPointer = ^PSPRecord;
Var CurrentMCB : MCBPointer;
    CurrentPSP : PSPPointer;
    LastMCB    : Boolean;
    I          : Integer;
    W          : Word;
    S          : String;
    X          : String;

Function CurrentProgram : String;
Var R       : Registers;
    S       : String;
    B       : Byte;
    Segment : Word;
Begin
 R.Ah:=$62;
 Intr($21,R);
 Segment:=R.Bx;
 CurrentPSP:=Ptr(R.Bx,$0000);
 LastMCB:=False;
 S:='';
 B:=3;
 Repeat;
  S:=S+CurrentPSP^.CmdLineDTA[B];
  Inc(B);
 Until CurrentPSP^.CmdLineDTA[B]=#13;
 CurrentProgram:=Gross(S+'.EXE');
End;


Begin
 ClrScr;
 WriteLn(CurrentCMDLine);
End.