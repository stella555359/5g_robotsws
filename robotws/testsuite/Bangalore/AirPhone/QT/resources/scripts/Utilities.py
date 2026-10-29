from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


def run_keyword_without_failure(keyword_name, *args):
    """
    This keyword takes the Keyword Name and its args as input and will help in capturing any type of exception.
    It will not allow the test case to be marked failed because of Keyword Timeout or any other exception.
    It is helpful for teardown keywords where we can have log collection keywords which are needed but when it
    fails it should not fail the test case.

    Last Modified By : Gopalakrishnan N (gopalakrishnan.n@nokia.com)
    Last Modified on : Dec 5, 2022
    """
    result = ''
    value = ''
    try:
        result, value = BuiltIn().run_keyword_and_ignore_error(keyword_name, *args)
    except Exception as e:
        print("Exception seen is {}".format(e))
        logger.warn("Keyword : \"{}\" had failed with an excpetion \"{}\"".format(keyword_name, e))
    return result, value
