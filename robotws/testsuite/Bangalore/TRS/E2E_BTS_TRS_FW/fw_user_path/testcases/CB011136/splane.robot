** Settings ***
Documentation
...     [Author]                    "Abeer Banu"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "09:05:2022"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB005999"
...     [Validated_TestLine]        "KVM_ST_LMP_TL1004"
...     [Procedure]                 "CB005999_Verification of Additional intermediate CA and TA Certificates"
...     [Precondition]              "ASOE hardware is required"
...     [Config]                    "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../CB011136/resources/common_keywords_CB011136_splane.robot


Suite Setup     Setup Oamops    dut=vdu_9857     alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_9857     alias=vdu

*** Test Cases ***
[2]CB011136_Splane Traffic Filtering
        Change the service account password
        Enable ssh access from rannic
        Fetch Splane Rules from RANNIC
        Verify Splane Rules
        Verify Splane Duplicate Rules
        Reset vDU
        Fetch Splane Rules from RANNIC
        Verify Splane Rules
