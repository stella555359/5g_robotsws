*** Settings ***
Variables    ../TestData/variable_9104.py
Library    ../lib/CB007331.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot

Documentation
...    author: jiangjing lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${throughput_dl_LTE}    300
${throughput_ul_LTE}    50
${target_throughput_dl_LTE}    213
${target_throughput_ul_LTE}    12
${ue_type_4G}    nokia_fastmile
${ue_type_5G}    nokia_fastmile
@{lte_cell_401}    ${401}
@{lte_cell_402}    ${402}
@{lte_cell_403}    ${403}
@{lte_cell_404}    ${404}

*** Keywords ***
General_SiSo_RU_module_reset_from_GUI_AZQF
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${protocol}=udp    ${duration}=${600}
    ...    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    8min    15s    RU Should Be Offline    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
    ...    target_avg_percent=${0.85}    min_percent=${0.80}

General_SiSo_RU_lock_unlock_AZQF
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${protocol}=udp    ${duration}=${30}
    ...    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Lock all RUs and check status    ru_index_list=${ru_index_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Unlock all RUs and check status    ru_index_list=${ru_index_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
    ...    target_avg_percent=${0.85}    min_percent=${0.80}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    [Teardown]  Run keywords    run keyword and ignore error    Unlock all RUs and check status    ru_index_list=${ru_index_list}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}    AND
    ...    run keyword and ignore error    Selenium Logout And Close Browser

General_SiSo_Cell_block_and_unblock_AZQF
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${protocol}=udp    ${duration}=${30}
    ...    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cells_other}    Get Other Ids    id_list=${cell_id_list}    given_id=${cell_id}[0]
    Block cells and check status    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
    ...    target_avg_percent=${0.85}    min_percent=${0.80}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${cell_id}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${cell_id}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}
    ...    target_avg_percent=${0.85}    min_percent=${0.80}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status    block_list=${lte_cell_404}
    run keyword and ignore error    Selenium Logout And Close Browser
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    sleep    120s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE cells and check status    block_list=${lte_cell_404}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status    block_list=${lte_cell_403}
    run keyword and ignore error    Selenium Logout And Close Browser
     Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE cells and check status    block_list=${lte_cell_403}
    run keyword and ignore error    Selenium Logout And Close Browser
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    sleep    120s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    [Teardown]    run keywords    run keyword and ignore error    UnBlock cells and check status in teardown step
    ...    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}

General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_Concurrent
    [Arguments]    ${tput_self_define}    ${duration}=${600}
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    ${tput_cell_1}    set variable    ${tput_self_define[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    run keywords    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${protocol}=udp    ${duration}=${600}
    ...    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}

Get Band From Case Name
    [Arguments]    ${casename}
    ${tmp}    split string    ${casename}    _
    ${band}    set variable    ${tmp}[-1]
    [Return]    ${band}

Commission According Band And FrameStruct
    [Arguments]    ${bandlist}    ${framestructlist}    ${config_id}=1
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${bandlist}[0]_config${config_id}.xml
    ${band_from_scf}    Get BandInfo From SCF
    ${status}  Run keyword and return status    lists should be equal    ${bandlist}    ${band_from_scf}
    Run Keyword If    ${status}==False    Run Keywords
    ...    Commissioning SCF And Check On Air    ${SCF_upload}
    ...    AND    Return From Keyword
    ${framestruct_from_scf}    Get FrameStructInfo From SCF
    ${length}    Get Length    ${framestructlist}
    FOR    ${i}    IN RANGE    ${length}
        ${status}    Run keyword and return status    should be True    '${framestructlist}[${i}]'=='${framestruct_from_scf}[${i}]'
        Run Keyword If    ${status}==False    Run Keywords
        ...    Commissioning SCF And Check On Air    ${SCF_upload}
        ...    AND    Return From Keyword
    END

Get FrameStructInfo From SCF
    [Arguments]    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}
    ${mo_nums}    Get Length    ${MO_A}
    &{dict_total}      create dictionary
    FOR    ${i}    IN RANGE    ${mo_nums}
        ${distname}    Set variable    ${MO_A[${i}]['distName']}
        ${cell_id}    Fetch From Right    ${distname}    -
        ${cell_id}    evaluate    ${cell_id}-${1}
        &{dict}      create dictionary
        ${result}    coam.get_parameters    dist_name=${distname}    pattern=frameStructureType    connection=${connection}
        Set To Dictionary    ${dict}    frameStructureType    ${result}[tddFrameStructure][frameStructureType]
        ${result}    coam.get_parameters    dist_name=${distname}    pattern=guardPeriodLength    connection=${connection}
        Set To Dictionary    ${dict}    guardPeriodLength    ${result}[tddFrameStructure][guardPeriodLength]
        ${result}    coam.get_parameters    dist_name=${distname}    pattern=lteToNrFrameShift    connection=${connection}
        Set To Dictionary    ${dict}    lteToNrFrameShift    ${result}[tddFrameStructure][lteToNrFrameShift]
        ${result}    coam.get_parameters    dist_name=${distname}    pattern=tdLteUlDlConfig    connection=${connection}
        Set To Dictionary    ${dict}    tdLteUlDlConfig    ${result}[tddFrameStructure][tdLteUlDlConfig]
        ${result}    coam.get_parameters    dist_name=${distname}    pattern=ulDlDataSlotRatio    connection=${connection}
        Set To Dictionary    ${dict}    ulDlDataSlotRatio    ${result}[tddFrameStructure][ulDlDataSlotRatio]
        ${framestruct}    get_framestrut_type    frameinfo=${dict}
        Set To Dictionary    ${dict_total}    ${cell_id}    ${framestruct}
    END
    [Return]    ${dict_total}

