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
[1]TRS_CB008490-QD_Failure_Alarm_Recovery_and_Path_Supervision_Failed_Scenarios_for_NG-U_interface_SA_ASIL
    Preconditions
    Perform Commissioning     scf_file=${basic_scfc}     verify_bts_status=False    timeout=600
    Sleep   30
    Verify Alarm        expected_alarms=${expected_alarms}       check_unexpected_alarms=True
    Perform Recommissioning    type=delta   delta_file=${NRGTPU_NGU}    skip_parameter_relation_errors=${True}  timeout=300
    BuiltIn.Sleep    10
    Verify RMOD is up
    Perform Call Setup
    Attach UE and send ul dl traffic
    Verify GTPU Path Failure Alarm with Wait_Timer
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
   Configure UE    5g=device_1:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=100
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_start         ue=1        pdu=1        qfi=1         dir=ul        mbps=100
   BuiltIn.Sleep     3


Verify GTPU Path Failure Alarm with Wait_Timer
    BuiltIn.Sleep    5
    Setup Oamops    bts_host=10.0.1.2      timeout=120    alias=mplane    bts_port=443
    Setup Oamops       bts_host=10.0.1.2     alias=${slave1}
    Run     sudo ip a d 10.0.1.1/24 dev eth3.650
    Sleep   10
    Verify Alarm    faultid=7706     should_exist=True    alarm_type=active     Severity=Major  alias=${slave1}
    Wait Until Keyword Succeeds     3 minute    10 s        Verify Alarm    faultid=7706     should_exist=False    alarm_type=active
    ...    alias=${slave1}


Trigger SA calls and Verify GTP Failure Alarm
    [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=device_1:data        command=ue_register        id=3
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=ue_register        id=3
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=set_pdu_param        ue=3        pdu=1        trf_type=internal
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=ue_pdu_session_setup       ue=3          pdu=1        gw=1
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_start         ue=3         pdu=1        qfi=1        dir=dl        mbps=100
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_start         ue=3        pdu=1        qfi=1         dir=ul        mbps=100
   BuiltIn.Sleep     3
   Perform Recommissioning     type=param     param_path=MRBTS-1/NRBTS-1/NRGTPU-1:pathRecoveryWaitTimer     operation=update     value=5
   ...  timeout=900
   Run      sudo ip a d fc00::3/124 dev eth3
   Verify Alarm    faultid=7706     should_exist=True    alarm_type=active      Severity=Major
   Wait Until Keyword Succeeds     5 minute    2 s        Verify Alarm    faultid=7706     should_exist=False    alarm_type=active


Stop traffic and detach UE
   [Documentation]        This test case keyword is to stop the Calls
   Configure UE    5g=device_1:data        command=trf_data_stop        ue=1        dir=dl
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=trf_data_stop        ue=1        dir=ul
   BuiltIn.Sleep     3
   Configure UE    5g=device_1:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
   BuiltIn.Sleep     3
