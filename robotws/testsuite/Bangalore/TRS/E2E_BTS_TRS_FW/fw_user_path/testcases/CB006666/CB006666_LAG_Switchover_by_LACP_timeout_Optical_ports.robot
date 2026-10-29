*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_L2.2898;TT_NCONF.2026; TT_L2.2806;TT_L2.2794;TT_NCONF.2000;TT_L2.2894;TT_L2.2815;
...     TT_L2.2917;TT_L2.2919;TT_L2.2903;TT_L2.2778;TT_L2.2728; TT_L2.2805"
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
[1]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations_And_Switchover_By_LACP

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag        ${CreateLAGActiveStandby}
    Sleep   20
    Verify LAG Parameters in LAPCDUs      bts1     bts2     lag_a    lag_s    lag_active    lag_standby
    Verify BFD     bfd     bfd
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify LAG Switchover by LACP Timeout
    Verify LAG Switchover by LOS Restoration and Alarm degradation by LACP Timeout
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveStandby}
    Verify No LACPDUs     bts1     bts2     nolag_a     nolag_s    lag_active_0     lag_standby_0
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[2]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Active_Configurations_And_Switchover_By_LACP

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag       ${CreateLAGActiveActive}
    Sleep    20
    Verify LAG Parameters in LAPCDUs      bts1     bts2     lag_a      lag_a1    lag_active      lag_active1
    Verify BFD      bfd     bfd
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify LAG Switchover by LACP Timeout
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA by LACP Timeout
    Remove LAG Configuration From BTS and Switch       remove_static_lag      ${DeleteLAGActiveActive}
    Verify No LACPDUs     bts1     bts2     nolag_a     nolag_s    lag_active_0     lag_standby_0
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch
