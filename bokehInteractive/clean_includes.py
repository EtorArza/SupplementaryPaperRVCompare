import sys

def usage():
    print("Usage:")
    print("python bokehinteractive/clean_includes.py \"path_to_html_file\"")
    exit(1)

if len(sys.argv) != 2:
    usage()

html_filepath = sys.argv[1]

with open(html_filepath, "r") as f:
    line_list = f.readlines()

res = []
includename = None
for line in line_list:
    line = line.strip("\n")
    if line.strip(" ")[:14] == "<!-- #include ":
        if includename != None:
            print("Error, includename != None in new '<!-- #include ' section.")
        res.append(line)
        includename = line.split("#include ")[-1]
        includename = includename.split("-->")[0].strip(" ")

    elif line.strip(" ")[:9] == "<!-- #end":
        if includename == None:
            print("Error, includename == None in '<!-- #end ' section.")
        res.append(line)
        includename = None
         

    elif includename == None:
        res.append(line)

with open(html_filepath, "w") as f:
    print("\n".join(res), file=f)