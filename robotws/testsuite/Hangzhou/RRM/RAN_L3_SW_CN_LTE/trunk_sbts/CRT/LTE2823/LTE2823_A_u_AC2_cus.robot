*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Search log and collect logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4MAPN_CUS
...               release-xL17SP    owner-yin.zhang
Resource          ../../../resources/DevHZ5_resource.robot
Library    plmn_verifiers.py

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:ovlOccurrences=1
...    LNBTS:ovlTimer=60
...    LNBTS:ovlThrOvlEarly=1
...    LNBTS:ovlThrOvl1=1
...    LNBTS:ovlThrOvl2=1

@{PARAMS_IN_SCF}
...    ${EMPTY}

${SNAPSHOT_FLAG}    pass:True,fail:True
${SOS_REPORT_FLAG}  pass:False,fail:False

*** Test Cases ***
LTE2823_A_u_AC2_Start_and_stop_of_PLMN_disabling_Counter_Automatic_AC_Barring_with_PLMN_disabling_updated
    [Tags]
    Start Rtpm Counter
    Attach number of UEs in Cell_11 to exceed overload level 2
    Wait until autoAcBarringStartTimer expire to activate ACB
    Wait until autoPlmnRmvlStartTimer expire to trigger SIM procedure to remove further PLMN
    Verify that further PLMN with 'autoRemovalAllowed is set to true' is not broadcasted in SIB1

    Detach number of UEs in Cell_11 to enters overload level 0
    Wait until autoAcbPlmnRmvlStopTimer expire to deactivate ACB and trigger SIM procedure to recover removed further PLMN
    Verify that previously removed further PLMN is broadcasted in SIB1

    Verify that counter 'Automatic AC Barring with PLMN disabling' is updated indicating the time period of further PLMN removal from SIB1

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=LTE2823_3cells_FDD    ue_count=200
    create cell alias    CELL_1    cell_id=11   cell_type=cus

Attach number of UEs in Cell_${cell_id} to exceed overload level 2
    Run keyword and ignore error    Run uex command    ue_attach  id=1..200  cell=${cell_id}    rate=1000
    [Teardown]    execute_uex_command    get_ue_summary

Wait until autoAcBarringStartTimer expire to activate ACB
    ${timer}    get scf parameter value    LNCEL-1/SIB-0:autoAcBarringStartTimer
    Sleep    ${timer}

Wait until autoPlmnRmvlStartTimer expire to trigger SIM procedure to remove further PLMN
    ${timer}    get scf parameter value    LNCEL-1/SIB-0:autoPlmnRmvlStartTimer
    Sleep    ${timer}

Verify that further PLMN with 'autoRemovalAllowed is set to true' is not broadcasted in SIB1
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 (plmn list not contains 24410 24412)
    ...    alias=sib1_flow  overall_timeout=120
    flow occurred as expected    alias=sib1_flow

Detach number of UEs in Cell_${cell_id} to enters overload level 0
    run uex command    ue_detach    all

Wait until autoAcbPlmnRmvlStopTimer expire to deactivate ACB and trigger SIM procedure to recover removed further PLMN
    ${timer}    get scf parameter value    LNCEL-1/SIB-0:autoAcbPlmnRmvlStopTimer
    Sleep    ${timer}

Verify that previously removed further PLMN is broadcasted in SIB1
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 (plmn list contains 24410 24412)
    ...    alias=sib1_flow  overall_timeout=120
    flow occurred as expected    alias=sib1_flow

Verify that counter 'Automatic AC Barring with PLMN disabling' is updated indicating the time period of further PLMN removal from SIB1
    Check Rtpm Counters    LNCEL-1:M8057C1=180

Search log and collect logs
    execute cmd on pc    grep -i -e "change.*overload2" -e "EnbcAutoPlmnSuspensionService.cpp" ${SAVE LOG DIRECTORY}/btslog.LOG
    Common Test Teardown And Stop Capture Logs