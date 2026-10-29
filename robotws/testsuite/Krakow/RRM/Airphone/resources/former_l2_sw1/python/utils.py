from typing import Callable


def skip_if_dryrun(fun):
    # type: (Callable) -> Callable
    """Simple decorator for robot dryrun"""
    def _inner(*args, **kwargs):
        if is_dry_run():
            return
        return fun(*args, **kwargs)
    return _inner


def is_dry_run():
    # type: () -> bool
    """
    Check if Robot is running in dryrun mode.
    If Robot isn't running False is return.

    :return: True if dryrun is active, False otherwise
    """
    dry_run = False
    try:
        from robot.running.context import EXECUTION_CONTEXTS
        curr_ctx = EXECUTION_CONTEXTS.current
        if curr_ctx:
            dry_run = curr_ctx.dry_run
    except Exception as exp:
        print('Dryrun exp: {}'.format(exp))
    return dry_run
