

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


#X11()

fnm = "/actual-vs-predict.png"
full_path = paste(home, fnm, sep="")

png(full_path, width=680, height=480)
par(mar = c(5,5,5,5))
with(dat1, plot(date, delta, type="b", col="black", pch=16, cex=2, xaxt="n",
                xlab="Date", ylab="Delta", ylim=c(-1700,0)))
title(main="Fig. 1 Actual Infected Cases minus Model Prediction")
mtext(text="negative ==> actual less than prediction", side=3, line=1)
axis(1, dat1$date, format(dat1$date, "%b %d"), cex.axis=1 )
par(new = T)
with(dat1, plot(date, delta_pct, type="b", col="red3", pch=1, 
                axes=F, xlab=NA, ylab=NA, cex=2, ylim=c(-16,0)))
axis(side = 4)
mtext(side = 4, line = 3, 'percentage')
legend("topleft",
       legend=c("Delta", "percent"),
       lty=c(1,1), pch=c(16, 1), col=c("black", "red3"))
dev.off()





