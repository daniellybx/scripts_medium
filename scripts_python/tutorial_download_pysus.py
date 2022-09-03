# IMPORTANDO PACOTES 
import pandas as pd   

from ftplib import FTP
from pysus.online_data.SIH import download

#DEFININDO VARIÁVEIS QUE SERÃO USADAS NO DOWLOAD DOS DADOS

#DEFININDO VARIÁVEIS
vars = ["MORTE", "CID_MORTE", "DIAG_PRINC"]
ufs = ["df", "go", "mt", "ms"]
anos = [2020, 2021] 
meses = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] 
cids = ["J13", "J14"]

#IMPORTANDO DADOS
for mes in meses: 
    for uf in ufs:
        for ano in anos:   
            df = download(uf, ano, mes)
            df = df.filter(vars)
            df = df[df['DIAG_PRINC'].isin(cids)]
            df.to_csv("sih_pneumonia_20_21.csv", mode='a', index=False, header=False)
            print(f"O arquivo do mês {mes} de {ano} do estado {uf.upper()} foi filtrado")