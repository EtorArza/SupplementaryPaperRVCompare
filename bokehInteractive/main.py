from bokeh.plotting import figure
from bokeh.resources import CDN
from bokeh.embed import file_html
from include_in_html import *

plot = figure()
plot.circle([1,2], [3,4])
plot.plot_height = 400
plot.plot_width = 400


plot2 = figure()
plot2.circle([1,2], [3,4])
plot2.plot_height = 400
plot2.plot_width = 400


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




# html_to_be_included.split("\n")
# html_to_be_included = "\n".join([el.strip(" ") for el in html_to_be_included])



include_in_html(process_html_into_includable_section(file_html(plot, CDN, "my plot")), "test1", html_filepath)
include_in_html(process_html_into_includable_section(file_html(plot2, CDN, "my plot")), "test2", html_filepath)