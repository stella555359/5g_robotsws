*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB007922_DL_CA_100UE.robot
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        AP    CLOUD_5G_I_LO_AP_LO    5G_RAN_TDD    CRT    SBTS00    owner_qinmao
Test Timeout      180 minutes
Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
${SCFC_NAME}          scf_CB007922_DL_CA_100UE.xml
${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
${WTS_NAME}           wts_CB007922_DL_CA_100UE.lua
@{LOG_NAME_LIST}    egatelog    gnb_snapshot
#sosreport    tshark
${actIncreasedFdmUsersPerSlot}     text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${maxNumPdschAllocationPerSlot}    text|16|//*[@name\="maxNumPdschAllocationPerSlot"]
${maxNumPuschAllocationPerSlot}    text|16|//*[@name\="maxNumPuschAllocationPerSlot"]
${tiltOffset}                      text|0|//*[@name\="tiltOffset"]
${pattern}    4x4_2cc

*** Test Cases ***
CB007922_DL_CA_100UE
    Step1:Update parameters between 2 TDD cells
    Step2:4UE DL 2CC CA
    Step3:100UE attach and send dl data

*** Keywords ***
Step1:Update parameters between 2 TDD cells
    Start Collect GNB and AP Syslog in 'step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    #add_ca_relation_CB7922    ${scfc_path}
    ${modify_list}    create list
    ...    ${actIncreasedFdmUsersPerSlot}
    ...    ${maxNumPdschAllocationPerSlot}
    ...    ${maxNumPuschAllocationPerSlot}
    ...    ${tiltOffset}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File

Step2:4UE DL 2CC CA
    Start capture GNB and AP Syslog in 'Step2_4UE' File
    FOR    ${i}    IN RANGE    1    5
        run keyword and continue on failure    Attach UE to cell2    ${i}
        Wait '0.5s' for stable running2
        run keyword and continue on failure    Send trf for UE    ${i}    DL    150M    4
    END
    Wait '300s' for stable running2
    #Start GNB Ttitrace With Streaming Mode
    #Wait '0.5s' for stable running2
    #${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_4UE
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${DL_tput_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${DL_tput_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    run keyword and continue on failure    should be true    ${DL_tput_cell1}>1000
    run keyword and continue on failure    should be true    ${DL_tput_cell2}>1000
    FOR    ${i}    IN RANGE    1    5
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_4UE' File

Step3:100UE attach and send dl data
    Start capture GNB and AP Syslog in 'Step3_100UE' File
    FOR    ${i}    IN RANGE    1    76
        run keyword and continue on failure    Attach UE to cell2    ${i}
        Wait '0.5s' for stable running2
        run keyword and continue on failure    Send trf for UE    ${i}    DL    28M    1
    END

    FOR    ${i}    IN RANGE    151    176
        run keyword and continue on failure    Attach UE to cell2    ${i}
        run keyword and continue on failure    Send trf for UE    ${i}    DL    80M    1
    END

    #    airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

    #Start GNB Ttitrace With Streaming Mode
    #Wait '0.5s' for stable running2
    #${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_100UE
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti

    Wait '600s' for stable running2
    Build excel table for CB007922 KPI vs
    ${DL_tput_cell1}    ${non_CA_num_1}    ${CA_num_1}    ${Max_non_CA_num_1}    ${Max_CA_num_1}    ${SCell_act_1}
    ...    ${DL_tput_cell2}    ${non_CA_num_2}    ${CA_num_2}    ${Max_non_CA_num_2}    ${Max_CA_num_2}    ${SCell_act_2}
    ...    get CA UE numbers from PM counter
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    1    ${DL_tput_cell1}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    2    ${non_CA_num_1}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    3    ${CA_num_1}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    4    ${Max_non_CA_num_1}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    5    ${Max_CA_num_1}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    6    ${SCell_act_1}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    7    ${DL_tput_cell2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    8    ${non_CA_num_2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    9    ${CA_num_2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    10    ${Max_non_CA_num_2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    11    ${Max_CA_num_2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    12    ${SCell_act_2}
    run keyword and continue on failure    should be true    ${DL_tput_cell1}>500
    run keyword and continue on failure    should be true    ${DL_tput_cell2}>500
    run keyword and continue on failure    should be true    ${CA_num_1}>1800
    run keyword and continue on failure    should be true    ${CA_num_2}>0
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_100UE' File


Attach UE to cell
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_id}    evaluate    ${ue_id}%10+1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    #${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    Wait '1s' for stable running2

Attach UE to cell2
    [Arguments]    ${ue_id}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_id}    evaluate    ${ue_id}%10+1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    #${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
    Wait '1s' for stable running2

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=7200s    trf_id=${num}
    END

Wait '${time}' for stable running2
    sleep    ${time}

modify_swconfig_by_CB007922_2
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    #add_txt_node   0x340000:15         #as PM counter period update to 15/15=1min
    add_txt_node   0x9D0000:15         #as PM counter period update to 15/15=1min
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node     0x70670:0        #22R1
    #If 4 subcells are deployed in gNB side ABIL/ABIO, then at AP side 2 AP ABILs needed to support such config blocks.
    #R&D flag value will be 0x70685=2 for such config blocks
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
Detach UE
    [Arguments]    ${ue_id}
    airphone_sa_detach    ue_id=${ue_id}    timeout=30

get CA UE numbers from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${DL_tput_1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${DL_tput_cell1}    evaluate    ${DL_tput_1}*8/1024/1024
    ${non_CA_num_1}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03000    cell_id=1
    ${CA_num_1}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03001    cell_id=1
    ${Max_non_CA_num_1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05000    cell_id=1
    ${Max_CA_num_1}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05001    cell_id=1
    ${SCell_act_1}=         get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C09000    cell_id=1
    ${DL_tput_2}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    ${DL_tput_cell2}    evaluate    ${DL_tput_2}*8/1024/1024
    ${non_CA_num_2}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03000    cell_id=2
    ${CA_num_2}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03001    cell_id=2
    ${Max_non_CA_num_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05000    cell_id=2
    ${Max_CA_num_2}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05001    cell_id=2
    ${SCell_act_2}=         get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C09000    cell_id=2
    [Return]    ${DL_tput_cell1}    ${non_CA_num_1}    ${CA_num_1}    ${Max_non_CA_num_1}    ${Max_CA_num_1}    ${SCell_act_1}
    ...         ${DL_tput_cell2}    ${non_CA_num_2}    ${CA_num_2}    ${Max_non_CA_num_2}    ${Max_CA_num_2}    ${SCell_act_2}

Build excel table for CB007922 KPI vs
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    1    0    ${SOFTWARE_INFO}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    1    tput_M55309C12001_cell1
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    2    PSCell_UEs_0_activated_SCells_cell1
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    3    PSCell_UEs_1_activated_SCells_cell1
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    4    Max_PSCell_UEs_0_activated_SCells_cell1
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    5    Max_PSCell_UEs_0_activated_SCells_cell1
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    6    SCell_activations_cell1
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    7    tput_M55309C12001_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    8    PSCell_UEs_0_activated_SCells_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    9    PSCell_UEs_1_activated_SCells_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    10    Max_PSCell_UEs_0_activated_SCells_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    11    Max_PSCell_UEs_0_activated_SCells_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB007922_kpi.xls    Sheet1    0    12    SCell_activations_cell2

Start capture gnb and ap syslog in '${file_name}' file2
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file2
    #check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}    syslog_${file_name}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}${file_name}   unzip=TRUE
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_ap.tar.gz