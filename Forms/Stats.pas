unit Stats;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw,
  Vcl.StdCtrls, dateUtils, Vcl.Imaging.GIFImg, Vcl.ExtCtrls, Math, Vcl.ComCtrls,
  Vcl.Imaging.pngimage;

type
  TForm2 = class(TForm)
    WebBrowser1: TWebBrowser;
    ScanBTN: TButton;
    TotalBlackLabel: TLabel;
    TrainBlackLabel: TLabel;
    TotalGreenLabel: TLabel;
    TrainGreenLabel: TLabel;
    TotalRedLabel: TLabel;
    TrainRedLabel: TLabel;
    L0: TLabel;
    SimEdit: TEdit;
    BlackSimLabel: TLabel;
    GreenSimLabel: TLabel;
    RedSimLabel: TLabel;
    NotBlackLabel: TLabel;
    NotGreenLabel: TLabel;
    NotRedLabel: TLabel;
    ScanGif: TImage;
    MemoBTN: TButton;
    Memo1: TMemo;
    StatusBarBG: TImage;
    ProgressBar1: TProgressBar;
    ComboBox1: TComboBox;
    ProgressLabel: TLabel;
    BGR: TImage;
    BGRT: TImage;
    BGRN: TImage;
    BGG: TImage;
    BGGT: TImage;
    BGGN: TImage;
    BGB: TImage;
    BGBT: TImage;
    BGBN: TImage;
    BGRS: TImage;
    BGGS: TImage;
    BGBS: TImage;
    StatsBG: TImage;
    BGG00: TImage;
    BGR01: TImage;
    BGR02: TImage;
    BGR03: TImage;
    BGR04: TImage;
    BGR05: TImage;
    BGR06: TImage;
    BGR07: TImage;
    BGB08: TImage;
    BGB09: TImage;
    BGB10: TImage;
    BGB11: TImage;
    BGB12: TImage;
    BGB13: TImage;
    BGB14: TImage;
    InfoLabel: TLabel;
    ScrollBox1: TScrollBox;
    Button1: TButton;
    procedure ScanBTNClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SimEditKeyPress(Sender: TObject; var Key: Char);
    procedure SimEditChange(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams) ; override;
    procedure MemoBTNClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    TotalBlack,TotalRed,TotalGreen,
    TrainBlack,TrainRed,TrainGreen,
    Black,Red,Green,
    NotRed,TrainNotRed,
    NotGreen,TrainNotGreen,
    NotBlack,TrainNotBlack :Integer;
    numbers: array [0..14] of Integer;
    Scaneando:Boolean;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

//=== Ativação do Form =========================================================
procedure TForm2.FormActivate(Sender: TObject);
var
  i:Integer;
  ovLinks: OleVariant;
begin
Form2.WebBrowser1.Navigate('csgodouble.gg/rolls.php');
//Verificar Links
while WebBrowser1.ReadyState<>READYSTATE_COMPLETE do
  begin
    Application.ProcessMessages;
    sleep(100);
    Application.ProcessMessages;
  end;
Memo1.Clear;
ovLinks:=WebBrowser1.OleObject.Document.All.Tags('A');
if ovLinks.Length > 0 then
  for i := 0 to ovLinks.Length-1 do
    if Pos('/rolls.php?id=', ovLinks.Item(i).href) > 0 then
      Memo1.Lines.Add(ovLinks.Item(i));
ScanBTN.Enabled:=True;
end;
//=== Rolar o Mouse ============================================================
procedure TForm2.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
with ScrollBox1.VertScrollBar do
  begin
    if (Position <= (Range - Increment)) then
      Position := Position + Increment
    else
      Position := Range - Increment;
  end;
end;
procedure TForm2.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
with ScrollBox1.VertScrollBar do
  begin
    if (Position >= Increment) then
      Position := Position - Increment
    else
      Position := 0;
  end;
end;
//=== Abrir memo com os links ==================================================
procedure TForm2.MemoBTNClick(Sender: TObject);
begin
if Memo1.Width=300 then
  while Memo1.Width>0 do
    begin
      Memo1.Width:=Memo1.Width-30;
      MemoBTN.Left:=Memo1.Width;
      MemoBTN.Caption:='>';
      Application.ProcessMessages;
      Sleep(5);
    end
