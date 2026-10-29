# from common import *
from random import randint
import asyncio


def send_double_ue_report_A1(ue_id, meas_id, srsrp, srsrq, ssinr):
    meas_cmd = 'ue_measurement_send_nr id={} meas_id={} srsrp_nr={} srsrq_nr={} ssinr_nr={} \
              event=A1'.format(ue_id, meas_id, srsrp, srsrq, ssinr)
    execute_wts_command(cmd=meas_cmd)
    time.sleep(1)
    execute_wts_command(cmd=meas_cmd)
    time.sleep(1)


async def send_reports_A1_A2_with_random_rsrp(ue_id, meas_id_a1_ca, srsrp_min, srsrp_max, srsrq, ssinr,
                                              watcher=None):
    if watcher:
        srsrp = randint(srsrp_min, srsrp_max)
        if srsrp <= 49:
            await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr={srsrp} "
                                       f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A2")
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")
        await asyncio.sleep(0.5)
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")
        # await asyncio.sleep(1)
    # else:
    #     srsrp = randint(srsrp_min, srsrp_max)
    #     print(f"RSRP: {srsrp}")
    #     meas_cmd = 'ue_measurement_send_nr id={} meas_id={} srsrp_nr={} srsrq_nr={} ssinr_nr={} \
    #               event=A1'.format(ue_id, meas_id_a1_ca, srsrp, srsrq, ssinr)
    #     if srsrp <= 49:
    #         meas_cmd_a1_mob = 'ue_measurement_send_nr id={} meas_id=1 srsrp_nr={} srsrq_nr={} ssinr_nr={} \
    #               event=A2'.format(ue_id, srsrp, srsrq, ssinr)
    #         execute_wts_command(cmd=meas_cmd_a1_mob)
    #     execute_wts_command(cmd=meas_cmd)
    #     time.sleep(1)
    #     execute_wts_command(cmd=meas_cmd)
    #     time.sleep(1)


async def send_reports_A1_A2_far_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp_min=40, srsrp_max=57,
                                              srsrq=40, ssinr=50, watcher=watcher)


async def send_reports_A1_A2_mid_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp_min=57, srsrp_max=71,
                                              srsrq=55, ssinr=75, watcher=watcher)


async def send_reports_A1_A2_near_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp_min=71, srsrp_max=86,
                                              srsrq=85, ssinr=95, watcher=watcher)


def show_meas_for_ue(ue_id):
    execute_wts_command(cmd='ue_meas_cfg_disp id={} meas_obj_type=nr'.format(ue_id))


def trigger_CA_with_A1_meas(ue_id, target_cell):
    if target_cell in [201, 202, 211, 212]:
        meas_id = 5
    else:
        meas_id = 6
    execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id={meas_id}"
                            f" srsrp_nr=90 event=A1")
