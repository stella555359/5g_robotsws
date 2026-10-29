import re
import fnmatch


def get_regex_match(engine='fnmatch'):
    """
    Get regex search engine.
    :param engine: Search engine (callable, str).
    :returns The user-defined search engine callable or one of defaults (callable).
    """
    return {
        'fnmatch': fnmatch.fnmatch,
        're': lambda string, pattern: bool(re.search(pattern, string))
    }.get(engine, engine)
