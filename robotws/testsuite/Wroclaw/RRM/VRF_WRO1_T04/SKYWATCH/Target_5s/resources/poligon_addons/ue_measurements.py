# from common import *
from random import randint
import asyncio
from tput import stop_traffic


async def send_reports_A1_A2_with_random_rsrp(ue_id, meas_id_a1_ca, srsrp_min, srsrp_max, srsrq, ssinr,
                                              watcher=None):
    srsrp = randint(srsrp_min, srsrp_max)
    # await asyncio.sleep(1)
    if srsrp <= 49:
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A2")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                               f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")
    await asyncio.sleep(0.2)
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                               f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")


async def send_reports_A1_A2_far_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp_min=40, srsrp_max=57,
                                              srsrq=40, ssinr=50, watcher=watcher)


async def send_reports_A1_A2_mid_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp_min=57, srsrp_max=71,
                                              srsrq=55, ssinr=75, watcher=watcher)


async def send_reports_A1_A2_near_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp_min=71, srsrp_max=86,
                                              srsrq=85, ssinr=95, watcher=watcher)


async def trigger_CA_with_A1_meas(ue_id, target_cell, watcher=None):
    if target_cell in [201, 202, 211, 212]:
        meas_id = 5
    else:
        meas_id = 6
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id}"
                               f" srsrp_nr=90 event=A1")


async def trigger_ho(ue_id, meas_type, target_phycell_id, tgt_ssb, src_cell_id, tgt_cell_id, watcher=None):
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} meas_type={meas_type}"
                               f" tgt_phycell_id={target_phycell_id} tgt_cell_ssb_frequency={tgt_ssb}")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_meas_a2_a5(ue_id, meas_id_a5_ho, target_phycell_id, src_cell_id, tgt_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr=30 event=A2")
    await asyncio.sleep(1)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a5_ho} srsrp_nr=30"
                               f" phycell_id={target_phycell_id} nrsrp_nr=85 event=A5")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_meas_a2_a3(ue_id, meas_id_a3_ho, target_phycell_id, src_cell_id, tgt_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr=50 event=A2")
    await asyncio.sleep(1)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a3_ho} srsrp_nr=50"
                               f" phycell_id={target_phycell_id} nrsrp_nr=60 event=A3")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_meas_a5(ue_id, meas_id_a5_ho, target_phycell_id, src_cell_id, tgt_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a5_ho} srsrp_nr=40"
                               f" phycell_id={target_phycell_id} nrsrp_nr=75 event=A5")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_meas_a3(ue_id, meas_id_a3_ho, target_phycell_id, src_cell_id, tgt_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a3_ho} srsrp_nr=50"
                               f" phycell_id={target_phycell_id} nrsrp_nr=60 event=A3")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_meas_a2_a5_vonr(ue_id, meas_id_a2_ho, meas_id_a5_ho, target_phycell_id,
                                     src_cell_id, tgt_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a2_ho} srsrp_nr=65 event=A2")
    await asyncio.sleep(1)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a5_ho} srsrp_nr=65"
                               f" phycell_id={target_phycell_id} nrsrp_nr=75 event=A5")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_meas_a2_a3_vonr(ue_id, meas_id_a2_ho, meas_id_a3_ho, target_phycell_id,
                                     src_cell_id, tgt_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a2_ho} srsrp_nr=65 event=A2")
    await asyncio.sleep(1)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a3_ho} srsrp_nr=55"
                               f" phycell_id={target_phycell_id} nrsrp_nr=75 event=A3")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_to_sim_gnb(ue_id, meas_type, target_phycell_id, tgt_ssb, src_cell_id,
                                tgt_cell_id, sim_gnb_id, watcher=None):
    # await stop_traffic(ue_id=ue_id, pdu_id="all", watcher=watcher)
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} meas_type={meas_type} "
                               f"tgt_phycell_id={target_phycell_id} tgt_cell_ssb_frequency={tgt_ssb}")
    await watcher.wait_for_pattern(f"UE{ue_id}: Inter-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to ENB-{sim_gnb_id}.{tgt_cell_id} performed", timeout=10)


async def trigger_A3_ho_meas_to_sim_gnb(ue_id, meas_id_a3_ho, target_phycell_id, src_cell_id, tgt_cell_id,
                                        sim_gnb_id, meas_id_a2_ho=1, send_a2_before_a3=False, watcher=None):
    # await stop_traffic(ue_id=ue_id, pdu_id="all", watcher=watcher)
    await asyncio.sleep(0.5)
    if send_a2_before_a3:
        # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a2_ho} srsrp_nr=65 event=A2")
        await asyncio.sleep(1)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a3_ho} "
                               f"phycell_id={target_phycell_id} nrsrp_nr=85 srsrp_nr=110 event=A3")
    await watcher.wait_for_pattern(f"UE{ue_id}: Inter-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to ENB-{sim_gnb_id}.{tgt_cell_id} performed", timeout=10)


async def trigger_A5_ho_meas_to_sim_gnb(ue_id, meas_id_a5_ho, target_phycell_id, src_cell_id, tgt_cell_id,
                                        sim_gnb_id, meas_id_a2_ho=1, send_a2_before_a5=False, watcher=None):
    # await stop_traffic(ue_id=ue_id, pdu_id="all", watcher=watcher)
    await asyncio.sleep(0.5)
    if send_a2_before_a5:
        # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a2_ho} srsrp_nr=65 event=A2")
        await asyncio.sleep(1)
    # await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a5_ho} "
                               f"phycell_id={target_phycell_id} nrsrp_nr=85 srsrp_nr=110 event=A5")
    await watcher.wait_for_pattern(f"UE{ue_id}: Inter-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to ENB-{sim_gnb_id}.{tgt_cell_id} performed", timeout=10)
