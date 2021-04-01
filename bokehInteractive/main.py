from bokeh.plotting import figure
from bokeh.resources import CDN
from bokeh.embed import file_html
from include_in_html import *
import pandas as pd

import numpy as np

from bokeh.io import curdoc
from bokeh.layouts import column, row
from bokeh.models import ColumnDataSource, Slider, TextInput
from bokeh.plotting import figure
from bokeh.models import CustomJS, Slider





html_filepath = "../../../EtorArza.github.io/pages/2021-interactive-comparing-RV.html"




def process_html_into_includable_section(inputhtml):

    splitted_html = inputhtml.split("\n")
    splitted_html = [el.strip(" ") for el in splitted_html]
    inputhtml = "\n".join(splitted_html)
    splitted_html = inputhtml.split("\n\n\n")



    for block in splitted_html:
        if "https://cdn.bokeh.org/bokeh/release/bokeh" in block:
            print("-----------------------------------")
            print("Add this to html head:   ")
            print("")
            print(block)
            print("-----------------------------------")


    inputhtml = "\n".join(splitted_html)
    html_to_be_included = inputhtml.split("<body>")[-1].split("</body>")[0]

    return html_to_be_included




print("-------------")
print("EXAMPLE: show that properties prop:scale_of_portions and prop:prop:bounds_with_interpretation are incompatible ")
print("-------------")

x_range = (0.03,0.07)


n = 10000000
nbins = 1000

tauparam = 0.05
lambdaparam = 0.0

normal1 = np.random.normal(loc = 0.05, scale = 0.00125, size = n)
normal2 = np.random.normal(loc = 0.0525, scale = 0.00125, size = n)
normaltau = np.random.normal(loc = 0.0475, scale = 0.00125, size = n)


ynormal1, xnormal1 = np.histogram(normal1, density=True, range=x_range, bins=nbins)
ynormal2, _ = np.histogram(normal2, density=True, range=x_range, bins=nbins)
ytau, _ = np.histogram(normaltau, density=True, range=x_range, bins=nbins)


ya = ynormal1
yb = ynormal2 * (1-tauparam) + ytau*tauparam

x = xnormal1[:-1] + (xnormal1[1] - xnormal1[0]) / 2 # plot position in the middle of bins




source = ColumnDataSource(data=dict(x=x.tolist(), ya=ya, yb=yb, ynormal1=ynormal1.tolist(), ynormal2=ynormal2.tolist(), ytau=ytau.tolist(), tauparam=[tauparam]*len(ya.tolist()), lambdaparam=[lambdaparam]*len(ya.tolist())))

plot1 = figure()
plot1.line('x', 'ya', source=source, line_width=3, line_alpha=0.6, color="orange")
plot1.line('x', 'yb', source=source, line_width=3, line_alpha=0.6)

callLambdaLocation = CustomJS(args=dict(source=source), code="""
    var data = source.data;
    var f = cb_obj.value
    var ynormal2 = data['ynormal2']
    var ytau = data['ytau']

    var tauparam = data['tauparam']
    var lambdaparam = data['lambdaparam']

    lambdaparam[0] = f


    var yb = data['yb']

    for (var i = 0; i < yb.length; i++) {
        yb[i] = ynormal2[i] * (1 - tauparam[0]) + ytau[i] * tauparam[0]
    }
    source.change.emit();
""")

callTauSize = CustomJS(args=dict(source=source), code="""
    var data = source.data;
    var f = cb_obj.value


    var ynormal2 = data['ynormal2']
    var ytau = data['ytau']

    var tauparam = data['tauparam']
    var lambdaparam = data['lambdaparam']

    tauparam[0] = f


    var yb = data['yb']

    for (var i = 0; i < yb.length; i++) {
        yb[i] = ynormal2[i] * (1 - tauparam[0]) + ytau[i] * tauparam[0]
    }
    source.change.emit();
""")


sliderTauLocation = Slider(start=-0.1, end=0.1, value=lambdaparam, step=.01, title="lambda")
sliderTauSize = Slider(start=0.0, end=1.0, value=tauparam, step=.01, title="tau")
sliderTauLocation.js_on_change('value', callLambdaLocation)
sliderTauSize.js_on_change('value', callTauSize)

layout1 = column(sliderTauLocation, sliderTauSize, plot1)



include_in_html(process_html_into_includable_section(file_html(layout1, CDN, "my plot")), "test1", html_filepath)



plot2 = figure()
plot2.circle([1,2], [3,4])
plot2.plot_height = 400
plot2.plot_width = 400

include_in_html(process_html_into_includable_section(file_html(plot2, CDN, "my plot")), "test2", html_filepath)