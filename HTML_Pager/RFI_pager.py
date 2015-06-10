# This script will load images onto an html document

import glob
import webbrowser

# Open a file:

def get_list(path,name):
    name = path+name
    get_list.jumbled_list = glob.glob(name)
    return get_list.jumbled_list

def make_homepage():
    f = open('RFI_Homepage.html','w')
    f.write('<!DOCTYPE html>')
    f.write('<head></head>')
    f.write('<body>')

    # Links
    f.write('<a href="Histograms.html"> Link to Histograms </a>')
    f.write('<p><a href="Intensity.html"> Link to Intensity </a></p>')
    f.write('<a href="Polarisation.html"> Link to Polarisation </a>')
    

def make_html(name,jumbled_list):
    make_html.filename = name+'.html'
    f = open(make_html.filename,'w')
    f.write('<!DOCTYPE html>')
    f.write('<head></head>')
    f.write('<body>')

    # Link to Homepage
    f.write('<a href="RFI_Homepage.html"> Link to Homepage </a>')

    f.write('<table>')
    if len(jumbled_list)%2 == 0:
        for i in range(0,len(jumbled_list),2):
            f.write('<tr>')
            f.write('<td><img src="'+jumbled_list[i]+'"/></td>')
            f.write('<td><img src="'+jumbled_list[i+1]+'"/></td>')
            f.write('</tr>')
    else:
        for i in range(0,len(jumbled_list)):
            f.write('<tr>')
            f.write('<td><img src="'+jumbled_list[i]+'"/></td>')
            f.write('</tr>')

    f.write('</table>')
    f.write('</body>')
    f.close()
    return make_html.filename


if __name__=='__main__':
    
    path = '/home/heiko/Work/PhD/RFI/April_2015/Plots/'
    make_homepage()
    get_list(path,'Hist*.png')
    make_html('Histograms',get_list.jumbled_list)
    get_list(path,'Int*.png')
    make_html('Intensity',get_list.jumbled_list)
    get_list(path,'Pol*.png')
    make_html('Polarisation',get_list.jumbled_list)
    # Open the HTML in Firefox
    #webbrowser.open_new_tab(make_html.filename)
    #exit()
