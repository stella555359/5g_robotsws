import csv


def searchFile(filename, searchName):
    f1 = open(filename, 'r', encoding='utf-8')
    x = {}
    y = []
    for ll, lines in enumerate(f1):
        lines = lines.rstrip("\n")
        if ":" in lines:
            if ll == 0:
                value = lines
            else:
                x[value] = y
                value = lines
                y = []
        else:
            y.append(lines)
    x[value] = y
    for i, j in x.items():
        for k in j:
            if searchName in k:
                return i
    return "not find"
