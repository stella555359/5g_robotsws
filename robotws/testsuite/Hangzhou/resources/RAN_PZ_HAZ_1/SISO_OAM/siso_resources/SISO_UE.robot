*** Settings ***
Documentation    This file is for  for siso cloud related cases
...              Please do not modify the file without notification to author
...              Author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Squad: SRAN HZ SISO

Resource   ./ue_patch.robot
Resource   ./UEs/andriod_phone.robot
Resource   ./UEs/9206.robot
Resource   ./UEs/AT_dingli.robot
Resource   ./UEs/AT_simcom.robot


*** Keywords ***
SISO UE L3call
    [Arguments]     ${ue_index}
	...    ${bts_id}   ${require_attach_cell_id}   ${eutra_cel_id}
    ...    ${network_type}    ${tech}    ${band}    ${earfcn}

    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    ${ue_type}    Set Variable     ${MATCHED_UE_INFO["MODEL"]}
    Run keyword and ignore error    ${ue_type}.Prepare UE  ue_index=${ue_index}  reset_sol=${reset}
    ...   network_type=${network_type}

    Wait Until Keyword Succeeds    600 sec    30 sec    ${ue_type}.UE Attach
    ...    bts_id=${bts_id}   require_attach_cell_id=${require_attach_cell_id}    eutra_cel_id=${eutra_cel_id}
    ...    network_type=${network_type}    tech=${tech}
    ...    band=${band}    earfcn=${earfcn}
    ...    ue_index=${ue_index}

    run keyword    ${ue_type}.Verify attach
    ...    bts_id=${bts_id}    require_attach_cell_id=${require_attach_cell_id}    eutra_cel_id=${eutra_cel_id}
	...    ue_index=${ue_index}

    [Teardown]    Run Keyword And Ignore Error     ${ue_type}.UE Detach
    ...    ue_index=${ue_index}


SISO UE Tput
    [Arguments]     ${ue_index}
	...    ${bts_id}    ${require_attach_cell_id}    ${eutra_cel_id}
    ...    ${network_type}    ${tech}    ${band}    ${earfcn}
    ...    ${dl_exp}    ${ul_exp}    ${deviation}=5%

    Run Keyword If   "${tech}"!='NB-IoT-FDD' and '${tech}'!='NB-IoT-TDD'  _SISO Normal UE Tput
    ...    ${ue_index}
    ...    ${bts_id}    ${require_attach_cell_id}    ${eutra_cel_id}
    ...    ${network_type}    ${tech}    ${band}    ${earfcn}
    ...    ${dl_exp}    ${ul_exp}    ${deviation}
    ...    ELSE   _SISO NBIOT UE Tput
    ...    ${ue_index}
    ...    ${bts_id}    ${require_attach_cell_id}    ${eutra_cel_id}
    ...    ${network_type}    ${tech}    ${band}    ${earfcn}
    ...    ${dl_exp}    ${ul_exp}    ${deviation}

_SISO Normal UE Tput
    [Arguments]     ${ue_index}
	...    ${bts_id}    ${require_attach_cell_id}    ${eutra_cel_id}
	...    ${network_type}    ${tech}    ${band}    ${earfcn}
    ...    ${dl_exp}    ${ul_exp}    ${deviation}=5%

    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL

    ${data_transfer_ul}    evaluate     int(${ul_exp})+1
    ${data_transfer_dl}    evaluate     int(${dl_exp})+10

    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    ${ue_type}    Set Variable     ${MATCHED_UE_INFO["MODEL"]}
    Run keyword and ignore error    ${ue_type}.Prepare UE  ue_index=${ue_index}  reset_sol=${reset}
    ...   network_type=${network_type}

    Wait Until Keyword Succeeds    600 sec    30 sec    ${ue_type}.UE Attach
    ...    bts_id=${bts_id}   require_attach_cell_id=${require_attach_cell_id}    eutra_cel_id=${eutra_cel_id}
    ...    network_type=${network_type}    tech=${tech}
    ...    band=${band}    earfcn=${earfcn}
    ...    ue_index=${ue_index}

    run keyword    ${ue_type}.Verify attach
    ...    bts_id=${bts_id}    require_attach_cell_id=${require_attach_cell_id}    eutra_cel_id=${eutra_cel_id}
	...    ue_index=${ue_index}

    ${hour}    ${min}    ${sec}    Get Time    hour min sec

    ${time_stamp}   Set Variable    ${hour}_${min}_${sec}

    run keyword    ${ue_type}.Start traffic    require_attach_cell_id=${require_attach_cell_id}
    ...     ue_index=${ue_index}    direction=ul     throughput=${data_transfer_ul}Mbits/sec    tag=${time_stamp}
    ...    duration=20s     iperf_port=${ul_port}     dt_name=dt_ul

    run keyword    ${ue_type}.Start traffic    require_attach_cell_id=${require_attach_cell_id}
    ...    ue_index=${ue_index}
    ...    direction=dl     throughput=${data_transfer_dl}Mbits/sec    tag=${time_stamp}
    ...    duration=20s     iperf_port=${dl_port}     dt_name=dt_dl

    Sleep    3s
    run keyword    ${ue_type}.Check Peak Throughput    total_time=60    theory_dl_peak=${dl_exp}    tag=${time_stamp}
    ...    require_attach_cell_id=${require_attach_cell_id}    theory_ul_peak=${ul_exp}    interval=10
    ...    duration_time_for_once=22s
    ...    acceptable_tput_percentage=${deviation}

    [Teardown]    run keyword    ${ue_type}.UE Detach    ue_index=${ue_index}

