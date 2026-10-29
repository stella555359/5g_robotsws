*** Settings ***
Documentation
...     [Procedure]             "Link Aggregation Support for Backhaul"
...     [Author]                "Sahana TC Santhosh KG"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab For Reporting"
...     [Feature_ID]            "CB006666"
...     [Requirement ID]        "TT_NCONF.2026;TT_TTSEC.1993;TT_L2.2933;TT_NCONF.1979;TT_NCONF.1999"
...     [Funtion_Hash_Tags]     "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]      "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]                "LAGRP under MRBTS-id/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]         "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1][1.0] CB006666-SR-B_Verification of Enable_Disable_LAG_With Optical Backhaul_ports_A_A_ASIB

    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=900     alias=default
    Configure LAG on Switch and BTS       dynamic_lag       ${CreateLAGActiveActive}
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Reset Bts           should_be_onair=${False}            rat=5g
    sleep     200
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveActive}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    [Teardown]      Reload BTS And Switch
