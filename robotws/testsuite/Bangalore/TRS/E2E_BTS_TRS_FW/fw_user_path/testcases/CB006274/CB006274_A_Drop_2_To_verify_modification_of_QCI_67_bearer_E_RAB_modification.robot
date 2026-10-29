***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate CB006274 Use case"
    ...     [Date]                  ""
    ...     [SCF]                   "plain_scf.xml"
    ...     [Author]                "Nandini Periyaswamy"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB006274"
    ...     [Validation_status]     "Validated"
    ...     [Validated_TestLine]    "ASIL_TL065"

Force Tags       CLOUD_R4BANO_CUS  CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN   QCP_RAN_VRF  CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


*** Test Cases ***
[1][1.0] CB006274_A_B1_Drop_2_To_verify_modification_of_QCI_67_bearer_E_RAB_modification


   Precondition
   Fetch the ips
   Bring setup on-air

##QoS parameters modification
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        lte=Virtual_alias_epc:data      command=ue_attach id=1 cell=11
    Configure UE        lte=Virtual_alias_epc:data      command=bearer_add ue=1 qci=67 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100
    Configure UE        lte=Virtual_alias_epc:data      command=trf_data_start ue=1 qci=67 dir=ul protocol=udp kbps=100     stats=true
    Execute cmd on egate      lte=Virtual_alias_epc:data    cmd=bearer_mod ue=1 id=10 mbr_dl=200 mbr_ul=200 gbr_dl=200 gbr_ul=200    timeout=60
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=modify_request    filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=modify_response    filter_file_name=${CB006274_trf_filter}
    Configure UE        lte=Virtual_alias_epc:data      command=ue_detach id=1

##QCI-67 to QC-2 modification
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        lte=Virtual_alias_epc:data      command=ue_attach id=1 cell=11
    Configure UE        lte=Virtual_alias_epc:data      command=bearer_add ue=1 qci=67 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100
    Configure UE        lte=Virtual_alias_epc:data      command=trf_data_start ue=1 qci=67 dir=ul protocol=udp kbps=100     stats=true
    Execute cmd on egate      lte=Virtual_alias_epc:data    cmd=bearer_mod ue=1 id=10 qci=2    timeout=60
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop

    ${qci_2_dscp}=      Get Parameter         param_path=${qci2_dscp_moc}
    Set Suite Variable    ${dscp}    ${qci_2_dscp}

    Retrieve UE ip   lte    Virtual_alias_epc    1
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=modify_request    filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=modify_response    filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification    filter_file_name=${CB006274_trf_filter}
    Configure UE        lte=Virtual_alias_epc:data      command=ue_detach id=1

