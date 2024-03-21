# from https://bbolker.github.io/mixedmodels-misc/notes/multimember.html

library(lme4)
library(broom.mixed)
library(ggplot2); theme_set(theme_bw())
library(Matrix)
library(dplyr); library(tidyr)
nm <- 20
nobs0 <- 500
set.seed(101)
## choose items for observations
W1 <- matrix(rbinom(nobs0*nm, prob=0.25, size=1),nrow=nobs0,ncol=nm)
dimnames(W1) <- list(NULL,LETTERS[seq(nm)])
W1[1:5,]
table(rowSums(W1))

image(Matrix(W1),ylim=c(1,10),sub="",ylab="Observation",
      xlab="Item",
      ## draw tick labels at top
      scales=list(at=1:20,x=list(labels=colnames(W1),
                                 alternating=2)))


b <- rnorm(nm)  ## item-level effects
beta <- c(1,2)
M <- data.frame(x=runif(nobs0))
X <- model.matrix(~x, data=M)
## n.b. get in trouble if we don't add residual error
## (theta is scaled relative to residual error)
## here, use theta=sigma=1
M$y <- c(X %*% beta) + c(W1 %*% b) +rnorm(nobs0,sd=1)
## we'll need this later
M$fake <- rep(LETTERS[seq(nm)],length.out=nobs0)
