# pylint:disable=E741

from itertools import chain

from testsuite.Krakow.RRM.RAN_PZ.resources.log.frame_to_str_pattern_dict_tree import frame_to_str_pattern_dict_tree
from testsuite.Krakow.RRM.RAN_PZ.resources.common.regex import get_regex_match

import unittest


def split_tshark_output_into_frames(ts_output_file):
    """
    takes tshark output from generator list line by line
    and assembles frames from it, yielding one frame at a time
    ts_output_file is expected to be generator outputting lines
    or list containing lines form tshark output
    """
    last_line_tag = '<last-line>'
    first_line_tag = '<first-line>'
    first_line_regex = 'Frame*bytes on wire*bytes captured*'
    ts_output = chain(ts_output_file, [last_line_tag])
    regex_match = get_regex_match()

    first_line_of_frame = first_line_tag
    rest_lines_of_frame = []

    for line in ts_output:
        if regex_match(line, first_line_regex) or line == last_line_tag:
            frame = [first_line_of_frame] + rest_lines_of_frame
            if first_line_of_frame is not first_line_tag:
                yield frame_to_str_pattern_dict_tree(frame)
            first_line_of_frame = line
            rest_lines_of_frame = []
            continue
        rest_lines_of_frame.append(line)


class Test_split_tshark_output_into_frames(unittest.TestCase):

    def test_finction(self):
        input = (l_ for l_ in [
            'Frame 1382056: 70 bytes on wire (560 bits), 70 bytes captured (560 bits)\n',
            '    Encapsulation type: Ethernet (1)\n',
            '    Arrival Time: Jun  4, 2020 11:58:22.008503000 CEST\n',
            'SW Event\n',
            '    SW Event Header: 0002021900000000\n',
            '        Reserved: 0x00\n',
            '        Timestamp and Event format indicator: 0x02\n',
            'ICOM 5G Protocol\n',
            '    PrachReceiveInd (Structure)\n',
            '        sfn (Uint16): 0x02dd(733)\n',
            '        slot (Uint8): 0x01(1)\n',
            '        slot_subcells_padding (Bytes): 00\n',
            #
            'Frame 22961: 60 bytes on wire (480 bits), 60 bytes captured (480 bits)\n',
            '    Encapsulation type: Ethernet (1)\n',
            '    Arrival Time: Jun  4, 2020 11:53:14.825230000 CEST\n',
            'SW Event\n',
            '    SW Event Header: 0002012200000000\n',
            '        Reserved: 0x00\n',
            '        Timestamp and Event format indicator: 0x02\n',
            'ICOM 5G Protocol\n',
            '    SlotTypeReq (Structure)\n',
            '        subcellId (Uint8): 0x02(2)\n',
            '        subcellId_sfn_padding (Bytes): 01\n',
            '        sfn (Uint16): 0x02df(735)\n',
            '        slot (Uint8): 0x03(3)\n',
            '        slotType (Enum): 32 (l1_common_slotType_t.SLOT_TYPE_C5)\n',
        ])
        output = split_tshark_output_into_frames(input)
        output = list(output)
        assert len(output) == 2
        # check of first then last line of 1st frame
        assert output[0]('Frame 1382056*')
        assert output[0]('ICOM*')('PrachReceiveInd*')('slot_subcells_padding*') == '00'
        # check of first then last line of 2nd frame
        assert output[1]('Frame 22961*')
        assert output[1]('ICOM*')('SlotTypeReq*')('slotType*') == '32 (l1_common_slotType_t.SLOT_TYPE_C5)'
