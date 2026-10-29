*** Settings ***
Documentation    Keywords using ute_admin_infomodel library
...              Resource used by RF Sharing Vrf tribe
...              Author: Dinu Olariu
...              Contact: dinu.olariu@nokia.com

Library  Collections
Library  SSHLibrary
Library  String
Library  python_resources/alarms_analysis.py

*** Variables ***
${dist_radio}=              //EQM_L-1//RMOD_L-*
${dist_smod}=               //EQM_L-1//SMOD_L-*
${dist_LTE_cell}=           /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*
${dist_WCDMA_cell}=         /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
${dist_GSM_cell}=           /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*
${dist_NR_cell}=            /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/NRBTS_M-*/CELL_M-*
${dist_cells}=              /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*   #old //LNBTS-1/LCELL-*
${dist_bts}=                /MRBTS-1/RAT-1/BTS_L-*/LNBTS-1                  #old //BTS_L-*/LNBTS-* & //RAT-1/BTS_L-* & /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1
${dist_LTE_bts}=            /MRBTS-1/RAT-1//LNBTS-1
${dist_SW_version}=         /MRBTS-1/RAT-1//BTS_CONF-1                          #old //BTS_L-*/BTS_CONF-*
${dist_commissioning}=      /MRBTS-1/RAT-1//BTS_CONF-1/CONFIGURATION_FILE-1     #old //BTS_CONF-*/CONFIGURATION_FILE-*

