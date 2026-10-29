# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import math

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console_info, logger_warning, logger_console
)
import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.traffic_management as traffic__
import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts as wts__
from validation_egate import check_egate_log_in_real_time, check_old_msg_in_egate_log
from robot.libraries.BuiltIn import BuiltIn
from suite_kw import wait_for_tput_end_state
import time


def logger_console_and_warn(msg):
    logger_console_info(msg)
    logger_warning(msg)


def __set_ue_data(nrs, k=1):
    data = []
    for nr in range(k, nrs+k):
        data.append(str(nr))
    return data


def __set_plmns(nr_ues):
    plmn = '311:489'
    data = []
    for ue in range(nr_ues):
        data.append(plmn)
    return data


def __set_slices_pdu_gw(nr, _slices, _pdu, _gw):
    if not _slices:
        _slices = __set_ue_data(nr)
    if not _pdu:
        _pdu = __set_ue_data(nr)
    if not _gw:
        _gw = __set_ue_data(nr)
    return _slices, _pdu, _gw


def __set_bearers_plmns(nr_ues, _bearer, _plmn):
    if not _bearer:
        _bearer = __set_ue_data(nr_ues, k=2)
    if not _plmn:
        _plmn = __set_plmns(nr_ues)
    return _bearer, _plmn


def _set_beam_info(beams_info, ue_nr):
    if beams_info is None:
        beams_info = [dict() for i in range(ue_nr)]
    return beams_info


def _set_modify_pdu_session(ue_modify, ue_nr):
    if ue_modify is None:
        ue_modify = [dict() for i in range(ue_nr)]
    return ue_modify


def _set_wait_time(wait_time, ue_nr):
    if wait_time is None:
        wait_time = [str() for i in range(ue_nr)]
    elif isinstance(wait_time, list) is False:
        temp = wait_time
        wait_time = [temp for ue in range(ue_nr)]
    return wait_time


def _set_cells_info(cell, ue_nr):
    if isinstance(cell, list) is False:
        cells = cell
        cell = [cells for i in range(ue_nr)]
    return cell


