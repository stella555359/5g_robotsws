*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${EXPECTED_Fault_ID}    4614
${Recovery_Flag}        False
*** Keywords ***
SyVe_CM_Verify_Alarm_Monitoring_From_OSS_Viewing_and_Ceasing
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    For case:Top50 optus acceptance case,Verify Alarm Monitoring from OSS viewing, ceasing
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Block RAT To Trigger Fault And Check on Netact
    ...    - Unblock RAT To Trigger Fault And Check on Netact
    ...    - Cancel and upload Alarm On Netact
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: Alarm could be uploaded to the netact and alarm could be cancel on netact.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.05.2024 - New case

    Set Tags    AUTHOR-yuan.1.gao@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Block RAT To Trigger Fault And Check On Netact
    Step 6: Unblock RAT To Trigger Fault And Check On Netact
    Step 7: Cancel And Upload Alarm On Netact
    Step 8: Check final alarms status from WebEM
    Step 9: Check final alarms status from Netact
    Step 10: Check final BTS state

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If     '${when}'!='initial'
    ${NR_parameters_list}    ${LNCEL_parameters_list}    ${WNCEL_parameters_list}   ${GNCEL_parameters_list}    Get BTS CELL parameters list
    Run Keyword If    "${NR_parameters_list.__len__()}">"${0}"    Set Test Variable    ${RAT_TO_BLOCK}    NR
    ...     ELSE IF    "${LNCEL_parameters_list.__len__()}">"${0}"    Set Test Variable    ${RAT_TO_BLOCK}    LTE
    ...     ELSE IF    "${WNCEL_parameters_list.__len__}">"${0}"    Set Test Variable    ${RAT_TO_BLOCK}    WCDMA
    ...     ELSE    "${GNCEL_parameters_list.__len__}">"${0}"    Set Test Variable    ${RAT_TO_BLOCK}    GSM

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: ${when} RAT To Trigger Fault And Check On Netact
    Log    Step ${index}: ${when} RAT To Trigger Fault And Check On Netact    console=True
    Run Keyword If    '${when}'=='Block'    Run Keywords    coam.Block RAT    ${RAT_TO_BLOCK}
    ...    AND   Set Test Variable    ${Recovery_Flag}    True
    ...    ELSE    Run Keywords    coam.Unblock RAT    ${RAT_TO_BLOCK}
    ...    AND     Set Test Variable    ${Recovery_Flag}    False
    Sleep    60s
    ${status}     Check Fault Is Existed On Netact     ${MRBTS_DN}    ${EXPECTED_Fault_ID}
    Run Keyword If    '${when}'=='Block'    Should Be True    ${status}
    ...    ELSE    Should Not Be True    ${status}

Step ${index}: Cancel And Upload Alarm On Netact
    Log    Step ${index}: Cancel Alarm On Netact    console=True
    ${Alarm_Netact_Current}    Get Active Alarms From Netact    dist_name=${MRBTS_DN}
    netact.Cancel Alarms    dist_name=${MRBTS_DN}    include_subnetworks=True
    ${alarms}     netact.Get Alarms     dist_name=${MRBTS_DN}
    ${length}     Get Length      ${alarms}
    Should Be True    '${length}'=='0'
    netact.Upload alarms    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check Fault Is Existed On Netact
    [Arguments]    ${MRBTS_DN}    ${Id}
    ${Active_Alarm_Netact}    Get Active Alarms From Netact    dist_name=${MRBTS_DN}
    ${result}    Set Variable    ${False}
    FOR    ${Item}    IN    @{Active_Alarm_Netact}
        ${result}    Set Variable If    '${Item["faultId"]}'=='${Id}'    ${True}    ${result}
        Exit For Loop If    '${Item["faultId"]}'=='${Id}'
    END
    [Return]    ${result}

Get BTS CELL parameters list
    ${BTS_CELL_list}=  coam.Get Cell List
    ${NR_CELL_parameters_list}=  Create List
    ${LTE_CELL_parameters_list}=  Create List
    ${WCDMA_CELL_parameters_list}=  Create List
    ${GSM_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['nr']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['cellDepType']}
        ...  ${item['globalCellId']}
        Append To List  ${NR_CELL_parameters_list}  ${temp}
    END
    Sort List  ${NR_CELL_parameters_list}
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['lte']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['globalCellId']}
        ...  ${item['narrowbandIotMode']}
        ...  ${item['cellName']}
        ...  ${item['eutranCellId']}
        ...  ${item['downlinkMimoMode']}
        ...  ${item['technology']}
        Append To List  ${LTE_CELL_parameters_list}  ${temp}
    END
    Sort List  ${LTE_CELL_parameters_list}
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['wcdma']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['cellId']}
        Append To List  ${WCDMA_CELL_parameters_list}  ${temp}
    END
    Sort List  ${WCDMA_CELL_parameters_list}
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['gsm']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['gsmSectorID']}
        Append To List  ${GSM_CELL_parameters_list}  ${temp}
    END
    Sort List  ${GSM_CELL_parameters_list}
    [Return]  ${NR_CELL_parameters_list}  ${LTE_CELL_parameters_list}  ${WCDMA_CELL_parameters_list}  ${GSM_CELL_parameters_list}

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If    '${Recovery_Flag}'=='True'    Run Keywords    coam.reset
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown
