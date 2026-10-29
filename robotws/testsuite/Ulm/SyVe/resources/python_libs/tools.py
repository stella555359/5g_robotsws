import pprint
import json
import sys


def PrettyPrintFormater(data):
    pp = pprint.PrettyPrinter(indent=4)
    return pp.pformat(data)


def CheckAlarmInList(alarms_list):
    alarms = ""
    for item in alarms_list:
        alarms = alarms + "\n" + json.dumps(item)
    return alarms


def pretty_print_object(clas, indent=0, index_prefix=''):
    print(' ' * indent + index_prefix + type(clas).__name__ + '():', file=sys.__stdout__)
    indent += 4
    for k, v in clas.__dict__.items():
        if isinstance(v, list):
            for idx, el in enumerate(v):
                if '__dict__' in dir(el):
                    pretty_print_object(el, indent, index_prefix="%s[%d]." % (k, idx))
        elif '__dict__' in dir(v):
            pretty_print_object(v, indent)
        else:
            print(' ' * indent + index_prefix + k + ': ' + str(v), file=sys.__stdout__)
