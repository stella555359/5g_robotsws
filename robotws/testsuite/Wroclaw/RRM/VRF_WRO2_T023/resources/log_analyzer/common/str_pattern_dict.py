from collections import OrderedDict
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.regex import get_regex_match


class PathList(list):
    """Companion class for strPatternDict 'find' and 'find_paths methods'."""

    def __init__(self, *args, **kargs):
        list.__init__(self, *args, **kargs)

    def first(self):
        return self[0]

    def last(self):
        return self[-1]

    @staticmethod
    def filter_paths(paths, part_pattern_path, engine='fnmatch'):
        """
        Filter paths according to part_pattern_path.
        part_pattern_path: ['ICOM*','maxHARQUI*'] will match paths: [ ... , 'ICOM*', ... , 'maxHARQUI*']

        :param paths: All paths, e.g. [{path: ['some','path'], val: some_value }, ...] (List<dict>).
        :param part_pattern_path: pattern to match paths, e.g. ['ICOM*','maxHARQUI*'] (List<str>).
        :param engine: Search engine (callable, str).
        :returns Filtered PathList. Has the same form as "paths" (List<dict>).
        """
        regex_match = get_regex_match(engine)
        if isinstance(part_pattern_path, str):
            part_pattern_path = [part_pattern_path]

        def _check_match(path):
            pattern_gen = iter(part_pattern_path)
            pattern = next(pattern_gen)

            for key in path['path']:
                if regex_match(key, pattern):
                    pattern = next(pattern_gen, None)
                if pattern is None:
                    return True
            return False

        filtered = PathList()
        filtered.extend([path for path in paths if _check_match(path)])
        return filtered

    def filter(self, part_pattern_path, engine='fnmatch'):
        return PathList.filter_paths(self, part_pattern_path, engine=engine)


class StrPatternDict(OrderedDict):
    """
    Dictionary extended with __call__ method allowing for accessing dictionary values by key regex.
    All keys and key regexes must be strings.

    usage:
        tree = str_pattern_dict( ... )
        val = tree('foo*')('baz*', engine='fnmatch')('bar', engine='re')
    """

    def __call__(self, key_pattern, engine='fnmatch'):
        """
        Return the value of the FIRST key matching the key_pattern. The value CAN be a StrPatternDict itself.
        :param key_pattern: Pattern of the key we want to match.
        :param engine: Regex search engine (callable, str).
        """
        regex_match = get_regex_match(engine)

        for key in self.keys():
            if regex_match(key, key_pattern):
                return self.__getitem__(key)
        raise KeyError()

    def pattern_get(self, key_patten, on_404=None):
        try:
            return self(key_patten)
        except KeyError:
            return on_404

    pget = pattern_get

    def follow(self, pattern_path, engine='fnmatch'):
        """
        Follow the whole dictionary according to pattern_path.
        :param pattern_path: Pattern to match dict keys by (str).
        :param engine: Regex search engine (callable, str).
        :returns The final value matching the pattern_path. This could be a leaf or a node (StrPatternDict, str).
        """
        tree = self
        for key in pattern_path:
            tree = tree(key, engine=engine)
        return tree

    @staticmethod
    def find_paths(tree, pattern, engine='fnmatch', list_class=PathList):
        """
        Find all paths with pattern matching dictionary key
        works on tree of dictionaries,
        returns list of dictionaries, like
        [ {path: ['path','to','pattern'], val: some_value },
          {path: ['another', 'path','to','pattern'], val: some_value }, ... ]

        :param tree: Pattern to match dict keys by (str).
        :param pattern: Pattern to match dict keys by (str).
        :param engine: Regex search engine (callable, str).
        :param list_class: Regex search engine (callable, str).
        :returns The final value matching the pattern_path. This could be a leaf or a node (StrPatternDict, str).
        """
        regex_match = get_regex_match(engine)
        found_paths = list_class()

        def _find_paths(tree, path=None):
            if path is None:
                path = []

            def _go_deeper():
                return isinstance(value, dict)

            for key, value in tree.items():
                if regex_match(key, pattern):
                    found_paths.append({'path': path + [key], 'val': value})

                if _go_deeper():
                    _find_paths(tree=value, path=path + [key])

        _find_paths(tree)
        return found_paths

    def find(self, pattern, engine='fnmatch'):
        """Alias for find_paths to work on self"""
        return StrPatternDict.find_paths(self, pattern, engine=engine)


def sort_and_convert_dict_to_str_pattern_dict(dictionary):
    """Convert dict to StrPatternDict with sorted keys"""
    keys = dictionary.keys()
    keys.sort()
    gen = ((key, dictionary[key]) for key in keys)
    return StrPatternDict(gen)