def define_refine_beam(profile_id, ueBeamIndexInitial, csirs_bestbeam, csirs_rsrp_best, csirs_rsrp_avg,
                       ue_testmode_set_nr_id, testmode, action, beamaction):
    cmd = 'beam_control_testmode_nr'
    cmd += ' profile_id={}'.format(profile_id)
    cmd += ' ueBeamIndexInitial={}'.format(ueBeamIndexInitial)
    cmd += ' csirs_bestbeam={}'.format(csirs_bestbeam)
    cmd += ' csirs_rsrp_best={}'.format(csirs_rsrp_best)
    cmd += ' csirs_rsrp_avg={}'.format(csirs_rsrp_avg)
    logger_console('Defining refined beam with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)

    cmd = ' ue_testmode_set_nr id={}'.format(ue_testmode_set_nr_id)
    cmd += ' testmode={}'.format(testmode)
    cmd += ' action={}'.format(action)
    cmd += ' profile_id={}'.format(profile_id)
    cmd += ' beamaction={}'.format(beamaction)
    logger_console('Setting UE to refined beam with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def define_pdu_session_modification(ue, pdu, qosflows_to_add, qosflows_to_del, by):
    cmd = 'ue_pdu_session_modify'
    cmd += ' ue={}'.format(ue)
    cmd += ' pdu={}'.format(pdu)
    cmd += ' qosflows_to_add={}'.format(qosflows_to_add)
    if qosflows_to_del:
        cmd += ' qosflows_to_del={}'.format(qosflows_to_del)
    cmd += ' by={}'.format(by)
    logger_console('Modifying pdu session with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def define_bler(csi_profile_id, cqi_mode, cqi, ri_mode, ri, pmi_mode, pmi, bler_profile_id, dl_bler):
    cmd = 'csi_override_testmode_nr'
    cmd += ' profile_id={}'.format(csi_profile_id)
    cmd += ' cqi_mode={}'.format(cqi_mode)
    cmd += ' cqi={}'.format(cqi)
    cmd += ' ri_mode={}'.format(ri_mode)
    cmd += ' ri={}'.format(ri)
    cmd += ' pmi_mode={}'.format(pmi_mode)
    cmd += ' pmi={}'.format(pmi)
    logger_console('Defining csi override with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)

    cmd = 'bler_testmode_nr'
    cmd += ' profile_id={}'.format(bler_profile_id)
    cmd += ' dl_bler={}'.format(dl_bler)
    logger_console('Defining bler with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def trigger_bler_cmd(bler_info):
    cmd = 'ue_testmode_set_nr'
    cmd += ' id={}'.format(bler_info['id'])
    cmd += ' testmode={}'.format(bler_info['testmode'])
    cmd += ' action={}'.format(bler_info['action'])
    cmd += ' profile_id={}'.format(bler_info['profile_id'])
    logger_console('Triggering bler with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def attach_many_sa_ues_to_slice(ues_id, cell=None, ue_modify=None, slice=None, pdu=None, gw=None, wait_time=None,
                                beams_info=None):
    slices, pdu, gw = __set_slices_pdu_gw(len(ues_id), slice, pdu, gw)
    wait_time = _set_wait_time(wait_time, len(ues_id))
    beam_info = _set_beam_info(beams_info, len(ues_id))
    cells = _set_cells_info(cell, len(ues_id))
    ue_modify = _set_modify_pdu_session(ue_modify, len(ues_id))

    for ue in range(len(ues_id)):
        attach_one_sa_ues_to_slice(ue_id=ues_id[ue], cell=cells[ue], slice=slices[ue], pdu=pdu[ue], gw=gw[ue],
                                   beam=beam_info[ue], modify_pdu=ue_modify[ue])
        if wait_time[ue]:
            wait_for_tput_end_state(seconds=wait_time[ue], msg_info='Waiting for {} before attaching next ue')


def attach_many_sa_ues_to_slice_and_run_traffic(ues_id, ues_ip, tput=None, window=None, cell=None, ue_modify=None,
                                                slice=None, pdu=None, gw=None, wait_time=None, beams_info=None,
                                                duration_tput='1200'):
    slices, pdu, gw = __set_slices_pdu_gw(len(ues_id), slice, pdu, gw)
    wait_time = _set_wait_time(wait_time, len(ues_id))
    beam_info = _set_beam_info(beams_info, len(ues_id))
    cells = _set_cells_info(cell, len(ues_id))
    ue_modify = _set_modify_pdu_session(ue_modify, len(ues_id))

    for ue in range(len(ues_id)):
        attach_one_sa_ues_to_slice_and_run_traffic(ue_id=ues_id[ue], tput=tput, ue_ip=ues_ip[ue], window=window,
                                                   cell=cells[ue], slice=slices[ue], pdu=pdu[ue], gw=gw[ue],
                                                   beam=beam_info[ue], duration_tput=duration_tput,
                                                   modify_pdu=ue_modify[ue])
        if wait_time[ue]:
            wait_for_tput_end_state(seconds=wait_time[ue], msg_info='Waiting for {} before attaching next ue')


def attach_one_sa_ues_to_slice(ue_id, cell=None, slice=None, pdu=None, gw=None, beam=None, modify_pdu=None):
    slice = ue_id if not slice else slice
    pdu = ue_id if not pdu else pdu
    gw = ue_id if not gw else gw
    if beam:
        define_refine_beam(**beam)
    wts__.register_ue(ue_id=ue_id, cell_id=cell)
    wts__.establish_pdu_session(ue_id=ue_id, pdu_id=pdu, nwslice=slice, gw_id=gw)
    if modify_pdu:
        define_pdu_session_modification(**modify_pdu)


def attach_one_sa_ues_to_slice_and_run_traffic(ue_id, ue_ip, tput=None, window=None, cell=None, duration_tput='1200',
                                               slice=None, pdu=None, gw=None, beam=None, modify_pdu=None):
    attach_one_sa_ues_to_slice(ue_id, cell, slice, pdu, gw, beam, modify_pdu)
    if tput:
        traffic__.send_downlink_v2_iperf(duration_tput=duration_tput, dl_tput=tput, ue_ip=ue_ip)
    if window:
        start_dl_tcp_traffic_for_one_sa_ue(ue_ip=ue_ip, window=tput, duration=duration_tput)


def attach_one_sa_ue_to_slice(ue_id, cell=None, slice=None, pdu=None, gw=None):
    slice = ue_id if not slice else slice
    pdu = ue_id if not pdu else pdu
    gw = ue_id if not gw else gw

    wts__.register_ue(ue_id=ue_id, cell_id=cell)
    wts__.establish_pdu_session(ue_id=ue_id, pdu_id=pdu, nwslice=slice, gw_id=gw)


def attach_one_sa_ue_to_slice_and_run_dl_tcp_traffic(ue_id, ue_ip, cell, slice, pdu, gw, pdu_session_modify, window,
                                                     duration, wait_time=None):
    attach_one_sa_ue_to_slice(ue_id=ue_id, cell=cell, slice=slice, pdu=pdu, gw=gw)
    start_dl_tcp_traffic_for_one_sa_ue(ue_ip=ue_ip, window=window, duration=duration)
    if pdu_session_modify:
        define_pdu_session_modification(**pdu_session_modify)
    if wait_time:
        wait_for_tput_end_state(seconds=wait_time)


def attach_many_sa_ues_to_slice_and_run_dl_tcp_traffic(ue_ids, ue_ips, cell, slices, pdus, gws, pdu_sessions_modify,
                                                       window, duration, wait_time=None):
    for i in range(len(ue_ids)):
        attach_one_sa_ue_to_slice_and_run_dl_tcp_traffic(ue_id=ue_ids[i], cell=cell, slice=slices[i], pdu=pdus[i],
                                                         gw=gws[i], pdu_session_modify=pdu_sessions_modify[i],
                                                         ue_ip=ue_ips[i], window=window, duration=duration,
                                                         wait_time=wait_time)


def attach_many_sa_ues_to_slice_setup_bler_and_run_traffic(ues_id, tput, ues_ip, cell=None, duration_tput='15',
                                                           slices=None, pdu=None, gw=None, bler_info=None):
    if isinstance(cell, list) is False:
        cells = [cell for i in range(len(ues_id))]
    slices, pdu, gw = __set_slices_pdu_gw(len(ues_id), slices, pdu, gw)

    for ue in range(len(ues_id)):
        wts__.register_ue(ue_id=ues_id[ue], cell_id=cells[ue])

    define_bler(**bler_info)

    for ue in range(len(ues_id)):
        wts__.establish_pdu_session(ue_id=ues_id[ue], pdu_id=pdu[ue], nwslice=slices[ue], gw_id=gw[ue])
        traffic__.send_downlink_v2_iperf(duration_tput=duration_tput, dl_tput=tput, ue_ip=ues_ip[ue])


def attach_many_sa_ues_to_different_slices_and_run_traffic(ues_id, tput, ues_ip, cell=None, slices=None, pdu=None,
                                                           gw=None, duration_tput='1200', wait_time=None):
    slices, pdu, gw = __set_slices_pdu_gw(len(ues_id), slices, pdu, gw)
    if wait_time and (type(wait_time) is not list):
        wait_time = [wait_time for ue in range(len(ues_id))]

    for ue in range(len(ues_id)):
        attach_one_sa_ues_to_slice_and_run_traffic(ue_id=ues_id[ue], tput=tput, ue_ip=ues_ip[ue], cell=cell,
                                                   duration_tput=duration_tput, slice=slices[ue], pdu=pdu[ue],
                                                   gw=gw[ue])
        if wait_time:
            wait_for_tput_end_state(seconds=wait_time[ue], msg_info='Waiting for {} before attaching next ue')


def attach_one_sa_ue_to_different_slices(ue_id, slices, cell=None):
    pdu = [str(session+1) for session in range(len(slices))]
    gw = slices
    wts__.register_ue(ue_id=ue_id, cell_id=cell)
    for slice in range(len(slices)):
        wts__.establish_pdu_session(ue_id=ue_id, pdu_id=pdu[slice], nwslice=slices[slice], gw_id=gw[slice])


def attach_many_sa_ue_each_to_multiple_slices(ues_id, slices_lists, cell=None):
    for ue in range(len(ues_id)):
        attach_one_sa_ue_to_different_slices(ues_id[ue], slices_lists[ue], cell)


def attach_many_nsa_ues(ues_id, cell_id=1, bearer=None, plmn=None):
    enb_id = '1'
    gnb_id = '2'
    wts__.setup_x2_link(initiator_device=enb_id, complementary_device=gnb_id)
    bearer, plmn = __set_bearers_plmns(len(ues_id), bearer, plmn)
    for ue in range(len(ues_id)):
        wts__.attach_ue_to_plmn_and_perform_sgnb_addition(ue_id=ues_id[ue],
                                                          bearer=bearer[ue],
                                                          selected_plmn=plmn[ue],
                                                          serving_plmn=plmn[ue],
                                                          cell_id=int(cell_id))


def start_dl_traffic_for_many_ues(ue_ips, window, duration='200', wait_time=None):
    for ue in range(len(ue_ips)):
        traffic__.send_tcp_iperf(duration, window, ue_ip=ue_ips[ue])
    if not wait_time:
        wait_time = duration
    # logger_console_info('Wait for trafic to run for {}s'.format(wait_time))
    # time.sleep(int(wait_time))
    # traffic__.stop_uplink_iperf()


def establish_pdu_session_and_modify_it(nwslice, gw, pdu_session_modify):
    wts__.establish_pdu_session(ue_id=pdu_session_modify['ue'], pdu_id=pdu_session_modify['pdu'],
                                nwslice=nwslice, gw_id=gw)
    define_pdu_session_modification(**pdu_session_modify)


def start_dl_tcp_traffic_for_one_sa_ue(ue_ip, window, duration):
    traffic__.send_tcp_iperf(duration_tput=duration, window=window, ue_ip=ue_ip)


def stop_iperf():
    traffic__.stop_uplink_iperf()


def create_partnership_between_eNB_and_gNB_for_all_cells(egate_log):
    msg = 'Established connection with proxy to eNB'
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, msg)
    wts__.run_egate_cmd("enb_xp_param id=1 ignore_xp=off xp_listening_socket=on")
    wts__.run_egate_cmd("enb_xp_param id=1 xp_peers=2")
    wts__.run_egate_cmd("enb_xp_link_up enb=1 target=2")
    wts__.run_egate_cmd('set_log log_to_file=on')
    expected_msg = "XpAP Link with GNB-2"
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, expected_msg, timeout=180)
    wts__.run_egate_cmd('set_log log_to_file=on')
    expected_msg = "Cell-1 has No CRM Partnership created"
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, expected_msg)
    wts__.run_egate_cmd("enb_x2_link_up enb=1 target=2")
    wts__.run_egate_cmd("enb_dss_param id=1 feature_flag=on message_sets=DMS3")


def create_partnership_for_one_cell(egate_log, cell_lte, cell_5g, port):
    cmd = "enb_cell_param enb=1 id={} lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num={}".format(cell_lte, port)
    wts__.run_egate_cmd(cmd)
    wts__.run_egate_cmd("enb_cell_dss_feature enb=1 id={} nr_dl_peak_rate_increase=on".format(cell_lte))
    wts__.run_egate_cmd("enb_cell_dss_feature enb=1 id={} superfast_allocation=off ".format(cell_lte))
    wts__.run_egate_cmd("enb_dss_cell_param enb=1 id={} dl_resource_sharing_algo=dl_prb_load_based ".format(cell_lte))
    wts__.run_egate_cmd("enb_dss_configure_partnership enb=1 cell={} dss_peer=2:{}".format(cell_lte, cell_5g))
    time.sleep(30)
    cmd = "enb_crm_cell_resource_reservation enb=1 cell={} tgt_enb=2 tgt_cell={}".format(cell_lte, cell_5g)
    cmd += " assigned_dl_minimum_share_to_nr=30" \
           " assigned_dl_maximum_share_to_nr=70 assigned_dl_minimum_share_to_lte=15"
    cmd += " assigned_dl_maximum_share_to_lte=70" \
           " assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70"
    wts__.run_egate_cmd(cmd)
    wts__.run_egate_cmd("enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200")
    wts__.run_egate_cmd("enb_dss_establish_partnership enb=1 cell={} tgt_enb=2 tgt_cell={}".format(cell_lte, cell_5g))
    partenership_msg = "Cell {}: EN DSS DL Cell Resource Area Coordination success on remote NE".format(cell_5g)
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, partenership_msg, timeout=120)
    wts__.run_egate_cmd("enb_dss_cell_resource_reservation_dl enb=1 cell={} reset".format(cell_lte))
    cmd = "enb_dss_dl_resource_cell_reservation cell={} enb=1".format(cell_lte)
    cmd += " prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none"
    wts__.run_egate_cmd(cmd)
    cmd = "enb_dss_dl_resource_cell_reservation cell={} enb=1 reserved_fixed_normal_subframes=0000000000-"\
        .format(cell_lte)
    cmd += "0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000"
    wts__.run_egate_cmd(cmd)
    cmd = "enb_dss_dl_resource_cell_reservation cell={} enb=1 min_lte_nr_dss_ratio=30".format(cell_lte)
    cmd += " max_lte_nr_dss_ratio=100"
    wts__.run_egate_cmd(cmd)
    cmd = "enb_dss_cell_resource_coordination enb=1 cell={} tgt_enb=2 tgt_cell={} dir=DL".format(cell_lte, cell_5g)
    wts__.run_egate_cmd(cmd)
    partenership_msg = "Cell 1: Update Indication : "
    partenership_msg += "EN DSS DL Cell Resource Area Coordination: both NEs synchronized"
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, partenership_msg)
    cmd = "enb_dss_ul_resource_cell_reservation cell={} enb=1 minimum_prb_share=30 maximum_prb_share=70"\
        .format(cell_lte)
    wts__.run_egate_cmd(cmd)
    cmd = "enb_dss_cell_resource_coordination enb=1 cell={} tgt_enb=2 tgt_cell={} dir=UL".format(cell_lte, cell_5g)
    wts__.run_egate_cmd(cmd)
    partenership_msg = "Cell 1: Update Indication : "
    partenership_msg += "EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized"
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, partenership_msg)
    cmd = "enb_dss_resource_allocation enb=1 cell={} tgt_enb=2 tgt_cell={} dir=DL allocation_start_"\
        .format(cell_lte, cell_5g)
    cmd += "time=immediate dl_allocated_normal_subframes=0111101110-0111101110-0111101110-0111101110-0111101110-"
    cmd += "0111101110-0111101110-0111101110"
    cmd += " dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,"
    cmd += "106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:"
    cmd += "0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+3"
    cmd += "3:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106"
    cmd += "+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,1"
    cmd += "06+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0"
    cmd += ",106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106"
    wts__.run_egate_cmd(cmd)
    partenership_msg = "Cell {}: Received DSS DL Resource Area Allocation Response SequenceNumber=0".format(cell_5g)
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, partenership_msg)
    cmd = "enb_dss_resource_allocation enb=1 cell={} tgt_enb=2 tgt_cell={} dir=UL allocation_start_"\
        .format(cell_lte, cell_5g)
    cmd += "time=immediate ul_allocated_prb_list=0,3|5,70|103,3"
    wts__.run_egate_cmd(cmd)
    partenership_msg = "Cell {}: Received EN DSS UL Qos Load Indication SequenceNumber=0"\
        .format(cell_5g)
    wts__.run_egate_cmd('set_log log_to_file=on')
    check_egate_log_in_real_time(egate_log, partenership_msg)


def create_partnership_for_many_cells(egate_log, cell_lte_list, cell_5g_list, port):
    for cell_lte, cell_5g in enumerate(cell_5g_list):
        create_partnership_for_one_cell(egate_log, cell_lte_list[cell_lte], cell_5g, port)


def wait_for_sib_for_all_cells(sib_reception_list, egate_log):
    for sib in sib_reception_list:
        wts__.wait_for_information_block_reception(sib_reception_dict=sib)
    old_msges = BuiltIn().get_variable_value('${MSG_TO_CHECK}')
    if old_msges is not None:
        check_old_msg_in_egate_log(egate_log, old_msges)


def set_internal_pdu_session(ue_id, pdu_id):
    command = "set_pdu_param ue={} pdu={} trf_type=internal".format(ue_id, pdu_id)
    wts__.run_egate_cmd(cmd=command)


def set_internal_pdu_session_multi_ue(ues_id, pdus_id):
    for ue_id in range(len(ues_id)):
        set_internal_pdu_session(ue_id=ues_id[ue_id], pdu_id=pdus_id[ue_id])


def set_multiple_internal_pdu_sessions_per_ue(ue_id, pdus_id):
    for pdu_id in range(len(pdus_id)):
        set_internal_pdu_session(ue_id, pdus_id[pdu_id])


