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
Triger CMP IR to install certificates
    [Arguments]     ${keypoolType}      ${remote_ctype}
    Certificate Configure   dut=vdu_9373_b     operation=restore_vendor_certificate  alias=con22
    Sleep   60
    Certificate Configure   dut=vdu_9373_b     operation=set_certificate_automatic_management
    ...     reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=con22
    Sleep   60
    Setup Remote Access    remote_device=vdu_9373_b.ocp     alias=conn26
    Execute Interactive Remote Command     command=${oam_pod_name}     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap}      alias=conn26
    Sleep   20
    Certificate Configure   dut=vdu_9373_b    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=con22
    Sleep   120
    Execute Interactive Remote Command     command=exit     alias=conn26
    Copy From Cluster To VM     ${remote_ctype}
    Run Keyword If  '${keypoolType}'=='RSA'      Rename pcap     ${changed_name}
    Run Keyword If  '${keypoolType}'=='ECDSA'     Rename pcap     ${changed_name_ecdsa}
    Teardown Remote Access  alias=conn26
    Verify CMP packets     ${filename_A}


verify cmp status
    [Arguments]    ${CMP_status_check}
    ${cmp_state_var} =    Query Admin Infomodel     dut=vdu_9373_b     query=get object ${cmp_r_moc_path}   alias=con22
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}


Copy From Cluster To VM
    [Arguments]     ${remote_ctype}
    Setup Remote Access    remote_device=${remote_ctype}     alias=conn28
    Execute Interactive Remote Command     command=${vcu_path_netact}     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm_netact}    exit_prompt= password:  alias=conn28
    Execute Interactive Remote Command     command=ute  exit_prompt=$   alias=conn28
    Teardown Remote Access      alias=conn28


Rename pcap
    [Arguments]     ${renamed_pcap}
    Setup Remote Access    remote_device=remote_device_1    alias=conn30
    Execute Interactive Remote Command     command=${renamed_pcap}  alias=conn30
    Teardown Remote Access      alias=conn30


Verify CMP packets
    [Arguments]     ${filename}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_ir
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_accept
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_certconf
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_pkiconf
    ...     filter_file_name=${traffic_filter_file_name}



Triger CMP IR to install certificates on vCU
    [Arguments]     ${keypoolType}
    Certificate Configure   dut=vcu_9373_b     operation=restore_vendor_certificate  alias=con22
    Sleep   60
    Certificate Configure   dut=vcu_9373_b     operation=set_certificate_automatic_management
    ...     reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=con22
    Sleep   60
    Setup Remote Access    remote_device=vcu_9373_b.ocp     alias=conn26
    ${output}=      Execute Interactive Remote Command     command=${oam_cu_pod_name}   alias=conn26
    ${status}=  Run Keyword And Return Status   Should Contain  ${output}   error
    Run Keyword If  '${status}'=='True'     Execute Interactive Remote Command     command=${oam_cu_pod_name}
    ...     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap}      alias=conn26
    Sleep   20
    Certificate Configure    dut=vcu_9373_b     operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}     alias=con22
    Sleep   120
    Execute Interactive Remote Command     command=exit     alias=conn26
    Copy From Cluster To VM for vCU
    Run Keyword If  '${keypoolType}'=='RSA'      Rename pcap     ${changed_name_cu}
    Run Keyword If  '${keypoolType}'=='ECDSA'     Rename pcap     ${changed_name_ecdsa_cu}
    Teardown Remote Access  alias=conn26
    Verify CMP packets on vCU    ${filename_A}


Copy From Cluster To VM for vCU
    Setup Remote Access    remote_device=vcu_9373_b.ocp     alias=conn28
    Execute Interactive Remote Command     command=${vcu_path}     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm}    exit_prompt= password:  alias=conn28
    Execute Interactive Remote Command     command=ute  exit_prompt=$   alias=conn28
    Teardown Remote Access      alias=conn28

Verify CMP packets on vCU
    [Arguments]     ${filename}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_ir_cu
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_accept_cu
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_certconf_cu
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_pkiconf_cu
    ...     filter_file_name=${traffic_filter_file_name}

