*** Settings ***
Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for TLS with Netact in vDU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify support for TLS with Netact  with RSA and ECDSA with TLS1.3 and TLS1.2"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009373-B"
...     [Requirement ID]    "TT_TTSEC.2359"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase configuration with oamTls configuration set to forced"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvDU-TL5562_20230620-1552_Netact.xml"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_B.robot


Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vdu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...     dut=vdu_9373_b     alias=default



*** Test Cases ***
[1]CB009373_B__SEC__ECDSA_operator_certificate_based_authentication_with_BTS_as_client-server_for_tlsv1.3_VDU
    Comment     Scenario Covers Netact with RSA and TLS1.2 version on vDU
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Load scf for vDU that has basic configuration
    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_netact}    timeout=300    alias=con22
    Sleep   100
    Comment     Trigger CMP IR to fetch both ECDSA and RSA certificate
    Triger CMP IR to add CLOUD certs   RSA  vdu_9373_b
    Comment     Load cert for Netact via install cert
    Install Netact Cert     vdu_9373_b
    Comment     Check TLS with Netact
    Check TLS   tls12   vdu_9373_b  vdu_9373_b.ocp  ${delta_to_change_oamtls_off}   ${delta_to_change_oamtls_forced}
    [TEARDOWN]  Teardown Oamops     dut=vdu_9373_b     alias=con22
    Comment       No support on Netact side since shared lab is used.
    Comment     Scenario Covers Netact with RSA and TLS1.3 version on vDU
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Load scf for vDU that has basic configuration
    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_dcap}    timeout=300    alias=con22
    Comment     Trigger CMP IR to fetch both ECDSA and RSA certificate
    Triger CMP IR to add CLOUD certs   RSA  vdu_9373_b
    Comment     Set tls to version 1.3
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_change_tls12_to_tls13}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Comment     Check TLS with Netact
    Check TLS   tls13    vdu_9373_b     vdu_9373_b.ocp  ${delta_to_change_oamtls_off}   ${delta_to_change_oamtls_forced}
    Teardown Oamops     dut=vdu_9373_b     alias=con22

    Comment     Scenario Covers Netact with ECDSA and TLS1.2 version on vDU
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Trigger CMP IR to fetch ECDSA cert
    Triger CMP IR to add CLOUD certs   ECDSA    vdu_9373_b
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_change_tls13_to_tls12}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=30
    ...     alias=con22
    Comment     Check TLS with Netact
    Check TLS   tls12   vdu_9373_b  vdu_9373_b.ocp  ${delta_to_change_oamtls_off}
    ...     ${delta_to_change_oamtls_forced}
    Teardown Oamops     dut=vdu_9373_b     alias=con22

    Comment     Scenario Covers Netact with ECDSA and TLS1.3 version on vDU
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Load scf for vDU that has basic configuration
    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_dcap}    timeout=300    alias=con22
    Comment     Trigger CMP IR to fetch both ECDSA and RSA certificate
    Triger CMP IR to install certificates   rsa     ecdsa
    Comment     Set tls to version 1.3
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_change_tls12_to_tls13}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Comment     Check TLS with Netact
    Check TLS with ECDSA    tls13   vdu_9373_b      vdu_9373_b.ocp
    Teardown Oamops     dut=vdu_9373_b     alias=con22
