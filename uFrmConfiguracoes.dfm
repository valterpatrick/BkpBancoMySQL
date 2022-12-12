object FrmConfiguracoes: TFrmConfiguracoes
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Configura'#231#245'es'
  ClientHeight = 371
  ClientWidth = 594
  Color = clBtnFace
  Constraints.MaxHeight = 400
  Constraints.MaxWidth = 600
  Constraints.MinHeight = 400
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PnBotoes: TPanel
    Left = 0
    Top = 326
    Width = 594
    Height = 45
    Align = alBottom
    TabOrder = 0
    object BtnFechar: TBitBtn
      Left = 446
      Top = 6
      Width = 140
      Height = 30
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = BtnFecharClick
    end
    object BtnGravar: TBitBtn
      Left = 300
      Top = 6
      Width = 140
      Height = 30
      Caption = 'Gravar'
      TabOrder = 1
      OnClick = BtnGravarClick
    end
  end
  object PnBackups: TPanel
    Left = 0
    Top = 41
    Width = 594
    Height = 285
    Align = alClient
    TabOrder = 1
    object DBGrid1: TDBGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 586
      Height = 277
      Align = alClient
      DataSource = DSBackups
      DrawingStyle = gdsGradient
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'CD_COD'
          ReadOnly = True
          Width = 50
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'DH_BKP'
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'TX_CAM'
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'TX_HST'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NM_BAN'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NM_USU'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NM_SNH'
          Width = 100
          Visible = True
        end>
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 594
    Height = 41
    Align = alTop
    TabOrder = 2
    object Label1: TLabel
      Left = 14
      Top = 15
      Width = 76
      Height = 13
      Alignment = taRightJustify
      Caption = 'Tipo do Backup:'
    end
    object Label2: TLabel
      Left = 431
      Top = 16
      Width = 91
      Height = 13
      Alignment = taRightJustify
      Caption = 'Tempo Verifica'#231#227'o:'
    end
    object Label3: TLabel
      Left = 273
      Top = 15
      Width = 77
      Height = 13
      Alignment = taRightJustify
      Caption = 'Exibir Tela DOS:'
    end
    object CmbTipoBackup: TComboBox
      Left = 96
      Top = 12
      Width = 140
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      Items.Strings = (
        'Um por vez (aguardar)'
        'Todos ao mesmo tempo')
    end
    object SpinTimer: TSpinEdit
      Left = 528
      Top = 12
      Width = 50
      Height = 22
      MaxValue = 60
      MinValue = 1
      TabOrder = 2
      Value = 10
    end
    object CmbExibirTelaDos: TComboBox
      Left = 356
      Top = 12
      Width = 50
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'N'#227'o'
      Items.Strings = (
        'N'#227'o'
        'Sim')
    end
  end
  object DSBackups: TDataSource
    DataSet = CDSBackups
    Left = 80
    Top = 320
  end
  object CDSBackups: TClientDataSet
    Aggregates = <>
    Params = <>
    BeforePost = CDSBackupsBeforePost
    BeforeDelete = CDSBackupsBeforeDelete
    OnNewRecord = CDSBackupsNewRecord
    Left = 40
    Top = 320
    object CDSBackupsCD_COD: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'CD_COD'
    end
    object CDSBackupsDH_BKP: TTimeField
      DisplayLabel = 'Hora'
      FieldName = 'DH_BKP'
      DisplayFormat = 'hh:mm'
      EditMask = '00:00'
    end
    object CDSBackupsTX_CAM: TStringField
      DisplayLabel = 'Caminho Backup'
      FieldName = 'TX_CAM'
      Size = 256
    end
    object CDSBackupsTX_HST: TStringField
      DisplayLabel = 'Host'
      FieldName = 'TX_HST'
      Size = 256
    end
    object CDSBackupsNM_BAN: TStringField
      DisplayLabel = 'Nome Banco'
      FieldName = 'NM_BAN'
      Size = 50
    end
    object CDSBackupsNM_USU: TStringField
      DisplayLabel = 'Usu'#225'rio'
      FieldName = 'NM_USU'
      Size = 50
    end
    object CDSBackupsNM_SNH: TStringField
      DisplayLabel = 'Senha'
      FieldName = 'NM_SNH'
      Size = 50
    end
    object CDSBackupsDH_ULT_BKP: TDateTimeField
      FieldName = 'DH_ULT_BKP'
    end
  end
end
