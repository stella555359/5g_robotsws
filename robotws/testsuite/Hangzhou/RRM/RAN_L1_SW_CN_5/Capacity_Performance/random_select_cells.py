# -*- coding: utf-8 -*


from random import shuffle


def random_split_list(list, group_num):
    shuffle(list)
    elem_num = int(len(list)/int(group_num))
    sub_list = []
    for i in range(0, len(list), elem_num):
        sub_list.append(list[i:i+elem_num])
    return sub_list


print(random_split_list([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 4))
