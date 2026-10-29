# from ue_rrc_resume_reestab import *
# from tput import *
# from ue_measurements import *
# from ue_state import *
# from errors import *
from RegexWatcher import watcher
from common import (random_delay_within_range, prepare_and_register_ue_with_pdu_sessions, deregister_ue_by_switch_off,
                    ue_capa_path, add_delay_to_scenario, add_fiveqi_1_to_pdu_2, modify_ue_capabilities,
                    modify_rrc_setup_cause)
from ue_profiles import (activate_sa_far_cell_testmod, prepare_amf_for_inactive_state, prepare_beam_profiles,
                         prepare_testmode_far_cell_rf_condition, prepare_testmode_mid_cell_rf_condition,
                         create_no_rrc_setup_req_profile, create_no_rrc_setup_complete_profile, activate_beam_profile,
                         activate_sa_mid_cell_testmod)
from ue_state import exit_idle_state_with_cause, amf_paging
from tput import run_tput_and_wait_for_idle, run_signalling_ul_dl, run_tput, run_vonr_call
from ue_rrc_resume_reestab import send_rrc_resume_with_cause
from ue_measurements import send_reports_A1_A2_with_random_rsrp, send_reports_A1_A2_near_cell, \
    send_reports_A1_A2_far_cell, send_reports_A1_A2_mid_cell
import asyncio
from random import randint

NUM_OF_LOOPS = 10
LONG_SEQ_LOOP_NUM = 5


async def stop_watcher(watcher=watcher):
    watcher.stop()


async def Precondition_For_Tests(watcher=watcher):
    await prepare_amf_for_inactive_state(watcher=watcher)
    await asyncio.sleep(2)
    await prepare_beam_profiles(watcher=watcher)
    # create_timing_advance_profiles()
    await prepare_testmode_far_cell_rf_condition(watcher=watcher)
    await prepare_testmode_mid_cell_rf_condition(watcher=watcher)
    # create_no_rrc_setup_req_profile()
    # create_no_rrc_setup_complete_profile()


