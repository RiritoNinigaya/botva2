[Code]
//������ ��� ������ � ProgressBar'���. ��� ������ ������� ����������� botva2.iss
//�� ������������� ��� ������ � �������� �����������
//Created by South.Tver 02.2010

type
  TImgPB = record
    Left,
    Top,
    Width,
    Height,
    MaxWidth  : integer;
    img1,img2 : Longint;
    //hParent   : HWND;
  end;

//������� �����������
function ImgPBCreate(hParent :HWND; bk, pb :ansistring; Left, Top, Width, Height :integer):TImgPB;
begin
  Result.Left:=Left+2;
  Result.Top:=Top+2;
  Result.Width:=0;
  Result.Height:=Height-4;
  Result.MaxWidth:=Width-4;
  if Length(pb)>0 then Result.img1:=ImgLoad(hParent,pb,Result.Left,Result.Top,0,Result.Height,True,False) else Result.img1:=0;
  if Length(bk)>0 then Result.img2:=ImgLoad(hParent,bk,Left,Top,Width,Height,True,False) else Result.img2:=0;
  //Result.hParent:=hParent;
  //if (Result.img1<>0) or (Result.img2<>0) then ImgApplyChanges(hParent);
end;

//���������� ������� ������������ (0-100)
procedure ImgPBSetPosition(var PB :TImgPB; Percent :Extended);
var
  NewWidth:integer;
begin
  if PB.img1<>0 then begin
    NewWidth:=Round(PB.MaxWidth*Percent/100);
    if PB.Width<>NewWidth then begin
      PB.Width:=NewWidth;
      ImgSetPosition(PB.img1,PB.Left,PB.Top,PB.Width,PB.Height);
      //ImgApplyChanges(PB.hParent);
    end;
  end;
end;

//�������� ������� ������������ (0-100)
function ImgPBGetPosition(PB :TImgPB):Extended;
begin
  if (PB.img1<>0) and (PB.MaxWidth<>0) then Result:=PB.Width*100/PB.MaxWidth else Result:=0;
end;

//������� �����������
procedure ImgPBDelete(var PB :TImgPB);
begin
  if PB.img1<>0 then ImgRelease(PB.img1);
  if PB.img2<>0 then ImgRelease(PB.img2);
  //if (PB.img1<>0) or (PB.img2<>0) then ImgApplyChanges(PB.hParent);
  PB.img1:=0;
  PB.img2:=0;
end;
