*** Settings ***
Documentation    CB008927
...              \n Please do not edit the existing keywords in this file without testing.
Resource          ./../../CUDU_L2/common_setup_teardown.robot
Library          ./python_keyword_for_ttitrace.py

*** Variables ***
${force_reboot}     ${True}
${Resource_PATH}    ${CURDIR}
${dlttitrace}       output_dl.csv
${filter}          (dldata_ssblocksendreql1sw||dldata_csirssendreql1sw||(3gpp.rnti == 65535 and dldata_pdschsendreql1sw))and(3gpp.subcellid == 0)
@{column_name}     3gpp.sfn    3gpp.slot    3gpp.rnti    3gpp.subcellid
                   ...    nr-rrc.controlResourceSetZero    nr-rrc.ssb_SubcarrierOffset
                   ...    DlData_CsiRsResourceL1sw_t.startPrb    DlData_CsiRsResourceL1sw_t.numOfPrb
                   ...    DlData_CsiRsResourceL1sw_t.startSymbol    DlData_CsiRsResourceL1sw_t.trsInfo
                   ...    DlData_PdschGrantL1sw.startPrb    DlData_PdschGrantL1sw.numOfPrb

*** Keywords ***

UE register with RAT1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes

    ${RAT1_patten}    Set Variable    resourceAllocation resourceAllocationType1,(.|\r|\n)*?rbg-Size config1
    Should Match Regexp    ${output}    ${RAT1_patten}

Check Rat0bitmap from TTITrace
    [Arguments]    ${log_dir}    ${pci}
    ${value}    Read Csv Columns    ${log_dir}/output_dl.csv    dlFdSchedData.rat0Bitmap    filter=physCellId=${pci}
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${rat0bitmap_list}

# ***************  Prepare ***************
Prepare TL w gNB_xml '${gNB_xml}' AP_xml '${AP_xml}' AP_cfg'${AP_cfg}'
    Run Keywords    log    <----CASE START: ${TEST_NAME} ---->    WARN
    ...    AND    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${gNB_xml}
    ...    iphy_file=${AP_xml}    swconfig_param=${RD}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${AP_cfg}
    ...    AND    Suite Setup Start WTS And Check OnAir    log=${False}    AND    Common Test Setup 2

Start UTE WTS with cfg file '${WTS_CFG}'
    Start UTE WTS    ${WTS_CFG}

Set egate rrc log '${flag}'
    ute_wtssim.Execute Egate Command    cmd=trace uec\=1 protocol\=rrc,nr_rrc ${flag}

online change with xml '${xml}'
    ${json_file}    Change Delta XML File To Delta Json File    ${xml}
    Delta Commission With SCF File    ${json_file}
    Suite Setup Start WTS And Check OnAir    log=${False}

# ***************  SA attach ***************
UE '${sid}'-'${eid}' Attach to Cell '${cell_id}' and setup PDU Session '${pdu_id}' with slice '${slice}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        ute_wtssim.Execute Egate Command    cmd=ue_change_location id\=${ue_id} cell\=${cell_id}
        SA 5G Attach    ${ue_id}
        SA Set Traffic Type To Internal    ${ue_id}    ${pdu_id}
        Trigger 5QI'6' Setup on UE '${ue_id}' on pdu '${pdu_id}'w nwslice '${slice}'
    END

UE '${sid}'-'${eid}' Attach to Cell '${cell_id}' and setup VoNR
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        ute_wtssim.Execute Egate Command    cmd=ue_change_location id\=${ue_id} cell\=${cell_id}
        SA VoNR Call For UE '${ue_id}'
    END

UE '${sid}'-'${eid}' Attach to Cell '${cell_id}' and setup external PDU Session '${pdu_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        ute_wtssim.Execute Egate Command    cmd=ue_change_location id\=${ue_id} cell\=${cell_id}
        SA 5G Attach    ue_id=${ue_id}
        SA Set Traffic Type To external    ${ue_id}    ${pdu_id}
        SA 5G PDU Session Setup    ${ue_id}    ${pdu_id}
    END

SA Set Traffic Type To external
    [Arguments]    ${ue_id}    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=external

# ***************  SA multi-DRB ***************
SA VoNR Call For UE '${ue_id}'
    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA Non GBR call for multi UE | 1 |
    SA 5G Attach    ${ue_id}
    SA Set Traffic Type To Internal    ${ue_id}    1
    SA 5G PDU Session Setup For Multi UE    ${ue_id}
    Modify 5QI 5 on UE '${ue_id}' with qosflows '2'
    Modify 5QI 1 on UE '${ue_id}' with qosflows '3'

