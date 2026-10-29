from RegexWatcher import watcher, file_logger
# from RegexWatcher import file_logger
from common import *
from ue_profiles import *
from tput import *
from ue_state import *
from ue_measurements import *
from ue_rrc_resume_reestab import *
import asyncio
from random import randint, choice, seed
from errors import (setup_no_sending_rrcsetup_req, deactivate_no_responding_to_rrc_messages,
                    setup_no_sending_rrcsetupcomplete)
from decorators import timed_async

NUM_OF_LOOPS = 5
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


async def SkyWatch_Seq_SA_Background(semaphore, ue_id, meas_id, target_cell=1,
                                     nwslice=1, rf_condition="near_cell", default_slice_5qi=6, vonr=False,
                                     period=None):
    """
    >added delay                    (currently 0)
    >5qi activated                  (mapped default_slice_5qi -> QoS)
    >testmodes activated            (based on rf_condition)
    >ue register with 2xPDU session
    >signalling 1kbps dl/ul
    >A1/A2 measurements send
    > data traffic 100/50 kbps dl/ul
    > optional vonr QoS and traffic
    >>MAIN SCENARIO<<
    """
    pass


""" Every function is decorated in the same way like:
        >added delay                    (currently 0)
        >capabilities activation        (based on caps)
        >activate beam profile          (only if band is n41)
        >5qi activated                  (mapped default_slice_5qi -> QoS)
        >testmodes activated            (based on rf_condition)
        >ue register with 2xPDU session
        >>>MAIN SCENARIO<<<
        >ue kill

* To avoid decoration You can use param scenario_type="special"
 """


async def SkyWatch_Seq_SA_004(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_002(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_001(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_IDLE", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_005(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul bytes=800 mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id, cause="mo-SMS", watcher=watcher)


async def SkyWatch_Seq_SA_003(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_S24_CAPA", scenario_type="special", default_slice_5qi=6,
                              rf_condition="far_cell"):
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


async def SkyWatch_Seq_SA_006(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_combined_tput_with_vonr(ue_id, data_ul_interval=10, watcher=watcher)
        await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)


async def SkyWatch_Seq_SA_025(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_combined_tput_with_vonr(ue_id, data_ul_interval=10, watcher=watcher)
        await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)


async def SkyWatch_Seq_SA_008(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_vonr_call_and_signalling(ue_id, watcher)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)


async def SkyWatch_Seq_SA_027(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_vonr_call_and_signalling(ue_id=ue_id, watcher=watcher)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)


async def SkyWatch_Seq_SA_046(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_vonr_call_and_signalling(ue_id=ue_id, watcher=watcher)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)


async def SkyWatch_Seq_SA_009(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="far_cell"):
    await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15))
    for run_id in range(1, int(num_of_loops) + 1):
        await amf_paging(ue_id=ue_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_vonr_call_and_signalling(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_028(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15))
    for run_id in range(1, int(num_of_loops) + 1):
        await amf_paging(ue_id=ue_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_vonr_call_and_signalling(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_047(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell"):
    await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await modify_rrc_setup_cause(ue_id=ue_id, cause='mt-Access', watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15))
    for run_id in range(1, int(num_of_loops) + 1):
        await amf_paging(ue_id=ue_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_vonr_call_and_signalling(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_010(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=128, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id, cause='mps-PriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_029(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=128, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_048(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=128, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mps-PriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_011(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=7, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_030(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=7, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_049(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=7, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mcs-PriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_012(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_031(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_050(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='highPriorityAccess', watcher=watcher)


async def SkyWatch_Seq_SA_013(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_032(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_051(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_018(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL3CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 3))


async def SkyWatch_Seq_SA_019(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 3))


async def SkyWatch_Seq_SA_020(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=9, rf_condition="far_cell"):
    await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=45M mbps=12 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=6M mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_037(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL3CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_038(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_039(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=9, rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=45M mbps=12 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=6M mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_056(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL3CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_057(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_058(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_INACT", default_slice_5qi=9, rf_condition="near_cell"):
    await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=45M mbps=12 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=6M mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_014(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_033(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_052(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_015(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_034(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_053(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_007(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_add=3,7")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Created FiveQi:Qfi mapping fiveQi 2",
                                       timeout=4)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await run_vonr_and_video_call(ue_id, watcher)
        await exit_idle_state_with_cause(ue_id, cause="mo-VideoCall", watcher=watcher)


async def SkyWatch_Seq_SA_026(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_add=3,7")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Created FiveQi:Qfi mapping fiveQi 2",
                                       timeout=4)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await run_vonr_and_video_call(ue_id, watcher)
        await exit_idle_state_with_cause(ue_id, cause="mo-VideoCall", watcher=watcher)


async def SkyWatch_Seq_SA_045(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_add=3,7")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Created FiveQi:Qfi mapping fiveQi 2",
                                       timeout=4)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await run_vonr_and_video_call(ue_id, watcher)
        await exit_idle_state_with_cause(ue_id, cause="mo-VideoCall", watcher=watcher)


async def SkyWatch_Seq_SA_016(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_035(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_054(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL2CC_UL2CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    for run_id in range(1, int(num_of_loops) + 1):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=800K mbps=2 protocol=tcp")
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await asyncio.sleep(randint(2, 4))


async def SkyWatch_Seq_SA_017(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL3CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="far_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_far_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_036(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL3CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_055(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL3CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_021(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_040(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_022(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_041(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_INACT", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=randint(14, 15),
                                        sleep_without_regex=4)
        await send_rrc_resume_with_cause(ue_id=ue_id, cause="mo_Data", watcher=watcher)


async def SkyWatch_Seq_SA_023(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_IDLE", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mo-Data', watcher=watcher)


async def SkyWatch_Seq_SA_042(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL1CC_UL1CC_IDLE", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops)+1):
        await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mo-Data', watcher=watcher)


async def SkyWatch_Seq_SA_024(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="mid_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul bytes=300 mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id, cause="mo-SMS", watcher=watcher)


async def SkyWatch_Seq_SA_043(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul bytes=300 mbps=2 protocol=tcp")
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id, cause="mo-SMS", watcher=watcher)


async def SkyWatch_Seq_SA_044(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell"):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await run_combined_tput_with_vonr(ue_id, data_ul_interval=10, watcher=watcher)
        await exit_idle_state_with_cause(ue_id, cause="mo-VoiceCall", watcher=watcher)
