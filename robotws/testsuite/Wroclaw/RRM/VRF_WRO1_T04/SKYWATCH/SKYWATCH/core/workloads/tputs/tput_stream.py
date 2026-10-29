import asyncio
from random import randint
from random import choice
from typing import Optional, Literal, Dict
from core.workloads.common import collect_traffic_stats


async def noop():
    return None


async def confirm_tput_on_ue(ue_id, pdu, qfi, direction, watcher=None):
    await watcher.send_command(f"trf_internal_disp ue={ue_id} pdu={pdu} qfi={qfi} dir={direction}")
    result = await watcher.wait_for_pattern(
        fr"UE #{ue_id}.*pdu # {pdu} qfi # {qfi}.*direction\s*{direction.upper()}.*rate\s*((?!0+(?:\.0+)?)"
        fr"\d+(?:\.\d+)? [KM]?bps)", timeout=1)
    if result:
        return result.group(1)
    else:
        return None


async def stop_vonr_call_and_signalling(ue_id, watcher=None):
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=2 dir=bi")
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)


async def stop_vonr_call(ue_id, watcher=None):
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=2 qfi=2 dir=bi")
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)


@collect_traffic_stats
async def run_signalling(ue_id, watcher=None):
    async def signalling_dl():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl period_ms=6000 burst=1"
                                   f" size=200 protocol=tcp")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Started Downlink Internal traffic Receiver on "
                                       fr"Ue:{ue_id} Pdu:2 Qfi:1", timeout=15, sleep_without_regex=6)

        return await confirm_tput_on_ue(ue_id, pdu=2, qfi=1, direction="dl", watcher=watcher)

    async def signalling_ul():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul period_ms=6000 burst=1"
                                   f" size=200 protocol=tcp")
        await watcher.wait_for_pattern(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} UpfId:1 Pdu:2 Qfi:1",
                                       timeout=15, sleep_without_regex=6)
        return await confirm_tput_on_ue(ue_id, pdu=2, qfi=1, direction="ul", watcher=watcher)

    dl_tput, ul_tput = await asyncio.gather(signalling_dl(), signalling_ul())
    return {
        "dl_sign": dl_tput,
        "ul_sign": ul_tput
    }


@collect_traffic_stats
async def start_vonr_call(ue_id, watcher=None, period=None):
    if period is None:
        period = choice([1, 2])

    async def run_dl_vonr():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom rtp_ps=61"
                                   f" rtp_send_silence_period=0 rtp_voice_silence=3:{period}")
        await watcher.wait_with_padding(fr"Started Downlink Internal traffic Receiver on Ue:{ue_id} Pdu:2 Qfi:2",
                                        total_time=3)
        return await confirm_tput_on_ue(ue_id, pdu=2, qfi=2, direction="dl", watcher=watcher)

    async def run_ul_vonr():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom rtp_ps=61"
                                   f" rtp_send_silence_period=0 rtp_voice_silence=3:{period}")
        await watcher.wait_with_padding(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} UpfId:1 Pdu:2 Qfi:2",
                                        total_time=3)
        return await confirm_tput_on_ue(ue_id, pdu=2, qfi=2, direction="ul", watcher=watcher)

    dl_tput = await run_dl_vonr()
    ul_tput = await run_ul_vonr()
    return {
        "dl_vonr": dl_tput,
        "ul_vonr": ul_tput,
        "period": period
    }

Load = Literal["light", "medium", "heavy", "background"]

LOAD_CONFIG_UL: Dict[Load, Dict] = {
        "light": {"interval_ms": 1300, "size": 1000, "burst": 2},
        "medium": {"interval_ms": 300, "size": 2000, "burst": 4},
        "heavy": {"interval_ms": 80, "size": 2500, "burst": 10},
        "background": {"interval_ms": 4000, "size": 100, "burst": 1}
}

LOAD_CONFIG_DL: Dict[Load, Dict] = {
        "light": {"interval_ms": 1200, "size": 1500, "burst": 4},
        "medium": {"interval_ms": 150, "size": 2500, "burst": 6},
        "heavy": {"interval_ms": 40, "size": 4000, "burst": 20},
        "background": {"interval_ms": 2000, "size": 500, "burst": 1}
}


