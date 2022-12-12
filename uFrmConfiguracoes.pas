unit uFrmConfiguracoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids,
  BGDBGrid, Datasnap.DBClient, Vcl.Buttons, Vcl.Samples.Spin, Math;

type
  TFrmConfiguracoes = class(TForm)
    PnBotoes: TPanel;
    PnBackups: TPanel;
    DSBackups: TDataSource;
    BtnFechar: TBitBtn;
    BtnGravar: TBitBtn;
    Panel1: TPanel;
    Label1: TLabel;
    CmbTipoBackup: TComboBox;
    SpinTimer: TSpinEdit;
    Label2: TLabel;
    CDSBackups: TClientDataSet;
    CDSBackupsCD_COD: TIntegerField;
    CDSBackupsDH_BKP: TTimeField;
    CDSBackupsTX_CAM: TStringField;
    CDSBackupsTX_HST: TStringField;
    CDSBackupsNM_BAN: TStringField;
    CDSBackupsNM_USU: TStringField;
    CDSBackupsNM_SNH: TStringField;
    CDSBackupsDH_ULT_BKP: TDateTimeField;
    CmbExibirTelaDos: TComboBox;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CDSBackupsNewRecord(DataSet: TDataSet);
    procedure BtnFecharClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnGravarClick(Sender: TObject);
    procedure CDSBackupsBeforePost(DataSet: TDataSet);
    procedure CDSBackupsBeforeDelete(DataSet: TDataSet);
  private
    CodBackup: Integer;
    vPodeFechar: Boolean;
    function GetCodBackup: Integer;
  public
  end;

var
  FrmConfiguracoes: TFrmConfiguracoes;

implementation

{$R *.dfm}


uses uFrmPrincipal;

procedure TFrmConfiguracoes.BtnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfiguracoes.BtnGravarClick(Sender: TObject);
begin
  if CmbTipoBackup.ItemIndex = -1 then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.BtnGravarClick', '##### Tipo do Backup n�o informado.');
    raise Exception.Create('Tipo do Backup n�o informado.');
  end;

  if FrmPrincipal.GravarDadosConfig(CDSBackups, CmbTipoBackup.ItemIndex, CmbExibirTelaDos.ItemIndex = 1, SpinTimer.Value) then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.BtnGravarClick', 'Dados gravados no arquivo ini. Pode Fechar.');
    vPodeFechar := True;
    Close;
  end
  else
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.BtnGravarClick', '##### Houve um erro ao tentar gravar. Tente novamente.');
    Application.MessageBox('Houve um erro ao tentar gravar. Tente novamente.', 'Erro', MB_ICONERROR + MB_OK);
  end;
end;

procedure TFrmConfiguracoes.CDSBackupsBeforeDelete(DataSet: TDataSet);
begin
  if Application.MessageBox('Confirma a exclus�o do registro?', 'Confirma��o', MB_ICONQUESTION + MB_YESNO) = IDNO then
    Abort;
end;

procedure TFrmConfiguracoes.CDSBackupsBeforePost(DataSet: TDataSet);
begin
  if CDSBackupsCD_COD.AsInteger = 0 then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.CDSBackupsBeforePost', '##### C�digo Inv�lido, tente gerar um novo registro antes de gravar.');
    raise Exception.Create('C�digo Inv�lido, tente gerar um novo registro antes de gravar.');
  end;
  if CDSBackupsTX_CAM.AsString.Trim = '' then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.CDSBackupsBeforePost', '##### Caminho do Backup inv�lido.');
    raise Exception.Create('Caminho do Backup inv�lido.');
  end;
  if CDSBackupsTX_HST.AsString.Trim = '' then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.CDSBackupsBeforePost', '##### Host inv�lido.');
    raise Exception.Create('Host inv�lido.');
  end;
  if CDSBackupsNM_BAN.AsString.Trim = '' then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.CDSBackupsBeforePost', '##### Nome do banco de dados inv�lido.');
    raise Exception.Create('Nome do banco de dados inv�lido.');
  end;
  if CDSBackupsNM_USU.AsString.Trim = '' then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.CDSBackupsBeforePost', '##### Usu�rio inv�lido.');
    raise Exception.Create('Usu�rio inv�lido.');
  end;
  if CDSBackupsNM_SNH.AsString.Trim = '' then
  begin
    FrmPrincipal.Log('TFrmConfiguracoes.CDSBackupsBeforePost', '##### Senha inv�lida.');
    raise Exception.Create('Senha inv�lida.');
  end;
end;

procedure TFrmConfiguracoes.CDSBackupsNewRecord(DataSet: TDataSet);
begin
  CDSBackupsCD_COD.AsInteger := GetCodBackup;
  CDSBackupsDH_BKP.AsDateTime := Now;
  CDSBackupsTX_CAM.AsString := ExtractFilePath(Application.ExeName);
  CDSBackupsTX_HST.AsString := 'LOCALHOST';
end;

procedure TFrmConfiguracoes.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := vPodeFechar or (Application.MessageBox('Tem certeza que deseja fechar o sistema?', 'Confirma��o', MB_ICONQUESTION + MB_YESNO) = IDYES);
end;

procedure TFrmConfiguracoes.FormCreate(Sender: TObject);
var
  vTipoBackup, vTimer: Integer;
  vExibirTelaDos: Boolean;
begin
  FrmPrincipal.Log('TFrmConfiguracoes.FormCreate', 'Aberto a tela de Configura��es.');
  CodBackup := 0;
  vPodeFechar := False;
  FrmPrincipal.CriaDataSet(CDSBackups);
  FrmPrincipal.LerDadosConfig(CDSBackups, vTipoBackup, vTimer, vExibirTelaDos, CodBackup);
  CmbTipoBackup.ItemIndex := vTipoBackup;
  CmbExibirTelaDos.ItemIndex := IfThen(vExibirTelaDos, 1, 0);
  SpinTimer.Value := vTimer;
end;

procedure TFrmConfiguracoes.FormDestroy(Sender: TObject);
begin
  FrmPrincipal.Log('TFrmConfiguracoes.FormDestroy', 'Fechado a tela de Configura��es.');
  FrmConfiguracoes := nil;
end;

function TFrmConfiguracoes.GetCodBackup: Integer;
begin
  CodBackup := CodBackup + 1;
  Result := CodBackup;
end;

end.
