import logging
import sys
logging.basicConfig(filename='log_l2_template.log', level='DEBUG')


def logger(fn):
    def inner(*args, **kwargs):
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.debug("\n\tMethod: {0},  \n\t\tPositional Arguments: {1},  \n\t\tKeyword Arguments: {2},\
                           \n\tReturns: {3}".format(fn.__name__, args, kwargs, func_return))
        return func_return
    return inner


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        if "--dryrun" not in sys.argv:
            logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner
