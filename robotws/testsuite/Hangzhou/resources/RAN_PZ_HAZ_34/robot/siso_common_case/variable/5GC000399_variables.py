import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# 5GC000399_eCPRI_FREERUN_state_handling
TOP_DOMAIN_NUMBER_MODIFY = [
    dict(dist_name='MRBTS-{mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
         list_name=None,
         filter_param='ToP domain number',
         p_name='topDomainNumber',
         value='43')
]
