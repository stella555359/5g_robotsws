*** Settings ***
Documentation
...     [Procedure]     "Link Aggregation Support for Backhaul"
...     [Author]        "Sahana TC Santhosh KG"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "CB006666"
...     [Requirement ID]   "TT_NCONF.1979 TT_NCONF.1999 TT_NCONF.2004 TT_NCONF.2026 TT_TTSEC.1993 TT_L2.2709"
...     [Funtion_Hash_Tags] ""
...     [Domain_Hash_Tags] "Backhaul L2"
...     [Validated_TestLine]    "2039"
...     [Config]    ""
...     [Runtime param]   "bts_id is provided at run time."

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/Common_LAG.robot
Resource        ${CURDIR}/../resources/Common_Top_sync.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1]CB006666-SR-A_Verification of Enable_Disable_LAG_With Optical Backhaul_ports_WithIPSec_Enabled
    Continue Keyword Execution On Failure    ${True}
    Configure Normal ports without LAG
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Alarms before LAG
    Configure LAG on Switch and BTS Optical Ports AS
    Check LAG and Port Status
    Configure IPSEC
    Get Ipsec Tunnels Status
    Verify BTS Status     should_be_onair=${True}
    Perform Switchover
    Get Ipsec Tunnels Status
    Verify BTS Status     should_be_onair=${True}
    Remove IPSEC
    Verify BTS Status     should_be_onair=${True}
    Remove LAG Configuration From BTS and Switch AS
    Alarms after LAG
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

