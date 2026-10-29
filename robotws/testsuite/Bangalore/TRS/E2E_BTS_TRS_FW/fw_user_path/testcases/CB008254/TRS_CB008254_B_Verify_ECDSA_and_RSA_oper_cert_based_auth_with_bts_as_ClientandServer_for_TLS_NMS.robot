*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check the authentication through operator certificate"
...     [Date]      "01-11-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify both RSA & ECDSA operator certificate-based auth with BTS as Client and server for TLS"
...     [Funtion_Hash_Tags] "RSA & ECDSA operator certificate-based authentication"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_NetSec.3197,OM_GEN_SFS_Netsec_3195"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "2205"
...     [Config]    "Set oamTls,certType for MPLANENW and Tlsversion flags to be set to false in SCF"
...     [scf_file]      "Configuration_scf_MRBTS-2205_Synergy_ASIK_ABIL_5G_20220822-1430_EAP_config.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cb008254.robot
Library         ta_emss

Suite Setup     Pre-conditions for testsuite
Suite Teardown  Post-conditions for testteardown

*** Variables***

***Test Cases***
[1]CB008254-A_Verify both RSA & ECDSA operator certificate-based auth with BTS as Client and server for TLSv1.3_NMS .
    Comment     Step 1 Commission with base.xml
    Perform Commissioning   scf_file=${base_scf}    verify_bts_status=False     timeout=400     alias=default
    Sleep   300
    Comment     Step 2 Configure tls related parameters and check oamTls status
    Read mplane IP
    Set tls parameter   ${oamtls}       ${oamTls_forced}
    Set tls parameter   ${tls_certtype}     ${certtype_ecdsa}
    Comment     Step 3 Verify DUT did not reboot
    Ping to Mplane
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version1_3}
    ${status}=            Query Admin Infomodel     query=get param ${oamTls_status}
#    Should be equal     ${status}        notSecured
#    Should be equal     ${status}   notConnected
    Comment     Step 4 Configure certificates on BTS
    Configure certificate on BTS    ${rsa_cert_tc2}     ${ecdsa_cert}   ${rsa_password_emssim}  ${ecdsa_password_dcap}
    Comment     Step 5 Configure EMSSIM and take capture
    Copy certificate to EMSSIM      ecdsa
    Verify TLS parameter and version for nms case       tls_capture_0
    Comment     Step 6 Verify pcap
    Get Pcap Details for TLS1_3 for emssim
    Comment     Step 7 check step 4 and 5 for case with RSA certificate
    Set tls parameter   ${tls_certtype}     ${certype_rsa}
    Copy certificate to EMSSIM      rsa
    Verify TLS parameter and version for nms case    tls_capture_1
    Comment     Step 8 verify pcap
    Get Pcap Details for TLS1_3 for emssim

[1]CB008254-A_Verify both RSA & ECDSA oper cert-based auth with BTS as client and server for TLSv1.2_and earlier_NMS.
    Comment     Step 1 : perform initial configuration for tls1.2 version
    Read mplane IP
    Set tls parameter   ${tls_certtype}     ${certtype_ecdsa}
    Sleep   60
    Comment     Step 2 Verify DUT did not reboot
    Ping to Mplane
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    ${status}=            Query Admin Infomodel     query=get param ${oamTls_status}
    Should be equal     ${status}        notConnected
    Comment     Step 3 Configure EMSSIM and take capture
    Copy certificate to EMSSIM      ecdsa
    Verify TLS parameter and version for nms case    tls_capture_2
    Comment     Step 4 Verify pcap
    Get Pcap Details for TLS1_2 for emssim
    Comment     Step 5 check step 3 and 4 for case with RSA certificate
    Set tls parameter   ${tls_certtype}     ${certype_rsa}
    Copy certificate to EMSSIM      rsa
    Verify TLS parameter and version for nms case    tls_capture_3
    Comment     Step 6 verify pcap
    Get Pcap Details for TLS1_2 with rsa for emssim
