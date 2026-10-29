def induce_delay_tc_start(minute):
    min = int(minute)
    lastdigit = int((float(repr(min)[-1])))
    check5 = [5, 0]
    check4 = [4, 9]
    check3 = [3, 8]
    check2 = [2, 7]
    check1 = [1, 6]
    if lastdigit in check1:
        return 5
    elif lastdigit in check2:
        return 1
    elif lastdigit in check3:
        return 1
    elif lastdigit in check4:
        return 65
    elif lastdigit in check5:
        return 65
    else:
        return 20


def induce_delay_pm_start(minute):
    min = int(minute)
    lastdigit = int((float(repr(min)[-1])))
    check5 = [5, 0]
    check4 = [4, 9]
    check3 = [3, 8]
    check2 = [2, 7]
    check1 = [1, 6]
    if lastdigit in check5:
        return 305
    elif lastdigit in check4:
        return 70
    elif lastdigit in check3:
        return 130
    elif lastdigit in check2:
        return 190
    elif lastdigit in check1:
        return 250
    else:
        return 200
