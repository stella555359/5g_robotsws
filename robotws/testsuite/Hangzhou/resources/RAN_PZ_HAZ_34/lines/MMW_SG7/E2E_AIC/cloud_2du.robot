*** Settings ***
Suite Setup    Suite Setup For Aic BTS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic

Documentation    Suite description
...   Author:      Li Zhiguo
...   Contact:     zhiguo.li@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     AIC basic

Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
Resource    ../../MMW_SG8/resources_aic/DevHZ5_resource_aic_ST.robot
Resource    ../Cloud_VRAN40/vDU.robot

*** Variables ***
${DEBUG}    True
${SNAPSHOT_FLAG}     pass:False,fail:True
@{CU_Pods}    cpif    cpue
@{DU_Pods}    cprt
${RESOURCES_LEAKAGE_FLAG}    ${False}
${vDU_DN_MRBTS}    MRBTS-37730
@{du1_rmods_list}    1    2    3
@{du2_rmods_list}    1
@{du1_cells_list}    1    2    11    12    21    22    23    24
@{du2_cells_list}    31    32    33
${retry_times}    1
${Allowed_Faults_Ids_AiC}   4405,16,4298,49,7504,4647,61631,1898,4153
@{FAULTS_EXCLUDED_CHECKING}    7307    7311    4647    61631    1898    4153

*** Test Cases ***
Cloud_E2E_Case
    RANNIC reset for some times
    Cell block and unblock for some times
    RMOD lock and unlock for some times
    RU reset for some times
    Mixed operations check
    Pods reset check
    vCU and vDU reset for some times
    Lock and unlock cell operations on vCU
    Lock and unlock NG link operations on vCU
    Lock and unlock slice operations on vCU
#    Lock and unlock XN operations on vCU

*** Keywords ***
Suite Setup For Aic BTS Env
    Common Suite Setup Aic 2Du

Mixed operations check
    log to console     //Mixed operations check: DU-1 RMOD lock and then reset RANNIC
    ${du_conn}=    Connect to vdu via rest api    du_index=0
    Lock RU    rmods_list=${du1_rmods_list}    cells_list=${du1_cells_list}    du_connection=${du_conn}    du_index=0
    Check the RANNIC reset and then pods status    du_connection=${du_conn}    du_index=0    cells_list=${du1_cells_list}
    Unlock RU    rmods_list=${du1_rmods_list}    cells_list=${du1_cells_list}    du_connection=${du_conn}
    Teardown vdu connection    connection=${du_conn}
    log to console     //Mixed operations check: DU-2 RMOD lock and then reset RANNIC
    ${du_conn}=    Connect to vdu via rest api    du_index=1
    Lock RU    rmods_list=${du2_rmods_list}    cells_list=${du2_cells_list}    du_connection=${du_conn}    du_index=1
    Check the RANNIC reset and then pods status    du_connection=${du_conn}    du_index=1    cells_list=${du2_cells_list}
    Unlock RU    rmods_list=${du2_rmods_list}    cells_list=${du2_cells_list}    du_connection=${du_conn}
    Teardown vdu connection    connection=${du_conn}

Lock RU
    [Arguments]    ${rmods_list}    ${cells_list}    ${du_connection}    ${du_index}=0
    Perform RMOD lock    rmods_list=${rmods_list}    connection=${du_connection}
    ${DU_STATE_ret}    Run Keyword If    '${du_index}' == '0'    Get Du State Aic    ELSE IF    '${du_index}' == '1'    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Run Keyword If    '${du_index}' == '0'    Check No New Active Faultid Exist Du    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
    ...    ELSE IF    '${du_index}' == '1'    Check No New Active Faultid Exist Du2    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
    Check fault and alarm 7114 exist on vCU    cells_list=${cells_list}

Unlock RU
    [Arguments]    ${rmods_list}    ${cells_list}    ${du_connection}
    Perform RMOD unlock    rmods_list=${rmods_list}    timeout=2min    connection=${du_connection}
    Check fault and alarm 7114 non-exist on vCU    cells_list=${cells_list}
    Aic Cells Should Be Onair
    Check No New Active Faults

RANNIC reset for some times
    ${du_conn}=    Connect to vdu via rest api    du_index=0
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-1 Rannic reset
        Check the RANNIC reset operation    du_connection=${du_conn}    du_index=0    cells_list=${du1_cells_list}
    END
    Teardown vdu connection    connection=${du_conn}
    ${du_conn}=    Connect to vdu via rest api    du_index=1
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-2 Rannic reset
        Check the RANNIC reset operation    du_connection=${du_conn}    du_index=1    cells_list=${du2_cells_list}
    END
    Teardown vdu connection    connection=${du_conn}

