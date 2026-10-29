from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.str_pattern_dict import \
    PathList, StrPatternDict
import unittest


class TestPathList(unittest.TestCase):
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


class TestStrPatternDict(unittest.TestCase):
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
        d = StrPatternDict([
            ('ICOM 5G Protocol', StrPatternDict([
                ('UserSetupReq (Structure)', 'PAYLOAD')
            ]))
        ])
        assert d('ICOM*')('User*') == 'PAYLOAD'

    def test_call_throws_key_error(self):
        self.assertRaises(KeyError, StrPatternDict(), 'nonexisting')

    def test_pattern_get(self):
        d = StrPatternDict([('ICOM 5G Protocol', 'UserSetupReq (Structure)')])
        assert d.pattern_get('ICOM*') == 'UserSetupReq (Structure)'
        assert d.pattern_get('nonexistent') is None
        assert d.pattern_get('nonexistent', on_404='too bad') == 'too bad'

    def test_follow(self):
        d = StrPatternDict([
            ('ICOM 5G Protocol', StrPatternDict([
                ('UserSetupReq (Structure)', 'PAYLOAD')
            ]))
        ])
        assert d.follow(['ICOM*', 'User*']) == 'PAYLOAD'

    def test_find_nothing(self):
        found = StrPatternDict.find_paths(self.full_tree, 'NONEXISTENT')
        assert found == []

    def test_find_leaves(self):
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
        leaves = StrPatternDict.find_paths(self.full_tree, '*Channel*')
        assert leaves == expected

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

    def test_find_leaves_and_branches(self):
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
        leaves_and_branches = StrPatternDict.find_paths(self.full_tree, '*srb*')
        assert leaves_and_branches == expected
