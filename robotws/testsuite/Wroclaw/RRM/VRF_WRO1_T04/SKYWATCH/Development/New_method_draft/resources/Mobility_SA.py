from ue_profiles import *
from ue_rrc_resume_reestab import *
from tput import *
from ue_measurements import *
from ue_state import *
from decorators import *


def inter_cell_ho_loop(ue_id=1, num_of_loops=2):
    ue_id = int(ue_id)
    register_ue_with_default_pdu_session(ue_id=ue_id)
    start_continuous_udp_traffic(ue_id=ue_id, pdu=1, qfi=1, direction='dl', speed='mbps=2')
    time.sleep(1)
    for i in range(1, int(num_of_loops)+1):
        trigger_handover_by_a3(ue_id=ue_id, phy_cell_id='51')
        time.sleep(2)
        trigger_handover_by_a3(ue_id=ue_id, phy_cell_id='50')
        logger.info(f"Handover loop nr: {i}", also_console=True)
        time.sleep(2)
    deregister_ue_by_switch_off(ue_id=ue_id)
