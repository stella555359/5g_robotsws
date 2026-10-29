# from common import *
import asyncio


async def setup_no_sending_rrcsetup_req(ue_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                               f" profile_id=1 action=activate")


async def setup_no_sending_rrcsetupcomplete(ue_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                               f" profile_id=2 action=activate")


async def deactivate_no_responding_to_rrc_messages(ue_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                               f" profile_id=1 action=deactivate")
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                               f" profile_id=2 action=deactivate")


async def x2_management_menb_refuse(watcher=None):
    await watcher.send_command(f"link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=refuse")
    await asyncio.sleep(1)


async def x2_management_no_rsp(watcher=None):
    await watcher.send_command(f"link_x2_management_abnormal_cases id=1 partner=2"
                               f" sgnb_modification_reqd_rsp=no_rsp")
    await asyncio.sleep(1)


async def x2_management_normal_rsp(watcher=None):
    await watcher.send_command(f"link_x2_management_abnormal_cases id=1 partner=2 "
                               f"sgnb_modification_reqd_rsp=normal_rsp")
    await asyncio.sleep(1)


async def rrc_reconf_scg_failure(ue_id, watcher=None):
    await watcher.send_command(f"ue_nr_rrc_reconf_param id={ue_id} if_contains=any action=scg_failure")
    await asyncio.sleep(1)
