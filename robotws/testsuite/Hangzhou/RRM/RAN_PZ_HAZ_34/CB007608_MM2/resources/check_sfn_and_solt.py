# -*- coding: utf-8 -*
# _*_coding:gbk_*_

sfn = 312
mod = 8
x = 1
list = ['29', '49', '59']
slot = 39
a = 312


def SFN_num(a, mod):
    print(type(a))
    print(mod)
    b = a % mod
    print(b)
    if b == 0:
        print("b=0", a)
    elif b == 1:
        print("b=1", a)
    return a


def SFN_X(a, mod):
    print(type(a))
    print(mod)
    b = a % mod
    print(b)
    if b == 0:
        print("b=0", b)
    elif b == 1:
        print("b=1", b)
    return b


def test_mod(sfn, mod):
    print(type(sfn))
#   type(mod)
#   print (sfn)
#   for x in sfn:
#       b=x
#       print (b)
#   return b
#   if sfn%mod==1:
#       b=x
#       print(b)
#       break
# return True


def get_mod(sfn, mod):
    if 1 == sfn % mod:
        print('True')
    return True


def check_list(slot, list):
    slot_str = str(slot)
    print(type(slot_str))
    print(type(list))
    if slot_str in list:
        return True
#   for i in range(len(list)):
#        print (list[i])
#        if slot==list[i]:
#           return True

# result0 = test_mod(sfn,mod)
# result1 = get_mode(sfn,mod,x)
# result2 = check_list(slot,*list)
# print(result1)
# print(result2)
