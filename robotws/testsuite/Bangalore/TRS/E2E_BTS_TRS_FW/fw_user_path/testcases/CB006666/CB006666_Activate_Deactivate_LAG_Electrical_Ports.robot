*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_NCONF.1979;TT_NCONF.1999;TT_NCONF.2342;TT_NCONF.2360; TT_L2.2735; TT_L2.2710"
...     [Funtion_Hash_Tags]    "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]    "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]    "LAGRP under TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]   "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag_e      ${CreateLAGActiveStandbyE}
    Verify LAG Parameters in LAPCDUs      bts3      bts4      lag_a1     lag_s1      lag_active_e      lag_standby_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BFD      bfd     bfd
    Port Removal From LAGRP AS
    Reset Bts       should_be_onair=${True}      rat=5g
    Verify LAG Parameters in LAPCDUs      bts3      bts4      lag_a1     lag_s1      lag_active_e      lag_standby_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify LAG Switchover by LOS Elec
    Verify LAG Switchover by LOS Restoration and Alarm degradation Elec
    Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveStandbyE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    Change Port Priority And Verify LAG Elec
    Change LACP Periodic Time
    LAG Status When ETHLK Locked Elec
    [Teardown]      Reload BTS And Switch

[2]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Active_Configurations

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag_e      ${CreateLAGActiveActiveE}
    Verify LAG Parameters in LAPCDUs      bts3      bts4      lag_a1     lag_a1_1      lag_active_e       lag_active1_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BFD      bfd     bfd
    Port Removal From LAGRP AA
    Reset Bts       should_be_onair=${True}      rat=5g
    Verify LAG Parameters in LAPCDUs      bts3      bts4      lag_a1     lag_a1_1      lag_active_e       lag_active1_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify LAG Switchover by LOS Elec
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA Elec
    Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveActiveE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    [Teardown]      Reload BTS And Switch

[3]Automation-CB006666_Verify_Static_Lag

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       static_lag_e       ${CreateStaticLagE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BFD      bfd      bfd
    Reset Bts       should_be_onair=${True}      rat=5g
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    Static LAG Status When ETHLK Locked Elec
    Static LAG Swithover Using LOS Elec
    Remove LAG Configuration From BTS and Switch       remove_static_lag_e      ${DeleteLAGActiveActiveE}
    [Teardown]      Reload BTS And Switch