def attach_multi_ue(ues_id, pdus_id, nwslices, cell_id=None):
    for ue_id in range(len(ues_id)):
        wts__.attach_ue_and_establish_pdu_session(ue_id=ues_id[ue_id], pdu=pdus_id[ue_id], nwslice=nwslices[ue_id],
                                                  cell_id=cell_id)


def smf_param_qos(qos_to_activate, smf_id=1):
    cmd = 'smf_param additional_qosflows_to_activate={} id={}'.format(qos_to_activate, smf_id)
    wts__.run_egate_cmd(cmd)


def run_internal_traffic_multi_ue(ues_id, pdus_id, tput, wait_time=None):
    tput = int(tput)
    num_of_inst = math.floor(tput / 175)

    if num_of_inst == 0:
        for ue_id in range(len(ues_id)):
            wts__.start_data_traffic_in_egate(ue_id=ues_id[ue_id], pdu=pdus_id[ue_id], trf_id=1, direction='dl',
                                              mbps=tput)

    else:
        for ue_id in range(len(ues_id)):
            for num in range(1, num_of_inst + 2):
                wts__.start_data_traffic_in_egate(ue_id=ues_id[ue_id], pdu=pdus_id[ue_id], trf_id=num, direction='dl',
                                                  mbps=175)
    if wait_time:
        wait_for_tput_end_state(seconds=wait_time, msg_info='Waiting for {} before validation')


def run_traffic_multi_ue_nsa(ues_id, mbps, bearers_id):
    mbps = int(mbps)
    num_of_inst = math.floor(mbps / 175)

    if num_of_inst == 0:
        for ue_id in range(len(ues_id)):
            wts__.start_data_traffic_in_egate(ue_id=ues_id[ue_id], direction='dl', mbps=mbps, bearer=bearers_id[ue_id],
                                              trf_id=1, net_arch='nsa')
    else:
        for ue_id in range(len(ues_id)):
            for num in range(1, num_of_inst + 2):
                wts__.start_data_traffic_in_egate(ue_id=ues_id[ue_id], direction='dl', mbps=175,
                                                  bearer=bearers_id[ue_id], trf_id=num, net_arch='nsa')
