Backup automatizado do Banco de Dados MySQL.

Desenvolvido em Delphi, utilizando os comandos do "mysqldump" para realizar o Backup automatizado do banco de dados MySQL e salvar em uma pasta específica.

No projeto utilizo apenas VCL salvando e lendo os dados de um arquivo INI sem criptografia (pode ser alterado) e usando um ClientDataSet para manipular os dados. O timer verifica a cada X minutos se está na hora de realizar o backup e o faz. Há um tryicon para poder maximizar e minimizar o aplicativo na bandeja. Na virada do dia o aplicativo exclui os arquivos na pasta e limpa o memo.

No arquivo "Config.ini" você informa os parâmetros e os dados do backup.

Arquivo Ini exemplo:

[GERAL]
TP_BKP=1
NR_TMP_TIM=1
DT_LMP_MEM=10/12/2022
TF_EXB_DOS=0

[BKP_001]
CD_COD=1
DH_BKP=10:00:00
TX_CAM=D:\BkpBancoMySQL\Backups\
TX_HST=google.com.br
NM_BAN=banco_dados
NM_USU=usuario_banco
NM_SNH=senha_banco
DH_ULT_BKP=10/12/2022 10:35:25
