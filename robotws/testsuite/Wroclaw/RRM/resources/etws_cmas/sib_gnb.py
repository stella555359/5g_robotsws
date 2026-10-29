from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm

import testsuite.Wroclaw.RRM.resources.etws_cmas.filters as filters

SHARK_OPTIONS = [('-o', 'swe.call_mac_nr:TRUE')]


def sib7_is_broadcasted(pcap_file, msg_id='*', message=None):
    return _sib_broadcasted(pcap_file, 7, msg_id, filters.SIB_7, message)


def sib6_is_broadcasted(pcap_file, msg_id='*'):
    return _sib_broadcasted(pcap_file, 6, msg_id, filters.SIB_6)


def sib7_is_not_broadcasted(pcap_file, msg_id='*', message=None):
    return _sib_broadcasted(pcap_file, 7, msg_id, filters.SIB_7, message, expect=False)


def sib6_is_not_broadcasted(pcap_file, msg_id='*'):
    return _sib_broadcasted(pcap_file, 6, msg_id, filters.SIB_6, expect=False)


def _sib_broadcasted(pcap_file, sibnr, msg_id, shark_filter=None, message=None, expect=True):
    expected_sib = 'sib{}'.format(sibnr)
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=shark_filter,
            ts_output_data_file_path=None, clean_up_tmp_file=True
        )
        sib_to_find = pm(expected_sib, name_line_pattern='empty')
        if msg_id:
            sib_to_find = sib_to_find.containing('messageIdentifier', '*{}*'.format(msg_id))
        if message:
            sib_to_find = sib_to_find.containing('Decoded Page*', '{}'.format(message))

        msgs = finder.find_next(sib_to_find)
        blog(msgs)
        if msgs and not expect:
            raise AssertionError("{sib} with msg_id {msg_id} was found in {file}, but should not be present!".format(
                sib=expected_sib,
                msg_id=msg_id,
                file=pcap_file)
            )
        elif not msgs and expect:
            raise AssertionError("{sib} with msg_id {msg_id} was not found in {file}, but should be present".format(
                sib=expected_sib,
                msg_id=msg_id,
                file=pcap_file)
            )
