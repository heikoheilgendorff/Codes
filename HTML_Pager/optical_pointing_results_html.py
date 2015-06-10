# This script will load images onto an html document

import glob
import webbrowser

# Open a file:

def get_list(path,name):
    name = path+name
    get_list.jumbled_list = glob.glob(name)
    return get_list.jumbled_list

def make_html(name,jumbled_list):
    make_html.filename = name+'.html'
    f = open(make_html.filename,'w')
    f.write('<!DOCTYPE html>')
    f.write('<head></head>')
    f.write('<body>')

    f.write('<table>')
    for i in range(0,len(jumbled_list)):
        f.write('<tr>')
        f.write('<td><img src="'+jumbled_list[i]+'"/></td>')
        f.write('</tr>')

    f.write('</table>')
    f.write('</body>')
    f.close()
    return make_html.filename


if __name__=='__main__':
    
    path = '/home/heiko/Desktop/Jan_2015/Plots/'
    get_list(path,'*Feb*.png')
    make_html('Optical_Pointing_Results',get_list.jumbled_list)

    # Open the HTML in Firefox
    #webbrowser.open_new_tab(make_html.filename)
    #exit()
