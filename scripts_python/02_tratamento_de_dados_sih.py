# %%
# IMPORTANDO PACOTES 
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd   
import seaborn as sns

from ftplib import FTP
from pysus.online_data.SIH import download

# %%
#DEFININDO VARIÁVEIS QUE SERÃO USADAS NO DOWLOAD DOS DADOS
vars = ["N_AIH", "MORTE", "CID_MORTE", "DIAG_PRINC", "NASC", "SEXO", "QT_DIARIAS", "VAL_TOT"]
ufs = ["df", "go", "mt", "ms"]
meses = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] 

# %%
#IMPORTANDO DADOS
df = pd.DataFrame() #criando DataFrame vazio que receberá os dados 

for mes in meses:   #criando comando de repetição que lerá cada arquivo e armazenar no df vazio
    for uf in ufs:
        df_temp = download(uf, 2021, mes)      #realizando o download dos dados com pysus
        df_temp = df_temp.filter(vars)         #filtrando variáveis selecionadas
        df = pd.concat([df, df_temp], axis= 0) #unindo dados de cada arquivo em um único df
        print(f"O arquivo do mês {mes} do estado {uf.upper()} foi filtrado")

# %%
#VERIFICANDO O TAMANHO DE CADA DATAFRAME
df_temp.shape, df.shape

# %%
#IDENTIFICANDO O TIPO DE VARIÁVEL
df.info()

# %%
#TRANSFORMANDO O TIPO DE VARIÁVEL
df["MORTE"] = df["MORTE"].astype(str)
df["NASC"] = pd.to_datetime(df["NASC"], format="%Y%m%d")
df.info()

# %%
#SUBSTITUINDO UM VALOR NUMÉRICO POR CATEGORIAS
sexo = {"1":"MASCULINO", "3":"FEMININO"}
df["SEXO"] = df["SEXO"].replace(sexo)

# %%
#FREQUENCIAS

##FREQUENCIA ABSOLUTA
df["N_AIH"].nunique()

df["SEXO"].value_counts()

df.groupby("SEXO")["N_AIH"].nunique()

##FREQUENCIA RELATIVA
df["SEXO"].value_counts(normalize= True)*100

# %%
#MEDIDAS DE LOCALIDADE

##MODA
morte = {"0":"NÃO", "1":"SIM"}
df["MORTE"] = df["MORTE"].replace(morte)

md_morte = pd.DataFrame(df["MORTE"].value_counts())
md_morte = md_morte.sort_values(by = "MORTE", ascending= False)
md_morte

##MÉDIA
mean_valtot = df["VAL_TOT"].mean()

##MEDIANA
median_qtdiarias = df["QT_DIARIAS"].median()

##PERCENTIL(QUANTIL)
qt25_qtdarias = df["QT_DIARIAS"].quantile(.25)
qt50_qtdarias = df["QT_DIARIAS"].quantile()
qt75_qtdarias = df["QT_DIARIAS"].quantile(.75)

# %%
#DISPERSÃO OU ESPALHAMENTO

##INTERVALO (AMPLITUDE)
amp_qtdiarias = max(df["QT_DIARIAS"]) - min(df["QT_DIARIAS"])

##VARIANCIA
var_qtdarias = df["QT_DIARIAS"].var().round(1)

##DESVIO PADRAO
dp_qtdarias = df["QT_DIARIAS"].std().round(1)

##MAD - DESVIO MÉDIO ABSOLUTO
mad_valtot = np.mean(np.absolute(df["VAL_TOT"] - np.mean(df["VAL_TOT"]))).round(1)

##MADe - DESVIO MEDIANO ABSOLUTO
made_valtot = np.median(np.absolute(df["VAL_TOT"] - np.mean(df["VAL_TOT"]))).round(1)

##IQR - INTERVALO INTERQUARTÍLICO
iqr_valtot = np.subtract(*np.percentile(df["VAL_TOT"], [75, 25])).round(1)

# %%
#GRÁFICOS PARA DADOS UNIVARIADOS

df2 = df[df["VAL_TOT"] <= 1000] #filtrando valores

##BOXPLOT
sns.set_style("darkgrid")  #definindo o tema do gráfico
plt.figure(figsize=(10,7)) #definindo o tamanho do gráfico

sns.boxplot(data=df2, x="VAL_TOT")
plt.title("Distribuição do valor total das internações")
plt.xlabel("Valor total")
plt.show()

##HISTOGRAMA
plt.figure(figsize=(10,7)) #definindo o tamanho do gráfico
plt.hist(df2["VAL_TOT"], bins=30, density=True, alpha=0.9)
plt.title("Distribuição do valor total das internações")
plt.xlabel("Valor total")
plt.ylabel("Contagem")
plt.show()

# %%
#MEDIDAS DE DISTRIBUIÇÃO

##MOMENTO
k = 2
momento = np.mean((df2["VAL_TOT"] - np.mean(df2["VAL_TOT"])) ** k)

##OBLIQUIDADE
obliquidade = np.sum((df2["VAL_TOT"] - np.mean(df2["VAL_TOT"])) ** 3) / (len(df2["VAL_TOT"]) * np.std(df2["VAL_TOT"]) ** 3)

##CURTOSE
curtose = np.sum((dadf2["VAL_TOT"]dos - np.mean(df2["VAL_TOT"])) ** 4) / (len(df2["VAL_TOT"]) * np.std(df2["VAL_TOT"]) ** 4) - 3

