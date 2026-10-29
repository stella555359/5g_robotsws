***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate CB006274 Use case"
    ...     [Date]                  ""
    ...     [SCF]                   "plain_scf.xml"
    ...     [Author]                "Abhishek Patil"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB006274"
    ...     [Validation_status]     "draft"
    ...     [Validated_TestLine]    "ASOF_10.58.143.83"

Force Tags       CLOUD_R4BANO_CUS  CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF  CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


*** Test Cases ***
[1][2.0] CB006274_A_B1_Drop_3_To_verify_TAC_Preemption_with_QCI_67_bearer


    Pre-condition
    Bring setup on-air

    Check Preemption with IPv4 Operator     0
    Perform Recommissioning     type=param     rat=lte        param_path=${Dynamic_firewall_flag}     operation=update    value=true
    ...     skip_parameter_relation_errors=${False}    timeout=60
    Sleep   30
    Bring up other 3 operator with IPv6 config
    ${operators}=         Evaluate    random.choice(range(3, 5))    random
    Set Suite Variable      ${operators}        ${operators}
    Check Preemption with IPv6 Operator     ${operators}
    ${operators_IPv4}=         Evaluate    random.choice(range(1, 2))    random
    Set Suite Variable      ${operators}        ${operators}
    Check Preemption with IPv4 Operator     ${operators_IPv4}
    [Teardown]    Keywords to run at end



*** Keywords ***
Check Preemption with IPv4 Operator
    [Arguments]     ${op}
    Fetch the ips  ${op}
    Copy File     ${delta_dir}/${3op_TAC_Parameters}    ${delta_dir}/${3op_TAC_Parameters_backup)
    Run     sudo sed -i "s/{LTAC_Value}/${Low_TAC_Value}/g" ${delta_dir}/${3op_TAC_Parameters}
    Run     sudo sed -i "s/{Preemption_Value}/${Low_Preemption_Value}/g" ${delta_dir}/${3op_TAC_Parameters}
    Perform Recommissioning     type=delta     delta_file=${3op_TAC_Parameters}     timeout=300
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status       req_rat=all
    Copy File   ${counter_path}/${CB006274_counter_file}     ${counter_path}/${CB006274_counter_file_bkp}
    Run     sudo sed -i "s/{operator}/{SGW}/g" ${counter_path}/${CB006274_counter_file}
    Pm Counters Start       analysis=Max_preemption_counters_Other_Op      counter_analysis_file=${CB006274_counter_file}     pm_interval=15
##Pre_emption with low values
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_1
    Attach Multiple UEs for low TAC threshold       ${plmn}
#Check Preemption should not happen due to low pre_emption value
    Run Keyword and ignore error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=112
    ...     cell=12 selected_plmn=${plmn}
    Sleep   5
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_1
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=Attach_fail   filter_file_name=${CB006274_trf_filter}

#Check Preemption should happen with correct pre_emption value
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_1_2
    Perform Recommissioning     type=param     rat=lte        param_path=${Max_num_preemption}     operation=update    value=5
    ...     skip_parameter_relation_errors=${False}    timeout=60
    Sleep   5
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=112 cell=12 selected_plmn=${plmn}
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_1_2
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=Attach_pass   filter_file_name=${CB006274_trf_filter}
    Sleep   111
    Run Keyword And Ignore Error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach id=1-2
    Copy File     ${delta_dir}/${3op_TAC_Parameters_backup}    ${delta_dir}/${3op_TAC_Parameters}

##Pre_emption with high values
    Copy File     ${delta_dir}/${3op_TAC_Parameters}    ${delta_dir}/${3op_TAC_Parameters_backup}
    Run     sudo sed -i "s/{LTAC_Value}/${High_TAC_Value}/g" ${delta_dir}/${3op_TAC_Parameters}
    Run     sudo sed -i "s/{Preemption_Value}/${High_Preemption_Value}/g" ${delta_dir}/${3op_TAC_Parameters}
    Sleep   5
    Perform Recommissioning     type=delta     delta_file=${3op_TAC_Parameters}     timeout=300
    Sleep   30
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_2
    Attach Multiple UEs for high TAC threshold      ${plmn}
    Check preemption should happen with max pre_emption value
    Verify Pm counters          analysis=Max_preemption_counters_Other_Op      counter_analysis_file=${CB006274_counter_file}      pm_interval=15
    Copy File     ${delta_dir}/${3op_TAC_Parameters_backup}    ${delta_dir}/${3op_TAC_Parameters}
    Run Keyword And Ignore Error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach id=1-120

