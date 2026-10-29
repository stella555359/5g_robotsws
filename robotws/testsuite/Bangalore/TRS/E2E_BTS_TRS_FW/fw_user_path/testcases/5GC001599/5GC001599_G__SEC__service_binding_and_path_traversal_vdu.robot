*** Settings ***
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

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../5GC001599/resources/common_keywords_1599.robot


Suite Setup     Setup Oamops    dut=vdu_1     alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu



*** test cases ***
[1][1.0] 5GC001599_G__SEC__service_binding_and_path_traversal_vdu

     Load scf

     Check there is no service binding to the zero address

     Check there is no path traversal to outside of container
