# from common import *
import asyncio
from random import randint
from random import choice


async def action_with_interval(repeats, interval, watcher, function):
    for i in range(repeats):
        await function
        await asyncio.sleep(interval)


async def run_tput(ue_id, pdu_id, trf_id, dir, bytes, unit_per_second, value_per_second, watcher=None):
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id={trf_id}"
                               f" dir={dir} bytes={bytes} {unit_per_second}={value_per_second}")


async def run_signalling_ul_dl(ue_id, watcher=None):
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl bytes=2K Kbps=10")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul bytes=2K Kbps=10")


async def run_tput_with_burst(ue_id, pdu_id, dir, gap, packet_size, packets_in_burst, watcher=None, **kwargs):
    other_params = " ".join(f"{key}={value}" for key, value in kwargs.items())
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1 dir={dir}  period_ms={gap}"
                               f" size={packet_size} burst={packets_in_burst} protocol=tcp {other_params}")


async def run_signalling_with_burst(ue_id, pdu_id, gap, packet_size, packets_in_burst, watcher=None, **kwargs):
    other_params = " ".join(f"{key}={value}" for key, value in kwargs.items())
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1 dir=ul  period_ms={gap}"
                               f" size={packet_size} burst={packets_in_burst} protocol=tcp {other_params}")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1 dir=dl  period_ms={gap}"
                               f" size={packet_size} burst={packets_in_burst} protocol=tcp {other_params}")


async def run_vonr_call(ue_id, watcher=None):
    period = choice([700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200])
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom"
                               f" period_ms={period} rtp_send_silence_period={period}")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom"
                               f" period_ms={period} rtp_send_silence_period={period}")
    await asyncio.sleep(90)
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=2 qfi=2 dir=bi")
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)


async def run_vonr_call_and_signalling(ue_id, watcher=None):
    period = choice([700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200])
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl seconds=90 Kbps=10")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul seconds=90 Kbps=10")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom"
                               f" period_ms={period} rtp_send_silence_period={period}")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom"
                               f" period_ms={period} rtp_send_silence_period={period}")
    await asyncio.sleep(900)
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=2 qfi=2 dir=bi")
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)


async def run_dldata_traffic_with_interval(ue_id, multi, interval, watcher=None):
    for _ in range(multi):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=2M mbps=15 protocol=tcp")
        await asyncio.sleep(interval)


async def run_uldata_traffic_with_interval(ue_id, multi, interval, watcher=None):
    for _ in range(multi):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=200K mbps=2 protocol=tcp")
        await asyncio.sleep(interval)


async def run_signalling_ul_dl_with_interval(ue_id, multi, interval, watcher=None):
    await asyncio.sleep(interval // 2)
    for _ in range(multi):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl bytes=2K Kbps=10")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul bytes=2K Kbps=10")
        await asyncio.sleep(interval)


async def run_combined_tput_with_vonr(ue_id, data_dl_multi=8, data_dl_interval=6, data_ul_multi=8,
                                      data_ul_interval=6, sign_multi=8, sign_interval=6, watcher=None):
    """ Default values are 8x loop and 6s interval, if needed to change just assign new value during function usage """

    # vonr_call = asyncio.create_task(run_vonr_call(ue_id, watcher))
    vonr_and_signalling = asyncio.create_task(run_vonr_call_and_signalling(ue_id, watcher))
    dl_data_trf = asyncio.create_task(run_dldata_traffic_with_interval(ue_id, multi=data_dl_multi,
                                                                       interval=data_dl_interval, watcher=watcher))
    ul_data_trf = asyncio.create_task(run_uldata_traffic_with_interval(ue_id, multi=data_ul_multi,
                                                                       interval=data_ul_interval, watcher=watcher))
    # signalling = asyncio.create_task(run_signalling_ul_dl_with_interval(ue_id, multi=sign_multi,
    #                                                                     interval=sign_interval, watcher=watcher))

    await asyncio.gather(vonr_and_signalling, dl_data_trf, ul_data_trf)


async def run_vonr_and_video_call(ue_id, watcher=None):
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=amr_wb_23_85")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=amr_wb_23_85")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=3 dir=dl rtp_codec=custom rtp_ps=900"
                               f" rtp_silence_ps=300 rtp_send_silence_period=200ms")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=3 dir=ul rtp_codec=custom rtp_ps=900"
                               f" rtp_silence_ps=300 rtp_send_silence_period=200ms")
    await asyncio.sleep(90)
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=7")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await stop_traffic(ue_id, pdu_id="all", watcher=watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=6)


async def stop_traffic(ue_id, pdu_id="all", watcher=None):
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu={pdu_id} dir=bi")
    await watcher.wait_for_pattern(fr"UE {ue_id}: Traffic was stopped", timeout=1)


async def start_vonr_call(ue_id, watcher=None):
    period = choice([700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200])
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom"
                               f" period_ms={period} rtp_send_silence_period={period}")
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom"
                               f" period_ms={period} rtp_send_silence_period={period}")


async def stop_vonr_call(ue_id, watcher=None):
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
