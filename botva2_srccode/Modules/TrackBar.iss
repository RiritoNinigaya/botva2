[Code]
//������ ��� ������ � TrackBar'���. ��� ������ ������� ����������� botva2.iss
//�� ������������� ��� ������ � �������� �����������
//Created by South.Tver 09.2010

//������� �������
//function ImgTBCreate(Parent: HWND; BkgImg, BtnImg:AnsiString; BkgLeft, BkgTop, BkgWidth, BkgHeight, MinX, MaxX, BtnTop, BtnWidth, BtnHeight, BtnShadowWidth:integer):integer;
//BkgImg    - �������� ��� ���� ��������
//BtnImg    - �������� ��� ������ ��������
//Parent    - ����� ������������� ����
//BkgLeft,
//BkgTop,
//BkgWidth,
//BkgHeight - ���������� ������ �������� ���� � ������/������ ������� �������� � ����������� ������������� ���� (Parent)
//MinX,
//MaxX      - ������� �����/������ ��������� �� ��� �, � �������� ������� ����� ��������� ������ (�������) �������� � ����������� Parent
//BtnTop,
//BtnWidth,
//BtnHeight,
//BtnShadowWidth - ��. ����������� ��������� � BtnCreate

//�� ���� ����������� ��������/���������� ind - ��������, ������� ������� ������� ImgTBCreate

//������� �������
//procedure ImgTkDelete(ind:integer);

//�������� ������� ������� �������� (0-100)
//function ImgTBGetPosition(ind:integer):integer;

//���������� ������� ������� �������� (0-100)
//procedure ImgTBSetPosition(ind, pos:integer);

//���������� ��������� ��������
//procedure ImgTBSetVisibility(ind:integer; Value:boolean);

//���������� ���������, ������� ����� ����������� ��� ����� ������� ��������
//procedure ImgTBSetChangePosEvent(ind:integer;proc:TImgTBChangePos);

type
  TImgTBProc = function (h:hWnd;Msg,wParam,lParam:Longint):Longint;
  TImgTBChangePos = procedure (pos:integer);

  TImgTrackBar = record
    bkgimg      : Longint;
    hbtn        : HWND;
    op          : Longint;
    MinX,
    MaxX        : integer;
    IsMouseDown : boolean;
    CurStartPos : TPoint;
    OnChangePos : TImgTBChangePos;
  end;

  TATB = array of TImgTrackBar;

var
  ATB : TATB;

function SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint; external 'SetWindowLongA@user32.dll stdcall';
function CallWindowProc(lpPrevWndFunc: Longint; hWnd: HWND; Msg: UINT; wParam, lParam: Longint): Longint; external 'CallWindowProcA@user32.dll stdcall';
function CallBackProc(P:TImgTBProc;ParamCount:integer):LongWord; external 'wrapcallbackaddr@{tmp}\CallbackCtrl.dll stdcall delayload';
function ScreenToClient(hWnd: HWND; var lpPoint: TPoint): BOOL; external 'ScreenToClient@user32.dll stdcall';
function GetCursorPos(var lpPoint: TPoint): BOOL; external 'GetCursorPos@user32.dll stdcall';
function GetAncestor(hwnd: HWND; gaFlags: UINT): HWND; external 'GetAncestor@user32.dll stdcall';
function DestroyWindow(hWnd: HWND): BOOL; external 'DestroyWindow@user32.dll stdcall';

function ImgTBGetInd(h:HWND):integer;
var
  i:integer;
begin
  Result:=-1;
  for i:=0 to GetArrayLength(ATB)-1 do
    if ATB[i].hbtn=h then begin
      Result:=i;
      Break;
    end;
end;

procedure ImgTBBtnMouseDown(h:HWND);
var
  Left,Top,Width,Height:integer;
  trind : integer;
begin
  trind:=ImgTBGetInd(h);
  if trind=-1 then Exit;
  GetCursorPos(ATB[trind].CurStartPos);
  ScreenToClient(h,ATB[trind].CurStartPos);
  ATB[trind].IsMouseDown:=True;
end;

procedure ImgTBBtnMouseUp(h:HWND);
var
  trind : integer;
begin
  trind:=ImgTBGetInd(h);
  if trind=-1 then Exit;
  ATB[trind].IsMouseDown:=False;
end;

function ImgTBGetPosition(ind:integer):integer;
var
  Left,Top,Width,Height:integer;
begin
  BtnGetPosition(ATB[ind].hbtn,Left,Top,Width,Height);
  Result:=Round((Left-ATB[ind].MinX)*100/(ATB[ind].MaxX-ATB[ind].MinX));
end;

procedure ImgTBSetPosition(ind, pos:integer);
var
  Left,Top,Width,Height:integer;
