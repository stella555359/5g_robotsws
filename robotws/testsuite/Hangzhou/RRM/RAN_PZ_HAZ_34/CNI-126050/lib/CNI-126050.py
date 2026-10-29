
def compare_value_for_lists(list_s, list_l):
    Flag = True
    for i in range(0, len(list_s)):
        if list_s[i] > list_l[i]:
            Flag = False
            break
    return Flag


def compare_value_for_dict(dict_s, dict_l):
    Flag = True
    for item in dict_s:
        key = item
        value_s = dict_s[item]
        if key in dict_l.keys():
            value_l = dict_l[key]
            if value_s > value_l:
                Flag = False
                break
    return Flag
