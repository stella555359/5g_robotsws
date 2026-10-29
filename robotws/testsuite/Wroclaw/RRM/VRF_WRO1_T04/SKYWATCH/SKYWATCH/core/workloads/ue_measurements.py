from core.workloads.errors import set_unsuccessful_ho_with_reestab
from random import randint
import asyncio


async def send_reports_A1_A2_with_random_rsrp(ue_id, meas_id_a1_ca, srsrp, srsrq, ssinr,
                                              watcher=None):
    """Sends A1 and A2 report based on limitation:
      for cell 1,2 n71 limit = 49
      for cell 21,22 n25 limit = 45
      for cell 201,202,211,212 n41 limit = 51"""
    async def send_report_a2():
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1 srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A2")

    async def send_report_a1():
        await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                                   f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")

    if meas_id_a1_ca == 5:
        # meas = 5 means cell n71
        limit = 49
    elif meas_id_a1_ca == 3:
        # meas=3 means cell n25
        limit = 45
    else:
        # meas 4 means cell n41
        limit = 51
    if srsrp <= limit:
        await asyncio.gather(send_report_a2(), send_report_a1())
    else:
        await send_report_a1()


async def send_reports_A1_A2_far_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp=randint(36, 44),
                                              srsrq=randint(48, 57), ssinr=randint(37, 47), watcher=watcher)


async def send_reports_A1_A2_mid_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp=randint(55, 71),
                                              srsrq=randint(58, 67), ssinr=randint(48, 73), watcher=watcher)


async def send_reports_A1_A2_near_cell(ue_id, meas_id_a1_ca, watcher=None):
    await send_reports_A1_A2_with_random_rsrp(ue_id=ue_id, meas_id_a1_ca=meas_id_a1_ca, srsrp=randint(72, 81),
                                              srsrq=randint(68, 76), ssinr=randint(74, 87), watcher=watcher)


async def send_report_A1_with_random_rsrp_nsa(ue_id, target_cell, srsrp_min, srsrp_max, srsrq_min, srsrq_max,
                                              ssinr_min, ssinr_max, watcher=None):
    srsrp = randint(srsrp_min, srsrp_max)
    srsrq = randint(srsrq_min, srsrq_max)
    ssinr = randint(ssinr_min, ssinr_max)
    if target_cell in [201, 202, 211, 212]:
        meas_id_a1_ca = 5
    else:
        meas_id_a1_ca = 6
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a1_ca} srsrp_nr={srsrp} "
                               f"srsrq_nr={srsrq} ssinr_nr={ssinr} event=A1")


async def send_reports_A1_far_cell_nsa(ue_id, target_cell, watcher=None):
    await send_report_A1_with_random_rsrp_nsa(ue_id=ue_id, target_cell=target_cell, srsrp_min=44, srsrp_max=56,
                                              srsrq_min=37, srsrq_max=56, ssinr_min=37, ssinr_max=66, watcher=watcher)


async def send_reports_A1_mid_cell_nsa(ue_id, target_cell, watcher=None):
    await send_report_A1_with_random_rsrp_nsa(ue_id=ue_id, target_cell=target_cell,  srsrp_min=57, srsrp_max=71,
                                              srsrq_min=57, srsrq_max=66, ssinr_min=67, ssinr_max=86, watcher=watcher)


async def send_reports_A1_near_cell_nsa(ue_id, target_cell, watcher=None):
    await send_report_A1_with_random_rsrp_nsa(ue_id=ue_id, target_cell=target_cell,  srsrp_min=72, srsrp_max=96,
                                              srsrq_min=67, srsrq_max=86, ssinr_min=77, ssinr_max=106, watcher=watcher)


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
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} meas_type={meas_type} "
                               f"tgt_phycell_id={target_phycell_id} tgt_cell_ssb_frequency={tgt_ssb}")
    await watcher.wait_for_pattern(f"UE{ue_id}: Inter-eNB handover from "
                                   f"EXT_ENB-2.{src_cell_id} to ENB-{sim_gnb_id}.{tgt_cell_id} performed", timeout=10)
    await asyncio.sleep(2)


async def trigger_A3_ho_meas_to_sim_gnb(ue_id, meas_id_a3_ho, target_phycell_id, src_cell_id, tgt_cell_id,
                                        sim_gnb_id, meas_id_a2_ho=1, send_a2_before_a3=False, watcher=None):
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


async def trigger_a3_ho_meas_for_nsa_and_fail(ue_id, target_cell, watcher=None):
    if target_cell == 1:
        target_pci = 145
    elif target_cell == 201:
        target_pci = 250
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1"
                               f" event=A3 srsrp_nr=11 phycell_id={target_pci} nrsrp_nr=120")
    await watcher.wait_with_padding(fr"UE{ue_id}:  === Bearer-type change from SCG-split to MCG is successful",
                                    total_time=randint(14, 15))


async def trigger_a3_ho_meas_for_nsa(ue_id, target_cell, watcher=None):
    if target_cell == 1:
        target_pci = 145
    elif target_cell == 201:
        target_pci = 250
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id=1"
                               f" event=A3 srsrp_nr=11 phycell_id={target_pci} nrsrp_nr=120")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=4)


async def trigger_ho_a5(ue_id, target_freq, target_phycell_id, src_cell_id, tgt_cell_id, tgt_gnb_id=2, watcher=None):
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} tgt_phycell_id={target_phycell_id} meas_type=A5 "
                               f"tgt_cell_ssb_frequency={target_freq}")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from EXT_ENB-2.{src_cell_id} "
                                   f"to EXT_ENB-{tgt_gnb_id}.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_a3(ue_id, target_freq, target_phycell_id, src_cell_id, tgt_cell_id, tgt_gnb_id=2, watcher=None):
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} tgt_phycell_id={target_phycell_id} meas_type=A3 "
                               f"tgt_cell_ssb_frequency={target_freq}")
    await watcher.wait_for_pattern(f"UE{ue_id}: Intra-eNB handover from EXT_ENB-2.{src_cell_id} "
                                   f"to EXT_ENB-{tgt_gnb_id}.{tgt_cell_id} performed", timeout=10)


