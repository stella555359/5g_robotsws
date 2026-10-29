async def send_rrc_resume_with_cause(ue_id, cause, watcher=None):
    await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} cause={cause}')
    await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
    await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)


async def change_cell_and_send_rrc_resume_with_cause(ue_id, cell, cause, watcher=None):
    await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} gnb=2 cell={cell} cause={cause}')
    await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
    await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed resume procedure", timeout=3)


async def change_cell_and_send_rrc_resume_with_cause_follow_by_rrc_setup(ue_id, cell, cause,
                                                                         watcher=None):
    await watcher.send_command(f'ue_nr_rrc_resume_request_param id={ue_id} gnb=2 cell={cell} cause={cause}')
    await watcher.send_command(f'ue_nr_rrc_resume id={ue_id}')
    await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed Registration type INITIAL_REGISTRATION",
                                   timeout=3)
