*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to admin API.
...  ******************
...  History of changes
...  ******************
...  - 19.05.2023 - Xu Yuyan commit to robotws
Library           OperatingSystem
Library           XML    use_lxml=True
Library           Collections
Library           String
#Library           hran_logging
#Library           hran_rest
#Resource          hran_frame_sbts_taf_oam.robot
Resource          hran_infomodel.robot
Resource          hran_admin.robot
#Library           hran_ims

*** Variables ***
${MRBTS}          ${EMPTY}
${LNBTS}          ${EMPTY}
${NOT_DEBIAN}     ${False}
${IGNORE_RAT}     []    # Cell status and RAT status in this list shall not be check.example:['WCDMA','GSM']
${ENB_ROOT_USER}    toor4nsn
${ENB_ROOT_PASS}    oZPS0POrRieRtu
${EXPECTANT_RATS_STATE_API}    ${EMPTY}    # The eight digit string represents the expected initial state and final state of NR,
# ...    LTE, WCDMA and GSM respectively. It is initialized in 'Setup RAT Data' and used in 'Get RATs State Duration'

*** Keywords ***
Check_SBTS_SMOD_RMOD_Cells_Alarms_BKInfomodel
    [Arguments]    ${timeout}=10 sec    ${print_table}=${False}
    [Documentation]    KW for wrapping functions for checking SBTS SMODs, RMODs, cell states and presence of active alarms
    LOG    Checking SBTS SMOD RMOD Cells status and Alarms    console=${True}
    ${are_smods_online}    ${smods_statuses}=    Infomodel Check If All Objects From Path Are Online    //SMOD_L-*    ${timeout}    ${print_table}
    ${are_rmods_online}    ${rmods_statuses}=    Infomodel Check If All Objects From Path Are Online
    ...    //EQM_R-*//RMOD_R-*    ${timeout}    ${print_table}
    ${are_cells_online}    ${cells_statuses}=    Infomodel Check If All Objects From Path Are Online
    ...    /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*    ${timeout}    ${print_table}    administrativeState=Unlocked
    ...    blockingState=Unblocked    operationalState=Enabled    proceduralState=OnAirDone    availabilityStatus=Online
    Admin Check Active Alarms    print_alarms=${print_table}
    Should be true    ${are_smods_online} and ${are_cells_online} and ${are_rmods_online}    Not all conditions were satisfied!

Get Current Name And Status Of All Cells
    [Arguments]    ${cell_name_type}=SCF_NAME
    [Documentation]    Get cell configuration names or internal names and their statuses.
    ...    Return two dictionaries, first dictionary contains mapping of cell onfiguration name and cell internal name,
    ...    second dictionary contains cell statuses.
    ...    Key of dictionaries shall be configuration name if ${cell_name_type} is 'SCF_NAME'
    ...    Key of dictionaries shall be configuration name if ${cell_name_type} is 'RUNTIME_NAME'
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | cell_name_type | No | Keys of dictionaries is configuration name or internal name, default vaule is SCF_NAME |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | scf_runtime_name_mapper \ | Dictionary contains mapping of cell onfiguration name and cell internal name |
    ...    | all_cell_status | Dictionary contains cell statuses |
    ...
    ...    *EXAMPLE*
    ...    | ${scf_runtime_name_mapper} | ${all_cell_status} | Get Current Name And Status Of All Cells | |
    ...    ${scf_runtime_name_mapper} = {'MRBTS-1815/GNBTS-1/GNBCF-1/GNCEL-1':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1',
    ...    'MRBTS-1815/LNBTS-3542/LNCEL-1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-1',
    ...    'MRBTS-1815/NRBTS-5487/NRCELL-1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-5487/NRCELL_R-1',
    ...    'MRBTS-1815/WNBTS-1/WNCEL-19081': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/WNBTS_R-1/WNCEL_R-19081'}
    ...    ${all_cell_status} = {'MRBTS-1815/GNBTS-1/GNBCF-1/GNCEL-1': {'administrativeState': 'Unlocked','availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Active'},
    ...    'MRBTS-1815/LNBTS-3542/LNCEL-1': {'administrativeState': 'Unlocked','availabilityStatus': 'Online','blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled','usageState': 'Idle'},
    ...    'MRBTS-1815/NRBTS-5487/NRCELL-1': {'administrativeState': 'Unlocked','availabilityStatus': 'Online','blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled','proceduralStatus': 'configured','usageState': 'Active'},
    ...    'MRBTS-1815/WNBTS-1/WNCEL-19081': {'availabilityStatus': 'Online','blockingState': 'Unblocked','operationalState': 'Enabled',
    ...    'usageState': 'Active'}}
    ...
    ...    | ${scf_runtime_name_mapper} | ${all_cell_status} | Get Current Name And Status Of All Cells | RUNTIME_NAME |
    ...    ${scf_runtime_name_mapper} = {
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1':'MRBTS-1815/GNBTS-1/GNBCF-1/GNCEL-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-1': 'MRBTS-1815/LNBTS-3542/LNCEL-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-5487/NRCELL_R-1': 'MRBTS-1815/NRBTS-5487/NRCELL-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/WNBTS_R-1/WNCEL_R-19081': 'MRBTS-1815/WNBTS-1/WNCEL-19081'}
    ...    ${all_cell_status} = {'/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1':
    ...    {'administrativeState': 'Unlocked','availabilityStatus': 'Online','blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled','usageState': 'Active'},
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-1': {'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online','blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Idle'},
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-5487/NRCELL_R-1': {'administrativeState': 'Unlocked','availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked','operationalState': 'Enabled','proceduralStatus': 'configured','usageState': 'Active'},
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/WNBTS_R-1/WNCEL_R-19081': {'availabilityStatus': 'Online','blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled','usageState': 'Active'}}
    ${cell_list}    coam.Get Cell List
    ${name_type_mapper}    Create Dictionary    SCF_NAME=configuration    RUNTIME_NAME=internal
    ${name_type}    Pop From Dictionary    ${name_type_mapper}    ${cell_name_type}
    ${value_list}    Get Dictionary Values    ${name_type_mapper}
    ${value_type}    Set Variable    ${value_list[0]}
    ${empty_list}    Create List
    ${GSM_cells}    Pop From Dictionary    ${cell_list['cells']}    gsm    ${empty_list}
    ${WCDMA_cells}    Pop From Dictionary    ${cell_list['cells']}    wcdma    ${empty_list}
    ${LTE_cells}    Pop From Dictionary    ${cell_list['cells']}    lte    ${empty_list}
    ${NR_cells}    Pop From Dictionary    ${cell_list['cells']}    nr    ${empty_list}
    ${scf_runtime_name_mapper}    Create Dictionary
    ${all_cell_status}    Create Dictionary
    FOR    ${cell}    IN    @{GSM_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{WCDMA_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    administrativeState
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{LTE_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{NR_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    [Return]    ${scf_runtime_name_mapper}    ${all_cell_status}
