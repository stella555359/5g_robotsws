*** Settings ***
Documentation
...     [Author]                    "Megha Patil"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "01-05-2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB008490-QD"
...     [Validated_TestLine]        "10-2-T0201-ASIL01"



variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases***
[1]TRS_CB008490-QD_Verify_Dynamic_Path_Supervision_of_GTP-U_path_supervision_for_NG-U_interface_modification_with_peer_IP_address_change_ASIL
    Preconditions
    Perform Commissioning     scf_file=${basic_scfc}     verify_bts_status=False    timeout=600
    Sleep   30
    Verify Alarm        expected_alarms=${expected_alarms}       check_unexpected_alarms=True
    Perform Recommissioning    type=delta   delta_file=${NRGTPU_NGU}    skip_parameter_relation_errors=${True}  timeout=300
    BuiltIn.Sleep    10
    Verify RMOD is up
    Perform Call Setup
    Attach UE and send ul dl traffic
    Verify GTP interface modification
    Stop traffic and detach UE

*** Keywords ***
Preconditions
    [Documentation]       This test case keyword is to add the required routes and IPs
    Run         ${ip_add}


Verify RMOD is up
    [Documentation]       This test case keyword is to verify the rmod status
    Wait Until Keyword Succeeds    20 min    30 sec    RMOD is Enabled

RMOD is Enabled
    [Documentation]       This test case keyword is to verify the rmod status
    @{RMOD_list} =    Query Admin Infomodel    query=get list //RMOD_R-*  timeout=300
    #   *
    @{rmod_ids}=    Create List
     FOR    ${rmod}    IN    @{RMOD_list}
        ${dist_name}=    Get From Dictionary    ${rmod}    dist_name
        ${rmod_id}=    Fetch From Right    ${dist_name}    /
        ${id_number}=    Split String From Right    ${rmod_id}    -    1
        Append To List    ${rmod_ids}    ${id_number}[1]
    END
     FOR    ${rmodId}   IN   @{rmod_ids}
        ${rmodInfo}=      Query Admin Infomodel    query=get object //RMOD_R-${rmodId}
        ${op_status}=       Get From Dictionary     ${rmodInfo}      operationalState
        Should Be Equal    ${op_status}     enabled
    END

Perform Call Setup
    [Documentation]        This test case keyword is to make the setup on On-Air and trigger the calls
    Call Setup      5g=device_1:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Verify Bts Status       should_be_onair=${True}      req_rat=nr


Attach UE and send ul dl traffic
   [Documentation]       This test case keyword is to verify bts status to trigger calls
   ${bts_status}     Run Keyword And Return Status       Verify Bts Status      should_be_onair=${True}    req_rat=nr
   Log      ${bts_status}
   Traffic Capture Start    capture_device=vm_eth3_interface
   Run Keyword If       ${bts_status}      Trigger UE Calls
   ...    ELSE     Perform Call Setup
   ${pcap_name}=    Traffic Capture Stop
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=GTP_SA_Uplane    filter_file_name=traffic_filters.json


Trigger UE Calls
   [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=device_1:data        command=ue_register        id=1
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=ue_register        id=1
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data    command=ue_pdu_session_modify    ue=1    pdu=2    qosflows_to_del=1
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_start         ue=1         pdu=2        qfi=1        dir=dl        mbps=100
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_start         ue=1        pdu=2        qfi=1         dir=ul        mbps=100
   BuiltIn.Sleep     3


Verify GTP interface modification
    Traffic Capture Start    capture_device=vm_eth3_interface
    BuiltIn.Sleep       30
    Trigger UE Calls
    Perform Recommissioning     type=param     param_path=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr     operation=update
    ...        value=10.0.1.10     timeout=900
    ${pcap_name}=    Traffic Capture Stop
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=NO_GTP_SA_Uplane    filter_file_name=traffic_filters.json


Stop traffic and detach UE
   [Documentation]        This test case keyword is to stop the Calls
   Configure UE    5g=device_1:data        command=trf_data_stop        ue=1        dir=dl
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_stop        ue=1        dir=ul
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
   BuiltIn.Sleep     3
