*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the sw rollback functionality when there is ECDSA certificate"
...     [Date]      "02-11-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify with automatic Configured ECDSA certificates are taken after SW roll-back fallback,
...     so that BTS can reconnect to via TLS"
...     [Funtion_Hash_Tags] "RSA & ECDSA operator certificate-based authentication"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_NetSec.3190"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "2205"
...     [Config]    "This testcase requires a build in active partition to have ECDSA certs configured and
...     then we do rollback to a passive build which...      RSA certificate"
...     [scf_file]  "Configuration_scf_MRBTS-2205_Synergy_ASIK_ABIL_5G_20221106-0748_swrollback_ecdsa.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cb008254.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown  Post-conditions for testteardown

*** Variables***

***Test Cases***
[1]CB008254_B_Verify with automatic Configured ECDSA certificates are taken after SW roll-back fallback
    Comment     Step 1 Commission with base.xml
    Perform Commissioning   scf_file=${base_scf}    verify_bts_status=False     timeout=400     alias=default
    Sleep   300
    Perform Recommissioning     type=delta      delta_file=${delta_scf_dcap_ecdsa}     skip_parameter_relation_errors=${True}
    ...     timeout=300
    Sleep   100
    Configure certificate on BTS    ${rsa_cert}     ${ecdsa_cert}   ${rsa_password_dcap}    ${ecdsa_password_dcap}
    Rollback Software   timeout=300      alias=default
    Perform Commissioning   scf_file=${cb008254_swrollback_rsa}   verify_bts_status=False     timeout=400
    ...     alias=default
    Comment     Step 2 Perform Rollback - build with RSA
    Rollback Software   timeout=300      alias=default
    Sleep   100
    ${status}=     Get Parameter        param_path=${featcadm_actCertPartitionSynch}
    Should Be True      '${status}'=='True'
    ${status}=     Get Parameter        param_path=${dcap_certtype}
    Should Be True      '${status}'=='ECDSA'
    Check server type and Verify TLS paramter and version   dcap   tls13    ECDSA   tls_capture_0
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_ecdsa}
    Read DCAP IP
    Get Pcap Details for TLS1_3 for dcap
    Expected alarms
    Comment     Step 3 Verify TLS parameters
    Rollback Software   timeout=300      alias=default
    Sleep   100
    Check server type and Verify TLS paramter and version    dcap    tls13   RSA     tls_capture_1
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_rsa}
    Comment     Step 4 Verify pcap
    Read DCAP IP
    Get Pcap Details for TLS1_3 for dcap
    ${status}=     Get Parameter        param_path=${featcadm_actCertPartitionSynch}
    Should Be True      '${status}'=='True'
    ${status}=     Get Parameter        param_path=${dcap_certtype}
    Should Be True      '${status}'=='RSA'


    Comment     Step 5 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Sleep   60
    Comment     Step 6 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   dcap    tls12   RSA     tls_capture_2
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_rsa}
    Read DCAP IP
    Get Pcap Details for TLS1_2 for dcap
    Comment     Step 7 Rollback again to come back to software that supports ECDSA
    Rollback Software   timeout=300      alias=default
    Sleep   100
    Comment     Step 8 Check tls certtype to be ecdsa
    ${status}=      Get Parameter        param_path=${dcap_certtype}
    Should be True      '${status}' == 'ECDSA'
    ${status}=      Get Parameter        param_path=${tls13_status}
    Should Be True      '${status}' == 'True'
    Comment     Step 9 Verify TLS parameters
    Check server type and Verify TLS paramter and version   dcap   tls13    ECDSA   tls_capture_0
    ...     ${delta_scf_dcap_delete}    ${delta_scf_dcap_ecdsa}
    Comment     Step 10 Verify pcap
    Read DCAP IP
    Get Pcap Details for TLS1_3 for dcap
    Comment     Step 11 Recommission tlsv1.3 to disabled and tlsv1.2 to enabled.
    Set tls parameter   ${tls_version_1_3_path}     ${tls_version_1_3_disabled}
    Set tls parameter   ${tls_version_1_2_path}     ${tls_version_1_2_enabled}
    Sleep   60
    Comment     Step 12 Verify TLS parameters and pcap
    Check server type and Verify TLS paramter and version   dcap    tls12   ECDSA   tls_capture_3
    ...     ${delta_scf_dcap_delete}   ${delta_scf_dcap_ecdsa}
    Read DCAP IP
    Get Pcap Details for TLS1_2 for dcap
    Get Pcap Details for TLS1_2 for ECDSA for dcap
    Alarms after reset      ${pre_alarm_faultids}
