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

Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Triger CMP IR to install certificates on vDU
    [Arguments]     ${keypoolType}  ${keypoolType2}
    Certificate Configure   dut=vdu_9373_b     operation=restore_vendor_certificate  alias=con22
    Sleep   60
    Certificate Configure   dut=vdu_9373_b     operation=set_certificate_automatic_management
    ...     reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=con22
    Sleep   60
    Certificate Configure   dut=vdu_9373_b    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=con22
    Sleep   60
     Certificate Configure   dut=vdu_9373_b     operation=set_certificate_automatic_management
     ...    reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType2}   alias=con22
    Sleep   60
    Certificate Configure   dut=vdu_9373_b    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType2}  alias=con22
    Sleep   60

Check server type and Verify TLS paramter and version
    [Arguments]     ${server_type}      ${tls_version}      ${poolType}     ${delta_to_delete}  ${delta_to_add}
    Run Keyword If      '${server_type}' == 'dcap'  Verify TLS parameter and version    ${delta_to_delete}
    ...     ${delta_to_add}     ${tls_version}  ${poolType}


Verify TLS parameter and version
    [Arguments]     ${delta_to_delete}  ${delta_to_add}     ${tls_version}  ${poolType}
    Setup Oamops    dut=vdu_9373_b    alias=con23
    Setup Remote Access    remote_device=vdu_9373_b.ocp     alias=conn26
    Execute Interactive Remote Command     command=${oam_pod_name}     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap_tls}      alias=conn26
    Sleep   20
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_delete}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Perform Recommissioning     dut=vdu_9373_b     type=delta      delta_file=${delta_to_add}
    ...     skip_parameter_relation_errors=${True}  force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Sleep   300
    Execute Interactive Remote Command     command=exit     alias=conn26
    Comment     Step 4 stop capture
    Copy From Cluster To VM     ${vdu_path_tls}
    Run Keyword If  '${poolType}'=='RSA' and '${tls_version}'=='tls13'     Rename pcap     ${changed_name_dcap_rsa}
    Run Keyword If  '${poolType}'=='ECDSA' and '${tls_version}'=='tls13'    Rename pcap     ${changed_name_dcap_ecdsa}
    Run Keyword If  '${poolType}'=='RSA' and '${tls_version}'=='tls12'  Rename pcap     ${changed_name_dcap_rsa_tls12}
    Run Keyword If  '${poolType}'=='ECDSA' and '${tls_version}'=='tls12'    Rename pcap ${changed_name_dcap_ecdsa_tls12}
    Teardown Remote Access  alias=conn26
    Teardown Oamops     dut=vdu_9373_b     alias=con23
    Verify TLS version and packet   ${tls_version}    ${filename_A_dcap_tls}

Copy From Cluster To VM
    [Arguments]     ${path_in_cluster}
    Setup Remote Access    remote_device=vdu_9373_b.ocp     alias=conn28
    Execute Interactive Remote Command     command=${path_in_cluster}     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm_dcap_tls}    exit_prompt= password:  alias=conn28
    Execute Interactive Remote Command     command=ute  exit_prompt=$   alias=conn28
    Teardown Remote Access      alias=conn28


Rename pcap
    [Arguments]     ${renamed_pcap}
    Setup Remote Access    remote_device=remote_device_1    alias=conn30
    Execute Interactive Remote Command     command=${renamed_pcap}  alias=conn30
    Teardown Remote Access      alias=conn30


Read DCAP IP
        ${dcap_server}=     Get Parameter   param_path=${dcap_ip_moc}
        Set Suite Variable          ${dcap_server}


Verify TLS version and packet
    [Arguments]     ${tls_version}      ${file}
    Run Keyword If  '${tls_version}'=='tls13'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_version       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls13'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_1_3_cipher_suites       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls13'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_application_data       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls12'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_version_1_2       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls12'    Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_1_2_cipher_suites       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls12'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls12_application_data       filter_file_name=${traffic_filter_file_name}


Get Pcap Details for TLS1_2 for ECDSA for dcap
    [Arguments]     ${file}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_certificate_ecdsa_tls12
    ...     filter_file_name=${traffic_filter_file_name}
