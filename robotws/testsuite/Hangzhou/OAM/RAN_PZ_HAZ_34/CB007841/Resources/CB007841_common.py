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


def searchSfpPowerLevel(filename):
    res = []
    count = 0
    with open(filename) as files:
        while count < 2:
            text = files.readline()
            index1 = text.find("SfpPowerLevel")
            index2 = text.find("HostPowerLevel")
            if index1 > 0:
                res.append(text[index1 + 16])
                count += 1
            if index2 > 0:
                res.append(text[index2 + 17])
                count += 1
    if res[0] != 0 and int(res[0]) <= int(res[1]):
        return True
    else:
        return False


def searchSfpPowercClass(filename):
    with open(filename, "r", encoding="utf-8") as f:
        text = f.readlines()[6]
        a = '{0:b}'.format(int(text[4:6], 16))
        if len(a) < 5:
            if a[-2] == '1':
                return True
            else:
                return False
        else:
            if a[-2] == '1' and a[-6] == '0':
                return True
            else:
                return False


def searchSfpPowercClass3(filename):
    with open(filename, "r", encoding="utf-8") as f:
        filecontent = [line for line in f.readlines()]
        text = filecontent[6]
        a = '{0:b}'.format(int(text[4:6], 16))
        if a[-2] == '1' and a[-6] == '1':
            text = filecontent[25]
            a = '{0:b}'.format(int(text[4:6], 16))
            if len(a) < 5:
                if a[-2] == '1':
                    return True
                else:
                    return False
            else:
                if a[-2] == '1' and a[-6] == '0':
                    return True
                else:
                    return False
        else:
            return False
