*** Settings ***
Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for DCAP in vDU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify support for DCAP with RSA and ECDSA with TLS1.3 and TLS1.2"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009373-B"
...     [Requirement ID]    "TT_TTSEC.2358"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase configuration with DCAP MOC"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvDU-TL5562_20230523-1608.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_B_vdu.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vdu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...     dut=vdu_9373_b     alias=default


*** Test Cases ***
[1]CB009373_B__SEC__Activation_and Deactivation_Modification_of_the_Elliptic_curve_certificate_support_for_TLS
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Loading SCF file which has DCAP configuration with RSA and TLS1.3 enabled
    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_dcap}    timeout=300    alias=con22
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Trigger CMP IR to fetch both ECDSA and RSA certificate
    Triger CMP IR to install certificates on vDU    RSA     ECDSA
    Comment     Check TLS with RSA with TLS1.3 version
    Check server type and Verify TLS paramter and version    dcap   tls13    RSA   ${delta_scf_dcap_delete}
    ...     ${delta_scf_dcap_rsa}
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Comment     Scenario Covers DCAP with RSA and TLS1.2 version
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Set Tls version to 1.3 disabled and 1.2 enabled
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_change_tls13_to_tls12}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}
    ...     timeout=300    alias=con22
    Sleep   100
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Check server type and Verify TLS paramter and version    dcap    tls12   RSA      ${delta_scf_dcap_delete}
    ...     ${delta_scf_dcap_rsa}
    Teardown Oamops     dut=vdu_9373_b     alias=con22

    Comment     Scenario covers DCAP with ECDSA and TLS 1.3 version
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Load SCF with DCAP configuration for ECDSA with TLS1.3
    Run Keyword And Ignore Error    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_dcap_ecdsa}
    ...     timeout=300    alias=con22
    Sleep   100
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Check TLS with ECDSA with 1.3 version
    Check server type and Verify TLS paramter and version    dcap    tls13   ECDSA    ${delta_scf_dcap_delete}
    ...     ${delta_scf_dcap_ecdsa}
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Comment     Scenario covers DCAP with ECDSA TLS 1.2 version
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Set Tls version to 1.3 disabled and 1.2 enabled
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_change_tls13_to_tls12}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Check TLS with ECDSA with 1.2 version
    Check server type and Verify TLS paramter and version    dcap    tls12   ECDSA    ${delta_scf_dcap_delete}
    ...     ${delta_scf_dcap_ecdsa}
    Get Pcap Details for TLS1_2 for ECDSA for dcap      ${filename_A_dcap_tls}
    [Teardown]     Teardown Oamops     dut=vdu_9373_b     alias=con22
