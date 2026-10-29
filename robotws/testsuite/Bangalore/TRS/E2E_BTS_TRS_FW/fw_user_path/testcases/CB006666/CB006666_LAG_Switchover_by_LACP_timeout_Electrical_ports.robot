*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_NCONF.2344;LTE_OPR_REQ_33491"
...     [Funtion_Hash_Tags]    "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]    "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]    "LAGRP under MRBTS-id/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]   "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Electrical_Configurations_And_Swithover_By_LACP

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag_e      ${CreateLAGActiveStandbyE}
    Verify LAG Parameters in LAPCDUs      bts3      bts4      lag_a1     lag_s1      lag_active_e     lag_standby_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BFD      bfd      bfd
    Verify LAG Switchover by LACP Timeout Elec
    Verify LAG Switchover by LACP Restoration and Alarm degradation Elec
    Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveStandbyE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[2]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Active_Electrical_Configurations_And_Switchover_By_LACP

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag_e      ${CreateLAGActiveActiveE}
    Verify LAG Parameters in LAPCDUs      bts3      bts4      lag_a1     lag_a1_1      lag_active_e       lag_active1_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BFD     bfd      bfd
    Verify LAG Switchover by LACP Timeout Elec
    Verify LAG Switchover by LACP Restoration and Alarm degradation AA
    Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveActiveE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch
