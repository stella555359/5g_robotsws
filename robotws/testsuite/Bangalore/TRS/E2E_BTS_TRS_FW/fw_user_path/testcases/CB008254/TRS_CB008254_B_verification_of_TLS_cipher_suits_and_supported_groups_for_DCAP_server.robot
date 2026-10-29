*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for different ciphers with graylog server and DCAP server"
...     [Date]      "02-11-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify both RSA & ECDSA operator certificate-based auth with BTS as Client and server for TLS"
...     [Funtion_Hash_Tags] "RSA & ECDSA operator certificate-based authentication"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_Netsec_3197,OM_GEN_SFS_NetSec.3190"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "2205"
...     [Config]    "This testcase requires DCAP and gray syslog server IP and MNL/MNLENT/TRBLCADM MOC"
...     [scf_file]  "Configuration_scf_MRBTS-2205_Synergy_ASIK_ABIL_5G_20221027-0749.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cb008254.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown  Post-conditions for testteardown

*** Variables***

***Test Cases***
[1]CB008254-A_Verify both RSA & ECDSA operator certificate-based authentication for RTPM with DCAP.
    Comment     Step 1 Commission with base.xml
    Perform Commissioning   scf_file=${base_scf}    verify_bts_status=False     timeout=400     alias=default
    Sleep   300
    Perform Recommissioning     type=delta      delta_file=${delta_scf_dcap_ecdsa}
    ...     skip_parameter_relation_errors=${True}  timeout=300
    Sleep   100
    Read mplane IP
    Comment     Step 2 configure BTS certificate
    Configure certificate on BTS    ${rsa_cert}     ${ecdsa_cert}      ${rsa_password_dcap}    ${ecdsa_password_dcap}
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version1_3}
    Comment     Step 3 Verify TLS parameters
    Check server type and Verify TLS paramter and version    dcap   tls13    ECDSA   tls_capture_1
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_ecdsa}
    Read DCAP IP
    Comment     Step 4 Verify pcap
    Get Pcap Details for TLS1_3 for dcap
    Expected alarms
    Comment     Step 5 Reset BTS
    Reset Bts       verify_bts=False    req_rat=all     should_be_onair=False       wait_for=300
    Sleep   300
    Comment     Step 6 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version    dcap   tls13    ECDSA   tls_capture_2
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_ecdsa}
    Get Pcap Details for TLS1_3 for dcap
    Comment     Step 7 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Comment     Step 8 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version    dcap    tls12   ECDSA   tls_capture_3
    ...     ${delta_scf_dcap_delete}   ${delta_scf_dcap_ecdsa}
    Get Pcap Details for TLS1_2 for dcap
    Get Pcap Details for TLS1_2 for ECDSA for dcap
    Comment     Step 9 Recommission to make changes for rsa case.
    Set tls parameter   ${tls_certtype}     ${certype_rsa}
    Comment     Step 10 Verify DUT did not reboot
    Ping to Mplane
    Comment     Step 11 Recommission to enable TLSv1.3
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version1_3}
    Comment     Step 12 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version    dcap    tls13   RSA     tls_capture_4
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_rsa}
    Read DCAP IP
    Get Pcap Details for TLS1_3 for dcap
    Comment     Step 13 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Comment     Step 14 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version    dcap    tls12   RSA     tls_capture_5
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_rsa}
    Get Pcap Details for TLS1_2 for dcap
    Alarms after reset      ${pre_alarm_faultids}
    Comment     Step 15  Reset BTS
    Reset Bts       verify_bts=False    req_rat=all     should_be_onair=False       wait_for=300
    Sleep   300
    Check server type and Verify TLS paramter and version    dcap    tls12   RSA    tls_capture_6
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_rsa}
    Get Pcap Details for TLS1_2 for dcap
