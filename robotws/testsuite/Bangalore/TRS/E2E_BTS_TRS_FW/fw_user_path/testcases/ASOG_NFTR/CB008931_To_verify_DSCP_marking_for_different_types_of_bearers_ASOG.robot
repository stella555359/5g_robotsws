***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate CB006274 Use case"
    ...     [Date]                  ""
    ...     [SCF]                   "plain_scf.xml"
    ...     [Author]                "Nandini Periyaswamy"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB006274"
    ...     [Validation_status]     "draft"
    ...     [Validated_TestLine]    "ASIB_TL043_10.53.187.104"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup     Pre-conditions for testsuite
Suite Teardown      Post-conditions for testteardown
#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops

*** Test Cases ***
[1]CB008931_SR_A_B2_To_verify_DSCP_marking_for_different_types_of_bearers_setup_during_E_RAB_Setup_procedure_actPubSafetyBearers_
#actOperatorQCI_actOperatorQCIGBR_actIncNumOperatorQci

     Pre-condition
     Bring setup on-air

    ${error_description}=    Set Variable    *Whenever LNBTS_FDD-0 having \${LNBTS_FDD-0.actPubSafetyVideo\} (value: true) equal to true, it is
    ...     required that \${LNBTS_FDD-0.actPubSafetyBearers\} (value: false) equal to true*
     Run Keyword and expect error    ${error_description}   Perform Recommissioning     type=param      rat=lte
     ...     param_path=${CB006274_feature_flag}     operation=update    value=true     skip_parameter_relation_errors=${False}    timeout=60

##    [Documentation]     enabling just actpubsafetybearers and establish qci67 should fail
    UE with qci67 bearer establishment should fail     lte    6op_cus_lte    2     11      1000    1       244:09
    QCI67 bearer establishment with initial context setuprequest should fail   lte    6op_cus_lte    3     11     1     244:09

     Perform Recommissioning     type=param     rat=lte        param_path=${pub_safety_feature_flag}     operation=update    value=true
     ...     skip_parameter_relation_errors=${true}    timeout=60
    UE with qci67 bearer establishment should fail     lte    6op_cus_lte    2     11      1000    1   244:09
    QCI67 bearer establishment with initial context setuprequest should fail   lte    6op_cus_lte    3     11    1    244:09

##    [Documentation]       To make sure actmcvideooverbooking should be configured whenever actpubsafetyvideo is set to true
    ${error_description2}=    Set Variable    *Whenever \${LNBTS_FDD-0.actPubSafetyVideo\} (value: true) is equal to true, it is required that
    ...     LNCEL_FDD.actMcVideoOverbooking must be configured in all LNCEL_FDD instances'*
    Run Keyword and expect error    ${error_description2}       Perform Recommissioning     type=param     rat=lte
    ...     param_path=${CB006274_feature_flag}     operation=update    value=true     skip_parameter_relation_errors=${False}    timeout=60
    Randomize 2 additional operators
    Verify CB006274 for operator      0
    Verify CB006274 for operator      ${operators}[0]
    Verify CB006274 for operator      ${operators}[1]

    FOR        ${i}        IN RANGE    0       6
        Call verification with operator     ${i}
    END

***Keywords***
Randomize 2 additional operators
    ${operators}=         Evaluate    random.sample(range(1, 6), 2)    random
    Set Suite Variable      ${operators}        ${operators}


Fetch the ips
     [Arguments]     ${op}
     Set Suite variable     ${op}
     ${cplane_ip}=      Get Parameter         param_path=TRSNW-${op}:${cplane_ip_moc}
     Set Suite Variable    ${cplane_ip}
     ${uplane_ip}=      Get Parameter         param_path=TRSNW-${op}:${uplane_ip_moc}
     Set Suite Variable    ${uplane_ip}
     ${mme_ip}=      Get Parameter         param_path=LNMME-${op}:${mme_ip_moc}
     Set Suite Variable    ${mme_ip}
     ${mcc}=     Get Parameter         param_path=LNMME-${op}:${mcc_moc}
     ${mnc}=     Get Parameter         param_path=LNMME-${op}:${mnc_moc}
     ${mnc}=    Run Keyword if    '${mnc}'=='9'      Set Variable     09      ELSE      Set Variable     ${mnc}
     ${plmn}=    Catenate     SEPARATOR=:     ${mcc}    ${mnc}
     Set Suite Variable      ${plmn}
     ${qci_67_dscp}=      Get Parameter         param_path=${qci67_dscp_moc}
     Set Suite Variable    ${qci_67_dscp}

