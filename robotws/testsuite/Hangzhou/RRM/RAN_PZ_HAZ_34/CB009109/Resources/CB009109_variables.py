import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

CHECK_DRX_INFORMATION_LIST = [
    {'target_milliSeconds': '7',
     'target_InactivityTimer': '9',
     'target_HARQ_Timer': '14',
     'target_RetransmissionTimer': '4',
     'target_LongCycleStartOffset': '7'
     },
    {'target_milliSeconds': '7',
     'target_InactivityTimer': '8',
     'target_HARQ_Timer': '28',
     'target_RetransmissionTimer': '5',
     'target_LongCycleStartOffset': '3'
     },
    {'target_milliSeconds': '7',
     'target_InactivityTimer': '9',
     'target_HARQ_Timer': '0',
     'target_RetransmissionTimer': '0',
     'target_LongCycleStartOffset': '13'
     },
    {'target_milliSeconds': '7',
     'target_InactivityTimer': '9',
     'target_HARQ_Timer': '0',
     'target_RetransmissionTimer': '0',
     'target_LongCycleStartOffset': '13'
     },
    {'target_milliSeconds': '7',
     'target_InactivityTimer': '8',
     'target_HARQ_Timer': '28',
     'target_RetransmissionTimer': '5',
     'target_LongCycleStartOffset': '3'},
]
