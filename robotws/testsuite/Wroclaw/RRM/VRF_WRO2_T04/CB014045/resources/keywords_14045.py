import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import load_delta_template
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import message_to_tree
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import update_parameter

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_files')


def activate_la_enhancements_feature(cell_id, value):
    template = load_delta_template(os.path.join(DELTA_DIR, 'activate_la.json'))
    delta = template.render(cell_id=cell_id, value=value, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def deactivate_la_enhancements_feature(cell_id):
    template = load_delta_template(os.path.join(DELTA_DIR, 'deactivate_la.json'))
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def calculate_average_tput(tputs_list):
    tputs_list = [float(tput) for tput in tputs_list]
    return round(sum(tputs_list) / len(tputs_list), 2)


def get_ue_rnti(pcap_file):
    tshark_filter = 'nr-rrc'
    output = TSharkCommandAssembler() \
        .with_filter(tshark_filter) \
        .with_pcap_file(pcap_file) \
        .build()
    crntis = message_to_tree(output).find('C-RNTI').filter('UEContextSetupResponse')
    assert len(crntis) == 1
    return crntis[0]['val']


def enable_ul_256_qam(nrcell_id):
    update_parameter(parameter='actUl256Qam', value='true',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def disable_ul_256_qam(nrcell_id):
    update_parameter(parameter='actUl256Qam', value='false',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def enable_la_for_hi_reliab(nrcell_id):
    update_parameter(parameter='actLAForHiReliab', value='true',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def disable_la_for_hi_reliab(nrcell_id):
    update_parameter(parameter='actLAForHiReliab', value='false',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def enable_uldftsofdm(nrcell_id):
    update_parameter(parameter='actUlDftSOfdm', value='true',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def disable_uldftsofdm(nrcell_id):
    update_parameter(parameter='actUlDftSOfdm', value='false',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def enable_optpuschprballoc(nrcell_id):
    update_parameter(parameter='actOptPuschPrbAlloc', value='true',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')


def disable_optpuschprballoc(nrcell_id):
    update_parameter(parameter='actOptPuschPrbAlloc', value='false',
                     distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{nrcell_id}')
