from core.workloads.common import *
from core.workloads.ue_profiles import *
from core.workloads.ue_measurements import *
from core.RegexWatcher import watcher, logger
import random

NUM_OF_LOOPS = 5


def clipped_expovariate(rng, mean, min_val, max_val):
    value = rng.expovariate(1/mean)
    return max(min_val, min(value, max_val))


async def SkyWatch_Seq_NSA_Background(semaphore, ue_id, meas_id, target_cell=1, rf_condition='near_cell',
                                      caps="NSA_S23_UE_CAPA", default_slice_5qi=6, vonr=False, pediod=None,
                                      beam_id=None, scenario_type="background"):
    srsrp_min = 71
    srsrp_max = 86
    srsrq = 85
    ssinr = 95
    meas_id_a1_ca = 3
    if rf_condition == 'near_cell':
        await activate_nsa_near_cell_testmod(ue_id=ue_id, target_cell=target_cell, watcher=watcher)

    elif rf_condition == 'mid_cell':
        srsrp_min = 57
        srsrp_max = 71
        srsrq = 55
        ssinr = 75
        await activate_nsa_mid_cell_testmod(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    elif rf_condition == 'far_cell':
        srsrp_min = 40
        srsrp_max = 57
        srsrq = 40
        ssinr = 50
        await activate_nsa_far_cell_testmod(ue_id=ue_id, target_cell=target_cell, watcher=watcher)
    else:
        logger.error(f"[ERROR] Wrong rf condition {rf_condition}")

    if target_cell == 1:
        meas_id_a1_ca = 5
    elif target_cell == 201:
        meas_id_a1_ca = 4
    else:
        logger.error(f"[ERROR] Wrong lcell id {target_cell} for CA meas")

    rng = random.Random()
    mean_active = rng.uniform(180, 360)
    await attach_ue(ue_id=ue_id, watcher=watcher)
    await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                               f"target_cells={target_cell} bearer=2 type=split_scg")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=4)
    await trigger_CA_with_A1_meas(ue_id, target_cell, watcher=watcher)
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl kbps=100")
    await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul kbps=50")
    await asyncio.sleep(clipped_expovariate(rng, mean_active, 30, 600))
    await watcher.send_command(f"trf_data_stop ue={ue_id} id=2 dir=bi")
    await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                    total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_001(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="far_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_far_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_002(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="far_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_far_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=300K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_003(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="far_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_far_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_004(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="far_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_far_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=300K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_011(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_012(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=4 bytes=300K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_013(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_014(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="mid_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=300K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_021(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="near_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_near_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_022(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="near_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_near_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=4 bytes=300K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_023(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="near_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_near_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)


async def SkyWatch_Seq_NSA_024(semaphore, ue_id, meas_id, num_of_loops=NUM_OF_LOOPS, target_cell=1,
                               rf_condition="near_cell", beam_id=None):
    for i in range(1, int(num_of_loops)+1):
        await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                   f"target_cells={target_cell} bearer=2 type=split_scg")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=5)
        await send_reports_A1_near_cell_nsa(ue_id, target_cell, watcher=watcher)
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=dl mbps=4 bytes=800K")
        await watcher.send_command(f"trf_data_start ue={ue_id} id=2 dir=ul mbps=2 bytes=300K")
        await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                        total_time=randint(14, 15), sleep_without_regex=4)
