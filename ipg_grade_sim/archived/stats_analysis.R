
library(readr)
library(skimr)
library(car)
library(dplyr)
df <- read_csv("F:/dissertation/ipg_grade_sim/processed/stats_wDrr.csv")
skim(df)

df <- df %>% filter(mean_P_AD_true>0)

attach(df)
plot(mean_NPC,mean_P_AD_true)
detach(df)
mdl <- lm(data=df,'mean_NPC~mean_P_AD_true+PRR')
summary(mdl)


boxCox(df$mean_NPC~1)
attach(df)
X <-  mean_P_AD_true/mean_v^2/mean_mass_eff^0.5
detach(df)

mdl <- lm('mean_NPC~I(mean_P_AD_true/mean_v^2/mean_mass_eff^0.5)+PRR-1',data = df)
summary(mdl)
plot(mdl)