RU reset for some times
    ${du_conn}=    Connect to vdu via rest api    du_index=0
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-1 RUs reset
        Check the reset RUs    rmods_list=${du1_rmods_list}    cells_list=${du1_cells_list}    du_connection=${du_conn}    du_index=0
    END
    Teardown vdu connection    connection=${du_conn}
    ${du_conn}=    Connect to vdu via rest api    du_index=1
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-2 RUs reset
        Check the reset RUs    rmods_list=${du2_rmods_list}    cells_list=${du2_cells_list}    du_connection=${du_conn}    du_index=1
    END
    Teardown vdu connection    connection=${du_conn}

vCU and vDU reset for some times
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do vCU and vDU reset
        vCU and vDU reset
    END

Cell block and unblock for some times
    ${du_conn}=    Connect to vdu via rest api    du_index=0
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-1 cell block and unblock
        Cell block and unblock check    cells_list=${du1_cells_list}    du_connection=${du_conn}    du_index=0
    END
    Teardown vdu connection    connection=${du_conn}
    ${du_conn}=    Connect to vdu via rest api    du_index=1
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-2 cell block and unblock
        Cell block and unblock check    cells_list=${du2_cells_list}    du_connection=${du_conn}    du_index=1
    END
    Teardown vdu connection    connection=${du_conn}

RMOD lock and unlock for some times
    ${du_conn}=    Connect to vdu via rest api    du_index=0
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-1 RMOD lock and unlock
        RMOD lock and unlock check    rmods_list=${du1_rmods_list}    cells_list=${du1_cells_list}    du_connection=${du_conn}    du_index=0
    END
    Teardown vdu connection    connection=${du_conn}
    ${du_conn}=    Connect to vdu via rest api    du_index=1
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do DU-2 RMOD lock and unlock
        RMOD lock and unlock check    rmods_list=${du2_rmods_list}    cells_list=${du2_cells_list}    du_connection=${du_conn}    du_index=1
    END
    Teardown vdu connection    connection=${du_conn}

Aic Cells Should Be Onair
    ${onair_status}  Wait Aic BTS Onair And Return Status
    Run Keyword If  '${onair_status}'=='${False}'    Fail

Check the RANNIC reset operation
    [Arguments]    ${du_connection}    ${du_index}=0    ${cells_list}=${du1_cells_list}
    ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${vDU_DN_MRBTS}    connection=${du_connection}
    Perform RANNIC reset    mrbts_id=${vDU_DN_MRBTS}    list_rannic_r_dn=${list_rannic_r_dn}    connection=${du_connection}
    Check fault and alarm 7114 exist on vCU    cells_list=${cells_list}
    ${DU_STATE_ret}    Run Keyword If    '${du_index}' == '0'    Get Du State Aic    ELSE IF    '${du_index}' == '1'    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Aic Cells Should Be Onair
    Check No New Active Faults

Check the RANNIC reset and then pods status
    [Arguments]    ${du_connection}    ${du_index}=0    ${cells_list}=${du1_cells_list}
    ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${vDU_DN_MRBTS}    connection=${du_connection}
    Perform RANNIC reset    mrbts_id=${vDU_DN_MRBTS}    list_rannic_r_dn=${list_rannic_r_dn}    connection=${du_connection}
    Check fault and alarm 7114 exist on vCU    cells_list=${cells_list}
    ${DU_STATE_ret}    Run Keyword If    '${du_index}' == '0'    Get Du State Aic    ELSE IF    '${du_index}' == '1'    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Wait Until Keyword Succeeds  10min  30s    Check All Pods Is Running
#    Check No New Active Faults

Pods reset check
    Log to console    reset Pod in vCU
    FOR    ${pod}    IN    @{CU_Pods}
        Restart Pod And Check All Pod Is Running In Aic vCU    ${pod}
    END
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults
    Log to console    reset Pod in vDU
    FOR    ${pod}    IN    @{DU_Pods}
        Restart Pod And Check All Pod Is Running In Aic vDU    ${pod}
        Restart Pod And Check All Pod Is Running In Aic vDU2    ${pod}
    END
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults

vCU and vDU reset
    Log to console    reset vDU
    DevHZ5_lib_aic.reset_du
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults
    Log to console    reset vCU
    DevHZ5_lib_aic.reset_cu
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults

