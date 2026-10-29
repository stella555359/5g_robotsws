from taf.rfrl.utilities.tl_config import get_global_bts_id

global_bts_id = get_global_bts_id()

localAccessBlockingMode_disabled = {f'MRBTS-{global_bts_id}/MNL-1/MNLENT-1/SECADM-1':
                                    {'localAccessBlockingMode': 'Disabled'}}

activation_delta = [
    {
        'distName': 'ASI-1/SECPRM-1',
        'parameters': [
            {'parameterName': 'btsEMRestrictAccSession', 'value': 'NoRWsessionAllowed', 'operation': 'update'},
        ]
    }
]

deactivation_delta = [
    {
        'distName': 'ASI-1/SECPRM-1',
        'parameters': [
            {'parameterName': 'btsEMRestrictAccSession', 'value': 'RWsessionCtrlNotActivated', 'operation': 'update'},
        ]
    }
]
