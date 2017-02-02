## ----echo=FALSE----------------------------------------------------------
require(Hmisc)
knitrSet('reg', width=80)

## ----glratio,cap='\\co{loess} nonparametric smoother relating CSF:blood glucose ratio to total CSF polymorph count in patients with either bacterial or viral meningitis.  Rug plot on axes plots indicate raw data values.',scap='\\co{loess} nonparametric smoother for glucose ratio'----
require(Hmisc)
getHdata(abm)   # Loads data frame ABM (note case)
with(ABM, {
  glratio <- gl / bloodgl
  tpolys <- polys * whites / 100
  plsmo(tpolys, glratio, xlab='Total Polymorphs in CSF',
       ylab='CSF/Blood Glucose Ratio',    # Fig. (*\ref{fig:reg-glratio}*)
       xlim=quantile(tpolys,  c(.05,.95), na.rm=TRUE),
       ylim=quantile(glratio, c(.05,.95), na.rm=TRUE))
 scat1d(tpolys); scat1d(glratio, side=4) })

## ----age-abm,cap="``Super smoother'' relating age to the probability of bacterial meningitis given a patient has bacterial or viral meningitis, with a rug plot showing the age distribution.",scap="Example of super smoother"----
with(ABM, {
  plsmo(age, abm, 'supsmu', bass=7,     # Fig. (*\ref{fig:reg-age-abm}*)
        xlab='Age at Admission, Years',
        ylab='Proportion Bacterial Meningitis')
  scat1d(age) })

## ----simple-linear-reg,cap='Data from a sample of $n=100$ points along with population linear regression line.  The $x$ variable is discrete.  The conditional distribution of $y | x$ can be thought of as a vertical slice at $x$.  The unconditional distribution of $y$ is shown on the $y$-axis.',scap='Sample of $n=100$ points with a linear regression line',mgp=c(1,1,0)----
n <- 100
set.seed(13)
x <- round(rnorm(n, .5, .25), 1)
y <- x + rnorm(n, 0, .1)
r <- c(-.2, 1.2)
plot(x, y, axes=FALSE, xlim=r, ylim=r, xlab=expression(x), ylab=expression(y))
axis(1, at=r, labels=FALSE)     # Fig. (*\ref{fig:reg-simple-linear-reg}*)
axis(2, at=r, labels=FALSE)
abline(a=0,b=1)
histSpike(y, side=2, add=TRUE)
abline(v=.6, lty=2)

## ----both-type-cls,cap='Pointwise 0.95 confidence intervals for $\\hat{y}$ (wider bands) and $\\hat{E}(y|x)$ (narrower bands).',scap='Two types of confidence bands'----
require(rms)
x1 <- c( 1,  3,  5,  6,  7,  9,  11)
y  <- c( 5, 10, 70, 58, 85, 89, 135)
dd <- datadist(x1, n.unique=5); options(datadist='dd')
f <- ols(y ~ x1)
p1 <- Predict(f, x1=seq(1,11,length=100), conf.type='mean')
p2 <- Predict(f, x1=seq(1,11,length=100), conf.type='individual')
p <- rbind(Mean=p1, Individual=p2)
ggplot(p, legend.position='none') +    # Fig. (*\ref{fig:reg-both-type-cls}*)
     geom_point(aes(x1, y), data=data.frame(x1, y, .set.=''))