Modify 5QI 5 on UE '${ue_id}' with qosflows '${qosflows_id}'
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 5 Setup | 1 |
    Log To Console    start 5QI-5 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_id} by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=1minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Modify 5QI 1 on UE '${ue_id}' with qosflows '${qosflows_id}'
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_id} by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message
    ...    timeout=1minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Modify 5QI 7 on multiUE '${sid}'-'${eid}' with qosflows '${qosflows_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        Modify 5QI 7 on UE '${ue_id}' with qosflows '${qosflows_id}'
    END

Modify 5QI 7 on UE '${ue_id}' with qosflows '${qosflows_id}'
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 2 Setup | 1 |
    Log To Console    start 5QI-2 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_id} by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Modify 5QI 2 on multiUE '${sid}'-'${eid}' with qosflows '${qosflows_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        Modify 5QI 2 on UE '${ue_id}' with qosflows '${qosflows_id}'
    END

Modify 5QI 2 on UE '${ue_id}' with qosflows '${qosflows_id}'
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 2 Setup | 1 |
    Log To Console    start 5QI-2 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_id} by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Setup 5QI 7 on multiUE '${sid}'-'${eid}' on pdu '${id}' with nwslice '${slice}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Set Traffic Type To Internal    ${ue_id}    ${id}
        Trigger 5QI'7' Setup on UE '${ue_id}' on pdu '${id}'w nwslice '${slice}'
    END

Trigger 5QI'${5qi_id}' Setup on UE '${ue_id}' on pdu '${id}'w nwslice '${slice}'
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start 5QI-${5qi_id} Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${id} nwslice=${slice} gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Initial Context Setup Successful|Resource Setup Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=1minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

# ***************  SA data send and stop ***************
Start ul Trafficon on UE '${sid}'-'${eid}' PDU ID '${pdu_id}' TRF ID '${trf_id}' QFI ID '${qfi_id}' with '${mbps}'mbps
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}    ${qfi_id}
    END

Start dl Trafficon on UE '${sid}'-'${eid}' PDU ID '${pdu_id}' TRF ID '${trf_id}' QFI ID '${qfi_id}' with '${mbps}'mbps
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}    2s    ${qfi_id}
    END

Start rtp_codec '${codec}' ul and dl data traffic on 5QI1 on ue'${sid}'-'${eid}' with PDU ID '${pdu_id}' TRF ID '${trf_id}' QFI ID '${qfi_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start DL voNR Traffic Internal    ${ue_id}    ${pdu_id}    ${codec}    ${trf_id}    2s    ${qfi_id}
        SA Start UL voNR Traffic Internal    ${ue_id}    ${pdu_id}    ${codec}    ${trf_id}    2s    ${qfi_id}
    END

SA Start UL voNR Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${codec}    ${trf_id}=1    ${sleep_time}=2s    ${qfi_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    \nStart UE${ue_id} UL ${codec} traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=ul rtp_codec\=${codec} trf_id\=${trf_id}
    Sleep    ${sleep_time}    reason=wait UL traffic is stable

SA Start DL voNR Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${codec}    ${trf_id}=1    ${sleep_time}=2s    ${qfi_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
    Log To Console    UE${ue_id} start DL ${codec} traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=dl rtp_codec\=${codec} trf_id\=${trf_id}
    Sleep    ${sleep_time}    reason=wait DL traffic is stable

Get UeIp From Egate and Ping the latest '${number}' UE
    Log To Console    start to get UE ip and ping UE
    ${rnti_reg}=    Set Variable    UE IP address:(\\d+\.\\d+\.\\d+\.\\d+)
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${ipList}=    String.Get Regexp Matches    ${content}    ${rnti_reg}      1
    ${number}          Evaluate          ${number}+1
    @{ipListNew}    Create List
    FOR    ${id}    IN RANGE    1    ${number}
        Append To List    ${ipListNew}    ${ipList}[-${id}]
    END
    FOR    ${ip}    IN    ${ipListNew}
        Execute ping to UE ip '${ip}'
        BuiltIn.Sleep   1s
    END

Execute ping to UE ip '${ip}'
    ${result}    Run Keyword    Process.Start Process    ping ${ip}    shell=True

Paging from AMF on UE '${id}'
    Make UE to idle on UE '${id}'
    Log To Console    Start to paging
    ${cmd}    Catenate    amf_paging_start id\=1 ue\=${id}
    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=reestablishment complete

Make UE to idle on UE '${id}'
    Log To Console    NAS normal release in progress
    ute_wtssim.Execute Egate Command    cmd=amf_paging_param id\=1 default_drx=128 max_paging_retries\=1
    ute_wtssim.Execute Egate Command    cmd=ue_ng_ctx_release id\=${id} cause\=NAS_normal_release    pass_regexp=UE Context Release Complete

Stop '${dir}' Traffic on UE '${sid}'-'${eid}' on PDU ID '${pdu_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Stop Data Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}
    END

# ***************  SA tput check ***************
Wait '${dir}' TPut get Target of '${target_tput}'mbps on UE '${ue_id}' of PDU ID '${pdu_id}'
   Wait until keyword succeeds    2min  10s    SA Check UE Cell TPut On Target
   ...    ${ue_id}    ${pdu_id}    ${dir}    ${target_tput}

Get SA UE'${ue_id}' '${dir}' tput on on PDU '${pdu_id}' QFI '${qfi}'
    ${act_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}
    [Return]    ${act_tp}

# ***************  SA detach ***************
SA 5G UE '${sid}'-'${eid}' Detach
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA 5G Detach    ${ue_id}
    END

# ***************  NSA attach ***************
UE '${sid}'-'${eid}' Attach to LTE Cell
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        NSA LTE Attach    ${ue_id}    1
    END

UE '${sid}'-'${eid}' Attach to NR Cell '${cid}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        NSA 5G Attach    ${ue_id}    2    ${cid}    2
    END

# ***************  NSA data send and stop ***************
Start dl Trafficon on UE '${sid}'-'${eid}' BearerID '${bearer_id}'with '${mbps}'mbps
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        NSA Start DL Traffic    ${ue_id}    ${bearer_id}    ${mbps}
    END

Start ul Trafficon on UE '${sid}'-'${eid}' BearerID '${bearer_id}'with '${mbps}'mbps
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        NSA Start UL Traffic    ${ue_id}    ${bearer_id}    ${mbps}
    END

Execute ping to UE '${ip}'
    Log To Console    start to ping UE
    ${result}    Run Keyword    Process.Start Process    ping ${ip}    shell=True

Stop '${dir}' Traffic on UE '${sid}'-'${eid}' BearerID '${bearer_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        NSA Stop Traffic    ${ue_id}    ${bearer_id}    ${dir}
    END

# ***************  NSA tput check ***************
Wait '${dir}' TPut get Target of '${target_tput}'mbps on UE '${ue_id}' of Bearer ID '${bearer_id}'
   Wait until keyword succeeds    30s  10s    NSA Check Average Traffic Bigger Than Target
   ...    ${ue_id}    ${bearer_id}    ${dir}    ${target_tput}

Get NSA UE '${ue_id}' '${dir}' TPut on Bearer ID '${bearer_id}'
    ${tp_delta}    NSA Get UE Average Traffic    ${ue_id}    ${bearer_id}    ${dir}
    [Return]    ${tp_delta}

# ***************  NSA detach ***************
NSA UE '${sid}'-'${eid}' Detach
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        NSA LTE Detach    ${ue_id}
    END

# ***************  LA ***************
Add DL Bler '${bler}' For NR Pcell on UE'${id}'
    ute_wtssim.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=4 dl_bler=${bler}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${id} scell=0 testmode=bler profile_id=4 action=activate

Clear DL Bler For NR Pcell on UE'${id}'
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${id} scell=0 testmode=bler profile_id=4 action=deactivate

# ***************  log capture ***************
Capture Ttitrace for duration '${capture_time}' to log dir '${log_dir}'
    Capture Convert Format Ttitrace With Streaming Mode    ${capture_time}    ${TEST_LOG_DIRECTORY}/${log_dir}
    [Return]    ${TEST_LOG_DIRECTORY}/${log_dir}/${dlttitrace}

Start capture Ttitrace
    common_Log_capture.Start Ttitrace With Streaming Mode

Stop capture Ttitrace and convert to Excelcsv to log dir '${log_dir}'
    common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/${log_dir}
    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_DIRECTORY}/${log_dir}
    [Return]    ${TEST_LOG_DIRECTORY}/${log_dir}/${dlttitrace}

Capture BIP for'${time}' to logDir'${dir}'and convert to csv'${name}' with filter'${filter}' and'${column_name}'
    Start Gnb BIP Log
    Sleep    ${time}
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/${dir}/
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${dir}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${dir}/${name}    ${filter}    ${column_name}
    [Return]    ${TEST_LOG_DIRECTORY}/${dir}/${name}

# ***************  Mobility ***************
Trigger A2 Event on UE '${ue_id}' srsrp_nr '${srsrp_nr}' srsrq_nr '${srsrq_nr}' of meas_id '${meas_id}'
    ${cmd}=    Catenate    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ute_wtssim.Execute Egate Command    ${cmd}
    Trigger A2 Event For Handover Ex    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${meas_id}
    ${cmd2}=    Catenate    ue_meas_cfg_disp id=${ue_id}
    ute_wtssim.Execute Egate Command    cmd=${cmd2}    pass_regexp=REPORT CONFIGURATIONS

Trigger A2 Event For Handover Ex
    [Arguments]    ${ue_id}    ${srsrp_nr}=11    ${srsrq_nr}=11    ${meas_id}=${EMPTY}
    Log To Console    Trigger A2 Event For Inter Freq Handover
    ${cmd2}=    Catenate    ue_meas_cfg_disp id=${ue_id}
    ute_wtssim.Execute Egate Command    cmd=${cmd2}    pass_regexp=REPORT CONFIGURATIONS
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A2    ${ue_id}
    ${measida2}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${pattern}    Set Variable    Successfully reconfigured dual connectivity
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measida2} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
    Should Match Regexp    ${output}    measGapConfig setup
    Sleep    1s    reason=wait for traffic stable

