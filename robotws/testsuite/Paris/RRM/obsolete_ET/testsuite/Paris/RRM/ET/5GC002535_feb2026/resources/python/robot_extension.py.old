from robot.libraries.BuiltIn import BuiltIn


def run_keyword_and_warn_on_failure(name, *args):
    """Runs the specified keyword logs a warning if the keyword fails.
    This keyword is similar to `Run Keyword And Ignore Error` but if the executed
    keyword fails, the error message is logged as a warning to make it more
    visible. Returns status and possible return value or error message exactly
    like `Run Keyword And Ignore Error` does.
    Errors caused by invalid syntax, timeouts, or fatal exceptions are not
    caught by this keyword. Otherwise this keyword itself never fails.
    New in Robot Framework 4.0.
    """
    status, message = BuiltIn().run_keyword_and_ignore_error(name, *args)
    if status == 'FAIL':
        BuiltIn().log("\nExecuting keyword '%s' failed:\n%s" % (name, message), level='warn')
    return status, message