Check TLS
    [Arguments]     ${tls_version}  ${dut_ctype}    ${remote_ctype}     ${delta_tls_off}    ${delta_tls_on}
    Setup Remote Access    remote_device=${remote_ctype}     alias=conn26
    Execute Interactive Remote Command     command=${oam_cu_pod_name}     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap_for_netact}      alias=conn26
    Sleep   20
    Perform Recommissioning     dut=${dut_ctype}     type=delta      delta_file=${delta_tls_off}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Perform Recommissioning     dut=${dut_ctype}     type=delta      delta_file=${delta_tls_on}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Integrate from Netact   ${dut_ctype}
    Execute Interactive Remote Command     command=exit     alias=conn26
    Check oamtls status     ${dut_ctype}
    Copy From Cluster To VM     ${remote_ctype}
    Teardown Remote Access  alias=conn26
    Verify TLS version and packet for netact    ${tls_version}      ${filename_A_netact_tls}


Check TLS with ECDSA
    [Arguments]     ${tls_version}  ${dut_ctype}    ${remote_ctype}
    Setup Remote Access    remote_device=${remote_ctype}     alias=conn26
    Execute Interactive Remote Command     command=${oam_cu_pod_name}     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap_for_netact}      alias=conn26
    Sleep   20
    Perform Recommissioning     dut=${dut_ctype}     type=delta      delta_file=${delta_to_change_oamtls_off_vcu}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Perform Recommissioning     dut=${dut_ctype}    type=delta
    ...     delta_file=${delta_to_change_oamtls_forced_vcu_ecdsa}   skip_parameter_relation_errors=${True}
    ...     force_reset=${True}     auto_lock_cells=${True}      timeout=300    alias=con22
    Integrate from Netact   ${dut_ctype}
    Execute Interactive Remote Command     command=exit     alias=conn26
    Check oamtls status     ${dut_ctype}
    Copy From Cluster To VM      ${remote_ctype}
    Teardown Remote Access  alias=conn26
    Verify TLS version and packet for netact   ${tls_version}      ${filename_A_netact_tls}

Verify TLS version and packet for netact
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


Triger CMP IR to add CLOUD certs
    [Arguments]     ${keypoolType}  ${dut_ctype}
    Certificate Configure   dut=${dut_ctype}     operation=restore_vendor_certificate  alias=con22
    Sleep   60
    Certificate Configure   dut=${dut_ctype}     operation=set_certificate_automatic_management
    ...     reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=con22
    Sleep   60
    Certificate Configure   dut=${dut_ctype}    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=con22
    Sleep   60


Install Netact Cert
    [Arguments]     ${cloud_type}
    Certificate Configure  dut=${cloud_type}   operation=install_certificate   cert_file=${additionalca_netact}
    ...     cert_type=CA  cert_format=PEM   alias=con22
    Sleep   60


Integrate from Netact
    [Arguments]   ${dut_ctype}
    Setup Ems   config_device=netact1   alias=default
    Run keyword If  '${dut_ctype}' == 'vcu_9373_b'  Enb Configuration Should Be Discovered  config_device=netact1
    ...     release=${netact_release}   mr=${mr_name}   mrbts_address=${mrbts_em_address_cu}
    ...     dist_name=${dist_name_vcu}      presentation_name=''    http_port=${http_port}
    ...     https_port=${https_port}   ip_version=IPv4     security_mode=TLS     mrbts_em_address=${mrbts_em_address_cu}
    ...     alias=default
     Run keyword If  '${dut_ctype}' == 'vdu_9373_b'     Enb Configuration Should Be Discovered  config_device=netact1
     ...    release=${netact_release}    mr=${mr_name}   mrbts_address=${mrbts_em_address_du}
     ...    dist_name=${dist_name_vdu}      presentation_name=''    http_port=${http_port}  https_port=${https_port}
     ...    ip_version=IPv4     security_mode=TLS     mrbts_em_address=${mrbts_em_address_du}     alias=default
    Teardown Ems    config_device=netact1    alias=default


Check oamtls status
    [Arguments]     ${dut_ctype}
    Setup Oamops    dut=${dut_ctype}    alias=con33
    ${status}=     Get Parameter    param_path=${oam_tls}   dut=${dut_ctype}     alias=con33
    Should Be True      '${status}'=='secured'
    Teardown Oamops     dut=${dut_ctype}     alias=con33

Check oamtls status is off
    [Arguments]     ${dut_ctype}
    ${status}=     Get Parameter    param_path=${oam_tls}   dut=${dut_ctype}     alias=con22
    Should Be True      '${status}'=='notConnected'

