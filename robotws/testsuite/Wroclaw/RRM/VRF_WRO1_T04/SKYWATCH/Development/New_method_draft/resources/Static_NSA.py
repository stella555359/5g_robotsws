from ue_profiles import *
from ue_measurements import *

NUM_OF_LOOPS = 10


async def SkyWatch_Seq_NSA_001(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_far_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_002(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_far_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=50 bytes=200K")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_003(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_far_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            trigger_CA_with_A1_meas(ue_id, target_cell)
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_004(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_far_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            trigger_CA_with_A1_meas(ue_id, target_cell)
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=50 bytes=200K")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_011(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_mid_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_012(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_mid_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=100 bytes=200K")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_013(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_mid_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            trigger_CA_with_A1_meas(ue_id, target_cell)
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_014(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_mid_cell_testmod(ue_id=ue_id)
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            trigger_CA_with_A1_meas(ue_id, target_cell)
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=50 bytes=200K")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_021(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_022(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=100 bytes=200K")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_023(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            trigger_CA_with_A1_meas(ue_id, target_cell)
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")


async def SkyWatch_Seq_NSA_024(semaphore, ue_id, num_of_loops=NUM_OF_LOOPS, target_cell=1):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        for i in range(1, int(num_of_loops)+1):
            execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                    f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
            execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                    f" srsrp_nr=50 srsrq_nr=40 ssinr_nr=50 event=A3")
            trigger_CA_with_A1_meas(ue_id, target_cell)
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
            execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=50 bytes=200K")
            await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")
