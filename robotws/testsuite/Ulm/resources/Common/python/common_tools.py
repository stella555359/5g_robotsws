import robot.api.logger as logger
import inspect
import functools


def python_log(function):
    """
    Function decorator logging entry + exit and parameters of functions.
    Entry and exit as logger.info, parameters as logger.DEBUG.
    """

    @functools.wraps(function)
    def wrapper(*args, **kwargs):
        # Log function entry
        func_name = function.__name__
        logger.info("Enter {}()".format(func_name))

        # Log function params (args and kwargs)
        if hasattr(inspect, "signature"):
            func_args = inspect.signature(
                function).bind(*args, **kwargs).arguments
        else:
            data = inspect.getargspec(function)
            if data.defaults:
                func_args = dict(
                    zip(reversed(data.args), reversed(data.defaults)))
            else:
                func_args = {}
            func_args.update(kwargs)
            pos_dict = dict(zip(data.args, args))
            func_args.update(pos_dict)

        func_args_str = ', '.join(
            "{} = {}".format(var_name, var_value)
            for var_name, var_value
            in func_args.items()
        )
        logger.debug("{} arguments: {}".format(func_name, func_args_str))

        # Execute wrapped (decorated) function:
        out = function(*args, **kwargs)

        # Log the exit of the function and the result it returns.
        logger.info("Exit {}()! => {}".format(func_name, out))

        return out

    return wrapper
