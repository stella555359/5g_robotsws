*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for TLS with Netact in vDU"
...     [Date]      "20-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify support for TLS with Netact with RSA with TLS1.3 and TLS1.2"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009857-D"
...     [Requirement ID]    "TT_TTSEC.2360"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "1"
...     [Config]    "This testcase needs oamtls parameter configuration to forced"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_vDU5562_20230620-1614_Netact.xml"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_B.robot

Suite Setup     Setup Oamops    dut=vdu_9857    alias=default
Suite Teardown      Teardown Oamops    dut=vdu_9857     alias=default

*** Test Cases ***
[1]CB009857-D_Verification of TLS authentication support when peer provides certificate with RSA key length with 4096-bit via WebEM
    Comment     Load scf for vDU that has basic configuration
    Perform Commissioning    dut=vdu_9857    scf_file=${comm_file_netact_vdu}    timeout=300    alias=default
    Sleep   300
    Check oamtls status is off      vdu_9857
    Comment     Trigger CMP IR to fetch RSA certificate
    Triger CMP IR to add CLOUD certs   RSA  vdu_9857
    Comment     Load cert for Netact via install cert
    Install Netact Cert
    Comment     Check TLS with Netact
    Check TLS       tls12       vdu_9857        vdu_9857.ocp    ${delta_to_change_oamtls_forced_vdu}
    Comment     Trigger CMP IR to fetch RSA certificate
    Triger CMP IR to add CLOUD certs   RSA  vdu_9857
    Setup Oamops     dut=vdu_9857     alias=default
    Comment     Set tls to version 1.3
    Perform Recommissioning     dut=vdu_9857     type=delta      delta_file=${delta_to_change_tls12_to_tls13_on_cu}
    ...     skip_parameter_relation_errors=${True}      timeout=300     alias=default
    Teardown Oamops     dut=vdu_9857     alias=default
    Comment     Check TLS with Netact
    Check TLS13   tls13   vdu_9857  vdu_9857.ocp
