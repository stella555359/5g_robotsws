import csv

"""
Func:get_require_attribut
Inp Arg: filename,event,parameter
Ret: all the values of parameter
"""


def get_require_attribut(filename, event, parameter):
    lst = []
    with open(filename) as fp:
        f_cont = csv.reader(fp)
        for line in f_cont:
            if "type" in line and parameter in line:
                idx = line.index(parameter)
            if event in line:
                m = line[idx]
                lst.append(float(m))
    return lst


"""
Func:get_max
Inp Arg: lst,value
Ret: Pass/Fail
"""


def get_max(lst, value):
    x = max(lst)
    if x == float(value):
        return 'Pass'
    else:
        return 'Fail'
