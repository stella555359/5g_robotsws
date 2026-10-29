*** Settings ***
Documentation
...     [Procedure]     "Link Aggregation Support for Backhaul"
...     [Author]        "Sahana TC Santhosh KG"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "CB006666"
...     [Requirement ID]   "TT_NCONF.1979 TT_NCONF.1999 TT_NCONF.2336 TT_L2.2720 TT_NCONF.2021 TT_NCONF.2026 TT_TTSEC.1993 TT_L2.2933 TT_NCONF.2021"
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
[1][1.0] CB006666-SR-B_Verification of Modification_LAG_With Optical Backhaul_ports_A_A_ASIL
    Continue Keyword Execution On Failure    ${True}
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Alarms before LAG
    Configure LAG on Switch and BTS Optical Ports AS Same System and Port Priotity
    Verify LAG Parameters in LAPCDUs Optical with Same System Priority And Port Priority
    Log     BTS And Switch Same System Priority and Same Port Priority - BTS having lower MAC considered as Actor followed with Port numbers of BTS
    Check LAG and Port Status P2 Active P1 Standby
    Modify System priority and Verify LAG Status
    Remove LAG Configuration From BTS and Switch AS
    Alarms after LAG
    Verify No LACPDUs


