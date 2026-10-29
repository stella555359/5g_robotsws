
import re
import fnmatch


def get_regex_match(engine='fnmatch'):
    """
    returns one of predefined options or
    what is passed as engine if option is not found
    allows for having defaults and also passing custom
    callable if needed, by default returns fnmatch
    returned callable signature is (string, pattern)
    """
    return {
        'fnmatch': fnmatch.fnmatch,
        're': lambda string, pattern: bool(re.search(pattern, string))
    }.get(engine, engine)


class TestGetRegexmatch:
    def test_get_regex_match_return_passed_engine(self):

        def func():
            pass

        class Obje:
            pass

        f = func
        s = 'NONEXISTENT'
        o = Obje()
        assert get_regex_match(f) == f
        assert get_regex_match(s) == s
        assert get_regex_match(o) == o
        #  what a good car it is was ^
