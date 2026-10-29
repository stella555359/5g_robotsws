from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

PARAM_ACTINCREASEDFDMUSERPERSLOT_ENABLE = [
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-1',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-2',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-3',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-4',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-5',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-6',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-7',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='true')
]

PARAM_ACTINCREASEDFDMUSERPERSLOT_DISABLE = [
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-1',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-2',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-3',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-4',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-5',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-6',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false'),
    dict(
         abbr='actIncreasedFdmUsersPerSlot',
         dist_name=_NRBTSname + '/NRCELL-7',
         filter_param='Activate increased frequency domain multiplexed users per slot',
         new_value='false')
]

COUNTERS_LTE_TP = [
    dict(
         counter_id='M8012C22',
         dist_name='CELLS/LNCEL-10/MCC-262_MNC-03/LTE Cell Throughput',
         full_path='CELLS/LNCEL-10/MCC-262_MNC-03/LTE_Cell_Throughput/PDCP_DATA_RATE_MAX_UL'
         ),
    dict(
         counter_id='M8012C25',
         dist_name='CELLS/LNCEL-10/MCC-262_MNC-03/LTE Cell Throughput',
         full_path='CELLS/LNCEL-10/MCC-262_MNC-03/LTE_Cell_Throughput/PDCP_DATA_RATE_MAX_DL'
         )
]
