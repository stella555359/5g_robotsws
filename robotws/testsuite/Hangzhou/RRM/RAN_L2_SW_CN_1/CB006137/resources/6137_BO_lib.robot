*** Settings ***
Resource    ../../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Check Scell Addition UL And DL
    [Arguments]    ${ueId}    ${scell_physicalid}
    Check SA Scell PhysicalID With UE ID    ${ueId}    ${scell_physicalid}    1

Check Scell Active Status
    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${egate_file}=/opt/iphy/latest/egate_console.log.001
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    failed
    [Return]    ${scell_status}

Check RRC Reconfig For VoNRDrx Profile2
    Save Egate Log
    OperatingSystem.Run    mv ${SUITE_LOG_DIRECTORY}/egate_console.log ${SUITE_LOG_DIRECTORY}/egate_console-DrxProfile2.log
    ${egate_console_file}=    Set Variable    ${SUITE_LOG_DIRECTORY}/egate_console-DrxProfile2.log
    ${DrxCfgRelease}=    Grep File    ${egate_console_file}    drx-Config release
    ${output}    String.Get Lines Matching Regexp    ${DrxCfgRelease}    drx-Config release    partial_match=${true}
    Log To Console    ${output}
    ${DrxProfile2}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms8,
    Log To Console    ${DrxProfile2}
    Should Contain    ${DrxProfile2}    drx-InactivityTimer ms8,

Check Scell Activated And DRX Configuration
    [Arguments]    ${scellNum}=1
    Sleep     2s    reason=wait scell is activated
    Save Egate Log
    OperatingSystem.Run    mv ${SUITE_LOG_DIRECTORY}/egate_console.log ${SUITE_LOG_DIRECTORY}/egate_console-DRX.log
    ${egate_console_file}=    Set Variable    ${SUITE_LOG_DIRECTORY}/egate_console-DRX.log
    FOR    ${scellIdx}    IN RANGE    1    ${scellNum}
        ${scell_activation}=    Grep File    ${egate_console_file}    SCellIndex ${scellIdx} activated successfully
        Should Contain    ${scell_activation}    SCellIndex ${scellIdx} activated successfully
    END
    ${DrxProfile1}=    Grep File    ${egate_console_file}    drx-Config setup
    Should Contain    ${DrxProfile1}    drx-Config setup
    ${DrxInactivityTimer}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms80
    Should Contain    ${DrxInactivityTimer}    drx-InactivityTimer ms80
    ${output}    String.Get Lines Matching Regexp    ${DrxProfile1}    drx-Config setup    partial_match=${true}
    Log To Console    ${output}

Check UL Tput On Target Pcell Plus Scell
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_sum_tp}
    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    ${sum_tp}    Evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    DL Troughput is ${sum_tp}    console=True
    Should Be True    ${sum_tp}>=${target_sum_tp}

Decrease Traffic Step By Step To Deactive Scell
    [Arguments]    ${ue}    ${target_trf}    ${trf_peak}    ${trf_type}=dl    ${scell_index}=1
    Start SA Internal Traffic    ${ue}    mbps=100    trf_type=${trf_type}
    Sleep     1s    reason=wait scell status is stable
    Run Keyword and Ignore Error    Check Tput On Target Pcell Plus Scell    ${ue}    0    1    20
    Start SA Internal Traffic    ${ue}    mbps=50    trf_type=${trf_type}
    Sleep     1s    reason=wait scell status is stable
    Run Keyword and Ignore Error    Check Tput On Target Pcell Plus Scell    ${ue}    0    1    20
    Start SA Internal Traffic    ${ue}    mbps=20    trf_type=${trf_type}
    Sleep     1s    reason=wait scell status is stable
    Run Keyword and Ignore Error    Check Tput On Target Pcell Plus Scell    ${ue}    0    1    20
    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
    Should Be True    "${scell_status}"=="pass"

Increase Traffic Step By Step To Active Scell
    [Arguments]    ${ue}    ${total_trf}    ${step_trf}    ${trf_type}=dl    ${scell_index}=1
    ${trf_times}    Evaluate    int(${total_trf}/${step_trf})
    FOR    ${t_time}    IN RANGE    1    ${trf_times}+1
        ${trf_tmp}    Evaluate    int(${step_trf}*${t_time})
        Run Keyword If    "${trf_type}"=="dl"    SA Start DL Traffic Internal    ${ue}    pdu_id=1    mbps=${trf_tmp}    trf_id=1
        ...    ELSE    SA Start UL Traffic Internal    ${ue}    pdu_id=1    mbps=${trf_tmp}    trf_id=1
        ${scell_status}    Check Scell Active Status
        Exit For Loop If    "${scell_status}"=="pass"
    END

Start ULDL Traffic And Check The Tput
    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}    ${dl_peak_tput}    ${ul_peak_tput}
    Start SA DL Big Traffic Internal    ${ue}    ${dl_trf}
    Start SA UL Big Traffic Internal    ${ue}    ${ul_trf}
    Sleep    5s    reason=wait UL traffic is stable
    Check Tput On Target Pcell Plus Scell    ${ue}    0    1    ${dl_peak_tput}
    Sleep    5s    reason=wait UL traffic is stable
    Check UL Tput On Target Pcell Plus Scell    ${ue}    0    1    ${ul_peak_tput}

Start SA UL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big ul udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${ul_times+1}