else
  while Memo1.Width<300 do
    begin
      Memo1.Width:=Memo1.Width+30;
      MemoBTN.Left:=Memo1.Width;
      MemoBTN.Caption:='<';
      Application.ProcessMessages;
      Sleep(5);
    end;
end;
//=== Form na TaskBar ==========================================================
procedure TForm2.CreateParams(var Params: TCreateParams) ;
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := 0;
end;
//=== Edit de simulação ========================================================
procedure TForm2.SimEditChange(Sender: TObject);
var x:double;
begin
if SimEdit.Text='' then SimEdit.Text:='0';
//Red
x:=StrToFloat(SimEdit.Text)*(Power(2,TrainNotRed));
RedSimLabel.Caption:=
    'Red: '+SimEdit.Text+'*(2^'+IntToStr(TrainNotRed)+')= '+FloatToStr(x);
//Green
x:=StrToFloat(SimEdit.Text)*(Power(2,TrainNotGreen));
GreenSimLabel.Caption:=
    'Green: '+SimEdit.Text+'*(2^'+IntToStr(TrainNotGreen)+')= '+FloatToStr(x);
//Black
x:=StrToFloat(SimEdit.Text)*(Power(2,TrainNotBlack));
BlackSimLabel.Caption:=
    'Black: '+SimEdit.Text+'*(2^'+IntToStr(TrainNotBlack)+')= '+FloatToStr(x);
