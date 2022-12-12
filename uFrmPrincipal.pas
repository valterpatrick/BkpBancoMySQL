unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Data.DB, Datasnap.DBClient, IniFiles, Math,
  DateUtils, StrUtils, MidasLib;

type
  TFrmPrincipal = class(TForm)
    PnBotoes: TPanel;
    PnLogs: TPanel;
    Memo: TMemo;
    BtnConfiguracoes: TBitBtn;
    BtnBackup: TBitBtn;
    BtnSobre: TBitBtn;
    BtnSair: TBitBtn;
    Timer: TTimer;
    CDSBackups: TClientDataSet;
    CDSBackupsCD_COD: TIntegerField;
    CDSBackupsDH_BKP: TTimeField;
    CDSBackupsTX_CAM: TStringField;
    CDSBackupsTX_HST: TStringField;
    CDSBackupsNM_BAN: TStringField;
    CDSBackupsNM_USU: TStringField;
    CDSBackupsNM_SNH: TStringField;
    CDSBackupsDH_ULT_BKP: TDateTimeField;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Maximizar1: TMenuItem;
    Minimizar1: TMenuItem;
    Fechar1: TMenuItem;
    procedure BtnSairClick(Sender: TObject);
    procedure BtnSobreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnConfiguracoesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnBackupClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Maximizar1Click(Sender: TObject);
    procedure Minimizar1Click(Sender: TObject);
    procedure Fechar1Click(Sender: TObject);
  private
    vTipoBackup: Integer;
    vExibirTelaDos: Boolean;
    vCaption: String;
    vDataLimparMemo: TDate;
    procedure HabilitaControles(Habilitar: Boolean = True);
    procedure VerificaBackup;
    procedure Backup;
    procedure DeleteFiles(NomePasta: String);
    procedure LimparDados;
  public
    procedure Log(Modulo, Msg: string);
    procedure CriaDataSet(Dataset: TClientDataSet);
    procedure LerDadosConfig(Dataset: TClientDataSet; out TipoBackup: Integer; out TempoVerificacao: Integer; out ExibirTelaDos: Boolean; out CodBackup: Integer);
    function GravarDadosConfig(Dataset: TClientDataSet; TipoBackup: Integer; ExibirTelaDos: Boolean; TempoVerificacao: Integer): Boolean;
    {Biblioteca Funções}
    function OpenExec(FileName: String; Params: String = ''; Visibility: Integer = SW_SHOWNORMAL; WorkDir: PChar = nil): TProcessInformation;
    function OpenExecAndWait(FileName, Params: String; Visibility: Integer; WorkDir: PChar = nil; Block: Boolean = False): Integer;
    procedure Wait(Time: Cardinal);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}


uses uFrmConfiguracoes {, Funcoes};

procedure TFrmPrincipal.BtnConfiguracoesClick(Sender: TObject);
begin
  try
    Timer.Enabled := False;
    FrmConfiguracoes := TFrmConfiguracoes.Create(Application);
    FrmConfiguracoes.ShowModal;
  finally
    Timer.Enabled := True;
  end;
end;

procedure TFrmPrincipal.Backup;
var
  Config: TIniFile;
  xArquivoBat: TStringList;
  camNomeArquivo, nomeArquivo, comando: String;
