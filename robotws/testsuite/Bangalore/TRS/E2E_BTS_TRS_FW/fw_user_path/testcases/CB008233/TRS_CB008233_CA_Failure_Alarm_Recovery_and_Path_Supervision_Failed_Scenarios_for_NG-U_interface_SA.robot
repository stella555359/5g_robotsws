*** Settings ***
Documentation
...     [Author]                    "Shreya Choudhary"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "01-05-2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB010712"
...     [Validated_TestLine]        "KVM65-TRSIV-TL007"
...     [Procedure]                 "TRS_Commissioning_SgNB_with_Dual_Stack_for_all_the_RATs"
...     [Precondition]              "ASOE + AEQN hardware is required"
...     [Config_Comments]           "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 10 Operators_IPv4"
...     [Function_Hash_Tags]        "SA 10 Operator RAN Sharing, Dual Stack, SCTP, verify 10 operator call with Airphone"


variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops



***Test Cases***
[1]TRS_CB008233_CA_Failure_Alarm_Recovery_and_Path_Supervision_Failed_Scenarios_for_NG-U_interface_SA
    Perform Commissioning       scf_file=${Configuration_scf_basic}    verify_bts_status=False     timeout=360
    Verify RMOD is up
    Perform Recommissioning     type=delta      delta_file=${NRGTPU}    verify_bts_status=False     timeout=240
    Sleep    360
    Call Setup      5g=${profile}:data    parallel=${False}     verify_attach=${False}     attach=${False}      timeout=600
    Sleep   120
    Configure UE       5g=${profile}:data  command=enb_x2_link_up   target=2    enb=1
    Get IP Address
    Attach UE and send ul dl traffic
    Verify GTPU Path Failure Alarm with Wait_Timer




*** Keywords ***
Verify RMOD is up
    [Documentation]       This test case keyword is to verify the rmod status
    BuiltIn.Wait Until Keyword Succeeds    20 min    30 sec    RMOD is Enabled

Get IP Address
    Get AMF IP Address
    Get NG-U IP Address

Get AMF IP Address
        ${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}
        ${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddress
        Set Suite Variable      ${amf_ip}       ${amf_ip}

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


Attach UE and send ul dl traffic
   [Documentation]       This test case keyword is to verify bts status to trigger calls
   ${bts_status}     Run Keyword And Return Status       Verify Bts Status      should_be_onair=${True}    req_rat=nr
   Log      ${bts_status}
   Traffic Capture Start    capture_device=vm_eth3_interface
   Run Keyword If       ${bts_status}      Trigger UE Calls_SA
   ...    ELSE     Perform Call Setup
   ${pcap_name}=    Traffic Capture Stop
    Sleep   60
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=CUSTOMER_GTP_NG_Uplane    filter_file_name=traffic_filters.json



Trigger UE Calls_SA
   [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=${profile}:data        command=ue_register        id=1
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=ue_register        id=1
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=100
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=trf_data_start         ue=1        pdu=1        qfi=1         dir=ul        mbps=100
   BuiltIn.Sleep     3

Perform Call Setup
    Call Setup      5g=${profile}:data    parallel=${False}     verify_attach=${False}     attach=${False}      timeout=600

Verify GTPU Path Failure Alarm with Wait_Timer
    Run     sudo ip a d fc00::1/119 dev eth3.200
    Run     sudo ip a d 10.0.1.1/24 dev eth3.200
    BuiltIn.Sleep    120
    Verify Alarm    faultid=7706     should_exist=True    alarm_type=active     Severity=Major
    Sleep   180
    Verify Alarm    faultid=7706     should_exist=False    alarm_type=active     Severity=Major