async def run_continous_data_and_signalling_tput(ue_id, duration=0, watcher=None, ul: Optional[Load] = None,
                                                 dl: Optional[Load] = None):

    @collect_traffic_stats
    async def run_dl_data(traffic_type):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl period_ms={traffic_type['interval_ms']}"
                                   f" burst={traffic_type['burst']} size={traffic_type['size']}")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Started Downlink Internal traffic Receiver on "
                                       fr"Ue:{ue_id} Pdu:1 Qfi:1", timeout=15)
        return {
            "dl_data": await confirm_tput_on_ue(ue_id, pdu=1, qfi=1, direction="dl", watcher=watcher)
        }

    @collect_traffic_stats
    async def run_ul_data(traffic_type):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul period_ms={traffic_type['interval_ms']} "
                                   f"burst={traffic_type['burst']} size={traffic_type['size']}")
        await watcher.wait_for_pattern(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} "
                                       fr"UpfId:1 Pdu:1 Qfi:1", timeout=15)
        return {
            "ul_data": await confirm_tput_on_ue(ue_id, pdu=1, qfi=1, direction="ul", watcher=watcher)
        }

    tasks = []
    if dl is not None:
        tasks.append(asyncio.create_task(run_dl_data(LOAD_CONFIG_DL[dl])))
    else:
        tasks.append(asyncio.create_task(noop()))
    if ul is not None:
        tasks.append(asyncio.create_task(run_ul_data(LOAD_CONFIG_UL[ul])))
    else:
        tasks.append(asyncio.create_task(noop()))
    tasks.append(asyncio.create_task(run_signalling(ue_id, watcher)))

    dl_tput, ul_tput, sign_tput = await asyncio.gather(*tasks)

    if duration != 0:
        await asyncio.sleep(duration)
        await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=all dir=bi")
    return {
        "dl_data": dl_tput,
        "ul_data": ul_tput,
        "dl_sign": sign_tput["dl_sign"],
        "ul_sign": sign_tput["ul_sign"]
    }


async def run_vonr_call_and_signalling(ue_id, watcher=None):
    await start_vonr_call(ue_id, watcher)
    await run_signalling(ue_id, watcher)
    await asyncio.sleep(45)
    await stop_vonr_call_and_signalling(ue_id, watcher)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(14, 15), sleep_without_regex=4)


async def run_combined_tput_vonr_and_video_call(ue_id, watcher=None):
    period = choice([1, 2])

    @collect_traffic_stats
    async def run_dl_data():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl period_ms=6000 burst=1 size=2000")
        await watcher.wait_for_pattern(
            fr"UE{ue_id}: Started Downlink Internal traffic Receiver on Ue:{ue_id} Pdu:1 Qfi:1", timeout=15,
            sleep_without_regex=6)

        return {
            "dl_data": await confirm_tput_on_ue(ue_id, pdu=1, qfi=1, direction="dl", watcher=watcher)
        }

    @collect_traffic_stats
    async def run_ul_data():
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul period_ms=6000 burst=1 size=300")
        await watcher.wait_for_pattern(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} UpfId:1 Pdu:1 Qfi:1",
                                       timeout=15, sleep_without_regex=6)
        return {
            "ul_data": await confirm_tput_on_ue(ue_id, pdu=1, qfi=1, direction="ul", watcher=watcher)
        }

    async def run_video(direction):
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=3 dir={direction} rtp_codec=custom"
                                   f" period_ms=40 rtp_ps=800 rtp_ts_step=33 rtp_send_silence_period=0"
                                   f" rtp_voice_silence=50:0")
        if direction == "ul":
            await watcher.wait_with_padding(fr"Started Uplink Internal traffic Receiver on Ue:{ue_id} "
                                            fr"UpfId:1 Pdu:2 Qfi:3", total_time=3)
        if direction == "dl":
            await watcher.wait_with_padding(fr"Started Downlink Internal traffic Receiver on Ue:{ue_id} Pdu:2 Qfi:3",
                                            total_time=3)
        await confirm_tput_on_ue(ue_id, pdu=2, qfi=3, direction=direction, watcher=watcher)

    await run_video(direction="ul")
    await run_video(direction="dl")
    await start_vonr_call(ue_id, watcher)
    await run_ul_data()
    await run_dl_data()
    await run_signalling(ue_id, watcher)
    await asyncio.sleep(45)
    await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=all dir=bi")
    await watcher.send_command(f"amf_ue_pdu_modify_param id=1 ue={ue_id} action=override_ie "
                               f"qos_flow_to_del_cause=NAS_normal_release")
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=7")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=6)