Triger CMP IR to install certificates for dcap
    [Arguments]     ${keypoolType}  ${keypoolType2}
    Certificate Configure   dut=vcu_9373_b     operation=restore_vendor_certificate  alias=con22
    Sleep   60
    Certificate Configure   dut=vcu_9373_b     operation=set_certificate_automatic_management
    ...     reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=con22
    Sleep   60
    Certificate Configure   dut=vcu_9373_b    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=con22
    Sleep   60
     Certificate Configure   dut=vcu_9373_b     operation=set_certificate_automatic_management
     ...    reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType2}   alias=con22
    Sleep   60
    Certificate Configure   dut=vcu_9373_b    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType2}  alias=con22
    Sleep   60

Check server type and Verify TLS paramter and version
    [Arguments]     ${server_type}      ${tls_version}      ${poolType}     ${delta_to_delete}  ${delta_to_add}
    Run Keyword If      '${server_type}' == 'dcap'  Verify TLS parameter and version    ${delta_to_delete}
    ...     ${delta_to_add}     ${tls_version}  ${poolType}     ${collect_pcap_tls_cu}


Verify TLS parameter and version
    [Arguments]         ${delta_to_delete}  ${delta_to_add}     ${tls_version}  ${poolType}     ${collect_pcap}
    Setup Oamops    dut=vcu_9373_b    alias=con23
    Setup Remote Access    remote_device=vcu_9373_b.ocp     alias=conn26
    Execute Interactive Remote Command     command=${oam_pod_name}     alias=conn26
    Perform Recommissioning     dut=vcu_9373_b     type=delta      delta_file=${delta_to_delete}
    ...     skip_parameter_relation_errors=${True}      timeout=300    alias=con23
    Execute Interactive Remote Command     command=${collect_pcap}      alias=conn26
    Sleep   200
    Perform Recommissioning     dut=vcu_9373_b     type=delta      delta_file=${delta_to_add}
    ...     skip_parameter_relation_errors=${True}      timeout=300   alias=con23
    Sleep   300
    Execute Interactive Remote Command     command=exit     alias=conn26
    Comment     stop capture
    Copy From Cluster To VM for dcap   ${vcu_path_tls}
    Run Keyword If  '${poolType}'=='RSA' and '${tls_version}'=='tls13'  Rename pcap     ${changed_name_dcap_rsa_cu}
    Run Keyword If  '${poolType}'=='ECDSA' and '${tls_version}'=='tls13'    Rename pcap ${changed_name_dcap_ecdsa_cu}
    Run Keyword If  '${poolType}'=='RSA' and '${tls_version}'=='tls12'  Rename pcap ${changed_name_dcap_rsa_tls12_cu}
    Run Keyword If  '${poolType}'=='ECDSA' and '${tls_version}'=='tls12'
    ...     Rename pcap     ${changed_name_dcap_ecdsa_tls12_cu}
    Teardown Remote Access  alias=conn26
    Teardown Oamops     dut=vcu_9373_b     alias=con23
    Verify TLS version and packet on cu     ${tls_version}    ${filename_A_dcap_tls}


Get Pcap Details for TLS1_2 for ECDSA for dcap
    [Arguments]     ${file}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_certificate_ecdsa_tls12
    ...     filter_file_name=${traffic_filter_file_name}

Copy From Cluster To VM for dcap
    [Arguments]     ${path_in_cluster}
    Setup Remote Access    remote_device=vcu_9373_b.ocp     alias=conn28
    Execute Interactive Remote Command     command=${path_in_cluster}     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm_dcap_tls}    exit_prompt= password:  alias=conn28
    Execute Interactive Remote Command     command=ute  exit_prompt=$   alias=conn28
    Teardown Remote Access      alias=conn28

Read DCAP IP
        ${dcap_server}=     Get Parameter   param_path=${dcap_ip_moc}   dut=vcu_9373_b  alias=con23
        Set Suite Variable          ${dcap_server}

Verify TLS version and packet on cu
    [Arguments]     ${tls_version}      ${file}
    Run Keyword If  '${tls_version}'=='tls13'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_version       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls13'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_1_3_cipher_suites_cu       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls13'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_application_data       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls12'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls_version_1_2       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls12'    Analyse Pcap       pcap_filename=${file}
    ...     analysis=verify_tls_1_2_cipher_suites_cu       filter_file_name=${traffic_filter_file_name}
    Run Keyword If  '${tls_version}'=='tls12'   Analyse Pcap        pcap_filename=${file}
    ...     analysis=verify_tls12_application_data       filter_file_name=${traffic_filter_file_name}
