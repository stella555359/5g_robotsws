from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.frame_to_str_pattern_dict_tree import \
    frame_to_str_pattern_dict_tree, StrPatternDict

import unittest


class TestFrameToStrPatternDictTree(unittest.TestCase):
    full_message = [
        'Frame 1215',  # 0
        '    Encapsulation',  # 1
        'Ethernet II',  # 2
        '    Source',  # 3
        '        Address: 02:40:43:80:10:02',  # 4
        'Internet Protocol Version',  # 5
        '    Flags: 0x4000',  # 6
        '         0... .... .... .... = Reserved bit: Not set',  # 7
        '    Destination',  # 8
        'Stream Control Transmission',  # 9
        '    [Checksum Status: Unverified]',  # 10
        '    DATA chunk',  # 11
        'SYSCOM Protocol',  # 12
        '    0000 .... = version',
        'ICOM 5G Protocol',
        '    UserSetupReq (Structure)',
        '        maxHARQUI (Uint8): 0x02',
        '        maxHARQUI_srbAddReqPs_padding (Bytes): 00',
        '        srbAddReqPs (DynamicVariableSizedArray)',
        '            srbAddReqPs-Payload',
        '        drbAddReqPs (DynamicVariableSizedArray)',
        '            drbAddReqPs-Payload',
        '                drbAddReqPs_item_0 (Structure)',
        '                    logicalChannelIdentity (Uint8): 0x04',
        '                    logicalChannelGroup (Uint8): 0x01',
        '                    priority (Uint8): 0x01',
        '        cellConfiguration(DynamicVariableSizedArray)',
        '            cellConfiguration-Offset (Uint32): 0x00000084',
    ]
    full_tree = StrPatternDict([
        ('Frame 1215', StrPatternDict([
            ('Encapsulation', None)])),
        ('Ethernet II', StrPatternDict([
            ('Source', StrPatternDict([
                ('Address', '02:40:43:80:10:02')]))])),
        ('Internet Protocol Version', StrPatternDict([
            ('Flags: 0x4000', StrPatternDict([
                ('0... .... .... .... = Reserved bit', 'Not set')])),
            ('Destination', None)])),
        ('Stream Control Transmission', StrPatternDict([
            ('[Checksum Status', 'Unverified]'),
            ('DATA chunk', None)])),
        ('SYSCOM Protocol', StrPatternDict([
            ('0000 .... = version', None)])),
        ('ICOM 5G Protocol',  StrPatternDict([
            ('UserSetupReq (Structure)', StrPatternDict([
                ('maxHARQUI (Uint8)', '0x02'),
                ('maxHARQUI_srbAddReqPs_padding (Bytes)', '00'),
                ('srbAddReqPs (DynamicVariableSizedArray)', StrPatternDict([
                    ('srbAddReqPs-Payload', None)])),
                ('drbAddReqPs (DynamicVariableSizedArray)', StrPatternDict([
                    ('drbAddReqPs-Payload', StrPatternDict([
                        ('drbAddReqPs_item_0 (Structure)', StrPatternDict([
                            ('logicalChannelIdentity (Uint8)', '0x04'),
                            ('logicalChannelGroup (Uint8)', '0x01'),
                            ('priority (Uint8)', '0x01')]))]))])),
                ('cellConfiguration(DynamicVariableSizedArray)', StrPatternDict([
                    ('cellConfiguration-Offset (Uint32)', '0x00000084')]))]))]))
    ])

    def _get_path_dict(self, key):
        return StrPatternDict([(key, self.full_tree[key])])

    def test_empty_message(self):
        assert {} == frame_to_str_pattern_dict_tree([])

    def test_one_element_message(self):
        assert {'Frame 1215': None} == frame_to_str_pattern_dict_tree(['Frame 1215'])

    def test_two_levels_down(self):
        m = self.full_message[:2]
        d = self._get_path_dict('Frame 1215')
        assert d == frame_to_str_pattern_dict_tree(m)

    def test_three_levels_down(self):
        m = self.full_message[2:5]
        d = self._get_path_dict('Ethernet II')
        assert d == frame_to_str_pattern_dict_tree(m)

    def test_three_levels_down_one_back(self):
        m = self.full_message[5:9]
        d = self._get_path_dict('Internet Protocol Version')
        assert d == frame_to_str_pattern_dict_tree(m)

    def test_three_levels_down_two_back_at_once(self):
        m = self.full_message[2:6]
        d = self._get_path_dict('Ethernet II')
        d['Internet Protocol Version'] = None
        assert d == frame_to_str_pattern_dict_tree(m)

    def test_three_levels_down_two_back_one_at_time(self):
        m = self.full_message[5:10]
        d = self._get_path_dict('Internet Protocol Version')
        d['Stream Control Transmission'] = None
        assert d == frame_to_str_pattern_dict_tree(m)

    def test_three_levels_down_two_elemets_same_level(self):
        m = self.full_message[9:12]
        d = self._get_path_dict('Stream Control Transmission')
        assert d == frame_to_str_pattern_dict_tree(m)

    def test_keys_are_full_line_until_last_element(self):
        m = self.full_message[5:9]
        tree = frame_to_str_pattern_dict_tree(m)
        val = tree['Internet Protocol Version']['Flags: 0x4000']
        # key 'Flags: 0x4000' is not 'Flags'
        assert val == {'0... .... .... .... = Reserved bit': 'Not set'}

    def test_full_load(self):
        m = self.full_message
        d = self.full_tree
        assert d == frame_to_str_pattern_dict_tree(m)
