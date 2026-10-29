*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
#Library           ../../../../../resources/python_libs/check_csv_log.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_relative_dir}    commissionings/HGZ

*** Keywords ***
Setup enviornment with relevant configuration
    [Arguments]   ${scf_path}    ${ru_list}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001342/Resources
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${testline_name}      Get TL Name
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    @{all_ru_list}    Create List    1    2
    FOR    ${r_list}    IN    @{all_ru_list}
         Run keyword and ignore error    Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    @{use_ru_list}    Run keyword If    ${ru_list}==1    Create List    2
                     ...     ELSE     Create List    0
    FOR    ${r_list}    IN    @{use_ru_list}
         Run Keyword If     ${r_list}==0    Exit For Loop
         Run keyword and ignore error    Perform RU Power Off    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    @{stream_list}=    Split String    ${current_version['Active']}    _    3
    ${steam}       Set Variable If      '${stream_list}[2]'=='9999'      SBTS00
    ...      ${stream_list}[0]
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${steam}/${scf_path}
    [Teardown]  Selenium Logout And Close Browser

Recover enviornment
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001342/Resources
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${testline_name}      Get TL Name
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    @{all_ru_list}    Create List    1    2
    FOR    ${r_list}    IN    @{all_ru_list}
         Run keyword and ignore error    Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    @{stream_list}=    Split String    ${current_version['Active']}    _    3
    ${steam}       Set Variable If      '${stream_list}[2]'=='9999'      SBTS00
    ...      ${stream_list}[0]
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${steam}/${scf_path}
    robot_common_operations.Common Suite Teardown
    [Teardown]  Selenium Logout And Close Browser

UE attach and Start L3 call
    [Arguments]    ${data_transfer_dl}=300    ${data_transfer_ul}=20    ${duration}=120    ${Expected_avg_percent}=0.5
    ...      ${Expected_min_percent}=0.3      ${ue_index}=${0}      ${apn_address}=dxdata1      ${ue_mode}=NSA
    ...     ${log_type}=Aasyslog      ${attach_mode}=5G_NSA
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...      attach_mode=${attach_mode}      log_type=${log_type}
    power_ue.Verify attach      ue_type=${ue_type}    ue_index=${ue_index}
    ${start_traffic_duration}    evaluate    ${duration}+${120}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}      apn_address=${apn_address}
    ...    ue_mode=${ue_mode}      dt_name=DT_dl_0
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}      apn_address=${apn_address}
    ...    ue_mode=${ue_mode}      dt_name=DT_ul_0
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    check_source=${log_type}
    Wait Until Keyword Succeeds       5min      30s      Connect to gnb coam via ssl      connection=GNB_OAM
    ${cell_mapping}=      Get Relation Mapping Between Cell Index And NrCellIdentity      connection_alias=GNB_OAM
    ${cell_id} =      convert to string    ${cell_mapping[${1}]['nrCellIdentity']}
    ${cell_id}=       Create List       ${cell_id}
    log to console    \n***check log***
    power_ue.Check Bi Tput    ue_type=${ue_type}    cells=${cell_id}      ultarget_throughput=${data_transfer_ul}
    ...      log=${tput_log}      dltarget_throughput=${data_transfer_dl}      target_avg_percent=${Expected_avg_percent}
    ...      min_percent=${Expected_min_percent}
    [teardown]    Stop traffic and UE detach      ue_type=${ue_type}      ue_index=${ue_index}

Stop traffic and UE detach
    [arguments]    ${ue_type}      ${ue_index}=${0}
    Run Keyword And Ignore Error      power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    Run Keyword And Ignore Error     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    Run Keyword And Ignore Error      power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Change CABLINK Link Speed to eCPRI10
    [Arguments]       ${version}
    Selenium Coam Login And Disable Screen Lock
    ...      download_dir=${TS_CASE_LOG_PATH}
    ...      url=https://${tl.gnbs[${0}].cu.oam_http_connection_details.addr}/
    ...      username=${tl.gnbs[${0}].cu.oam_http_connection_details.username}
    ...      password=${tl.gnbs[${0}].cu.oam_http_connection_details.password}
    ...      version=${version}
    ${object_list}    selenium_coam.get_object_name_list    object_name=CABLINK-
    ${object_num}   Get Length   ${object_list}
    set test variable   ${change_counter}   ${0}
    FOR  ${object_id}  IN RANGE    1   ${object_num+1}
            ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${object_id}
            ...   filter_param=Link speed    abbr=linkSpeed
            Run Keyword If    '${currect_status}'=='eCpri25'   Run keywords    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${object_id}
            ...    filter_param=Link speed    abbr=linkSpeed
            ...    new_value=eCpri10    node_index=${0}  AND
            ...    set test variable   ${change_counter}   ${change_counter+1}
    END
    Run Keyword If    ${change_counter}>0   Run keywords   selenium_coam.validate_plan   AND
    ...   selenium_coam.activate_plan   AND
    ...   Sleep  5min   AND
    ...   Wait until keyword succeeds    10min    30s    Verify all cells should be onair
    [Teardown]    RUN keywords      Selenium Coam Logout And Close Browser
    ...      AND      COAM Teardown gnb connections
