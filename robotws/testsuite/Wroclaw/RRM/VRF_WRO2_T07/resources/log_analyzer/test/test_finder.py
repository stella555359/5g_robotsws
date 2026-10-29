import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.finder as finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.readers import IterableReader
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.str_pattern_dict import StrPatternDict
import unittest
from mock import MagicMock


class TestMessageFinder(unittest.TestCase):

    def test_init(self):
        class NotLogReader:
            pass

        class FakeReader(finder.LogReader):
            list = generator = reset_generator = MagicMock()

        mf = finder.MessageFinder(FakeReader())
        FakeReader.generator.assert_called_once()

        with self.assertRaises(ValueError):
            finder.MessageFinder(NotLogReader())

    def test_find(self):
        user_setup = StrPatternDict([('UserSetupReq', StrPatternDict([('slot', '0x05(5)')]))])
        slot_type_3 = StrPatternDict([('SlotTypeReq', StrPatternDict([('slot', '0x03(3)')]))])
        slot_type_7 = StrPatternDict([('SlotTypeReq', StrPatternDict([('slot', '0x07(7)')]))])

        mf = finder.MessageFinder(IterableReader(iterable=[slot_type_3, user_setup, slot_type_7]))
        m_user_setup = PcapMessageMatcher('UserSetupReq', message_type_pattern='empty')
        m_slot = PcapMessageMatcher('SlotTypeReq', message_type_pattern='empty')
        m_miss = PcapMessageMatcher('none existent')

        # find next test
        assert mf.find_next(m_slot) == slot_type_3
        assert mf.find_next(m_slot) == slot_type_7
        assert mf.find_next(m_slot) is None
        assert mf.find_next_anew(m_slot) == slot_type_3
        assert mf.find_next_anew([m_slot]) == (slot_type_3, m_slot)

        # find all test
        mf.reset_generator()
        assert mf.find_all(m_slot) == [slot_type_3, slot_type_7]
        # output parameter does not matter if matchers passed to find_all is not list
        assert mf.find_all(m_slot, output='tag_list') == [slot_type_3, slot_type_7]
        assert mf.find_all(m_slot, output='dict') == [slot_type_3, slot_type_7]
        assert mf.find_all([m_slot], output='tag_list') == [(slot_type_3, m_slot), (slot_type_7, m_slot)]
        assert mf.find_all([m_slot], output='dict') == {'SlotTypeReq': [slot_type_3, slot_type_7]}

        assert mf.find_all([m_miss], output='dict') == {}
        assert mf.find_all([m_miss], output='tag_list') == []
        assert mf.find_all([m_miss], output='raw_list') == []

        assert mf.find_all([m_miss, m_slot, m_user_setup], output='dict') == {
            'SlotTypeReq': [slot_type_3, slot_type_7], 'UserSetupReq': [user_setup]
        }
        assert mf.find_all_anew([m_miss, m_slot, m_user_setup], output='dict') == {
            'SlotTypeReq': [slot_type_3, slot_type_7], 'UserSetupReq': [user_setup]
        }
        assert mf.find_all([m_slot], forget_matcher_on_hit=True, output='tag_list') == [(slot_type_3, m_slot)]
        # output parameter does not matter if matchers passed to find_all is not list
        assert mf.find_all(m_slot, forget_matcher_on_hit=True, output='tag_list') == [slot_type_3]
        assert mf.find_all(m_slot, forget_matcher_on_hit=True) == [slot_type_3]

        # find exactly test
        assert mf.find_one(m_user_setup) == user_setup
        assert mf.find_exactly(2, m_slot) == [slot_type_3, slot_type_7]
        with self.assertRaises(AssertionError):
            mf.find_exactly(2, m_user_setup)