Pre-condition
     ${interface_adddress_last_octet}=        Set Variable        1
     ${interface_adddress_last_octet_IPv6}=      Set Variable        0X06
     ${sim_ip}=            Set Variable     20

    ${vlan_id}=    Set Variable     ${vlan_ids}[1]
    Copy File     ${delta_dir}/${delta_6op_config}    ${delta_dir}/${delta_6op_config_copy}
    FOR        ${i}        IN RANGE    0       13
           ${nw_ipv4}=         Evaluate            ${interface_adddress_last_octet}-1
           ${nw_ipv6}=         Evaluate            hex(${interface_adddress_last_octet_IPv6}-2)
           ${nw_ipv6}=         Evaluate            hex(${nw_ipv6}).lstrip("0x")
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
           Bring IPv4 VLAN VM Interfaces       ${vlan_id}            10.0.3.${interface_adddress_last_octet}
           ...      10.0.3.${broadcast_adddress_last_octet}     30
           Run      sudo ifconfig eth3.${vlan_id} inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
           ${ENB_interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+1
           ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
           ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
           Run     sudo sed -i "s/{{vlan_id${i}}}/${vlan_id}/g" ${delta_dir}/${delta_6op_config}
           ${vlan_id}=      Evaluate      ${vlan_id}+1
    END

     FOR    ${i}    IN RANGE        0       13
           Run      sudo ip a a 10.0.1.${sim_ip}/24 dev eth3.${vlan_ids}[0]
           ${sim_ip}=    Evaluate   ${sim_ip}+1
     END

    Perform Delta Commissioning      ${delta_6op_config}
    Sleep       120
    Perform Recommissioning     type=delta      delta_file=${Multi_QCI}    skip_parameter_relation_errors=${True}   timeout=300
    Sleep     60

    [Teardown]           Copy File     ${delta_dir}/${delta_6op_config_copy}    ${delta_dir}/${delta_6op_config}


Bring setup on-air
    Call Setup  lte=6op_cus_lte:data        attach=      verify_attach=${False}       parallel=${False}
    Sleep    60
    Verify Bts Status       req_rat=all
    FOR    ${i}    IN RANGE        0       6
           ${link_status}=   Get Parameter       param_path=${mme_moc}-${i}:${s1_link}
           Should Be True    '${link_status}'=='available'
    END

Bring IPv4 VLAN VM Interfaces
    [Arguments]             ${Vlan_ID}          ${interface_address}        ${broadcast_ip_address}         ${sunbet_mask}
    ${eth_vlan}=    Set Variable    sudo ip link add link eth3 name eth3.${Vlan_ID} type vlan id ${Vlan_ID}
    Run     ${eth_vlan}
    ${interface_ip}=    Set Variable    sudo ip addr add ${interface_address}/${sunbet_mask} brd ${broadcast_ip_address} dev eth3.${Vlan_ID}
    Run     ${interface_ip}
    ${interface_up}=    Set Variable    sudo ip link set dev eth3.${Vlan_ID} up
    Run     ${interface_up}

UE with qci67 bearer establishment should fail
    [Arguments]        ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${sgw_id}   ${plmn}
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    [Documentation]    using run keyword and expect error since the qci67 bearer establishment has to fail with CB006274 feature flag disabled.
    Run Keyword and Expect error    *sErrBearerAcquireUiBearerAllocationReject*         Configure UE        ${prof}=${prof_id}:data
    ...     command=bearer_add ue=${ue_id} qci=67 gbr_ul=${bit_rate} gbr_dl=${bit_rate} mbr_ul=${bit_rate} mbr_dl=${bit_rate}
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=qci67_invalid_qos   filter_file_name=${CB006274_trf_filter}
    Detach UE     ${prof}     ${prof_id}    ${ue_id}

QCI67 bearer establishment with initial context setuprequest should fail
    [Arguments]       ${prof}     ${prof_id}    ${ue_id}     ${cell_id}   ${sgw_id}   ${plmn}
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=init_setup
    [Documentation]    using run keyword and expect error since the qci67 bearer establishment has to fail with CB006274 feature flag disabled and
    ...    qci67 beaerer is established with initial setup context req , ue attach will be successful but qci67 establisment fails
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop       alias=init_setup
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=qci67_invalid_qos   filter_file_name=${CB006274_trf_filter}
    Detach UE     ${prof}     ${prof_id}    ${ue_id}

Attach UE and establish dedicated qci67 bearer
    [Arguments]        ${prof}     ${prof_id}    ${ue_id}     ${cell_id}   ${bit_rate}   ${sgw_id}   ${plmn}
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=67 gbr_ul=${bit_rate} gbr_dl=${bit_rate}
    ...     mbr_ul=${bit_rate} mbr_dl=${bit_rate}
    Sleep    5

Verify dedicated bearer QCI establishment is successful with default qci
    [Arguments]        ${ded_qci}    ${def_qci}     ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${ul_data}
    ...     ${dl_data}   ${sgw_id}   ${plmn}
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${ded_qci} gbr_ul=${bit_rate} gbr_dl=${bit_rate}
    ...     mbr_ul=${bit_rate} mbr_dl=${bit_rate}
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${def_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_req   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}
    Verify DSCP from pcap   ${pcap_file}
#    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}

Retrieve UE ip
    [Arguments]    ${prof}    ${prof_id}   ${ue_id}
    ${output}=          Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_disp id=${ue_id}    pass_regexp=ip [active]   timeout=60
    Log To Console     ${output}
    ${lines}=        Split to lines   ${output}
    ${index}=        Set Variable     0
    FOR   ${line}   IN   @{lines}
        ${index}=   Evaluate         ${index}+1
        ${found}=   run_keyword_and_return_status    Should Contain    ${line}    ip [active]
        Exit For Loop If    ${found}==True
        Set Suite Variable    ${line}
    END
    ${words}=            Split String       ${line}
    ${ip}=               Set Variable      ${words}[2]
    Set Suite Variable    ${ue_ip}    ${ip}



Verify qci bearer establishment with initial context setuprequest with default qci
	[Arguments]       ${ded_qci}   ${def_qci}    ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${ul_data}
    ...     ${dl_data}  ${sgw_id}   ${plmn}
	[Documentation]     qci67 bearer establishment is initiated during the UE attach as configured in lua file
    log     ${bit_rate}
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
	Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${def_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep   2
	Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${def_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_req_with_bearer   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}
    Verify DSCP from pcap   ${pcap_file}

Verify dedicated bearer QCI establishment is successful with default qci and dedicated qci
	[Arguments]        ${ded_qci}   ${second_ded_qci}     ${def_qci}     ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${ul_data}
    ...     ${dl_data}   ${sgw_id}   ${plmn}
	Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
	Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${second_ded_qci}
	Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${ded_qci} gbr_ul=${bit_rate} gbr_dl=${bit_rate}
    ...     mbr_ul=${bit_rate} mbr_dl=${bit_rate}
	Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${def_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
	Sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${def_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_req   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=mult_erab_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}
    Set Suite Variable   ${ded_qci}     ${second_ded_qci}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_req   filter_file_name=${CB006274_trf_filter}
    Verify DSCP from pcap   ${pcap_file}

Verify qci bearer establishment with initial context setup request is successful with default qci and dedicated qci
    [Arguments]       ${ded_qci}    ${second_ded_qci}   ${def_qci}    ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${ul_data}
    ...     ${dl_data}    ${sgw_id}   ${plmn}
    [Documentation]     qci67 bearer establishment is initiated during the UE attach as configured in lua file
    log     ${bit_rate}
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${def_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul protocol=udp
    ...     Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${second_ded_qci}
    Set Suite Variable   ${def_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_req_with_multi_bearer   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}
    Verify DSCP from pcap   ${pcap_file}

Detach UE
    [Arguments]     ${prof}     ${prof_id}    ${ue_id}
    Configure UE        ${prof}=${prof_id}:data        command=ue_detach id=${ue_id}

'${action}' CB006274 feature
    Perform Delta Commissioning      ${CB006274_feature_delta_${action}}
    Sleep     30


Verify CB006274 for operator
    [Arguments]      ${operator_id}
    [Documentation]    To chose particular SGW configured for specific operator in the lua file , sgw id is fetched
    ${sgw_id}=     Evaluate     ${operator_id}+1
    'Enable' CB006274 feature
    Fetch the ips    ${operator_id}
#    ${ue_ip}=        Set Variable     41.7.248.1
#    Set Suite variable     ${ue_ip}
    Verify dedicated bearer QCI establishment is successful with default qci      67   9    lte    6op_cus_lte
    ...     2   11   1000   1   1    ${sgw_id}     ${plmn}
#    ${ue_ip}=        Set Variable     41.7.248.2
#    Set Suite variable     ${ue_ip}
    Verify dedicated bearer QCI establishment is successful with default qci      67   69      lte    6op_cus_lte
    ...     4   11   1000   1   1   ${sgw_id}    ${plmn}

#    ${ue_ip}=        Set Variable     41.7.248.3
#    Set Suite variable     ${ue_ip}
    Verify qci bearer establishment with initial context setuprequest with default qci   67  9    lte    6op_cus_lte
    ...     3   11   1000   1   1    ${sgw_id}    ${plmn}
#    ${ue_ip}=        Set Variable     41.7.248.4
#    Set Suite variable     ${ue_ip}
    Verify qci bearer establishment with initial context setuprequest with default qci   67  69    lte    6op_cus_lte
    ...     5   11   1000   1   1    ${sgw_id}     ${plmn}

#    ${ue_ip}=        Set Variable     41.7.248.5
#    Set Suite variable     ${ue_ip}
    Verify dedicated bearer QCI establishment is successful with default qci and dedicated qci  67  69  9  lte    6op_cus_lte
    ...     6   11   1000   1   1     ${sgw_id}    ${plmn}
#    ${ue_ip}=        Set Variable     41.7.248.6
#    Set Suite variable     ${ue_ip}
    Verify qci bearer establishment with initial context setup request is successful with default qci and dedicated qci   67  69  9
    ...     lte    6op_cus_lte   7   11   1000   1   1    ${sgw_id}   ${plmn}
    'Disable' CB006274 feature
    UE with qci67 bearer establishment should fail     lte    6op_cus_lte    9     11      1000    ${sgw_id}     ${plmn}
    QCI67 bearer establishment with initial context setuprequest should fail   lte    6op_cus_lte    10     11     ${sgw_id}    ${plmn}
    FOR    ${i}    IN RANGE   2   8
           Detach UE     lte    6op_cus_lte      ${i}
    END

Randomize UE
    ${UE_ID}=         Evaluate          (random.randrange(101,121))     random
    Set Suite Variable      ${ue_id}        ${UE_ID}

Call verification with operator
    [Arguments]      ${operator_id}
    [Documentation]    To chose particular SGW configured for specific operator in the lua file , sgw id is fetched
    ${sgw_id}=     Evaluate     ${operator_id}+1
    Fetch the ips    ${operator_id}
    Randomize UE
    Verify operator specific GBR and Non GBR QCI call and public safety bearer      lte    6op_cus_lte    ${ue_id}     12      ${sgw_id}     ${plmn}

Verify operator specific GBR and Non GBR QCI call and public safety bearer
    [Arguments]           ${prof}     ${prof_id}   ${ue_id}     ${cell_id}    ${sgw_id}   ${plmn}
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp kbps_dl=10 kbps_ul=10 stats=true
    Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${GBR_QCI}[${${ue_id}-100}] gbr_dl=10
    ...     gbr_ul=10 mbr_dl=10 mbr_ul=10
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${GBR_QCI}[${${ue_id}-100}] dir=dl_and_ul protocol=udp
    ...     kbps_dl=10 kbps_ul=10 stats=true
    Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${Non_GBR_QCI}[${${ue_id}-100}]
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${Non_GBR_QCI}[${${ue_id}-100}] dir=dl_and_ul
    ...     protocol=udp kbps_dl=10 kbps_ul=10 stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}
#    Set Suite Variable   ${GBR_QCI}    ${${GBR_QCI}[${ue_id}]}
#    Set Suite Variable   ${NonGBR_QCI}    ${Non_GBR_QCI}[${ue_id}]
    ${mnc}=     Get Parameter         param_path=LNBTS-1:qciTabOperator
#    Set Suite Variable   ${Non_GBR_dscp}    ${qciTabOperator.${NonGBR_QCI}_dscp}
#    Set Suite Variable   ${GBR_dscp}    ${qci_${GBR_QCI}_dscp}
#    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_req_with_multi_bearer   filter_file_name=${CB006274_trf_filter}
#    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_resp   filter_file_name=${CB006274_trf_filter}
#    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}
    Configure UE        ${prof}=${prof_id}:data        command=ue_detach id=${ue_id}
    Verify DSCP from pcap   ${pcap_file}



Verify DSCP from pcap
    [Arguments]       ${pcap_file}
    ${bearer}=  Set Variable      tshark -n -r ${pcap_file} -Y "s1ap && s1ap.qCI" -T fields -e s1ap.E_RABToBeSetupListCtxtSUReq|wc-l2>/tmp/stderr.txt
    ${Number_of_bearer_in_call}=      Run       ${bearer}
    @{qci_list}=    Create List
    @{arp_list}=    Create List
    ${qci}=     Run     tshark -n -r ${pcap_file} -Y "s1ap && s1ap.qCI" -T fields -e s1ap.qCI 2>/tmp/stderr.txt
    ${result}=      Run Keyword And Return Status   Should Contain   ${qci}  \n
    @{qci_list}=    Run keyword IF      "${result}"!="True"         Split String    ${qci}  ,      ELSE    Split String    ${qci}  \n
    ${arp}=     Run     tshark -n -r ${pcap_file} -Y "s1ap && s1ap.qCI" -T fields -e s1ap.priorityLevel 2>/tmp/stderr.txt
    ${result}=      Run Keyword And Return Status   Should Contain   ${arp}  \n
    @{arp_list}=    Run keyword IF      "${result}"!="True"         Split String    ${arp}  ,      ELSE    Split String    ${arp}  \n
    log    ${qci_list}
    log    ${arp_list}
    ${QCI_ARP_feature_flag}=    Get Parameter       param_path=${ACT_QCI_ARP_flag}
    FOR     ${i}    IN RANGE    0       ${Number_of_bearer_in_call}
        Run keyword If     '${QCI_ARP_feature_flag}'=='True'     Get DSCP value    ${qci_list}[${i}]    ${arp_list}[${i}]
        ...     ELSE  Get DSCP value from QCITAB    ${qci_list}[${i}]
        Analyse pcap            pcap_filename=${pcap_file}        analysis=GTP_UL_Traffic     filter_file_name=${CB008931_Traffic}
    END




Get DSCP value
    [Arguments]     ${QCI}      ${ARP}
    Run keyword If      ${QCI}<100   Get DSCP value from normal QCI  ${QCI}      ${ARP}
    ...     ELSE    Get DSCP value from Operator Specific QCI    ${QCI}      ${ARP}

Get DSCP value from normal QCI
    [Arguments]     ${QCI}      ${ARP}
    ${DSCP_Value}=      Get parameter       param_path=LNBTS-1:qciTab${QCI}
    ${values}=    Get Dictionary Values    ${DSCP_Value}
    log     ${values}
    ${ARP}      Convert To Integer  ${ARP}
    ${list}=    Get Dictionary Values    ${values}[0]
    Log    ${list}
    ${dscp}=    Get from Dictionary    ${list}[0]   dscpProfIdx
    Run keyword If     '${dscp}'=='None'     Get DSCP value from QCITAB     ${QCI}
    ...     ELSE    Get DSCP from DSCPPR    ${QCI}      ${ARP}      ${dscp}


Get DSCP value from Operator Specific QCI
    [Arguments]     ${QCI}      ${ARP}
    ${DSCP_Value}=      Get parameter       param_path=LNBTS-1:qciTabOperator
    ${1}=    Get Length    ${DSCP_Value}
    FOR        ${i}        IN RANGE    0       ${1}
        ${2}=      Get From List    ${DSCP_Value}   ${i}
        ${Inc_qci}=       Get from Dictionary    ${2}       qci
        Exit For Loop IF      "${Inc_qci}"=="${QCI}"
    END
    log     ${2}
    ${ARP}      Convert To Integer  ${ARP}
    ${dscp}=    Get from Dictionary    ${2}   dscpProfIdx
    Run keyword If     '${dscp}'=='None'     Get DSCP value from QCITAB     ${QCI}
    ...     ELSE    Get DSCP from DSCPPR    ${QCI}      ${ARP}      ${dscp}


Get DSCP from DSCPPR
    [Arguments]     ${QCI}      ${ARP}      ${dscp}
    ${dscppr}=      Get parameter       param_path=DSCPPR-${dscp}
    log     ${dscppr}
    ${1}=    Get Dictionary Items    ${dscppr}
    log     ${1}[0]
    log     ${1}[1]
    ${dscppr}=    Get from Dictionary    ${1}[1]       dscpMarking
    ${2}=      Get From List    ${dscppr}   0
    ${dscppr_len}=     Get Length  ${dscppr}
    Run keyword If     ${dscppr_len}==1     Get DSCP value from one DSCPPR      ${2}       ${ARP}      ${QCI}
    ...     ELSE  Get DSCP value from multiple DSCPPR    ${dscppr}       ${ARP}      ${QCI}


Get DSCP value from one DSCPPR
    [Arguments]     ${DSCPPR}      ${ARP}      ${QCI}
    ${start_arp}=       Get from Dictionary    ${DSCPPR}       arpValueStart
    ${stop_arp}=        Get from Dictionary    ${DSCPPR}       arpValueStop
    ${start_arp}     Convert To Integer  ${start_arp}
    ${stop_arp}     Convert To Integer  ${stop_arp}
    ${arp_count}=       Evaluate    ${stop_arp}-${start_arp}+1
    Compare with ARP and get DSCP   ${DSCPPR}    ${arp_count}    ${start_arp}    ${stop_arp}     ${ARP}      ${QCI}
    ${1234}=      Run keyword IF      "${1234}"!="${EMPTY}"        Set Variable    ${1234}      ELSE       Get DSCP value from QCITAB    ${QCI}
    Set Suite variable  ${dscp_value_for_filter}    ${1234}


Get DSCP value from multiple DSCPPR
    [Arguments]     ${Multiple_DSCPPR}      ${ARP}      ${QCI}
    log     ${Multiple_DSCPPR}
    ${length_DSCPPR}=     Get Length  ${Multiple_DSCPPR}
    FOR     ${i}    IN RANGE    ${length_DSCPPR}
        ${start_arp}=       Get from Dictionary    ${Multiple_DSCPPR}[${i}]       arpValueStart
        ${stop_arp}=        Get from Dictionary    ${Multiple_DSCPPR}[${i}]       arpValueStop
        ${start_arp}     Convert To Integer  ${start_arp}
        ${stop_arp}     Convert To Integer  ${stop_arp}
        ${arp_count}=       Evaluate    ${stop_arp}-${start_arp}+1
        Compare with ARP and get DSCP   ${Multiple_DSCPPR}[${i}]    ${arp_count}    ${start_arp}    ${stop_arp}     ${ARP}      ${QCI}
    END
    ${1234}=      Run keyword IF      "${1234}"!="${EMPTY}"            Set Variable    ${1234}     ELSE       Get DSCP value from QCITAB    ${QCI}
    Set Suite variable  ${dscp_value_for_filter}    ${1234}


Compare with ARP and get DSCP
    [Arguments]     ${DSCPPR}   ${arp_count}    ${start_arp}    ${stop_arp}     ${ARP}      ${QCI}
    log     ${stop_arp}
    log     ${QCI}
    @{ARP_list_dscppr}=    Create List
    FOR     ${j}    IN RANGE        ${arp_count}
        Append To List      ${ARP_list_dscppr}      ${start_arp}
        ${start_arp}=       Evaluate    ${start_arp}+1
        log     ${ARP_list_dscppr}
        ${arp_from_dscppr}=     Get From List    ${ARP_list_dscppr}    ${j}
        ${1234}=      Run keyword IF      ${arp_from_dscppr} == ${ARP}         DSCP_Fetch    ${DSCPPR}      ELSE    Set Variable    ${EMPTY}
        log     ${1234}
        Exit For Loop IF      "${1234}"!="${EMPTY}"
        Set Suite variable  ${1234}    ${1234}
    END
    Set Suite variable  ${1234}    ${1234}
    [Return]        ${1234}


DSCP_Fetch
    [Arguments]     ${DSCPPR}
    ${dscp}=    Get from Dictionary    ${dscppr}   dscpValue
    [Return]        ${dscp}
#a    Set Suite variable  ${dscp}    ${dscp}


Get DSCP value from QCITAB
    [Arguments]     ${QCI}
    ${DSCP_Value}=      Get parameter       param_path=MRBTS-1/LNBTS-1:qciTab${QCI}:dscp
    log     ${DSCP_Value}
    Set Suite variable  ${dscp_value_for_filter}    ${DSCP_Value}
    [Return]        ${DSCP_Value}


Keywords to run at end
       Traffic Capture Stop
       Call Teardown   lte=6op_cus_lte:data
       Run      sudo killall egate edaemon
       FOR        ${i}        IN RANGE    0       13
            Run     sudo ip link delete eth3.${vlan_id}
            ${vlan_id}=     Evaluate    ${vlan_id}+1
       END