begin
  Config := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\config.ini');
  Try
    xArquivoBat := TStringList.Create;
    nomeArquivo := CDSBackupsNM_BAN.AsString.Trim + '_' + FormatDateTime('YYYY-MM-DD_HH-NN', Now);
    camNomeArquivo := ExtractFileDir(CDSBackupsTX_CAM.AsString.Trim) + '\' + nomeArquivo;
    ForceDirectories(ExtractFileDir(Application.ExeName) + '\Arqbat\');
    ForceDirectories(CDSBackupsTX_CAM.AsString.Trim);

    comando := 'mysqldump.exe --column-statistics=0 --compress -u ' + CDSBackupsNM_USU.AsString.Trim + ' -h ' + CDSBackupsTX_HST.AsString.Trim + ' --password=' +
      CDSBackupsNM_SNH.AsString.Trim + ' --databases ' + CDSBackupsNM_BAN.AsString.Trim + ' > "' + camNomeArquivo + '.sql"';
    xArquivoBat.Add(comando);
    xArquivoBat.SaveToFile(ExtractFileDir(Application.ExeName) + '\Arqbat\' + nomeArquivo + '.bat');

    Log('TFrmPrincipal.Backup', 'Realizando backup (' + IfThen(vTipoBackup = 1, 'Todos ao mesmo tempo', 'Um por vez (aguardar)') + '). Comando: ' + comando);
    if vTipoBackup = 1 then // Todos ao mesmo tempo
    begin
      if vExibirTelaDos then
        OpenExec(ExtractFileDir(Application.ExeName) + '\Arqbat\' + nomeArquivo + '.bat', '', SW_NORMAL)
      else
        OpenExec(ExtractFileDir(Application.ExeName) + '\Arqbat\' + nomeArquivo + '.bat', '', SW_HIDE);
      Wait(100);
    end
    else // Um por vez (aguardar)
    begin
      if vExibirTelaDos then
        OpenExecAndWait(ExtractFileDir(Application.ExeName) + '\Arqbat\' + nomeArquivo + '.bat', '', SW_NORMAL)
      else
        OpenExecAndWait(ExtractFileDir(Application.ExeName) + '\Arqbat\' + nomeArquivo + '.bat', '', SW_HIDE);
    end;
    Config.WriteDateTime('BKP_' + FormatFloat('000', CDSBackupsCD_COD.AsInteger), 'DH_ULT_BKP', Now);
  Finally
    Config.Free;
    FreeAndNil(xArquivoBat);
  End;
end;

procedure TFrmPrincipal.DeleteFiles(NomePasta: String);
var
  SR: TSearchRec;
  J: Integer;
begin
  try
    J := FindFirst(NomePasta + '*.*', faAnyFile, SR);
    while J = 0 do
    begin
      if (SR.Attr and faDirectory) <> faDirectory then
      begin
        if DeleteFile(NomePasta + SR.Name) then
          Log('TFrmPrincipal.DeleteFiles', 'Arquivo Excluído: ' + NomePasta + SR.Name);
      end;
      J := FindNext(SR);
    end;
  except
    on E: Exception do
    begin
    end;
  end;
end;

procedure TFrmPrincipal.BtnBackupClick(Sender: TObject);
var
  vTimer, vCodBackup: Integer;
begin
  Log('TFrmPrincipal.BtnBackupClick', 'Realizando backup manual.');
  try
    Caption := vCaption + ' [Sistema travado. Aguarde a execução dos backups (manual)]';
    Timer.Enabled := False;
    HabilitaControles(False);
    CriaDataSet(CDSBackups);
    LerDadosConfig(CDSBackups, vTipoBackup, vTimer, vExibirTelaDos, vCodBackup);
    Timer.Interval := vTimer * 60000;

    CDSBackups.First;
    while not CDSBackups.Eof do
    begin
      Backup;

      CDSBackups.Next;
    end;
    Log('TFrmPrincipal.BtnBackupClick', 'Backup manual realizado com sucesso.');
  finally
    Caption := vCaption;
    HabilitaControles(True);
    Timer.Enabled := True;
  end;
end;

procedure TFrmPrincipal.BtnSobreClick(Sender: TObject);
begin
  Application.MessageBox('Desenvolvido por Valter Patrick Silva Ferreira (valterpatrick@hotmail.com).',
    'Informação', MB_ICONINFORMATION + MB_OK);
end;

procedure TFrmPrincipal.CriaDataSet(Dataset: TClientDataSet);
begin
  if Dataset.Active then
  begin
    Dataset.EmptyDataSet;
    Dataset.Close;
  end;
  Dataset.CreateDataSet;
  Dataset.Open;
end;

procedure TFrmPrincipal.VerificaBackup;
begin
  LimparDados;
  Log('TFrmPrincipal.VerificaBackup', 'Verificando backups a serem feitos...');
  CDSBackups.First;
  while not CDSBackups.Eof do
  begin
    if (TimeOf(Now) >= TimeOf(CDSBackupsDH_BKP.Value)) and (DateOf(CDSBackupsDH_ULT_BKP.AsDateTime) < Date) then
      Backup
    else
      Log('TFrmPrincipal.VerificaBackup', 'Backup banco de dados "' + CDSBackupsNM_BAN.AsString.Trim + '" não realizado. Hora programada: "' + CDSBackupsDH_BKP.AsString + '".');

    CDSBackups.Next;
  end;
end;

procedure TFrmPrincipal.BtnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.Fechar1Click(Sender: TObject);
begin
  Log('TFrmPrincipal.Fechar1Click', 'Clicado para fechar o sistema a partir do TrayIcon.');
  Close;
end;

procedure TFrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Application.MessageBox('Tem certeza que deseja fechar o sistema?', 'Confirmação', MB_ICONQUESTION + MB_YESNO) = IDYES;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  Log('TFrmPrincipal.FormCreate', 'Abrindo o sistema.');
  HabilitaControles(True);
  vCaption := Self.Caption;
  Timer.Enabled := False;
  Timer.Interval := 60000; // Vai aguardar um minuto antes da primeira sincronização
  Timer.Enabled := True;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  Log('TFrmPrincipal.FormDestroy', 'Fechado a tela principal.');
end;

function TFrmPrincipal.GravarDadosConfig(Dataset: TClientDataSet; TipoBackup: Integer; ExibirTelaDos: Boolean; TempoVerificacao: Integer): Boolean;
var
  Config: TIniFile;
  B: TBookmark;
  nomeSecao: String;
begin
  Log('TFrmPrincipal.GravarDadosConfig', 'Gravando dados no arquivo ini.');
  Config := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\config.ini');
  try
    Config.WriteInteger('GERAL', 'TP_BKP', TipoBackup);//Tipo do Backup, ordem do combobox
    Config.WriteInteger('GERAL', 'NR_TMP_TIM', TempoVerificacao);//Tempo de Verificação do Timer
    Config.WriteBool('GERAL', 'TF_EXB_DOS', ExibirTelaDos);//Exibir a tela do DOS quando executar o backup
    Dataset.DisableControls;
    B := Dataset.Bookmark;
    Dataset.First;
    while not Dataset.Eof do
    begin
      nomeSecao := 'BKP_' + FormatFloat('000', Dataset.FieldByName('CD_COD').AsInteger);
      Config.WriteInteger(nomeSecao, 'CD_COD', Dataset.FieldByName('CD_COD').AsInteger);//Indice do Backup
      Config.WriteTime(nomeSecao, 'DH_BKP', Dataset.FieldByName('DH_BKP').Value);//Hora que o backup será realizado
      Config.WriteString(nomeSecao, 'TX_CAM', Dataset.FieldByName('TX_CAM').AsString);//Caminho para salvar o backup
      Config.WriteString(nomeSecao, 'TX_HST', Dataset.FieldByName('TX_HST').AsString);//Host do Banco de dados
      Config.WriteString(nomeSecao, 'NM_BAN', Dataset.FieldByName('NM_BAN').AsString);//Nome do banco de dados
      Config.WriteString(nomeSecao, 'NM_USU', Dataset.FieldByName('NM_USU').AsString);//Nome do usuário do banco de dados
      Config.WriteString(nomeSecao, 'NM_SNH', Dataset.FieldByName('NM_SNH').AsString);//Senha do usuário do banco de dados
      Config.WriteDateTime(nomeSecao, 'DH_ULT_BKP', Dataset.FieldByName('DH_ULT_BKP').AsDateTime);//Data-Hora do último backup

      Dataset.Next;
    end;
    Result := True;
    Log('TFrmPrincipal.GravarDadosConfig', 'Dados gravados no arquivo ini.');
  finally
    Dataset.Bookmark := B;
    Dataset.EnableControls;
    Config.Free;
  end;
end;

procedure TFrmPrincipal.HabilitaControles(Habilitar: Boolean);
begin
  PnBotoes.Enabled := Habilitar;
end;

procedure TFrmPrincipal.LerDadosConfig(Dataset: TClientDataSet; out TipoBackup: Integer; out TempoVerificacao: Integer; out ExibirTelaDos: Boolean; out CodBackup: Integer);
var
  Config: TIniFile;
  listaSecoes: TStringList;
  I, QuantBkp: Integer;
begin
  Log('TFrmPrincipal.LerDadosConfig', 'Lendo dados do arquivo ini.');
  Config := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\config.ini');
  try
    listaSecoes := TStringList.Create;
    Config.ReadSections(listaSecoes); // Lê todas as seções no arquivo INI
    QuantBkp := 0;
    for I := 0 to listaSecoes.Count - 1 do
    begin
      if Pos('BKP_', listaSecoes[I]) > 0 then // Apenas seções com o pré-fixo "BKP_"
      begin
        if listaSecoes[I] = ('BKP_' + FormatFloat('000', Config.ReadInteger(listaSecoes[I], 'CD_COD', 0))) then // Conferir se o código da seção é o mesmo do nome
        begin
          QuantBkp := QuantBkp + 1;
          Dataset.Append;
          Dataset.FieldByName('CD_COD').AsInteger := Config.ReadInteger(listaSecoes[I], 'CD_COD', 0);//Indice do Backup
          Dataset.FieldByName('DH_BKP').Value := Config.ReadTime(listaSecoes[I], 'DH_BKP', StrToTime('00:00:00'));//Hora que o backup será realizado
          Dataset.FieldByName('TX_CAM').AsString := Config.ReadString(listaSecoes[I], 'TX_CAM', ExtractFilePath(Application.ExeName));//Caminho para salvar o backup
          Dataset.FieldByName('TX_HST').AsString := Config.ReadString(listaSecoes[I], 'TX_HST', 'LOCALHOST');//Host do Banco de dados
          Dataset.FieldByName('NM_BAN').AsString := Config.ReadString(listaSecoes[I], 'NM_BAN', '');//Nome do banco de dados
          Dataset.FieldByName('NM_USU').AsString := Config.ReadString(listaSecoes[I], 'NM_USU', '');//Nome do usuário do banco de dados
          Dataset.FieldByName('NM_SNH').AsString := Config.ReadString(listaSecoes[I], 'NM_SNH', '');//Senha do usuário do banco de dados
          Dataset.FieldByName('DH_ULT_BKP').AsDateTime := Config.ReadDateTime(listaSecoes[I], 'DH_ULT_BKP', 0);//Data-Hora do último backup
          Dataset.Post;
          CodBackup := IfThen(CodBackup > Dataset.FieldByName('CD_COD').AsInteger, CodBackup, Dataset.FieldByName('CD_COD').AsInteger);
        end;
      end;
    end;
    TipoBackup := Config.ReadInteger('GERAL', 'TP_BKP', -1);//Tipo do Backup, ordem do combobox
    TipoBackup := IfThen((TipoBackup < -1) or (TipoBackup > 1), -1, TipoBackup);
    TempoVerificacao := Config.ReadInteger('GERAL', 'NR_TMP_TIM', 10);//Tempo de Verificação do Timer
    TempoVerificacao := IfThen((TempoVerificacao < 1) or (TempoVerificacao > 60), 10, TempoVerificacao);
    vDataLimparMemo := Config.ReadDate('GERAL', 'DT_LMP_MEM', Date - 1);//Data da última vez que limpou as pastas e o memo
    ExibirTelaDos := Config.ReadBool('GERAL', 'TF_EXB_DOS', False);//Exibir a tela do DOS quando executar o backup
    Log('TFrmPrincipal.LerDadosConfig', 'Tipo Backup: ' + TipoBackup.ToString + '; Tempo Verificação: ' + TempoVerificacao.ToString + '; Data Limpou Memo: ' +
      DateToStr(vDataLimparMemo) + '; Exibir Tela DOS: ' + IfThen(ExibirTelaDos, 'Sim', 'Não') + '; Quant. Backups carregados: ' + QuantBkp.ToString + '.');
  finally
    Config.Free;
  end;
end;

procedure TFrmPrincipal.LimparDados;
var
  Config: TIniFile;
begin
  if vDataLimparMemo < Date then
  begin
    DeleteFiles(ExtractFileDir(Application.ExeName) + '\Arqbat\');
    DeleteFiles(ExtractFileDir(Application.ExeName) + '\Backups\');
    Memo.Lines.Clear;
    Log('TFrmPrincipal.LimparDados', 'Memo limpo e apagado arquivos das pastas "Arqbat" e "Backups". Data: ' + DateToStr(Date));
    Config := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\config.ini');
    try
      Config.WriteDateTime('GERAL', 'DT_LMP_MEM', Date);
    finally
      Config.Free;
    end;
  end;
end;

procedure TFrmPrincipal.TimerTimer(Sender: TObject);
var
  vTimer, vCodBackup: Integer;
  vExibirTelaDos: Boolean;
begin
  try
    Caption := vCaption + ' [Sistema travado. Aguarde a verificação/execução dos backups]';
    Timer.Enabled := False;
    HabilitaControles(False);
    CriaDataSet(CDSBackups);
    LerDadosConfig(CDSBackups, vTipoBackup, vTimer, vExibirTelaDos, vCodBackup);
    Timer.Interval := vTimer * 60000;
    VerificaBackup;
  finally
    Caption := vCaption;
    HabilitaControles(True);
    Timer.Enabled := True;
  end;
end;

procedure TFrmPrincipal.Log(Modulo, Msg: string);
var
  Arq: TextFile;
  Linha, CaminhoPasta, ArqLog: String;
begin
  try
    try
      CaminhoPasta := ExtractFileDir(Application.ExeName) + '\Logs\' + FormatDateTime('yyyy\MM\', Date);
      ForceDirectories(CaminhoPasta);
      ArqLog := CaminhoPasta + FormatDateTime('dd', Date) + '.log';
      AssignFile(Arq, ArqLog);
      if FileExists(ArqLog) then
        Append(Arq)
      else
        Rewrite(Arq);
      Linha := FormatDateTime('dd/MM/yyyy hh:mm:ss.zzz', Now) + ': ' + Modulo + ' => ' + Msg;
      Writeln(Arq, Linha);
      Memo.Lines.Add('# ' + Linha);
    except
    end;
  finally
    try
      CloseFile(Arq);
    except
    end;
  end;
end;

procedure TFrmPrincipal.Maximizar1Click(Sender: TObject);
begin
  TrayIcon1.BalloonHint := 'BkpBancoMySQL maximizado!';
  TrayIcon1.ShowBalloonHint;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
  Log('TFrmPrincipal.Maximizar1Click', 'Maximizado o sistema a partir do TrayIcon.');
end;

procedure TFrmPrincipal.Minimizar1Click(Sender: TObject);
begin
  Self.Hide();
  Self.WindowState := wsMinimized;
  TrayIcon1.Visible := True;
  TrayIcon1.Animate := True;
  TrayIcon1.BalloonHint := 'BkpBancoMySQL minimizado!';
  TrayIcon1.ShowBalloonHint;
  Log('TFrmPrincipal.Minimizar1Click', 'Minimizado o sistema a partir do TrayIcon.');
end;

{Biblioteca Funções}

procedure TFrmPrincipal.Wait(Time: Cardinal);
var
  Tick: Cardinal;
begin
  Tick := GetTickCount + Time;
  while Tick > GetTickCount do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;
end;

function TFrmPrincipal.OpenExec(FileName, Params: String; Visibility: Integer; WorkDir: PChar): TProcessInformation;
var
  zAppName: array [0 .. 512] of Char;
  zCurDir: array [0 .. 255] of Char;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  S: String;
begin
  S := FileName + ' ' + Params;
  StrPCopy(zAppName, S);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  CreateProcess(nil, zAppName, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, WorkDir, StartupInfo, ProcessInfo);
  Result := ProcessInfo;
end;

function TFrmPrincipal.OpenExecAndWait(FileName, Params: String; Visibility: Integer; WorkDir: PChar; Block: Boolean): Integer;
var
  zAppName: array [0 .. 512] of Char;
  zCurDir: array [0 .. 255] of Char;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  C: Cardinal;
  S: String;
begin
  S := FileName + ' ' + Params;
  StrPCopy(zAppName, S);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  Result := 0;
  if not CreateProcess(nil, zAppName, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, WorkDir, StartupInfo, ProcessInfo) then
    Result := -1
  else
  begin
    while WaitforSingleObject(ProcessInfo.hProcess, 10) = WAIT_TIMEOUT do
      if Block then
        Sleep(100)
      else
        Application.ProcessMessages;
    GetExitCodeProcess(ProcessInfo.hProcess, C);
  end;
end;

end.