## ----exresid,w=6,h=6,mfrow=c(2,2),scap='Four examples of residual plots',cap='Using residuals to check some of the assumptions of the simple linear regression model.  Top left panel depicts non-constant $\\sigma^2$, which might call for transforming $y$.  Top right panel shows constant variance but the presence of a systemic trend which indicates failure of the linearity assumption.  Bottom left panel shows the ideal situation of white noise (no trend, constant variance).  Bottom right panel shows a $q-q$ plot that demonstrates approximate normality of residuals, for a sample of size $n=50$.  Horizontal reference lines are at zero, which is by definition the mean of all residuals.'----
# Fit a model where x and y should have been log transformed
n <- 50
set.seed(2)
res <- rnorm(n, sd=.25)
x <- runif(n)
y <- exp(log(x) + res)
f <- ols(y ~ x)
plot(fitted(f), resid(f))    # Fig. (*\ref{fig:reg-exresid}*)
# Fit a linear model that should have been quadratic
x <- runif(n, -1, 1)
y <- x ^ 2 + res
f <- ols(y ~ x)
plot(fitted(f), resid(f))
# Fit a correctly assumed linear model 
y <- x + res
f <- ols(y ~ x)
plot(fitted(f), resid(f))
# Q-Q plot to check normality of residuals
qqnorm(resid(f)); qqline(resid(f))

## ----bmi,mfrow=c(2,2),w=6,h=4.5,cap='Harm of percentiling BMI in a regression model'----
x <- seq(10, 55, length=200)
d <- dnorm(x, mean=28, sd=2)
plot(x, d, type='l', xlab='BMI', ylab='Density')   # Fig. (*\ref{fig:reg-bmi}*)
pctile <- 100*pnorm(x, mean=28, sd=2)
plot(x, pctile, type='l', xlab='BMI', ylab='BMI Percentile')
risk <- .01 + pmax(x - 25, 0)*.01
plot(x, risk, type='l', xlab='BMI', ylab='Risk')
plot(pctile, risk, type='l', xlab='BMI Percentile', ylab='Risk')

## ----bmiq,cap='What are quintile numbers modeling?'----------------------
set.seed(1)
bmi  <- rnorm(500, mean=28, sd=2)
require(Hmisc)
bmiq <- cut2(bmi, g=5)
table(bmiq)
cuts <- cut2(bmi, g=5, onlycuts=TRUE)
cuts
bmim <- cut2(bmi, g=5, levels.mean=TRUE)
means <- as.numeric(levels(bmim))
plot(c(21, 36), c(1, 5), type='n', xlab='BMI', ylab='Quintile #')   # Fig. (*\ref{fig:reg-bmiq}*)
for(i in 1 : 5) {
  lines(cuts[c(i, i+1)], c(i, i))
  points(means[i], i)
}

## ----mult-reg-assume-twovar,w=4.5,h=3.5,cap='Data satisfying all the assumptions of simple multiple linear regression in two predictors.  Note equal spread of points around the population regression lines for the $x_{2}=1$ and $x_{2}=0$ groups (upper and lower lines, respectively) and the equal spread across $x_1$.  The $x_{2}=1$ group has a new intercept, $\\alpha+\\beta_2$, as the $x_2$ effect is $\\beta_2$.  On the $y$ axis you can clearly see the difference between the two true population regression lines is $\\beta_{2} = 3$.',scap='Assumptions for two predictors'----
# Generate 25 observations for each group, with true beta1=.05, true beta2=3
d <- expand.grid(x1=1:25, x2=c(0, 1))
set.seed(3)
d$y <- with(d, .2*x1 + 3*x2 + rnorm(50, sd=.5))
with(d, plot(x1, y, xlab=expression(x[1]), ylab=expression(y)))
abline(a=0, b=.2)    # Fig. (*\ref{fig:reg-mult-reg-assume-twovar}*)
abline(a=3, b=.2)
text(13, 1.3, expression(y==alpha + beta[1]*x[1]),           srt=24, cex=1.3)
text(13, 7.1, expression(y==alpha + beta[1]*x[1] + beta[2]), srt=24, cex=1.3)

## ----olslead-------------------------------------------------------------
getHdata(lead)
f <- ols(maxfwt ~ group, data=lead)
f

## ----leadgrage-----------------------------------------------------------
fa <- ols(maxfwt ~ age + group, data=lead)
fa
anova(fa)
anova(f)    # reduced model (without age)

