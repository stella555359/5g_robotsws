from core.RegexWatcher import watcher
from core.workloads.common import *
from core.workloads.ue_profiles import *
from core.workloads.tputs.tput_once import *
from core.workloads.tputs.tput_stream import *
from core.workloads.ue_state import *
from core.workloads.ue_measurements import *


LONG_SEQ_LOOP_NUM = 2
TEST_MODE_PERIOD = 10


async def SkyWatch_Seq_SA_059_01_n71(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await start_vonr_call(ue_id=ue_id, watcher=watcher)
        await run_signalling(ue_id, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await send_report_a2_vonr_near_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_far_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await send_report_a1_vonr_near_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await activate_sa_near_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await stop_vonr_call_and_signalling(ue_id, watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)


async def SkyWatch_Seq_SA_059_02_n25(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await start_vonr_call(ue_id=ue_id, watcher=watcher)
        await run_signalling(ue_id, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_far_cell_testmod(ue_id, target_cell, watcher)
        await send_report_a2_vonr_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await send_report_a1_vonr_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_near_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await stop_vonr_call_and_signalling(ue_id, watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)


async def SkyWatch_Seq_SA_059_03_n41(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=9, rf_condition="near_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    for run_id in range(1, int(num_of_loops)+1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await add_fiveqi_1_to_pdu_2(ue_id, watcher)
        await start_vonr_call(ue_id=ue_id, watcher=watcher)
        await run_signalling(ue_id, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_far_cell_testmod(ue_id, target_cell, watcher)
        await send_report_a2_vonr_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await send_report_a1_vonr_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_near_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await stop_vonr_call_and_signalling(ue_id, watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='emergency', watcher=watcher)


async def SkyWatch_Seq_SA_060(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE", default_slice_5qi=6, rf_condition="near_cell",
                              beam_id=None, nwslice=1, vonr=False):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await run_continous_data_and_signalling_tput(ue_id, watcher=watcher, dl="medium", ul="medium")
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_far_cell_testmod(ue_id, target_cell, watcher)
        await send_report_a2_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await send_report_a1_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_near_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await stop_traffic(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mo-Data', watcher=watcher)


async def SkyWatch_Seq_SA_061(semaphore, ue_id, meas_id, num_of_loops=LONG_SEQ_LOOP_NUM, target_cell=1,
                              caps="SA_DL4CC_UL2CC_IDLE_64QAM", default_slice_5qi=6, rf_condition="near_cell",
                              beam_id=None, nwslice=1, vonr=False):
    for run_id in range(1, int(num_of_loops) + 1):
        await send_reports_A1_A2_near_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
        await run_continous_data_and_signalling_tput(ue_id, watcher=watcher, dl="medium", ul="medium")
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_far_cell_testmod(ue_id, target_cell, watcher)
        await send_report_a2_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await send_report_a1_far_rf(ue_id=ue_id, meas_id=meas_id, watcher=watcher)
        await activate_sa_mid_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await activate_sa_near_cell_testmod(ue_id, target_cell, watcher)
        await asyncio.sleep(TEST_MODE_PERIOD)
        await stop_traffic(ue_id=ue_id, watcher=watcher)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)
        await exit_idle_state_with_cause(ue_id=ue_id, cause='mo-Data', watcher=watcher)
