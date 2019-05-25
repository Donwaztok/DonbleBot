unit Client;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.OleCtrls,
  SHDocVw, MSHTML, Vcl.ComCtrls, Vcl.ExtCtrls, Registry, Vcl.Buttons, Vcl.MPlayer,
  Vcl.Imaging.pngimage, Math, ShellAPI, Vcl.AppEvnts;

type
  TForm1 = class(TForm)
    Header: TImage;
    PainelLateral: TPanel;
    BTNPainel: TImage;
    CSGODoubleBG: TImage;
    CSGODoubleWeb: TWebBrowser;
    CSGODoubleBTN: TImage;
    CSGODoubleTimer: TTimer;
    CSGODoubleStatusLabel: TLabel;
    CSGODoubleRollLabel: TLabel;
    ConfigIEBTN: TButton;
    CSGODoubleRedEdit: TEdit;
    CSGODoubleGreenEdit: TEdit;
    CSGODoubleBlackEdit: TEdit;
    CSGODoubleBalanceLabel: TLabel;
    RadioGreen: TRadioButton;
    RadioRed: TRadioButton;
    RadioBlack: TRadioButton;
    CSGODoubleRedLabel: TLabel;
    CSGODoubleGreenLabel: TLabel;
    CSGODoubleBlackLabel: TLabel;
    CSGODoubleMaxBetLabel: TLabel;
    AboutBG: TImage;
    CSGODoubleTotalTLabel: TLabel;
    DonateBTN: TImage;
    StatsBTN: TImage;
    Memo1: TMemo;
    Past0BG: TImage;
    Past0Label: TLabel;
    Past1Label: TLabel;
    Past1BG: TImage;
    Past2Label: TLabel;
    Past2BG: TImage;
    Past3Label: TLabel;
    Past3BG: TImage;
    Past4Label: TLabel;
    Past4BG: TImage;
    Past5Label: TLabel;
    Past5BG: TImage;
    Past6Label: TLabel;
    Past6BG: TImage;
    Past7Label: TLabel;
    Past7BG: TImage;
    Past8Label: TLabel;
    Past8BG: TImage;
    Past9Label: TLabel;
    Past9BG: TImage;
    VersaoLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BTNPainelClick(Sender: TObject);
    procedure CSGODoubleBTNClick(Sender: TObject);
    procedure CSGODoubleTimerTimer(Sender: TObject);
    procedure ConfigIEBTNClick(Sender: TObject);
    procedure CSGODoubleBlackEditKeyPress(Sender: TObject; var Key: Char);
    procedure CSGODoubleGreenEditKeyPress(Sender: TObject; var Key: Char);
    procedure CSGODoubleRedEditKeyPress(Sender: TObject; var Key: Char);
    procedure DonateBTNClick(Sender: TObject);
    procedure StatsBTNClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    CDTimeD:Real;
    CDValor:Double;
    CDBalance,CDRoll,CDErros,CDMaxBet,CDTotalTime,CDBalanceIni,CDSaldo:Integer;
    CDStatus,CDRollS,CDColor,CDBetColor: String;
    CDBetEfetuado,CDResultado,Historico: Boolean;
    Buttons: OleVariant;
    CDTotalTimeT:TTime;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Stats;

//=== Começa Aplicação =========================================================
//==============================================================================
//== Função da Versão do Aplicativo ============================================
Function VersaoExe: String;
type
   PFFI = ^vs_FixedFileInfo;
var
   F       : PFFI;
   Handle  : Dword;
   Len     : Longint;
   Data    : Pchar;
   Buffer  : Pointer;
   Tamanho : Dword;
   Parquivo: Pchar;
   Arquivo : String;
begin
   Arquivo  := Application.ExeName;
   Parquivo := StrAlloc(Length(Arquivo) + 1);
   StrPcopy(Parquivo, Arquivo);
   Len := GetFileVersionInfoSize(Parquivo, Handle);
   Result := '';
   if Len > 0 then
   begin
      Data:=StrAlloc(Len+1);
      if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
      begin
         VerQueryValue(Data, '',Buffer,Tamanho);
         F := PFFI(Buffer);
         Result := Format('%d.%d.%d.%d',
                          [HiWord(F^.dwFileVersionMs),
                           LoWord(F^.dwFileVersionMs),
                           HiWord(F^.dwFileVersionLs),
                           Loword(F^.dwFileVersionLs)]
                         );
      end;
      StrDispose(Data);
   end;
   StrDispose(Parquivo);
