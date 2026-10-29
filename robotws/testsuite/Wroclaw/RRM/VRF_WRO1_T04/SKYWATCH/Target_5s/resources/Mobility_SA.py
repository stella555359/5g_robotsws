from RegexWatcher import watcher
from ue_profiles import *
from ue_rrc_resume_reestab import *
from tput import *
from ue_measurements import *
from ue_state import *
from common import *

NUM_OF_LOOPS = 5


async def SkyWatch_Seq_SA_075_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=15, target_phycell_id=375, src_cell_id=1,
                                tgt_cell_id=21, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=1, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=9, src_cell_id=1,
                                tgt_cell_id=201, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_075_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=9, src_cell_id=21,
                                tgt_cell_id=201, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=21, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=15, target_phycell_id=48, src_cell_id=21,
                                tgt_cell_id=1, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_075_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=14, target_phycell_id=48, src_cell_id=201,
                                tgt_cell_id=1, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=201, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=375, src_cell_id=201,
                                tgt_cell_id=21, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=201, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a3(ue_id=ue_id, meas_id_a3_ho=12, target_phycell_id=375, src_cell_id=201,
                                tgt_cell_id=21, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_071_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a3(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=145, src_cell_id=1,
                             tgt_cell_id=2, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=1, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a2_a5(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=145, src_cell_id=1,
                                tgt_cell_id=2, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_071_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a3(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=190, src_cell_id=21,
                             tgt_cell_id=22, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_071_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a3(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=250, src_cell_id=201,
                             tgt_cell_id=202, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=201, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_meas_a5(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=250, src_cell_id=201,
                             tgt_cell_id=202, watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_093_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a5_vonr(ue_id=ue_id, meas_id_a2_ho=6, meas_id_a5_ho=10, target_phycell_id=375,
                                     src_cell_id=1, tgt_cell_id=21, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=1, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a5_vonr(ue_id=ue_id, meas_id_a2_ho=6,  meas_id_a5_ho=8, target_phycell_id=9,
                                     src_cell_id=1, tgt_cell_id=201, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_093_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a5_vonr(ue_id=ue_id, meas_id_a2_ho=4, meas_id_a5_ho=6, target_phycell_id=9,
                                     src_cell_id=21, tgt_cell_id=201, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=21, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a5_vonr(ue_id=ue_id, meas_id_a2_ho=4, meas_id_a5_ho=8, target_phycell_id=48,
                                     src_cell_id=21, tgt_cell_id=1, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_093_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a5_vonr(ue_id=ue_id, meas_id_a2_ho=5, meas_id_a5_ho=9, target_phycell_id=48,
                                     src_cell_id=201, tgt_cell_id=1, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=201, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a3_vonr(ue_id=ue_id, meas_id_a2_ho=5, meas_id_a3_ho=7, target_phycell_id=375,
                                     src_cell_id=201, tgt_cell_id=21, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=201, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a2_a5_vonr(ue_id=ue_id, meas_id_a2_ho=5, meas_id_a5_ho=8, target_phycell_id=375,
                                     src_cell_id=201, tgt_cell_id=21, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_089_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a3(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=145, src_cell_id=1,
                             tgt_cell_id=2, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=1, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a5(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=145, src_cell_id=1,
                             tgt_cell_id=2, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_089_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a3(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=190, src_cell_id=21,
                             tgt_cell_id=22, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_089_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_INACT", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a3(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=250, src_cell_id=201,
                             tgt_cell_id=202, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
    await change_cell_and_send_rrc_resume_with_cause(ue_id=ue_id, cell=201, cause="mo_Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await start_vonr_call(ue_id, watcher)
    await trigger_ho_meas_a5(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=250, src_cell_id=201,
                             tgt_cell_id=202, watcher=watcher)
    await stop_vonr_call(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)


async def SkyWatch_Seq_SA_069_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=63, src_cell_id=1,
                                        tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=63, src_cell_id=1,
                                        tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_069_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=64, src_cell_id=21,
                                        tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_069_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=65, src_cell_id=201,
                                        tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=65, src_cell_id=201,
                                        tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_081_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=66, src_cell_id=1,
                                        tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=66, src_cell_id=1,
                                        tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_081_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=67, src_cell_id=21,
                                        tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_081_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=68, src_cell_id=201,
                                        tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=68, src_cell_id=201,
                                        tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_087_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=63, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    # await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=63, src_cell_id=1,
    #                                     tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=1,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=63, src_cell_id=1,
    #                                     tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_087_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=21,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=64, src_cell_id=21,
    #                                     tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_087_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=65, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    # await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=65, src_cell_id=201,
    #                                     tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=201,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=65, src_cell_id=201,
    #                                     tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_067_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=15, target_phycell_id=64, src_cell_id=1,
    #                                     tgt_cell_id=32, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=65, src_cell_id=1,
    #                                     tgt_cell_id=33, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_067_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=65, src_cell_id=21,
    #                                     tgt_cell_id=33, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=7, target_phycell_id=63, src_cell_id=21,
    #                                     tgt_cell_id=31, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_067_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=14, target_phycell_id=63, src_cell_id=201,
    #                                     tgt_cell_id=31, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=64, src_cell_id=201,
    #                                     tgt_cell_id=32, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=12, target_phycell_id=64, src_cell_id=201,
    #                                     tgt_cell_id=32, sim_gnb_id=3, send_a2_before_a3=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_079_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=67, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=9, target_phycell_id=67, src_cell_id=1,
    #                                     tgt_cell_id=42, sim_gnb_id=4, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=7, target_phycell_id=68, src_cell_id=1,
    #                                     tgt_cell_id=43, sim_gnb_id=4, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_079_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=68, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=43, sim_gnb_id=4, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=13, target_phycell_id=68, src_cell_id=21,
    #                                     tgt_cell_id=43, sim_gnb_id=4, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=7, target_phycell_id=66, src_cell_id=21,
    #                                     tgt_cell_id=41, sim_gnb_id=4, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_079_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=66, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=41, sim_gnb_id=4, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=8, target_phycell_id=66, src_cell_id=201,
    #                                     tgt_cell_id=41, sim_gnb_id=4, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=67, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=7, target_phycell_id=67, src_cell_id=201,
    #                                     tgt_cell_id=42, sim_gnb_id=4, send_a2_before_a5=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=67, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=42, sim_gnb_id=4, watcher=watcher)
    # await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=5, target_phycell_id=67, src_cell_id=201,
    #                                     tgt_cell_id=42, sim_gnb_id=4, send_a2_before_a3=True, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_085_01_n71(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=1,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=2, target_phycell_id=64, src_cell_id=1,
    #                                     tgt_cell_id=32, sim_gnb_id=3, send_a2_before_a5=True, meas_id_a2_ho=6,
    #                                     watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=1,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=65, src_cell_id=1,
    #                                     tgt_cell_id=33, sim_gnb_id=3, send_a2_before_a5=True, meas_id_a2_ho=6,
    #                                     watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_085_02_n25(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=65, tgt_ssb=520110, src_cell_id=21,
                                tgt_cell_id=33, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=9, target_phycell_id=65, src_cell_id=21,
    #                                     tgt_cell_id=33, sim_gnb_id=3, send_a2_before_a5=True, meas_id_a2_ho=4,
    #                                     watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=21,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=8, target_phycell_id=63, src_cell_id=21,
    #                                     tgt_cell_id=31, sim_gnb_id=3, send_a2_before_a5=True, meas_id_a2_ho=4,
    #                                     watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)


async def SkyWatch_Seq_SA_085_03_n41(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                                     caps="SA_DL4CC_UL2CC_IDLE", scenario_type="mobility", rf_condition="mid_cell"):
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=63, tgt_ssb=125290, src_cell_id=201,
                                tgt_cell_id=31, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=63, src_cell_id=201,
    #                                     tgt_cell_id=31, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A5", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A5_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a5_ho=3, target_phycell_id=64, src_cell_id=201,
    #                                     tgt_cell_id=32, sim_gnb_id=3, send_a2_before_a5=True, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
    await send_reports_A1_A2_mid_cell(ue_id=ue_id, meas_id_a1_ca=meas_id, watcher=watcher)
    await run_signalling_ul_dl(ue_id=ue_id, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="dl", bytes="2M",
                   unit_per_second="Mbps", value_per_second=2, watcher=watcher)
    await run_tput(ue_id=ue_id, pdu_id=1, trf_id=1, dir="ul", bytes="200K",
                   unit_per_second="Mbps", value_per_second=1, watcher=watcher)
    await add_fiveqi_1_to_pdu_2(ue_id=ue_id, watcher=watcher)
    await start_vonr_call(ue_id=ue_id, watcher=watcher)
    await trigger_ho_to_sim_gnb(ue_id=ue_id, meas_type="A3", target_phycell_id=64, tgt_ssb=396970, src_cell_id=201,
                                tgt_cell_id=32, sim_gnb_id=3, watcher=watcher)
    # await trigger_A3_ho_meas_to_sim_gnb(ue_id=ue_id, meas_id_a3_ho=2, target_phycell_id=64, src_cell_id=201,
    #                                     tgt_cell_id=32, sim_gnb_id=3, send_a2_before_a3=True, watcher=watcher)
    await stop_vonr_call(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(randint(10, 15))
    await enter_idle_state(ue_id=ue_id, watcher=watcher)
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await exit_idle_state_with_cause(ue_id, cause="mo-Data", watcher=watcher)
