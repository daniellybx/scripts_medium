#CARREGANDO PACOTES
library(tidyverse)
library(read.dbc)
library(reshape2)

#IMPORTANDO DADOS
files = cbind(paste0("D:/scripts_medium/dados/dengue_df/", list.files(path = "D:/scripts_medium/dados/dengue_df/", pattern = "\\.dbc$")))

d_fn = NULL

for (i in 1:length(files)) {
  
  d_temp = read.dbc(files[i])
  d_fn= data.frame(rbind(d_fn, d_temp))
}

#IDENTIFICANDO VARIÁVEIS NO DATASET FINAL
glimpse(d_fn)

#ANALISANDO A AMPLITUDE DOS DADOS
summary(d_fn$DT_SIN_PRI) 
hist(d_fn$DT_SIN_PRI, breaks = 108, freq = T, col = "red",
     xlab = "Data", ylab = "Número de casos", main = "Casos de dengue registrados no DF, 2013 a 2019") 

#SELECIONANDO DADOS DO PERÍODO CONSIDERADO
d_fn = subset(d_fn, d_fn$DT_SIN_PRI >= "2012-12-30" & d_fn$CLASSI_FIN != "5")

#ANALISANDO A AMPLITUDE DOS DADOS APÓS A SELEÇÃO POR DATA
summary(d_fn$DT_SIN_PRI) 
hist(d_fn$DT_SIN_PRI, breaks = 108, freq = T, col = "blue", 
     xlab = "Data", ylab = "Número de casos", main = "Casos de dengue registrados no DF, 2013 a 2019")  

#SELECIONANDO DADOS ATÉ O ANO DE 2018 PARA CRIAR O DIAGRAMA DE CONTROLE
diag = subset(d_fn, d_fn$DT_SIN_PRI <= "2018-12-29")
diag2 = data.frame(diag$DT_SIN_PRI)
diag2$diag.DT_SIN_PRI = format(diag2$diag.DT_SIN_PRI, "%Y-%b-%d")

#TRATANDO DATAS E CALCULANDO AS INCIDÊNCIAS MENSAIS
diag2$ano = substring(diag2$diag.DT_SIN_PRI, 1, 4)
diag2$mes = substring(diag2$diag.DT_SIN_PRI, 6, 8)

diag2$mes = factor(diag2$mes, levels = c("jan", "fev", "mar", "abr",
                                         "mai", "jun", "jul", "ago",
                                         "set", "out", "nov", "dez"))
diag2$caso = 1

diag3 = data.frame(aggregate(caso ~ ano+mes, data = diag2, FUN = sum))

#CALCULANDO TAXAS DE INCIDÊNCIA MENSAIS
diag3$pop[diag3$ano == 2013] = 2789761
diag3$pop[diag3$ano == 2014] = 2852372
diag3$pop[diag3$ano == 2015] = 2914830
diag3$pop[diag3$ano == 2016] = 2997216
diag3$pop[diag3$ano == 2017] = 3039444
diag3$pop[diag3$ano == 2018] = 2974703

diag3$taxa_inc = round(diag3$caso/diag3$pop*100000, 2)

diag3$caso = NULL
diag3$pop = NULL

#CRIANDO TABELA COM OS DADOS DE MÊS E ANO
diag3 = dcast(mes ~ ano, data = diag3)
diag3$`2012` = NULL
diag3$media = round(rowMeans(diag3[,2:7]), 2)
diag3$sd = round(apply(diag3[,2:7], 1, sd, na.rm = TRUE), 2)

#CRIANDO LIMITES SUPERIORES E INFERIORES DO GRÁFICO
diag3$low = round(diag3$media - (1.96*diag3$sd), 2)
diag3$high = round(diag3$media + (1.96*diag3$sd), 2)

diag3$low[diag3$low < 0] = 0
diag3$mes = as.numeric(diag3$mes)

#CRIANDO DATA.FRAME DO ANO DE 2019
diag4 = subset(d_fn, d_fn$DT_SIN_PRI > "2018-12-29")
diag4 = data.frame(diag4$DT_SIN_PRI)
diag4$diag4.DT_SIN_PRI = format(diag4$diag4.DT_SIN_PRI, "%Y-%b-%d")

diag4$ano = substring(diag4$diag4.DT_SIN_PRI, 1, 4)
diag4$mes = substring(diag4$diag4.DT_SIN_PRI, 6, 8)

diag4$mes = factor(diag4$mes, levels = c("jan", "fev", "mar", "abr",
                                         "mai", "jun", "jul", "ago",
                                         "set", "out", "nov", "dez"))
diag4$caso = 1

diag4 = data.frame(aggregate(caso ~ ano+mes, data = diag4, FUN = sum))

diag4$pop = 3015268

diag4$taxa_inc = round(diag4$caso/diag4$pop*100000 ,2)

diag4$caso = NULL
diag4$pop = NULL

diag4 = dcast(mes ~ ano, data = diag4)
diag4$`2018` = NULL

colnames(diag4) = c("mes", "inc")
diag4$mes = as.numeric(diag4$mes)

#PLOTANDO O DIAGRAMA DE CONTROLE COM O RBASE
plot(diag3$mes, diag3$media, ylim = c(0,400), type = "l",
     main = "Diagrama de controle de dengue, DF, 2019",
     ylab = "Taxa de incidência",
     xlab = "Mês")

polygon(c(diag3$mes,rev(diag3$mes)), c(diag3$low,rev(diag3$high)),col = "grey90", border = FALSE)

lines(diag3$mes, diag3$media, lwd = 1)

lines(diag3$mes, diag3$high, col="grey50", lty=2)
lines(diag3$mes, diag3$low, col="grey50", lty=2)
lines(diag4$mes, diag4$inc, col="red", lwd = 2)

#PLOTANDO O DIAGRAMA DE CONTROLE COM GGPLOT2
ggplot(diag3, aes(x = mes, y= media))+
  geom_line(aes(x = mes, y= media), colour = "black", size = 1.3)+
  geom_ribbon(data = diag3, aes(ymin=low, ymax=high), alpha=0.3 , fill = "grey70")+
  ggtitle("Diagrama de controle de dengue, DF, 2019")+
  theme_bw()+
  ylab("Taxa de incidência")+
  xlab("mês")+
  scale_x_discrete(limits=1:12)+
  geom_line(data = diag4, aes(x = mes, y= inc), colour = "red", size = 1.3)+
  geom_point(data = diag4, aes(x = mes, y= inc), colour = "red", size = 1.3)

#CRIANDO UM DATA.FRAME COM APENAS UMA PARTE DO ANO
diag5 = subset(diag4, diag3$mes <= 3)

ggplot(diag3, aes(x = mes, y= media))+
  geom_line(aes(x = mes, y= media), colour = "black", size = 1.3)+
  geom_ribbon(data = diag3, aes(ymin=low, ymax=high), alpha=0.3 , fill = "grey70")+
  ggtitle("Diagrama de controle de dengue, DF, 2019")+
  theme_bw()+
  ylab("Taxa de incidência")+
  xlab("mês")+
  scale_x_discrete(limits=1:12)+
  geom_line(data = diag5, aes(x = mes, y= inc), colour = "red", size = 1.3)+
  geom_point(data = diag5, aes(x = mes, y= inc), colour = "red", size = 1.3)
