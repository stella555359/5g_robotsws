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


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../5GC002215/resources/common_keywords_5GC002215.robot


Suite Setup     Setup Oamops    dut=vdu_1    alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu


*** Test Cases ***
[1][1.0] 5GC002215_G_ike_sa_failure_alarm_for_vdu_and_vcu


          Check Ipsec Tunnel Status For Vdu And Vcu


          Modify Ike Encrypted For Vdu
          Recover Ike Encrypted For Vdu

          Modify Ike Authentication Algorithm For Vdu

         Recover Ike Authentication Algorithm For Vdu

          Modify Ike Encrypted For Vcu

          Recover Ike Encrypted For Vcu

          Modify Ike Authentication Algorithm For Vcu

          Recover Ike Authentication Algorithm For Vcu
