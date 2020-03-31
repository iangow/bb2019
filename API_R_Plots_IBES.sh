#	API_R_Plots_IBES.sh: creates API plot .cmd
#	chmod +x ./API_R_Plots_IBES.sh
#	./API_R_Plots_IBES.sh > ./API_R_Plots_IBES.cmd
#	chmod +x ./API_R_Plots_IBES.cmd
#	R --no-restore --no-save --slave < ./API_R_Plots_IBES.cmd

echo "#	R --no-restore --no-save --slave < ./API_R_Plots_IBES.cmd"

for country in  AUS CAN CHN DEU FRA GBR HKG IDN JPN KOR MYS NZL PHL SGP THA TWN

do

	echo "BB68_data <- read.table(\"./Country_Results/"$country"/APIs_IBES_to_plot_"$country".txt\",sep=\"\t\",stringsAsFactors=FALSE,header=TRUE)"
	echo "x <- as.numeric(BB68_data[1:540, \"Day\"])"
	echo "xrange <- range(-400,200)"
	echo "y1 <- BB68_data[1:540, \"API_Good_News\"]"
	echo "y2 <- BB68_data[1:540, \"API_Bad_News\"]"
	echo "y2 <- (y2 - y2[1])"
#	y3 is the average of y1 and y2; we can plot this as well (to do this, enable all references to y3)
	echo "y3 <- (y1 + y2)/2"
#	to replace y1 and y2 by their differences from their average, enable next 2 statements
	echo "y1 <- (y1 - y3)"
	echo "y2 <- (y2 - y3)"

#	get the ranges for the x and y axes of this graph
	echo "y1range <- range(y1)"
	echo "y2range <- range(y2)"
	echo "api_min = min(c(range(y1),range(y2)))"
	echo "api_min <- floor(100*api_min)/100"
	echo "api_max = max(c(range(y1),range(y2)))"
	echo "api_max <- ceiling(100*api_max)/100"
	echo "yrange <- range(api_min,api_max)"
	echo "colors <- rainbow(2)"
	echo "pdf(\"./Country_Results/$country/F3_API_plot_base_case_"$country".pdf\")"
	echo "plot(xrange, yrange, type=\"n\", xlab=\"Event Day\", ylab=\"API\")"
	echo "lines(x,y1,type=\"l\", lwd=1.5, col=\"green\")"
	echo "lines(x,y2,type=\"l\", lwd=1.5, col=\"red\")"
	echo "abline(v=0, lty=3, lwd=1, col=\"black\")"
	echo "abline(h=0, lty=1, lwd=1, col=\"black\")"
	echo "legend(bty=\"n\", xrange[1], yrange[2], c(\"Good News\",\"Bad News\"), col=c(\"green\",\"red\"), lty=1:1)"
	echo "title(cex.main=1, main = paste(\""$country--IBES, base case"\"))"
	echo "dev.off( )"
	echo "rm(y1,y2,y3)"

	done

echo "q( )"

exit
