
from testsuite.Krakow.RRM.RAN_PZ.resources.log.readers import LogReader, IterableReader
from testsuite.Krakow.RRM.RAN_PZ.resources.log.matchers import MessageMatcher, PcapMessageMatcher
from testsuite.Krakow.RRM.RAN_PZ.resources.common.str_pattern_dict import StrPatternDict

import unittest
from mock import MagicMock, mock_open, patch


class MessageFinder(object):

    def __init__(self, log_reader):
        '''
        clas that actually does the serching for messages
        '''
        if not isinstance(log_reader, LogReader):
            em = ': log_reader must be of LogReader type'
            raise ValueError(self.__class__.__name__ + em)

        self.log_reader = log_reader
        self.message_generator = self.log_reader.generator()

    def _find(self, matchers, forget_matcher_on_hit=False):
        matchers = list(matchers)  # make copy to work on
        for frame in self.message_generator:
            for position, matcher in enumerate(matchers):
                if matcher(frame):
                    if forget_matcher_on_hit:
                        matchers[position] = lambda frame: False
                    yield (frame, matcher)

    def _make_dict(self, list_of_msg_matcher_tuples):
        d = {matcher.tag: [] for _, matcher in list_of_msg_matcher_tuples}
        [d[matcher.tag].append(msg) for msg, matcher in list_of_msg_matcher_tuples]
        return d

    def find_next(self, matchers, forget_matcher_on_hit=False):
        """
        finds mesxt frame tha any of matchers returns true
        """
        is_matchers_list = isinstance(matchers, list)
        if not is_matchers_list:
            matchers = [matchers]

        output = next(self._find(matchers, forget_matcher_on_hit), None)

        if not is_matchers_list and output is not None:
            output = output[0]  # result is a (frame, matcher) so it becomes only frame here

        return output

    def find_next_anew(self, matchers, forget_matcher_on_hit=False):
        """
        resets generator and searches for first message matching
        """
        self.reset_generator()
        return self.find_next(matchers, forget_matcher_on_hit)

    def find_all(self, matchers, forget_matcher_on_hit=False, output='dict'):
        """
        returns list of all messages from generator current position to end of file
        if forget_matcher_on_hit=True then each matcher will be forgotten after one hit
        resets generator afterward

        FOR ONE MATCHER PASSED LICKE finder.find_all(matcher)
        LIST FO MSAGES WILL ALWAYS BE RETURNED REGARDLES OF output OPTION
        SO IF output OPTIONS ARE NEEDED FOR SINGLE MATCHER
        PASS IT LIKE finder.find_all([matcher], optput='tag_list')

        # preserves order of messages in pcap file
        for finder.find_next(matcher) returns
            [msg, msg, ...] or []

        # preserves order of messages in pcap file
        for finder.find_all([matcher, matcher, ....], output='tag_list'|output='raw_list') returns
            [(msg, matcher), (msg, matcher), ...] or []

        # preserving order of messages FOR EACH TAG in pcap file
        for finder.find_all([matcher, matcher, ....], output='dict')
            {'tag': [msg, msg, ...], 'tag': [msg, msg, ...], ...} or {}
        IF THERE WAS NO MESSAGE FOUND FOR ANY OF MATCHERS ITS TAG WONT VE PRESENT IN OUTPUT

        SO IF
            find(matchers=[
                Matcher('msg_A', tag='FOO'),
                Matcher('msg_B', tag='BAR')
            ], output_dict=True)
        RETURNS
            {'msg_BAR': [msg_Z], 'msg_BAR': [msg_Y, msg_X]}
        WE LOSE ORDER OF WHENEVER MESSAGES FOR TAG msg_FOO OR msg_BAR WERE RECEIVED FIRST
        BUT PRESERVE ORDER FOR TAG AND KNOW msg_Y WAS RECEIVED BEFORE msg_X
        """
        options = {
            'dict': self._make_dict,
            'tag_list': lambda result: result,  # return untouched
            'raw_list': lambda result: [tup[0] for tup in result],  # take only msgs
        }

        find_multiple_msg = isinstance(matchers, list)
        if not find_multiple_msg:
            matchers = [matchers]  # _find needs matchers as list

        modify = options[output] if find_multiple_msg else options['raw_list']
        result = modify(list(self._find(matchers, forget_matcher_on_hit)))

        self.reset_generator()
        return result

    def find_all_anew(self, matchers, forget_matcher_on_hit=False, output='dict'):
        """
        resets generator and calls find_rest
        """
        self.reset_generator()
        return self.find_all(matchers, forget_matcher_on_hit, output)

    def find_exactly(self, x, matcher):
        """
        finds all messages matching single matcher and asserts their number
        """
        if not isinstance(matcher, MessageMatcher):
            em = 'find_exactly expects exactly one matcher'
            raise ValueError(self.__class__.__name__ + em)

        y = self.find_all_anew(matcher)
        em = self.__class__.__name__ + "expected {} messages but found {}"
        assert len(y) == x, em.format(x, len(y))
        return y

    def find_one(self, matcher):
        """
        checks there is EXACTLY ONE message that matches, raises AssertionError,
        returns 1|0 matching element returned from matchers
        resets generator afterward
        """
        return self.find_exactly(1, matcher)[0]

    def reset_generator(self):
        self.message_generator = self.log_reader.reset_generator()


