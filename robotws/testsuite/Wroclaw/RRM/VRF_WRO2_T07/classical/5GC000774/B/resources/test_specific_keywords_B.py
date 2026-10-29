from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters import get_relevant_pm_counters

scf_params_rohc_b = {'actRohc': 'true', 'maxCidAllowed': '4',
                     'miNrPDCP2Report': '5min', 'miNrRRCC': '5min', 'miNrE1InterfaceCuCpSa': '5min'}


"""
PM counters list:
    M55135C01001 - gNB sent
    M55135C01002 - gNB received
    M55124C06001 - cell sent
    M55124C06002 - cell received
"""


def check_compressor_decompressor_counters(pi_dir):
    counter_ids = ['M55320C19001', 'M55320C19002', 'M55320C19003', 'M55320C19004']
    value_dict = get_relevant_pm_counters(pi_dir, counter_ids)
    for counter in value_dict.values():
        for cell, counter_values in iter(counter.items()):
            blog(cell, counter_values[-1])
            assert int(counter_values[-1]) > 0, 'ROHC Compressor and Decompressor counters not incremented'


def get_cs_ue_from_ngap_logs(pcap_path):
    with LogHelper() as lh:
        pcap = lh.add_pcap(pcap_file_path=pcap_path, tshark_filter='ngap', lua=None, clean_up_tmp_file=True)

        ue_caps = pcap.find_next(PcapMessageMatcher('UERadioCapabilityInfoIndication', message_type_pattern='empty'))
        cs_ue = ue_caps.find('*maxNumberROHC-ContextSessions')
        return cs_ue.first()['val'].split()[0][2:]


def check_rohc_context_counters_04(pi_dir, max_cid_allowed, cs_ue):
    counter_ids = ['M55135C01001', 'M55135C01002', 'M55124C06001', 'M55124C06002']
    value_dict = get_relevant_pm_counters(pi_dir, counter_ids)
    no_contexts = calculate_no_contexts_for_rohc(int(max_cid_allowed), int(cs_ue))

    for counter_values in value_dict['M55135C01001'].values():
        assert int(counter_values[-1]) == 2*no_contexts, 'Invalid counter value for counter M55135C01001'

    for counter_values in value_dict['M55135C01002'].values():
        assert int(counter_values[-1]) == 2*no_contexts, 'Invalid counter value for counter M55135C01002'

    assert sum(int(counter_values[-1]) for counter_values in value_dict['M55124C06001'].values()) == 2 * no_contexts, \
        'Invalid counter value for counter M55124C06001'

    assert sum(int(counter_values[-1]) for counter_values in value_dict['M55124C06002'].values()) == 2 * no_contexts, \
        'Invalid counter value for counter M55124C06002'


def check_rohc_context_counters_05(pi_dir, max_cid_allowed, cs_ue):
    counter_ids = ['M55135C01001', 'M55135C01002', 'M55124C06001', 'M55124C06002']
    value_dict = get_relevant_pm_counters(pi_dir, counter_ids)
    no_contexts = calculate_no_contexts_for_rohc(int(max_cid_allowed), int(cs_ue))

    for counter_values in value_dict['M55135C01001'].values():
        assert int(counter_values[-1]) == no_contexts, 'Invalid counter value for counter M55135C01001'

    for counter_values in value_dict['M55135C01002'].values():
        assert int(counter_values[-1]) == no_contexts, 'Invalid counter value for counter M55135C01002'

    context_sum = 0
    for cell_id, counter_values in iter(value_dict['M55124C06001'].items()):
        context_sum += int(counter_values[-1])
    assert context_sum == no_contexts, 'Invalid counter value for counter M55124C06001'

    context_sum = 0
    for cell_id, counter_values in iter(value_dict['M55124C06002'].items()):
        context_sum += int(counter_values[-1])
    assert context_sum == no_contexts, 'Invalid counter value for counter M55124C06002'


def check_rohc_context_counters_06(pi_dir, max_cid_allowed, cs_ue):
    counter_ids = ['M55135C01001', 'M55135C01002', 'M55124C06001', 'M55124C06002']
    value_dict = get_relevant_pm_counters(pi_dir, counter_ids)
    no_contexts = calculate_no_contexts_for_rohc(int(max_cid_allowed), int(cs_ue))

    for counter_values in value_dict['M55135C01001'].values():
        assert int(counter_values[-1]) == 6*no_contexts, 'Invalid counter value for counter M55135C01001'

    for counter_values in value_dict['M55135C01002'].values():
        assert int(counter_values[-1]) == 6*no_contexts, 'Invalid counter value for counter M55135C01002'

    context_sum_1 = 0
    for cell_id, counter_values in iter(value_dict['M55124C06001'].items()):
        context_sum_1 += int(counter_values[-1])

    context_sum_2 = 0
    for cell_id, counter_values in iter(value_dict['M55124C06002'].items()):
        context_sum_2 += int(counter_values[-1])

    assert context_sum_1 == context_sum_2, 'Invalid counter values for counter the cell-specific counters'


def check_rohc_context_counters_07(pi_dir, max_cid_allowed, cs_ue):
    counter_ids = ['M55135C01001', 'M55135C01002', 'M55124C06001', 'M55124C06002']
    value_dict = get_relevant_pm_counters(pi_dir, counter_ids)
    no_contexts = calculate_no_contexts_for_rohc(int(max_cid_allowed), int(cs_ue))

    for counter_values in value_dict['M55135C01001'].values():
        assert int(counter_values[-1]) == 2*no_contexts, 'Invalid counter value for counter M55135C01001'

    for counter_values in value_dict['M55135C01002'].values():
        assert int(counter_values[-1]) == 2*no_contexts, 'Invalid counter value for counter M55135C01002'

    context_sum = 0
    for cell_id, counter_values in iter(value_dict['M55124C06001'].items()):
        context_sum += int(counter_values[-1])
    assert context_sum == no_contexts, 'Invalid counter value for counter M55124C06001'

    context_sum = 0
    for cell_id, counter_values in iter(value_dict['M55124C06002'].items()):
        context_sum += int(counter_values[-1])
    assert context_sum == no_contexts, 'Invalid counter value for counter M55124C06002'


def calculate_no_contexts_for_rohc(max_cid_allowed, cs_ue):
    no_contexts = min(cs_ue/2, max_cid_allowed)
    return no_contexts + 1