end;
//=== Criação do Form ==========================================================
procedure TForm1.FormCreate(Sender: TObject);
begin
//Valores Iniciais
CDErros:=0;CDMaxBet:=0;CDTotalTime:=0;CDBalanceIni:=0;
CDBetColor:='';
CDBetEfetuado:=False;CDResultado:=False;
//ETC
PainelLateral.Width:=0;
VersaoLabel.Caption:='['+VersaoExe+']';
end;
//=== Redimensionar Form =======================================================
procedure TForm1.FormResize(Sender: TObject);
begin
CSGODoubleWeb.Width:=CSGODoubleBG.Width-270;
CSGODoubleWeb.Height:=CSGODoubleBG.Height;
CSGODoubleWeb.Left:=270;
end;
//=== Doações ==================================================================
procedure TForm1.DonateBTNClick(Sender: TObject);
begin
ShellExecute(Handle,'open','https://steamcommunity.com/tradeoffer/new/?partner=293918095&token=kb9-Bw_I','','',1);
end;
//=== Abrir Form das Estatisticas ==============================================
procedure TForm1.StatsBTNClick(Sender: TObject);
begin
Form2.Show;
end;
//=== Abrir/Fehcar Painel Lateral ==============================================
procedure TForm1.BTNPainelClick(Sender: TObject);
begin
if PainelLateral.Width=250 then
  while PainelLateral.Width>0 do
    begin
      PainelLateral.Width:=PainelLateral.Width-25;
      Application.ProcessMessages;
      Sleep(5);
    end
else
  while PainelLateral.Width<250 do
    begin
      PainelLateral.Width:=PainelLateral.Width+25;
      Application.ProcessMessages;
      Sleep(5);
    end;
