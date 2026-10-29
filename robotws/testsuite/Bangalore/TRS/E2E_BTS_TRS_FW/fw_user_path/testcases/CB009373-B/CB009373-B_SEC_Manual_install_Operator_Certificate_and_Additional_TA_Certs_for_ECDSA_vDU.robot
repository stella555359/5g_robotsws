*** Settings ***
Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for certificate configuration on vCU and vDU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify support for certificate configuration on vCU and vDU"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009373-B"
...     [Requirement ID]    "OM_GEN_SFS_NetSec.2429"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase needs basic scf with certificate details and CMP MOC"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvDU-TL1107_20230621-1924_Base_SCF.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_B.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vcu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vcu_9373_b     alias=default


*** Test Cases ***
[1]CB009373-B_SEC_Manual_install_Operator_Certificate and Additional TA CA Certificate for_ECDSA_vDU
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Comment     Check loading of additional CA from Operator Certificate- Install Certificate tab with base scf.
    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_base}    timeout=300    alias=con22
    Sleep   300
    Check vmAllocated   oam_pod     vdu_9373_b
    @{config_path}=     Create List     src_ip_vdu
    ${tnl_val1}=     Get Config Variable     ${config_path}
    Set Suite Variable    ${tnl_val1}    ${tnl_val1}
    Comment     Get CMP IP
    ${Primary_cmp}=     Get Parameter    param_path=${cmp_moc}   dut=vdu_9373_b     alias=con22
    Set Suite Variable      ${Primary_cmp}  ${Primary_cmp}
    Comment     Get Src IP
    ${cmp1_SourceIP}=   Get Parameter    param_path=${tnl_val1}   dut=vdu_9373_b     alias=con22
    Set Suite Variable  ${cmp1_SourceIP}    ${cmp1_SourceIP}
    Comment     Loading additional CA cert
    Certificate Configure  dut=vdu_9373_b   operation=install_certificate   cert_file=${additionalca_certificate}
    ...     cert_type=CA  cert_format=PEM   alias=con22
    Sleep    60
    Comment     Manual Trigger with Keypool as RSA when certTypeForAuth is set to RSA and MO added for RSA.CMP IRsuccess
    Triger CMP IR to install certificates   RSA     vdu_9373_b
    Comment     Manual Trigger with Keypool as ECDSA.
    Triger CMP IR to install certificates   ECDSA   vdu_9373_b
    [Teardown]      Teardown Oamops     dut=vdu_9373_b     alias=con22


[2]CB009373-B_SEC_Manual_install_Operator_Certificate and Additional TA CA Certificate for_ECDSA_vCU
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Comment     Check loading of additional CA from Operator Certificate- Install Certificate tab. Basic SCF is loaded.
    Perform Commissioning    dut=vcu_9373_b    scf_file=${comm_file_base_cu}    timeout=300    alias=con22
    Sleep   100
    Check vmAllocated   oam_pod     vcu_9373_b
    @{config_path}=     Create List     src_ip_vcu
    ${tnl_val}=     Get Config Variable     ${config_path}
    Set Suite Variable    ${tnl_val}    ${tnl_val}
    ${cmp1_SourceIP_CU}=    Get Parameter    param_path=${tnl_val}   dut=vcu_9373_b  alias=con22
    Set Suite Variable      ${cmp1_SourceIP_CU}     ${cmp1_SourceIP_CU}
    Comment     Get CMP IP
    ${Primary_cmp}=     Get Parameter    param_path=${cmp_moc}   dut=vcu_9373_b     alias=con22
    Set Suite Variable      ${Primary_cmp}  ${Primary_cmp}
    Certificate Configure   dut=vcu_9373_b      operation=install_certificate   cert_file=${additionalca_certificate}
    ...     cert_type=CA  cert_format=PEM  alias=con22
    Sleep    60
    Comment     Manual Trigger with Keypool as RSA when certTypeForAuth is set to RSA and MO added for RSA.CMP IRsuccess
    Triger CMP IR to install certificates on vCU    RSA
    Comment     Load SCF with CMPECDSA MO and certTypeForTlsAuth set to ECDSA
    Triger CMP IR to install certificates on vCU    ECDSA
   [Teardown]  Teardown Oamops     dut=vcu     alias=con22