end;
//=== Somente Numeros ==========================================================
procedure TForm2.SimEditKeyPress(Sender: TObject; var Key: Char);
begin
If not CharInSet(key,['0'..'9',#08]) then key:=#0;
end;
//=== Escanear valores =========================================================
procedure TForm2.ScanBTNClick(Sender: TObject);
var
  I,X,Sites:integer;
  ovTables: OleVariant;
begin
//Se botão Cancel
if ScanBTN.Caption='Cancel' then Scaneando:=False;
//Se botão Scan
if ScanBTN.Caption='Scan' then
begin
//detalhes começa
ScanBTN.Caption:='Cancel';
Scaneando:=True;
Scangif.Visible:=True;
(ScanGif.Picture.Graphic as TGIFImage).Animate:=True;
//Valores Iniciais
TotalBlack:=0; TotalRed:=0; TotalGreen:=0;
TrainBlack:=0; TrainRed:=0; TrainGreen:=0;
Black:=0; Red:=0; Green:=0;
NotRed:=0;   TrainNotRed:=0;
NotGreen:=0; TrainNotGreen:=0;
NotBlack:=0; TrainNotBlack:=0;
for I := 0 to 14 do numbers[I]:=0;
//Contar quantos dias scanear
Sites:=0;
if ComboBox1.ItemIndex=0 then Sites:=1-1;
if ComboBox1.ItemIndex=1 then Sites:=2-1;
if ComboBox1.ItemIndex=2 then Sites:=3-1;
if ComboBox1.ItemIndex=3 then Sites:=4-1;
if ComboBox1.ItemIndex=4 then Sites:=5-1;
if ComboBox1.ItemIndex=5 then Sites:=10-1;
if ComboBox1.ItemIndex=6 then Sites:=25-1;
if ComboBox1.ItemIndex=7 then Sites:=Memo1.Lines.Count-1;
//Progress Bar
ProgressBar1.Visible:=True;
ProgressBar1.Position:=0;
ProgressBar1.Min:=0;
ProgressBar1.Max:=Sites;
ProgressLabel.Caption:='0/'+IntToStr(Sites+1);
//Verificar todos os links e abrir
for X := 0 to Sites do
  begin
    if Scaneando=False then Break;
    WebBrowser1.Navigate(Memo1.Lines[X]);
    //esperar o site completar
    while WebBrowser1.ReadyState<>READYSTATE_COMPLETE do
      begin
        sleep(100);
        Application.ProcessMessages
      end;
    //scanear valores
    ovTables:=WebBrowser1.OleObject.Document.getElementsByTagName('td');
      for I := 0 to ovTables.Length - 1 do
        begin
        //Red
          if (ovTables.item(I).innerText = '1')or
             (ovTables.item(I).innerText = '2')or
             (ovTables.item(I).innerText = '3')or
             (ovTables.item(I).innerText = '4')or
             (ovTables.item(I).innerText = '5')or
             (ovTables.item(I).innerText = '6')or
             (ovTables.item(I).innerText = '7') then
            begin
              TotalBlack:=TotalBlack+Black; if TrainBlack<=Black then TrainBlack:=Black;
              TotalGreen:=TotalGreen+Green; if TrainGreen<=Green then TrainGreen:=Green;
              if TrainNotRed<=NotRed then TrainNotRed:=NotRed;
              Black:=0; Green:=0; NotRed:=0;
              Red:=Red+1;
              NotGreen:=NotGreen+1;
              NotBlack:=NotBlack+1;
              numbers[StrToInt(ovTables.item(I).innerText)]:=
                numbers[StrToInt(ovTables.item(I).innerText)]+1;
            end;
        //Green
          if (ovTables.item(I).innerText = '0') then
            begin
              TotalBlack:=TotalBlack+Black; if TrainBlack<=Black then TrainBlack:=Black;
              TotalRed:=TotalRed+Red; if TrainRed<=Red then TrainRed:=Red;
              if TrainNotGreen<=NotGreen then TrainNotGreen:=NotGreen;
              Black:=0; Red:=0; NotGreen:=0;
              Green:=Green+1;
              NotBlack:=NotBlack+1;
              NotRed:=NotRed+1;
              numbers[StrToInt(ovTables.item(I).innerText)]:=
                numbers[StrToInt(ovTables.item(I).innerText)]+1;
            end;
        //Black
          if (ovTables.item(I).innerText = '8')or
             (ovTables.item(I).innerText = '9')or
             (ovTables.item(I).innerText = '10')or
             (ovTables.item(I).innerText = '11')or
             (ovTables.item(I).innerText = '12')or
             (ovTables.item(I).innerText = '13')or
             (ovTables.item(I).innerText = '14') then
            begin
              TotalRed:=TotalRed+Red; if TrainRed<=Red then TrainRed:=Red;
              TotalGreen:=TotalGreen+Green; if TrainGreen<=Green then TrainGreen:=Green;
              if TrainNotBlack<=NotBlack then TrainNotBlack:=NotBlack;
              Red:=0; Green:=0; NotBlack:=0;
              Black:=Black+1;
              NotGreen:=NotGreen+1;
              NotRed:=NotRed+1;
              numbers[StrToInt(ovTables.item(I).innerText)]:=
                numbers[StrToInt(ovTables.item(I).innerText)]+1;
            end;
          ProgressBar1.Position:=X;
          ProgressLabel.Caption:=IntToStr(X+1)+'/'+IntToStr(Sites+1);
        end;
    //Total Label
    TotalRedLabel.Caption:='Total Red: '+IntToStr(TotalRed);
    TotalGreenLabel.Caption:='Total Green: '+IntToStr(TotalGreen);
    TotalBlackLabel.Caption:='Total Black: '+IntToStr(TotalBlack);
    //Train Label
    TrainRedLabel.Caption:='Train Red: '+IntToStr(TrainRed);
    TrainGreenLabel.Caption:='Train Green: '+IntToStr(TrainGreen);
    TrainBlackLabel.Caption:='Train Black: '+IntToStr(TrainBlack);
    //Not Label
    NotRedLabel.Caption:='Not Red Train: '+IntToStr(TrainNotRed);
    NotGreenLabel.Caption:='Not Green Train: '+IntToStr(TrainNotGreen);
    NotBlackLabel.Caption:='Not Black Train: '+IntToStr(TrainNotBlack);
    //Numeros no label
    L0.Caption:='';
    for I := 0 to 14 do L0.Caption:=L0.Caption+IntToStr(I)+': '+IntToStr(Numbers[I])+#13;
  end;
end;
//detalhes fim
ProgressBar1.Visible:=False;
SimEdit.Enabled:=True;
Scangif.Visible:=False;
ScanBTN.Caption:='Scan';
(ScanGif.Picture.Graphic as TGIFImage).Animate:=False;
end;
end.