async def trigger_ho_a5_with_reestab(ue_id, target_freq, target_phycell_id, watcher=None):
    await set_unsuccessful_ho_with_reestab(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} tgt_phycell_id={target_phycell_id} meas_type=A5 "
                               f"tgt_cell_ssb_frequency={target_freq}")
    await watcher.wait_for_pattern(fr"UE-{ue_id} PDU SESSION ID-2 setup/reestablishment complete", timeout=10)


async def trigger_ho_a3_with_reestab(ue_id, target_freq, target_phycell_id, watcher=None):
    await set_unsuccessful_ho_with_reestab(ue_id=ue_id, watcher=watcher)
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_ho_nr ue_id={ue_id} tgt_phycell_id={target_phycell_id} meas_type=A3 "
                               f"tgt_cell_ssb_frequency={target_freq}")
    await watcher.wait_for_pattern(fr"UE-{ue_id} PDU SESSION ID-2 setup/reestablishment complete", timeout=10)


async def trigger_B2_ho_meas_to_sim_enb(ue_id, meas_id_b2_ho, target_phycell_id, src_cell_id, tgt_cell_id,
                                        meas_id_a2_ho=1, watcher=None):
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_a2_ho} event=A2 "
                               f"phycell_id={target_phycell_id} nrsrp_nr=19 nrsrq_nr=17")
    await asyncio.sleep(1)
    await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_b2_ho} event=B2 "
                               f"phycell_id={target_phycell_id} nrsrp_nr=31 nrsrq_nr=17 srsrp_nr=10")
    await watcher.wait_for_pattern(f"UE{ue_id}: Successful handover from "
                                   f"EXT_ENB-2.{src_cell_id} to ENB-5.{tgt_cell_id}", timeout=10)


async def trigger_B2_ho_meas_to_ext_gnb(ue_id, target_gnb_id, tgt_cell_id, target_plmn, src_cell_id, watcher=None):
    await asyncio.sleep(0.5)
    await watcher.send_command(f"ue_cfg_meas_disp id={ue_id}")
    await watcher.send_command(f"gnb_trigger_inter_rat_handover_to_5g ue={ue_id} target_gnb={target_gnb_id} "
                               f"target_cell={tgt_cell_id} plmn={target_plmn}")
    await watcher.wait_for_pattern(f"UE{ue_id}: Inter-eNB handover from "
                                   f"ENB-5.{src_cell_id} to EXT_ENB-2.{tgt_cell_id} performed", timeout=10)


async def send_report_mobility_vonr(ue_id, meas_id, srsrp, srsrq, ssinr, event, watcher=None):
    meas_id_A2_vonr = meas_id + 1
    meas_id_A1_vonr = meas_id + 2
    if event == 'A2':
        meas_id_vonr = meas_id_A2_vonr
    elif event == 'A1':
        meas_id_vonr = meas_id_A1_vonr
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id_vonr} srsrp_nr={srsrp} "
                               f"srsrq_nr={srsrq} ssinr_nr={ssinr} event={event}")


async def send_report_a2_vonr_near_rf(ue_id, meas_id, event='A2', watcher=None):
    await send_report_mobility_vonr(ue_id=ue_id, meas_id=meas_id, srsrp=80, srsrq=randint(68, 76),
                                    ssinr=randint(74, 87), event=event, watcher=watcher)


async def send_report_a1_vonr_near_rf(ue_id, meas_id, event='A1', watcher=None):
    await send_report_mobility_vonr(ue_id=ue_id, meas_id=meas_id, srsrp=87, srsrq=randint(68, 76),
                                    ssinr=randint(74, 87), event=event, watcher=watcher)


async def send_report_a2_vonr_far_rf(ue_id, meas_id, event='A2', watcher=None):
    await send_report_mobility_vonr(ue_id=ue_id, meas_id=meas_id, srsrp=51, srsrq=randint(48, 57),
                                    ssinr=randint(37, 47), event=event, watcher=watcher)


async def send_report_a1_vonr_far_rf(ue_id, meas_id, event='A1', watcher=None):
    await send_report_mobility_vonr(ue_id=ue_id, meas_id=meas_id, srsrp=59, srsrq=randint(48, 57),
                                    ssinr=randint(37, 47), event=event, watcher=watcher)


async def send_report_mobility(ue_id, meas_id, srsrp, srsrq, ssinr, event, watcher=None):
    meas_id_A2 = 1
    meas_id_A1 = meas_id + 1
    if event == 'A2':
        meas_id = meas_id_A2
    elif event == 'A1':
        meas_id = meas_id_A1
    await watcher.send_command(f"ue_measurement_send_nr id={ue_id} meas_id={meas_id} srsrp_nr={srsrp} "
                               f"srsrq_nr={srsrq} ssinr_nr={ssinr} event={event}")


async def send_report_a2_far_rf(ue_id, meas_id, event='A2', watcher=None):
    await send_report_mobility(ue_id=ue_id, meas_id=meas_id, srsrp=43, srsrq=randint(48, 57),
                               ssinr=randint(37, 47), event=event, watcher=watcher)


async def send_report_a1_far_rf(ue_id, meas_id, event='A1', watcher=None):
    await send_report_mobility(ue_id=ue_id, meas_id=meas_id, srsrp=55, srsrq=randint(48, 57),
                               ssinr=randint(37, 47), event=event, watcher=watcher)
