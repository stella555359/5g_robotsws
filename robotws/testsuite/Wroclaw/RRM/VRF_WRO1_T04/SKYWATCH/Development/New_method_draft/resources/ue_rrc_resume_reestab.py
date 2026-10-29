# from common import *
# from ue_profiles import *
from ue_profiles import deactivate_bler_profile, activate_bler_profile


async def send_rrc_resume_with_cause(ue_id, cause, bler_profile_id=1, watcher=None):
    if watcher:
        # await deactivate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
        await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} cause={cause}')
        await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
        await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)
        # await activate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id, watcher=watcher)
    else:
        # deactivate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id)
        execute_wts_command(cmd='ue_nr_rrc_resume_request_param id={} cause={}'.format(ue_id, cause))
        execute_wts_command(cmd='ue_nr_rrc_resume id={}'.format(ue_id))
        time.sleep(2)
        # activate_bler_profile(ue_id=ue_id, profile_id=bler_profile_id)
