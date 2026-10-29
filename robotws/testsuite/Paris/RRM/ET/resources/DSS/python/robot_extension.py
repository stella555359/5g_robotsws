import time
from robot.libraries.BuiltIn import BuiltIn

KW_RUNS = 0


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


def custom_kw_runner(name, *args):
    global KW_RUNS
    KW_RUNS += 1
    return BuiltIn().run_keyword_and_return_status(name, *args)


def run_custom_kw(name="", *args):
    global KW_RUNS
    KW_RUNS = 0
    status = False
    retries = 10
    interval = 1
    for _ in range(retries):
        status = custom_kw_runner(name, *args)
        if bool(status):
            break
        time.sleep(interval)
    if not bool(status):
        raise AssertionError(
            f"Keyword '{name}' failed after retrying for {retries*interval} seconds."
        )
    if bool(status) and KW_RUNS > 1:
        BuiltIn().log(f"{KW_RUNS} runs were necessary for '{name}'", level="WARN")
    return status, KW_RUNS


# Kw is executed 30 tries even if one execution is FAILED
def run_specific_custom_kw(name="", *args):
    global KW_RUNS
    KW_RUNS = 0
    status = False
    retries = 30
    interval = 30
    # for testing purpose
    # retries = 10
    # interval = 1
    for _ in range(retries):
        status = custom_kw_runner(name, *args)
        if not bool(status):
            BuiltIn().log(f"{KW_RUNS} run(s) FAILED for '{name}'", level="WARN")
        time.sleep(interval)
    if bool(status) and KW_RUNS > 1:
        BuiltIn().log(f"{KW_RUNS} runs were necessary for '{name}'", level="WARN")
    return status, KW_RUNS
