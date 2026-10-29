import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers as matchers
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.str_pattern_dict import StrPatternDict
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher, TTIMessageMatcher

import unittest
from mock import patch


class TestSyslogMessageMatcher(unittest.TestCase):

    def test_init(self):
        assert matchers.SyslogMessageMatcher('*foo*').tag == '*foo*'
        assert matchers.SyslogMessageMatcher('bar', 'bar').tag == 'bar'

    def test_call(self):
        smm = matchers.SyslogMessageMatcher('*foo*')
        assert smm('might fool me once')
        assert not smm('wont let you do it twice thought')


class TestPcapMessageMatcher(unittest.TestCase):

    @patch(__name__+'.PcapMessageMatcher.containing')
    def test_init(self, m_containing):
        matcher_empty = PcapMessageMatcher('test_msg_pattern', tag='msg1', message_type_pattern='empty')
        m_containing.assert_called_once_with(key_pattern='test_msg_pattern', value_pattern=None,
                                             path_filter=None, regex_engine='fnmatch')
        assert matcher_empty.tag == 'msg1'

        matcher_default = PcapMessageMatcher('test_msg_pattern', message_type_pattern='structure')
        m_containing.assert_called_with(key_pattern='*test_msg_pattern*(Structure)*', value_pattern=None,
                                        path_filter=None, regex_engine='fnmatch')
        assert matcher_default.tag == 'test_msg_pattern'

        PcapMessageMatcher('test_msg_pattern', message_type_pattern='{}_custom')
        m_containing.assert_called_with(key_pattern='test_msg_pattern_custom', value_pattern=None,
                                        path_filter=None, regex_engine='fnmatch')

    def test_containing_not_containing(self):
        d_inner = StrPatternDict()
        d_inner['slots'] = '3',
        d_inner['errors'] = 'many'
        d_inner['protocol'] = 'its complicated'
        d_outer = StrPatternDict()
        d_outer['Structure'] = d_inner

        # containing test
        badoo = matchers.PcapMessageMatcher('Structure', message_type_pattern='empty')
        badoo.containing('slots')  # containing key test
        badoo.containing('errors', 'many')  # containing key value test
        assert len(badoo.chain) == 3
        assert badoo.check(d_outer) is True  # __call__ and check tested

        # not_containing test
        tinder = matchers.PcapMessageMatcher('Structure', message_type_pattern='empty')
        tinder.not_containing('cat ears')  # not_containing key test
        assert tinder.check(d_outer)
        tinder.not_containing('errors', 'many')  # not_containing key value test
        assert tinder.check(d_outer) is False

        # path_filter test
        assert matchers.PcapMessageMatcher('Structure', message_type_pattern='empty')\
            .containing('protocol', path_filter='Structure')(d_outer)
        assert not matchers.PcapMessageMatcher('Structure', message_type_pattern='empty')\
            .containing('protocol', path_filter='not complicated')(d_outer)


class TestTTIMessageMatcher(unittest.TestCase):

    @patch(__name__+'.TTIMessageMatcher.containing')
    def test_init(self, m_containing):
        matcher = TTIMessageMatcher('test_msg_pattern')
        m_containing.assert_called_with('message', 'test_msg_pattern', 'fnmatch')
        assert matcher.tag == 'test_msg_pattern'

        TTIMessageMatcher('test_msg_pattern', message_key_pattern='custom')
        m_containing.assert_called_with('custom', 'test_msg_pattern', 'fnmatch')

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
