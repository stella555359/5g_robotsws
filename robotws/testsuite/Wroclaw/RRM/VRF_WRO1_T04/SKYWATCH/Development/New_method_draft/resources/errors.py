# from common import *


def setup_no_sending_rrcsetup_req(ue_id):
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                            f" profile_id=1 action=activate")
    time.sleep(1)


def setup_no_sending_rrcsetupcomplete(ue_id):
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                            f" profile_id=2 action=activate")
    time.sleep(1)


def deactivate_no_responding_to_rrc_messages(ue_id):
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                            f" profile_id=1 action=deactivate")
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=contention_resolution"
                            f" profile_id=2 action=deactivate")
    time.sleep(1)
