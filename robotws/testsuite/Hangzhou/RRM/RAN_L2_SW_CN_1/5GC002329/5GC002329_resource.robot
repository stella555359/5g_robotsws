*** Settings ***
Library      ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
*** Variables ***
${WTS_AP_XML}    AirphoneConfig.xml
${WTS_CFG}    basic_setup.cfg
${WTS_DIR}    /opt/iphy/latest
${LOCAL_WTS_DIR}    ${CURDIR}/config
${config_path}    ${EMPTY}
${gnb_swconfig}    ${config_path}/swconfig_gnb.txt
${ap_swconfig}    ${config_path}/swconfig_ap.txt
${iphy}    ${config_path}/iphy.xml
${gnb_scf}    ${config_path}/SCF_1.xml
${2329_scf}    ${LOCAL_WTS_DIR}/SCF_1.xml
${2cell_iphy}    ${LOCAL_WTS_DIR}/iphy_f_t_2cell.xml    
${wts_lua_cfg}    ${config_path}/${WTS_CFG}
${wts_ap_config}    ${config_path}/new.xml
${CELL1_SIB}    eNB 2 cell 1: SystemInformationBlockType2-NR updated
${CELL2_SIB}    eNB 2 cell 2: SystemInformationBlockType2-NR updated
${CELL3_SIB}    eNB 2 cell 3: SystemInformationBlockType2-NR updated
${CELL4_SIB}    eNB 2 cell 4: SystemInformationBlockType2-NR updated
*** Keywords ***
Send All Config For Testline
    Get Config File By Base Band Board Type
    OperatingSystem.Run    cp ${wts_lua_cfg} ${WTS_DIR}/${WTS_CFG}
    OperatingSystem.Run    cp ${wts_ap_config} ${WTS_DIR}/${WTS_AP_XML}
    Send Swconfig for GNB    ${gnb_swconfig}
    Send Swconfig for AP    ${ap_swconfig}
    #Modify IPHY File And Send to Airphone    ${iphy}
    Modify IPHY File Version By Airphone Automatically And Send To Airphone    ${iphy}
    Full Commission With SCF File    ${gnb_scf}
    #actCarrierAggregation=true
    #gNbCuType=SA
    #actNonGbrServiceDiff=false

Get Config File By Base Band Board Type
    ${config_path}    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    ${config_path_ABIO}    ${config_path_ABIL}
    ${gnb_swconfig}=    Set Variable If    "${SW_BRANCH}"=="SBTS22R2"    ${config_path}/swconfig_gnb_22R2.txt    ${config_path}/swconfig_gnb_22R1.txt
    Set Suite Variable    ${gnb_swconfig}
    ${ap_swconfig}=    Set Variable If    "${SW_BRANCH}"=="SBTS22R2"    ${config_path}/swconfig_ap_22R2.txt    ${config_path}/swconfig_ap_22R1.txt
    Set Suite Variable    ${ap_swconfig}
    Set Suite Variable    ${iphy}    ${config_path}/${iphy}
    Set Suite Variable    ${gnb_scf}    ${config_path}/${BASIC_SCF}
    Set Suite Variable    ${wts_lua_cfg}    ${config_path}/${WTS_CFG}
    Set Suite Variable    ${wts_ap_config}    ${config_path}/${WTS_AP_XML}
    OperatingSystem.File Should Exist    ${gnb_swconfig}
    OperatingSystem.File Should Exist    ${ap_swconfig}
    OperatingSystem.File Should Exist    ${iphy}
    OperatingSystem.File Should Exist    ${gnb_scf}
    OperatingSystem.File Should Exist    ${wts_lua_cfg}
    OperatingSystem.File Should Exist    ${wts_ap_config}

Common Suite Setup
    Suite Setup Update GNB    log=${False}
    #Send All Config For Testline
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    #${json_file}=    Change Delta XML File To Delta Json File    ${CURDIR}/config/delta_2329.xml
    #Run Keyword And Ignore Error    Delta Commission With SCF File    ${json_file}
    Modify IPHY File And Send to Airphone    ${2cell_iphy}
    Add RD Parameters To GNB Swconfig File    0x58062d=1
    Full Commission With SCF File    ${2329_scf}
    ${ret}=    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run keyword If    "${ret}"=="${False}"    Reboot TL And Check Configured
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Cell1 UE SIB Decoding Should Be Successful
    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL1_SIB}    timeout=300s
    Log    sib_decoding_is_ok

