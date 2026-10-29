from ue_profiles import *
from ue_measurements import *

NUM_OF_LOOPS = 10


async def SkyWatch_Seq_NSA_031(semaphore, ue_id, target_cell=1, target_pci=145):
    async with semaphore:
        execute_wts_command(cmd=f"ue_attach id={ue_id}", wait_for_regex=f"UE{ue_id}: === UE IS ACTIVE")
        activate_nsa_mid_cell_testmod(ue_id=ue_id)

        execute_wts_command(cmd=f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                                f"target_cells={target_cell} bearer=2 type=split_scg",
                                wait_for_regex=f"UE{ue_id}: Successfully reconfigured dual connectivity")
        execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                f" srsrp_nr=70 srsrq_nr=40 ssinr_nr=80 event=A3")
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=dl mbps=100 bytes=2M")
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} id=2 dir=ul mbps=50 bytes=200K")
        execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1"
                                f" event=A3 srsrp_nr=11 phycell_id={target_pci} nrsrp_nr=120")

        await asyncio.sleep(randint(10, 15))
        execute_wts_command(cmd=f"ue_detach id={ue_id}")
