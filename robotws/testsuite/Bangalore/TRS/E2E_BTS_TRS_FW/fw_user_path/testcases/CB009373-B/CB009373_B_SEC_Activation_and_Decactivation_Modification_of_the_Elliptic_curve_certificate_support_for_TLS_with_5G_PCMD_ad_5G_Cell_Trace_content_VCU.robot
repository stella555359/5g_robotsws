*** Settings ***
Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for DCAP in vCU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify support for DCAP with RSA and ECDSA with TLS1.3 and TLS1.2 on vCU"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009373-B"
...     [Requirement ID]    "OM_GEN_SFS_NetSec.3205"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase configuration with DCAP MOC"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_vCU5562_20230530-1155.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_B.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vcu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...     dut=vcu_9373_b     alias=default



*** Test Cases ***
[1]CB009373_B__SEC__Activation_and Decactivation_Modification_of_the_Elliptic_curve_certificate_support_for_TLS
    Comment     Scenario Covers DCAP with RSA and TLS1.3 version
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Comment     Loading SCF file which has DCAP configuration with RSA and TLS1.3 enabled
    Perform Commissioning    dut=vcu_9373_b    scf_file=${comm_file_dcap_cu}    timeout=300    alias=con22
    Teardown Oamops     dut=vcu_9373_b     alias=con22
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Comment     Trigger CMP IR to fetch both ECDSA and RSA certificate
    Triger CMP IR to install certificates for dcap      RSA     ECDSA
    Teardown Oamops     dut=vcu_9373_b     alias=con22
    Comment     Check TLS with RSA with TLS1.3 version
    Check server type and Verify TLS paramter and version    dcap   tls13    RSA   ${delta_scf_dcap_delete_cu}
    ...     ${delta_scf_dcap_rsa_cu}
    Comment     Scenario Covers DCAP with RSA and TLS1.2 version
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Comment     Set Tls version to 1.3 disabled and 1.2 enabled
    Perform Recommissioning     dut=vcu_9373_b     type=delta      delta_file=${delta_to_change_tls13_to_tls12_on_cu}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Teardown Oamops     dut=vcu_9373_b     alias=con22
    Check server type and Verify TLS paramter and version    dcap    tls12   RSA      ${delta_scf_dcap_delete_cu}
    ...     ${delta_scf_dcap_rsa_cu}

    Comment     Scenario covers DCAP with ECDSA and TLS 1.3 version
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Comment     Set TLSversion 1.3
    Perform Recommissioning     dut=vcu_9373_b     type=delta      delta_file=${delta_to_change_tls12_to_tls13_on_cu}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Teardown Oamops     dut=vcu_9373_b     alias=con22
    Comment     Check TLS with ECDSA with 1.3 version
    Check server type and Verify TLS paramter and version    dcap    tls13   ECDSA    ${delta_scf_dcap_delete_cu}
    ...     ${delta_scf_dcap_ecdsa_cu}
    Comment     Scenario covers DCAP with ECDSA TLS 1.2 version
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Comment     Set Tls version to 1.3 disabled and 1.2 enabled
    Perform Recommissioning     dut=vcu_9373_b     type=delta      delta_file=${delta_to_change_tls13_to_tls12_on_cu}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Teardown Oamops     dut=vcu_9373_b     alias=con22
    Comment     Check TLS with ECDSA with 1.2 version
    Check server type and Verify TLS paramter and version    dcap    tls12   ECDSA    ${delta_scf_dcap_delete_cu}
    ...     ${delta_scf_dcap_ecdsa_cu}
    Get Pcap Details for TLS1_2 for ECDSA for dcap      ${filename_A_dcap_tls}
    [Teardown]  Run Keyword and Ignore Error    Teardown Oamops     dut=vcu_9373_b     alias=con22
