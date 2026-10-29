
from functools import partial
from abc import ABCMeta, abstractproperty

import unittest
from mock import MagicMock, mock_open, patch

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.common.regex import get_regex_match
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.common.str_pattern_dict import StrPatternDict


# cant use lambda due to flake E731 so :-(
def _negate_func(f):
    def _f(*args, **kargs):
        return not f(*args, **kargs)
    return _f


class MessageMatcher(object):

    __metaclass__ = ABCMeta

    # tag property !!!!!!!!!!!!!!! ??????????????

    @abstractproperty
    def __call__(self, frame):
        """
        expected to return True for frame matching conditions and False otherwise
        """
        pass


class SyslogMessageMatcher(MessageMatcher):

    def __init__(self, pattern, tag=None, regex_engine='fnmatch'):
        self.regex_match = get_regex_match(regex_engine)
        self.tag = {None: pattern}.get(tag, tag)
        self.pattern = pattern

    def __call__(self, syslog_line):
        return self.regex_match(syslog_line, self.pattern)


class PcapMessageMatcher(MessageMatcher):

    # !!! fnmatch compatible patterns !!!
    name_line_patterns = {
        'empty': '{}',
        'structure': '*{}*(Structure)*',   # is last * needed ?
    }

    def __init__(
        self, message_name_pattern, tag=None, hint=None, regex_engine=None,
        default_regex_engine='fnmatch', name_line_pattern='structure',
    ):
        """
        message_name_pattern is meant to be whole name of the message like SlotTypeReq
        name_line_pattern is sometimes different from message to message and their pattern
        is put into name_line_patterns dict can't do anything about it
        tag is used to identify message [check PcapMessageFinder to find out how]
        if not provided message_name_pattern is used as tag value so if you passed
        something like 'PucchReceive*' [strongly discouraged] many messages can be matched
        and since it is not trivial to identify message name from frame
        and different messages tend to have different name_line_patterns
        tag is used to help identify them [check PcapMessageFinder to find out how]
        for rest params check _contains method
        """
        # self.message_name_pattern = message_name_pattern
        self.default_regex_engine = default_regex_engine
        self.tag = tag
        if not tag:
            self.tag = message_name_pattern

        self.chain = []

        # if any key does not match, use passed value
        name_line_regex = self.name_line_patterns.get(
            name_line_pattern, name_line_pattern
        ).format(message_name_pattern)

        # appending message name pattern check
        self.containing(name_line_regex, hint, regex_engine)

    # ponder what to do if value is a tree of dicts of any kind
    def _contains(
        self, frame, key_pattern, value_pattern=None,
        hint=None, regex_engine=None,
    ):
        """
        checks if frame has key_pattern and additionally checks if value_pattern match
        if it is provided, hint is expected to be PathList.filter_paths part_pattern_path
        returns bool

        SO FAR value_pattern CAN ONLY BE A !!! SIMPLE VALUE !!!
        NOT A DICT OR TREE OF DICTS, SO USE WISELY !!!!!!!!!!!!
        """
        if not regex_engine:
            regex_engine = self.default_regex_engine
        regex_match = get_regex_match(regex_engine)
        if frame is None:
            return False
        found_paths = frame.find(key_pattern, regex_engine)
        if hint:
            found_paths = found_paths.filter(
                part_pattern_path=hint,
                engine=regex_engine
            )
        if not found_paths:
            return False

        if value_pattern:
            for dictionary in found_paths:
                if regex_match(dictionary['val'], value_pattern):
                    return True
            return False

        return True

    def _append_contains_function(
        self, key_pattern, value_pattern=None,
        hint=None, regex_engine=None, negate=False,
    ):
        f = pf = partial(
            self._contains,
            key_pattern=key_pattern, value_pattern=value_pattern,
            hint=hint, regex_engine=regex_engine,
        )

        if negate:
            # f = lambda frame: not pf(frame)  # noqa: E731
            f = _negate_func(pf)

        self.chain.append(f)

    def containing(
        self, key_pattern, value_pattern=None,
        hint=None, regex_engine=None,
    ):
        self._append_contains_function(
            key_pattern=key_pattern, value_pattern=value_pattern,
            hint=hint, regex_engine=regex_engine,
        )
        return self

    c = containing

    def not_containing(
        self, key_pattern, value_pattern=None,
        hint=None, regex_engine=None,
    ):
        self._append_contains_function(
            key_pattern=key_pattern, value_pattern=value_pattern,
            hint=hint, regex_engine=regex_engine,
            negate=True
        )
        return self

    nc = not_containing

    def check(self, frame):
        for f in self.chain:
            if f(frame) is False:
                return False
        return True

    def __call__(self, frame):
        return self.check(frame)


