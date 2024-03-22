## combining a couple of methods
# https://bbolker.github.io/mixedmodels-misc/notes/multimember.html
# https://www.azandisresearch.com/2022/12/31/visualize-mixed-effect-regressions-in-r-with-ggplot2/
library(lme4)
library(Matrix)
library(broom.mixed)
library(ggplot2);
library(see)
library(Matrix)
library(tidyverse)
library(lme4)
library(ggsci)
library(cowplot)
library(dplyr); library(tidyr)
library(latex2exp)

out <- R.matlab::readMat('nfc_tbl_mixed.mat')
kappa <- 3600/36e6/0.306

# 1 is delP, 2 is delf, 3 is npc and 4 is nfc
y = out$y[,1]
nobs0 <- length(y)
X = matrix(out$X,nrow = length(y))
Z = matrix(out$Z,nrow = length(y))
ngrp <-  dim(Z)[2]
dimnames(Z) <- list(NULL,seq(ngrp))

table(rowSums(Z))
Matrix(Z)
image(Matrix(Z),xlim=c(1,10),ylim=c(1,10),sub="",ylab="Observation",
      xlab="Item",
      ## draw tick labels at top
      scales=list(at=seq(1,ngrp),x=list(labels=seq(1,ngrp),
                                 alternating=2)))

M <- data.frame(x1=(X[,2]+X[,3]),x3=X[,4],x4=X[,5]-1,x5=X[,6]-1,y=y-1)
M$fake = rep(seq(ngrp),length.out=nobs0)

lmod <- lFormula(y~x1+(1|fake), data=M)
lmod$reTrms$Zt <- lmod$reTrms$Ztlist[[1]] <- Matrix(t(Z))
devfun <- do.call(mkLmerDevfun, lmod)
opt <- optimizeLmer(devfun)
m1 <- mkMerMod(environment(devfun), opt, lmod$reTrms, fr = lmod$fr)

summary(m1)

dd <- tidy(m1, effects="ran_vals")
dd <- transform(dd, level=reorder(level,estimate))
ggplot(dd,aes(x=level,y=estimate))+
  geom_pointrange(aes(ymin=estimate-2*std.error,
                      ymax=estimate+2*std.error))+coord_flip()

M <- M %>% 
  mutate(fit.m = predict(m1, re.form = NA),
         fit.c = predict(m1, re.form = NULL))

M <- M %>%
  mutate(resid = resid(m1))

M %>%
  ggplot(aes(x = x1, y = y)) +
  geom_point(pch = 16, col = "grey") +
  geom_line(aes(y = fit.m), col = 1, size = 2)

M %>%
  ggplot(aes(x = x1, y = fit.m + resid)) +
  geom_point(pch = 16) +
  geom_line(aes(y = fit.m), col = 1, size = 2)

Cond_DF <- as.data.frame(ranef(m1)) %>%
  transmute(unit = grp, b0_hat = condval) %>%
  mutate(Intercept_cond = b0_hat + summary(m1)$coef[1,1])

M %>%
  ggplot(aes(x = x1, y = fit.m + resid)) +
  geom_point(pch = 16, col = "grey",size=3) +
  geom_line(aes(y = fit.m,linetype="Best Fit"), col = 1, size = 1) +
  geom_violinhalf(data = Cond_DF, aes(x = 0, y = Intercept_cond,color="Random Intercepts"), trim = FALSE, width = 10, fill = 'red',alpha=.5)+
  ylab(TeX(r'($\Delta F_{true}$ [L/hr])'))+
  xlab(TeX(r'($\Delta F_{inferred}$ [L/hr])'))+
  scale_color_manual(name="Random Effects",values = "black") +
  scale_linetype_manual(name= "Fixed Effects", values = "solid")
  
theme_set(theme_gray())
M %>%
  ggplot(aes(x = x1/1000, y = (fit.m + resid)/1000)) +
  geom_point(aes(y=y/1000,fill = "Without Random Intercepts"),pch = 16, col = "skyblue",size=3) +
  geom_point(aes(fill="With Random Intercepts"),pch = 16, col = "darkred",size=3) +
  geom_line(aes(y = fit.m/1000,linetype="Best Fit"), col = 1, size = 1) +
  geom_violinhalf(data = Cond_DF, aes(x = 0, y = Intercept_cond/1000,color="Distribution"), trim = FALSE, width = 10, fill = 'red',alpha=.5)+
  ylab(TeX(r'($\Delta P_{true}$ [kW])'))+
  xlab(TeX(r'($\Delta P_{inferred}$ kW])'))+
  scale_color_manual(name="Random Effects",values = c("Distribution" = "black")) +
  scale_fill_manual(name="",values = c("Without Random Intercepts" = "skyblue","With Random Intercepts" = "skyblue")) +
  scale_linetype_manual(name= "Fixed Effects", values = "solid")+
  annotate("text", x = -8, y = 30, label = TeX(sprintf(r'($ \Delta P_{true} \sim (%.3f \pm %.3f) \Delta P_{inferred}$)', s$coefficients[2],s$coefficients[4]*1.96)))

ggsave(filename = 'mixedEffects.png',width = 6,height=4, device = 'png', dpi=300)
