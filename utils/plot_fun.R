

#' Plot actual and model predictions
#'
#' @param df data frame with at least these columns : date, confirmed, exp_pred, lin_pred, t
#' @param fnm name of the output file, including full path
#' @description 
#'   
#' @return None
#' @export
predict_vs_actual_plot = function(df, cur_t, title, fnm) {
  n = nrow(df)
  cur_date = as.character(format(df[which(df$t == cur_t), "date"], "%b-%d"))
  fmax1 = max(df[,"exp_pred"], na.rm=TRUE)
  fmax2 = max(df[,"lin_pred"], na.rm=TRUE)
  amax = max(df[,"confirmed"], na.rm=TRUE)
  ymax = max(fmax1, fmax2, amax)
  ymax = ceiling(ymax/1000)*1000
  
  png(fnm, width=680, height=480)
  # actual
  plot(df[,"t"], df[,"confirmed"], type="p", pch=1, cex=1, bg="black",
       xaxt="n", ylim=c(0,ymax),
       xlab="Date", ylab="# confirmed cases",
       main=title)
  # only print every 4th date
  ix = seq(from=df[1,"t"], to=df[n, "t"], by=4)
  axis(1, at=df$t[ix], format(df$date[ix], "%b %d"), cex.axis = .8, tick=TRUE)
  # exp model fit line
  lines(df[(n-15):n,"t"], df[(n-15):n,"exp_pred"], col="red", lwd=2.5, lty=2)
  # linear model fit linear
  lines(df[(n-15):n,"t"], df[(n-15):n,"lin_pred"], col="blue", lwd=2.5, lty=5)
  # exp model prediction 
  points(df[(cur_t+1):(cur_t+2),"t"], df[(cur_t+1):(cur_t+2),"exp_pred"], cex=2, pch=19, col="red")
  # linear model prediction 
  points(df[(cur_t+1):(cur_t+2),"t"], df[(cur_t+1):(cur_t+2),"lin_pred"], cex=2, pch=19, col="blue")
  # divider line
  abline(v=cur_t, col="grey", lwd=2)
  grid(nx=NA, ny=NULL, lwd = 2)
  # today's date
  text(x=cur_t, y=100, labels=cur_date, pos=3, col="blue", cex=0.8)
  # format the numbers
  txt1 = paste(as.character(df[cur_t+1, "date"]), ":") 
  txt2 = paste(format(round(df[cur_t+1, "exp_pred"],0), big.mark=","), "(exp)")
  txt3 = paste(format(round(df[cur_t+1, "lin_pred"],0), big.mark=","), "(linear)")
  # prediction text
  text(x=min(df[,"t"]), y=ymax*0.76, labels=txt1, pos=4, col="red", cex=1.3)
  text(x=min(df[,"t"])+1, y=ymax*0.7, labels=txt2, pos=4, col="red", cex=1.3)
  text(x=min(df[,"t"])+1, y=ymax*0.64, labels=txt3, pos=4, col="red", cex=1.3)
  # mark the two sides
  text(x=cur_t, y=ymax*0.2, labels="Forecast", pos=4, col="red4", cex=1)
  text(x=cur_t-0.5, y=ymax*0.2, labels="Actual", pos=2, col="red4", cex=1)
  # put legend in the upper left hand corner
  legend("topleft",
         legend=c("exp fit", "linear fit", "actual"),
         lty=c(2,5,0), pch=c(19, 19, 1), col=c("red", "blue", "black"))
  
  dev.off()
}


#' Plot beta parameter over time
#'
#' @param df usu the matrix Daily_updates
#' @param title title of the plot
#' @param plot_fnm name of the output file, full path
#' @description Plot beta over time.
#' @return None
#' @export
beta_plot = function(df, title, plot_fnm) {
  dte = as.Date(rownames(df))
  png(plot_fnm, width=680, height=480)
  plot(dte, df[,"beta"], type="b", pch=21, cex=2, col="black", bg="red",
       xaxt="n",
       xlab="Date", ylab="Fitted Beta",
       main=title)
  # only print every 4th date
  ix = seq(from=1, to=nrow(df), by=3)
  axis(1, at=dte[ix], format(dte[ix], "%b %d"), cex.axis = .8, tick=TRUE)
  grid(nx=NA, ny=NULL)
  dev.off() 
}

#' Plot model prediction errors
#'
#' @param dat_fnm csv file with the prediction errors 
#' @param title title of the plot
#' @param plot_fnm name of the output file, full path
#' @description Plot the errors of the exponential model over time. 
#'    Require file "actual-vs-predict.csv"
#' @return None
#' @export
exp_delta_plot = function(dat_fnm, title, plot_fnm) {
  dat1 = read.csv(dat_fnm, header=TRUE, stringsAsFactors=FALSE)
  dat1[,"date"] = as.Date(dat1[,"date"], format="%Y-%m-%d")
  delta_min = min(dat1[,"delta"], na.rm = TRUE)
  delta_max = max(dat1[,"delta"], na.rm = TRUE)
  ymin = floor(delta_min/1000)*1000
  ymax = ceiling(delta_max/1000)*1000

  png(plot_fnm, width=680, height=480)
  with(dat1, plot(date, delta, type="b", col="black", pch=16, cex=2, xaxt="n",
                  xlab="Date", ylab="Actual - Predict", ylim=c(ymin,ymax)))
  title(main=title)
  axis(1, dat1$date, format(dat1$date, "%b %d"), cex.axis=1 )
  mtext(text="negative ==> actual less than predict", side=3, line=0)
  text(x=as.integer(dat1[1,"date"]), y=ymin*0.5, 
       labels="Actual # have been consistently less than predict", 
       cex=2, col="grey", pos=4)
  par(new = T)
  pct_min = min(dat1[,"delta_pct"], na.rm = TRUE)
  pct_max = max(dat1[,"delta_pct"], na.rm = TRUE)
  ymin = floor(pct_min/10)*10
  ymax = ceiling(pct_max/10)*10
  with(dat1, plot(date, delta_pct, type="b", col="red3", pch=1, 
                  axes=F, xlab=NA, ylab=NA, cex=2, ylim=c(ymin, ymax)))
  axis(side = 4)
  mtext(side = 4, line = 3, 'percentage')
  legend("topright",
         legend=c("Delta (left axis)", "Delta % (right)"),
         lty=c(1,1), pch=c(16, 1), col=c("black", "red3"))
  dev.off()
}



