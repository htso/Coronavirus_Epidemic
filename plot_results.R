

library(ggplot2)

today = Sys.Date()
today.ch = as.character(today)

home = getwd()
data_path = paste(home,  "/data/", sep="")
plot_path = paste(home,  "/plots/", sep="")

csv_file = "actual-vs-predict.csv"
full_path = paste(data_path, csv_file, sep="")

dat1 = read.csv(full_path, header=TRUE, stringsAsFactors=FALSE)
dat1[,"date"] = as.Date(dat1[,"date"], format="%Y-%m-%d")

plot()

X11()
png(full_path)
plot(dat1[,"date"], dat1[,"predict"], type="b", col="red",
     xlab="Date", ylab="Number of Infected Cases",
     main="Coronvirus Cases vs Predictions")
par(new=TRUE)
lines(dat1[,"date"], dat1[,"actual"], type="b", col="blue")


abline(v=last.t, col="grey", lwd=2)
grid(NA, 10, lwd = 2)
text(x=last.t, y=100, labels=latest.date, pos=3, col="blue", cex=1)
txt = c(paste(as.character(forecast.df[1,"date"]), round(forecast.df[1,"confirmed"],0), sep=" : "), 
        paste(as.character(forecast.df[2,"date"]), round(forecast.df[2,"confirmed"],0), sep=" : "))
hgt = max(df[,"confirmed"])
text(x=1, y=c(hgt*0.9, hgt*0.8), labels=txt, pos=4, col="red", cex=2)
dev.off()


X11()
par(mar = c(5,5,2,5))
with(dat1, plot(date, delta, type="b", col="red3", xlab="Date", ylab="Delta", ylim=c(-500,-1600)))
par(new = T)
with(dat1, plot(date, delta_pct, pch=16, axes=F, xlab=NA, ylab=NA, cex=1.2))
axis(side = 4)
mtext(side = 4, line = 3, 'Number genes selected')
legend("topleft",
       legend=c(expression(-log[10](italic(p))), "N genes"),
       lty=c(1,0), pch=c(NA, 16), col=c("red3", "black"))