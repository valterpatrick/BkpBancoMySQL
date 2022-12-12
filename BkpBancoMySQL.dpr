program BkpBancoMySQL;

uses
  Vcl.Forms,
  uFrmPrincipal in 'uFrmPrincipal.pas' {FrmPrincipal},
  uFrmConfiguracoes in 'uFrmConfiguracoes.pas' {FrmConfiguracoes}{,
  Funcoes in '..\..\Shared\Funcoes.pas'};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
