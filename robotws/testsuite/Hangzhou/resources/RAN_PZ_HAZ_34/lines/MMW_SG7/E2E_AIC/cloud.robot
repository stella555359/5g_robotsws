*** Settings ***
Suite Setup    Suite Setup For Aic BTS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic

Documentation    Suite description
...   Author:      zhu baijie
...   Contact:     baijie.zhu@nokia-sbell.com
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
${vDU_DN_MRBTS}    MRBTS-37390
@{rmods_list}    1    2
@{cells_list}    1    2    12    13
${retry_times}    1

${Allowed_Faults_Ids_AiC}   4405,16,4298,49,7504,4675
@{FAULTS_EXCLUDED_CHECKING}
...    7307    7311    7325

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
    [Arguments]    ${scf}=SCF_SBTS00.xml
    Setup BTS Env Aic   scf=${scf}

Mixed operations check
    log to console     //Mixed operations check: RMOD lock and then reset RANNIC
    Connect to vdu via rest api
    Lock RU
    Check the RANNIC reset and then pods status
    [Teardown]    Unlock RU

Lock RU
    Perform RMOD lock    rmods_list=${rmods_list}
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Check No New Active Faultid Exist Du    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
    Check fault and alarm 7114 exist on vCU

Unlock RU
    Perform RMOD unlock    rmods_list=${rmods_list}    timeout=2min
    Check fault and alarm 7114 non-exist on vCU
    Aic Cells Should Be Onair
    Check No New Active Faults
    Teardown vdu connection

RANNIC reset for some times
    Connect to vdu via rest api
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do Rannic reset
        Check the RANNIC reset operation
    END
    Teardown vdu connection

RU reset for some times
    Connect to vdu via rest api
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do RUs reset
        Check the reset RUs
    END
    Teardown vdu connection

vCU and vDU reset for some times
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do vCU and vDU reset
        vCU and vDU reset
    END

Cell block and unblock for some times
    Connect to vdu via rest api
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do cell block and unblock
        Cell block and unblock check
    END
    Teardown vdu connection

RMOD lock and unlock for some times
    Connect to vdu via rest api
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} times do RMOD lock and unlock
        RMOD lock and unlock check
    END
    Teardown vdu connection

Aic Cells Should Be Onair
    ${onair_status}  Wait Aic BTS Onair And Return Status
    Run Keyword If  '${onair_status}'=='${False}'    Fail

Check the RANNIC reset operation
    ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${vDU_DN_MRBTS}
    Perform RANNIC reset    mrbts_id=${vDU_DN_MRBTS}    list_rannic_r_dn=${list_rannic_r_dn}
    Check fault and alarm 7114 exist on vCU
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Aic Cells Should Be Onair
    Check No New Active Faults

Check the RANNIC reset and then pods status
    ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${vDU_DN_MRBTS}
    Perform RANNIC reset    mrbts_id=${vDU_DN_MRBTS}    list_rannic_r_dn=${list_rannic_r_dn}
    Check fault and alarm 7114 exist on vCU
    ${DU_STATE_ret}    Get Du State Aic
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
    END
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults

vCU and vDU reset
    Log to console    reset vDU
    reset_du
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults
    Log to console    reset vCU
    DevHZ5_lib_aic.Reset Cu
    Wait Until Keyword Succeeds  10min  30s    Aic Cells Should Be Onair
    Check No New Active Faults

Check the reset RUs
    Perform reset RUs    rmods_list=${rmods_list}
    sleep  60s
    Check fault and alarm 7114 exist on vCU
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Aic Cells Should Be Onair
    Check No New Active Faults

RMOD lock and unlock check
    Perform RMOD lock    rmods_list=${rmods_list}
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Check No New Active Faultid Exist Du    ${initial_act_alarm_list_du}    ${FAULTS_EXCLUDED_CHECKING}
    Check fault and alarm 7114 exist on vCU
    Perform RMOD unlock    rmods_list=${rmods_list}
    Check fault and alarm 7114 non-exist on vCU
    Aic Cells Should Be Onair
    Check No New Active Faults


Cell block and unblock check
    Perform Cells block    cells_list=${cells_list}
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Check fault 49 and alarm 7102 exist on vDU
    Perform Cells unblock    cells_list=${cells_list}
    Check fault 49 and alarm 7102 non-exist on vDU
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
    ...    ${alarming_object_cell1}=NRCELL-1
    ...    ${alarming_object_cell2}=NRCELL-2
    ...    ${alarming_object_cell12}=NRCELL-12
    ...    ${alarming_object_cell13}=NRCELL-13
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell1}
    Fm Fault Should Be Raised Du Aic    ${fault49_alarm7102}
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell2}
    Fm Fault Should Be Raised Du Aic    ${fault49_alarm7102}
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell12}
    Fm Fault Should Be Raised Du Aic    ${fault49_alarm7102}
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell13}
    Fm Fault Should Be Raised Du Aic    ${fault49_alarm7102}

