# -*- coding: utf-8 -*

"""
Author:         Ren Biyao
Contact Mail:   biyao.ren@nokia-sbell.com
Description:    calculate avg value for input data list
example:
        ['1,2,3,4']==> the avg is 2.5
"""


def avg_calculate(input_list):
    sum = 0.0
    for cur_number in input_list:
        sum = sum + cur_number
    avg = sum / len(input_list)
    return avg


def remove_unit(input_str, alpha):
    return (input_str.partition(alpha))[0][:]
