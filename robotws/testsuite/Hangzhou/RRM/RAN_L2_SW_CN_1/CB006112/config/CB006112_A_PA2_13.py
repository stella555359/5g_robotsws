from __future__ import division


def change_2D_list_to_1D_and_Cal_the_rate_bigger_than_4(li_st):
    a = []
    for i in li_st:
        a.append(i)
    b = []
    for j in a:
        if j > 4:
            b.append(j)
    c = "%f" % float(len(b)/len(a))
    return c
