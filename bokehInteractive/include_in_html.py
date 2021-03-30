

def include_in_html(content_to_include, input_includename, html_filepath):


    with open(html_filepath, "r") as f:
        line_list = f.readlines()

    res = []
    includename = None
    initial_spaces = 0
    for line in line_list:
        line = line.strip("\n")
        if line.strip(" ")[:14] == "<!-- #include " or line.strip(" ")[:13] == "<!--#include " :
            if includename != None:
                print("Error, includename != None in new '<!-- #include ' section.")
            res.append(line)
            initial_spaces = line.split("<!-- #include")[0].count(" ")
            includename = line.split("#include ")[-1]
            includename = includename.split("-->")[0].strip(" ")
            if includename != input_includename:
                includename = None
            continue

        elif line.strip(" ")[:9] == "<!-- #end":
            if includename == input_includename:
                lines_to_append = content_to_include.split("\n")
                for el in lines_to_append:
                    if el == "":
                        continue
                    res.append(" "*(2+initial_spaces) + el)
                #res.append(content_to_include)
            includename = None
            

        if includename == None:
            res.append(line)

    with open(html_filepath, "w") as f:
        print("\n".join(res), file=f, end="")