def check_special_line(content):
    list1 = content.splitlines()
    list1.reverse()
    return list1[5].replace(' ', '')
