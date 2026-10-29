from testsuite.Krakow.RRM.RAN_PZ.resources.common.maybe import Maybe
from testsuite.Krakow.RRM.RAN_PZ.resources.common.str_pattern_dict import StrPatternDict


def message_to_tree(
        message,
        delimiter=b': ',
        cutout_len=4,
        dictionary=StrPatternDict
):
    """
    converts message provided as list of strings
    to multi level dictionary structure,
    by default StrPatternDict class is used

    example:
    message_string_list = [ ' ... ', ' ... ', ... ]
    message_tree = message_to_tree(message_string_list)
    """

    def _level(snake, score_penalty=cutout_len):
        """
        returns level of string snake ;-)
        """
        return (len(snake) - len(snake.strip())) / score_penalty

    def _next_level_line_generator(message):
        """
        takes message as list of strings
            ['ICOM 5G Protocol ',
             '    UserSetupReq (Structure)',
             '        srbAddReqPs (DynamicVariableSizedArray)',
             '            srbAddReqPs-Payload',
             '        drbAddReqPs (DynamicVariableSizedArray)',
             '            drbAddReqPs-Payload']
        and returns tuple (level_of_next_line, line) generator like
            (1,    'ICOM 5G Protocol')
            (2,    'UserSetupReq (Structure)')
            (3,    'srbAddReqPs (DynamicVariableSizedArray)')
            (2,    'srbAddReqPs-Payload')
            (3,    'drbAddReqPs (DynamicVariableSizedArray)')
            (None, 'drbAddReqPs-Payload')
        """
        levels_from_second_element_onward = [_level(line) for line in message[1:]]
        next_level_line = levels_from_second_element_onward + [None]
        stripped_message = [line.strip() for line in message]
        return (item for item in zip(next_level_line, stripped_message))

    def _make_dict(
            message_generator,
            current_level=0,
            delimiter=delimiter
    ):
        """
        make current level of dictionary, recursive function
        """
        tree = dictionary()
        next_level = 0
        for next_level, line in message_generator:

            def _enter_cutout():
                return True if (0 if next_level is None else next_level) > \
                               (0 if current_level is None else current_level) else False

            def _exit_cutout():
                return True if (0 if next_level is None else next_level) < \
                               (0 if current_level is None else current_level) else False

            if not _enter_cutout():
                split = Maybe(line.split(delimiter), None)
                key, val = split[0], split[1]
                tree[key] = val

            if _enter_cutout():
                lower_tree, next_level = _make_dict(
                    message_generator,
                    current_level=next_level
                )
                tree[line] = lower_tree

            if _exit_cutout():
                return tree, next_level
        return tree, next_level

    tree, _ = _make_dict(_next_level_line_generator(message))
    return tree


class TestMessageToTree:
    full_message = [
        'Frame 1215',
        '    Encapsulation',
        'Ethernet II',
        '    Source',
        '        Address: 02:40:43:80:10:02',
        'Internet Protocol Version',
        '    Flags: 0x4000',
        '         0... .... .... .... = Reserved bit: Not set',
        '    Destination',
        'Stream Control Transmission',
        '    [Checksum Status: Unverified]',
        '    DATA chunk',
        'SYSCOM Protocol',
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

    def _get_path_dict(self, key):
        return {key: self.full_tree[key]}

    def test_empty_message(self):
        assert {} == message_to_tree([])

    def test_one_element_message(self):
        assert {'Frame 1215': None} == message_to_tree(['Frame 1215'])

    def test_two_levels_down(self):
        m = self.full_message[:2]
        d = self._get_path_dict('Frame 1215')
        assert d == message_to_tree(m)

    def test_three_levels_down(self):
        m = self.full_message[2:5]
        d = self._get_path_dict('Ethernet II')
        assert d == message_to_tree(m)

    def test_three_levels_down_one_back(self):
        m = self.full_message[5:9]
        d = self._get_path_dict('Internet Protocol Version')
        assert d == message_to_tree(m)

    def test_three_levels_down_two_back_at_once(self):
        m = self.full_message[2:6]
        d = self._get_path_dict('Ethernet II')
        d['Internet Protocol Version'] = None
        assert d == message_to_tree(m)

    def test_three_levels_down_two_back_one_at_time(self):
        m = self.full_message[5:10]
        d = self._get_path_dict('Internet Protocol Version')
        d['Stream Control Transmission'] = None
        assert d == message_to_tree(m)

    def test_three_levels_down_two_elemets_same_level(self):
        m = self.full_message[9:12]
        d = self._get_path_dict('Stream Control Transmission')
        assert d == message_to_tree(m)

    def test_keys_are_full_line_until_last_element(self):
        m = self.full_message[5:9]
        tree = message_to_tree(m)
        val = tree['Internet Protocol Version']['Flags: 0x4000']
        # key 'Flags: 0x4000' is not 'Flags'
        assert val == {'0... .... .... .... = Reserved bit': 'Not set'}

    def test_full_load(self):
        m = self.full_message
        d = self.full_tree
        assert d == message_to_tree(m)
