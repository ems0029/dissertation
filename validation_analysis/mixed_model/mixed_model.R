## combining a couple of methods
# https://bbolker.github.io/mixedmodels-misc/notes/multimember.html
# https://www.azandisresearch.com/2022/12/31/visualize-mixed-effect-regressions-in-r-with-ggplot2/
library(lme4)
library(Matrix)
library(broom.mixed)
library(ggplot2); theme_set(theme_bw())
library(see)
library(Matrix)
library(tidyverse)
library(lme4)
library(ggsci)
library(cowplot)
library(dplyr); library(tidyr)

out <- R.matlab::readMat('nfc_tbl_mixed_justDOE.mat')
y = matrix(out$y)
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

M <- data.frame(x1=X[,2],x2=X[,3],x3=X[,4],y=y)
M$fake = rep(seq(ngrp),length.out=nobs0)

lmod <- lFormula(y~x1+x2+x3+(1|fake), data=M)
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
  geom_point(pch = 16, col = "grey") +
  geom_line(aes(y = fit.m), col = 1, size = 2) +
  geom_violinhalf(data = Cond_DF, aes(x = 0, y = Intercept_cond), trim = FALSE, width = 10000, fill = 'red') +
  coord_cartesian(xlim = c(-10000, 10000),ylim = c(-10000, 10000))  
