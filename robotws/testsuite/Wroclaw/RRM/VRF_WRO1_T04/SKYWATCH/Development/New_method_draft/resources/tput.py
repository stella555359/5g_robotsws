# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: 5G_SW_WRO
:contact:
"""
# from common import *
import asyncio
from random import randint


async def action_with_interval(repeats, interval, watcher, function):
    for i in range(repeats):
        await function
        await asyncio.sleep(interval)


async def run_tput(ue_id, pdu_id, trf_id, dir, bytes, unit_per_second, value_per_second, watcher=None):
    if watcher:
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id={trf_id}"
                                   f" dir={dir} bytes={bytes} {unit_per_second}={value_per_second}")
    else:
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id={trf_id} \
                                dir={dir} bytes={bytes} {unit_per_second}={value_per_second}")


async def run_tput_and_wait_for_idle(ue_id, pdu_id, trf_id, dir, bytes, unit_per_second, value_per_second, watcher,
                                     sleep_without_regex=6):
    await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id={trf_id}"
                               f" dir={dir} bytes={bytes} {unit_per_second}={value_per_second}")
    # await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15),
    #                                 sleep_without_regex=sleep_without_regex)
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=15,
                                    sleep_without_regex=sleep_without_regex)


async def run_signalling_ul_dl(ue_id, pdu_id, bytes, unit_per_second, value_per_second, watcher=None):
    if watcher:
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1"
                                   f" dir=dl bytes={bytes} {unit_per_second}={value_per_second}")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1"
                                   f" dir=ul bytes={bytes} {unit_per_second}={value_per_second}")
    else:
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1 \
                                dir=dl bytes={bytes} {unit_per_second}={value_per_second}")
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} pdu={pdu_id} trf_id=1 \
                                dir=ul bytes={bytes} {unit_per_second}={value_per_second}")


async def run_vonr_call(ue_id, watcher=None):
    if watcher:
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=amr_wb_23_85")
        await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=amr_wb_23_85")
        await asyncio.sleep(90)
        await watcher.send_command(f"trf_data_stop ue={ue_id} pdu=2 qfi=2 dir=bi")
        await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
        await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Removed FiveQi", timeout=5)
        await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=randint(10, 15), sleep_without_regex=4)
    else:
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=amr_wb_23_85")
        execute_wts_command(cmd=f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=amr_wb_23_85")
        await asyncio.sleep(90)
        execute_wts_command(cmd=f"trf_data_stop ue={ue_id} pdu=2 qfi=2 dir=bi")
        execute_wts_command(cmd=f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_del=3")
        await asyncio.sleep(randint(10, 15))