Check Preemption with IPv6 Operator
    [Arguments]     ${op}
    Fetch the ips  ${op}
    Copy File     ${delta_dir}/${6op_TAC_Parameters}    ${delta_dir}/${6op_TAC_Parameters_backup}
    Run     sudo sed -i "s/{LTAC_Value}/${Low_TAC_Value}/g" ${delta_dir}/${6op_TAC_Parameters}
    Run     sudo sed -i "s/{Preemption_Value}/${Low_Preemption_Value}/g" ${delta_dir}/${6op_TAC_Parameters}
    Perform Recommissioning     type=delta     delta_file=${6op_TAC_Parameters}     timeout=300
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status       req_rat=all
    Copy File   ${counter_path}/${CB006274_counter_file}     ${counter_path}/${CB006274_counter_file_bkp}
    Run     sudo sed -i "s/{operator}/{SGW}/g" ${counter_path}/${CB006274_counter_file}
    Pm Counters Start       analysis=Max_preemption_counters_Other_Op      counter_analysis_file=${CB006274_counter_file}     pm_interval=15
##Pre_emption with low values
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_1
    Attach Multiple UEs for low TAC threshold       ${plmn}
#Check Preemption should not happen due to low pre_emption value
    Run Keyword and ignore error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=112 cell=12
    ...     selected_plmn=${plmn}
    Sleep   5
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_1
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=Attach_fail   filter_file_name=${CB006274_trf_filter}

#Check Preemption should happen with correct pre_emption value
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_1_2
    Perform Recommissioning     type=param     rat=lte        param_path=${Max_num_preemption}     operation=update    value=5
    ...     skip_parameter_relation_errors=${False}    timeout=60
    Sleep   5
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=112 cell=12 selected_plmn=${plmn}
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_1_2
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=Attach_pass   filter_file_name=${CB006274_trf_filter}
    Sleep   111
    Run Keyword And Ignore Error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach id=1-2
    Copy File     ${delta_dir}/${6op_TAC_Parameters_backup}    ${delta_dir}/${6op_TAC_Parameters}

##Pre_emption with high values
    Copy File     ${delta_dir}/${6op_TAC_Parameters}    ${delta_dir}/${6op_TAC_Parameters_backup}
    Run     sudo sed -i "s/{LTAC_Value}/${High_TAC_Value}/g" ${delta_dir}/${6op_TAC_Parameters}
    Run     sudo sed -i "s/{Preemption_Value}/${High_Preemption_Value}/g" ${delta_dir}/${6op_TAC_Parameters)
    Perform Recommissioning     type=delta     delta_file=${6op_TAC_Parameters}     timeout=300
    Sleep   30
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_2
    Attach Multiple UEs for high TAC threshold      ${plmn}
    Check preemption should happen with max pre_emption value
    Verify Pm counters          analysis=Max_preemption_counters_Other_Op      counter_analysis_file=${CB006274_counter_file}      pm_interval=15
    Copy File     ${delta_dir}/${6op_TAC_Parameters_backup}    ${delta_dir}/${6op_TAC_Parameters}
    Run Keyword And Ignore Error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach id=1-120



Keywords to run at end
#    Perform Commissioning       scf_file=/tmp/192.168.255.129_scf.xml       verify_bts_status=False
#a    Run     sudo killall edaemon egate
    Run Keyword And Ignore Error    Copy File   ${counter_path}/${CB006274_counter_file_bkp}     ${counter_path}/${CB006274_counter_file}
    Run Keyword And Ignore Error    Copy File     ${delta_dir}/${3op_TAC_Parameters_backup}    ${delta_dir}/${3op_TAC_Parameters}
    Run Keyword And Ignore Error    Copy File     ${delta_dir}/${6op_TAC_Parameters_backup}    ${delta_dir}/${6op_TAC_Parameters}
