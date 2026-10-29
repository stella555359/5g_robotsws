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
[1]TRS_CB008233_B_Online_Parameter_Change_for_X2U_IP_and_Path_Supervision_Parametrs_Scenarios_for_X2-U_interface_NSA_with_interface_modification_ASOE
    Perform Commissioning       scf_file=${Configuration_scf_basic}    verify_bts_status=False     timeout=360
    Verify RMOD is up
    Perform Recommissioning     type=delta      delta_file=${NRGTPU}    verify_bts_status=False     timeout=240
    Sleep    360
    Call Setup      5g=${profile}:data    parallel=${False}     verify_attach=${False}     attach=${False}      timeout=600
    Sleep   120
    Configure UE       5g=${profile}:data  command=enb_x2_link_up   target=2    enb=1
    Verify X2 link Status      1
    Get X2-U IP Address
    Attach UE and send ul dl traffic
    Verify GTP interface modification



*** Keywords ***
Verify RMOD is up
    [Documentation]       This test case keyword is to verify the rmod status
    BuiltIn.Wait Until Keyword Succeeds    20 min    30 sec    RMOD is Enabled

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


Get X2-U IP Address
    [Arguments]          ${index}=1
    ${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
    ${x2uplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=x2Uplane
    FOR   ${operator}   IN RANGE   0   ${index}
        ${x2uplane_add}=   Get from list       ${x2uplane_list}        ${operator}
        ${x2uplane_moc}=    Get From Dictionary     ${x2uplane_add}       ipV4AddressDN1
        ${x2uplane_ipif}=   Query Admin Infomodel     query=get object ${x2uplane_moc}
        ${x2uplane_ip}=    Get From Dictionary      ${x2uplane_ipif}      localIpAddr
        Set Suite Variable      ${x2uplane_ip}      ${x2uplane_ip}
    END


Verify X2 link Status
    [Arguments]          ${operators}=2
    FOR   ${operator}   IN RANGE   1   ${operators}
          ${operator_str}=     Convert To String        ${operator}
          ${X2_status}=      Query Admin Infomodel    query=get object //LTEENB_R-${operator_str}
          ${X2_link_status}=       Get From Dictionary     ${X2_status}      x2LinkStatus
          Should Be Equal    ${X2_link_status}      available
    END


Attach UE and send ul dl traffic
   [Documentation]       This test case keyword is to verify bts status to trigger calls
   ${bts_status}     Run Keyword And Return Status       Verify Bts Status      should_be_onair=${True}    req_rat=nr
   Log      ${bts_status}
   Traffic Capture Start    capture_device=vm_eth3_interface
   Run Keyword If       ${bts_status}      Trigger UE Calls_SA
   ${pcap_name}=    Traffic Capture Stop
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=CUSTOMER_GTP_X2_Uplane    filter_file_name=traffic_filters.json



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


Verify GTP interface modification
    Traffic Capture Start    capture_device=vm_eth3_interface
    BuiltIn.Sleep       30
    Perform Recommissioning     type=delta      delta_file=${x2Uplane}    verify_bts_status=False     timeout=240
    Sleep   60
    Get X2-U IP Address
    Sleep   30
    Trigger UE Calls_SA
    ${pcap_name}=    Traffic Capture Stop
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=No_GTP_X2_Uplane    filter_file_name=traffic_filters.json

