*** Settings ***
Documentation
...     [Procedure]             "Link Aggregation Support for Backhaul"
...     [Author]                "Sahana TC Santhosh KG"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 ". . . ."
...     [Feature_ID]            "CB006666"
...     [Requirement ID]        ""
...     [Funtion_Hash_Tags]     ""
...     [Domain_Hash_Tags]      "Backhaul L2"
...     [Validated_TestLine]    "2212"
...     [Config]                ""
...     [Runtime param]         "bts_id is provided at run time."

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops

*** Test Cases ***
[1][1.0] CB006666-SR-A_Verification of Switchover using LACP as Link failure detection_Active_Standby

    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${False}     timeout=600     alias=default
    Configure LAG on Switch and BTS Optical Ports AS
    Lock Ethlk3 port
    Verify LAG Parameters in LAPCDUs
    Check LAG and Port Status
    Verify LAG Switchover by LACP Timeout
    Verify LAG Switchover by LOS Restoration and Alarm degradation by LACP Timeout
    Remove LAG Configuration From BTS and Switch AS
    Verify No LACPDUs
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
