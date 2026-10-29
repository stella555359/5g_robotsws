*** Settings ***
Documentation
    ...     [Procedure]             "TRS_CB008233_CA_Verify_Dynamic_Path_Supervision_of_GTP-U_path_supervision_for_bulk_released_UEs_ASIL"
    ...     [Date]                  "12-05-2024"
    ...     [Author]                "Megha Patil"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "RANSHARING"
    ...     [Feature_ID]            "CB008233"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL00"


Variables        ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops



***Test cases***
[1]TRS_CB008233_CA_Verify_Dynamic_Path_Supervision_of_GTP-U_path_supervision_for_bulk_released_UEs_ASIL
    [Documentation]     This test case is to verify 6 operator calls with common enb configured  out side for shared S1U ips configured for 5g
    Preconditions
    Perform Commissioning       scf_file=${Basic_scf}     verify_bts_status=False     timeout=400     alias=default
    Sleep   30
    Verify RMOD is up
    Perform Call Setup
    Get IP Address
    Trigger Calls and verify GTP
    Start the counters analysis
    Stop traffic and detach UE

***keywords***
Preconditions
    Run    sudo ip link add link eth3 name eth3.2020 type vlan id 2020
    Run    sudo ip addr add 10.0.1.1/24 dev eth3.2020
    Run    sudo ip link set dev eth3.2020 up
    Run     ${ip_add}

Verify RMOD is up
    BuiltIn.Wait Until Keyword Succeeds    20 min    30 sec    RMOD is Enabled

RMOD is Enabled
    @{RMOD_list} =    Query Admin Infomodel    query=get list //RMOD_R-*  timeout=300
    @{rmod_ids}=    Create List
    FOR    ${rmod}    IN    @{RMOD_list}
        ${dist_name}=    Get From Dictionary    ${rmod}    dist_name
        ${rmod_id}=    Fetch From Right    ${dist_name}    /
        ${id_number}=    Split String From Right    ${rmod_id}    -    1
        Append To List    ${rmod_ids}    ${id_number}[1]
    END
    FOR     ${rmodId}   IN   @{rmod_ids}
        ${rmodInfo}=      Query Admin Infomodel    query=get object //RMOD_R-${rmodId}
        ${op_status}=       Get From Dictionary     ${rmodInfo}      operationalState
        Should Be Equal    ${op_status}     enabled
    END

Stop traffic and detach UE
   [Documentation]        This test case keyword is to stop the Calls
   FOR  ${ue_id}   IN RANGE    1   7
   Configure UE    5g=device_10:data        command=trf_data_stop        ue=${ue_id}        dir=dl
   BuiltIn.Sleep     3
   Configure UE    5g=device_10:data        command=trf_data_stop        ue=${ue_id}        dir=ul
   BuiltIn.Sleep     3
   Configure UE    5g=device_10:data        command=ue_deregister        id=${ue_id}        ue_deregister_type=switch_off
   BuiltIn.Sleep     3
    END

Get IP Address
    Get AMF IP Address
    Get NG-U IP Address

