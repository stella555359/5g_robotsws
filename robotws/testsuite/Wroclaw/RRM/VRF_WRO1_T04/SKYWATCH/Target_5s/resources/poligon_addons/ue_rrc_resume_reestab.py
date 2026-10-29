# from common import *
# from ue_profiles import *
from ue_profiles import deactivate_bler_profile, activate_bler_profile


async def send_rrc_resume_with_cause(ue_id, cause, bler_profile_id=None, watcher=None):
    if watcher:
        if bler_profile_id is not None:
            # await deactivate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
            await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} cause={cause}')
            await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
            await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)
            # await activate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
        # else:
        #     await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} cause={cause}')
        #     await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
        #     await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)


async def change_cell_and_send_rrc_resume_with_cause(ue_id, cell, cause, bler_profile_id=1, watcher=None):
    if watcher:
        if bler_profile_id is not None:
            # await deactivate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
            await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} gnb=2 cell={cell} cause={cause}')
            await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
            await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)
            # await activate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
        else:
            await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} gnb=2 cell={cell} cause={cause}')
            await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
            await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)


async def change_cell_and_send_rrc_resume_with_cause_follow_by_rrc_setup(ue_id, cell, cause,
                                                                         bler_profile_id=1, watcher=None):
    if watcher:
        if bler_profile_id is not None:
            # await deactivate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
            await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} gnb=2 cell={cell} cause={cause}')
            await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
            await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed Registration type INITIAL_REGISTRATION",
                                           timeout=3)
            # await activate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
        else:
            await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} gnb=2 cell={cell} cause={cause}')
            await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
            await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed Registration type INITIAL_REGISTRATION",
                                           timeout=3)