Cell2 UE SIB Decoding Should Be Successful
    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL2_SIB}    timeout=300s
    Log    sib_decoding_is_ok

Cell3 UE SIB Decoding Should Be Successful
    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL3_SIB}    timeout=300s
    Log    sib_decoding_is_ok

Configure UTE ETH3 For CA
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.200/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.1/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.1/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.121/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.9/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.10/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.11/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.12/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.13/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.90/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.2.91/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.103/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.104/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.105/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3

Get Cell Throughput By PM Counter
    [Documentation]    scell throughput pm counter: M55310C01006
    #<p name="reportingIntervalPm">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${pcell_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=1
    ${scell_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=2
    log to console    pcell throughput=${pcell_tp},scell throughput=${scell_tp}
    [Return]    ${pcell_tp}    ${scell_tp}

Display Egate Status
    ${output}=    ute_wtssim.Execute Egate Command    cmd=sim_state_disp    return_output=True
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_summary    return_output=True

Start WTS And Check OnAir
    [Documentation]    This keyword is to start WTS, wait for onAir
    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
    5GC002329_resource.Cell1 UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    Verify Cell Setup
    Display Egate Status
    Sleep    180s    wait for 3 cells' sib all come up...

Wait For New New Pmcounter Period Start
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.

Attach Single SA CA UE and Get Throughput
    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
    [Return]    ${pcell_tp}    ${scell_tp}

Attach SA CA UE and Get Throughput
    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=350    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    ...    ${A1_add}=${False}    ${A2_rel}=${False}
    _Attach Muli SA CA UE Traffic And Setup PDU    ${UE_ID}    ${A1_add}
    _Start Multi SA CA UE Traffic    ${UE_ID}    ${dl_tp_set}    ${ul_tp_set}
    ${list_tp_all}=    _Get Multi SA CA UE Traffic    ${UE_ID}
    _Stop Multi SA CA UE Traffic    ${UE_ID}
    _Detach Multi SA CA UE    ${UE_ID}    ${A2_rel}
    _Check Muti SA CA UE DL Throughput    ${dl_tp_threshold}    ${list_tp_all}

_Attach Muli SA CA UE Traffic And Setup PDU
    [Arguments]    ${UE_ID}    ${A1_add}=${False}
    @{ids} =    String.Split String    ${UE_ID}    -
    FOR    ${UE_ID}    IN    @{ids}
        SA 5G Attach    ue_id=${UE_ID}
        SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
        SA CA 5G PDU Session Setup    ue_id=${UE_ID}    A1_add=${A1_add}
    END

_Start Multi SA CA UE Traffic
    [Arguments]    ${UE_ID}    ${dl_tp_set}    ${ul_tp_set}
    @{ids} =    String.Split String    ${UE_ID}    -
    FOR    ${UE_ID}    IN    @{ids}
        SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    END
    Sleep    5s    reason=Wait traffic stable

_Get Multi SA CA UE Traffic
    [Arguments]    ${UE_ID}
    @{ids} =    String.Split String    ${UE_ID}    -
    @{list_tp_all}=    Create List
    FOR    ${UE_ID}    IN    @{ids}
        ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
        ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
        ${pcell_dl}=    Wait Until Keyword Succeeds    3min    5s
        ...    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
        ${scell_dl}=    Wait Until Keyword Succeeds    3min    10s
        ...    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
        &{dic_tp_ue}=    Create Dictionary    pcell_dl    ${pcell_dl}    scell_dl    ${scell_dl}
        Collections.Append To List    ${list_tp_all}    ${dic_tp_ue}
    END
    [Return]    ${list_tp_all}

_Stop Multi SA CA UE Traffic
    [Arguments]    ${UE_ID}
    @{ids} =    String.Split String    ${UE_ID}    -
    FOR    ${UE_ID}    IN    @{ids}
        SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    END

_Detach Multi SA CA UE
    [Arguments]    ${UE_ID}    ${A2_rel}
    @{ids} =    String.Split String    ${UE_ID}    -
    FOR    ${UE_ID}    IN    @{ids}
        Run Keyword If    ${A2_rel}    _Trigger A2 Scell Release    ${UE_ID}
        SA 5G Detach    ue_id=${UE_ID}
    END

_Check Muti SA CA UE DL Throughput
    [Arguments]    ${dl_tp_threshold}    ${list_tp_all}
    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
        Should Be True    ${dic_tp_ue.pcell_dl}>${dl_tp_threshold} and ${dic_tp_ue.scell_dl}>${dl_tp_threshold}
    END

Modify PDU Session with VONR
    [Arguments]    ${ue_id}    ${vonr_drx}=${False}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${qfi_5qi_5}    Get QFI for 5QI setup    ${output_0}    5
    Log To Console    ${output_0}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output_1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    Run Keyword If    ${vonr_drx}    String.Get Lines Matching Regexp    ${output_1}    drx-Config setup    partial_match=${true}
    ${qfi_5qi_1}    Get QFI for 5QI setup    ${output_1}    1
    Log To Console    ${output_1}
    [Return]    ${qfi_5qi_5}    ${qfi_5qi_1}

Release PDU Session with VONR
    [Arguments]    ${ue_id}    ${common_drx}=${False}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    Run Keyword If    ${common_drx}    String.Get Lines Matching Regexp    ${output}    drx-Config setup    partial_match=${true}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Get QFI for 5QI setup
    [Arguments]    ${content}    ${5QI_id}
    ${qosflow_added}    Set Variable    Added QosFlow with QFI:(\\d) 5QI:${5QI_id} SEID:1
    ${qfi_id}    String.Get Regexp Matches    ${content}    ${qosflow_added}    1
    Log to Console    ${qfi_id}
    [Return]    ${qfi_id}[0]

SA Start VONR DL TCP and UDP Traffic
    [Arguments]    ${ue_id}    ${tcp_qfi}    ${udp_qfi}
    Log To Console    Start DL TCP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu=1 qfi\=${tcp_qfi} trf_id=1 protocol=tcp dir=dl
    Log To Console    Start DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi\=${udp_qfi} trf_id=2 mbps=10 dir=dl protocol=udp
    Sleep    5s    reason=wait DL TCP traffic is stable

Get and Check CA UE DL throughput
    [Arguments]    ${ue_id}    ${pcell_dl_tp_threshold}    ${scell_dl_tp_threshold}
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=1    dir=dl
    ${pcell_dl}=    Wait Until Keyword Succeeds    3min    5s
    ...    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_dl}=    Wait Until Keyword Succeeds    3min    10s
    ...    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1
    Should Be True    ${pcell_dl}>${pcell_dl_tp_threshold} and ${scell_dl}>${scell_dl_tp_threshold}