Get AMF IP Address
    FOR    ${rmod}    IN    1   7
        ${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}
        ${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddress
        Set Suite Variable      ${amf_ip}       ${amf_ip}
    END

Get NG-U IP Address
    [Arguments]          ${index}=1
    ${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
    ${nguplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngUplane
    FOR   ${operator}   IN RANGE   0   ${index}
        ${nguplane_add}=   Get from list       ${nguplane_list}     ${operator}
        ${nguplane_moc}=    Get From Dictionary     ${nguplane_add}       ipV4AddressDN1
        ${nguplane_ipif}=   Query Admin Infomodel     query=get object ${nguplane_moc}
        ${nguplane_ip}=    Get From Dictionary      ${nguplane_ipif}      localIpAddr
        Set Suite Variable      ${nguplane_ip}       ${nguplane_ip}
    END


Perform Call Setup
    [Documentation]        This test case keyword is to make the setup on On-Air and trigger the calls
    Call Setup    5g=device_10:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=900
    Sleep   60
    Verify Bts Status       should_be_onair=${True}      req_rat=nr

Bring UP X2 Link
    FOR    ${enb_id}   IN RANGE    1   12  2
       Configure UE    5g=device_10:data     command=enb_x2_link_up  enb=${enb_id}  target=2
       BuiltIn.Sleep   1
    END

Trigger Calls and verify GTP
    Perform SA UPlane calls



Perform SA UPlane calls
    FOR  ${ue_id}   IN RANGE    1   7
    Traffic capture start       capture_device=vm_eth3_interface
        Configure UE    5g=device_10:data   command=set_pdu_param      ue=${ue_id}     pdu=1   trf_type=internal
        BuiltIn.Sleep   2
        Configure UE    5g=device_10:data   command=ue_register    id=${ue_id}    profile=1
        BuiltIn.Sleep   2
        Configure UE    5g=device_10:data   command=ue_pdu_session_setup       pdu=1   gw=1    ue=${ue_id}     nwslice=${ue_id}
        BuiltIn.Sleep   2
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable      ${pcap_file}         ${pcap_file}
   Analyse Pcap    pcap_filename=${pcap_file}    analysis=CUSTOMER_GTP    filter_file_name=traffic_filters.json
    END

Perform NSA UPlane calls
    FOR     ${ue}   IN RANGE    1   7
    Configure UE       5g=device_10:data  command=ue_mme_param    id=${ue}    sgw_id=1
    BuiltIn.Sleep  5
    Configure UE       5g=device_10:data  command=ue_attach   id=${ue}
    BuiltIn.Sleep  15
    Configure UE       5g=device_10:data  command=enb_ue_dc_start    ue=${ue}    target_gnb=2   target_cells=1   bearer=2   type=split_scg
    BuiltIn.Sleep  10
    Configure UE       5g=device_10:data  command=trf_data_start   ue=${ue}   id=2   dir=ul   trf_id=1  kbps=2000
    BuiltIn.Sleep  10
    Configure UE       5g=device_10:data  command=trf_data_start   ue=${ue}   id=2   dir=dl   trf_id=1  kbps=2000
    BuiltIn.Sleep  10
    END



Verify SA calls
    [Arguments]      ${No_of_Operators}=2
    FOR ${Operator_index}       IN RANGE    0       ${No_of_Operators}
        @{ngUplane_DN_List}=    Get Parameter   param_path=NRBTS-1:ngUplane
        ${Primary_Uplane_IPv6_IP}   ${Secondary_Uplane_IPv6_IP}=    Get Dual Uplane IPv6 IP     ${ngUplane_DN_List}     ${Operator_index}
        ${AMF_v4_IP}=   Set Variable If     ${Operator_index}==0    ${Primary_IPv4_AMF}     ${Secondary_IPv4_AMF}
        ${AMF_v6_IP}=   Set Variable If     ${Operator_index}==0    ${Primary_IPv6_AMF}     ${Secondary_IPv6_AMF}
        ${Uplane_IP}=   Set Variable    ${Primary_Uplane_IPv6_IP}
        BuiltIn .Sleep   60
#       Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_SA_Slice
        Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_SA_data_dl
        Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_SA_data_ul
        ${Uplane_IP}=   Set Variable    ${Secondary_Uplane_IPv6_IP}
#       Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_SA_Slice
        Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_SA_data_dl
        Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_SA_data_ul
    END


Verify NSA calls IPv4
    [Arguments]      ${No_of_Operators}=2
    FOR    ${Operator_index}       IN RANGE    0       ${No_of_Operators}
       ${s1Uplane_DN_List}=    Get Parameter   param_path=NRNWSLICE_NSA-${Operator_index+1}:s1Uplane:ipV4AddressDN1:localIpAddr
        ${Uplane_IP}=   Set Variable    ${s1Uplane_DN_List}
       Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_NSA_data_dl_simulated
       Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_NSA_data_ul_simulated
       ${s1Uplane_DN_List}=    Get Parameter   param_path=NRNWSLICE_NSA-${Operator_index+1}:s1Uplane:ipV4AddressDN2:localIpAddr
        ${Uplane_IP}=   Set Variable    ${s1Uplane_DN_List}
       Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_NSA_data_dl_simulated
       Analyse pcap    pcap_filename=${pcap_file}      analysis=Verify_NSA_data_ul_simulated
    END

Start the counters analysis
   [Documentation]       This test case keyword is to execute three operations
    Start PM counter analysis


Start PM counter analysis
   [Documentation]        This test case keyword is to start the counter
   PM Counters Start       analysis=verify_counters      counter_analysis_file=${counter_analysis_file}
