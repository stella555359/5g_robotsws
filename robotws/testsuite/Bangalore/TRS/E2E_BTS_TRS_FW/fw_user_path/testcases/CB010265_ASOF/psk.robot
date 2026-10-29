*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:06:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010265"
...     [Funtion_Hash_Tags]     "Verification_of_IPSec_Connection_based_on_PSK_before and after SW_Upgrade"
...     [Procedure]             "Verification_of_IPSec_Connection_based_on_PSK_before and after SW_Upgrade"

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test cases ***

[1]CB010265_TRS_C_Verification_of_IPSec_Connection_based_on_PSK_before and after SW_Upgrade

   Perform Commissioning    scf_file=${Ipsec_scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
    sleep      300
    Ipsec Psk Update    key=Nokia@123       dut=bts     timeout=60      alias=default
    sleep   60
    Verify Ipsec Tunnels Status
    Ipsec Psk Update    key=Nokia@567       dut=bts     timeout=60      alias=default
    sleep   60
    Verify Ipsec Tunnels Status Not Exist
    Perform Software Download And Update       wft_profile=Trunk_ENB      package=auto       activate_sw=True     update_timeout=3000
    Ipsec Psk Update    key=Nokia@123       dut=bts     timeout=60      alias=default
    sleep   60
    Verify Ipsec Tunnels Status
    Ipsec Psk Update    key=Nokia@567       dut=bts     timeout=60      alias=default
    sleep   60
    Verify Ipsec Tunnels Status Not Exist




*** keywords ***

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default


Manual_Installation_of_SHA1_Cert
    Certificate Configure    operation=install_certificate    cert_file=${SHA1_Cert}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}

Manual_Installation_of_SHA384_Cert
    Certificate Configure    operation=install_certificate    cert_file=${SHA384_Cert}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}

Manual_Installation_of_1K_Cert
    Certificate Configure    operation=install_certificate    cert_file=${1K_Cert}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Pswd}

