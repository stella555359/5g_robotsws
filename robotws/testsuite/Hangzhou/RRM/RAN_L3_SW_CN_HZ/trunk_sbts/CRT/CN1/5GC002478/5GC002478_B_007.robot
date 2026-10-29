*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               owner-xianjiao.xie    release-5G20B    team-SG2
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=230
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    MRBTS-1/NRBTS-1:ngUeRetentionTmr=300
...    @{modify_relation_error}
@{modify_relation_error}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac
@{Delete_Useless_Cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs


*** Test Cases ***
5GC002478-ET-B007_Verify_cell_is_still_deactive_after_NG_link_unlock_as_cell_set_to_lock
    [Documentation]
    ...    it will cover NGLink lock, GNB state from OnAir change to Configured and cell state from "Active,Enabled,unbarred" change to "Idle,
    ...    Disabled,unbarred", then unlock NGLink, GNB state change to OnAir and cell state turn into "Active,Enabled,unbarred"; as well cover
    ...    all NGLink and cell is locked, unlock cell or NGLink, cell is still deactive, when all NGLink and cell is unlock,cell will turu into
    ...    "Active,Enabled,unbarred"; in addition, verify CellDeactDelayTimer is correct
    [Tags]    QC_60838
    Precondition for case B007
    first lock NG and cell and check
    Check Wireshark Log    ${CURDIR}${/}A2A_B007${/}firstlock.ini    name=firstlock    wait_string=GNBDUConfigurationUpdateAcknowledge::6
    second lock NG and cell and check
    UE Deregister From GNB    ue_id=3
    Check Wireshark Log    ${CURDIR}${/}A2A_B007${/}secondlock.ini    name=secondlock    wait_string=GNBDUConfigurationUpdateAcknowledge::6

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=10
    Comment    Debug Enter Into Egate

Precondition for case B007
    Delta commission parameters    ${Delete_Useless_Cell}
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    L3 call is successful    ue_id=1

L3 call is successful
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    Initial Context Setup Successful
    Traffic should be ok    ue_id=${ue_id}    type=SA

first lock NG and cell and check
    stop capture wireshark log
    start to capture wireshark log    firstlock
    Lock NG link and cell
    Unlock NG link and cell

second lock NG and cell and check
    start to capture wireshark log    secondlock
    Lock cell and NG link
    Unlock NG link and cell

Lock NG link and cell
    Disable NG Link1
    Check result for lock NG link    wait_time=62
    Lock cell1
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred

Unlock NG link and cell
    Lock or unlock NG link    operation=Unlocked
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Unlock Cell1
    Check result for unlock cell

Lock cell and NG link
    Lock cell1        #keyword
    Check result for lock cell
    Disable NG Link1
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check BTS state    operationalState=configured

Check result for lock NG link
    [Arguments]    ${wait_time}
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check BTS state
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    Wait for GNB state change    wait_time=${wait_time}
    Check BTS state    operationalState=configured
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Wait to check UE    UE_wait=5
    UE should be released

Check result for unlock cell
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Check BTS state
    L3 call is successful    ue_id=3

Check result for lock cell
    Wait to check UE    UE_wait=5
    UE should be released
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check BTS state    operationalState=integrated to RAN

Lock or unlock NG link
    [Arguments]    ${operation}
    delta commission parameters    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=${operation}

Check BTS state
    [Arguments]    ${operationalState}=onAir
    Object Should Exist    NRBTS:operationalState=${operationalState}

Check cell state as expected
    [Arguments]    ${operationalState}    ${barringStatus}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=${operationalState}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=${barringStatus}

Wait for GNB state change
    [Arguments]    ${wait_time}
    sleep    ${wait_time}

UE should be released
    execute egate command    ue_disp id=1 state=OFF     pass_regexp=OFF

Wait to check UE
    [Arguments]    ${UE_wait}
    sleep    ${UE_wait}

UE Deregister From GNB
  [Arguments]    ${ue_id}=1
  Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached
