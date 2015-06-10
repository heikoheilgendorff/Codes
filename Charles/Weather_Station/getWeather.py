##python script that will parse the html data file created by wview
##it will turn this into a hartrao data formatted weather file
'''
Written by HMH in June 2015

What this code does:
First it reads in the input file from the weatherstation.

Then it goes through this file, line by line and pulls out the relevant information and appending that info into a variable called weatherData.

Then it goes through weatherData and pulls out the actual values and puts them in variable x.
For example: weatherData has 'outsideTemp=24.2<br>', x has '24.2'

It then gets the date and time of the measurements from x.

Finally, it outputs all the information from x into the format required for the next part of the chain and saves it in a file called weatherDataKlerefontein.txt

'''

import re
import datetime

##first open the file
#f = open("/var/www/weather/parameterlist.htm")
path_to_input = "/home/heiko/Desktop/Charles/Weather_Station/"
path_to_output = "/home/heiko/Desktop/Charles/Weather_Station/"
f = open(path_to_input+"parameterlist.htm")

#and read in all the data
lines = f.readlines()

#search for lines that contain the keywords that we want to put into our weather file
weatherData=[]

for line in lines:
	if re.search('outsideTemp=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('stationPressure=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('outsideHumidity=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('windSpeed=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('windDirection=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('windDirectionDegrees=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('dailyRain=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('outsideDewPt=',line):
	    #print line
            weatherData.append(line)
for line in lines:
	if re.search('stationDate=',line):
	    #print line
	    weatherData.append(line)
for line in lines:
	if re.search('stationTime=',line):
	    #print line
            weatherData.append(line)

# If we want to save the output:
'''
f1 = open("original_output.txt","w")
for i in range(0,len(weatherData)):
	f1.write(weatherData[i])
f1.close()
'''

# Let's clean up the output:
x = []
for i in range(0,len(weatherData)):
	x.append(weatherData[i].split('=')[1].split('<')[0])
        

# Get the date and time right:
date = x[8]
dt = date
mn, day, yr = (int(x) for x in dt.split('/'))
year = int("20"+date[6:])
ans = datetime.date(year, mn, day)
day = ans.strftime("%A")
day_name = day[0:3]
time = x[9]
date = x[8]
day = date[3:5]
mn = date[0:2]
year = "20"+date[6:]
mnth = {'01':'Jan','02':'Feb','03':'Mar','04':'Apr','05':'May','06':'Jun','07':'Jul','08':'Aug','09':'Sep','10':'Oct','11':'Nov','12':'Dec'}
month = mnth[mn]
dt = date


# Now for formatting:
# ignore date for now:

f2 = open(path_to_output+"weatherDataKlerefontein.txt","w")
f2.write(day_name+" "+month+" "+day+" "+time+" UTC "+year+"	"+"-"+"	WX = "+x[0]+" degC, "+x[1]+" mbar, "+x[2]+" %, "+x[3]+" m/s, "+x[5]+" degrees "+x[4]+", "+x[6]+" mm, "+x[7]+" degC")


f2.close()

#from ~/cbass/gcpCbass/util/common/WxReaderSA.cc
#  data_.mtSampleTime_            = str.findNextStringSeparatedByChars("-").str();
#    data_.airTemperatureC_         = str.findNextInstanceOf("=", "degC").toDouble();
#    data_.pressure_                = str.findNextInstanceOf(",", "mbar").toDouble();
#    data_.relativeHumidity_        = str.findNextInstanceOf(",", "%").toDouble();
#    data_.windSpeed_               = str.findNextInstanceOf(",", "m/s").toDouble();
#    data_.windDirectionDegrees_    = str.findNextInstanceOf(",", "deg").toDouble();
#    data_.mtVaporPressure_         = str.findNextInstanceOf(",", "mm").toDouble();
#    data_.mtDewPoint_              = str.findNextInstanceOf(",", "degC").toDouble();