Attach SA UE and Check pCSI multiplexing
    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    ${output}=    SA 5G PDU Session Setup CA   ue_id=${UE_ID}
	Check pCSI multiplexing    ${output}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}

SA 5G PDU Session Setup CA
    [Arguments]    ${ue_id}
    Log To Console    start 5G PDU Session Setup CA...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    [Return]    ${output}
    Log To Console    ${output}

Check pCSI multiplexing
    [Arguments]    ${content}
    ${slot_320_regex}=    Set Variable    reportSlotConfig slots320 : (?P<slot_320>\\d+)
    ${slot_320_list}=    String.Get Regexp Matches    ${content}    ${slot_320_regex}    slot_320
    ${slot_320_1}=    Set Variable    @{slot_320_list}[0]
    ${slot_320_2}=    Set Variable    @{slot_320_list}[1]
    Should Be True    "${slot_320_1}"=="${slot_320_2}"

Get and Check PM Counter After SCELL Activation
    [Documentation]    scell throughput pm counter: M55310C01006
    #<p name="reportingIntervalPm">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${pcell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=1
    Should Be True    "${pcell_dl_tp}">"0"
    ${scell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=2
    Should Be True    "${scell_dl_tp}">"0"
    ${pcell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=1
    Should Be True    "${pcell_ul_tp}">"0"
    ${scell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=2
    Should Be True    "${scell_ul_tp}"=="0"
    ${scell_activations}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=2
    Should Be True    "${scell_activations}"=="1"
    ${scell_deact_buffer}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=2
    Should Be True    "${scell_deact_buffer}"=="0"

Get and Check PM Counter After SCELL Deactivation
    [Documentation]    scell throughput pm counter: M55310C01006
    #<p name="reportingIntervalPm">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${pcell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=1
    Should Be True    "${pcell_dl_tp}">"0"
    ${pcell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=1
    Should Be True    "${pcell_ul_tp}">"0"
    ${scell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C03006    cell_id=2
    Should Be True    "${scell_ul_tp}"=="0"
    ${scell_activations}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=2
    Should Be True    "${scell_activations}"=="0"
    ${scell_deact_buffer}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=2
    Should Be True    "${scell_deact_buffer}"=="1"
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${scell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=2
    Should Be True    "${scell_dl_tp}"=="0"


Moving UE to SCell bad coverage area
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=0 num_dl_pkts=10000
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} scell=1 testmode=bler action=activate profile_id=1

Check Scell Activation
    ta5g_egate.Wait For Egate Console Output    expected_message=SCellIndex 1 activated successfully    timeout=300s
    Log To Console    SCellIndex 1 activated successfully

SA Start DL and UL Traffic
    Log To Console    Start DL Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
    Log To Console    Start UL Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=3 mbps=175 dir=ul

Attach SA UE
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}

A1 triggered Scell Addition
    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A1 srsrp_nr=110 phycell_id=50
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

A2 triggered Pcell Change
    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 srsrp_nr=80 srsrq_nr=66 scell=1 scell_rsrp=115 scell_rsrq=100
	${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Set WTS UE To Single Cell
    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
    @{old_params_list}    Create List    enb=2 cell=[0-9]
    @{new_params_list}    Create List    enb=2 cell=3
    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}

Attach SA UE Do HO and Get Throughput
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    Save Egate Log    log_path=${Egatelog_path}
    ${measId}=    Get MeasID A3
    Trigger Intra A3 HO Incoming    ${UE_ID}    meas_id=${measId}
    Sleep    3s
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    should be true    ${pcell_tp}>${dl_tp_threshold}
    should be true    ${scell_tp}>${dl_tp_threshold}
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}

Get MeasID A3
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA3
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[0]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measId}=    Set Variable    @{measId_list}[0]
    [Return]    ${measId}

Trigger Intra A3 HO Incoming
    [Arguments]    ${UE_ID}=1    ${meas_id}=1
    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
    ...    phycell_id=50 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=SCellIndex 1 activated successfully

Change UE Capability for 2200
    [Documentation]    Set QCM-SDX60 UE capability for 2200
    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
    @{old_params_list}    Create List    ue_nr_capabilities=[0-9a-zA-Z]+
    ${UE_CAPACITY_2200}=    Catenate    SEPARATOR=    ue_nr_capabilities=E9A0D000574D5A13160003C12016093160019C3D0304D90
    ...    61CF9863CA160704C020311C01EA3614606B04610D04083A4022CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C0017C00700
    ...    05F0002400702A0F88DAC1184341020F100892D931541238F21CF8C73E618F28581C0E1E04FE0000003F80000001200380083070A0200
    ...    0007587850001846000084015070500711800001048100388C00000C00C028808C0A8B4090226C73E1C2893B639F0E1429DB1CF870276
    ...    C73E182410431087A07803E0028100C0381802A0380030120020301F0A801000000008000010040000000200000401000004008000030
    ...    040000200200001401000802008020000180100000C0080000700400003802001000000040000400200100C0300400004802000028010
    ...    00016008004050140100080003802001030070040000680200003A4940081E079724A0000F2E4940181E0781E079724A0080F03C0F2E4
    ...    940301E0781E0781E0781E5C9280403C0F03C0F03CB92500E0781E0781E0781E0781E5C1280003CB92500007A724A0040F03D39250040
    ...    781E07A704A0000F4E4940381E0781E0781E0781E07A724A00C0F03C0F03D3925000078724A01C0F03C0F03C0F03C0F03C39250020781
    ...    E1C9280303C0F03C0F0E0940001E181FCA9ACA9AC14AC0CAC19AC0DACA5AC99AC05AC04AC08AC15ACA1AC8DAC1DADD201E0800004B292
    ...    82000032CA480800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA4808000
    ...    54B29202000172CA4A0800064B292820001B2CA4808020701D2CA4A0800074B29281CA55554AA2E9555D2A8AA0B1540E2A83455298AA4
    ...    D154062A8145526AAA475541E2ABB500C6502A2010080406030180C02010080402010180C06030180C02010080C020100804020100804
    ...    020100804020100804020100800180040700308080300602018000404008000100C018002018030851080008101820303850586068808
    ...    89098A0C0C8D8E0E8F909293139414951697A0A12320
    @{new_params_list}    Create List    ${UE_CAPACITY_2200}
    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}

Set WTS UE To Pcell
    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
    @{old_params_list}    Create List    enb=2 cell=[0-9]
    @{new_params_list}    Create List    enb=2 cell=1

Attach SA UE Do TwiceScellAddition And ScellRelease
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA1}=    Get MeasID A1
    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA2}=    Get MeasID A2 release
    Trigger A2 Release    ${UE_ID}   meas_id=${measIdA2}
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA1}=    Get MeasID A1 Twice
    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA2}=    Get MeasID A2 release Twice
    Trigger A2 Release    ${UE_ID}   meas_id=${measIdA2}
    Sleep    3s
    Get CA Cell Average Throughput    1    dl    pcell    0
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}

