from bokeh.plotting import figure
from bokeh.resources import CDN
from bokeh.embed import file_html
from include_in_html import *
import pandas as pd
from bokeh.models import Range1d
import numpy as np

from bokeh.io import curdoc
from bokeh.layouts import column, row
from bokeh.models import ColumnDataSource, Slider, TextInput
from bokeh.plotting import figure
from bokeh.models import CustomJS, Slider, Label





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
nbins = 2000

tauparam = 0.1
lambdaparam = 0

binsize = (x_range[1] - x_range[0]) / (nbins - 1)

print(binsize)

normal1 = np.random.normal(loc = 0.05, scale = 0.0025, size = n)
normal2 = np.random.normal(loc = 0.05, scale = 0.0025, size = n)
normaltau = np.random.normal(loc = 0.05, scale = 0.0025, size = n)


ynormal1, xnormal1 = np.histogram(normal1, density=True, range=x_range, bins=nbins)
ynormal2, _ = np.histogram(normal2, density=True, range=x_range, bins=nbins)
ytau, _ = np.histogram(normaltau, density=True, range=x_range, bins=nbins)


ya = ynormal1
yb = ynormal2 * (1-tauparam) + ytau*tauparam

x = xnormal1[:-1] + (xnormal1[1] - xnormal1[0]) / 2 # plot position in the middle of bins

C_P_and_zeroes = ["Probability of X_A < X_B = 0.5"] * (len(x))
C_D_and_zeroes = ["Dominance rate of X_A over X_B = 0.5"] * (len(x))

source = ColumnDataSource(data=dict(x=x.tolist(), ya=ya, yb=yb, yacum=(ya.cumsum()*binsize).tolist(), ybcum=(yb.cumsum()*binsize).tolist(), ynormal1=ynormal1.tolist(), ynormal2=ynormal2.tolist(), ytau=ytau.tolist(), C_P_and_zeroes=C_P_and_zeroes, C_D_and_zeroes=C_D_and_zeroes))

plot1_prob = figure(plot_width=400, plot_height=400)
plot1_prob.line('x', 'ya', source=source, line_width=3, line_alpha=0.6, color="orange")
plot1_prob.line('x', 'yb', source=source, line_width=3, line_alpha=0.6)

plot1_cum = figure(plot_width=400, plot_height=400)
plot1_cum.line('x', 'yacum', source=source, line_width=3, line_alpha=0.6, color="orange")
plot1_cum.line('x', 'ybcum', source=source, line_width=3, line_alpha=0.6)

plot1_values = figure(plot_width=800, plot_height=100)
plot1_values.axis.visible = False
plot1_values.text(0, 0.501, text='C_P_and_zeroes', alpha=0.0085, text_font_size='20px', text_baseline='left', text_align='left', source=source)
plot1_values.text(0, 0.499, text='C_D_and_zeroes', alpha=0.0085, text_font_size='20px', text_baseline='left', text_align='left', source=source)

plot1_values.x_range=Range1d(0.00, 0.25)
plot1_values.y_range=Range1d(0.4975, 0.5025)



sliderTauLocation = Slider(start=-0.01, end=0.01, value=lambdaparam, step=x[1]-x[0], title="lambda", format="0[.]0000")
sliderTauSize = Slider(start=0.0, end=0.2, value=tauparam, step=.01, title="tau")

callback1 = CustomJS(args=dict(source=source, tauparam=sliderTauSize, lambdaparam=sliderTauLocation), code="""
    var data = source.data;
    var ynormal2 = data['ynormal2']
    var ytau = data['ytau']
    var binsize = 0.00002001

    var labdaImpliesIndexOfset = Math.round(lambdaparam.value / binsize);
    var indexAfterOffset = 0

    var C_P_and_zeroes = data['C_P_and_zeroes']
    var C_D_and_zeroes = data['C_D_and_zeroes']




    var yb = data['yb']
    var ybcum = data['ybcum']
    var cumprob = 0
    for (var i = 0; i < yb.length; i++) {
        indexAfterOffset = Math.min(Math.max(0, i + labdaImpliesIndexOfset), yb.length-1)
        yb[i] = ynormal2[i] * (1 - tauparam.value) + ytau[indexAfterOffset] * tauparam.value
        cumprob = cumprob + yb[i] * binsize
        ybcum[i] = cumprob
    }

    for (var i = 0; i < yb.length; i++) {
        C_P_and_zeroes[i] = "Probability of X_A < X_B = " + tauparam.value.toString()
        C_D_and_zeroes[i] = "Dominance rate of X_A over X_B = " + 0.79
    }


    source.change.emit();
""")

sliderTauLocation.js_on_change('value', callback1)
sliderTauSize.js_on_change('value', callback1)

layout1 = column(sliderTauLocation, sliderTauSize, plot1_values, row(plot1_prob, plot1_cum))



include_in_html(process_html_into_includable_section(file_html(layout1, CDN, "my plot")), "test1", html_filepath)



plot2 = figure()
plot2.circle([1,2], [3,4])
plot2.plot_height = 400
plot2.plot_width = 400

include_in_html(process_html_into_includable_section(file_html(plot2, CDN, "my plot")), "test2", html_filepath)