#a    Run Keyword And Ignore Error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach all       timeout=60

Attach Multiple UEs for low TAC threshold
    [Arguments]     ${plmn}
    ${SGW}=      Evaluate            ${op}+1
    Set Suite Variable    ${SGW}    ${SGW}
    Execute cmd on egate      lte=Max_Preemption_CUS_IPv4_IPv6:data    cmd=ue_mme_param id=1-120 sgw_id=${SGW}   timeout=60
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=1-2 cell=12 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=bearer_add ue=1-2 qci=2 gbr_dl=100 gbr_ul=100 mbr_dl=100 mbr_ul=100
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=1-2 qci=2 dir=ul kbps=1000 protocol=udp
    Sleep   5
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=bearer_add ue=1-2 qci=3 gbr_dl=100 gbr_ul=100 mbr_dl=100 mbr_ul=100
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=bearer_add ue=1-2 qci=4 gbr_dl=100 gbr_ul=100 mbr_dl=100 mbr_ul=100
    Sleep   5
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=1-2 qci=3 dir=ul kbps=1000 protocol=udp
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=1-2 qci=4 dir=ul kbps=1000 protocol=udp
    Sleep   5


Attach Multiple UEs for high TAC threshold
    [Arguments]     ${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=1-15 cell=11 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=16-30 cell=12 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=31-47 cell=13 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=48-60 cell=11 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=61-80 cell=12 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=81-100 cell=13 selected_plmn=${plmn}
    Sleep   5
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=bearer_add ue=1-100 qci=2 gbr_dl=10 gbr_ul=10 mbr_dl=10 mbr_ul=10
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=1-100 qci=2 dir=ul kbps=50 protocol=udp
    Sleep   10
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=bearer_add ue=1-100 qci=3 gbr_dl=10 gbr_ul=10 mbr_dl=10 mbr_ul=10
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=1-100 qci=3 dir=ul kbps=50 protocol=udp
    Sleep   10
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=bearer_add ue=1-100 qci=4 gbr_dl=10 gbr_ul=10 mbr_dl=10 mbr_ul=10
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=1-100 qci=4 dir=ul kbps=50 protocol=udp
    Sleep   30

Check preemption should happen with max pre_emption value
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_2
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=113 cell=12 selected_plmn=${plmn}
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=trf_data_start ue=113 qci=67 dir=ul kbps=1000 protocol=udp
    Sleep   5
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_2
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach id=113
    Set Suite Variable    ${Total_no_of_released_bearer}    0
    FOR     ${i}        IN RANGE    1       4
        Set Suite Variable   ${No_of_bearer}        ${i}
        ${output}   ${Number_of_Bearer_released}=      Run Keyword and ignore error    Analyse_pcap    pcap_filename=${pcap_file}
        ...     analysis=Max_preemption   filter_file_name=${CB006274_trf_filter}
        Continue For Loop IF    "${output}"=="FAIL"
        ${Total_no_of_released_bearer}=     Evaluate    ${Total_no_of_released_bearer} + ${${Number_of_Bearer_released} * ${i}}
    END
    Should be True  ${Total_no_of_released_bearer}==128





***Keywords***
Randomize 2 additional operators
    ${operators}=         Evaluate    random.sample(range(1, 6), 2)    random
    Set Suite Variable      ${operators}        ${operators}

    Verify CB006274 for operator      ${operators}[0]
    Verify CB006274 for operator      ${operators}[1]


Fetch the ips
     [Arguments]     ${op}
     Set Suite variable     ${op}
     ${cplane_ip}=      Get Parameter         param_path=TRSNW-${op}:${cplane_ip_moc}
     ${res}=        Run Keyword and return status    Should Contain	    ${cplane_ip}	10.0.
     ${cplane_ip}=      Run keyword IF      '${res}'=='True'         Sleep    1      ELSE    Get Parameter
     ...        param_path=TRSNW-${op}:${cplane_ipv6_moc}
     Set Suite Variable    ${cplane_ip}
     ${uplane_ip}=      Get Parameter         param_path=TRSNW-${op}:${uplane_ip_moc}
     ${res}=        Run Keyword and return status    Should Contain     ${uplane_ip}    10.0.
     ${uplane_ip}=      Run keyword IF      '${res}'=='True'         Sleep    1      ELSE    Get Parameter
     ...        param_path=TRSNW-${op}:${uplane_ipv6_moc}
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
     ${SGW}=      Evaluate            ${op}+1
     Set Suite Variable    ${SGW}    ${SGW}


Pre-condition
     ${interface_adddress_last_octet}=        Set Variable        1
     ${interface_adddress_last_octet_IPv6}=      Set Variable        0X06
     ${sim_ip}=            Set Variable     20

    ${vlan_id}=    Set Variable     ${vlan_ids}[1]
    Copy File     ${delta_dir}/${delta_3op_config_IPv4}    ${delta_dir}/${delta_3op_config_copy_IPv4}
    FOR        ${i}        IN RANGE    0       13
           ${nw_ipv4}=         Evaluate            ${interface_adddress_last_octet}-1
           ${nw_ipv6}=         Evaluate            hex(${interface_adddress_last_octet_IPv6}-2)
           ${nw_ipv6}=         Evaluate            hex(${nw_ipv6}).lstrip("0x")
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
           Bring IPv4 VLAN VM Interfaces       ${vlan_id}            10.0.3.${interface_adddress_last_octet}
           ...      10.0.3.${broadcast_adddress_last_octet}     30
           Run         sudo ifconfig eth3.${vlan_id} inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
           ${ENB_interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+1
           ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
           ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
            Run		sudo sed -i "s/{{vlan_id${i}}}/${vlan_id}/g" ${delta_dir}/${delta_3op_config_IPv4}
            ${vlan_id}=      Evaluate      ${vlan_id}+1
    END

     FOR    ${i}    IN RANGE        0       13
           Run         sudo ip a a 10.0.1.${sim_ip}/24 dev eth3.${vlan_ids}[0]
           Run         sudo ip a a fc00::${sim_ip}/116 dev eth3.${vlan_ids}[0]
           ${sim_ip}=    Evaluate   ${sim_ip}+1
     END

    Perform Recommissioning     type=delta     delta_file=${delta_3op_config_IPv4}     timeout=300
    Sleep     60

    [Teardown]           Copy File     ${delta_dir}/${delta_3op_config_copy_IPv4}    ${delta_dir}/${delta_3op_config_IPv4}


Bring setup on-air
    Call Setup  lte=Max_Preemption_CUS_IPv4_IPv6:data    parallel=${False}    verify_attach=${False}    attach=${False}
    Sleep    60
    Verify Bts Status       req_rat=all
    FOR    ${i}    IN RANGE        0       3
           ${link_status}=   Get Parameter       param_path=${mme_moc}-${i}:${s1_link}
           Should Be True    '${link_status}'=='available'
    END

Bring IPv4 VLAN VM Interfaces
    [Arguments]             ${Vlan_ID}          ${interface_address}        ${broadcast_ip_address}         ${sunbet_mask}
    Run     sudo ip link add link eth3 name eth3.${Vlan_ID} type vlan id ${Vlan_ID}
    Run     sudo ip addr add ${interface_address}/${sunbet_mask} brd ${broadcast_ip_address} dev eth3.${Vlan_ID}
    Run     sudo ip link set dev eth3.${Vlan_ID} up

Bring up other 3 operator with IPv6 config
#a    Copy File     ${delta_dir}/${delta_3op_config_IPv6}    ${delta_dir}/${delta_3op_config_copy_IPv6}
    Perform Recommissioning     type=delta     delta_file=${delta_3op_config_IPv6}     timeout=300
    Sleep     120
    Wait Until Keyword Succeeds  5 min     1 min    Verify Bts Status       req_rat=all
    FOR    ${i}    IN RANGE        0       6
           ${link_status}=   Get Parameter       param_path=${mme_moc}-${i}:${s1_link}
           Should Be True    '${link_status}'=='available'
    END



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
    ...     qci67 beaerer is established with initial setup context req , ue attach will be successful but qci67 establisment fails
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
    Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=67 gbr_ul=${bit_rate} gbr_dl=${bit_rate} mbr_ul=${bit_rate}
    ...     mbr_dl=${bit_rate}
    Sleep    5

Verify dedicated bearer QCI establishment is successful with default qci
    [Arguments]        ${ded_qci}  ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${ul_data}     ${dl_data}   ${sgw_id}   ${plmn}
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${ded_qci} gbr_ul=${bit_rate} gbr_dl=${bit_rate}
    ...     mbr_ul=${bit_rate} mbr_dl=${bit_rate}
    Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul
    ...     protocol=udp Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id)
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_req   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}

