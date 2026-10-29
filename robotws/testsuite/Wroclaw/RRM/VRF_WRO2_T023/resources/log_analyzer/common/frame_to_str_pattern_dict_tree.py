from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.maybe import Maybe
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.str_pattern_dict import StrPatternDict


def _level(snake, score_penalty=4):
    """
    Return level of string snake ;-)
    score_penalty is cutout length. For more information, look at _next_level_line_generator.
    """
    return (len(snake) - len(snake.strip())) / score_penalty


def _next_level_line_generator(message):
    """
    Take message as list of strings
        ['ICOM 5G Protocol ',
         '    UserSetupReq (Structure)',
         '        srbAddReqPs (DynamicVariableSizedArray)',
         '            srbAddReqPs-Payload',
         '        drbAddReqPs (DynamicVariableSizedArray)',
         '            drbAddReqPs-Payload']
    and return tuple (level_of_next_line, line) generator like
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


def _make_dict(message_generator, current_level=0, delimiter=': '):
    """Make current level of dictionary."""

    tree = StrPatternDict()
    next_level = None
    for next_level, line in message_generator:

        def _enter_cutout():
            if next_level is None:
                return False
            return True if next_level > current_level else False

        def _exit_cutout():
            if next_level is None:
                return True
            return True if next_level < current_level else False

        if not _enter_cutout():
            split = Maybe(line.split(delimiter), None)
            key, val = split[0], split[1]
            tree[key] = val

        if _enter_cutout():
            lower_tree, next_level = _make_dict(
                message_generator=message_generator,
                current_level=next_level,
                delimiter=delimiter
            )
            tree[line] = lower_tree

        if _exit_cutout():
            return tree, next_level
    return tree, next_level


def frame_to_str_pattern_dict_tree(message, delimiter=': '):
    """
    Convert message provided as list of strings to a multi-level StrPatternDict structure.
    usage:
        message_string_list = [ ' ... ', ' ... ', ... ]
        message_tree = frame_to_str_pattern_dict_tree(message_string_list)
    """
    tree, _ = _make_dict(
        message_generator=_next_level_line_generator(message),
        current_level=0,
        delimiter=delimiter
    )
    return tree