Check the reset RUs
    [Arguments]    ${rmods_list}    ${cells_list}    ${du_connection}    ${du_index}=0
    Perform reset RUs    rmods_list=${rmods_list}    connection=${du_connection}
    sleep  60s
    Check fault and alarm 7114 exist on vCU    cells_list=${cells_list}
    ${DU_STATE_ret}    Run Keyword If    '${du_index}' == '0'    Get Du State Aic    ELSE IF    '${du_index}' == '1'    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Aic Cells Should Be Onair
    Check No New Active Faults

RMOD lock and unlock check
    [Arguments]    ${rmods_list}    ${cells_list}    ${du_connection}    ${du_index}=0
    Perform RMOD lock    rmods_list=${rmods_list}    connection=${du_connection}
    ${DU_STATE_ret}    Run Keyword If    '${du_index}' == '0'    Get Du State Aic    ELSE IF    '${du_index}' == '1'    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Run Keyword If    '${du_index}' == '0'    Check No New Active Faultid Exist Du    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
    ...    ELSE IF    '${du_index}' == '1'    Check No New Active Faultid Exist Du2    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
    Check fault and alarm 7114 exist on vCU    cells_list=${cells_list}
    Perform RMOD unlock    rmods_list=${rmods_list}    connection=${du_connection}
    Check fault and alarm 7114 non-exist on vCU    cells_list=${cells_list}
    Aic Cells Should Be Onair
    Check No New Active Faults

Cell block and unblock check
    [Arguments]    ${cells_list}    ${du_connection}    ${du_index}=0
    Perform Cells block    cells_list=${cells_list}    connection=${du_connection}
    ${DU_STATE_ret}    Run Keyword If    '${du_index}' == '0'    Get Du State Aic    ELSE IF    '${du_index}' == '1'    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Run Keyword If    '${du_index}' == '0'    Check fault 49 and alarm 7102 exist on vDU    cells_list=${cells_list}
    ...    ELSE IF    '${du_index}' == '1'    Check fault 49 and alarm 7102 exist on vDU2    cells_list=${cells_list}
    Perform Cells unblock    cells_list=${cells_list}    connection=${du_connection}
    Run Keyword If    '${du_index}' == '0'    Check fault 49 and alarm 7102 non-exist on vDU    cells_list=${cells_list}
    ...    ELSE IF    '${du_index}' == '1'    Check fault 49 and alarm 7102 non-exist on vDU2    cells_list=${cells_list}
    Aic Cells Should Be Onair
    Check No New Active Faults

Check fault 4261 and alarm 7114 non-exist on vDU
    [Arguments]    ${fault_id}=4261    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Cell disabled due to unknown problem; logs collected
    ...    ${alarming_object_cell1}=NRCELL-1
    ...    ${alarming_object_cell2}=NRCELL-2
    ${fault4261_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell1}
    Fm Fault Should Be Cleared Du Aic    ${fault4261_alarm7114}
    ${fault4261_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell2}
    Fm Fault Should Be Cleared Du Aic    ${fault4261_alarm7114}

Check fault 4261 and alarm 7114 exist on vDU
    [Arguments]    ${fault_id}=4261    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Cell disabled due to unknown problem; logs collected
    ...    ${alarming_object_cell1}=NRCELL-1
    ...    ${alarming_object_cell2}=NRCELL-2
    ${fault4261_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell1}
    Fm Fault Should Be Raised Du Aic    ${fault4261_alarm7114}
    ${fault4261_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell2}
    Fm Fault Should Be Raised Du Aic    ${fault4261_alarm7114}

Check fault 49 and alarm 7102 exist on vDU
    [Arguments]    ${fault_id}=49    ${alarm_id}=7102    ${severity}=Critical
    ...    ${alarm_name}=BASE STATION RESOURCE BLOCKED BY USER
    ...    ${fault_name}=Cell blocked
    ...    ${cells_list}=${du1_cells_list}
    FOR    ${cell_id}    IN    @{cells_list}
        ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
        ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=NRCELL-${cell_id}
        Fm Fault Should Be Raised Du Aic    ${fault49_alarm7102}
    END

Check fault 49 and alarm 7102 exist on vDU2
    [Arguments]    ${fault_id}=49    ${alarm_id}=7102    ${severity}=Critical
    ...    ${alarm_name}=BASE STATION RESOURCE BLOCKED BY USER
    ...    ${fault_name}=Cell blocked
    ...    ${cells_list}=${du1_cells_list}
    FOR    ${cell_id}    IN    @{cells_list}
        ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
        ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=NRCELL-${cell_id}
        Fm Fault Should Be Raised Du2 Aic    ${fault49_alarm7102}
    END

