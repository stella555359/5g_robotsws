# -*- coding: utf-8 -*-
"""
:created on: 04-22-2021
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
from inspect import ismethod, isfunction
import six
from sys import exc_info
from threading import Thread
from .func_call import *
if six.PY2:
    import Queue
else:
    import queue as Queue


def log(msg):
    'doc'
    from robot.libraries.BuiltIn import BuiltIn
    BuiltIn().log(msg)


# pylint: disable=no-value-for-parameter
def run_sequential(funccalls):
    """ Run list of function calls in sequence.
    @param FuncCall funccalls: function calls list
    """
    results = []
    for funccall in funccalls:
        try:
            res = funccall.func(*funccall.args, **funccall.kwargs)
            result = FuncResultReturnValue(
                threadame=funccall.threadame,
                returnvalue=res)
        except Exception as e:
            result = FuncResultException(
                threadame=funccall.threadame,
                exception=e, traceback=exc_info()[2])
        results.append(result)
    return results


class Ta_Parallel():
    'run parallel'

    def __init__(self):
        ''
        pass

    def _get_queue(self, newfunccalls, stoponfirstexception):
        ''
        n = len(newfunccalls)
        results = [None] * n
        outstandingresults = set()
        for i in range(n):
            outstandingresults.add(i)
        for i in range(n):
            while True:
                try:
                    (j, funcresult) = self.queue.get(block=True, timeout=10)
                    self.queue.task_done()
                    outstandingresults.remove(j)
                    if isinstance(funcresult,
                                  FuncResultException) and stoponfirstexception:
                        raise ParallelError(
                            funcresult.threadname, funcresult.exception)
                    else:
                        results[j] = funcresult
                    break
                except Queue.Empty:
                    log("waiting for function calls: %s" % ", ".join(
                        ["(%s)" % newfunccalls[i] for i in outstandingresults]))
        return results

    def _makewrapper(self, funccall, j):
        'in'
        def threadwrapper(*args, **kwargs):
            'in'
            try:
                res = funccall.func(*args, **kwargs)
                self.queue.put((j, FuncResultReturnValue(
                    threadname=funccall.threadname,
                    returnvalue=res)))
                return res
            except Exception as e:
                self.queue.put((j, FuncResultException(
                    threadname=funccall.threadname,
                    exception=e, traceback=exc_info()[2])))
        return threadwrapper

    def run_parallel(self, funccalls, stoponfirstexception=True):
        """ Run list of function calls in parallel.
        :param FuncCall funccalls: function calls list
        :param bool stoponfirstexception: flag to stop execution on the first exception (default is True)
        """
        self.queue = Queue.Queue()
        threads = []

        threadmap = {}
        for funccall in funccalls:
            if funccall.threadname not in threadmap:
                threadmap[funccall.threadname] = [funccall]
            else:
                threadmap[funccall.threadname].append(funccall)

        newfunccalls = []
        for threadname in threadmap:
            if len(threadmap[threadname]) == 1:
                newfunccalls.append(threadmap[threadname][0])
            else:
                newfunccalls.append(
                    FuncCall(
                        threadname=threadname,
                        func=run_sequential,
                        args=(threadmap[threadname],)))

        for (i, funccall) in enumerate(newfunccalls):
            thread = Thread(
                target=self._makewrapper(funccall, i),
                name=funccall.threadname,
                args=funccall.args,
                kwargs=funccall.kwargs)
            threads.append(thread)
            thread.daemon = True
            thread.start()
        return self._get_queue(newfunccalls, stoponfirstexception)

    def add_func(self, module_name, func_name, threadname, args=(), kwargs={}):
        """ add func which will be run parallel.
        :param module_name: kw comes from which  library
        :param func_name: means keyword name, it should be in module_name's library
        :param thread_name: just define a different name if use same keyword
        :param args: keyword's args, format should be tuple
        :param kwargs: keyword's kwargs, format should be dictionary
        """
        mod = __import__(module_name)
        class_init = getattr(mod, module_name)()
        funccall = FuncCall(
            threadname=threadname,
            func=getattr(class_init, func_name),
            args=args,
            kwargs=kwargs)
        return funccall, class_init

    def add_func_in_same_obj(self, class_init,  func_name, threadname, args=(), kwargs={}):
        """ add func in same class object which will be run parallel.
        :param class_init: add_func's return class object, same alias need to use
        :param func_name: means keyword name, it should be in module_name's library
        :param thread_name: just define a different name if use same keyword
        :param args: keyword's args, format should be tuple
        :param kwargs: keyword's kwargs, format should be dictionary
        """
        funccall = FuncCall(
            threadname=threadname,
            func=getattr(class_init, func_name),
            args=args,
            kwargs=kwargs)
        return funccall
