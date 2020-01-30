# Wuhan coronavirus epidemic
# Jan 29, 2020
# (c) Horace W. Tso

today = Sys.Date()
today.ch = as.character(today)

home = getwd()
data_path = paste(home,  "/data/", sep="")
plot_path = paste(home,  "/plots/", sep="")

if ( file.exists("CoronaV.RData") ) load("CoronaV.RData")

csv_file = "corona_data.csv"
full_path = paste(data_path, csv_file, sep="")

# override dat with the latest data
dat = read.csv(full_path, header=TRUE, stringsAsFactors=FALSE)
dat = dat[9:nrow(dat),]
dat[,"t"] = 1:nrow(dat)
dat[,"date"] = as.Date(dat[,"date"], format="%Y-%m-%d")
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

# ==== Fit model ==============================================
model = nls(confirmed ~ alpha*exp(beta*t) + intcpt , data=dat, start=init_param)
res = summary(model)
cat("===== Model summary ====================================== \n")
res

latest.date = as.character(dat[nrow(dat), "date"])

if ( !exists("Model_param") ) Model_param = list()
Model_param[[length(Model_param)+1]] = res

if ( !exists("Daily_updates") ) Daily_updates = NULL
Daily_updates = rbind(Daily_updates, res$coefficients[,1])
rownames(Daily_updates)[nrow(Daily_updates)] = latest.date


# ==== Prediction =================================
last.t = tail(dat[,"t"],1)
forecast.df = data.frame(matrix(NA, nrow=3, ncol=ncol(dat)))
colnames(forecast.df) = colnames(dat)
dte = dat[nrow(dat), "date"] + 1:3
forecast.df[1:3,"date"] = dte
forecast.df[,"date"] = as.Date(forecast.df[,"date"], origin="1970-01-01")
forecast.df[,"t"] = last.t + 1:3

cat("===== Model prediction for next three days ====================================== \n")
pred = predict(model, newdata=forecast.df, se.fit = TRUE, level=0.95)
pred

forecast.df[,"confirmed"] = pred
df = rbind(dat, forecast.df)

# ==== Plots ==========================================
fnm = paste("daily-prediction-", latest.date, ".png",  sep="")
full_path = paste(plot_path, fnm, sep="")
png(full_path)
plot(df[,"t"], df[,"confirmed"], type="b", 
     xlab="Date", ylab="No of confirmed cases",
     main="Coronvirus Confirmed Cases and Predictions")
abline(v=last.t, col="grey", lwd=2)
grid(NA, 10, lwd = 2)
text(x=last.t, y=100, labels=latest.date, pos=3, col="blue", cex=1)
txt = c(paste(as.character(forecast.df[1,"date"]), round(forecast.df[1,"confirmed"],0), sep=" : "), 
        paste(as.character(forecast.df[2,"date"]), round(forecast.df[2,"confirmed"],0), sep=" : "))
hgt = max(df[,"confirmed"])
text(x=1, y=c(hgt*0.9, hgt*0.8), labels=txt, pos=4, col="red", cex=2)
dev.off()

fnm = paste("Beta-history.png",  sep="")
full_path = paste(plot_path, fnm, sep="")
png(full_path, width=1080, height=480)
par(mfrow=c(1,3))
dte = as.Date(rownames(Daily_updates))
plot(dte, Daily_updates[,"beta"], type="b", cex=5, bg="red", col="black", lwd=3, pch=21,
     xlab="Date", ylab="beta",
     main="Rate of Infection (Beta)")
grid(NA, 10, lwd = 1)
plot(dte, Daily_updates[,"alpha"], type="b",  cex=5, bg="blue", col="black", lwd=3, pch=22,
     xlab="Date", ylab="alpha",
     main="Alpha")
grid(NA, 10, lwd = 1)
plot(dte, Daily_updates[,"intcpt"], type="b",  cex=5, bg="green", col="black", lwd=3, pch=25,
     xlab="Date", ylab="Intercept",
     main="Intercept")
grid(NA, 10, lwd = 1)
dev.off()



# save everything to RData file
save.image("CoronaV.RData")