class TestMessageFinder(unittest.TestCase):

    def test_init(self):
        class NotLogReader:
            pass

        class FakeReader(LogReader):
            list = generator = reset_generator = MagicMock()

        mf = MessageFinder(FakeReader())
        FakeReader.generator.assert_called_once()

        with self.assertRaises(ValueError):
            MessageFinder(NotLogReader())

    def test_find(self):

        d1 = StrPatternDict()
        d1['slot'] = '0x05(5)'
        du = StrPatternDict()
        du['UserSetupReq'] = d1

        d2 = StrPatternDict()
        d2['slot'] = '0x03(3)'
        ds1 = StrPatternDict()
        ds1['SlotTypeReq'] = d2

        d3 = StrPatternDict()
        d3['slot'] = '0x07(7)'
        ds2 = StrPatternDict()
        ds2['SlotTypeReq'] = d3

        find_all_ds2 = StrPatternDict()
        find_all_ds2['SlotTypeReq'] = d3

        find_all_ds1_ds2 = StrPatternDict()
        find_all_ds1_ds2['SlotTypeReq'] = [ds1, ds2]
        i = [ds1, du, ds2]

        mf = MessageFinder(IterableReader(iterable=i))
        mu = PcapMessageMatcher('UserSetupReq', name_line_pattern='empty')
        ms = PcapMessageMatcher('SlotTypeReq', name_line_pattern='empty')
        mx = PcapMessageMatcher('none existent')

        assert mf.find_next(ms) == ds1
        assert mf.find_next(ms) == ds2
        assert mf.find_next(ms) is None
        assert mf.find_next_anew(ms) == ds1
        assert mf.find_next_anew([ms]) == (ds1, ms)

        mf.reset_generator()
        assert mf.find_all(ms) == [ds1, ds2]
        assert mf.find_all(ms, output='tag_list') == [ds1, ds2]
        assert mf.find_all(ms, output='dict') == [ds1, ds2]
        assert mf.find_all([ms], output='tag_list') == [(ds1, ms), (ds2, ms)]
        assert mf.find_all([ms], output='dict') == {'SlotTypeReq': [ds1, ds2]}
        assert mf.find_all([mx], output='dict') == {}
        assert mf.find_all([mx], output='tag_list') == []
        assert mf.find_all([mx], output='raw_list') == []
        assert mf.find_all([mx, ms, mu], output='dict') == {'SlotTypeReq': [ds1, ds2], 'UserSetupReq': [du]}
        assert mf.find_all_anew([mx, ms, mu], output='dict') == {'SlotTypeReq': [ds1, ds2], 'UserSetupReq': [du]}

        assert mf.find_all([ms], forget_matcher_on_hit=True, output='tag_list') == [(ds1, ms)]
        assert mf.find_all(ms, forget_matcher_on_hit=True, output='tag_list') == [ds1]
        assert mf.find_all(ms, forget_matcher_on_hit=True) == [ds1]
        assert mf.find_one(mu) == du
        assert mf.find_exactly(2, ms) == [ds1, ds2]
        with self.assertRaises(AssertionError):
            mf.find_exactly(2, mu)