Trigger A3 Event on UE '${UE_ID}' For interFreqHO on meas_id '${meas_id}' to physcellID '${PCELL_ID}'
    Log To Console    Trigger measurement_gap off
    ${cmd1}=    Catenate    ue_enb_param id=${ue_id} measurement_gap=off
    ute_wtssim.Execute Egate Command    cmd=${cmd1}    #pass_regexp=REPORT CONFIGURATIONS
    Log To Console    Trigger A3 Event For Inter Freq Handover
    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${PCELL_ID} nrsrp_nr=80 nrsrq_nr=80
    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=SgNB Modification Confirm
    ${cmd2}=    Catenate    ue_meas_cfg_disp id=${ue_id}
    ute_wtssim.Execute Egate Command    cmd=${cmd2}    pass_regexp=REPORT CONFIGURATIONS

# ***************  log verify ***************
Verify ttitrace bler should not high than '${rate}' in path '${ttiPath}'
    ${ret1}    Summary_harq_info_bler_rate_in_path    ${TEST_LOG_DIRECTORY}/${ttiPath}/    ${rate}
    Log    ${ret1}      WARN
    Run Keyword And Continue On Failure    Should Contain    ${ret1}    True
    Run Keyword And Continue On Failure    Should not Contain    ${ret1}    False

Verify ttitrace bler should higher than '${rate}' in path '${ttiPath}'
    ${ret1}    Summary_harq_info_bler_rate_in_path    ${TEST_LOG_DIRECTORY}/${ttiPath}/    ${rate}
    Log    ${ret1}      WARN
    Run Keyword And Continue On Failure    Should Contain    ${ret1}    False

Get Egate log and check '${ResourceAllocationType1}'
    Log To Console    start to check 'ResourceAllocationType' in egate log
    ${ResourceAllocationType_reg}=    Set Variable    ResourceAllocationType: (RESOURCEALLOCATIONTYPE\\d+)
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${ResourceAllocationType}=    String.Get Regexp Matches    ${content}    ${ResourceAllocationType_reg}      1
    Should Contain    ${ResourceAllocationType}[-1]    ${ResourceAllocationType1}

Generate Data From Bip'${csv1}' TTitrace'${csv2}' FrameType'${type}' physCellId'${id}' when ignoreNotFullBufferSlot'${flag}'
    ${Data}    ${csvTputContent}    Generate_Summary_Csv    ${csv1}    ${csv2}    ${type}    ${id}    ${flag}
    log    ${csvTputContent}    WARN
    [Return]    ${Data}

Check PrbNum'${prbExpression}' Should not Lower Percentage'${p}' on SlotType'${type}' in Data'${Data}'
#    valid slotType in: [ SSB, SIB/OSI, TRS, D, S ]
#    valid Operators in:  [">", "<", "==", "!=", ">=", "<="]
    ${rst}    ${print}    Check_PrbNum_Should_as_Expected_on_SlotType    ${Data}    ${prbExpression}    ${p}    ${type}
    log    ${print}    WARN
    Run Keyword And Continue On Failure    should be true    ${rst}

Verify Column '${name}' Average Value Should In Range '${min}'-'${max}' in ttiLog '${logFile}'
    ${rst}    ${print}    Verify_Column_Average_Value_Should_In_Range    ${logFile}    ${name}    ${min}    ${max}
    log    ${print}    WARN
    Run Keyword And Continue On Failure    should be true    ${rst}
