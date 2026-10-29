*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_NCONF.2336; TT_L2.2720;TT_NCONF.1979;TT_NCONF.1999;TT_NCONF.2342;TT_NCONF.2360;
...     TT_L2.2735; TT_L2.2710; TT_L2.2812; TT_L2.2893 ;LTE_OPR_REQ_33492"
...     [Funtion_Hash_Tags]    "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]    "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]    "LAGRP under MRBTS-id/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]    "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]Automation-CB006666_Verify_LAG_Election_with_System_Priority_Modification

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Log     Configure LAG on Switch and BTS Electrical Ports AS Same System and Port Priotity
    Configure LAG on Switch and BTS           sp_pp_same_e     ${CreateLAG}
    Verify LAG Parameters in LAPCDUs       bts3       bts4       lag_sspa       lag_ssps      lag_ssps     lag_sspa
    Log     BTS And Switch Same System Priority and Same Port Priority - BTS having lower MAC considered as Actor followed with Port numbers of BTS
    Check LAG and Port Status      enabled        STANDBY_ENABLED        ACTIVE_ENABLED
    Modify System priority and Verify LAG Status
    Remove LAG Configuration From BTS and Switch       remove_lag_e        ${DeleteLAGActiveStandbyE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    [Teardown]      Reload BTS And Switch

[2]Automation-CB006666_Verify_LAG_Election_with_Port_Priority_Modification

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS           dynamic_lag_e        ${CreateLAGActiveStandbyE}
    Verify LAG Parameters in LAPCDUs       bts3       bts4      lag_a1     lag_s1      lag_active_e       lag_standby_e
    Check LAG and Port Status      enabled        ACTIVE_ENABLED        STANDBY_ENABLED
    Modify Port priority and Verify LAG Status
    Remove LAG Configuration From BTS and Switch       remove_lag_e      ${DeleteLAGActiveStandbyE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    [Teardown]      Reload BTS And Switch

[3]Automation-CB006666_Verify_LAG_With_Port_Addition_Deletion

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS           dynamic_lag_e       ${CreateLAGActiveActiveE}
    Check LAG and Port Status      enabled        ACTIVE_ENABLED        ACTIVE_ENABLED
    Add Port and Delete Port
    Remove LAG Configuration From BTS and Switch        remove_lag_e        ${DeleteLAGActiveActiveE}
    Verify No LACPDUs       bts3     bts4     nolag_a1      nolag_s1      lag_active_0_e       lag_standby_0_e
    [Teardown]      Reload BTS And Switch
