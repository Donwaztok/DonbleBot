program DonbleBot;



uses
  Vcl.Forms,
  Client in 'Forms\Client.pas' {Form1},
  Stats in 'Forms\Stats.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
