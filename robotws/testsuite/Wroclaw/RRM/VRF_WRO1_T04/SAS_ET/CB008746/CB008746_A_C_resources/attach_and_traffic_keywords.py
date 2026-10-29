"""
:copyright: Nokia Networks
:author: Mateusz Lesniak
:maintainer: Beata Kapusta, Marcin Trebunia
:contact: I_CD_ET_TESTERS@internal.nsn.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

from time import sleep
from os.path import join
from itertools import zip_longest

from ta5g_ue_mobility import ta5g_ue_mobility

from variables import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts import run_egate_cmd, \
    attach_ue_and_establish_pdu_session, start_data_traffic_in_egate


def wait_for_egate_command_effect(duration=2):
    sleep(duration)


def attach_nsa_ues_with_spid_parameter(nsa_ues=(101, 102), spids=(1, 1), second_plmn='312:490', bearers=(2,),
                                       target_cells=1, ues_with_additional_bearer=(), second_plmn_ues=()):
    """
    Attach NSA UEs with specified spid parameter.

    :param nsa_ues:                         (tuple) List of UEs IDs.
    :param spids:                           (tuple) List of SPID for NSA UEs (order matchings NSA UEs)
    :param second_plmn:                     (str)  Second plmn number.
    :param bearers:                         (tuple) Set of bearers available for NSA UEs.
    :param target_cells:                    (int) Cell to perform 5G attach
    :param ues_with_additional_bearer:      (tuple) List of UEs that will have additional bearer activated.
    :param second_plmn_ues:                 (tuple) List of UEs atttached to second plmn.

    """
    for ue_id, spid in zip_longest(nsa_ues, spids):
        ta5g_ue_mobility().attach_ue_to_enb(
            ue_id=ue_id,
            pass_regexp=f'UE{ue_id}: === UE IS ACTIVE'
        )
        if bearers:
            for bearer in bearers:
                if bearer == 2:
                    continue
                if ue_id in ues_with_additional_bearer:
                    run_egate_cmd(
                        cmd=f'bearer_add ue={ue_id} id={bearer} filter=2 precedence=2 local_port=7072 proto=17 '
                            f'filter=3 precedence=3 remote_port=7073 proto=17')
                    wait_for_egate_command_effect()
        if second_plmn_ues:
            if ue_id in second_plmn_ues and second_plmn:
                run_egate_cmd(cmd=f'enb_endc_param id=1 selected_plmn={second_plmn} serving_plmn={second_plmn}')
                wait_for_egate_command_effect()
            else:
                run_egate_cmd(cmd='enb_endc_param id=1 selected_plmn=311:489 serving_plmn=311:489')
                wait_for_egate_command_effect()
        if spid:
            run_egate_cmd(cmd=f'ue_enb_param id={ue_id} spid={spid}')
            wait_for_egate_command_effect()
        if bearers and ue_id in ues_with_additional_bearer:
            ta5g_ue_mobility().start_gnb_addition_procedure(
                ue=ue_id,
                target_cells=target_cells,
                bearer=f'{",".join(str(e) for e in bearers)}',
                dc_type='split_scg',
                pass_regexp=fr'UE{ue_id}: Proxy [(]eNB \d+ cell \d+[)] reported successful RA'
            )
        else:
            ta5g_ue_mobility().start_gnb_addition_procedure(
                ue=ue_id,
                target_cells=target_cells,
                bearer=2,
                dc_type='split_scg',
                pass_regexp=fr'UE{ue_id}: Proxy [(]eNB \d+ cell \d+[)] reported successful RA'
            )
        wait_for_egate_command_effect()


def attach_sa_ues_to_according_nwslices(sa_ues=(1, 2), nwslices=(1, 1), additional_qosflows_to_activate='',
                                        local_cell=1):
    """
    Attach SA UEs to specified nwslices.

    :param sa_ues:                         (tuple) List of SA UEs' IDs.
    :param nwslices:                       (tuple) List of nwslices (order matching SA UEs given)
    :param additional_qosflows_to_activate (str)  Additional qos flows to activate for given UEs, separated with commas
    :param local_cell                      (int)  Local cell on which UE should attach (needed for taf keyword)

    """
    if additional_qosflows_to_activate:
        run_egate_cmd(cmd=f'smf_param id=1 additional_qosflows_to_activate={additional_qosflows_to_activate}')
        wait_for_egate_command_effect()

    for ue_id, nwslice in zip_longest(sa_ues, nwslices, fillvalue=1):
        attach_ue_and_establish_pdu_session(ue_id=ue_id, cell_id=local_cell, nwslice=nwslice)


def perform_traffic_on_different_times_for_ues(nsa_ues=(), sa_ues=(), dl_tput='175', ul_tput='24', traffic_delay=6,
                                               traffic_direction='dl', traffic_bearers=(2, 3), qfi_sa=(1, 2),
                                               traffics_per_bearer=3, traffics_per_qfi=3):
    """
    Start traffic for all NSA and SA UEs on different times.

    :param nsa_ues:                         (tuple) List of NSA UEs' IDs.
    :param sa_ues:                          (tuple) List of SA UEs' IDs.
    :param dl_tput:                         (str) Downlink traffic rate in megabytes per second.
    :param ul_tput:                         (str) Uplink traffic rate in megabytes per second.
    :param traffic_delay:                   (int) Time in seconds of delay between traffic starts.
    :param traffic_direction:               (str) Traffic direction (ul, dl or bi).
    :param traffic_bearers:                 (tuple) Bearers to run traffic on
    :param qfi_sa:                          (tuple) Qfi for SA devices.
    :param traffics_per_bearer:             (int) Number of traffic runs per NSA bearer.
    :param traffics_per_qfi:                (int) Number of traffic runs per SA qfi.

    """
    for ue_id, traffic_bearer in zip(nsa_ues, traffic_bearers):
        if traffic_direction in ['bi', 'ul']:
            _start_traffic(traffics_per_bearer, traffic_bearer, ue_id, ul_tput, 'ul', 'nsa')
        if traffic_direction in ['bi', 'dl']:
            _start_traffic(traffics_per_bearer, traffic_bearer, ue_id, dl_tput, 'dl', 'nsa')
        sleep(traffic_delay)  # Feature requires time intervals between traffic start

    for ue_id, qfi in zip(sa_ues, qfi_sa):
        if traffic_direction in ['bi', 'ul']:
            _start_traffic(traffics_per_qfi, qfi, ue_id, ul_tput, 'ul', 'sa')
        if traffic_direction in ['bi', 'dl']:
            _start_traffic(traffics_per_qfi, qfi, ue_id, dl_tput, 'dl', 'sa')
        sleep(traffic_delay)  # Feature requires time intervals between traffic start


def activate_additional_bearer_and_run_traffic(ues_with_late_bearer_activation=(11,), traffic_direction='dl',
                                               traffics_per_bearer=1, dl_tput='120', ul_tput='10'):
    """
    Activate additional bearer (hardcoded as 3) for NSA UE and run traffic with it

    :param ues_with_late_bearer_activation: (tuple) List of NSA UEs' IDs.
    :param traffic_direction:               (str) Traffic direction (ul, dl or bi).
    :param traffics_per_bearer:             (int) Number of traffic runs per bearer.
    :param dl_tput:                         (str) Downlink traffic rate in megabytes per second.
    :param ul_tput:                         (str) Uplink traffic rate in megabytes per second.

    """
    for ue_id in ues_with_late_bearer_activation:
        run_egate_cmd(cmd=f'bearer_add ue={ue_id} id=3 filter=2 precedence=2 local_port=7072 proto=17 '
                          f'filter=3 precedence=3 remote_port=7073 proto=17')
        wait_for_egate_command_effect()
        run_egate_cmd(cmd=f'enb_ue_dc_modify ue={ue_id} bearer_to_add=3 by=enb cause=RN_count_reaches_max_value')
        wait_for_egate_command_effect(5)
        if traffic_direction in ['bi', 'ul']:
            _start_traffic(traffics_per_bearer, 3, ue_id, ul_tput, 'ul', 'nsa')
        if traffic_direction in ['bi', 'dl']:
            _start_traffic(traffics_per_bearer, 3, ue_id, dl_tput, 'dl', 'nsa')


def perform_individual_traffic_for_ues(specific_traffic_params, traffic_direction='dl'):
    """
    Start traffic for all NSA and SA UEs on different times.

    :param specific_traffic_params:         (dict) Dictionary with all the parameters needed for traffic, defined in
                                                   variables
    :param traffic_direction:               (str) Traffic direction (ul, dl or bi).

    """
    for ue_traffic_params in specific_traffic_params:
        net_arch = 'nsa' if ue_traffic_params['ue_id'] >= 101 else 'sa'
        if traffic_direction in ['bi', 'ul']:
            _start_traffic_with_individual_value(ue_traffic_params['traffic_id'], ue_traffic_params['bearer'],
                                                 ue_traffic_params['ue_id'], ue_traffic_params['tput'], 'ul', net_arch)
        if traffic_direction in ['bi', 'dl']:
            _start_traffic_with_individual_value(ue_traffic_params['traffic_id'], ue_traffic_params['bearer'],
                                                 ue_traffic_params['ue_id'], ue_traffic_params['tput'], 'dl', net_arch)


def _start_traffic(traffics_per_bearer_or_qfi, bearers_or_qfis, ue_id, tput, direction, net_arch):
    traffic_ids = iter(range(2, traffics_per_bearer_or_qfi + 2))
    for traffic in range(traffics_per_bearer_or_qfi):
        trf_id = next(traffic_ids)
        if net_arch.lower() == 'nsa':
            logger_console(f'Start traffic: dir={direction}, UE={ue_id} bearer={bearers_or_qfis} '
                           f'trf_id={trf_id} mbps={tput}')
            start_data_traffic_in_egate(ue_id=ue_id, net_arch=net_arch, direction=direction, mbps=tput,
                                        bearer=bearers_or_qfis, trf_id=trf_id)
        else:
            logger_console(f'Start traffic: dir={direction}, UE={ue_id} qfi={bearers_or_qfis} '
                           f'trf_id={trf_id} mbps={tput}')
            start_data_traffic_in_egate(ue_id=ue_id, net_arch=net_arch, direction=direction, mbps=tput,
                                        qfi=bearers_or_qfis, trf_id=trf_id)


def _start_traffic_with_individual_value(trf_id, bearers_or_qfis, ue_id, tput, direction, net_arch):
    if net_arch.lower() == 'nsa':
        logger_console(f'Start traffic: dir={direction}, UE={ue_id} bearer={bearers_or_qfis} '
                       f'trf_id={trf_id} mbps={tput}')
        start_data_traffic_in_egate(ue_id=ue_id, net_arch=net_arch, direction=direction, mbps=tput,
                                    bearer=bearers_or_qfis, trf_id=trf_id)
    else:
        logger_console(f'Start traffic: dir={direction}, UE={ue_id} qfi={bearers_or_qfis} '
                       f'trf_id={trf_id} mbps={tput}')
        start_data_traffic_in_egate(ue_id=ue_id, net_arch=net_arch, direction=direction, mbps=tput,
                                    qfi=bearers_or_qfis, trf_id=trf_id)


def activate_advanced_srs_for_ues(nsa_ues=(101, 102, 103, 104, 105, 106)):
    """
    Activate advanced SRS for given UEs by applying profiles defined in variables

    :param nsa_ues:                         (tuple) List of NSA UEs' IDs.

    """
    profiles_to_set = [
        'ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed test_type=SRS init_quad_pos=3 init_sub_quad_pos=2 step=5 '
        'trigger_puxch_update=0',
        'ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed test_type=SRS init_quad_pos=2 init_sub_quad_pos=2 step=5 '
        'trigger_puxch_update=0',
        'ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed test_type=SRS init_quad_pos=0 init_sub_quad_pos=0 step=5 '
        'trigger_puxch_update=0',
        'ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed test_type=SRS init_quad_pos=1 init_sub_quad_pos=0 step=5 '
        'trigger_puxch_update=0',
        'ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed test_type=SRS init_quad_pos=0 init_sub_quad_pos=0 step=5 '
        'trigger_puxch_update=0',
        'ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed test_type=SRS init_quad_pos=1 init_sub_quad_pos=0 step=5 '
        'trigger_puxch_update=0'
    ]

    for profile in profiles_to_set:
        run_egate_cmd(profile)

    for profile_id, ue_id in enumerate(nsa_ues, start=1):
        run_egate_cmd(f'ue_testmode_set_nr id={ue_id} testmode=ul_mimo_srs_beam_pos action=activate '
                      f'profile_id={profile_id}')