begin
  if pos<0 then pos:=0;
  if pos>100 then pos:=100;
  BtnGetPosition(ATB[ind].hbtn,Left,Top,Width,Height);
  Left:=ATB[ind].MinX+Round(pos*(ATB[ind].MaxX-ATB[ind].MinX)/100);
  BtnSetPosition(ATB[ind].hbtn,Left,Top,Width,Height);
  if ATB[ind].OnChangePos<>nil then ATB[ind].OnChangePos(pos);
end;

procedure ImgTBSetVisibility(ind:integer; Value:boolean);
begin
  BtnSetVisibility(ATB[ind].hbtn,Value);
  ImgSetVisibility(ATB[ind].bkgimg,Value);
  //ImgApplyChanges(GetAncestor(ATB[ind].hbtn,1));
end;

function ImgTBBtnProc(h:hWnd;Msg,wParam,lParam:Longint):Longint;
var
  Left,Top,Width,Height:integer;
  trind : integer;
  p     : TPoint;
  Parent: HWND;
begin
  trind:=ImgTBGetInd(h);
  if trind=-1 then begin
    Result:=0;
    Exit;
  end;
  if Msg=$2 then SetWindowLong(h,-4,ATB[trind].op);
  Result:=CallWindowProc(ATB[trind].op,h,Msg,wParam,lParam);
  case Msg of
    $47 : if ATB[trind].OnChangePos<>nil then ATB[trind].OnChangePos(ImgTBGetPosition(trind));
    $200: if ATB[trind].IsMouseDown then begin
      Parent:=GetAncestor(h,1);
      GetCursorPos(p);
      ScreenToClient(Parent,p);
      BtnGetPosition(h,Left,Top,Width,Height);
      Left:=p.X-ATB[trind].CurStartPos.X;
      if Left<ATB[trind].MinX then Left:=ATB[trind].MinX;
      if Left>ATB[trind].MaxX then Left:=ATB[trind].MaxX;
      BtnSetPosition(h,Left,Top,Width,Height);
      ImgSetVisibility(ATB[trind].bkgimg,not ImgGetVisibility(ATB[trind].bkgimg)); //����� ������-�� �������� � ������ �������� �� ���������
      ImgSetVisibility(ATB[trind].bkgimg,not ImgGetVisibility(ATB[trind].bkgimg)); //�� ��� ���� ����� ���������
      ImgApplyChanges(Parent);                                                     //�� ���������������� ������ (������� ��������)
    end;
  end;
end;

function ImgTBCreate(Parent: HWND; BkgImg, BtnImg:AnsiString; BkgLeft, BkgTop, BkgWidth, BkgHeight, MinX, MaxX, BtnTop, BtnWidth, BtnHeight, BtnShadowWidth:integer):integer;
var
  i:integer;
begin
  i:=GetArrayLength(ATB);
  SetArrayLength(ATB,i+1);
  ATB[i].OnChangePos:=nil;
  ATB[i].MinX:=MinX;
  ATB[i].MaxX:=MaxX-BtnWidth;
  ATB[i].IsMouseDown:=False;
  ATB[i].bkgimg:=ImgLoad(Parent,BkgImg,BkgLeft,BkgTop,BkgWidth,BkgHeight,True,False);
  ATB[i].hbtn:=BtnCreate(Parent,MinX,BtnTop,BtnWidth,BtnHeight,BtnImg,BtnShadowWidth,False);
  BtnSetEvent(ATB[i].hbtn,BtnMouseDownEventID,WrapBtnCallback(@ImgTBBtnMouseDown,1));
  BtnSetEvent(ATB[i].hbtn,BtnMouseUpEventID,WrapBtnCallback(@ImgTBBtnMouseUp,1));
  ATB[i].op:=SetWindowLong(ATB[i].hbtn,-4,CallBackProc(@ImgTBBtnProc,4));
  Result:=i;
  //ImgApplyChanges(Parent);
end;

procedure ImgTBDelete(ind:integer);
//var
//  Last,i:integer;
begin
//������ ������� ������� �������
//  Last:=GetArrayLength(ATB)-1;
//  if (ind>=0) and (ind<=Last) then begin
    ImgRelease(ATB[ind].bkgimg);
    ATB[ind].bkgimg:=0;
    DestroyWindow(ATB[ind].hbtn);
    ATB[ind].hbtn:=0;
//    if ind<Last then
//      for i:=ind to Last-1 do begin
//        ATB[i]:=ATB[i+1];
//      end;
//    SetArrayLength(ATB,Last);
//  end;
end;

procedure ImgTBSetChangePosEvent(ind:integer;proc:TImgTBChangePos);
begin
  ATB[ind].OnChangePos:=proc;
end;

