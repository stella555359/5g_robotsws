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
Resource        ${CURDIR}/../CB009373CIT-B/resources/common_keywords_CB009373_B.robot


Suite Setup     Setup Oamops    dut=vdu_1    alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu


*** test cases ***

[1][1.0] CB009373_B__SEC__RSA_and_ECDSA_operator_certificate_switch_used_for_https_traffic


         Load scf

         Configure the parameter certTypeForResthttpsTLSAuth to default value

        install ECDSA certificate only on vDU

         install RSA certificate

         Configure the parameter certTypeForResthttpsTLSAuth to ECDSA

         Restore Cerficate to default

         Get Operator Certificates
