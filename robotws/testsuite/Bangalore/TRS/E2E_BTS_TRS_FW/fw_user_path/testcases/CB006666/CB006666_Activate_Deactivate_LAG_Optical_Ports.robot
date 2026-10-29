*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_NCONF.2026;TT_TTSEC.1993;TT_L2.2933;TT_NCONF.1979;TT_NCONF.1999"
...     [Funtion_Hash_Tags]    "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]    "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]    "LAGRP under MRBTS-id/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]   "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot
Resource        ${CURDIR}/../resources/Common_Top_sync.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations_And_Swithover

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=400     alias=default
    Configure LAG on Switch and BTS       dynamic_lag        ${CreateLAGActiveStandby}
    Verify LAG Parameters in LAPCDUs      bts1     bts2     lag_a    lag_s    lag_active    lag_standby
    Check LAG and Port Status      enabled        ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BFD      bfd       bfd
    Run Keyword      Make 5G Calls
    Reset Bts       should_be_onair=${True}       rat=5g
    Verify LAG Parameters in LAPCDUs    bts1      bts2     lag_a    lag_s    lag_active    lag_standby
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Restoration and Alarm degradation
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveStandby}
    Verify No LACPDUs      bts1     bts2     nolag_a     nolag_s    lag_active_0     lag_standby_0
    Configure LAG on BTS With Different Physical type
    Change Port Priority And Verify LAG
    LAG Status When ETHLK Locked
    Verify No LACP When BTS And Switch In Passive
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[2]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Active_Configurations

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       dynamic_lag       ${CreateLAGActiveActive}
    Verify LAG Parameters in LAPCDUs      bts1     bts2     lag_a      lag_a1    lag_active      lag_active1
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BFD      bfd     bfd
    Run Keyword      Make 5G Calls
    Reset Bts       should_be_onair=${True}       rat=5g
    Verify LAG Parameters in LAPCDUs      bts1      bts2      lag_a      lag_a1    lag_active      lag_active1
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveActive}
    Verify No LACPDUs     bts1     bts2      nolag_a     nolag_s    lag_active_0     lag_standby_0
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[3]Automation-CB006666_Verify_Static_Lag_And_Swithover_Using_LOS

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG on Switch and BTS       static_lag       ${CreateStaticLag}
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify No LACPDUs     bts1     bts2     nolag_a     nolag_s    lag_active_0     lag_standby_0
    Verify BFD     bfd     bfd
    Run Keyword      Make 5G Calls
    Reset Bts       should_be_onair=${True}       rat=5g
    Verify No LACPDUs     bts1     bts2      nolag_a     nolag_s    lag_active_0     lag_standby_0
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Static LAG Status When ETHLK Locked
    Static LAG Swithover Using LOS
    Remove LAG Configuration From BTS and Switch       remove_static_lag      ${DeleteLAGActiveActive}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[4]Automation-CB006666_Verify_TOPP_Unicast_With_LAG_AS

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf_ToppU}   verify_bts_status=${True}     timeout=300     alias=default
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Configure LAG on Switch and BTS       dynamic_lag        ${CreateLAGActiveStandby}
    Check LAG and Port Status     enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BTS Status     should_be_onair=${True}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Reset Bts       should_be_onair=${True}       rat=5g
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Verify Topp After LAG Switchover
    Remove LAG Configuration From BTS and Switch      remove_lag      ${DeleteLAGActiveStandby}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[5]Automation-CB006666_Verify_TOPP_Multicast_With_LAG_AS

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf_ToppM}   verify_bts_status=${True}     timeout=300     alias=default
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Configure LAG on Switch and BTS       dynamic_lag        ${CreateLAGActiveStandby}
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BTS Status     should_be_onair=${True}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Reset Bts       should_be_onair=${True}       rat=5g
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Verify Topp After LAG Switchover
    Remove LAG Configuration From BTS and Switch      remove_lag      ${DeleteLAGActiveStandby}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch

[6]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations_And_Swithover_Via_Netact

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Configure LAG Via Netact
    Perform Switchover
    Verify Ems Alarm    config_device=netact1042    faultid=61662     occurences=1        severity=minor       alias=lab1042
    Reload Switchover
    Verify Ems Alarm    config_device=netact1042    faultid=61662      should_exist=${False}      alias=lab1042
    [Teardown]      Reload BTS And Switch