Get MeasID A1 Twice
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[1]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA1}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA1}

Get MeasID A2 release Twice
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[1]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA2}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA2}

Change UE Capacity for NO supportedSRS-Resources N2N1
    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
    @{old_params_list}    Create List    ue_nr_capabilities=[0-9a-zA-Z]+
    ${UE_CAPACITY_n2n1}=    Catenate    SEPARATOR=    ue_nr_capabilities=E980D000574D5A13160003C0A02C1262C003387A0609B20
    ...    C39F30C7942C0E098040623803D46C28C0D608C21A081074804596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E00
    ...    0BE000280380507C18D608C21A081078804496C98AA091C790E7C639F30C7942C0E070F027F0000001FC0000000400383000000141E0C
    ...    00060A00002120561C0C01C28000004100460E140400030E00A020C028808C0A8B4090276C73E1C29D3B639F0E14E9DB1CF870226C73E
    ...    182410421887A05007C2018060300540600060240040603E1500200000001000002008000000040000080200000801000006008000040
    ...    040000280200100401004000030020000180100000E00800007004002000000080000800400201806008000090040000500200002C010
    ...    0080A02802001000070040020600E0080000D0040000749280103C0F2E4940001E5C9280303C0F03C0F2E4940101E0781E5C9280603C0
    ...    F03C0F03C0F03CB9250080781E0781E079724A01C0F03C0F03C0F03C0F03CB825000079724A0000F4E4940081E07A724A0080F03C0F4E
    ...    0940001E9C9280703C0F03C0F03C0F03C0F4E4940181E0781E07A724A0000F0E4940381E0781E0781E0781E078724A0040F03C3925006
    ...    0781E0781E1C1280003C303F9535953582958195833581B594B5933580B58095811582B5943591B583B5BA403C1000009652504000065
    ...    949010000296525000000C1000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E
    ...    5949410000C9652504000365949010040E03A5949410000E965250394AAAA9545D2AABA55154162A81C55068AA531549A2A80C55028AA
    ...    4D5548EAA83C5576A009940A880402010180C06030080402010080406030180C060300804020300804020100804020100804020100804
    ...    0201008040200060010100182020200300801000101010000040180400080E006
    @{new_params_list}    Create List    ${UE_CAPACITY_n2n1}
    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}

