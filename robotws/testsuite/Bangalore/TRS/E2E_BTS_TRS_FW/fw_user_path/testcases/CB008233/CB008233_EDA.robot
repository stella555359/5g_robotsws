***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate Certifictes installed properly or not"
    ...     [Date]                  "05-06-2021"
    ...     [Author]                "Megha Patil"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "CMP"
    ...     [Feature_ID]            "CB007156"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "10-2-T0201-ASOE01:"
    ...     [Config]            "gNB should configured"


variables       ta_e2e_bts_trs_fw
Resource       ${CURDIR}/../resources/common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Variables ***
${telnet_port}              20000
${ip_a_s}        /home/ute/Documents/route_vlan_virtual.sh
${base_scfc}        /home/ute/Downloads/Configuration_scf_MRBTS-1_ASOE_Airtel_India_AKQZ_20250522-1919.xml
${counter_analysis_file}        /home/ute/fw_user_path/testcases/CB008233/resources/counter_analysis_file.json
${vlanif_counter_analysis}      /home/ute/fw_user_path/testcases/CB008233/resources/vlanif_counter_analysis.json
${NRGTPU_NG}        /home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/config/1/delta_files/NRGTPU_NG.xml

*** Test Cases ***
[1]TRS_CB008233_MAX_GTPU
    Preconditions
    Perform Commissioning     scf_file=${base_scfc}     verify_bts_status=False    timeout=600
    BuiltIn.Sleep   30
    Verify RMOD is up
    Perform Recommissioning    type=delta	delta_file=${NRGTPU_NG}	skip_parameter_relation_errors=${True}	timeout=300
    Sleep   180
    Perform Call Setup
    Attach UE and send ul dl traffic
    BuiltIn.Sleep   30
    Start the counters analysis
    BuiltIn.Sleep   30
    Verify the PM counters



*** Keywords ***
Preconditions
   [Documentation]       This test case keyword is to add the required routes and IPs
   Run    sh ${ip_a_s}

Verify RMOD is up
    [Documentation]       This test case keyword is to verify the rmod status
    Wait Until Keyword Succeeds     20 min      30 sec      RMOD is Enabled

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
   Run Keyword If       ${bts_status}      Trigger UE Calls
   ...    ELSE     Perform Call Setup
   ${pcap_name}=    Traffic Capture Stop
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=SA_ul_dl_call    filter_file_name=traffic_filters.json


Perform Call Setup
   [Documentation]        This test case keyword is to make the setup on On-Air and trigger the calls
    Call Setup      5g=Device_2:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep   120
    Verify Bts Status       should_be_onair=${True}      req_rat=nr



Trigger UE Calls
   [Documentation]        This test case keyword is to trigger the calls
    FOR     ${ue_id}    IN RANGE    1   100
    Configure UE    5g=Device_2:data        command=ue_register        id=${ue_id}
    BuiltIn.Sleep     3
    Configure UE    5g=Device_2:data        command=ue_register        id=${ue_id}
    BuiltIn.Sleep     3
    Configure UE    5g=Device_2:data        command=set_pdu_param        ue=${ue_id}        pdu=1        trf_type=internal
    BuiltIn.Sleep     3
    Configure UE    5g=Device_2:data        command=ue_pdu_session_setup       ue=${ue_id}          pdu=1        gw=1
    BuiltIn.Sleep     3
    Configure UE    5g=Device_2:data        command=trf_data_start         ue=${ue_id}         pdu=1        qfi=1        dir=dl        mbps=100
    BuiltIn.Sleep     3
    Configure UE    5g=Device_2:data        command=trf_data_start         ue=${ue_id}        pdu=1        qfi=1         dir=ul        mbps=100
    BuiltIn.Sleep     3
    Configure UE    5g=Device_2:data        command=ue_stats_nr     id=${ue_id}     cell_group=MCG
    END



Start the counters analysis
   [Documentation]       This test case keyword is to execute three operations
    Start PM counter analysis
    Sleep     100


Start PM counter analysis
   [Documentation]        This test case keyword is to start the counter
   PM Counters Start       analysis=verify_counters      counter_analysis_file=${counter_analysis_file}


Verify the PM counters
    [Documentation]        This test case keyword is to verify counter and ue status
    Verify VLANIF-1 counters
   Sleep    60


Verify VLANIF-1 counters
   [Documentation]      This test case keyword is to verify vlanif counters
   Verify PM Counters      analysis=verify_counters      counter_analysis_file=${vlanif_counter_analysis}

