import asyncio
from random import randint
from random import choice
from core.workloads.common import collect_traffic_stats
from core.workloads.tputs.tput_stream import confirm_tput_on_ue


@collect_traffic_stats
async def run_data_traffic(ue_id, watcher=None):
    async def run_dl_data():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl bytes=800K mbps=4 protocol=tcp")
        return await confirm_tput_on_ue(ue_id, pdu=1, qfi=1, direction="dl", watcher=watcher)

    async def run_ul_data():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul bytes=300K mbps=2 protocol=tcp")
        return await confirm_tput_on_ue(ue_id, pdu=1, qfi=1, direction="ul", watcher=watcher)

    dl_tput = await run_dl_data()
    ul_tput = await run_ul_data()
    return {
        "dl_data": dl_tput,
        "ul_data": ul_tput
    }


@collect_traffic_stats
async def run_signalling_ul_dl(ue_id, watcher=None):
    async def signalling_dl():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl bytes=2K Kbps=10 protocol=tcp")
        return await confirm_tput_on_ue(ue_id, pdu=2, qfi=1, direction="dl", watcher=watcher)

    async def signalling_ul():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul bytes=2K Kbps=10 protocol=tcp")
        return await confirm_tput_on_ue(ue_id, pdu=2, qfi=1, direction="ul", watcher=watcher)

    dl_tput = await signalling_dl()
    ul_tput = await signalling_ul()

    return {
        "dl_sign": dl_tput,
        "ul_sign": ul_tput
    }


# ==================================================================================
# async def action_with_interval(repeats, interval, watcher, function):
#     for i in range(repeats):
#         await function
#         await asyncio.sleep(interval)
#
#
# async def run_tput(ue_id, pdu_id, trf_id, dir, bytes, unit_per_second, value_per_second, watcher=None):
#     await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id={trf_id}"
#                                f" dir={dir} bytes={bytes} {unit_per_second}={value_per_second}")


async def run_combined_tput_with_vonr(ue_id, watcher=None):
    # period = choice([1, 2, 3, 4])
    period = choice([1, 2])
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom rtp_ps=61 "
                               f"rtp_send_silence_period=0 rtp_voice_silence=3:{period}")
    await asyncio.sleep(3)
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom rtp_ps=61 "
                               f"rtp_send_silence_period=0 rtp_voice_silence=3:{period}")
    await asyncio.sleep(3)
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl period_ms=6000 burst=1 size=2000")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Started Downlink Internal traffic Receiver on Ue:{ue_id}"
                                   fr" Pdu:1 Qfi:1", timeout=15, sleep_without_regex=6)

    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul period_ms=6000 burst=1 size=300")
    await watcher.wait_for_pattern(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} UpfId:1"
                                   fr" Pdu:1 Qfi:1", timeout=15, sleep_without_regex=6)

    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl period_ms=6000 burst=1 size=200")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Started Downlink Internal traffic Receiver on Ue:{ue_id} "
                                   fr"Pdu:2 Qfi:1", timeout=15, sleep_without_regex=6)

    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul period_ms=6000 burst=1 size=200")
    await watcher.wait_for_pattern(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} "
                                   fr"UpfId:1 Pdu:2 Qfi:1", timeout=15, sleep_without_regex=6)

    await asyncio.sleep(45)
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=all dir=bi")
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)


async def stop_traffic(ue_id, pdu_id="all", watcher=None):
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu={pdu_id} dir=bi")
    await watcher.wait_for_pattern(fr"UE {ue_id}: Traffic was stopped", timeout=1)
