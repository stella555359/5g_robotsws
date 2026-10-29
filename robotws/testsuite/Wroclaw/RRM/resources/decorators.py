import os
from functools import wraps
import time
import traceback
from testsuite.Wroclaw.RRM.resources.log.log import blog


def logged_keyword(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        loc = ''
        fn = ''
        tb = traceback.extract_stack()
        if len(tb) > 2:
            loc = '%s:%d' % (os.path.basename(tb[-2][0]), tb[-2][1])
            fn = tb[-2][2]

        file_name = loc
        module = fn
        func_name = func.__name__

        blog("{}: {}(): call {} with args={} kwargs={}".format(file_name, module, func_name, args, kwargs),
             console=False)
        response = func(*args, **kwargs)
        blog("{}: {}(): {} returned {}".format(file_name, module, func_name, response), console=False)

        return response
    return wrapper


def logged_all_class_methods(cls):
    class NewCls(object):
        def __init__(self, *args, **kwargs):
            self.o_instance = cls(*args, **kwargs)

        def __getattribute__(self, s):
            """
            this is called whenever any attribute of a NewCls object is accessed. This function first tries to
            get the attribute off NewCls. If it fails then it tries to fetch the attribute from self.oInstance (an
            instance of the decorated class). If it manages to fetch the attribute from self.oInstance, and
            the attribute is an instance method then `time_this` is applied.
            """
            try:
                x = super(NewCls, self).__getattribute__(s)
            except AttributeError:
                pass
            else:
                return x
            x = self.o_instance.__getattribute__(s)
            if x == self.__init__:
                return logged_keyword(x)
            else:
                return x
    return NewCls


def wait_until_function_succeeds(retry_time_in_seconds=60, retry_interval_in_seconds=1):
    def wrapper(func):
        def inner_wrapper(*args, **kwargs):
            stop_time = time.time() + retry_time_in_seconds
            timeout_exceeded = False
            while not timeout_exceeded:
                timeout_exceeded = time.time() > stop_time
                try:
                    func(*args, **kwargs)
                except Exception:
                    time.sleep(retry_interval_in_seconds)
                else:
                    return
            if timeout_exceeded:
                raise Exception("Timeout exceeded while waiting {timeout} seconds for {nam}{arg}".format(
                    timeout=retry_time_in_seconds, nam=func.__name__, arg=args))
        return inner_wrapper
    return wrapper