Start SA Internal Traffic
    [Arguments]    ${ue}    ${mbps}    ${trf_type}=dl    ${pdu_id}=1    ${trf_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue} pdu\=${pdu_id} dir=${trf_type} mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait traffic is stable

Start SA VONR GBR DL And UL Traffic
    [Arguments]    ${ueId}    ${qfi_id}    ${dl_trf}    ${ul_trf}
    Log To Console    Start VONR DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
    Log To Console    Start VONR UL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
    Sleep    5s    reason=wait DL/UL traffic is stable

Stop SA Internal Traffic
    [Arguments]    ${ue_id}    ${dir_id}=dl    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=${dir_id}

Stop SA Internal Traffic With Trfid
    [Arguments]    ${ue_id}    ${dir_id}=dl    ${pdu_id}=1    ${trf_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=${dir_id} trf_id=${trf_id}

Trigger 5QI 5 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 5 Setup | 1 |
    Log To Console    start 5QI-5 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:2 5QI:5    partial_match=${true}
    Log To Console    ${output}

Trigger 5QI 1 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:3 5QI:1    partial_match=${true}
    Log To Console    ${output}

Trigger A1 With RSRP And Check Scell Addition
    [Arguments]    ${ue}    ${pcell}    ${scell}    ${rsrp}    ${mea_id}=1
    Trigger Scell Addition With CoverbaseA1 Rsrp    ${ue}    ${pcell}    ${rsrp}    ${mea_id}
    Check Scell Addition UL And DL    ${ue}    ${scell}

Trigger A2 With RSRP And Check Scell Release
    [Arguments]    ${ue}    ${scell_phycell_id}    ${scell_index}    ${rsrp}
    Trigger A2 Scell Release    ${ue}    ${scell_index}    ${rsrp}    ${scell_phycell_id}
    Check Scell Release    ${ue}    ${scell}

Check TP On Target
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
    Sleep    3s    reason=make sure rrcreconfiguration complete
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP}
    Log To Console    DL Troughput is ${dlsum_tp}    console=True
    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    ${ulsum_tp}    Evaluate    ${pcell_ulTP}+${scell_ulTP}
    Log To Console    UL Troughput is ${ulsum_tp}    console=True
    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}

Check TP On Target No CA
    [Arguments]    ${ueId}    ${pcell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
    Sleep    8s    reason=make sure hand over complete
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
    Log To Console    DL Troughput is ${pcell_dlTP}    console=True
    Should Be True    ${pcell_dlTP}>=${target_dlsum_tp}
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    Log To Console    UL Troughput is ${pcell_ulTP}    console=True
    Should Be True    ${pcell_ulTP}>=${target_ulsum_tp}

A2 Triggered Pcell Change
    [Arguments]    ${UE_ID}    ${meas_id}
    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

A3 Trigger Handover
    [Arguments]    ${UE_ID}    ${meas_id}    ${PCELL_ID}    ${EXT_ENB1}    ${EXT_ENB2}
    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${PCELL_ID} nrsrp_nr=80 nrsrq_nr=80
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=Intra-eNB handover from ${EXT_ENB1} to ${EXT_ENB2} performed

Check Pcell And Scell Tput Per UE
    [Arguments]    ${ueId}    ${PcellDlTput}    ${ScellDlTput}    ${PcellUlTput}    ${ScellUlTput}
    Sleep   10s    reason=wait traffic to be stable
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${PcellDlTput}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=1    target_tp=${ScellDlTput}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=ul    cell_type=pcell    scell_index=0    target_tp=${PcellUlTput}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=ul    cell_type=scell    scell_index=1    target_tp=${ScellUlTput}

Check Pcell And Scell DL Tput Per UE
    [Arguments]    ${ueId}    ${PcellDlTput}    ${DlTput_Scell1}    ${DlTput_Scell2}    ${DlTput_Scell3}
    Sleep   10s    reason=wait traffic to be stable
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${PcellDlTput}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=1    target_tp=${DlTput_Scell1}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=2    target_tp=${DlTput_Scell2}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=3    target_tp=${DlTput_Scell3}

Check Pcell And Scell UL Tput Per UE
    [Arguments]    ${ueId}    ${PcellUlTput}    ${UlTput_Scell1}    ${UlTput_Scell2}    ${UlTput_Scell3}
    Sleep   10s    reason=wait traffic to be stable
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=ul    cell_type=pcell    scell_index=0    target_tp=${PcellUlTput}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=ul    cell_type=scell    scell_index=1    target_tp=${UlTput_Scell1}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=ul    cell_type=scell    scell_index=2    target_tp=${UlTput_Scell2}
    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=ul    cell_type=scell    scell_index=3    target_tp=${UlTput_Scell3}

Check TP On Target 4CC
    [Arguments]    ${ueId}    ${target_dlsum_tp}    ${target_ulsum_tp}
    Sleep    3s    reason=make sure rrcreconfiguration complete
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    0
    ${scell1_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    1
    ${scell2_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    2
    ${scell3_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    3
    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell1_dlTP}+${scell2_dlTP}+${scell3_dlTP}
    Log To Console    DL Troughput is ${dlsum_tp}    console=True
    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    0
    ${scell1_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    2
    ${ulsum_tp}    Evaluate    ${pcell_ulTP}+${scell1_ulTP}
    Log To Console    UL Troughput is ${ulsum_tp}    console=True
    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}
