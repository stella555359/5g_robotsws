
import re
import fnmatch
import collections

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.common.regex import get_regex_match


class PathList(list):

    def __init__(self, *args, **kargs):
        list.__init__(self, *args, **kargs)

    def first(self):
        return self[0]

    def last(self):
        return self[-1]

    @staticmethod
    def filter_paths(paths, part_pattern_path, engine='fnmatch'):
        """
        filters paths that follow part_pattern_path path guidelines
        for part_pattern_path like ['ICOM*','maxHARQUI*'] will match
        only paths that are like [ ... , 'ICOM*', ... , 'maxHARQUI*']
        pattern matching engine can be changed, defaults to fnmatch
        expects paths to be list of dictionaries like
        [ {path: ['path','to','pattern'], val: some_value },
          {path: ['another', 'path','to','pattern'], val: some_value }, ... ]
        returns new PathList of dictionaries like paths input variable,
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


class StrPatternDict(collections.OrderedDict):
    """
    dictionary extended with __call__ method
    allowing for accessing dictionary keys by regex
    ALL KEYS MUST BE OF TYPE STRING
    function can be substituted at any call

    example:
    tree = str_pattern_dict( ... )
    val = tree('ICOM*')('User*', engine='fnmatch')('drb', engine='re')
    """

    def __init__(self, *args, **kargs):
        super(StrPatternDict, self).__init__(self, *args, **kargs)

    def __call__(self, key_pattern, engine='fnmatch'):
        """
        returns FIRST hit matching the key_pattern
        key_pattern: pattern of key we want to find
        engine: regex match function, or 'fnmatch' or 're'
                must retain call signature of (string, pattern)
                and return True on hit
        """
        regex_match = get_regex_match(engine)

        for key in self.keys():
            if regex_match(key, key_pattern):
                return self.__getitem__(key)
        raise KeyError()

    def follow(self, pattern_path, engine='fnmatch'):
        """
        follows pattern path step by step, returns value of last element
        method added so user can just copy/paste any pattern_path from
        find method, using find method of StrPatternDict then filter
        of PathList is suggested solution rather than using follow
        """
        tree = self
        for key in pattern_path:
            tree = tree(key, engine=engine)
        return tree

    @staticmethod
    def find_paths(tree, pattern, engine='fnmatch', list_class=PathList):
        """
        finds all paths with pattern matching dictionary key
        pattern matching engine can be changed, defaults to fnmatch
        works on tree of dictionaries,
        returns list of dictionaries, like
        [ {path: ['path','to','pattern'], val: some_value },
          {path: ['another', 'path','to','pattern'], val: some_value }, ... ]
        """
        regex_match = get_regex_match(engine)
        found_paths = list_class()

        def _find_paths(tree, path=None):
            if path is None:
                path = []

            def _go_deeper():
                return isinstance(val, dict)

            for key in tree.keys():
                val = tree[key]

                if regex_match(key, pattern):
                    found_paths.append({'path': path + [key], 'val': val})

                if _go_deeper():
                    _find_paths(tree=val, path=path + [key])

        _find_paths(tree)
        return found_paths

    def find(self, pattern, engine='fnmatch'):
        """ alias for find_paths to work on self """
        return StrPatternDict.find_paths(self, pattern, engine=engine)


class TestPathList:
    # from TestStrPatternDict StrPatternDict.find_paths(self.full_tree, '*int*')
    all_paths = [
        {'path': ['ICOM 5G Protocol', 'UserSetupReq (Structure)', 'maxHARQUI (Uint8)'],
         'val': '0x02'},
        {'path': ['ICOM 5G Protocol',
                  'UserSetupReq (Structure)',
                  'cellConfiguration(DynamicVariableSizedArray)',
                  'cellConfiguration-Offset (Uint32)'],
         'val': '0x00000084'},
        {'path': ['ICOM 5G Protocol',
                  'UserSetupReq (Structure)',
                  'drbAddReqPs (DynamicVariableSizedArray)',
                  'drbAddReqPs-Payload',
                  'drbAddReqPs_item_0 (Structure)',
                  'logicalChannelGroup (Uint8)'],
         'val': '0x01'},
        {'path': ['ICOM 5G Protocol',
                  'UserSetupReq (Structure)',
                  'drbAddReqPs (DynamicVariableSizedArray)',
                  'drbAddReqPs-Payload',
                  'drbAddReqPs_item_0 (Structure)',
                  'priority (Uint8)'],
         'val': '0x01'},
        {'path': ['ICOM 5G Protocol',
                  'UserSetupReq (Structure)',
                  'drbAddReqPs (DynamicVariableSizedArray)',
                  'drbAddReqPs-Payload',
                  'drbAddReqPs_item_0 (Structure)',
                  'logicalChannelIdentity (Uint8)'],
         'val': '0x04'}
    ]

    def test_filter_no_paths(self):
        paths = PathList.filter_paths(self.all_paths, 'NONEXISTENT')
        assert paths == []

    def test_filter_one_paths(self):
        expected = [self.all_paths[4]]
        paths = PathList.filter_paths(self.all_paths, ['UserSetupReq*', '*Identity*'])
        assert paths == expected

    def test_filter_many_paths(self):
        expected = self.all_paths[2:]
        paths = PathList.filter_paths(self.all_paths, ['*item_0*'])
        assert paths == expected


class TestStrPatternDict:
    # dict() == OrderedDict() -> True
    full_tree = {
        'Frame 1215': {
            'Encapsulation': None},
        'Ethernet II': {
            'Source': {
                'Address': '02:40:43:80:10:02'}},
        'Internet Protocol Version': {
            'Flags: 0x4000': {
                '0... .... .... .... = Reserved bit': 'Not set'},
            'Destination': None},
        'Stream Control Transmission': {
            '[Checksum Status': 'Unverified]',
            'DATA chunk': None},
        'SYSCOM Protocol': {
            '0000 .... = version': None},
        'ICOM 5G Protocol': {
            'UserSetupReq (Structure)': {
                'maxHARQUI (Uint8)': '0x02',
                'maxHARQUI_srbAddReqPs_padding (Bytes)': '00',
                'srbAddReqPs (DynamicVariableSizedArray)': {
                    'srbAddReqPs-Payload': None},
                'drbAddReqPs (DynamicVariableSizedArray)': {
                    'drbAddReqPs-Payload': {
                        'drbAddReqPs_item_0 (Structure)': {
                            'logicalChannelIdentity (Uint8)': '0x04',
                            'logicalChannelGroup (Uint8)': '0x01',
                            'priority (Uint8)': '0x01'}}},
                'cellConfiguration(DynamicVariableSizedArray)': {
                    'cellConfiguration-Offset (Uint32)': '0x00000084'}}}
    }

    def test_call(self):
        expected = 'PAYLOAD'
        d1 = StrPatternDict()
        d1['UserSetupReq (Structure)'] = expected
        d = StrPatternDict()
        d['ICOM 5G Protocol'] = d1
        assert d('ICOM*')('User*') == expected

    def test_call_throws_key_error(self):
        d = StrPatternDict()
        error = None
        try:
            d('nonexisting')
        except KeyError as e:
            error = e
        assert isinstance(error, KeyError)

    def test_follow(self):
        expected = 'PAYLOAD'
        d1 = StrPatternDict()
        d1['UserSetupReq (Structure)'] = expected
        d = StrPatternDict()
        d['ICOM 5G Protocol'] = d1
        assert d.follow(['ICOM*', 'User*']) == expected

    def test_find_nothing(self):
        found = StrPatternDict.find_paths(self.full_tree, 'NONEXISTENT')
        assert found == []

    def test_find_leafs(self):
        expected = [
            {'path': ['ICOM 5G Protocol',
                      'UserSetupReq (Structure)',
                      'drbAddReqPs (DynamicVariableSizedArray)',
                      'drbAddReqPs-Payload',
                      'drbAddReqPs_item_0 (Structure)',
                      'logicalChannelGroup (Uint8)'],
             'val': '0x01'},
            {'path': ['ICOM 5G Protocol',
                      'UserSetupReq (Structure)',
                      'drbAddReqPs (DynamicVariableSizedArray)',
                      'drbAddReqPs-Payload',
                      'drbAddReqPs_item_0 (Structure)',
                      'logicalChannelIdentity (Uint8)'],
             'val': '0x04'}
        ]
        leafs = StrPatternDict.find_paths(self.full_tree, '*Channel*')
        assert leafs == expected

    def test_find_branch(self):
        expected = [
            {'path': ['ICOM 5G Protocol', 'UserSetupReq (Structure)'],
             'val': self.full_tree['ICOM 5G Protocol']['UserSetupReq (Structure)']},
            {'path': ['ICOM 5G Protocol',
                      'UserSetupReq (Structure)',
                      'drbAddReqPs (DynamicVariableSizedArray)',
                      'drbAddReqPs-Payload',
                      'drbAddReqPs_item_0 (Structure)'],
             'val': {'logicalChannelGroup (Uint8)': '0x01',
                     'logicalChannelIdentity (Uint8)': '0x04',
                     'priority (Uint8)': '0x01'}}
        ]
        branches = StrPatternDict.find_paths(self.full_tree, '*Structure*')
        assert branches == expected

    def test_find_leafs_and_branches(self):
        expected = [
            {'path': ['ICOM 5G Protocol',
                      'UserSetupReq (Structure)',
                      'maxHARQUI_srbAddReqPs_padding (Bytes)'],
             'val': '00'},
            {'path': ['ICOM 5G Protocol',
                      'UserSetupReq (Structure)',
                      'srbAddReqPs (DynamicVariableSizedArray)'],
             'val': {'srbAddReqPs-Payload': None}},
            {'path': ['ICOM 5G Protocol',
                      'UserSetupReq (Structure)',
                      'srbAddReqPs (DynamicVariableSizedArray)',
                      'srbAddReqPs-Payload'],
             'val': None}
        ]
        leafs_and_branches = StrPatternDict.find_paths(self.full_tree, '*srb*')
        assert leafs_and_branches == expected
