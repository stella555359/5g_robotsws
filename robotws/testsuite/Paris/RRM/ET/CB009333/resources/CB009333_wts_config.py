"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

from robot.libraries.BuiltIn import BuiltIn
from taf.config.wts import wts


def prepare_wts_config(target_path, net_arch='SA', nr_ue_caps=None, mrdc_ue_caps=None,
                       arfcn_gscn_change=None, slice_scheduler=False):
    """
    Configure WTS config file for CB009333. Includes changes related to DRB instances on gNB & optional UE capability
    change
    :param target_path: (str) Wts config file path
    :param net_arch: (str) Network architecture (SA or NSA)
    :param nr_ue_caps: (str) UE NR Capabilities for 5G.
    :param mrdc_ue_caps: (str) UE MRDC Capabilities for LTE
    :param arfcn_gscn_change: (bool) Set to True if NRARFCN and GSCN should be modified
    :param slice_scheduler: (bool) Set to True if Slice Aware Scheduler is used in test
    """

    wts_instance = wts()
    wts_instance.load_wts_cfg('/opt/iphy/latest/basic_setup.cfg')
    if net_arch == 'SA':
        _modify_5qi(wts_instance)
        _add_qosflows_activation(wts_instance)
    else:
        _add_bearer(wts_instance)
    if nr_ue_caps or mrdc_ue_caps:
        _set_ca_ue_cap(wts_instance, nr_ue_caps, mrdc_ue_caps)
    if arfcn_gscn_change:
        _modify_arfcn_gscn(wts_instance)
    if slice_scheduler:
        _add_nwslice(wts_instance)
    wts_instance.save_wts_cfg(target_path)
    return target_path


def _add_qosflows_activation(wts_instance):
    wts_instance.insert(
        [
            'smf_param id=1 additional_qosflows_to_activate=2'
        ],
        'after', 'uec_param id=1 reordering_window_size=1000 reordering_timer=200'
    )


def _modify_5qi(wts_instance):
    wts_instance.modify(command='set_qosflow id=2 5qi=5', modification='5qi=7')


def _add_bearer(wts_instance):
    wts_instance.modify(command='enb_param id=1 endc_capable_qci=9', modification='endc_capable_qci=all')
    wts_instance.modify(command='enb_endc_param id=1', modification='enable_dl_data_forwarding=on use_nr_ran_cont=on')
    wts_instance.insert(
        [
            'ue_enb_endc_param id=101 bearer=2-3',
            'ue_enb_endc_param id=102 bearer=2-3'
        ],
        'before',
        'set_bearer id=2 ue=101 qci=9 pdn=1 ip=$PDN_IP101 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 '
        'trf_type=internal'
    )
    wts_instance.insert(
        [
            'set_bearer id=3 ue=101 qci=8 pdn=1 default=off',
            'set_bearer id=3 ue=102 qci=8 pdn=1 default=off'
        ],
        'after', 'set_bearer id=2 ue=102 qci=9 pdn=1 ip=$PDN_IP102 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1'
                 ' trf_type=internal'
    )


def _add_nwslice(wts_instance):
    gnb2_config = wts_instance.get('set_gnb').replace(' nssai=0x1:0xd143a5', '')
    wts_instance.delete('set_gnb id=2')
    wts_instance.insert(
        gnb2_config, 'after', 'enb_endc_param id=1'
    )
    wts_instance.insert(
        'nwslice_set id=2 snssai=0x01:0x02 amf_region_id=1 plmn_list=311:489',
        'after',
        'nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1'
    )


def _set_ca_ue_cap(wts_instance, nr_ue_caps, mrdc_ue_caps):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if nr_ue_caps:
        wts_var_to_modify = 'SA_UE_CAPABILITIES_FDD' if 'FDD' in test_name else 'SA_UE_CAPABILITIES_TDD'
        wts_instance.delete(f'sim_var_set {wts_var_to_modify}')
        wts_instance.insert(f'set {wts_var_to_modify}={nr_ue_caps}', 'before', 'set ENB1_S1_ADDR="10.0.1.136"')
    if mrdc_ue_caps:
        wts_var_to_modify = 'NR_EUTRA_CAPABILITIES_FDD' if 'FDD' in test_name else 'NR_EUTRA_CAPABILITIES_TDD'
        wts_instance.modify(
            command=f'sim_var_set {wts_var_to_modify}', modification=f'{wts_var_to_modify}={nr_ue_caps}')
        wts_instance.modify(command='enb_endc_param id=101', modification='serving_cell_index_range_scg=8:9')


def _modify_arfcn_gscn(wts_instance):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    cell_ids = ['3', '4'] if 'FDD' in test_name else ['1', '2']
    gscn_values = ['1595', '1595'] if 'FDD' in test_name else ['7915', '8019']
    arfcn_values = ['134100:124900', '137100:127900'] if 'FDD' in test_name else ['640000:640000', '650000:650000']

    for cell_id, arfcn, gscn in zip(cell_ids, arfcn_values, gscn_values):
        wts_instance.modify(command=f'set_cell id={cell_id} gnb=2', modification=f'nr_arfcn={arfcn}')
        wts_instance.modify(command=f'set_cell id={cell_id} gnb=2', modification=f'gscn={gscn}')
