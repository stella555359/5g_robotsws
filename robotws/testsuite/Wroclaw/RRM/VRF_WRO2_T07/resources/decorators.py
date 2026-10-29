from robot.api import logger
import os
import inspect
from functools import wraps
import time
import traceback

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.exceptions import TimeoutError
from testsuite.Wroclaw.RRM.resources.log.log import blog
from robot.libraries.BuiltIn import register_run_keyword, RobotNotRunningError
from robot.libraries.BuiltIn import BuiltIn as RobotBuiltIn


def is_robot_running():
    try:
        RobotBuiltIn().get_variable_value('${TEST NAME}')
        return True
    except RobotNotRunningError:
        return False


def get_module_path_from_filename(func):
    raw_module_path = os.path.relpath(inspect.getfile(func))
    if '/' in raw_module_path:
        module_path = raw_module_path.replace('/', '.').strip('.py')
    else:
        module_path = raw_module_path.replace('\\', '.').strip('.py')
    return module_path


def get_module_path(func, args):
    module_path = get_module_path_from_filename(func)
    if args:
        if inspect.isfunction(func) and ' at ' in str(args[0]):
            module_path = str(args[0]).strip('<').split()[0]
    return module_path


def get_args_without_self_object(func, args):
    if args:
        if inspect.isfunction(func) and ' at ' in str(args[0]):
            return list(args[1:])
        else:
            return list(args)
    else:
        return list()


def generate_label_html(label_name, label_type):
    label_pass_html = "<span class='label {}'>{}</span>".format(label_type, label_name)
    return label_pass_html


def generate_message_body_html(message, remove_equal_sing=False):
    if remove_equal_sing:
        message_body_html = "<span class='generated'>{}</span>".format(message)
    else:
        message_body_html = "<span class='generated'> = {}</span>".format(message)
    return message_body_html


def function_start_logger(function_name, args, kwargs, runner):
    logger.info("<h4>{}{}</h4>".format(generate_label_html('FUNCTION START', 'pass'),
                                       generate_message_body_html(function_name, remove_equal_sing=True)), html=True)
    logger.info("{}{}".format(generate_label_html('ARGS', 'debug'),
                              generate_message_body_html(args)), html=True)
    logger.info("{}{}".format(generate_label_html('KWARGS', 'debug'),
                              generate_message_body_html(kwargs)), html=True)
    logger.info("{}{}".format(generate_label_html('RUNNER', 'debug'),
                              generate_message_body_html(runner)), html=True)


def function_end_logger(func_name, full_function_path, func_response):
    return_label = " {} RETURNED".format(func_name.upper())
    return_label_html = generate_label_html(return_label, 'debug')
    return_body_html = generate_message_body_html(func_response)

    logger.info("{}{}".format(return_label_html, return_body_html), html=True)
    logger.info("<h4>{}{}</h4>".format(
        generate_label_html('FUNCTION END', 'pass'),
        generate_message_body_html(full_function_path, remove_equal_sing=True)), html=True)


def logged_function(file_name, module, func, args, kwargs):
    func_name = func.__name__
    blog("{}: {}(): call {} with args={} kwargs={}".format(file_name, module, func_name, args, kwargs),
         console=False)
    func_response = func(*args, **kwargs)
    blog("{}: {}(): {} returned {}".format(file_name, module, func_name, func_response), console=False)
    return func_response


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

        if is_robot_running():
            module_path = get_module_path(func, args)
            full_function_path = " {}.{}".format(module_path, func_name)
            runner = " {} / {}".format(file_name, module)
            function_start_logger(full_function_path, args, kwargs, runner)
            func_response = func(*args, **kwargs)
            function_end_logger(func_name, full_function_path, func_response)
        else:
            func_response = logged_function(file_name, module, func, args, kwargs)

        return func_response
    return wrapper


def logged_block_keyword(func):
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

        if not hasattr(func, 'triggered_by_run_keyword'):
            try:
                setattr(func, 'triggered_by_run_keyword', True)
            except AttributeError:
                return logged_function(file_name, module, func, args, kwargs)

            if 'wrapper' in func_name:
                blog("@logged_block_keyword decorator should not wrap other wrappers, move it under other decorators!",
                     console=False, level='WARN')
                delattr(func, 'triggered_by_run_keyword')
                return logged_function(file_name, module, func, args, kwargs)

            arguments = get_args_without_self_object(func, args)

            for key, value in kwargs.items():
                arguments.append("{}={}".format(key, value))

            module_path = get_module_path(func, args)
            func_name = "{}.{}".format(module_path, func_name)

            try:
                RobotBuiltIn().import_library(module_path)
                register_run_keyword(module, func_name, len(arguments), deprecation_warning=False)
                response = RobotBuiltIn().run_keyword(func_name, *arguments)
            except RobotNotRunningError:
                delattr(func, 'triggered_by_run_keyword')
                response = logged_function(file_name, module, func, args, kwargs)

        else:
            delattr(func, 'triggered_by_run_keyword')
            response = logged_function(file_name, module, func, args, kwargs)

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


def wait_until_function_succeeds(retry_time_in_seconds=60, retry_interval_in_seconds=1,
                                 exception=Exception, part_of_msg=None):
    def wrapper(func):
        def inner_wrapper(*args, **kwargs):
            stop_time = time.time() + retry_time_in_seconds
            timeout_exceeded = False
            while not timeout_exceeded:
                timeout_exceeded = time.time() > stop_time
                try:
                    return func(*args, **kwargs)
                except exception as e:
                    blog("{} exception occurred.".format(type(e).__name__))
                    blog(e)
                    if part_of_msg is None or any(part in str(e.message) for part in part_of_msg):
                        blog("Will retry after {}s...".format(retry_interval_in_seconds))
                        time.sleep(retry_interval_in_seconds)
                    else:
                        return exception(e.message)
            if timeout_exceeded:
                raise TimeoutError("Timeout exceeded while waiting {timeout} seconds for {nam}{arg}".format(
                    timeout=retry_time_in_seconds, nam=func.__name__, arg=args))
        return inner_wrapper
    return wrapper
