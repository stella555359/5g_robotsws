from itertools import chain

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.frame_to_str_pattern_dict_tree import \
    frame_to_str_pattern_dict_tree
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.regex import get_regex_match


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