_SISO NBIOT UE Tput
    [Arguments]     ${ue_index}
    ...    ${bts_id}    ${require_attach_cell_id}    ${eutra_cel_id}
    ...    ${network_type}    ${tech}    ${band}    ${earfcn}
    ...    ${dl_exp}    ${ul_exp}    ${deviation}=5%

    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL

    ${data_transfer_ul}    evaluate     int(${ul_exp})+1
    ${data_transfer_dl}    evaluate     int(${dl_exp})+10

    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    ${ue_type}    Set Variable     ${MATCHED_UE_INFO["MODEL"]}
    Run keyword and ignore error    ${ue_type}.Prepare UE  ue_index=${ue_index}  reset_sol=${reset}
    ...   network_type=${network_type}

    Wait Until Keyword Succeeds    600 sec    30 sec    ${ue_type}.UE Attach
    ...    bts_id=${bts_id}   require_attach_cell_id=${require_attach_cell_id}    eutra_cel_id=${eutra_cel_id}
    ...    network_type=${network_type}    tech=${tech}
    ...    band=${band}    earfcn=${earfcn}
    ...    ue_index=${ue_index}

    run keyword    ${ue_type}.Verify attach
    ...    bts_id=${bts_id}    require_attach_cell_id=${require_attach_cell_id}    eutra_cel_id=${eutra_cel_id}
	...    ue_index=${ue_index}

    ${hour}    ${min}    ${sec}    Get Time    hour min sec

    ${time_stamp}   Set Variable    ${hour}_${min}_${sec}



    run keyword    ${ue_type}.Start traffic    require_attach_cell_id=${require_attach_cell_id}
    ...    ue_index=${ue_index}
    ...    direction=dl     throughput=${data_transfer_dl}Mbits/sec    tag=${time_stamp}
    ...    duration=30s     iperf_port=${dl_port}     dt_name=dt_dl

    Sleep    3s
    run keyword    ${ue_type}.Check DL Peak Throughput    total_time=60    theory_dl_peak=${dl_exp}    tag=${time_stamp}
    ...    require_attach_cell_id=${require_attach_cell_id}    theory_ul_peak=${ul_exp}    interval=10
    ...    duration_time_for_once=30s
    ...    acceptable_tput_percentage=${deviation}

    run keyword    ${ue_type}.Start traffic    require_attach_cell_id=${require_attach_cell_id}
    ...     ue_index=${ue_index}    direction=ul     throughput=${data_transfer_ul}Mbits/sec    tag=${time_stamp}
    ...    duration=30s     iperf_port=${ul_port}     dt_name=dt_ul
    Sleep    3s

    run keyword    ${ue_type}.Check UL Peak Throughput    total_time=60    theory_dl_peak=${dl_exp}    tag=${time_stamp}
    ...    require_attach_cell_id=${require_attach_cell_id}    theory_ul_peak=${ul_exp}    interval=10
    ...    duration_time_for_once=30s
    ...    acceptable_tput_percentage=${deviation}

    [Teardown]    run keyword    ${ue_type}.UE Detach    ue_index=${ue_index}