Attach SA UE Do A1ScellAdd And A3HO A1ScellAdd
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA1}=    Get MeasID A1
    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
    ${measIdA3}=    Get MeasID A3
    Trigger A3 Handover    ${UE_ID}   meas_id=${measIdA3}
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA1}=    Get MeasID A1 Second Pcell
    Trigger A1 Scell Addition    ${UE_ID}   meas_id=${measIdA1}
    Sleep    3s
    Get CA Cell Average Throughput    1    dl    pcell    0
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}

Trigger A3 Handover
    [Arguments]    ${UE_ID}    ${meas_id}=1
    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5
    ...    ssinr_nr=10 phycell_id=53 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.4 performed

Get MeasID A1 Second Pcell
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[1]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA1}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA1}

SA CA 5G PDU Session Setup
    [Arguments]    ${ue_id}    ${A1_add}=${False}    ${drx_on}=${False}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | A1_add | No | ${True} |
    ...    | drx_on | No | ${True} |
    ...    Example:
    ...    | SA CA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful     timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output_0}    Initial Context Setup Successful    partial_match=${true}
    ${output}    Run Keyword Unless    ${A1_add}    String.Get Lines Matching Regexp    ${output_0}
    ...    SCellIndex 1 activated successfully    partial_match=${true}
    ${output}    Run Keyword If     ${drx_on}    String.Get Lines Matching Regexp    ${output_0}     drx-Config setup    partial_match=${true}
    Run Keyword If    ${A1_add}    Trigger A1 Scell Addition    ${ue_id}    90
    Log To Console    ${output}