Check fault 49 and alarm 7102 non-exist on vDU
    [Arguments]    ${fault_id}=49    ${alarm_id}=7102    ${severity}=Critical
    ...    ${alarm_name}=BASE STATION RESOURCE BLOCKED BY USER
    ...    ${fault_name}=Cell blocked
    ...    ${cells_list}=${du1_cells_list}
    FOR    ${cell_id}    IN    @{cells_list}
        ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
        ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=NRCELL-${cell_id}
        Fm Fault Should Be Cleared Du Aic    ${fault49_alarm7102}
    END

Check fault 49 and alarm 7102 non-exist on vDU2
    [Arguments]    ${fault_id}=49    ${alarm_id}=7102    ${severity}=Critical
    ...    ${alarm_name}=BASE STATION RESOURCE BLOCKED BY USER
    ...    ${fault_name}=Cell blocked
    ...    ${cells_list}=${du1_cells_list}
    FOR    ${cell_id}    IN    @{cells_list}
        ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
        ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=NRCELL-${cell_id}
        Fm Fault Should Be Cleared Du2 Aic    ${fault49_alarm7102}
    END

Check fault and alarm 7114 exist on vCU
    [Arguments]    ${fault_id}=7104    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Matching ServedCell not found over F1-C
    ...    ${cells_list}=${du1_cells_list}
    FOR    ${cell_id}    IN    @{cells_list}
        ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
        ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=NRCELL-${cell_id}
        Fm Fault Should Be Raised Cu Aic    ${fault7104_alarm7114}
    END

Check fault and alarm 7114 non-exist on vCU
    [Arguments]    ${fault_id}=7104    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Matching ServedCell not found over F1-C
    ...    ${cells_list}=${du1_cells_list}
    FOR    ${cell_id}    IN    @{cells_list}
        ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
        ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=NRCELL-${cell_id}
        Fm Fault Should Be Cleared Cu Aic    ${fault7104_alarm7114}
    END

Lock and unlock NG link operations on vCU
    Log to console    Begin to NG lock
    Disable NG Link1
    Disable NG Link2
    Disable NG Link3
    Check fault and alarm 7114 exist on vCU
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107
    ...    cells_list=${du1_cells_list}
    Check fault and alarm 7114 exist on vCU
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107
    ...    cells_list=${du2_cells_list}
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    ${DU_STATE_ret}    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Log to console    Begin to NG unlock
    Enable NG Link1
    Enable NG Link2
    Enable NG Link3
    Check fault and alarm 7114 non-exist on vCU
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107
    ...    cells_list=${du1_cells_list}
    Check fault and alarm 7114 non-exist on vCU
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107
    ...    cells_list=${du2_cells_list}
    Aic Cells Should Be Onair

Lock and unlock slice operations on vCU
    log to console    //this is do slice lock and unlock
    Lock slice 1
    unLock slice 1

Lock slice ${number}
    Delta Commission Parameters Cu    SNSSAI-${number}:administrativeState=Locked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu    SNSSAI-${number}:administrativeState=Locked

unLock slice ${number}
    Delta Commission Parameters Cu    SNSSAI-${number}:administrativeState=Unlocked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu    SNSSAI-${number}:administrativeState=Unlocked

Lock and unlock XN operations on vCU
    log to console    //this is do Xn lock and unlock
    Xn lock
    Xn unlock

Xn lock
    Delta Commission Parameters Cu    NRADJGNB-1:administrativeState=Locked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist    XNLINK-1:xnLinkStatus=Unavailable

Xn unlock
    Delta Commission Parameters Cu     NRADJGNB-1:administrativeState=Unlocked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist    XNLINK-1:xnLinkStatus=available

Lock and unlock vDU operations on vCU
    log to console    //this is do vDU lock and unlock on vCu
    ${du_id_list}    Create List    1
    Cloud Lock vDU And Check Result    du_id_list=${du_id_list}
    Cloud Unlock vDU And Check Result    du_id_list=${du_id_list}

Lock and unlock cell operations on vCU
    Log to console    //this is do cell lock and unlock on vCU
    Lock Cell1
    Lock Cell2
    Lock Cell11
    Lock Cell12
    Lock Cell21
    Lock Cell22
    Lock Cell23
    Lock Cell24
    Unlock Cell1
    Unlock Cell2
    Unlock Cell11
    Unlock Cell12
    Unlock Cell21
    Unlock Cell22
    Unlock Cell23
    Unlock Cell24
    Lock Cell31
    Lock Cell32
    Lock Cell33
    Unlock Cell31
    Unlock Cell32
    Unlock Cell33
