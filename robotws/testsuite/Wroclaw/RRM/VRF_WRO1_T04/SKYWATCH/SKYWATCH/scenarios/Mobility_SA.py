from core.RegexWatcher import watcher
from core.workloads.tputs.tput_stream import *
from core.workloads.tputs.tput_once import *
from core.workloads.ue_measurements import *
from core.workloads.ue_state import *
from core.workloads.common import *
from core.workloads.ue_profiles import *


NUM_OF_LOOPS = 5


async def SkyWatch_Seq_SA_075_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=396970, target_phycell_id=375, src_cell_id=1,
                        tgt_cell_id=21, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=520110, target_phycell_id=9, src_cell_id=1,
                        tgt_cell_id=201, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_075_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=520110, target_phycell_id=9, src_cell_id=21,
                        tgt_cell_id=201, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=125290, target_phycell_id=48, src_cell_id=21,
                        tgt_cell_id=1, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_075_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5(ue_id=ue_id, target_freq=125290, target_phycell_id=48, src_cell_id=201,
                        tgt_cell_id=1, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await activate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5(ue_id=ue_id, target_freq=396970, target_phycell_id=375, src_cell_id=201,
                        tgt_cell_id=21, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await activate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a3(ue_id=ue_id, target_freq=396970, target_phycell_id=375, src_cell_id=201,
                        tgt_cell_id=21, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_071_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3(ue_id=ue_id, target_freq=125290, target_phycell_id=145, src_cell_id=1,
                        tgt_cell_id=2, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=125290, target_phycell_id=145, src_cell_id=1,
                        tgt_cell_id=2, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_071_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3(ue_id=ue_id, target_freq=396970, target_phycell_id=190, src_cell_id=21,
                        tgt_cell_id=22, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_071_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3(ue_id=ue_id, target_freq=520110, target_phycell_id=250, src_cell_id=201,
                        tgt_cell_id=202, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=520110, target_phycell_id=250, src_cell_id=201,
                        tgt_cell_id=202, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_093_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=396970, target_phycell_id=375, src_cell_id=1,
                        tgt_cell_id=21, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=520110, target_phycell_id=9, src_cell_id=1,
                        tgt_cell_id=201, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_093_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=520110, target_phycell_id=9, src_cell_id=21,
                        tgt_cell_id=201, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=125290, target_phycell_id=48, src_cell_id=21,
                        tgt_cell_id=1, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_093_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5(ue_id=ue_id, target_freq=125290, target_phycell_id=48, src_cell_id=201,
                        tgt_cell_id=1, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await activate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a3(ue_id=ue_id, target_freq=396970, target_phycell_id=375, src_cell_id=201,
                        tgt_cell_id=21, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await activate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5(ue_id=ue_id, target_freq=396970, target_phycell_id=375, src_cell_id=201,
                        tgt_cell_id=21, watcher=watcher)
    await asyncio.sleep(randint(5, 10))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_089_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3(ue_id=ue_id, target_freq=125290, target_phycell_id=145, src_cell_id=1,
                        tgt_cell_id=2, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=125290, target_phycell_id=145, src_cell_id=1,
                        tgt_cell_id=2, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_089_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3(ue_id=ue_id, target_freq=396970, target_phycell_id=190, src_cell_id=21,
                        tgt_cell_id=22, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_089_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3(ue_id=ue_id, target_freq=520110, target_phycell_id=250, src_cell_id=201,
                        tgt_cell_id=202, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5(ue_id=ue_id, target_freq=520110, target_phycell_id=250, src_cell_id=201,
                        tgt_cell_id=202, watcher=watcher)
    await asyncio.sleep(randint(2, 5))
    await stop_vonr_call(ue_id, watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_069_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=63, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_069_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=21,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_069_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=65, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_081_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=66, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_081_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=67, tgt_ssb=396970, src_cell_id=21,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_081_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=68, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_087_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=63, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_087_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=21,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_087_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=65, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_067_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_067_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_067_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_079_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=67, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_079_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_079_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=67, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=67, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_085_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_085_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_085_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_072_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=145, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=145, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_072_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=190, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_072_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=250, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=250, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_076_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=375, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=9, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_076_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=9, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=48, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_076_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=48, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)

    await activate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=375, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_090_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=145, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=145, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_090_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=190, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_090_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=250, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=250, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_094_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=375, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=9, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_094_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=9, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=48, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_094_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=48, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await activate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await deactivate_beam_control_profile(ue_id=ue_id, beam_id=beam_id, watcher=watcher)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=375, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_083_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IRAT", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    # await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    # await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=12, target_phycell_id=70, src_cell_id=1,
    #                                     tgt_cell_id=52, watcher=watcher)
    # await asyncio.sleep(5)
    # await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=1, target_plmn="310:260",
    #                                     src_cell_id=52, watcher=watcher)
    # await stop_traffic(ue_id=ue_id, watcher=watcher)
    # await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    # await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    # await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    # await asyncio.sleep(10)
    await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=69, src_cell_id=1,
                                        tgt_cell_id=51, watcher=watcher)
    await asyncio.sleep(5)
    await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=1, target_plmn="310:260",
                                        src_cell_id=51, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_083_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IRAT", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    # await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    # await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=10, target_phycell_id=70, src_cell_id=21,
    #                                     tgt_cell_id=52, watcher=watcher)
    # await asyncio.sleep(5)
    # await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=21, target_plmn="310:260",
    #                                     src_cell_id=52, watcher=watcher)
    # await stop_traffic(ue_id=ue_id, watcher=watcher)
    # await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    # await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    # await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    # await asyncio.sleep(10)
    await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=69, src_cell_id=21,
                                        tgt_cell_id=51, watcher=watcher)
    await asyncio.sleep(5)
    await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=21, target_plmn="310:260",
                                        src_cell_id=51, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_083_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IRAT", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    # await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    # await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=70, src_cell_id=201,
    #                                     tgt_cell_id=52, watcher=watcher)
    # await asyncio.sleep(5)
    # await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=201, target_plmn="310:260",
    #                                     src_cell_id=52, watcher=watcher)
    # await stop_traffic(ue_id=ue_id, watcher=watcher)
    # await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    # await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    # await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    # await asyncio.sleep(10)
    await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=69, src_cell_id=201,
                                        tgt_cell_id=51, watcher=watcher)
    await asyncio.sleep(5)
    await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=201, target_plmn="310:260",
                                        src_cell_id=51, watcher=watcher)
    await stop_traffic(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_101_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IRAT", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    # await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    # await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=12, target_phycell_id=70, src_cell_id=1,
    #                                     tgt_cell_id=52, watcher=watcher)
    # await asyncio.sleep(5)
    # await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=1, target_plmn="310:260",
    #                                     src_cell_id=52, watcher=watcher)
    # await stop_vonr_call(ue_id, watcher)
    # await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    # await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    # await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    # await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    # await start_vonr_call(ue_id, watcher)
    # await asyncio.sleep(10)
    await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=69, src_cell_id=1,
                                        tgt_cell_id=51, watcher=watcher)
    await asyncio.sleep(5)
    await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=1, target_plmn="310:260",
                                        src_cell_id=51, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_101_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IRAT", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    # await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    # await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=12, target_phycell_id=70, src_cell_id=21,
    #                                     tgt_cell_id=52, watcher=watcher)
    # await asyncio.sleep(5)
    # await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=21, target_plmn="310:260",
    #                                     src_cell_id=52, watcher=watcher)
    # await stop_vonr_call(ue_id, watcher)
    # await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    # await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    # await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    # await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    # await start_vonr_call(ue_id, watcher)
    # await asyncio.sleep(10)
    await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=69, src_cell_id=21,
                                        tgt_cell_id=51, watcher=watcher)
    await asyncio.sleep(5)
    await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=21, target_plmn="310:260",
                                        src_cell_id=51, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_101_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IRAT", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    # await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    # await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=12, target_phycell_id=70, src_cell_id=201,
    #                                     tgt_cell_id=52, watcher=watcher)
    # await asyncio.sleep(5)
    # await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=201, target_plmn="310:260",
    #                                     src_cell_id=52, watcher=watcher)
    # await stop_vonr_call(ue_id, watcher)
    # await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    # await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    # await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    # await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    # await start_vonr_call(ue_id, watcher)
    # await asyncio.sleep(10)
    await trigger_B2_ho_meas_to_sim_enb(ue_id=ue_id, meas_id_b2_ho=11, target_phycell_id=69, src_cell_id=201,
                                        tgt_cell_id=51, watcher=watcher)
    await asyncio.sleep(5)
    await trigger_B2_ho_meas_to_ext_gnb(ue_id=ue_id, target_gnb_id=2, tgt_cell_id=201, target_plmn="310:260",
                                        src_cell_id=51, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_097_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=67, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_097_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_097_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=67, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=67, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_099_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=66, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_099_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=67, tgt_ssb=396970, src_cell_id=21,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_099_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=68, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await wait_until_idle_state(ue_id=ue_id, watcher=watcher)


async def SkyWatch_Seq_SA_080_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=67, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_080_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_080_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=67, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_082_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_082_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=67, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_082_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_098_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=67, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_098_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_098_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=67, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_100_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=66, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_100_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=67, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_100_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=68, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_068_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=64, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_068_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_068_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=64, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_070_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_070_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=64, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_070_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=False):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_086_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=64, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_086_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_086_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="light", ul="light")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id, watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=64, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_088_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=125290, target_phycell_id=63, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_088_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=396970, target_phycell_id=64, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)


async def SkyWatch_Seq_SA_088_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell",
                                     beam_id=None, nwslice=1, vonr=True):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a3_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_continous_data_and_signalling_tput(ue_id=ue_id, watcher=watcher, dl="background", ul="background")
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(10)
    await trigger_ho_a5_with_reestab(ue_id=ue_id, target_freq=520110, target_phycell_id=65, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15, sleep_without_regex=0)
