*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for different ciphers with graylog server and DCAP server"
...     [Date]      "02-11-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify both RSA & ECDSA operator certificate-based auth with BTS as Client-server for TLS"
...     [Funtion_Hash_Tags] "RSA & ECDSA operator certificate-based authentication"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_Netsec_3197,OM_GEN_SFS_NetSec.3190"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "3707"
...     [Config]    "This testcase requires Trace expert configurations from NRBTS/NRCTRLTS/NRMTRACECU  MOC"
...     [scf_file]  "scf to be updated"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cb008254.robot


Suite Setup     Pre-conditions for testsuite
Suite Teardown  Post-conditions for testteardown

*** Test Cases ***
[1]CB008254_A_Activation of the CB008254 RSA & Elliptic curve certificate support for TLS for Trace Expert and MNI
    Comment     Step 1 Commission with base.xml
    Perform Commissioning   scf_file=${base_scf}    verify_bts_status=True  wait_for_onair_status=900   alias=default
    Sleep   300
    Perform Recommissioning     type=delta      delta_file=${delta_scf_trace}     skip_parameter_relation_errors=${True}
    ...     timeout=300
    Sleep   100
    Comment     Step 2 Configure Certificates on BTS
    Configure certificate on BTS    ${rsa_cert_trace}   ${ecdsa_cert_trace}     ${rsa_password_trace}
    ...     ${ecdsa_password_trace}
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version1_3}
    Read mplane IP
    Read trace_expert ip
    Comment     Step 3 Verify TLS parameters
    Check server type and Verify TLS paramter and version    trex    tls13   ECDSA    tls_capture_0
    ...     ${delta_scf_trace_delete}   ${delta_scf_trace}
    Comment     Step 4 Verify pcap -- no application data
    Get Pcap Details for TLS1_3 for trex
    Comment     Step 5 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Comment     Step 6 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   trex    tls12   ECDSA   tls_capture_1
    ...     ${delta_scf_trace_delete}   ${delta_scf_trace}
    Read trace_expert ip
    Get Pcap Details for TLS1_2 for ecdsa in trex
    Comment     Step 8 Recommission to make changes for rsa case.
    Set tls parameter   ${tls_certtype}     ${certype_rsa}
    Comment     Step 9 Verify DUT did not reboot
    Ping to Mplane
    Comment     Step 10 Recommission to enable TLSv1.3
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version1_3}
    Comment     Step 11 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   trex    tls13   RSA     tls_capture_2
    ...     ${delta_scf_trace_delete}   ${delta_scf_trace_rsa}
    Read trace_expert ip
    Get Pcap Details for TLS1_3 for trex
    Comment     Step 12 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Comment     Step 13 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   trex    tls12   RSA     tls_capture_4
    ...     ${delta_scf_trace_delete}   ${delta_scf_trace_rsa}
    Read trace_expert ip
    Get Pcap Details for TLS1_2 for rsa in trex
    Comment     RAT= LTE
    Comment     Step 1 Perform commisioning.SCF has TLSv1.3 and tlsv1.2 enabled and has certTypeForTlsAuth on ECDSA
    Perform Commissioning   scf_file=${cb008254_traceexpert_4g}    verify_bts_status=False     timeout=400
    ...     alias=default
    Sleep   100
    Read trace_expert ip for 4g
    Read mplane IP
    Comment     Step 2 Verify TLS parameters
    Check server type and Verify TLS paramter and version   trex    tls13   ECDSA   tls_capture_5
    ...     ${delta_scf_trace_delete_4g}    ${delta_scf_trace_4g_ecdsa}
    Comment     Step 3 Verify pcap
    Get Pcap Details for TLS1_3 for trex
    Comment     Step 4 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Comment     Step 5 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   trex    tls12   ECDSA   tls_capture_6
    ...     ${delta_scf_trace_delete_4g}   ${delta_scf_trace_4g_ecdsa}
    Read trace_expert ip for 4g
    Get Pcap Details for TLS1_3 for trex
    Get Pcap Details for TLS1_2 for ecdsa in trex
    Comment     Step 6 Recommission to make changes for rsa case.
    Set tls parameter   ${tls_certtype}     ${certype_rsa}
    Comment     Step 7 Verify DUT did not reboot
    Ping to Mplane
    Comment     Step 8 Recommission to enable TLSv1.3
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version1_3}
    Comment     Step 9 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   trex    tls13   RSA     tls_capture_7
    ...     ${delta_scf_trace_delete_4g}    ${delta_scf_trace_4g}
    Read trace_expert ip for 4g
    Get Pcap Details for TLS1_3 for trex
    Comment     Step 10 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Comment     Step 11 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   trex    tls12   RSA     tls_capture_8
    ...     ${delta_scf_trace_delete_4g}    ${delta_scf_trace_4g}
    Read trace_expert ip for 4g
    Get Pcap Details for TLS1_2 for rsa in trex
