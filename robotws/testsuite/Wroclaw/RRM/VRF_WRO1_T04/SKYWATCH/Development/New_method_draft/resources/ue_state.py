# from common import *
from ue_profiles import activate_bler_profile, deactivate_bler_profile


def exit_idle_state(ue_id):
    execute_wts_command(cmd=f'ue_im_exit id={ue_id}',
                        wait_for_regex=f'Initial Context Setup Successful for UE with AMF UE ID {ue_id}')


async def amf_paging(ue_id, watcher=None):
    await watcher.send_command(f"amf_paging_start id=1 ue={ue_id}")
    await watcher.wait_for_pattern(fr"UE-{ue_id} PDU SESSION ID-2 setup/reestablishment complete", timeout=5)


async def exit_idle_state_with_cause(ue_id, cause, watcher=None, bler_profile_id=1):
    if watcher:
        # await deactivate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
        await watcher.send_command(f'ue_nr_rrc_setup_param id={ue_id} establishment_cause={cause}')
        await watcher.send_command(f'ue_im_exit id={ue_id}')
        await watcher.wait_for_pattern(fr"UE-{ue_id} PDU SESSION ID-2 setup/reestablishment complete", timeout=5)
        # await activate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
    else:
        execute_wts_command(cmd=f'ue_nr_rrc_setup_param id={ue_id} establishment_cause={cause}')
        execute_wts_command(cmd=f'ue_im_exit id={ue_id}',
                            wait_for_regex=f'Initial Context Setup Successful for UE with AMF UE ID {ue_id}')
