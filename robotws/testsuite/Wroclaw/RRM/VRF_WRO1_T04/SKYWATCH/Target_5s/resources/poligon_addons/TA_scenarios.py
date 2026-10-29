from RegexWatcher import watcher, file_logger
# from RegexWatcher import file_logger
from common_poligon import *
from ue_profiles import *
from tput import *
from ue_state import *
from ue_measurements import *
from ue_rrc_resume_reestab import *
import asyncio
from random import randint, choice, seed
from errors import (setup_no_sending_rrcsetup_req, deactivate_no_responding_to_rrc_messages,
                    setup_no_sending_rrcsetupcomplete)
from decorators_poligon import timed_async

NUM_OF_LOOPS = 1
LONG_SEQ_LOOP_NUM = 2
TRF_DURATION = 300


async def stop_watcher(watcher=watcher):
    await watcher.stop()


async def Precondition_For_Tests(watcher=watcher):
    await prepare_amf_for_inactive_state(watcher=watcher)
    await asyncio.sleep(2)
    await prepare_beam_profiles(watcher=watcher)
    await prepare_timing_advance_profiles(watcher=watcher)
    await prepare_testmode_near_cell_rf_condition(watcher=watcher)
    await prepare_testmode_far_cell_rf_condition(watcher=watcher)
    await prepare_testmode_mid_cell_rf_condition(watcher=watcher)
    await create_no_rrc_setup_req_profile(watcher=watcher)
    await create_no_rrc_setup_complete_profile(watcher=watcher)


async def SkyWatch_Seq_SA_Background(semaphore, ue_id, cell=1,
                                     nwslice=1, rf_condition='near_cell', default_slice_5qi=6, vonr=False):
    seed(42)
    srsrp = randint(72, 90)
    srsrq = randint(68, 76)
    ssinr = randint(74, 87)
    meas_id_a1_ca = 3
    if rf_condition == 'near_cell':
        bler_profile_id = await activate_sa_near_cell_testmod(ue_id=ue_id, target_cell=cell, watcher=watcher)
    elif rf_condition == 'mid_cell':
        srsrp = randint(56, 71)
        srsrq = randint(58, 67)
        ssinr = randint(48, 73)
        bler_profile_id = await activate_sa_mid_cell_testmod(ue_id=ue_id, target_cell=cell, watcher=watcher)
    elif rf_condition == 'far_cell':
        srsrp = randint(40, 55)
        srsrq = randint(48, 57)
        ssinr = randint(37, 47)
        bler_profile_id = await activate_sa_far_cell_testmod(ue_id=ue_id, target_cell=cell, watcher=watcher)
    else:
        file_logger.error(f"[ERROR] Wrong rf condition {rf_condition}")

    if cell == 1:
        meas_id_a1_ca = 5
    elif cell == 21:
        meas_id_a1_ca = 3
    elif cell == 201:
        meas_id_a1_ca = 4
    else:
        file_logger.error(f"[ERROR] Wrong lcell id {cell} for CA meas")

    if default_slice_5qi != 6:
        await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal"
                                   f" default_qos_flow={default_slice_5qi}")
    await prepare_and_register_ue_with_pdu_sessions(ue_id, cell, watcher, bler_profile_id=bler_profile_id)
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl kbps=1")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul kbps=1")

    if (cell == 1) and (srsrp <= 49):
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A2")
    if (cell == 21) and (srsrp <= 45):
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A2")
    if (cell == 201) and (srsrp <= 51):
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A2")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                               f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")
    await asyncio.sleep(0.2)
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl kbps=100")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul kbps=50")

    if vonr:
        period = choice([700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200])
        await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_add=3")
        await asyncio.sleep(0.5)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom "
                                   f"period_ms={period} rtp_send_silence_period={period}")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom "
                                   f"period_ms={period} rtp_send_silence_period={period}")


async def SkyWatch_Seq_SA_004(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT"):
    bler_profile_id = await activate_sa_far_cell_testmod(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await prepare_and_register_ue_with_pdu_sessions(ue_id, target_cell, watcher, bler_profile_id=bler_profile_id)
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", bler_profile_id=bler_profile_id,
                                         watcher=watcher)
    await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_005(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_IDLE", target_profile=1):
    # await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
    bler_profile_id = await activate_sa_near_cell_testmod(ue_id=ue_id, target_cell=target_cell,
                                                          target_profile=target_profile, watcher=watcher)
    await prepare_and_register_ue_with_pdu_sessions(ue_id, target_cell, watcher, bler_profile_id=bler_profile_id)
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await run_vonr_call_and_signalling(ue_id, watcher)
        # await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        # await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
        #                                 sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
    await deregister_ue_by_switch_off(ue_id, watcher)


async def SkyWatch_Seq_SA_003_01_nonmMIMO(semaphore, ue_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                          caps="SA_S24_CAPA", scenario_type="special"):
    await watcher.send_command(f"ue_change_location id={ue_id} cell={target_cell}")
    # activate_timing_advance_profile(ue_id=ue_id, profile_id=1)
    await setup_no_sending_rrcsetup_req(ue_id=ue_id, watcher=watcher)
    await register_ue(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: T300 expiration: No response to RRCSetupRequest",
                                    total_time=randint(5, 10), sleep_without_regex=0)
    # await asyncio.sleep(randint(30, 50))
    await deactivate_no_responding_to_rrc_messages(ue_id=ue_id, watcher=watcher)
    await setup_no_sending_rrcsetupcomplete(ue_id=ue_id, watcher=watcher)
    await register_ue(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: detached", total_time=2,
                                    sleep_without_regex=0)
    await deactivate_no_responding_to_rrc_messages(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_003_02_mMIMO(semaphore, ue_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                       caps="SA_S24_CAPA", scenario_type="special"):
    await watcher.send_command(f"ue_change_location id={ue_id} cell={target_cell}")
    await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
    # activate_timing_advance_profile(ue_id=ue_id, profile_id=1)
    await setup_no_sending_rrcsetup_req(ue_id=ue_id, watcher=watcher)
    await register_ue(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: T300 expiration: No response to RRCSetupRequest",
                                    total_time=randint(5, 10), sleep_without_regex=0)
    # await asyncio.sleep(randint(30, 50))
    await deactivate_no_responding_to_rrc_messages(ue_id=ue_id, watcher=watcher)
    await setup_no_sending_rrcsetupcomplete(ue_id=ue_id, watcher=watcher)
    await register_ue(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: detached", total_time=2,
                                    sleep_without_regex=0)
    await deactivate_no_responding_to_rrc_messages(ue_id=ue_id, watcher=watcher)
