*** Settings ***
Documentation
...     [Procedure]     "Link Aggregation Support for Backhaul"
...     [Author]        "Sahana TC Santhosh KG"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "CB006666"
...     [Requirement ID]   "TT_NCONF.2000 TT_L2.2894 TT_L2.2815 TT_L2.2917 TT_L2.2919 TT_L2.2903"
...     [Funtion_Hash_Tags] ""
...     [Domain_Hash_Tags] "Backhaul L2"
...     [Validated_TestLine]    "2039"
...     [Config]    ""
...     [Runtime param]   "bts_id is provided at run time."

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] CB006666-SR-A_Verification of Switchover using LACP as Link failure detection_Active_Standby
    Continue Keyword Execution On Failure    ${True}
    Configure Normal ports without LAG
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Alarms before LAG
    Configure LAG on Switch and BTS Optical Ports AS
    Lock Ethlk3 port
    Verify LAG Parameters in LAPCDUs
    Check LAG and Port Status
    Verify LAG Switchover by LACP Timeout
    Verify LAG Switchover by LOS Restoration and Alarm degradation by LACP Timeout
    Remove LAG Configuration From BTS and Switch AS
    Alarms after LAG
    Verify No LACPDUs

