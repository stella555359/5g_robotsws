"""
:copyright: Nokia Networks
:author: Mateusz Lesniak
:maintainer: Marcin Trebunia
:contact: marcin.trebunia@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import re


def configure_nwslices_in_wts_cfg_file(wts_instance, snssai):
    """
    Add nwslices to loaded WTS config.

    :param wts_instance:  (wts) Instance of wts object with loaded WTS config.
    :param snssai:        (list) List of snssai parameters needed by nwslice object.
    """
    set_qosrule = wts_instance.find_all(command='set_qosrule')
    set_qosflow = wts_instance.find_all(command='set_qosflow')
    qos_rules = sorted([int(wts_instance.get_parameter(command=qosrule_id, parameter='id')) for qosrule_id in
                        set_qosrule])
    qos_flows = sorted([int(wts_instance.get_parameter(command=qosflow_id, parameter='id')) for qosflow_id in
                        set_qosflow])
    qos_rules = str(qos_rules).replace('[', '').replace(']', '').replace(" ", "")
    qos_flows = str(qos_flows).replace('[', '').replace(']', '').replace(" ", "")
    wts_instance.modify(command='nwslice_set id=1', modification=f"qos_rules={qos_rules} qos_flows={qos_flows}")
    for idx, param in enumerate(snssai, start=2):
        wts_instance.clone_and_modify(command='nwslice_set id=1', modification=f"id={idx} qos_rules={qos_rules} "
                                      f"qos_flows={qos_flows} snssai=0x01:{param} default=off")


def configure_second_plmn_in_wts_cfg_file(wts_instance, plmn, mme_pool_area=1, gnb_id=2, cell_id=1, set_amf_region=1):
    """
    Add parameters required by second plmn to loaded WTS config.

    :param wts_instance:   (wts) Instance of wts object with loaded WTS config.
    :param plmn:           (str) PLMN number in format MCC:MNC.
    :param mme_pool_area:  (int) mme_pool_area id from wts_config.
    :param gnb_id:         (int) gnb_id from wts_config.
    :param cell_id:        (int) cell_id from wts_config.
    :param set_amf_region: (int) set_amf_region id from wts_config.
    """
    base_plmn = wts_instance.get_parameter(command='set_enb id=1', parameter='plmn')
    wts_instance.modify(command=f'mme_pool_area id={mme_pool_area}', modification=f'eq_plmn={plmn}')
    wts_instance.modify(command=f'set_gnb id={gnb_id}', modification=f'plmnList={base_plmn},{plmn}')
    wts_instance.modify(command=f'set_cell id={cell_id}', modification=f'eq_plmn={plmn}')
    wts_instance.modify(command=f'set_cell id={cell_id}', modification=f'shared_plmn=311:489,{plmn}')
    wts_instance.modify(command=f'set_amf_region id={set_amf_region}', modification=f'plmn={base_plmn},{plmn}')


def configure_second_plmn_for_ues(wts_instance, net_arch, ue_list, plmn):
    """
    Reconfigure UE parameters required by second plmn.

    :param wts_instance:  (wts) Instance of wts object with loaded WTS config.
    :param plmn:          (str) Added PLMN number in format MCC:MNC.
    :param ue_list:       (int) List of UE id's to which new plmn will be configured.
    :param net_arch:      (int) Net_arch of UE id's to which new plmn will be configured.
    """
    if net_arch == 'nsa':
        for ue_id in ue_list:
            ue_imsi = wts_instance.get_parameter(command=f'set_ue id={ue_id}', parameter='imsi').split(':')[-1]
            wts_instance.modify(command=f'set_ue id={ue_id}', modification=f'imsi={plmn}:{ue_imsi}')
    elif net_arch == 'sa':
        for ue_id in ue_list:
            ue_suci = wts_instance.get_parameter(command=f'set_ue id={ue_id}', parameter='suci').split(':')[-1]
            wts_instance.modify(command=f'set_ue id={ue_id}', modification=f'suci=0:{plmn}:0000:0:0:{ue_suci}')


def configure_additional_qosflow(wts_instance, qos_flows):
    """
    Configure additional qos flows and enable all.

    :param wts_instance:  (wts) Instance of wts object with loaded WTS config.
    :param qos_flows:     (str) List of dicts with qos flows in format
                                [{'id': '4', '5qi': '5'}, {'id': '5', '5qi': '5'}]
    """
    for qos in qos_flows:
        old_qfi_5qi = wts_instance.get_parameter(command=f"set_qosflow id={qos['id']}", parameter='5qi')
        if old_qfi_5qi:
            old_qfi_id = wts_instance.get_parameter(command=f"set_qosflow 5qi={qos['5qi']}", parameter='id')
            if old_qfi_id:
                wts_instance.modify(command=f"set_qosflow id={old_qfi_id}", modification=f"5qi={old_qfi_5qi}")
            wts_instance.modify(command=f"set_qosflow id={qos['id']}", modification=f"5qi={qos['5qi']}")
        else:
            wts_instance.insert(f"set_qosflow id={qos['id']} 5qi={qos['5qi']}", 'after', f'set_qosflow id=1')
    wts_instance.delete(command='enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
    wts_instance.insert(f'enb_param id=1 endc_capable_qci=all', 'after', 'set_enb id=1')


def configure_additional_qosrules(wts_instance, qos_rules):
    """
    Add qos_rules to loaded WTS config.

    :param wts_instance:  (wts) Instance of wts object with loaded WTS config.
    :param qos_rules:     (list) List of qos_rules parameters needed by nwslice object.
    """
    for idx, param in enumerate(qos_rules, start=3):
        wts_instance.clone_and_modify(command='set_qosrule id=2', modification=f'id={idx} qos_flow={param}')


def configure_additional_bearer(wts_instance, bearers, first_nsa_ue, target_number_of_nsa_ues, qci, pdn):
    wts_instance.delete(command='enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
    wts_instance.insert(f'enb_param id=1 endc_capable_qci=all', 'after', 'set_enb id=1')
    wts_instance.modify(command='enb_endc_param id=1', modification='enable_dl_data_forwarding=on')
    wts_instance.insert(f'ue_enb_endc_param id=1 bearer={bearers[0]}-{bearers[-1]}', 'after', 'enb_param id=1')

    for ue_id in range(first_nsa_ue, first_nsa_ue + int(target_number_of_nsa_ues)):
        for bearer in bearers:
            if bearer == 2:
                continue
            wts_instance.insert(f"set_bearer id={bearer} ue={ue_id} qci={qci} pdn={pdn}", 'after',
                                f'set_bearer id=2 ue={ue_id}')


def set_custom_ue_cap(wts_instance, net_arch, nr_ue_caps, mrdc_ue_caps, first_sa_ue, first_nsa_ue, num_of_sa_ues=1,
                      num_of_nsa_ues=1):
    if net_arch == 'SA' and nr_ue_caps:
        for ue_id in range(first_sa_ue, first_sa_ue + num_of_sa_ues + 1):
            wts_instance.modify(command=f'ue_param id={ue_id}', modification=f'ue_nr_capabilities={nr_ue_caps}')
    elif net_arch == 'NSA' and mrdc_ue_caps:
        for ue_id in range(first_nsa_ue, first_nsa_ue + num_of_nsa_ues + 1):
            wts_instance.modify(command=f'ue_param id={ue_id}', modification=f'ue_nr_capabilities={nr_ue_caps}')
            wts_instance.modify(command=f'ue_param id={ue_id}', modification=f'ue_eutra_nr_capabilities={mrdc_ue_caps}')
            wts_instance.modify(command='enb_endc_param id=1', modification='serving_cell_index_range_scg=8:9')


def modify_arfcn_gscn(wts_instance):
    wts_instance.modify(command='set_cell id=2 gnb=2', modification=f'nr_arfcn=643330:643330')
    wts_instance.modify(command='set_cell id=2 gnb=2', modification=f'gscn=7950')


def configure_mu_mimo(wts_instance):
    wts_instance.insert("cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-69,-34,14,48",
                        'after', f'uec_param id=1')
    wts_instance.insert("cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate",
                        'after', f'cell_srs_beam_pos_nr profile_id=1')


def remove_cell_and_its_ues(wts_instance, remove_cell):
    for cell_id in remove_cell:
        wts_instance.delete(command=f"set_cell id={cell_id} gnb=2")
        commands_set_ues = wts_instance.find_all_by_parameter('', f'cell={cell_id}')
        for command in commands_set_ues:
            id_of_ue_to_delete = re.search(r'(id=)(\d+)', command).group(2)
            wts_instance.delete(command=f"set_ue simulated id={id_of_ue_to_delete} enb=2")
            wts_instance.delete(command=f"ue_param id={id_of_ue_to_delete}")
            wts_instance.delete(command=f"set_pdu_gateway id={id_of_ue_to_delete}")
