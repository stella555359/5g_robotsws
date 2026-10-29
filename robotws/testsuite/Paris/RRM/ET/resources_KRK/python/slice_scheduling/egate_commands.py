
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import re
import testsuite.Paris.RRM.ET.resources_KRK.python.common_wts as wts__
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console


def define_beam_testmode(profile_id, ue_testmode_set_nr_id, testmode, action, beamaction, beam_type):
    cmd = ' ue_testmode_set_nr id={}'.format(ue_testmode_set_nr_id)
    cmd += ' testmode={}'.format(testmode)
    cmd += ' action={}'.format(action)
    cmd += ' profile_id={}'.format(profile_id)
    cmd += ' beamaction={}'.format(beamaction)
    logger_console('Setting UE to {} beam with command: {}'.format(beam_type, cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def define_refine_beam(profile_id, ue_beam_index_initial, csirs_bestbeam, csirs_rsrp_best, csirs_rsrp_avg,
                       ue_testmode_set_nr_id, testmode, action, beamaction, beam_type="refined"):
    cmd = 'beam_control_testmode_nr'
    cmd += ' profile_id={}'.format(profile_id)
    cmd += ' ueBeamIndexInitial={}'.format(ue_beam_index_initial)
    cmd += ' csirs_bestbeam={}'.format(csirs_bestbeam)
    cmd += ' csirs_rsrp_best={}'.format(csirs_rsrp_best)
    cmd += ' csirs_rsrp_avg={}'.format(csirs_rsrp_avg)
    logger_console('Defining refined beam with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)

    define_beam_testmode(profile_id, ue_testmode_set_nr_id, testmode, action, beamaction, beam_type)


def define_ssb_beam(profile_id, ue_beam_index_initial, ssbeam_bestbeam, ssbeam_rsrp_best, ssbeam_rsrp_avg,
                    ue_testmode_set_nr_id, testmode, action, beamaction, beam_type="SSB"):
    cmd = 'beam_control_testmode_nr'
    cmd += ' profile_id={}'.format(profile_id)
    cmd += ' ueBeamIndexInitial={}'.format(ue_beam_index_initial)
    cmd += ' ssbeam_bestbeam={}'.format(ssbeam_bestbeam)
    cmd += ' ssbeam_rsrp_best={}'.format(ssbeam_rsrp_best)
    cmd += ' ssbeam_rsrp_avg={}'.format(ssbeam_rsrp_avg)
    logger_console('Defining SSB beam with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)

    define_beam_testmode(profile_id, ue_testmode_set_nr_id, testmode, action, beamaction, beam_type)


def define_srs_beam_position(profile_id=1, init_pos=None, srs_mode=None):
    cmd = f'ue_srs_beam_pos_nr'
    cmd = f'{cmd} profile_id={profile_id}'

    if init_pos:
        cmd = f'{cmd} init_pos={init_pos}'
    if srs_mode:
        cmd = f'{cmd} init_pos={srs_mode}'
    logger_console('Defining srs beam position with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def ue_ta_nr(profile_id=1, delete=None, nb_reps_ta_sim=None, ue_speed=None, ue_p_delay_max=None, ue_p_delay_min=None,
             ue_p_delay_initial=None, ue_fo_velocity=None, ue_p_symbol_delay_initial=None):
    cmd = f'ue_ta_nr profile_id={profile_id}'
    if delete:
        cmd += f' delete={delete}'
    if nb_reps_ta_sim:
        cmd += f' nb_reps_ta_sim={nb_reps_ta_sim}'
    if ue_speed:
        cmd += f' ue_speed={ue_speed}'
    if ue_p_delay_max:
        cmd += f' ue_p_delay_max={ue_p_delay_max}'
    if ue_p_delay_min:
        cmd += f' ue_p_delay_min={ue_p_delay_min}'
    if ue_p_delay_initial:
        cmd += f' ue_p_delay_initial={ue_p_delay_initial}'
    if ue_fo_velocity:
        cmd += f' ue_fo_velocity={ue_fo_velocity}'
    if ue_p_symbol_delay_initial:
        cmd += f' ue_p_symbol_delay_initial={ue_p_symbol_delay_initial}'
    logger_console('Defining UE TA with command: '.format(cmd))
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


def csi_override_testmode_nr(csi_profile_id, cqi_mode=None, cqi=None, cqi_min=None, cqi_max=None, cqi_step=None,
                             cqi_period=None, ri_mode=None, ri=None, pmi_mode=None, pmi=None):
    cmd = f'csi_override_testmode_nr profile_id={csi_profile_id}'
    if cqi_mode:
        cmd += f' cqi_mode={cqi_mode}'
    if cqi:
        cmd += f' cqi={cqi}'
    if cqi_min:
        cmd += f' cqi_min={cqi_min}'
    if cqi_max:
        cmd += f' cqi_max={cqi_max}'
    if cqi_step:
        cmd += f' cqi_step={cqi_step}'
    if cqi_period:
        cmd += f' cqi_period={cqi_period}'
    if ri_mode:
        cmd += f' ri_mode={ri_mode}'
    if ri:
        cmd += f' ri={ri}'
    if pmi_mode:
        cmd += f' pmi_mode={pmi_mode}'
    if pmi:
        cmd += f' pmi={pmi}'
    logger_console('Defining csi override with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def trigger_bler_cmd(bler_info):
    cmd = 'ue_testmode_set_nr'
    cmd += ' id={}'.format(bler_info['id'])
    cmd += ' testmode={}'.format(bler_info['testmode'])
    cmd += ' action={}'.format(bler_info['action'])
    cmd += ' profile_id={}'.format(bler_info['profile_id'])
    logger_console('Triggering bler with command: '.format(cmd))
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def script(file, ue=None, ignore=None, noexec=None, entry=None):
    """Triggers egate command: script. Takes parameters:
       Required parameters:
       :param file: str, script filename
       Additional parameters:
       :param ue: scripted UE identifier(s), available options 1..25000+
       :param ignore: ignore errors, available values on|off, default 0
       :param noexec: not execute, just check syntax, available values on|off, default 0
       :param noexec: entry function in Lua script, available values string up to 1024 symbols

       Executes script from a file
    """
    cmd = f'script file={file}'
    if ue:
        cmd = f'{cmd} ue={ue}'
    if ignore:
        cmd = f'{cmd} ignore={ignore}'
    if noexec:
        cmd = f'{cmd} noexec={noexec}'
    if entry:
        cmd = f'{cmd} entry={entry}'
    logger_console(f'Starting script with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def ul_cell_noise_testmode_nr(profile_id=1, delete=None, noise_pusch=None, noise_pucch=None, noise_prach=None,
                              noise_srs=None):
    """Triggers egate command: ul_cell_noise_testmode_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       Additional parameters:
       :param delete: delete the test profile, available options - yes|no; true|false; 1|0; on|off; set on true
       :param noise_pusch: Applied to PUSCH channel between AP l2 L1 Interface for all UEs in a Cell, [unit:dBFS],
                           available values -1053..-90
       :param noise_pucch: Applied to PUCCH channel between AP l2 L1 Interface for all UEs in a Cell, [unit:dBFS],
                           available values -1053..-90
       :param noise_prach: Applied to PRACH channel per UE for a given Cell, [unit:dBFS],
                           available values -1053..-90
       :param noise_srs: Applied to SRS channel per UE for a given Cell, [unit:dBFS], available values -1053..-90
       Note:
       Cell Noise used dBFS based units and gNB estimates the noise in the channel and reports in dBM units.
       Please find below an example of dBFS units (to be used in the command) and gNBs (estimated value)
       This table is just for a “ball park” co-relation which can be used to decide on the values to be used:
        1. dBFS ( -300 ) =>  -64 (dBm)
        2. dBFS ( -600 )  =>  -94 (dBm)
        3. dBFS (-900 )   =>  -122 (dBm)
       When different channels or UEs with different noise powers are multiplexed in the same OFDM symbol,
       the same power shall be applied to all the PRBs in the bandwidth.
       The noise power parameter must be the same for the multiplexed channels and UEs.
       When different powers are used, the power for the last processed L2 message shall be applied.
       https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1104199524#
       AirphoneRestrictionsAPoverABIO-NoiseGeneration
        Examples:
        - Configure Ul cell noise TestMode NR with all parameters:
            ul_cell_noise_testmode_nr profile_id=1  noise_pusch=-600 noise_pucch=-610 noise_prach=-620 noise_srs=-630
            ul_cell_noise_testmode_nr profile_id=2  noise_pusch=-610 noise_pucch=-600 noise_prach=-630 noise_srs=-620
        - Configure UL CELL NOISE TestMode NR with noise_pusch:
            ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-610
        - Configure UL CELL NOISE TestMode NR with noise_pucch:
            ul_cell_noise_testmode_nr profile_id=4 noise_pucch=-610
        - Configure UL CELL NOISE TestMode NR with noise_prach:
            ul_cell_noise_testmode_nr profile_id=4 noise_prach=-620
        - Configure UL CELL NOISETestMode NR with noise_srs:
            ul_cell_noise_testmode_nr profile_id=4 noise_srs=-650
        - Modify UL CELL NOISE TestMode NR:
            ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-650 noise_pucch=-660 noise_prach=-670 noise_srs=-680
        - Dispaly configured UL CELL NOISE TestMode NR:
            ul_cell_noise_testmode_nr profile_id=2
    """
    cmd = f'ul_cell_noise_testmode_nr profile_id={profile_id}'
    if delete:
        cmd = f'{cmd} delete={delete}'
        logger_console(f'Deleting UL CELL NOISE parameters with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    if noise_pusch:
        cmd = f'{cmd} noise_pusch={noise_pusch}'
    if noise_pucch:
        cmd = f'{cmd} noise_pucch={noise_pucch}'
    if noise_prach:
        cmd = f'{cmd} noise_prach={noise_prach}'
    if noise_srs:
        cmd = f'{cmd} noise_srs={noise_srs}'
    if __check_if_only_show(cmd):
        logger_console(f'Showing online UL CELL NOISE parameters with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    logger_console(f'Updating online UL CELL NOISE parameters with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)
    return


def set_ul_sinr_testmode_nr(profile_id=1, delete=None, sinr_target_srs=None, sinr_target_pusch=None,
                            sinr_target_pucch=None, sinr_target_preamble=None, noise_pusch=None, noise_pucch=None,
                            noise_prach=None, noise_srs=None, pathloss=None, pcmax=None, pusch_tx_power=None,
                            phr_value_offset=None, srs_tx_power=None, alpha=None):
    """Triggers egate command: cell_testmode_set_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       Additional parameters:
       :param delete: delete the test profile, available options - yes|no; true|false; 1|0; on|off; set on true
       :param sinr_target_srs: basic UL_SINR param: sinr_target_srs used for SRS transmit power,
                               available values -600..600
       :param sinr_target_pusch: basic UL_SINR param: sinr_target_pusch value for PUSCH, available values -600..600
       :param sinr_target_pucch: basic UL_SINR param: sinr_target_pucch value for PUCCH, available values -600..600
       :param sinr_target_preamble: basic UL_SINR param: sinr_target_preamble value for SRS channel,
                                    available values -600..600
       :param noise_pusch: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param noise_pucch: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param noise_prach: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param noise_srs: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param pathloss: advance UL_SINR param: pathloss value in dB, this is mandatory when configuring Advanced Ul
                        Sinr Test profile, available values 28..164
       :param pcmax: advance UL_SINR param: pcmax, Power in dBm, available values -30..33
       :param pusch_tx_power: advance UL_SINR param: pusch_tx_power, available values -851..0
       :param phr_value_offset: advance UL_SINR param: phr_value_offset, available values -30..30
       :param srs_tx_power: advance UL_SINR param: srs_tx_power, available values -851..0
       :param alpha: advance UL_SINR param, defined Alpha ::= ENUMERATED {alpha0, alpha04, alpha05, alpha06, alpha07,
                     alpha08, alpha09, alpha1}, available values 0..100
       Examples:
       - Configure basic UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1 sinr_target_srs=100 sinr_target_pusch=200 sinr_target_pucch=300
       - Modify UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1 sinr_target_srs=0 sinr_target_pusch=300 sinr_target_pucch=-300
       - Configure advanced UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=2 pathloss=28 pcmax=30
       - Delete UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1 delete=1
       - Dispaly configured UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1
    """
    cmd = f'ul_sinr_testmode_nr profile_id={profile_id}'
    if delete:
        cmd = f'{cmd} delete={delete}'
        logger_console(f'Deleting UL-SINR TestMode NR with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    if sinr_target_srs:
        cmd = f'{cmd} sinr_target_srs={sinr_target_srs}'
    if sinr_target_pusch:
        cmd = f'{cmd} sinr_target_pusch={sinr_target_pusch}'
    if sinr_target_pucch:
        cmd = f'{cmd} sinr_target_pucch={sinr_target_pucch}'
    if sinr_target_preamble:
        cmd = f'{cmd} sinr_target_preamble={sinr_target_preamble}'
    if noise_pusch:
        cmd = f'{cmd} noise_pusch={noise_pusch}'
    if noise_pucch:
        cmd = f'{cmd} noise_pucch={noise_pucch}'
    if noise_prach:
        cmd = f'{cmd} noise_prach={noise_prach}'
    if noise_srs:
        cmd = f'{cmd} noise_srs={noise_srs}'
    else:
        logger_console(f'Showing online Advance and Basic UlSinr parameters with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    logger_console(f'Updates online Advance and Basic UlSinr parameters with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def ul_mimo_switch_nr(profile_id=1, delete=None, pusch_tx_mix_ratio=None, srs_tx_mix_ratio=None):
    """Triggers egate command: ul_mimo_switch_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       Additional parameters:
       :param delete: delete the test profile, available options - yes|no; true|false; 1|0; on|off; set on true
       :param pusch_tx_mix_ratio: 0 value sent in the Pusch_sendreq to AP layer 1 will NOT enable any logic at AP Layer
                                  1 for this command, available values 0..100
       :param srs_tx_mix_ratio: 0 value sent in the Srs_sendreq to AP layer 1 will NOT enable any logic at AP Layer
                                  1 for this command, available values 0..100
        Examples:
        - Configure UL MIMO SWITCH TestMode NR with all parameters:
            ul_mimo_switch_nr profile_id=1 pusch_tx_mix_ratio=40 srs_tx_mix_ratio=50
            ul_mimo_switch_nr profile_id=1 pusch_tx_mix_ratio=50 srs_tx_mix_ratio=30
        - Configure UL MIMO SWITCH TestMode NR with pusch_tx_mix_ratio:
            ul_mimo_switch_nr profile_id=1 pusch_tx_mix_ratio=40
        - Configure UL MIMO SWITCH TestMode NR with srs_tx_mix_ratio:
            ul_mimo_switch_nr profile_id=1 srs_tx_mix_ratio=40
    """
    cmd = f'ul_mimo_switch_nr profile_id={profile_id}'
    if delete:
        cmd = f'{cmd} delete={delete}'
    if pusch_tx_mix_ratio:
        cmd = f'{cmd} pusch_tx_mix_ratio={pusch_tx_mix_ratio}'
    if srs_tx_mix_ratio:
        cmd = f'{cmd} srs_tx_mix_ratio={srs_tx_mix_ratio}'
    logger_console(f'Switching ul mimo parameters with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def phr_override_testmode_nr(profile_id=1, delete=None, phr_mode=None, phr_start=None, phr_min=None, phr_max=None,
                             phr_step_size=None, phr_period=None, pc_max=None):
    """Triggers egate command: phr_override_testmode_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       Additional parameters:
       :param delete: delete the test profile, available options - yes|no; true|false; 1|0; on|off; set on true
       :param phr_mode: FIXED - phr value shall be overwritten using the phr_start. ONEWAY - phr value shall start
                        increasing/decreasing from phr_start until phr_max/phr_min. OSCILLATING - phr value shall
                        oscillate between phr_min and phr_max, Default_Value : FIXED
       :param phr_start: starting powerHeadroomLevel value for any pattern, available values -33..40, set on 0
       :param phr_min: lower limit of powerHeadroomLevel in the pattern, available values -33..40, set on -23
       :param phr_max: upper limit powerHeadroomLevel in the pattern, available values -33..40, set on 40
       :param phr_step_size: The difference of powerHeadroomLevel between steps, available values -63..63, set on 0
       :param phr_period: The number of power headroom report(s) before powerHeadroomLevel shall change/move to
                          the next step, available values 1..255, set on 1
       :param pc_max: Nominal UE transmission power level, phr_mode is to be ignored for pcmax, available values
                      -30..33, set on 0
       Examples:
       - Configure Phr Override TestMode NR with all parameters:
        phr_override_testmode_nr profile_id=1 phr_mode=Oneway phr_start=-23phr_min=-23 phr_max=40 phr_step_size=1
        phr_period=20 pc_max=30
       - Dispaly configured Phr Override TestMode NR:
        phr_override_testmode_nr profile_id=1
       - Modify Phr Override TestMode NR:
        phr_override_testmode_nr profile_id=1 phr_mode=Fixed
       - Delete Phr Override TestMode NR:
        phr_override_testmode_nr profile_id=1 delete=true
       - For Fixed Mode Phr_start is mandate which we are giving by default:
        phr_override_testmode_nr profile_id=1 phr_mode=Fixed
       - For Oneway and Oscillation : phr_max should be greater than phr_min:
        phr_override_testmode_nr profile_id=1 phr_mode=Oneway phr_min=-23 phr_max=40
       - For Oneway and Oscillation : phr_start should be between phr_min and phr_max:
        phr_override_testmode_nr profile_id=1 phr_mode=Oneway phr_start=-24 phr_min=-23 phr_max=40
       - For Oneway and Oscillation : phr_start, phr_min, phr_max, phr_step_size and phr_period are mandatory which
       will be recived by default:
        phr_override_testmode_nr profile_id=1 phr_mode=Oneway
        OUTPUT:
        CTRL_AP_TEST_PHR_OVERRIDE_NR for profileId=1 delete=0 phrLevelMode=1 phrLevelStart=0 phrLevelMin=-2300
        phrLevelMax=4000 phrLevelStepSize=0 phrLevelPeriod=1 pcMax=0

        Updates online Phr parameters.
    """
    cmd = f'phr_override_testmode_nr profile_id={profile_id}'
    if delete:
        cmd = f'{cmd} delete={delete}'
        logger_console(f'Deleting Phr TestMode NR with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    if phr_mode:
        cmd = f'{cmd} phr_mode={phr_mode}'
    if phr_start:
        cmd = f'{cmd} phr_start={phr_start}'
    if phr_min:
        cmd = f'{cmd} phr_min={phr_min}'
    if phr_max:
        cmd = f'{cmd} phr_max={phr_max}'
    if phr_step_size:
        cmd = f'{cmd} phr_step_size={phr_step_size}'
    if phr_period:
        cmd = f'{cmd} phr_period={phr_period}'
    if pc_max:
        cmd = f'{cmd} pc_max={pc_max}'
    if __check_if_only_show(cmd):
        logger_console(f'Showing online Phr parameters with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    logger_console(f'Updates online Phr parameters with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def ue_srs_beam_pos_nr(profile_id=1, delete=None, srsMode=None, init_pos=None, final_pos=None, step_count=None,
                       dtx_start=None, num_dtx=None):
    """Triggers egate command: ue_srs_beam_pos_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       Additional parameters:
       :param delete: delete the test profile, available options - yes|no; true|false; 1|0; on|off; set on true
       :param srsMode: (str), List of Modes supported:
        - fixed	- Fixed UE position is defined by InitPos only
        - single - Ue position will be changed ONCE after stepCount
        - oneway - As many changes of the UE position between Inital and Final defined by Step size for each
                   UE position change to be triggered
        - oscillating - Never Ending changes of the UE position till profile is active for the UE defined by
                   Step size for each UE position change to be triggered
        available values oscillating, oneway, single, fixed
       :param init_pos: UE position based on 4 possible positions in a cell. Pos = 0 is the default position,
                        available values 0..3
       :param final_pos: UE position based on 4 possible positions in a cell. Used for modes which dynamically
                         will change the UE Position, available values 0..3
       :param step_count: mandatory value for modes other than fixed. Used to change the UE Position towards L1,
                          available values 1..1024
       :param dtx_start: This will trigger not responding to periodic SRS send request, available values 0..255
       :param num_dtx: The value will determine how many times SRSSendReq will not be 'responded' towards AP l1
                       in a Periodic SRS configuration, available values 0..255
       Examples:
       - Configure UE SRS BEAM POS TestMode NR with all parameters with single mode:
        ue_srs_beam_pos_nr profile_id=1 init_pos=1 final_pos=2 step_count=200 dtx_start=100 num_dtx=50 srsMode=single
       - Configure UE SRS BEAM POS TestMode NR with FIXED mode:
        ue_srs_beam_pos_nr profile_id=4 init_pos=1 dtx_start=100 num_dtx=50 srsMode=fixed
       - Configure UE SRS BEAM POS TestMode NR with stepCount:
        ue_srs_beam_pos_nr profile_id=4 step_count=200
       - Modify UE SRS BEAM POS TestMode NR:
        ue_srs_beam_pos_nr profile_id=1 init_pos=2 final_pos=3 step_count=250 dtx_start=140 num_dtx=100 srsMode=fixed
       - Dispaly configured UE SRS BEAM POS TestMode NR:
        ue_srs_beam_pos_nr profile_id=1
    """
    cmd = f'ue_srs_beam_pos_nr profile_id={profile_id}'
    if delete:
        cmd = f'{cmd} delete={delete}'
        logger_console(f'Deleting UL-SINR TestMode NR with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    if srsMode:
        cmd = f'{cmd} srsMode={srsMode}'
    if init_pos:
        cmd = f'{cmd} init_pos={init_pos}'
    if final_pos:
        cmd = f'{cmd} final_pos={final_pos}'
    if step_count:
        cmd = f'{cmd} step_count={step_count}'
    if dtx_start:
        cmd = f'{cmd} dtx_start={dtx_start}'
    if num_dtx:
        cmd = f'{cmd} num_dtx={num_dtx}'
    if __check_if_only_show(cmd):
        logger_console(f'Showing online UE SRS BEAM POS parameters with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    logger_console(f'Updates online UE SRS BEAM POS parameters with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def ul_sinr_testmode_nr(profile_id=1, delete=None, sinr_target_srs=None, sinr_target_pusch=None,
                        sinr_target_pucch=None, sinr_target_preamble=None, noise_pusch=None, noise_pucch=None,
                        noise_prach=None, noise_srs=None, pathloss=None, pcmax=None, pusch_tx_power=None,
                        phr_value_offset=None, srs_tx_power=None, alpha=None):
    """Triggers egate command: ul_sinr_testmode_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       Additional parameters:
       :param delete: delete the test profile, available options - yes|no; true|false; 1|0; on|off; set on true
       :param sinr_target_srs: basic UL_SINR param: sinr_target_srs used for SRS transmit power,
                               available values -600..600
       :param sinr_target_pusch: basic UL_SINR param: sinr_target_pusch value for PUSCH, available values -600..600
       :param sinr_target_pucch: basic UL_SINR param: sinr_target_pucch value for PUCCH, available values -600..600
       :param sinr_target_preamble: basic UL_SINR param: sinr_target_preamble value for SRS channel,
                                    available values -600..600
       :param noise_pusch: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param noise_pucch: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param noise_prach: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param noise_srs: This parameter is deprecated in this command, Use ul_cell_noise_testmode_nr to set the value,
                           available values -1053..-90
       :param pathloss: advance UL_SINR param: pathloss value in dB, this is mandatory when configuring Advanced Ul
                        Sinr Test profile, available values 28..164
       :param pcmax: advance UL_SINR param: pcmax, Power in dBm, available values -30..33
       :param pusch_tx_power: advance UL_SINR param: pusch_tx_power, available values -851..0
       :param phr_value_offset: advance UL_SINR param: phr_value_offset, available values -30..30
       :param srs_tx_power: advance UL_SINR param: srs_tx_power, available values -851..0
       :param alpha: advance UL_SINR param, defined Alpha ::= ENUMERATED {alpha0, alpha04, alpha05, alpha06, alpha07,
                     alpha08, alpha09, alpha1}, available values 0..100
       Examples:
       - Configure basic UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1 sinr_target_srs=100 sinr_target_pusch=200 sinr_target_pucch=300
        sinr_target_preamble=300
       - Modify UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1 sinr_target_srs=0 sinr_target_pusch=300 sinr_target_pucch=-300
        sinr_target_preamble=200
       - Configure advanced UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=2 pathloss=28 pcmax=30
       - Delete UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1 delete=1
       - Dispaly configured UL-SINR TestMode NR:
        ul_sinr_testmode_nr profile_id=1
    """
    cmd = f'ul_sinr_testmode_nr profile_id={profile_id}'
    if delete:
        cmd = f'{cmd} delete={delete}'
        logger_console(f'Deleting UL-SINR TestMode NR with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    if sinr_target_srs:
        cmd = f'{cmd} sinr_target_srs={sinr_target_srs}'
    if sinr_target_pusch:
        cmd = f'{cmd} sinr_target_pusch={sinr_target_pusch}'
    if sinr_target_pucch:
        cmd = f'{cmd} sinr_target_pucch={sinr_target_pucch}'
    if sinr_target_preamble:
        cmd = f'{cmd} sinr_target_preamble={sinr_target_preamble}'
    if noise_pusch:
        cmd = f'{cmd} noise_pusch={noise_pusch}'
    if noise_pucch:
        cmd = f'{cmd} noise_pucch={noise_pucch}'
    if noise_prach:
        cmd = f'{cmd} noise_prach={noise_prach}'
    if noise_srs:
        cmd = f'{cmd} noise_srs={noise_srs}'
    if __check_if_only_show(cmd):
        logger_console(f'Showing online Advance and Basic UlSinr parameters with command: {cmd}')
        wts__.run_egate_cmd_and_wait_for_data(cmd)
        return
    logger_console(f'Updates online Advance and Basic UlSinr parameters with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def cell_testmode_set_nr(profile_id=1, cell_id=1, testmode=1, gnb=None, action=None):
    """Triggers egate command: cell_testmode_set_nr. Takes parameters:
       Required parameters:
       :param profile_id: test profile id, available values 1..255
       :param cell_id: local identifier for a cell or cell_id=all for all cells, available values all or 1..257
       :param testmode: testmode to be used,
                        available values ul_cell_noise|cell_srs_beam_pos|remote_interference|rim_rs|ul_cell_power
       Additional parameters:
       :param gnb: local identifier for gNodeB, available values all or 1..254
       :param action: triggers the activation or the deactivation of the test mode,
                      available values all activate/deactivate
       Note for associating cell_srs_beam_pos::
        For NSA : Before ue_attach procedure -> Please create a profile using cell_srs_beam_pos_nr
        and use cell_testmode_set_nr to associate the a profile with cell. Then proceed to ue_attach.
        For SA : Please create a profile using cell_srs_beam_post_nr and use cell_testmode_set_nr
        to associate the a profile with cell. Both commands can be added in basic_setup.cfg configuration file,
        just before the log level setup.
       Note for updating existing cell_srs_beam_pos  profile values or updating cell_testmode_set_nr command:
        Please update the profile and associate it using cell_testmode_set_nr. Perform a Cell Lock-Unlock so
        the new values are updated at AP L1.
       Examples:
       - Associate new testmode profile to cell before attach/after attach:
        cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=1 action=activate
        cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=1 action=deactivate
       - Associate new testmode cell_srs_beam_pos to cell:
        cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
        cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_power profile_id=1 action=deactivate
    """
    cmd = f'cell_testmode_set_nr cell_id={cell_id}'
    if gnb:
        cmd = f'{cmd} gnb={gnb}'
    cmd = f'{cmd} testmode={testmode} profile_id={profile_id}'
    if action:
        cmd = f'{cmd} action={action}'
    logger_console(f'Associating Cells to testmode with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def ue_testmode_set_nr(testmode, id=1, profile_id=1, scell=None, beamaction=None, action=None, cell_group=None):
    """Triggers egate command: ue_testmode_set_nr. Takes parameters:
       Required parameters:
       :param id: specified UE ID, available values 1..25000+
       :param profile_id: test profile id, available values 1..255
       :param testmode: testmode to be used,
                        available values: rlf|bler|ta|pwr_ctrl|ul_sinr|beam_control|srs_uplink_beamforming|phr_override
            |contention_resolution|csi_override|forced_dtx|ue_srs_beam_pos|ul_mimo_switch_nr|mac|dlrlcdrop|
            |ul_mimo_srs_beam_pos|bwp|configured_grant|mue_prach_control|pusch_power_control|ul_rrh_power_contol
       Additional parameters:
       :param scell: carrier aggregation serving cell (carrier component, CC),
                     available values 0..31+ or {primary,secondary}
       :param beamaction: beamaction is triggered only during BeamControlTestMode,
                      available values attach|switch|recovery
       :param action: triggers the activation or the deactivation of the test mode,
                      available values all activate/deactivate
       :param cell_group: cell group type MCG/SCG is applicable only for NR-DC SA case,
                     available values DEFAULT|MCG|SCG
       Examples:
       - Associate new testmode profile to UE before attach/after attach:
        ue_testmode_set_nr id=1 scell=1 testmode=bler action=activate
        ue_testmode_set_nr id=1,2 scell=1,2,31 testmode=bler action=activate
        ue_testmode_set_nr id=1 scell=primary testmode=bler action=activate
        ue_testmode_set_nr id=1 scell=secondary testmode=bler action=activate
        ue_testmode_set_nr id=1 testmode=bler profile_id=1
    """
    cmd = f'ue_testmode_set_nr id={id}'
    cmd = f'{cmd} testmode={testmode}'
    if profile_id:
        cmd = f'{cmd} profile_id={profile_id}'
    if scell:
        cmd = f'{cmd} scell={scell}'
    if beamaction:
        cmd = f'{cmd} beamaction={beamaction}'
    if action:
        cmd = f'{cmd} action={action}'
    if cell_group:
        cmd = f'{cmd} cell_group={cell_group}'
    logger_console(f'Associating UEs to testmode with command: {cmd}')
    wts__.run_egate_cmd_and_wait_for_data(cmd)


def change_radio_conditions(mimo_info, ue_test_info, noise_info, cell_test_info):
    """Triggers egate commands: ue_testmode_set_nr, cell_testmode_set_nr, ul_cell_noise_testmode_nr, ul_mimo_switch_nr.
    These commands change radio condtions.
    :param mimo_info: information to pass to ul_mimo_switch_nr command
    :param ue_test_info: information to pass to ue_testmode_set_nr command
    :param noise_info: information to pass to ul_cell_noise_testmode_nr command
    :param cell_test_info: information to pass to cell_testmode_set_nr command
    """
    logger_console("Changing radio conditions")
    ul_mimo_switch_nr(**mimo_info)
    ue_testmode_set_nr(**ue_test_info)
    ul_cell_noise_testmode_nr(**noise_info)
    cell_testmode_set_nr(**cell_test_info)


def change_radio_conditions_for_many_ues(ues_id, ue_test_info, cell_test_info, mimo_info=None, noise_info=None):
    """Triggers egate commands: ue_testmode_set_nr, cell_testmode_set_nr, ul_cell_noise_testmode_nr, ul_mimo_switch_nr.
    These commands change radio condtions.
    :param mimo_info: information to pass to ul_mimo_switch_nr command
    :param ue_test_info: information to pass to ue_testmode_set_nr command
    :param noise_info: information to pass to ul_cell_noise_testmode_nr command
    :param cell_test_info: information to pass to cell_testmode_set_nr command
    """
    logger_console("Changing radio conditions")
    if mimo_info:
        ul_mimo_switch_nr(**mimo_info)
    for ue in ues_id:
        ue_testmode_set_nr(**ue_test_info[ue])
    if noise_info:
        ul_cell_noise_testmode_nr(**noise_info)
    for ue in ues_id:
        cell_testmode_set_nr(**cell_test_info[ue])


def __check_if_only_show(cmd):
    regex = r'profile_id=\d+$'
    return re.search(regex, cmd)
