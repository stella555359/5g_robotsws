*** Settings ***
Documentation
...     [Procedure]     "Link Aggregation Support for Backhaul"
...     [Author]        "Sahana TC Santhosh KG"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "CB006666"
...     [Requirement ID]   "TT_NCONF.2006 TT_NCONF.2336 TT_NCONF.2340 TT_L2.2918 TT_L2.2805 TT_L2.2901 TT_L2.2902"
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
[1][1.0] CB006666-SR-A_Verification of Switchover using Hardware-LOS as link failure detection_Active_Standby
    Continue Keyword Execution On Failure    ${True}
    Configure Normal ports without LAG
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Alarms before LAG
    Configure LAG on Switch and BTS Optical Ports AS
    Lock Ethlk3 port
    Verify LAG Parameters in LAPCDUs
    Check LAG and Port Status
    Reset Bts     should_be_onair=${True} rat=5g
    Verify LAG Parameters in LAPCDUs
    Check LAG and Port Status
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Restoration and Alarm degradation
    Remove LAG Configuration From BTS and Switch AS
    Verify No LACPDUs
    Change Port Priority And Verify LAG
    LAG Status When ETHLK Locked
    Verify No LACP When BTS And Switch In Passive
    Alarms after LAG
    Change LACP Periodic Time