class TTIMessageMatcher(MessageMatcher):
    """
    simpler version of PcapMessageMatcher
    tti messages are StrPatternDict like
    {'message': 'message_name', ....} so
    by passing message_name_key you can
    change behaviour i.e:
    TTIMessageMatcher('1', first_check_key='sfn')
    will find all messages with 'sfm' = '1'
    by default it is set up so it checks message name
    """

    def __init__(
            self, first_check_pattern, tag=None, regex_engine=None,
            default_regex_engine='fnmatch', first_check_key='message'
    ):
        self.default_regex_engine = default_regex_engine
        self.tag = tag
        if not tag:
            self.tag = first_check_pattern

        self.chain = []

        # appending message name pattern check
        self.containing(first_check_key, first_check_pattern, regex_engine)

    def _contains(self, message, key_pattern, val_pattern=None, regex_engine=None):
        if not regex_engine:
            regex_engine = self.default_regex_engine
        regex_match = get_regex_match(regex_engine)

        try:
            val = message(key_pattern)
            if val_pattern:
                return regex_match(val, val_pattern)
            return True
        except KeyError:
            return False

    def _append_contains_function(
            self, key_pattern, val_pattern=None, regex_engine=None, negate=False
    ):
        f = pf = partial(
            self._contains,
            key_pattern=key_pattern, val_pattern=val_pattern, regex_engine=regex_engine,
        )

        if negate:
            # f = lambda message: not pf(message)  # noqa: E731
            f = _negate_func(pf)

        self.chain.append(f)

    def containing(self, key_pattern, val_pattern=None, regex_engine=None):
        self._append_contains_function(
            key_pattern=key_pattern, val_pattern=val_pattern, regex_engine=regex_engine,
        )
        return self

    c = containing

    def not_containing(self, key_pattern, val_pattern=None, regex_engine=None):
        self._append_contains_function(
            key_pattern=key_pattern, val_pattern=val_pattern, regex_engine=regex_engine,
            negate=True
        )
        return self

    nc = not_containing

    def check(self, frame):
        for f in self.chain:
            if f(frame) is False:
                return False
        return True

    def __call__(self, frame):
        return self.check(frame)


class TestSyslogMessageMatcher(unittest.TestCase):

    def test_class(self):
        smm = SyslogMessageMatcher('*foo*')
        assert smm('maight fool me once')
        assert not smm('wont let you do it twice thought')
        assert smm.tag == '*foo*'
        smm = SyslogMessageMatcher('bar', 'bar')
        assert smm.tag == 'bar'


class TestPcapMessageMatcher(unittest.TestCase):

    @patch(__name__+'.PcapMessageMatcher.containing')
    def test_init(self, m_containing):
        matcher_empty = PcapMessageMatcher('test_msg_pattern', tag='msg1', name_line_pattern='empty')
        m_containing.assert_called_once_with('test_msg_pattern', None, None)
        assert matcher_empty.tag == 'msg1'

        matcher_default = PcapMessageMatcher('test_msg_pattern', name_line_pattern='structure')
        m_containing.assert_called_with('*test_msg_pattern*(Structure)*', None, None)
        assert matcher_default.tag == 'test_msg_pattern'

        matcher_custom = PcapMessageMatcher('test_msg_pattern', name_line_pattern='{}_custom')
        m_containing.assert_called_with('test_msg_pattern_custom', None, None)

    def test_containing_not_containing(self):
        # d inner
        dinner = StrPatternDict()
        dinner['slots'] = '3',
        dinner['errors'] = 'many'
        # d outer
        douter = StrPatternDict()
        douter['Structure'] = dinner

        badoo = PcapMessageMatcher('Structure', name_line_pattern='empty')
        badoo.containing('slots')
        # containing single element tested
        # _append_contains_function tested
        # _contains tested
        badoo.containing('errors', 'many')          # containing multiple elements tested
        assert len(badoo.chain) == 3
        assert badoo(douter) is True                # __call__ and check tested

        tinder = PcapMessageMatcher('Structure', name_line_pattern='empty')
        tinder.containing('slots')
        tinder.not_containing('errors', 'many')
        assert tinder.check(douter) is False
    # test hint


class TestTTIMessageMatcher(unittest.TestCase):

    @patch(__name__+'.TTIMessageMatcher.containing')
    def test_init(self, m_containing):
        matcher = TTIMessageMatcher('test_msg_pattern')
        m_containing.assert_called_with('message', 'test_msg_pattern', None)
        assert matcher.tag == 'test_msg_pattern'

        matcher_custom_key = TTIMessageMatcher('test_msg_pattern', first_check_key='custom')
        m_containing.assert_called_with('custom', 'test_msg_pattern', None)

    def test_containing_not_containing(self):
        message = StrPatternDict()
        message['message'] = 'SlotTypeReq'
        message['slot'] = '3'
        message['sfn'] = '6'

        matcher = TTIMessageMatcher('SlotTypeReq')
        matcher.containing('sfn')
        # containing single element tested
        # _append_contains_function tested
        # _contains tested
        assert len(matcher.chain) == 2
        assert matcher(message) is True             # __call__ and check tested
        matcher.containing('slot', '3')             # containing multiple elements tested
        assert matcher(message) is True
        assert TTIMessageMatcher('SlotTypeReq').not_containing('sfn', '6')(message) is False
