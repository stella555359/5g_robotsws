# -*- coding:utf-8 -*-
import exceptions


def verify_input_start_trace(level, exec_type):
    l2_hi_exec_types = ["pdcp", "rlc"]
    print ("exec_type: ", str(exec_type))
    if level.lower() == "l2_hi":
        if not exec_type.lower() in l2_hi_exec_types:
            raise RuntimeError("Input exec_type %s illegal, expect %s" % (exec_type, " or ".join(l2_hi_exec_types)))
    elif level.lower() in ["l2_lo", "l2_ps"]:
        if str(exec_type) == "" or str(exec_type) == 'None':
            pass
        else:
            raise RuntimeError("Input exec_type %s illegal, expect EMPTY" % exec_type)
    else:
        raise RuntimeError("Input level %s illegal, should be l2_hi or l2_lo or l2_ps" % level)
