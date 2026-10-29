from random import randint
import asyncio


async def amf_paging(ue_id, watcher=None):
    await watcher.send_command(f"amf_paging_start id=1 ue={ue_id}")
    await watcher.wait_for_pattern(fr"UE-{ue_id} PDU SESSION ID-2 setup/reestablishment complete", timeout=7)


async def wait_until_idle_state(ue_id, watcher=None):
    await asyncio.sleep(randint(10, 15))
    await watcher.send_command(f'ue_im_entry id={ue_id} by=ue')
    await watcher.wait_with_padding(fr"UE{ue_id}: IS IDLE", total_time=10, sleep_without_regex=0)


async def exit_idle_state_with_cause(ue_id, cause, watcher=None):
    await watcher.send_command(f'ue_nr_rrc_setup_param id={ue_id} establishment_cause={cause}')
    await watcher.send_command(f'ue_im_exit id={ue_id}')
    await watcher.wait_for_pattern(fr"UE-{ue_id} PDU SESSION ID-2 setup/reestablishment complete", timeout=7)


async def wait_until_ue_inactive(ue_id, sim_gnb_id, watcher=None):
    await asyncio.sleep(randint(10, 15))
    await watcher.send_command(f'gnb_ue_inactivity_start ue={ue_id} gnb={sim_gnb_id}')
    await watcher.wait_with_padding(fr"UE{ue_id}: Is INACTIVE", total_time=30, sleep_without_regex=0)