Manual_SiSo_SM_NR_RAT_reset
    [Arguments]    ${tput_self_define}    ${duration}=${30}
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    NR RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    ${tput_cell_1}    set variable    ${tput_self_define[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    check_tput_for_each_cell_for_config    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    LTE RAT Reset
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    check_tput_for_each_cell_for_config    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_BTS_Site_Reset
    [Arguments]    ${tput_self_define}    ${duration}=${30}
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    # reset site
    Perform BTS Site Reset
    # check bts onair
    Sleep    5min
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    ${tput_cell_1}    set variable    ${tput_self_define[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    run keywords    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_Cell_block_and_unblock_AZQF_60M
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${protocol}=udp    ${duration}=${30}
    ...    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cells_other}    Get Other Ids    id_list=${cell_id_list}    given_id=${cell_id}[0]
    Block cells and check status    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}    tput_from=self_define
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${cell_id}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${cell_id}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    duration=${duration}    tput_from=self_define
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status    block_list=${lte_cell_402}
    run keyword and ignore error    Selenium Logout And Close Browser
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    sleep    120s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE cells and check status    block_list=${lte_cell_402}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status    block_list=${lte_cell_401}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE cells and check status    block_list=${lte_cell_401}
    run keyword and ignore error    Selenium Logout And Close Browser
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    sleep    120s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    [Teardown]    run keywords    run keyword and ignore error    UnBlock cells and check status in teardown step
    ...    block_list=${cells_other}    check_alarm=${False}    gnb_type=${gNb_CuType}
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}

UnBlock cells and check status in teardown step
     [Arguments]    ${block_list}    ${gnb_type}    ${check_alarm}=${False}
     run keyword and ignore error    Selenium Logout And Close Browser
     Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
     UnBlock cells and check status    block_list=${block_list}    check_alarm=${check_alarm}    gnb_type=${gnb_type}
     run keyword and ignore error    Selenium Logout And Close Browser

Get PA Ports For All RUs
    ${attenuation_port_numbers}    Get PA Ports For each RU    ru_index=${0}
    ${PA_RU1_1_4_7331}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${0}    index_end=${4}
    ${PA_RU1_5_8_7331}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${4}    index_end=${8}
    Set Suite Variable    ${PA_RU1_1_4_7331}
    Set Suite Variable    ${PA_RU1_5_8_7331}
    ${PA_RU2_7331}    Get PA Ports For each RU    ru_index=${1}
    Set Suite Variable    ${PA_RU2_7331}

CB007957 get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${time}

CB007957 online change actMicroDtx and allowTrafficConcentration
    [Arguments]     ${actMicroDtx}=false    ${allowTrafficConcentration}=false
    selenium login and disable screen lock
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-401
    ...    filter_param=Activate eNode B power saving - Micro DTX    p_name=actMicroDtx    value=${actMicroDtx}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-401
    ...    filter_param=Allow traffic concentration    p_name=allowTrafficConcentration    value=${allowTrafficConcentration}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    verify all cells should be onair
    [Teardown]    selenium logout and close browser

CB007957 online change allowTrafficConcentration
    [Arguments]     ${allowTrafficConcentration}=false
    selenium login and disable screen lock
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-401
    ...    filter_param=Allow traffic concentration    p_name=allowTrafficConcentration    value=${allowTrafficConcentration}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    verify all cells should be onair
    [Teardown]    selenium logout and close browser

CB007957-A_SISO_1_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load
    [Arguments]    ${interval}
    CB007957 online change actMicroDtx and allowTrafficConcentration
    ${wait_time}    CB007957 get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    selenium login and disable screen lock
    ${counter_3C4_step1}    Get PM Counter via Webem    counter_id=M40003C4    interval=${interval}
    selenium logout and close browser
    CB007957 online change actMicroDtx and allowTrafficConcentration    actMicroDtx=true    allowTrafficConcentration=true
    ${wait_time}    CB007957 get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    selenium login and disable screen lock
    ${counter_3C4_step2}    Get PM Counter via Webem    counter_id=M40003C4    interval=${interval}
    Should be True    ${counter_3C4_step2} < ${counter_3C4_step1}
    selenium logout and close browser
    CB007957 online change allowTrafficConcentration
    ${wait_time}    CB007957 get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    selenium login and disable screen lock
    ${counter_3C4_step3}    Get PM Counter via Webem    counter_id=M40003C4    interval=${interval}
    Should be True    ${counter_3C4_step3} < ${counter_3C4_step1}
    [Teardown]    Run Keywords    CB007957 online change actMicroDtx and allowTrafficConcentration    AND
    ...    selenium logout and close browser

CB007957-A_SISO_4_Manual_SiSo_CALL_LTE_data_call_with_activate_micro-DTx_function_2S_2CC
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    sleep    2min
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    CB007957 online change actMicroDtx and allowTrafficConcentration    actMicroDtx=true    allowTrafficConcentration=false
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    sleep    2min
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=0.6    min_percent=0.6
    [Teardown]    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}

Init PA Ports Value For All RUs
    [Arguments]    ${value}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4_7331}    value=${value}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8_7331}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_7331}    value=${127}
