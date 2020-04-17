# coronavirus.R -- Code to model the coronavirus epidemic in Wuhan, China. 
# Jan 29, 2020
# (c) Horace W. Tso


if ( file.exists("nCoV.RData") ) load("nCoV.RData")
rm(full_path, data_path, plot_path, csv_file, dat, model, last.t, latest.date)

home = getwd()
cat("home : ", home)
data_path = paste(home,  "/data/", sep="")
plot_path = paste(home,  "/plots/", sep="")
utils_path = paste(home, "/utils/", sep="")

fnm = "plot_fun.R"
fun_path = paste(utils_path, fnm, sep="")
source(fun_path)

today = Sys.Date()
today.ch = as.character(today)

csv_file = "corona_data.csv"
full_path = paste(data_path, csv_file, sep="")
cat("csv full path : ", full_path)
# override dat with the latest data     
dat = read.csv(full_path, header=TRUE, stringsAsFactors=FALSE)
dat = dat[9:nrow(dat),]
N = nrow(dat)
dat[,"date"] = as.Date(dat[,"date"], format="%Y-%m-%d")
dat[,"t"] = 1:N
cat("====== Data ============================ \n")
dat 

# ==== Estimate starting parameters ===================================
# Initial intercept must be less than min(y) and greater than zero
init_intcpt = min(dat[,"confirmed"]) / 2
# Estimate other parameters using a linear model
model0 = lm(log(confirmed - init_intcpt)~t, data=dat)  
alpha0 = exp(coef(model0)[1])
beta0 = coef(model0)[2]
init_param = list(alpha=alpha0, beta=beta0, intcpt=init_intcpt)
cat("===== Starting parameters =============================== \n")
init_param

# ==== Exponential model ==============================================
model = nls(confirmed ~ alpha*exp(beta*t) + intcpt , data=dat, start=init_param)
res = summary(model)
cat("===== Model summary ====================================== \n")
res

if ( !exists("Model_param") ) Model_param = list()
Model_param[[length(Model_param)+1]] = res

last_date = dat[N,"date"]
# save beta in a separate data frame
if ( !exists("Daily_updates") ) Daily_updates = NULL
Daily_updates = rbind(Daily_updates, res$coefficients[,1])
rownames(Daily_updates)[nrow(Daily_updates)] = last_date


# prepare a data frame to hold model predictions
fcast_horizon = 3
last_t = dat[N,"t"]
forecast.df = data.frame(matrix(NA, nrow=N+fcast_horizon, ncol=5))
colnames(forecast.df) = c("date", "t", "exp_pred", "lin_pred", "confirmed")
forecast.df[1:N, "confirmed"] = dat[,"confirmed"]
dte = c(dat[,"date"], last_date + 1:fcast_horizon)
forecast.df[,"date"] = dte
t = c(dat[,"t"], last_t + 1:fcast_horizon)
forecast.df[,"t"] = t

# prediction =======================================
pred = predict(model, newdata=forecast.df, se.fit = TRUE, level=0.95)
forecast.df[,"exp_pred"] = pred



# ==== Linear model ===================================
dat2 = dat[12:N,]
model2 = glm(confirmed ~ t, family=gaussian, data=dat2)
res2 = summary(model2)
# prediction ==========================================
pred2 = predict(model2, newdata=forecast.df)
forecast.df[,"lin_pred"] = pred2

if ( !exists("Forecast") ) Forecast = list()
Forecast = append(Forecast, forecast.df)



# ==== Plots ======================================================
title = "Fig. 1 Predictions vs Actual Confirmed Cases (China only)"
fnm = paste("prediction-", today.ch, ".png", sep="")
full_path = paste(plot_path, fnm, sep="")
predict_vs_actual_plot(forecast.df, last_t, title, full_path)
# make a copy in top dir
file.copy(from=full_path, to=home)
file.rename(from=file.path(home, fnm), to=file.path(home, "latest-prediction.png"))

title = "Fig. 2 Prediction Errors (Exp model)"
fnm = "actual-vs-predict.csv"
full_path = paste(data_path, fnm, sep="")
plot_fnm = "actual-vs-predict.png"
exp_delta_plot(dat_fnm=full_path, title=title, plot_fnm=plot_fnm)

title = "Fig. 3 Beta history"
fnm = "beta_history.png"
full_path = paste(plot_path, fnm, sep="")
beta_plot(Daily_updates, title, full_path)

        
# save everything 
save.image("CoronaV.RData")

# NOTE : 
# To reproduce the plots on github, I discard everything after Feb 11. 
# The reason is on 12th, NHC changed methodology of reporting confirmed cases, which caused a jump in
# the plot. 

dat0 = dat[1:27,]
new.cases = c(NA, diff(dat0[,"confirmed"]))
new.deaths = c(NA, diff(dat0[,"deaths"]))
new.recov = c(NA, diff(dat0[,"recovered"]))
new.sev = c(NA, diff(dat0[,"severe"]))

dat = cbind(dat0, new.cases=new.cases, new.deaths=new.deaths, new.recov=new.recov, new.sev=new.sev)




png("things-have-peaked.png", width=1080, height=680)
par(mfrow=c(2,3))
with(dat, plot(date, new.cases, type="b", xlab="", ylab="",
               col="red", cex=2,
               cex.main=2, cex.lab=2, cex.axis=1.5,
               main="# Newly Confirmed Cases"))
grid(nx=NA, ny=NULL)
text(x=as.integer(dat[1,"date"])+2, y=2500, 
     labels="peaked a week ago", 
     cex=3, col="grey", pos=4)

with(dat, plot(date, suspected, type="b", xlab="", ylab="",
               col="blue", cex=2,
               cex.main=2, cex.lab=2, cex.axis=1.5,
               main="# Suspect Cases"))
grid(nx=NA, ny=NULL)
text(x=as.integer(dat[1,"date"])+2, y=20000, 
     labels="peaked 3 days ago", 
     cex=3, col="grey", pos=4)

with(dat, plot(date, quarantined, type="b", xlab="", ylab="",
               col="orange", cex=2,
               cex.main=2, cex.lab=2, cex.axis=1.5,
               main="# Quarantined"))
grid(nx=NA, ny=NULL)
text(x=as.integer(dat[1,"date"])+2, y=100000, 
     labels="reached a plateau", 
     cex=3, col="grey", pos=4)

with(dat, plot(date, new.deaths, type="b", xlab="", ylab="",
               cex.main=2, cex.lab=2, cex.axis=1.5,
               main="# New Deaths"))
grid(nx=NA, ny=NULL)
with(dat, plot(date, new.recov, type="b", xlab="Date", ylab="# recovered",
               cex.main=2, cex.lab=2, cex.axis=1.5,
               main="# Recovered"))
grid(nx=NA, ny=NULL)
with(dat, plot(date, new.sev, type="b", xlab="", ylab="",
               cex.main=2, cex.lab=2, cex.axis=1.5,
               main="# Severe Cases"))
grid(nx=NA, ny=NULL)
dev.off()