async def SkyWatch_Seq_SA_004_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps",
                                       value_per_second=100, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Kbps", value_per_second=200, watcher=watcher)
            await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_004_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps",
                                       value_per_second=100, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Kbps", value_per_second=200, watcher=watcher)
            await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)

        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_004_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)

        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps",
                                       value_per_second=100, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Kbps", value_per_second=200, watcher=watcher)
            await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)

        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_002_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()

        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)

        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps",
                                       value_per_second=100, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)

        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_002_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps",
                                       value_per_second=100, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)

        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_002_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)

        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps",
                                       value_per_second=100, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_001_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput_and_wait_for_idle(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                                             unit_per_second="Mbps", value_per_second=2, watcher=watcher,
                                             sleep_without_regex=12)
            await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_001_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput_and_wait_for_idle(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                                             unit_per_second="Mbps", value_per_second=2, watcher=watcher,
                                             sleep_without_regex=12)
            await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_001_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        # activate_timing_advance_profile(ue_id=ue_id, profile_id=1)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput_and_wait_for_idle(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                                             unit_per_second="Mbps", value_per_second=2, watcher=watcher,
                                             sleep_without_regex=12)
            await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_005_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")

        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)

        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput_and_wait_for_idle(ue_id=ue_id, pdu_id=2, trf_id=1, dir="ul", bytes="800",
                                             unit_per_second="Kbps", value_per_second=2, watcher=watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-SMS", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_005_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")

        await add_delay_to_scenario()

        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)

        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput_and_wait_for_idle(ue_id=ue_id, pdu_id=2, trf_id=1, dir="ul", bytes="800",
                                             unit_per_second="Kbps", value_per_second=2, watcher=watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-SMS", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_005_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)

        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput_and_wait_for_idle(ue_id=ue_id, pdu_id=2, trf_id=1, dir="ul", bytes="800",
                                             unit_per_second="Kbps", value_per_second=2, watcher=watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-SMS", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_003_01_nonmMIMO(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                          watcher=watcher):
    async with semaphore:
        ue_change_location(ue_id=ue_id, cell=target_cell)
        await add_delay_to_scenario()
        activate_timing_advance_profile(ue_id=ue_id, profile_id=1)
        await random_delay_within_range(delay_from=1, delay_to=15)
        for run_id in range(1, int(num_of_loops) + 1):
            setup_no_sending_rrcsetup_req(ue_id=ue_id)
            register_ue(ue_id=ue_id)
            await asyncio.sleep(randint(5, 10))
            deactivate_no_responding_to_rrc_messages(ue_id=ue_id)
            setup_no_sending_rrcsetupcomplete(ue_id=ue_id)
            register_ue(ue_id=ue_id)
            await asyncio.sleep(2)
            deactivate_no_responding_to_rrc_messages(ue_id=ue_id)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_003_02_mMIMO(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                       watcher=watcher):
    async with semaphore:
        ue_change_location(ue_id=ue_id, cell=target_cell)
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        activate_timing_advance_profile(ue_id=ue_id, profile_id=1)
        await random_delay_within_range(delay_from=1, delay_to=15)
        for run_id in range(1, int(num_of_loops) + 1):
            setup_no_sending_rrcsetup_req(ue_id=ue_id)
            register_ue(ue_id=ue_id)
            await asyncio.sleep(randint(5, 10))
            deactivate_no_responding_to_rrc_messages(ue_id=ue_id)
            setup_no_sending_rrcsetupcomplete(ue_id=ue_id)
            register_ue(ue_id=ue_id)
            await asyncio.sleep(2)
            deactivate_no_responding_to_rrc_messages(ue_id=ue_id)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_006_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=5, srsrp_min=40, srsrp_max=57,
                                                      srsrq=40, ssinr=50, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Kbps",
                           value_per_second=200, watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_006_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()

        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=3, srsrp_min=40, srsrp_max=57,
                                                      srsrq=40, ssinr=50, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Kbps",
                           value_per_second=200, watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_006_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=4, srsrp_min=40, srsrp_max=57,
                                                      srsrq=40, ssinr=50, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Kbps",
                           value_per_second=200, watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_025_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Kbps",
                           value_per_second=200, watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_025_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")

        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Kbps",
                           value_per_second=200, watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_025_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")

        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id, pdu_gw_list, target_cell, watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Kbps",
                           value_per_second=200, watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_008_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id, watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_008_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_008_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_027_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_027_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_027_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_046_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_046_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_046_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_009_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=0)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_009_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_009_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        # activate_timing_advance_profile(ue_id=ue_id, profile_id=1)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_028_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_028_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_028_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_047_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_047_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_047_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=4")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell,
                                                        watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
        # await random_delay_within_range(delay_from=10, delay_to=15)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
        for run_id in range(1, int(num_of_loops) + 1):
            await amf_paging(ue_id=ue_id, watcher=watcher)
            await add_fiveqi_1_to_pdu_2(ue_id, watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await run_vonr_call(ue_id=ue_id, watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_010_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_010_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id, cause='mps-PriorityAccess')

        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_010_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_029_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_029_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_029_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops)+1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_048_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_048_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_048_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=5")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=2,
                                                        target_cell=target_cell)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_011_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_011_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_011_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_030_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_030_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_030_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_049_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_049_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_049_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal default_qos_flow=6")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=3,
                                                        target_cell=target_cell)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=10, delay_to=15)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess')
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_012_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_012_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_012_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_031_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_031_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_031_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_050_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_050_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_050_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=INACT_OFF_SA_S24")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=4,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                           unit_per_second="Mbps", value_per_second=10, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                           unit_per_second="Mbps", value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=20, delay_to=25)
            await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_013_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_013_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_013_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_032_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_032_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_032_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_051_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_051_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_051_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=5,
                                                        target_cell=target_cell, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K", unit_per_second="Mbps",
                           value_per_second=1, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_018_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_018_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_018_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_019_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=1,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_019_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=1,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_019_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=1,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_020_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_020_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_020_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_037_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_037_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_037_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_038_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=1,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_038_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=1,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_038_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=1,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_039_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_039_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_039_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_056_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_056_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_056_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_057_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_057_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_057_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=6,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Kbps=200")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Kbps=20")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(84)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_058_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_058_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_058_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     watcher=watcher):
    async with semaphore:
        await add_delay_to_scenario()
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, nwslice=7,
                                                        target_cell=target_cell, watcher=watcher)
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=dl Mbps=4")
            await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 trf_id=1 dir=ul Mbps=1")
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await asyncio.sleep(60)
            await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=1 dir=bi")
            await random_delay_within_range(delay_from=2, delay_to=3)
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_014_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_014_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_014_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        await activate_sa_far_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_033_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_033_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_033_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        await activate_sa_mid_cell_testmod(ue_id=ue_id, watcher=watcher)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_052_01_n71(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=5, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_052_02_n25(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=3, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_052_03_n41(semaphore, ue_id, pdu_gw_list, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        await watcher.send_command(f"ue_param capability_file={ue_capa_path}"
                                   f" id={ue_id} ue_nr_capabilities=SA_S24_CAPA")
        await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
        await prepare_and_register_ue_with_pdu_sessions(ue_id=ue_id, pdu_gw_list=pdu_gw_list, target_cell=target_cell)
        for run_id in range(1, int(num_of_loops) + 1):
            await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=4, watcher=watcher)
            await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M", unit_per_second="Mbps",
                           value_per_second=2, watcher=watcher)
            await run_signalling_ul_dl(ue_id=ue_id, pdu_id=2, bytes="2K", unit_per_second="Kbps", value_per_second=100,
                                       watcher=watcher)
            await random_delay_within_range(delay_from=25, delay_to=30)
            await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data")
        await deregister_ue_by_switch_off(ue_id=ue_id, watcher=watcher)