##QCI-67 to QC-4 modification
    Perform Recommissioning     type=delta     delta_file=${QCI_67_4_same_parameters}     timeout=300
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        lte=Virtual_alias_epc:data      command=ue_attach id=1 cell=11
    Configure UE        lte=Virtual_alias_epc:data      command=bearer_add ue=1 qci=67 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100
    Configure UE        lte=Virtual_alias_epc:data      command=trf_data_start ue=1 qci=67 dir=ul protocol=udp kbps=100     stats=true
    sleep    5
    ${pcap_file}=       Traffic Capture Stop

    ${qci_67_dscp}=      Get Parameter         param_path=${qci67_dscp_moc}
    Set Suite Variable    ${dscp}    ${qci_67_dscp}

    Retrieve UE ip   lte    Virtual_alias_epc    1
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification    filter_file_name=${CB006274_trf_filter}

    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      lte=Virtual_alias_epc:data    cmd=bearer_mod ue=1 id=10 qci=4    timeout=60
    sleep   5
    ${pcap_file}=       Traffic Capture Stop

    ${qci_4_dscp}=      Get Parameter         param_path=${qci4_dscp_moc}
    Set Suite Variable    ${dscp}    ${qci_4_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=modify_request    filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=modify_response    filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification    filter_file_name=${CB006274_trf_filter}
    Configure UE        lte=Virtual_alias_epc:data      command=ue_detach id=1

#    [Documentation]   change dscp of 67 to different value and verify dscp
    Change dscp value of qci67
    Verify changed dscp is reflecting

     Reset Bts      verify_bts=True    req_rat=all   Should_be_onair=True    wait_for=600
     Sleep   60
     Verify changed dscp is reflecting
    [Teardown]    Keywords to run at end

***Keywords***
Verify changed dscp is reflecting
    Traffic Capture Start   capture_device=vm_eth3_interface
    Configure UE        lte=Virtual_alias_epc:data      command=ue_attach id=1 cell=11
    Configure UE        lte=Virtual_alias_epc:data      command=bearer_add ue=1 qci=67 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100
    Configure UE        lte=Virtual_alias_epc:data      command=trf_data_start ue=1 qci=67 dir=ul protocol=udp kbps=100     stats=true
    sleep    5
    ${pcap_file}=       Traffic Capture Stop

    Retrieve UE ip   lte    Virtual_alias_epc    1
    Set Suite Variable    ${dscp}    ${changed_qci67_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification    filter_file_name=${CB006274_trf_filter}
    Configure UE        lte=Virtual_alias_epc:data      command=ue_detach id=1

Change dscp value of qci67
    ${qci_67_dscp}=      Get Parameter         param_path=${qci67_dscp_moc}
    FOR   ${i}   IN RANGE   10
        ${changed_qci67_dscp}=         Evaluate    random.choice(range(0, 64))  random
        Set Suite Variable      ${changed_qci67_dscp}      ${changed_qci67_dscp}
        Exit For Loop if     ${changed_qci67_dscp}!=${qci_67_dscp}
    END

    Copy File     ${delta_dir}/${qci67_dscp_change}    ${delta_dir}/${qci67_dscp_change_copy}
    Run     sudo sed -i "s/{{67_dscp}}/${changed_qci67_dscp}/g" ${delta_dir}/${qci67_dscp_change}
    Perform Recommissioning     type=delta     delta_file=${qci67_dscp_change}     timeout=300
    Sleep   5
    [Teardown]    Copy File     ${delta_dir}/${qci67_dscp_change_copy}    ${delta_dir}/${qci67_dscp_change}


Retrieve UE ip
    [Arguments]    ${prof}    ${prof_id}   ${ue_id}
    ${output}=          Execute cmd on egate      ${prof}=${prof_id}:data    cmd=ue_disp id=${ue_id}    pass_regexp=[active]   timeout=60
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

Precondition

     Run   sudo ip link add link eth3 name eth3.${vlan_ids}[1] type vlan id ${vlan_ids}[1]
     Run   sudo ip addr add 10.0.2.209/30 brd 10.0.2.211 dev eth3.${vlan_ids}[1]
     Run   sudo ip link set dev eth3.${vlan_ids}[1] up
     Run   sudo ip r a 10.0.4.210/32 via 10.0.2.210
     Run   sudo ip r a 10.0.3.210/32 via 10.0.2.210

    Copy File     ${delta_dir}/${delta_6274_config}    ${delta_dir}/${delta_6274_config_copy}
    Run     sudo sed -i "s/{{vlanid_1}}/${vlan_ids}[1]/g" ${delta_dir}/${delta_6274_config}
    Perform Recommissioning     type=delta     delta_file=${delta_6274_config}     timeout=300
    Sleep   60
    [Teardown]    Copy File     ${delta_dir}/${delta_6274_config_copy}    ${delta_dir}/${delta_6274_config}

Bring setup on-air
    Call Setup      lte=Virtual_alias_epc:data    parallel=${False}    verify_attach=${False}    attach=
    Sleep    30
    Verify Bts Status       req_rat=lte

Fetch the ips
     ${cplane_ip}=      Get Parameter         param_path=TRSNW-0:${cplane_ip_moc}
     Set Suite Variable    ${cplane_ip}
     ${uplane_ip}=      Get Parameter         param_path=TRSNW-0:${uplane_ip_moc}
     Set Suite Variable    ${uplane_ip}
     ${mme_ip}=      Get Parameter         param_path=LNMME-0:${mme_ip_moc}
     Set Suite Variable    ${mme_ip}
     ${qci_67_dscp}=      Get Parameter         param_path=${qci67_dscp_moc}
     Set Suite Variable    ${qci_67_dscp}


Keywords to run at end
    Run Keyword and ignore error       Traffic Capture Stop
    Call Teardown   lte=Virtual_alias_epc:data
    Run     sudo killall edaemon egate