end;
//=== Configurar o IE11 ========================================================
procedure TForm1.ConfigIEBTNClick(Sender: TObject);
var reg: TRegistry;
begin
//Colocar emulador do IE11
reg := TRegistry.Create;
reg.RootKey:=HKEY_CURRENT_USER;
reg.OpenKey('\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION',True);
reg.WriteInteger(ExtractFileName(Application.ExeName),11001);
reg.CloseKey();
reg.Free;
end;
//=== CSGODouble Somente numeros nos Edits =====================================
procedure TForm1.CSGODoubleRedEditKeyPress(Sender: TObject; var Key: Char);
begin
If not CharInSet(key,['0'..'9',#08]) then key:=#0;
end;
procedure TForm1.CSGODoubleGreenEditKeyPress(Sender: TObject; var Key: Char);
begin
If not CharInSet(key,['0'..'9',#08]) then key:=#0;
end;
procedure TForm1.CSGODoubleBlackEditKeyPress(Sender: TObject; var Key: Char);
begin
If not CharInSet(key,['0'..'9',#08]) then key:=#0;
end;
//=== Termina Aplicação ========================================================
//==============================================================================

//=== Começa CSGODouble.gg ====================================================
//==============================================================================
//=== CSGODouble botão Start ===================================================
procedure TForm1.CSGODoubleBTNClick(Sender: TObject);
begin
if CSGODoubleTimer.Enabled=False then
  begin
    CSGODoubleBTN.Picture.LoadFromFile(ExtractFilePath(Application.Name)+'Textures/BTNStop.png');
    CSGODoubleWeb.Navigate('csgodouble.gg/',4);
    CSGODoubleTimer.Enabled:=True;
    CDResultado:=True;
    CDBetEfetuado:=False;
    CDErros:=0;
  end
else
  begin
    CSGODoubleBTN.Picture.LoadFromFile(ExtractFilePath(Application.Name)+'Textures/BTNStart.png');
    //CSGODoubleWeb.Navigate('About:Blank',4);
    CSGODoubleTimer.Enabled:=False;
  end;
end;
//=== Funções do Timer CSGODouble ==============================================
procedure TForm1.CSGODoubleTimerTimer(Sender: TObject);
var I,X:Integer;
begin
CDTotalTime:=CDTotalTime+1;
CDTotalTimeT:=CDTotalTime/SecsPerDay;
CDTimeD:=(CDTotalTimeT*1440)/60;
CSGODoubleTotalTLabel.Caption:='Total Time: '+TimeToStr(CDTotalTimeT)+' | '
              +FloatToStr(CDSaldo/(StrToFloat(format('%n',[CDTimeD]))))+' p/h';
if CSGODoubleWeb.ReadyState=READYSTATE_COMPLETE then
begin
  try //Capturar ID1 - Banner
    CDStatus:=CSGODoubleWeb.OleObject.Document.getElementById('banner').InnerText;
  except
    CDStatus:='* CSGODoubleBot *';
  end;
    if CDStatus='' then CDStatus:='* CSGODoubleBot *';
    CSGODoubleStatusLabel.Caption:=CDStatus;
  try //Capturar ID2 - Balance
    CDBalance:=CSGODoubleWeb.OleObject.Document.getElementById('balance').InnerText;
  except end;
    CSGODoubleBalanceLabel.Caption:='Balance: '+IntToStr(CDBalance);
  //Se for Rolling
  if (copy(CDStatus,0,10)='Rolling in')and(CDBetEfetuado=False) then
    begin
      CDBetEfetuado:=True;
      CDResultado:=False;
      sleep(1000);
      Application.ProcessMessages;
      sleep(1000);
      //Inserir valor e apostar
      if CDBalanceIni=0 then CDBalanceIni:=CDBalance;
      CDBetColor:='';
      CSGODoubleRedLabel.Caption  :='';
      CSGODoubleGreenLabel.Caption:='';
      CSGODoubleBlackLabel.Caption:='';
      if RadioRed.Checked=True then //Se Vermelho
        begin
          CDValor:=StrToInt(CSGODoubleRedEdit.text)*(Power(2,CDErros));
          CSGODoubleWeb.OleObject.Document.all.Item('betAmount',0).value:=CDValor;
          CSGODoubleRedLabel.Caption:=CSGODoubleRedEdit.text+'(2^'+IntToStr(CDErros)
                              +') = '+FloatToStr(CDValor);
          if CDValor>CDMaxBet then CDMaxBet:=Trunc(CDValor);
          CDBetColor:='Red';
          Buttons := CSGODoubleWeb.OleObject.Document.getElementsByTagName('button');
          for I := 0 to Buttons.Length - 1 do
              if Buttons.item(I).innerText = '1 to 7' then Buttons.item(I).click();
        end else
      if RadioGreen.Checked=True then //Se Verde
        begin
          CDValor:=StrToInt(CSGODoubleGreenEdit.text)*(Power(2,CDErros));
          CSGODoubleWeb.OleObject.Document.all.Item('betAmount',0).value:=CDValor;
          CSGODoubleGreenLabel.Caption:=CSGODoubleGreenEdit.text+'(2^'+IntToStr(CDErros)
                              +') = '+FloatToStr(CDValor);
          if CDValor>CDMaxBet then CDMaxBet:=Trunc(CDValor);
          CDBetColor:='Green';
          Buttons := CSGODoubleWeb.OleObject.Document.getElementsByTagName('button');
          for I := 0 to Buttons.Length - 1 do
              if Buttons.item(I).innerText = '0' then Buttons.item(I).click();
        end else
      if RadioBlack.Checked=True then //Se Preto
        begin
          CDValor:=StrToInt(CSGODoubleBlackEdit.text)*(Power(2,CDErros));
          CSGODoubleWeb.OleObject.Document.all.Item('betAmount',0).value:=CDValor;
          CSGODoubleBlackLabel.Caption:=CSGODoubleBlackEdit.text+'(2^'+IntToStr(CDErros)
                              +') = '+FloatToStr(CDValor);
          if CDValor>CDMaxBet then CDMaxBet:=Trunc(CDValor);
          CDBetColor:='Black';
          Buttons := CSGODoubleWeb.OleObject.Document.getElementsByTagName('button');
          for I := 0 to Buttons.Length - 1 do
              if Buttons.item(I).innerText = '8 to 14' then Buttons.item(I).click();
        end;
      //Start Balance, Saldo e Max Bet
      CDSaldo:=CDBalance-CDBalanceIni;
      if CDSaldo>0 then
        CSGODoubleMaxBetLabel.Caption:='Start Balance: '+IntToStr(CDBalanceIni)
          +'(+'+IntToStr(CDSaldo)+') | Max Bet: '+IntToStr(CDMaxBet)
      else
        CSGODoubleMaxBetLabel.Caption:='Start Balance: '+IntToStr(CDBalanceIni)
          +'('+IntToStr(CDSaldo)+') | Max Bet: '+IntToStr(CDMaxBet);
      Historico:=True;
    end;
  //se for CSGODouble rolled ...!
  if (copy(CDStatus,0,17)='CSGODouble rolled')and(CDResultado=False) then
    begin
      //Capturar o resultado
      CDRollS:='';
      //Somente Numeros
      for I := 1 To Length(CDStatus) do
        if CharInSet(CDStatus[I],['0'..'9']) Then CDRollS:=CDRollS+CDStatus[I];
      CDRoll:=StrToInt(CDRollS);
      //Verificando a cor
      if CDRoll= 0 then CDColor:='Green';
      if CDRoll= 1 then CDColor:='Red';
      if CDRoll= 2 then CDColor:='Red';
      if CDRoll= 3 then CDColor:='Red';
      if CDRoll= 4 then CDColor:='Red';
      if CDRoll= 5 then CDColor:='Red';
      if CDRoll= 6 then CDColor:='Red';
      if CDRoll= 7 then CDColor:='Red';
      if CDRoll= 8 then CDColor:='Black';
      if CDRoll= 9 then CDColor:='Black';
      if CDRoll=10 then CDColor:='Black';
      if CDRoll=11 then CDColor:='Black';
      if CDRoll=12 then CDColor:='Black';
      if CDRoll=13 then CDColor:='Black';
      if CDRoll=14 then CDColor:='Black';
      CSGODoubleRollLabel.Caption:=IntToStr(CDRoll)+' | '+CDColor;
      //Acertando ou Errando
      if CDBetColor<>'' then
        if CDBetColor<>CDColor then CDErros:=CDErros+1 else CDErros:=0;
      //Permitir uma nova aposta
      CDResultado:=True;
      CDBetEfetuado:=False;
      //Historico
      Historico:=True;
    end;
  if Historico=True then
    begin
      //Histórico
      Memo1.Text:=CSGODoubleWeb.OleObject.Document.getElementById('past').innertext;
      //1° Past
      Past0Label.Caption:=Memo1.Lines[18];
        if (StrToInt(Past0Label.Caption)<>0) then begin
          if (StrToInt(Past0Label.Caption)<=7) then begin
            Past0BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past0BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past0BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //2° Past
      Past1Label.Caption:=Memo1.Lines[16];
        if (StrToInt(Past1Label.Caption)<>0) then begin
          if (StrToInt(Past1Label.Caption)<=7) then begin
            Past1BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past1BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past1BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //3° Past
      Past2Label.Caption:=Memo1.Lines[14];
        if (StrToInt(Past2Label.Caption)<>0) then begin
          if (StrToInt(Past2Label.Caption)<=7) then begin
            Past2BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past2BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past2BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //4° Past
      Past3Label.Caption:=Memo1.Lines[12];
        if (StrToInt(Past3Label.Caption)<>0) then begin
          if (StrToInt(Past3Label.Caption)<=7) then begin
            Past3BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past3BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past3BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //5° Past
      Past4Label.Caption:=Memo1.Lines[10];
        if (StrToInt(Past4Label.Caption)<>0) then begin
          if (StrToInt(Past4Label.Caption)<=7) then begin
            Past4BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past4BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past4BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //6° Past
      Past5Label.Caption:=Memo1.Lines[8];
        if (StrToInt(Past5Label.Caption)<>0) then begin
          if (StrToInt(Past5Label.Caption)<=7) then begin
            Past5BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past5BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past5BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //7° Past
      Past6Label.Caption:=Memo1.Lines[6];
        if (StrToInt(Past6Label.Caption)<>0) then begin
          if (StrToInt(Past6Label.Caption)<=7) then begin
            Past6BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past6BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past6BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //8° Past
      Past7Label.Caption:=Memo1.Lines[4];
        if (StrToInt(Past7Label.Caption)<>0) then begin
          if (StrToInt(Past7Label.Caption)<=7) then begin
            Past7BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past7BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past7BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //9° Past
      Past8Label.Caption:=Memo1.Lines[2];
        if (StrToInt(Past8Label.Caption)<>0) then begin
          if (StrToInt(Past8Label.Caption)<=7) then begin
            Past8BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past8BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past8BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      //10° Past
      Past9Label.Caption:=Memo1.Lines[0];
        if (StrToInt(Past9Label.Caption)<>0) then begin
          if (StrToInt(Past9Label.Caption)<=7) then begin
            Past9BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Red.png')
          end else Past9BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Gray.png')
        end else Past9BG.Picture.LoadFromFile
                    (ExtractFilePath(Application.Name)+'Textures/Green.png');
      Historico:=False;
    end;
  //Recarregar se desconectar
  try
  Memo1.Text:=CSGODoubleWeb.OleObject.Document.getElementByID('chatArea').innerText;
  for X := 0 to Memo1.Lines.Count-1 do
    if Memo1.Lines[X]='Connection lost...' then CSGODoubleWeb.Refresh;
  Memo1.Clear;
  except end;
end;
end;//Fim
//=== Termina CSGODouble.gg ===================================================
//==============================================================================
end.
