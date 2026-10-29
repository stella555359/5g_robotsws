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
Resource        ${CURDIR}/../5GC002072_C/resources/common_keywords_5GC002072_c.robot


Suite Setup     Setup Oamops    dut=vdu_1    alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu


*** test cases ***

[1][1.0] 5GC002072_C__SEC__Log_Activity_From_WebEM_User

         Load scf

        Lock Cell And Unlock Cell In WebEM

        Lock RU And Unlock RU In WebEM

        Reset RU In WebEM

        Reset VDU In WebEM