*** Keywords ***
Infomodel Check FHS state
    [Documentation]
    ...  Helper keyword checking FHS states.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                     | Man. | Default | Description                               |
    ...  | FHS_list                      | Yes  |         | list of FHS Ids to be checked             |
    ...  | exp_operationalState_check    | Yes  |         | expected FHS operationalState as regex    |
    ...  | exp_operationalState          | Yes  |         | expected FHS operationalState             |
    ...  | exp_availabilityStatus_check  | Yes  |         | expected FHS availabilityStatus as regex  |
    ...  | exp_availabilityStatus        | Yes  |         | expected FHS availabilityStatus           |
    ...  | exp_administrativeState_check | Yes  |         | expected FHS administrativeState as regex |
    ...  | exp_administrativeState       | Yes  |         | expected FHS administrativeState          |
    ...  | tech                          | No   | NR      | BTS technology                            |
    ...  | timeout                       | No   | 60      | time in seconds after which KW will fail  |
    ...  | alias                         | No   | default | alias of ute_admin_infomodel instance     |
    ...
    ...  *RETURN*
    ...  KW is passed if expected states are correlated with FHS states, otherwise failed

    [Arguments]  ${FHS_list}  ${exp_operationalState_check}  ${exp_operationalState}  ${exp_availabilityStatus_check}  ${exp_availabilityStatus}
    ...  ${exp_administrativeState_check}  ${exp_administrativeState}  ${tech}=NR  ${timeout}=60  ${alias}=default
    FOR  ${item}  IN  @{FHS_list}
        ${Obj_info}=  Query infomodel  query=get object ${item}  alias=${alias}
        ${Obj_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${Obj_info['stateInfo']}
        ${query1}=  Create Long String  ${item} is [stateInfo.operationalState=${exp_operationalState_check},
        ...  stateInfo.availabilityStatus=${exp_availabilityStatus_check}, stateInfo.administrativeState=${exp_administrativeState_check}]
        ${query2}=  Create Long String  ${item} is [operationalState=${exp_operationalState_check},
        ...  availabilityStatus=${exp_availabilityStatus_check}, administrativeState=${exp_administrativeState_check}]
        Run Keyword If  ${Obj_stateInfo}
        ...  Query infomodel  query=${query1}  timeout=${timeout}  alias=${alias}
        ...  ELSE
        ...  Query infomodel  query=${query2}  timeout=${timeout}  alias=${alias}
        Log Long String  ${tech} FHS ${item} status:\n - operationalState=${exp_operationalState}, availabilityStatus=${exp_availabilityStatus},
        ...  administrativeState=${exp_administrativeState}  console=True
    END

Get SMOD Primary info
    [Arguments]  ${SMOD_list}  ${alias}
    FOR  ${item}  IN  @{SMOD_list}
        ${SMOD_param}=  Query Infomodel  query=get object ${item}  alias=${alias}
        Exit For Loop If  '${SMOD_param['activeRole']}' == 'Primary'
    END
    ${Primary_SMOD_SN}=  Set Variable  ${SMOD_param['serialNumber']}

    ${SMOD_list}=  Query Infomodel  query=get list //SMOD-*  alias=${alias}
    FOR  ${item}  IN  @{SMOD_list}
        Exit For Loop If  '${item['serialNumber']}' == '${Primary_SMOD_SN}'
    END
    Set Test Variable  ${Primary_SMOD_DN}  ${item.dist_name}

Infomodel Check TRX state
    [Documentation]
    ...  Helper keyword checking TRX states.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man. | Default | Description                              |
    ...  | TRX_id                 | Yes  |         | TRX Id to be checked                     |
    ...  | exp_operationalState   | Yes  |         | expected TRX operationalState            |
    ...  | exp_availabilityStatus | Yes  |         | expected TRX availabilityStatus          |
    ...  | exp_blockingState      | Yes  |         | expected TRX blockingState               |
    ...  | timeout                | No   | 60      | time in seconds after which KW will fail |
    ...  | alias                  | No   | default | alias of ute_admin_infomodel instance    |
    ...
    ...  *RETURN*
    ...  KW is passed if expected states are correlated with TRX states, otherwise failed

    [Arguments]  ${TRX_id}  ${exp_operationalState}  ${exp_availabilityStatus}  ${exp_blockingState}  ${timeout}=60  ${alias}=default
    ${Obj_info}=  Query infomodel  query=get object ${TRX_id}  alias=${alias}
    ${Obj_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${Obj_info['stateInfo']}

    ${query1}=  Create Long String  ${TRX_id} is [stateInfo.operationalState=${exp_operationalState},
    ...  stateInfo.availabilityStatus=${exp_availabilityStatus}, stateInfo.blockingState=${exp_blockingState}]
    ${query2}=  Create Long String  ${TRX_id} is [operationalState=${exp_operationalState}, availabilityStatus=${exp_availabilityStatus},
    ...  blockingState=${exp_blockingState}]
    Run Keyword If  ${Obj_stateInfo}
    ...  Query infomodel  query=${query1}  timeout=${timeout}  alias=${alias}
    ...  ELSE
    ...  Query infomodel  query=${query2}  timeout=${timeout}  alias=${alias}

Infomodel Get LANE Operational State
    [Documentation]
    ...  Helper keyword providing LANE Operational State.
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description                       |
    ...  | LANE_Id   | Yes  |         | LANE Id to be checked             |
    ...  | alias     | Yes  |         | alias of admin_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                  |
    ...  | LANE_operationalState    | LANE Id operational state |

    [Arguments]  ${LANE_Id}  ${alias}
    ${LANE_R_obj} =  Query Infomodel  get object ${LANE_Id}  alias=${alias}
    ${LANE_operationalState}=  Set Variable  ${LANE_R_obj.operationalState}
    [Return]  ${LANE_operationalState}

Infomodel reconnect session
    [Documentation]
    ...  Helper keyword for Infomodel reconnect session
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter       | Man. | Default | Description                                                       |
    ...  | alias           | Yes  |         | alias of admin/admin_infomodel instance                           |
    ...  | connection_type | Yes  |         | Admin connection type. Can be ssh_tunnel, oam_ip, admin_forwarder |
    ...
    [Arguments]  ${alias}  ${connection_type}
    Disconnect Infomodel  alias=${alias}
    Teardown Infomodel  alias=${alias}
    Log  Current Infomodel session stopped  console=True
    Log  Reconnect Infomodel session  console=True
    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
    Run Keyword If  '${alias_tech}' in ['NR','LTE','SBTS','SRAN']
    ...  Start ADMIN_INFOMODEL On  alias=${alias}  connection_type=${connection_type}