#    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}

Retrieve UE ip
    [Arguments]    ${prof}    ${prof_id}   ${ue_id}
    ${output}=          Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_disp id=${ue_id}    pass_regexp=ip [active]   timeout=60
    Log To Console     ${output}
    @{lines}=        Split to lines   ${output}
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
#	[Arguments]       ${ded_qci}   ${def_qci}    ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${bit_rate}    ${ul_data}     ${dl_data}
#    ...        ${sgw_id}   ${plmn}
    [Arguments]       ${ded_qci}   ${def_qci}    ${prof}     ${prof_id}   ${ue_id}     ${cell_id}       ${sgw_id}   ${plmn}
	[Documentation]     qci67 bearer establishment is initiated during the UE attach as configured in lua file
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
	Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci}
    ...     dir=dl_and_ul protocol=udp Mbps_dl=${dl_data Mbps_ul=${ul_data} stats=true
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Retrieve UE ip     ${prof}    ${prof_id}    ${ue_id}
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${def_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_req_with_bearer   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=init_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}

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
	Configure UE        ${prof}=${prof_id}:data        command=bearer_add ue=${ue_id} qci=${ded_qci} gbr_ul=${bit_rate}
    ...     gbr_dl=${bit_rate} mbr_ul=${bit_rate} mbr_dl=${bit_rate}
	Configure UE        ${prof}=${prof_id}:data        command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul
    ...     protocol=udp Mbps_dl=${dl_data} Mbps_ul=${ul_data} stats=true
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


Verify qci bearer establishment with initial context setup request is successful with default qci and dedicated qci
    [Arguments]       ${ded_qci}    ${second_ded_qci}   ${def_qci}    ${prof}     ${prof_id}   ${ue_id}     ${cell_id}   ${ul_data}
    ...     ${dl_data}    ${sgw_id}   ${plmn}
    [Documentation]     qci67 bearer establishment is initiated during the UE attach as configured in lua file
    Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        ${prof}=${prof_id}:data        command=ue_param id=${ue_id} release=15 category=12 supported_bands=3:false
    ...     ca_supported_bands=3:a:a category_dl=17 category_ul=14 ul_64QAM_supported=on dl_256QAM_supported=on
    Configure UE        ${prof}=${prof_id}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
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
    Fetch the ips    ${operator_id}
    Pm Counters Start       analysis=Max_preemption_counters      counter_analysis_file=${CB006274_counter_file}     pm_interval=15
##Pre_emption with low values
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_1
    Attach Multiple UEs for low TAC threshold
#Check Preemption should not happen due to low pre_emption value
    Run Keyword and ignore error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=111 cell=12
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_1
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=Attach_fail   filter_file_name=${CB006274_trf_filter}

#Check Preemption should happen with correct pre_emption value
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_1_2
    Perform Recommissioning     type=param     rat=lte        param_path=${Max_num_preemption}     operation=update    value=5
    ...     skip_parameter_relation_errors=${False}    timeout=60
    Sleep   5
    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_attach id=111 cell=12
    ${pcap_file}=       Traffic Capture Stop    alias=Scenario_1_2
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=Attach_pass   filter_file_name=${CB006274_trf_filter}
#    Sleep   111
    Run Keyword And Ignore Error    Configure UE    lte=Max_Preemption_CUS_IPv4_IPv6:data        command=ue_detach id=1-2

##Pre_emption with high values
    Perform Recommissioning     type=delta     delta_file=${High_TAC_Parameters}     timeout=300
    Sleep   30
#a    Traffic Capture Start   capture_device=vm_eth3_interface    alias=Scenario_2
    Attach Multiple UEs for high TAC threshold
    Check preemption should happen with max pre_emption value
    Verify Pm counters          analysis=Max_preemption_counters      counter_analysis_file=${CB006274_counter_file}      pm_interval=15