Check fault 49 and alarm 7102 non-exist on vDU
    [Arguments]    ${fault_id}=49    ${alarm_id}=7102    ${severity}=Critical
    ...    ${alarm_name}=BASE STATION RESOURCE BLOCKED BY USER
    ...    ${fault_name}=Cell blocked
    ...    ${alarming_object_cell1}=NRCELL-1
    ...    ${alarming_object_cell2}=NRCELL-2
    ...    ${alarming_object_cell12}=NRCELL-12
    ...    ${alarming_object_cell13}=NRCELL-13
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell1}
    Fm Fault Should Be Cleared Du Aic    ${fault49_alarm7102}
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell2}
    Fm Fault Should Be Cleared Du Aic    ${fault49_alarm7102}
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell12}
    Fm Fault Should Be Cleared Du Aic    ${fault49_alarm7102}
    ${fault49_alarm7102}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell13}
    Fm Fault Should Be Cleared Du Aic    ${fault49_alarm7102}

Check fault and alarm 7114 exist on vCU
    [Arguments]    ${fault_id}=7104    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Matching ServedCell not found over F1-C
    ...    ${alarming_object_cell1}=NRCELL-1
    ...    ${alarming_object_cell2}=NRCELL-2
    ...    ${alarming_object_cell12}=NRCELL-12
    ...    ${alarming_object_cell13}=NRCELL-13
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell1}
    Fm Fault Should Be Raised Cu Aic    ${fault7104_alarm7114}
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell2}
    Fm Fault Should Be Raised Cu Aic    ${fault7104_alarm7114}
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell12}
    Fm Fault Should Be Raised Cu Aic    ${fault7104_alarm7114}
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell13}
    Fm Fault Should Be Raised Cu Aic    ${fault7104_alarm7114}

Check fault and alarm 7114 non-exist on vCU
    [Arguments]    ${fault_id}=7104    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Matching ServedCell not found over F1-C
    ...    ${alarming_object_cell1}=NRCELL-1
    ...    ${alarming_object_cell2}=NRCELL-2
     ...   ${alarming_object_cell12}=NRCELL-12
    ...    ${alarming_object_cell13}=NRCELL-13
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell1}
    Fm Fault Should Be Cleared Cu Aic    ${fault7104_alarm7114}
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell2}
    Fm Fault Should Be Cleared Cu Aic    ${fault7104_alarm7114}
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell12}
    Fm Fault Should Be Cleared Cu Aic    ${fault7104_alarm7114}
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object_cell13}
    Fm Fault Should Be Cleared Cu Aic    ${fault7104_alarm7114}

Lock and unlock NG link operations on vCU
    Log to console    Begin to NG lock
    Disable NG Link1
    Disable NG Link2
    Disable NG Link3
    Check fault and alarm 7114 exist on vCU
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107
    ${DU_STATE_ret}    Get Du State Aic
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Log to console    Begin to NG unlock
    Enable NG Link1
    Enable NG Link2
    Enable NG Link3
    Check fault and alarm 7114 non-exist on vCU
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107
    Aic Cells Should Be Onair

Lock and unlock slice operations on vCU
    log to console    //this is do slice lock and unlock
    Lock slice 1
    unLock slice 1

Lock slice ${number}
    Delta Commission Parameters Cu    SNSSAI-${number}:administrativeState=Locked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu    SNSSAI-${number}:administrativeState=Locked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu    SNSSAI-${number}:operationalState=disabled

unLock slice ${number}
    Delta Commission Parameters Cu    SNSSAI-${number}:administrativeState=Unlocked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu    SNSSAI-${number}:administrativeState=Unlocked
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu    SNSSAI-${number}:operationalState=enabled

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
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu  NRCELL-1:operationalState=disabled
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu  NRCELL-1:availabilityStatus=off line
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu  NRCELL-1:barringStatus=unbarred
    Lock Cell2
    Lock Cell12
    Lock Cell13
    Unlock Cell1
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu  NRCELL-1:operationalState=enabled
#    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu  NRCELL-1:availabilityStatus=on line
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist In Cu  NRCELL-1:barringStatus=unbarred
    Unlock Cell2
    Unlock Cell12
    Unlock Cell13