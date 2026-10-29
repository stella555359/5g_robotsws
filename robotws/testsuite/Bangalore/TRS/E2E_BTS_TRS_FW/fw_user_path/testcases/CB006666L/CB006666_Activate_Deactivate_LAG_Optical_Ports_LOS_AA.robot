*** Settings ***
Documentation
...     [Procedure]     "Link Aggregation Support for Backhaul"
...     [Author]        "Sahana TC Santhosh KG"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "CB006666"
...     [Requirement ID]   "OAM_REQ_WEBEM_1726 TT_L2.2900 TT_L2.2899 TT_L2.2933 TT_L2.2721 TT_L2.2726"
...     [Funtion_Hash_Tags] ""
...     [Domain_Hash_Tags] "Backhaul L2"
...     [Validated_TestLine]    "2212"
...     [Config]    ""
...     [Runtime param]   "bts_id is provided at run time."

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1][1.0] CB006666-SR-B_Verification of Switchover using Hardware-LOS as link failure detection_Active_Active
    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Alarms before LAG
    Configure LAG on Switch and BTS Optical Ports AA
    Lock Ethlk3 port
    Verify LAG Parameters in LAPCDUs AA
    Check LAG and Port Status AA
    Reset Bts      should_be_onair=${True}  rat=5g
    Verify LAG Parameters in LAPCDUs AA
    Check LAG and Port Status AA
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA
    Remove LAG Configuration From BTS and Switch AA
    Alarms after LAG
    Verify No LACPDUs
