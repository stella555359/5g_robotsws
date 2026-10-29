from core.workloads.common import *
from core.workloads.ue_measurements import *
from core.workloads.errors import *
from core.RegexWatcher import watcher

NUM_OF_LOOPS = 5


async def SkyWatch_Seq_NSA_031(semaphore, ue_id, meas_id, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    """    Intra-frequency intra-gNB intra-DU HO - Success    """
    await perform_sgnb_addition_procedure(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 protocol=tcp")
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 protocol=tcp")
    await trigger_a3_ho_meas_for_nsa(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await asyncio.sleep(randint(10, 15))


async def SkyWatch_Seq_NSA_032(semaphore, ue_id, meas_id, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    """    Intra-frequency intra-gNB intra-DU HO - HO execution failure T304    """
    await perform_sgnb_addition_procedure(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=2M protocol=tcp")
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=200K protocol=tcp")
    await rrc_reconf_scg_failure(ue_id=ue_id, watcher=watcher)
    await trigger_a3_ho_meas_for_nsa_and_fail(ue_id=ue_id, target_cell=target_cell, watcher=watcher)


async def SkyWatch_Seq_NSA_033(semaphore, ue_id, meas_id, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    """    Intra-frequency intra-gNB intra-DU HO - HO execution failure TDCoverall    """
    await perform_sgnb_addition_procedure(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=2M protocol=tcp")
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=200K protocol=tcp")
    await x2_management_no_rsp(watcher=watcher)
    await trigger_a3_ho_meas_for_nsa_and_fail(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await x2_management_normal_rsp(watcher=watcher)


async def SkyWatch_Seq_NSA_034(semaphore, ue_id, meas_id, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    """    Intra-frequency intra-gNB intra-DU HO - HO execution failure MeNB refusal   """
    await perform_sgnb_addition_procedure(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=2M protocol=tcp")
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=200K protocol=tcp")
    await x2_management_menb_refuse(watcher=watcher)
    await trigger_a3_ho_meas_for_nsa_and_fail(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    await x2_management_normal_rsp(watcher=watcher)
