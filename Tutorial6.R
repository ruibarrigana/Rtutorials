# # # # # # # # # # # # # # #
# Ridge regression and LASSO #
# # # # # # # # # # # # # # #
library(glmnet)
library(ISLR)

# Get rid of NA
Hitters = na.omit(Hitters)

# Create model
x = model.matrix(Salary~.,Hitters)[,-1]
y = Hitters$Salary

# Ridge regression
grid = 10^seq(10,-2,length=100)
ridge.mod = glmnet(x,y,alpha=0,lambda=grid)

# Compare parameters
dim(coef(ridge.mod))
ridge.mod$lambda[50]
coef(ridge.mod)[,50]
sqrt(sum(coef(ridge.mod)[-1,50]^2))
ridge.mod$lambda[60]
coef(ridge.mod)[,60]
sqrt(sum(coef(ridge.mod)[-1,60]^2))

# Estimate coefficients for new lambda
predict(ridge.mod,s=50,type="coefficients")[1:20,]

# Partition into train and test
set.seed(1)
train = sample(1:nrow(x),nrow(x)/2)
test = (-train)
y.test = y[test]

# Fit ridge regression
ridge.mod = glmnet(x[train,],y[train],alpha=0,lambda=grid,thres=1e-12)
ridge.pred = predict(ridge.mod,s=4,newx=x[test,])
mean((ridge.pred-y.test)^2)

# Model with intercept only (=mean)
mean((mean(y[train])-y.test)^2)
ridge.pred=predict(ridge.mod,s=1e10,newx=x[test,])
mean((ridge.pred-y.test)^2)

# Compare with linear regression
ridge.pred = predict(ridge.mod ,s=0,newx=x[test,],exact=T)
mean((ridge.pred-y.test)^2)
lm(y~x,subset=train)
predict(ridge.mod,s=0,exact=T,type="coefficients")[1:20,]

# Use cross-validation to choose lambda
set.seed(1)
cv.out = cv.glmnet(x[train,],y[train],alpha=0,lambda=grid)
plot(cv.out)
bestlam = cv.out$lambda.min
bestlam

ridge.pred = predict(ridge.mod,s=bestlam,newx=x[test,])
mean((ridge.pred-y.test)^2)

# Reestimate using entire dataset
out = glmnet(x,y,alpha=0)
predict(out,type="coefficients",s=bestlam)[1:20,]

# LASSO
lasso.mod = glmnet(x[train,],y[train],alpha=1,lambda=grid)
plot(lasso.mod)

# LASSO and cross-validation
set.seed(1)
cv.out = cv.glmnet(x[train,],y[train],alpha=1)
plot(cv.out)
bestlam = cv.out$lambda.min
lasso.pred = predict(lasso.mod,s=bestlam,newx=x[test,])
mean((lasso.pred-y.test)^2)

out = glmnet(x,y,alpha=1,lambda=grid)
lasso.coef = predict(out,type="coefficients",s=bestlam)[1:20,]
lasso.coef
lasso.coef[lasso.coef!=0]



