*** Settings ***
Documentation
...     [Procedure]             "IPSec for eCPRI M Plane"
...     [Author]                "Sahana TC"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 ". . . ."
...     [Feature_ID]            "CB006114"
...     [Requirement ID]        "TT_TTSEC.1976,TT_TTSEC.2212,TT_TTSEC.1335,TT_TTSEC.2221,TT_TTSEC.2238,TT_TTSEC.2223,TT_TTSEC.2239
...                              TT_TTSEC.2225,TT_TTSEC.2229,TT_TTSEC.2232,TT_TTSEC.2226,TT_TTSEC.2028,TT_TTSEC.2234,WBTS_SEC_59565
...                              WBTS_SEC_59583"
...     [Funtion_Hash_Tags]     "Security"
...     [Domain_Hash_Tags]      "Fronthaul IPsec"
...     [Validated_TestLine]    "2011"
...     [Config]                ""
...     [Runtime param]         "bts_id is provided at run time."

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CB006114_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

*** Test Cases ***
[1][1.0] CB008325-5G-A CB007875 CB006114 1558 Activation of the feature CB006114 in RuProtectOptional RuProtectenable mode from NMS_WebEm_Automation

    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=1200     alias=default
    Login to sshenb and fronthaul and capture