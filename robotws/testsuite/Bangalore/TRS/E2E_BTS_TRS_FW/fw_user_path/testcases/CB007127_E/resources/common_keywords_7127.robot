*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot


*** Keywords ***


Basic commissioning
    Perform Commissioning      scf_file=${vcu_base_scf}      timeout=600      dut=vcu_1         alias=vcu
    BuiltIn.Sleep   200

Triger CMP IR to install certificates on vCU
    Setup Oamops        dut=vcu_1       alias=vcu
    Certificate Configure   dut=vcu_1     operation=restore_vendor_certificate      alias=vcu
    BuiltIn.Sleep   30
    Certificate Configure   dut=vcu_1     operation=set_certificate_automatic_management        alias=vcu
    ...    reference_number=${refnum}  preshared_key=${psk}   key_pool_type=RSA
    BuiltIn.Sleep   30
    Certificate Configure   dut=vcu_1    operation=install_cmp_certificate     timeout=120         alias=vcu
    ...     key_pool_type=RSA
    BuiltIn.Sleep   30

Configure CRL Source To Certificate Extention
    Setup Oamops        dut=vcu_1       alias=vcu
    Perform Recommissioning     dut=vcu_1     type=delta      delta_file=${CRLDP_extension}         alias=vcu
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=600
    BuiltIn.Sleep   200
    Certificate Configure   dut=vcu_1    operation=get_certificate_revocation_list     timeout=120          alias=vcu
    BuiltIn.Sleep   100


Configure CRL Source To To Manual Configuration And CRL DP
    Setup Oamops        dut=vcu_1       alias=vcu
    Perform Recommissioning     dut=vcu_1     type=delta      delta_file=${multiple_CRLDP_config}        alias=vcu
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=200
    BuiltIn.Sleep   120
    traffic_capture_start       capture_device=vCU        capture_type=plane    plane_type=['mplane']
    ...    pod_names=['po-cran33-oamext-0']      measurement_point=Transport_Interface    timeout=180        alias=vcu
    Certificate Configure   dut=vcu_1    operation=get_certificate_revocation_list     timeout=120          alias=vcu
    BuiltIn.Sleep   80
    traffic_capture_stop   capture_device=vCU     timeout=120       keep_alias=True     alias=vcu
    BuiltIn.Sleep       20
    generate_capture_files     capture_device=vCU        timeout=120        alias=vcu
    BuiltIn.Sleep       20
    Run     rm /home/ute/Desktop/*
    ${CRL_log}=    Upload Traffic Capture File     capture_device=vCU      capture_type=plane     plane_type=['mplane']
    ...     local_path=/home/ute/Desktop    timeout=180       alias=vcu


Verify CRL download          ${CRL_log}
    Setup Oamops        dut=vcu_1       alias=vcu
    [Arguments]     ${CRL_log}
    Analyse Pcap        dut=vcu_1      pcap_filename=${CRL_log}    analysis=verify_ldap_crl_req
    ...    filter_file_name=${filter_file_name}        alias=vcu
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_crl_reply    filter_file_name=${filter_file_name}
    ...    alias=vcu



Remove one incorrect CRLDP configuration,Check alarm
    Setup Oamops        dut=vcu_1       alias=vcu
    Perform Recommissioning     dut=vcu_1     type=delta      delta_file=${remove_invalid_CRLDP_config}       alias=vcu
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=600
    BuiltIn.Sleep   200
    Verify Alarm            faultid=7220       dut=vcu_1          should_exist=${False}             alias=vcu
    BuiltIn.Sleep   100

