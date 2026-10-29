# -*- coding: utf-8 -*

patternId = ['aa00bb00', '2222']
list1 = ['3300', 'aa00', 'aa00']
list2 = ['2200', '1100', 'bb00']
list3 = ['ss', '22', '00']


def check_patternId(aimid, *lists):
    patternId_list = recombination_patternId(*lists)
    print(patternId_list)
    for i in range(len(patternId_list)):
        for j in range(len(aimid)):
            if aimid[j] == patternId_list[i]:
                print('aim patternId included')
                return True
    return False


def recombination_patternId(*lists):
    len1 = len(lists)
    len2 = len(lists[0])
    check = True
    relist = []
    for i in range(len1):
        if len(lists[i]) != len2:
            check = False
    if check:
        for j in range(len2):
            patternstr = ''
            for k in range(len1):
                patternstr += lists[k][j]
            print(patternstr)
            relist.append(patternstr)
    return relist


# recombination_patternId(list1, list2)
# result = check_patternId(patternId, list1, list2)
# print(result)
