*** Settings ***
Documentation    Auther:Stella.lin@nokia-sbell.com

Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/fiberswitch_common.robot
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.config.scf    WITH NAME    scf
Library    taf.analyzer.pcap    WITH NAME    cap
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    taf.analyzer.pcap     WITH NAME    cap
Variables   5GC001795_variables.py

*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}
${nrbts_id}    ${tl.gnbs[0].global_bts_id}
${DATA_TIME}    99999999
${DATA_LENGTH}    1400
${ASIK_MASTER_ALIAS}    ASIK Master
${ABIL_MASTER_ALIAS}    ABIL Master
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_7319}    faultId=${7319}
&{fault_7300}    faultId=${7300}
&{fault_9000}    faultId=${9000}
&{fault_1981}    faultId=${1981}
&{fault_6450}    faultId=${6450}
&{fault_4592}    faultId=${4592}
&{fault_10}    faultId=${10}
&{fault_1901}    faultId=${1901}
@{FAULT_ID_LIST}   &{fault_6450}
@{HISTORY_FAULT_ID_LIST}    &{fault_10}    &{fault_1901}

*** Keywords ***
Recommission With Backup SCF File
    [Arguments]    ${backup_scf_file}    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${backup_scf_file}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.

Get Rnti From BIP
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    ...                [PRIVATE]
    [Arguments]    ${bip_log}    ${luashark_path}=/home/ute/luashark/luashark.lua
    cap.Read Cap    cap_file=${bip_log}    display_filter=uldata_puschreceiverespharqu    X=lua_script:${luashark_path}
    ${condition}=     catenate     UlData_PuschReceiveRespHarqU.grants_item_7.crc == 0x00
    ...               and  UlData_PuschReceiveRespHarqU.grants_item_7.dtx == 0x00
    ${rnti_list} =    cap.Get Element Value    element_expression=UlData_PuschReceiveRespHarqU.grants_item_7.rnti
    ...    element_idx=${0}
    ...    default_value=True
    ...    condition_expression= ${condition}
    [Return]    ${rnti_list}[0]

Perform BTS Power Off
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${model}=HBTE
    ${bts_pdu_ip}=  set variable  ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.addr}
    ${bts_pdu_port}=  set variable  ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${bts_pdu_ip}    alias=bts
    pdu.power_off    port=${bts_pdu_port}    pdu_device=bts

Perform BTS Power On
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${model}=HBTE
    ${bts_pdu_ip}=  set variable  ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.addr}
    ${bts_pdu_port}=  set variable  ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${bts_pdu_ip}    alias=bts
    pdu.power_on    port=${bts_pdu_port}    pdu_device=bts

SISO Verify Fault 10 For RU_${ru_index}
    ${ru_info}      COAM get ru detial info by ru index    ru_index=${ru_index}
    ${RMOD_R}    Set Variable    ${ru_info['id']['runtime'].split('/')}[-1]
    ${fault_10_for_RU}    Create Dictionary     faultId=${10}   source=${RMOD_R}
    Perform RU Power Off    ru_index=${ru_index}
    Wait Until Keyword Succeeds     90 sec    3 sec    RU Should Be Power Off    ru_index=${ru_index}
    Wait For Expect Fault Present   faultId=${10}   source=${RMOD_R}  timeout=120
    @{allowed_faults}   Create List   @{ALLOWED_FAULT}   ${fault_10_for_RU}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    ${cell_group_index}    Evaluate    ${ru_index}-${1}
    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_index}
    Perform RU Power On    ru_index=${ru_index}
    Wait For Expect Fault To Disappear   faultId=${10}  source=${RMOD_R}   timeout=600
    Wait Until Keyword Succeeds    240 sec    5 sec    RU Should Be Online
    Wait Until Keyword Succeeds    600 sec    5 sec    Cell Should Be Enabled    cell_idx=${ru_index}   cell_group_idx=${cell_group_index}
    Wait Until Keyword Succeeds    60 sec    5 sec     COAM Check GNB cell on air
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}

1795 Suite SetUp
    [Arguments]    ${scf_file_name}=${None}    ${ru_num}=1    ${ru_type}=AZQG    ${scf_path}=/home/ute/SCF
    ...            ${is_pdl_checking_needed}=${True}   ${asik_alais}=ASIK Master
    COAM Create log directory    is_set_to_test_case_level=${False}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${asik_alais}
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...                                                               file_path=${SUITE_LOG_PATH}
    ${scf_file_name}    Get SCF File Name based on stream version    scf_file_name=${scf_file_name}
    ${scf_file}    Join Path    ${scf_path}    ${scf_file_name}
    run keyword if  not '${scf_file_name}'=='${None}'    Recommission With Backup SCF File    backup_scf_file=${scf_file}
    ...                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    ${status}    ${result}    Run Keyword And Ignore Error     COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    run keyword if  not '${status}'=='PASS'    Run Keywords    Perform BTS Power Off    AND
    ...                                                sleep  10 sec    AND
    ...                                                Perform BTS Power On    AND
    ...    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Verify All Used RU Type    ru_num=${ru_num}    ru_type=${ru_type}
    run keyword and ignore error    COAM Teardown gnb connections

Get SCF File Name based on stream version
    [Documentation]    Author: Jia Lei
    ...                Description: return SBTS_${scf_file_name} for common build.
    ...                             for 0.800 release, return original ${scf_file_name}.
    ...                             for common build, use SBTS_${scf_file_name}.
    [Arguments]      ${scf_file_name}=${None}
    ...               ${connection}=GNB_OAM
    ${sw_release_name}    coam.get_sw_release_name    connection=${connection}
    ${scf_file_name} =    set variable if    'SBTS' in '${sw_release_name}'    SBTS_${scf_file_name}    ${scf_file_name}
    [Return]    ${scf_file_name}

1795 Suite TearDown
#    [Arguments]    ${scf_file_name}=Configuration_3sector_4x4_80.xml    ${scf_path}=/home/ute/SCF
#    ${scf_file}    Join Path    ${scf_path}    ${scf_file_name}
#    Connect to gnb coam via ssl
#    Run Keyword And Ignore Error    Recommission With Backup SCF File    backup_scf_file=${scf_file}
    Run Keyword And Ignore Error    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    run keyword and ignore error    COAM Teardown gnb connections

1795 Case SetUp
    [Arguments]    ${ru_num}=1    ${hw_slot}=${1}
    ${asik_connect_status}    Run Keyword And Return Status    Connect to Common Unit Master
    run keyword if  not ${asik_connect_status}    Run Keywords    Perform BTS Power Off    AND
    ...                                                      sleep  10 sec    AND
    ...                                                      Perform BTS Power On
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${ru_detect_status}    ${result}    Run Keyword And Ignore Error    COAM Check GNB RU Status
    run keyword if  not '${ru_detect_status}'=='PASS'    Run Keywords    Power Off For All RU    ru_num=${ru_num}    AND
    ...                                                      sleep  20 sec    AND
    ...                                                      Power On For All RU    ru_num=${ru_num}
    COAM Create log directory
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    Connect to Capacity Unit Slave    hw_slot=${hw_slot}
    run keyword and ignore error    Connect to Capacity Unit Loner    hw_slot=${hw_slot}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error   Connect to gnb coam via ssl

1795 Case TearDown
    [Arguments]    ${case_contain_special_operation}=${False}
#    Run Keyword And Ignore Error   Run Keyword If Test Failed      COAM Save snapshot via rest api    timeout=900
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    @{ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_ID_LIST}
    run keyword and continue on failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    run keyword if    ${case_contain_special_operation}
    ...              Run Keyword And Ignore Error   Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    ...              ELSE
    ...              run keyword and continue on failure    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    CI_interface.Common Case Teardown

Reconnection For gnb Alais
    [Arguments]    ${hw_slot}=${1}
    Connect to Common Unit Master
    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    Connect to Capacity Unit Slave    hw_slot=${hw_slot}
    Run Keyword And Ignore Error    Connect to Capacity Unit Loner    hw_slot=${hw_slot}
    Connect to RU With Allocated IP

Power Off For All RU
    [Arguments]    ${ru_num}=1
    FOR  ${index}    IN RANGE    ${ru_num}
        ${index}    Evaluate    ${index}+${1}
        ${status}    Run Keyword And Return Status     Perform RU Power Off    ru_index=${index}    model=HBTE
        run keyword if  not ${status}    Log    Power Off RU_${index}  failed.
    END

Power On For All RU
    [Arguments]    ${ru_num}=1
    FOR  ${index}    IN RANGE    ${ru_num}
       ${index}    Evaluate    ${index}+${1}
       ${status}    Run Keyword And Return Status     Perform RU Power On    ru_index=${index}    model=HBTE
       run keyword if  not ${status}    Log    Power On RU_${index}  failed.
    END

Check Tddtimer File From RF
    [Arguments]    ${alias}=RU
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to RU With Allocated IP
    ${info} =   Set Variable    No such file or directory
    FOR  ${index}    IN RANGE    ${3}
         ${output1} =    csn.execute      command=ls -l /mnt/factory/configs/unit/tddtimer.conf     connection=${alias}
         ${status} =    Run Keyword And Return Status    Should Not Contain    ${output1}    ${info}
         Return From Keyword If  ${status}==${False}
         Delete Tddtimer File From RF
    END
#   [Teardown]  Run Keyword And Ignore Error   csn.disconnect   connection=${alias}

Upload Tddtimer File To RF
    [Arguments]    ${path}    ${alias}=RU
#    Connect to RU With Allocated IP
    ${output1} =    csn.execute      command=ls -l /mnt/factory/configs/unit/tddtimer.conf     connection=${alias}
    ${info} =   Set Variable    No such file or directory
    ${status} =    Run Keyword And Return Status    Should Not Contain    ${output1}    ${info}
    Run Keyword If    ${status}==${False}    WAIT UNTIL KEYWORD SUCCEEDS    3 min     6 sec
    ...  csn.upload file     local_path=${path}     remote_path=/mnt/factory/configs/unit/tddtimer.conf    connection=${alias}
    csn.send command      command=cd /mnt/factory/configs/unit;sync     connection=${alias}
    csn.send command      command=cd /mnt/factory/configs/unit;sync     connection=${alias}
    csn.send command      command=cd /mnt/factory/configs/unit;sync     connection=${alias}
#    [Teardown]  Run Keyword And Ignore Error   csn.disconnect   connection=${alias}

Delete Tddtimer File From RF
    [Arguments]    ${alias}=RU
#    Connect to RU With Allocated IP
    csn.execute    command=rm /mnt/factory/configs/unit/tddtimer.conf    connection=${alias}
    csn.send command      command=cd /mnt/factory/configs/unit;sync     connection=${alias}
    csn.send command      command=cd /mnt/factory/configs/unit;sync     connection=${alias}
    csn.send command      command=cd /mnt/factory/configs/unit;sync     connection=${alias}

Verify RRH L3 Call With Qualcomm With Aasyslog
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}=5M
    ...           ${dl_data_transfer}=40M
    ...           ${expect_ul_tput}=2.5
    ...           ${expect_dl_tput}=23.3
    ...           ${expect_ul_bler}=0.03
    ...           ${duration}=180
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${hw_slot}=${1}
    ...           ${ue_type}=Andriod
    ...           ${is_ulbler_calcu}=${True}
    ...           ${reset_sol}=ue_reboot
    ...           ${connection}=ASIK Master
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${cellid}=1
    ...           ${is_wireshark_log_capture}=${False}
    ...           ${iperf_type}=via_app
    ...           ${is_askey_used}=False
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${protocol}=udp
    ...           ${hwcheck_index}=${1}
    ...           ${is_do_require_ue}=${True}
    ${duration}    Convert To Integer    ${duration}
    ${expect_ul_tput}    Convert To Number    ${expect_ul_tput}
    ${expect_dl_tput}    Convert To Number    ${expect_dl_tput}
    ${expect_bler}    Convert To Number    ${expect_ul_bler}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    run keyword and ignore error    csn.disconnect    connection=${connection}
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    connection_alias_store.Connect to Common Unit Master
    ${wireshark_log_path_on_testPC}    Start UE Attach With Power UE    reset_sol=${reset_sol}
    ...                              ue_index=${ue_index}
    ...                              4G_check=${4G_check}
    ...                              is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                              is_askey_used=${is_askey_used}
    ...                              hwcheck_index=${hwcheck_index}
    ...                              is_do_require_ue=${is_do_require_ue}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    Run Keyword And Ignore error    Check Iperf Progress on APP server
    Start L3 Call With Power UE       ul_data_transfer=${ul_data_transfer}
    ...                               dl_data_transfer=${dl_data_transfer}
    ...                               ue_index=${ue_index}
    ...                               iperf_type=${iperf_type}
    ...                               protocol=${protocol}
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         expect_ul_bler=${expect_ul_bler}
    ...                         duration=${duration}
    ...                         download_dir=${download_dir}
    ...                         hw_slot=${hw_slot}
    ...                         is_ulbler_calcu=${is_ulbler_calcu}
    ...                         cellid=${cellid}
    ...                         ignore_time=${ignore_time}
    ...                         target_avg_percent=${target_avg_percent}
    ...                         actCarrierAggregation=${actCarrierAggregation}
    ...                         list_all_cell_ids=${list_all_cell_ids}
#    Run Keyword If    not ${status}    Run Keyword And Continue On Failure    Fail    msg=Tput not reach the target!
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...            protocol=${protocol}

Check Iperf Progress on APP server
    Log to console    \nCheck Iperf Progress on APP server
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.send_command    command=ps -ef | grep iperf     connection=APPserver    timeout=120
    ${output}    csn.read_output    size=1000    connection=APPserver
    ${iperf_tput} =    get regexp matches    ${output}    \\b(\\d+)M\\b
    ${tput_num}=      get length     ${iperf_tput}
    ${total_iperf_traffic}    run keyword if    ${tput_num}
    ...    Get Total Iperf traffic on Appserver    iperf_tput=${iperf_tput}
    ...    ELSE    set variable    0
    Log to console    \nTotal traffic on Appserver is: ${total_iperf_traffic}M!
    [Teardown]    csn.disconnect    connection=APPserver

Get Total Iperf traffic on Appserver
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${iperf_tput}
    @{iperf_value_list}    create list
    FOR  ${item}  IN   @{iperf_tput}
        ${item}    Remove String    ${item}    M
        ${integer_item}    convert to integer    ${item}
        append to list    ${iperf_value_list}    ${integer_item}
    END
    ${total_iperf_traffic} =    evaluate    sum(${iperf_value_list})
    [Return]    ${total_iperf_traffic}

Verify RRH L3 Call With Qualcomm
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}=5M
    ...           ${dl_data_transfer}=40M
    ...           ${expect_ul_tput}=2.5
    ...           ${expect_dl_tput}=23.3
    ...           ${expect_ul_bler}=0.03
    ...           ${duration}=180
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${hw_slot}=${1}
    ...           ${ue_type}=Andriod
    ...           ${reset_sol}=ue_reboot
    ...           ${is_ulbler_calcu}=${True}
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${cellid}=1
    ...           ${is_wireshark_log_capture}=${False}
    ...           ${iperf_type}=via_app
    ...           ${is_askey_used}=False
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${protocol}=udp
    ...           ${hwcheck_index}=${1}
    ...           ${is_do_require_ue}=${True}
    ${wireshark_log_path_on_testPC}    Verify RRH L3 Call With Qualcomm With Aasyslog    ul_data_transfer=${ul_data_transfer}
    ...                                                                                  dl_data_transfer=${dl_data_transfer}
    ...                                                                                  expect_ul_tput=${expect_ul_tput}
    ...                                                                                  expect_dl_tput=${expect_dl_tput}
    ...                                                                                  expect_ul_bler=${expect_ul_bler}
    ...                                                                                  duration=${duration}
    ...                                                                                  download_dir=${download_dir}
    ...                                                                                  hw_slot=${hw_slot}
    ...                                                                                  ue_type=${ue_type}
    ...                                                                                  reset_sol=${reset_sol}
    ...                                                                                  is_ulbler_calcu=${is_ulbler_calcu}
    ...                                                                                  ue_index=${ue_index}
    ...                                                                                  4G_check=${4G_check}
    ...                                                                                  cellid=${cellid}
    ...                                                                                  is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                                                                  iperf_type=${iperf_type}
    ...                                                                                  is_askey_used=${is_askey_used}
    ...                                                                                  protocol=${protocol}
    ...                                                                                  hwcheck_index=${hwcheck_index}
    ...                                                                                  cellid=${cellid}
    ...                                                                                  ignore_time=${ignore_time}
    ...                                                                                  target_avg_percent=${target_avg_percent}
    ...                                                                                  actCarrierAggregation=${actCarrierAggregation}
    ...                                                                                  list_all_cell_ids=${list_all_cell_ids}
    ...                                                                                  is_do_require_ue=${is_do_require_ue}
    [Return]    ${wireshark_log_path_on_testPC}

Get UE Type From init File
    [Documentation]   Author: xiaoxia.hao@nokia-sbell.com
    ${ue_type}    translate_power_ue_type_from_testline
    set suite variable    ${ue_type}

Check RU Calibration Status And Power
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.10    ${asik_connection}=ASIK Master    ${retry_time}=3
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
            Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}
            ...    asik_alias=${asik_connection}   connection=${connection}
           Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
           ...    Check RU Calibration Status    ru_alias=RU${ru_index}
           run keyword if    "AZQ" in "${tl.gnbs[0].dus[0].rus[0].radio_type}"    Check AZGX RU Power on DFE   ru_alias=RU${ru_index}
           ...    ELSE
           ...             Check RU Power on DFE    ru_alias=RU${ru_index}    ru_dfe_ip=${ru_dfe_ip}
           csn.Disconnect  connection=RU${ru_index}
    END
   [Teardown]  COAM Teardown gnb connections

Check RU Calibration Status And Power on Specifc RU
    [Documentation]  Author: Zhou xiangyue
    ...                updated 2021.07.12: Jia Lei check RU calibration based on ru type or ru index
    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.10    ${asik_connection}=ASIK Master
    ...    ${retry_time}=3    ${ru_index}=1    ${ru_type}=${None}    ${dual_alias}=MultiRAT GNB Master
    ...    ${is_dualasik_used}=False    ${dualcore_hostname}=fct4s0icom.local
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    run keyword if    ${is_dualasik_used}    Connect To MultiRAT GNB Common Unit Master    hostname=${dualcore_hostname}
    ${asik_connection}    set variable if    ${is_dualasik_used}    ${dual_alias}    ${asik_connection}
    ${container_id}    set variable if    ${is_dualasik_used}    ${0x1018}    ${0x2018}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    ${specific_ru_index_list}    run keyword if    '${ru_type}'!='${None}'     Get RU index based on RU type
    ...    connection=${connection}    ru_type=${ru_type}
    ${ru_list}    set variable if     '${ru_type}'!='${None}'    ${specific_ru_index_list}    ${ru_index}
    FOR    ${ru_index}    IN    @{ru_list}
            Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}
            ...    asik_alias=${asik_connection}   connection=${connection}    container_id=${container_id}
           Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
           ...    Check RU Calibration Status    ru_alias=RU${ru_index}
           run keyword if    "AZQ" in "${tl.gnbs[0].dus[0].rus[0].radio_type}"    Check AZGX RU Power on DFE   ru_alias=RU${ru_index}
           ...    ELSE
           ...             Check RU Power on DFE    ru_alias=RU${ru_index}    ru_dfe_ip=${ru_dfe_ip}
           csn.Disconnect  connection=RU${ru_index}
    END
   [Teardown]  COAM Teardown gnb connections

Get RU index based on RU type
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=GNB_OAM    ${ru_type}=${None}
    @{specific_ru_index_list}    create list
    ${ru_index_list}  Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
            ${radio_type}    get ru type  ru_index=${ru_index}
            run keyword if    '${radio_type}'=='${ru_type}'    append to list    ${specific_ru_index_list}    ${ru_index}
    END
    [Return]    ${specific_ru_index_list}

Check RU Calibration Status
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${carrier_name}=NR
    ${calibration_output}    csn.execute    command=bfcali -stat    connection=${ru_alias}
    ${nr_calibration}    Split String From RU Calibration Output    calibration_output=${calibration_output}
    Get RU Calibration Value And Compare    nr_calibration=${nr_calibration}

Split String From RU Calibration Output
    [Documentation]  Author: Jia Lei
    [Arguments]    ${calibration_output}    ${carrier_name}=NR    ${sperator}=\r\n\r\n
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    [Return]    ${nr_calibration}

Get RU Calibration Value And Compare
    [Documentation]  Author: Jia Lei
    [Arguments]    ${nr_calibration}
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           should be equal   ${attempt_count}    ${success_count}
    END

Check RU Power on DFE
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.10    ${ru_dfe_alias}=ru_dfe
    ...    ${all_attenna_ports}=8
    csn.connect to    hostname=${ru_dfe_ip}
    ...               username=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...               alias=${ru_dfe_alias}
    ...               proxy=${ru_alias}
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        ${dfe_power_output}    csn.execute    command=dapd -stat ${index}    connection=${ru_dfe_alias}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  csn.Disconnect  connection=${ru_dfe_alias}

Get HW Slot ID From TL
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=ASIK Master
    Connect to Common Unit Master    alias=${connection}
    ${is_asib}    If ASIB card used
    Run keyword if    '${is_asib}'=='${False}'    Get HW Slot ID For ASIK    connection=${connection}
    ...    ELSE    log    ASIB is used!
   [Teardown]  csn.Disconnect  connection=${connection}

Get HW Slot ID For ASIK
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=ASIK Master
    ${arp_output}    csn.execute    command=arp -a    connection=${connection}
    ${hwslot_regexp}    set variable    fsp-.*(\\d+)a
    ${hwslot_id}    Get Regexp Matches    ${arp_output}    ${hwslot_regexp}    1
    Sort List       ${hwslot_id}
    ${hw_slot}    convert to integer    ${hwslot_id}[0]
    set suite variable    ${hw_slot}

Synchronization Holdover Support
    [Documentation]  Author: Jia Lei
    [Arguments]    ${connection}=GNB_OAM    ${normal_tuning_mode}=Normal tuning
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${sync_source_org}    coam_parameter.get_single_value_from_scf_file    parameter=syncInputType
    ...                           dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                           connection=${connection}
    set test variable    ${sync_source_org}
    Verify BTS Sync Source And Tuning Mode    sync_type=${sync_source_org}    tuning_mode=${normal_tuning_mode}
    Modify BTS Sync Source to Tirgger Holdover status   connection=${connection}
    ${allowed_faults}   Create List   @{GNB_ALLOWED_FAULT}    ${fault_1899}
    sleep    5min
    Recover Sync Status to Normal state    sync_type=${sync_source_org}    connection=${connection}
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Run Keyword And Continue On Failure    Wait For Expect Fault To Disappear
    ...    faultId=${1899}    source=SMOD_R-1    timeout=600    connection=${connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    ...                                                                       connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Verify BTS Sync Source And Tuning Mode
    [Arguments]    ${connection}=GNB_OAM    ${tuning_mode}=Normal tuning
    ...    ${sync_type}==1pps/ToD from external GNSS receiver
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${active_sync_dict}=    Get BTS Active Sync Source     alias=${connection}    tuning_mode=${tuning_mode}
    ${sync_output}            Get From Dictionary                  ${active_sync_dict}         syncInputType
    should be equal as strings           ${sync_output}           ${sync_type}

Modify BTS Sync Source to Tirgger Holdover status
    [Documentation]  Author: Jia Lei
    [Arguments]    ${tuning_mode}=holdover    ${connection}=GNB_OAM
    @{syncinput_type_value}    create list
    ${syncinput_type}    create dictionary    syncInputType=2.048MHz input
    Append To List    ${syncinput_type_value}    ${syncinput_type}
    &{sync_input_type_modify}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                                               parameter=syncInputList
    ...                                               value=${syncinput_type_value}
    @{sync_input_type_modify}    Create List     ${sync_input_type_modify}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${sync_input_type_modify}    timeout=900
    wait until keyword succeeds    10min    1min    Check Sync status is Holdover state    tuning_mode=${tuning_mode}    connection=${connection}

Check Sync status is Holdover state
    [Arguments]    ${tuning_mode}=holdover    ${connection}=GNB_OAM
    [Documentation]    Author: Jia Lei
    ...      Get Sync Status from BTS
    ...     tuning_mode:  BTS Sync status i.e Normal or Holdover
    ...     alias:   AdminConnection object or if used, string name alias
    ${bts_sync_status}       coam.get_bts_sync_source_status      connection=${connection}
    ${bts_tuningMode}        Get From Dictionary                  ${bts_sync_status}         tuningMode
    should contain          ${bts_tuningMode}                    ${tuning_mode}

Recover Sync Status to Normal state
    [Documentation]  Author: Jia Lei
    [Arguments]    ${tuning_mode}=Normal tuning     ${connection}=GNB_OAM    ${sync_type}=1pps/ToD from external GNSS receiver
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    @{syncinput_type_value}    create list
    ${syncinput_type}    create dictionary    syncInputType=${sync_type}
    Append To List    ${syncinput_type_value}    ${syncinput_type}
    &{sync_input_type_para}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                                               parameter=syncInputList
    ...                                               value=${syncinput_type_value}
    @{sync_input_type_para}    Create List     ${sync_input_type_para}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${sync_input_type_para}    timeout=900
    wait until keyword succeeds    10min    1min    Check Sync status is Holdover state    tuning_mode=${tuning_mode}    connection=${connection}


Perform RU Reset From Admin CLI
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：perform ru reset from admin cli.
    [Arguments]    ${ru_index}=1    ${connection}=enblte    ${mrbts_index}=${tl.gnbs[0].instance_id}
    ${RU_dn}=     Catenate    /MRBTS-${mrbts_index}/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    enblte.reset_unit        dist_name=${RU_dn}
    ...                      reset_type=Hard
    ...                      force_radio_reset=True
    ...                      timeout=900
    ...                      connection=${connection}

General RF Module Reset From LTE
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：Performing an RRU reset from LTE side (Master Node) triggers the same RRU to be lost on gNB side.
    ...                            While LTE side is on "Initializing" state, No Connection to Unit alarm came up on gNB side.
    [Arguments]    ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${0}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}     connection=${enb_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${enb_connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Perform RU Reset From Admin CLI    ru_index=${ru_index}    connection=${enb_connection}
        run keyword and ignore error    Wait Until Keyword Succeeds
        ...    3 min    15 sec    RU Should Be Offline    ru_index=${ru_index}    connection=${enb_connection}
    END
    Connect to gnb coam via ssl    connection=${gnb_connection}
    ${GNB_ALLOWED_FAULT}   Create List   @{GNB_ALLOWED_FAULT}   ${fault_10}
    run keyword and ignore error    Wait For Expect Fault Present   faultId=${10}   timeout=180    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${gnb_connection}
    Wait until keyword succeeds    15 min    30 sec    Check enb status is in cell on air status
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    connection=${enb_connection}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Enblte close down    AND
                   ...             Run Keyword And Ignore Error    COAM Teardown gnb connections

Get Fiberswitch Channel Number For GNB RU
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 port 15 and 16, used for gnb RU. port 13 and 14 for concurrent enb.
    @{channel_number}    create list    2   3
    [Return]    ${channel_number}

Get Fiberswitch Channel Number For ENB RU
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 port 15 and 16, used for gnb RU. port 13 and 14 for concurrent enb.
    @{channel_number}    create list    0    1
    [Return]    ${channel_number}

Set Fiber Switch Into linkup
    [Documentation]    Connects to optical switch and sets switch into operational position for given radio.
    [Arguments]    ${channel_numbers}
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    &{linkup_setting}    create dictionary
    FOR    ${n}    IN    @{channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${channel_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].channel_no}
         ${in_port}    Convert To String    ${module_no}
         ${out_port}    Convert To String    ${channel_no}
         Set To Dictionary    ${linkup_setting}    ${in_port}=${out_port}
    END
    Switch RU And Verify Connection State    connection=${linkup_setting}

Set Fiber Switch Into link_failure
    [Documentation]    Connects to optical switch and sets switch into link failure position for given radio.
    [Arguments]    ${channel_numbers}
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    ...             ${dummy_output_channel}=00
    &{link_failure_settings}    create dictionary
    FOR    ${n}    IN    @{channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${in_port}    Convert To String    ${module_no}
         Set To Dictionary    ${link_failure_settings}    ${in_port}=${dummy_output_channel}
    END
    Switch RU And Verify Connection State    connection=${link_failure_settings}

4G_Site_eCPRI_link_failure_break_2mins_recovery
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：Performing ecpri link failure on eNB side with concurrent mode.
    ...                           While ENB side is in fault10 state, Cell is still on air gNB side.
    ...                           step1: Enb cell on air
    ...                           step2: cable link break, Check alarm ： faultid 10 should be in active alarm
    ...                           step3: Wait for 3 minutes, Cable link  recover, cells are onair with No unexpected active alarms
    [Arguments]    ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${1}    ${ru_index}=${1}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}     connection=${enb_connection}
    Log To Console    \n\tSet Fiber Switch Into link_failure
    ${enb_used_channel}    Get Fiberswitch Channel Number For ENB RU
    Set Fiber Switch Into link_failure    channel_numbers=${enb_used_channel}
    ${ENB_ALLOWED_FAULT}   Create List   ${ALLOWED_FAULT}   ${fault_10}
    Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${10}   timeout=300    connection=${enb_connection}
    ...    is_need_to_setup_gnb_connection=${False}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ENB_ALLOWED_FAULT}    connection=${enb_connection}
    ${status}=    run keyword and return status    Wait For Expect Fault Present   faultId=${10}   timeout=180    connection=${gnb_connection}
    run keyword if    ${status}    Run Keyword And Continue On Failure    Fail    msg=\n\tFault 10 appears on concurretn gnb!\n
    Log To Console    \n\tSet Fiber Switch Into link_up
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ENB_ALLOWED_FAULT}    connection=${enb_connection}
    Set Fiber Switch Into linkup    channel_numbers=${enb_used_channel}
    Run Keyword And Continue On Failure    Wait For Expect Fault To Disappear   faultId=${10}  timeout=600    connection=${enb_connection}
    ...    is_need_to_setup_gnb_connection=${False}
    Wait Until Keyword Succeeds    300 sec    3 sec    RU Should Be Online    ru_index=${ru_index}    connection=${enb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${gnb_connection}
    Wait until keyword succeeds    15 min    30 sec    Check enb status is in cell on air status
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    connection=${enb_connection}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${gnb_connection}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Set Fiber Switch Into linkup    channel_numbers=${enb_used_channel}    AND
                   ...             Run Keyword And Ignore Error    Enblte close down    AND
                   ...             Run Keyword And Ignore Error    COAM Teardown gnb connections

5G_Site_eCPRI_link_failure_break_2mins_recovery
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：Performing ecpri link failure on gNB side with concurrent mode.
    ...                           While GNB side is in fault10 state, Cell is still on air ENB side.
    ...                           step1: Gnb cell on air
    ...                           step2: cable link break, Check alarm ： faultid 10 should be in active alarm, no alarm on enb.
    ...                           step3: Wait for 3 minutes, Cable link  recover, cells are onair with No unexpected active alarms
    [Arguments]    ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${1}    ${ru_index}=${1}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}     connection=${enb_connection}
    Log To Console    \n\tSet Fiber Switch Into link_failure
    ${gnb_used_channel}    Get Fiberswitch Channel Number For GNB RU
    Set Fiber Switch Into link_failure    channel_numbers=${gnb_used_channel}
    ${GNB_ALLOWED_FAULT}   Create List   ${GNB_ALLOWED_FAULT}   ${fault_10}
    Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${10}   timeout=300    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    Wait Until Keyword Succeeds    300 sec    3 sec    RU Should Be Online    ru_index=${ru_index}    connection=${enb_connection}
    Wait until keyword succeeds    15 min    30 sec    Check enb status is in cell on air status
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    connection=${enb_connection}
    ${status}=    run keyword and return status    Wait For Expect Fault Present   faultId=${10}   timeout=180    connection=${enb_connection}
    ...    is_need_to_setup_gnb_connection=${False}
    run keyword if    ${status}    Run Keyword And Continue On Failure    Fail    msg=\n\tFault 10 appears on concurretn enb!\n
    Log To Console    \n\tSet Fiber Switch Into link_up
    Set Fiber Switch Into linkup    channel_numbers=${gnb_used_channel}
    Wait For Expect Fault To Disappear   faultId=${10}  timeout=600    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    connection=${enb_connection}
    Wait Until Keyword Succeeds    600 sec    3 sec    RU Should Be Online    ru_index=${ru_index}    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${gnb_connection}
    Wait until keyword succeeds    15 min    30 sec    Check enb status is in cell on air status
    ${ALLOWED_HISTORY_FAULT}   Create List   ${ALLOWED_HISTORY_FAULT}   ${fault_10}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${gnb_connection}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Set Fiber Switch Into linkup    channel_numbers=${gnb_used_channel}    AND
                   ...             Run Keyword And Ignore Error    Enblte close down    AND
                   ...             Run Keyword And Ignore Error    COAM Teardown gnb connections


5G_Site_eCPRI_link_failure_break_2mins_recovery 10 times with L3 call
    [Documentation]  Author: Jia Lei
    ...               This case is used to test link failure and recovery 10 times
    ...               loop 10 TIMES link up and down, then L2 call
    FOR    ${count}    IN RANGE    10
        run keyword and continue on failure    5G_Site_eCPRI_link_failure_break_2mins_recovery_non_RFS
    END
    Verify RRH L3 Call With Qualcomm    ul_data_transfer=50M
    ...                                 dl_data_transfer=800M
    ...                                 expect_ul_tput=27
    ...                                 expect_dl_tput=670
    ...                                 duration=240
    ...                                 is_ulbler_calcu=${False}
    ...                                 is_do_require_ue=${False}

5G_Site_eCPRI_link_failure_break_2mins_recovery_non_RFS
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：Performing ecpri link failure on gNB side with single mode
    ...                           step1: Gnb cell on air
    ...                           step2: cable link break, Check alarm ： faultid 10 should be in active alarm, ru auto reset.
    ...                           step3: Wait for 3 minutes, Cable link recover, cells are onair with No unexpected active alarms
    [Arguments]    ${gnb_connection}=GNB_OAM    ${ru_index}=${1}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    Log To Console    \n\tSet Fiber Switch Into link_failure
    Set Fiber Switch Into link_failure For RU on Mitron
    ${GNB_ALLOWED_FAULT}   Create List   ${ALLOWED_FAULT}   ${fault_10}
    Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${10}   timeout=300    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    sleep    60 sec
    Log To Console    \n\tSet Fiber Switch Into link_up
    Set Fiber Switch Into linkup For RU
    Wait For Expect Fault To Disappear   faultId=${10}  timeout=600    connection=${gnb_connection}
    Wait Until Keyword Succeeds    600 sec    3 sec    RU Should Be Online    ru_index=${ru_index}    connection=${gnb_connection}
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    connection=${gnb_connection}
    ${ALLOWED_HISTORY_FAULT}   Create List   ${ALLOWED_HISTORY_FAULT}   ${fault_10}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${gnb_connection}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Set Fiber Switch Into linkup For RU    AND
                   ...             Run Keyword And Ignore Error    COAM Teardown gnb connections

General_GNSS reset on ENB via Admin CLI
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...     Perform GNSS Reset From Admin CLI on enb side, as enb sync from external gnss.
    ...     Reset eNB side GPS. GPS goes grayed out, then comes up in degraded mode
    ...     and finally goes green after a couple of mins. Site remains on air.
    [Arguments]     ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${0}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Wait until keyword succeeds    15 min    30 sec    Check enb status is in cell on air status
    GNSS Should Be Online via Admin CLI    connection=${enb_connection}
    Perform GNSS Reset From Admin CLI    connection=${enb_connection}
    wait until keyword succeeds    5mins    5s    GNSS Should Be Degraded via Admin CLI    connection=${enb_connection}
    Wait until keyword succeeds    5 min    30 sec    Check enb status is in cell on air status
    Wait Until Keyword Succeeds    10min    30s    GNSS Should Be Online via Admin CLI    connection=${enb_connection}
    [Teardown]    run keyword and ignore error    Enblte close down

Perform GNSS Reset From Admin CLI
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：perform ru reset from admin cli.
    [Arguments]    ${connection}=enblte    ${mrbts_index}=${tl.gnbs[0].instance_id}
    ${gnss_dn}=     Catenate    /MRBTS-${mrbts_index}/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
    enblte.reset_unit        dist_name=${gnss_dn}
    ...                      reset_type=Hard
    ...                      force_radio_reset=True
    ...                      timeout=300
    ...                      connection=${connection}

Get GNSS Statuses and Compare
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    [Arguments]    ${state}    ${status}=operationalState    ${connection}=enblte
    ${GNSS_statuses_response}=    enblte.get_gnsses_statuses    connection=${connection}
    ${response}=    Get From Dictionary    ${GNSS_statuses_response['GNSSE_R-1']}    ${status}
    Should Be Equal    ${response}    ${state}

GNSS Should Be Degraded via Admin CLI
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    [Arguments]    ${connection}=enblte
    Get GNSS Statuses and Compare    state=Degraded    status=availabilityStatus    connection=${connection}
    Get GNSS Statuses and Compare    state=Disabled    status=operationalState    connection=${connection}

GNSS Should Be Online via Admin CLI
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    [Arguments]    ${connection}=enblte
    Get GNSS Statuses and Compare    state=Online   status=availabilityStatus    connection=${connection}
    Get GNSS Statuses and Compare    state=Enabled   status=operationalState    connection=${connection}

General_Perform eNB_site_reset
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...     Perform ENB Reset From Admin CLI, LTE site resets and recover while 5G side remains on air.
    ...     update chu xiangsheng : delete expect Alarm 1981, 20B don't raise this alarm.
    [Arguments]    ${enb_connection}=enblte    ${enb_index}=${0}    ${gnb_connection}=GNB_OAM
    Perform ENB Reset From Admin CLI    connection=${enb_connection}    enb_index=${enb_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#	Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${1981}   timeout=180    connection=${gnb_connection}
#	${GNB_ALLOWED_FAULT}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_1981}
	Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
	...    allowed_faults=@{GNB_ALLOWED_FAULT}
    sleep    90s
    run keyword and ignore error    Enblte close down
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Wait until keyword succeeds    15 min    30 sec    Check enb status is in cell on air status
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_FAULT}    connection=${enb_connection}
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min
    [Teardown]    run keyword and ignore error    Enblte close down

Perform ENB Reset From Admin CLI
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...     Perform ENB Reset From Admin CLI
    [Arguments]     ${connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${0}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    enblte.reset_site    wait_for_reconnection=${True}    connection=${connection}    timeout=900
    [Teardown]    run keyword and ignore error    Enblte close down

General SiSo RU Lock Unlock on eNB
   [Documentation]  Author:xiangyue.zhou@nokia-sbell.com
   ...                2020/11/9 Jia Lei: add for loop for several rus on one enb
   ...                Unit Blocked alarm comes up on LTE but 5G stays on air. A "lock" icon shows up on the RRU on 5G.
    [Arguments]     ${enb_mr_bts_id}    ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${0}    ${timeout}=600
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${enb_connection}
    @{ru_list}    Create List
    ${enb_allowed_faults}    Create List    @{ALLOWED_FAULT}    ${fault_48}
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=@{enb_allowed_faults}    connection=${enb_connection}
        enblte.lock_ru    dist_name=MRBTS-${enb_mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    timeout=${timeout}    connection=${enb_connection}
        Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Blocked    ru_index=${ru_index}    connection=${enb_connection}
        run keyword and continue on failure    Wait Until Keyword Succeeds
        ...    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}    connection=${gnb_connection}
        Wait Until Keyword Succeeds    600 sec   5 sec     COAM Check GNB cell on air    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=@{GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    END
    Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${48}   timeout=180    connection=${enb_connection}
    ...    is_need_to_setup_gnb_connection=${False}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{enb_allowed_faults}    connection=${enb_connection}
    FOR    ${ru_index}    IN    @{ru_list}
        enblte.unlock_ru    dist_name=MRBTS-${enb_mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    timeout=${timeout}    connection=${enb_connection}
        Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Unblocked
        ...    ru_index=${ru_index}    connection=${enb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=@{enb_allowed_faults}    connection=${enb_connection}
        run keyword and continue on failure    Wait Until Keyword Succeeds
        ...    240 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${gnb_connection}
        Wait Until Keyword Succeeds    600 sec   5 sec     COAM Check GNB cell on air    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=@{GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    END
    Wait Until Keyword Succeeds    900 sec   30 sec     Check enb status is in cell on air status
    [Teardown]    run keyword and ignore error    Enblte close down

Get all cellids on enb
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${alias}=enblte    ${enb_index}=${0}
    Connect to eNB via ssl    connection=${alias}    enb_index=${enb_index}
    @{MOs}    enblte.get_managed_objects    class_name=LNCEL_A    connection=${alias}
    @{cell_ids}    create list
    FOR    ${MO}    IN    @{MOs}
         ${lncelid}    Fetch from right    ${MO['distName']}    -
        append to list    ${cell_ids}    ${lncelid}
    END
    sort list    ${cell_ids}
    [Teardown]    Enblte close down    connection=${alias}
    [Return]    ${cell_ids}

General SiSo Cell Lock Unlock on eNB
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：Block/Unblock cell from LTE, while NR call is ongoing, verify NR call is continue.
    [Arguments]     ${enb_mr_bts_id}    ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${0}    ${timeout}=600
	Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${cell_id_list}    Get all cellids on enb    alias=${enb_connection}    enb_index=${enb_index}
    ${enb_allowed_faults}    Create List    @{ALLOWED_FAULT}    ${fault_49}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    FOR    ${cell_idx}    IN    @{cell_id_list}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_FAULT}    connection=${enb_connection}
        enblte.block    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_mr_bts_id}/LNCEL_R-${cell_idx}
        ...    connection=${enb_connection}    timeout=${timeout}
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    300 sec    30 sec    Cell Should Be Blocked on enblte
        ...    enb_mr_bts_id=${enb_mr_bts_id}    cell_idx=${cell_idx}    connection=${enb_connection}
        Wait Until Keyword Succeeds    60 sec    5 sec    COAM Check GNB cell on air    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
	   ...    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${49}   timeout=300    connection=${enb_connection}
        ...    is_need_to_setup_gnb_connection=${False}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=${enb_allowed_faults}    connection=${enb_connection}
        enblte.unblock    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_mr_bts_id}/LNCEL_R-${cell_idx}
        ...    connection=${enb_connection}    timeout=${timeout}
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    300 sec    30 sec    Cell Should Be Unblocked on enblte
        ...    enb_mr_bts_id=${enb_mr_bts_id}    cell_idx=${cell_idx}    connection=${enb_connection}
        Wait Until Keyword Succeeds    60 sec    5 sec    COAM Check GNB cell on air    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
	    ...    connection=${gnb_connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${enb_allowed_faults}
        ...    connection=${enb_connection}
    END
    Wait Until Keyword Succeeds    900 sec   30 sec     Check enb status is in cell on air status
    [Teardown]    run keyword and ignore error    Enblte close down

RU Should Be Blocked
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...                 This keyword is used to check enb ru status
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['blockingState']}    Blocked

RU Should Be Unblocked
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...                 This keyword is used to check enb ru status
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['blockingState']}    Unblocked

Cell Should Be Blocked on enblte
    [Documentation]   Auther: lei.jia@nokia-sbell.com
    ...                 This keyword is used to check enb subcell status
    [Arguments]      ${enb_mr_bts_id}    ${cell_idx}=${1}   ${timeout}=300     ${connection}=enblte
   ${subcell_status}    enblte.get_parameters
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_mr_bts_id}/LNCEL_R-${cell_idx}
    ...    connection=${connection}
    Should Be Equal As Strings  ${subcell_status["stateInfo"]["operationalState"]}   Disabled
    Should Be Equal As Strings  ${subcell_status["stateInfo"]["availabilityStatus"]}  Offline
    Should Be Equal As Strings  ${subcell_status["stateInfo"]["blockingState"]}  Blocked

Cell Should Be Unblocked on enblte
    [Documentation]   Auther: lei.jia@nokia-sbell.com
    ...                 This keyword is used to check enb subcell status
    [Arguments]      ${enb_mr_bts_id}    ${cell_idx}=${1}   ${timeout}=300    ${connection}=enblte
   ${subcell_status}    enblte.get_parameters
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${enb_mr_bts_id}/LNCEL_R-${cell_idx}
    ...    connection=${connection}
    Should Be Equal As Strings  ${subcell_status["stateInfo"]["operationalState"]}   Enabled
    Should Be Equal As Strings  ${subcell_status["stateInfo"]["availabilityStatus"]}  Online
    Should Be Equal As Strings  ${subcell_status["stateInfo"]["blockingState"]}  Unblocked

Unlock all RUs and check status on enb
    [Documentation]    Author: lei.jia
    ...                Description: Intergration recovery actions if case with operations failed
    ...                ${operation}: Supported values:  ru_unlock
    [Arguments]    ${enb_mr_bts_id}    ${enb_connection}=enblte    ${enb_index}=${0}    ${timeout}=600
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${enb_connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        enblte.unlock_ru    dist_name=MRBTS-${enb_mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    timeout=${timeout}    connection=${enb_connection}
        Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${enb_connection}
        Wait Until Keyword Succeeds    600 sec   5 sec     Check enb status is in cell on air status
    END

Interger Calculate
    [Documentation]    Author: xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${input_number}=0
    ${input_number}=    Convert To Integer    ${input_number}
    ${input_number}    Evaluate    ${input_number}+1
    Set Test Variable    ${fail_count}    ${input_number}
    [Return]    ${fail_count}

Get Cluster Start Up time
    [Documentation]    Author: xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${date_before_reset}    ${result_format}=timer
    ${date_after_reset}    robot.libraries.DateTime.Get current date
    ${reset_time}    Subtract Date From Date    ${date_after_reset}    ${date_before_reset}
    ${convert_reset_time}    Convert Time    ${reset_time}    ${result_format}    exclude_milles=yes
    Log to console    the reset time is ${convert_reset_time}

Perfrom gNB site reset with COAM
    [Documentation]     Author: lei.jia@nokia-sbell.com
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}

Update eNB SW
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    ...                 This keyword is used to upgrade enb sw build
    [Arguments]    ${SW}     ${connection}=enblte     ${enb_index}=${0}
    log to console    Get enb Active SW Version
    ${active_sw_version}    Get eNB Active SW Version    enb_index=${enb_index}
    return from keyword if  "${active_sw_version}" == "${SW}"
    log to console    Begin to download enb sw
    ${enb_sw_package}    Download eNB SW    SW=${SW}
    log to console    Perform enb sw upgrade
    Perform eNB SW Update    package=${enb_sw_package}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Wait until keyword succeeds    15 min    30 sec    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    run keyword and ignore error    Remove eNB Downloaded Content    SW=${enb_sw_package}

Get eNB Active SW Version
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    ...                 This keyword is used to upgrade enb sw build
    [Arguments]  ${connection}=enblte
    ...             ${enb_index}=${0}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    ${sw_version} =     coam.get_sw_version    connection=enblte
    [Return]   ${sw_version}

Download eNB SW
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    ...                 This keyword is used to upgrade enb sw build
    [Arguments]    ${SW}    ${package_store_path}=${SUITE_LOG_PATH}
    log    ${SW}
    ${sw_name}=          Set Variable If
    ...                 "SBTS20B" in "${SW}"    ${SW}_release_BTSSM_downloadable_A53.zip
    ...                 "SBTS20C" in "${SW}"    ${SW}_release_BTSSM_downloadable_A54.zip
    log    ${enb_sw_web_path}${SW.split('_')[0]}/${sw_name}
    ${sw_url}=          Catenate    sudo wget ${enb_sw_web_path}${SW.split('_')[0]}/${sw_name} -nv -P ${package_store_path}
    ${status}=          run keyword and return status    file should not exist  ${package_store_path}/${sw_name}
    run keyword if      not ${status}    remove file    ${package_store_path}/${sw_name}
    ${res}=             Run         ${sw_url}
    file should exist  ${package_store_path}/${sw_name}
    [Return]            ${sw_name}

Remove eNB Downloaded Content
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    ...                 This keyword is used to upgrade enb sw build
    [Arguments]    ${SW}    ${package_store_path}=${SUITE_LOG_PATH}
    ${RM}=         Catenate    rm -rf ${package_store_path}/${SW}
    Run Process     ${RM}      timeout=5min    shell=True

Perform eNB SW Update
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    ...                 This keyword is used to upgrade enb sw build
    [Arguments]  ${package}  ${package_store_path}=${SUITE_LOG_PATH}    ${connection}=enblte
    coam.update_software     sw_package=${package_store_path}/${package}     should_activate=True    timeout=2400   connection=${connection}
    sleep    5min

Get eNB Target Build From UTE
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                 This keyword is used to fetch target enb sw build from UTE file.
    [Arguments]    ${enb_sw_file_name}=AEHC_ENB_SW_Version.txt   ${enb_sw_file_path}=/home/ute/SCF
    ${enb_sw_file}    Join Path    ${enb_sw_file_path}    ${enb_sw_file_name}
    ${enb_sw_content}    Get File    ${enb_sw_file}
    ${enb_sw_content}    split string    ${enb_sw_content}    separator=:
    ${enb_tartget_sw_version}    strip string    ${enb_sw_content}[1]
    [Return]    ${enb_tartget_sw_version}

COAM Get GNB Cells ID list
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：get cell id from site
    [Arguments]    ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info    connection=${connection}
    ${all_cells_id_list}=   create list
   FOR    ${cell_info}    IN    @{cells_info}
      append to list    ${all_cells_id_list}    ${cell_info['globalCellId']}
   END
   Sort List       ${all_cells_id_list}
    [Return]    ${all_cells_id_list}

Get Cell Group ID list via Admin CLI
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_group_list}    get dictionary keys    ${cell_info}
    Sort List       ${cell_group_list}
    ${cellgroup_id_list}=   create list
    FOR    ${cell_group}    IN    @{cell_group_list}
         ${cellgroupid}    Fetch from right    ${cell_group}    -
        append to list    ${cellgroup_id_list}    ${cellgroupid}
    END
    [Return]    ${cellgroup_id_list}

Check counter increment
    [Arguments]     ${counter_id}
    sleep     16m
	${pm_counters}=   coam.get pm counters   ${counter_id}    connection=GNB_OAM
    ${string_values}=   Convert To String   ${pm_counters}
    ${single_pm_counter}=    Get Regexp Matches    ${string_values}    \\d{10}.{3}\\d+
    ${single_pm_counter_string}=   Convert To String   ${single_pm_counter}
    ${single_pm_counters}=    Get Regexp Matches    ${single_pm_counter_string}    \\b\\d\\b
    ${pm_counters_length}=    get length    ${single_pm_counters}
    ${counter}=     set variable     0
    Should Match Regexp    ${single_pm_counters[0]}    \\d+     #this chekcs data
    FOR    ${INDEX}    IN RANGE    ${pm_counters_length}
         ${counter}=    evaluate   ${counter}+${single_pm_counters[${INDEX}]}
    END
    should be true    ${counter} > 0

TMO Suite SetUp
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]    ${enb_connection}=enblte    ${gnb_connection}=GNB_OAM
    ...             ${enb_index}=${0}    ${if_commissioning}=True
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Get HW Slot ID From TL
    run keyword if     ${if_commissioning}    CI_commssion.common commissioning
    Run Keyword And Ignore Error    Modify NR Signal    value=0
    Run Keyword And Ignore Error    Modify LTE Signal    value=15
    @{GNB_ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_4459_LIST}
    set suite variable    ${GNB_ALLOWED_FAULT}

TMO Case TearDown
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]    ${is_stop_traffic_needed}=${True}    ${enb_index}=${1}    ${enb_connection}=enblte
    Stop Traffic and Restore Att Value    is_stop_traffic_needed=${is_stop_traffic_needed}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_FAULT}    connection=${enb_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    Enblte close down
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9

Check PBCH BlockPower From X2 Log
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${wireshark_log_path_on_testPC}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${nrcell_id}=NRCELL-1
    ...            ${connection}=GNB_OAM
    Convert Pcap File To Pdml    file_path=${wireshark_log_path_on_testPC}
    ${ss_pbch_block_power_list}    Get Field Value From Pdml
    ...    filter_expression=x2ap and nr-rrc.ss_PBCH_BlockPower == 9
    ...    xpath=.//nr-rrc.ss_PBCH_BlockPower
    ${ss_pbch_block_power}    get from list    ${ss_pbch_block_power_list}    0
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${ss_power_in_scf}    coam_parameter.get_single_value_from_scf_file    parameter=ssPbchBlockPower
    ...                                                                    dist_name=NRBTS-${nr_bts_id}/${nrcell_id}
    ...                                                                    connection=${connection}
    ${expected_ss_power_value}    Evaluate    ${ss_power_in_scf}+${6}
    ${expected_ss_power_value}    Convert To String    ${expected_ss_power_value}
    run keyword and continue on failure     should be equal    ${expected_ss_power_value}    ${ss_pbch_block_power}

Convert Pcap File To Pdml
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    ...    Description: convert to pcap file to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    cap.load_pcap_file    pcap_file=${file_path}
    ...    command_template={tshark_path} -Y "x2ap" -r {pcap_file} -X lua_script:{luashark_path} -T pdml

Get Field Value From Pdml
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    ...    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show
    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}
    [Return]    ${field_value}

###Modify SCF####
Modify SCF and Perform Commission
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF
    ...               ${is_pdl_checking_needed}=${True}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    Connect to gnb coam via ssl
    ${modified_scf_file_path}    Run keyword if    '${scf_file_name}'=='${None}'    Load Current SCF And Define modified scf path
    ...                          ELSE              Load SCF and Define modified scf path    scf_file_name=${scf_file_name}    scf_path=${scf_path}
    run keyword if  not ${ParameterToDelete}=='NULL'     Delete Objects in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${ParamterToModify}=='NULL'     Add and Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists to SCF    parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    COAM Commission with scf file    scf_file_path=${modified_scf_file_path}    timeout=900
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    sleep    60s
#    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air via WebUI    download_dir=${scf_dir_path}
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min

Load SCF and Define modified scf path
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword load scf and return modified scf path for future use.
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF
     Connect to gnb coam via ssl
    ${scf_file_path}    Join Path    ${scf_path}    ${scf_file_name}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${TS_CASE_LOG_PATH}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Load Current SCF And Define modified scf path
    ${default_scf_file_path}    COAM Download scf from cluster   scf_dir_path=${TS_CASE_LOG_PATH}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${timestamp}_updated.xml
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Delete Objects in SCF
    [Documentation]   Remove object , Mo, List, Element with p_name.
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

Add and Modify elements to scf
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

Modify ListElements to scf
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
     FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  Modify SCF ListElements   dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
     END

Modify SCF ListElements
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
     FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
     END

AddLists to SCF
    [Documentation]   add List items and elements, if the items are present, remove it first.
    [Arguments]    ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        ${res}=    Run Keyword And Ignore error    scf.add item to list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END

Add MOs To SCF with Given version
    [Documentation]   Add Mos for given version, used for add channels
    [Arguments]   ${parameters_lists}    ${version}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${version}
    END
###### Modify SCF End######
Check AZGX RU Power on DFE
    [Documentation]  Author: haoxiaoxia
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.3    ${all_attenna_ports}=8
    ${connection}    csn.get connection by alias    alias=${ru_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send     ssh ${ru_dfe_ip}\n
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        Call Method    ${channel}    send     dapd -stat ${index}\n
        sleep  2s
        ${dfe_power_output}    Call Method    ${channel}    recv    ${65535}
        Log    ${dfe_power_output}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  Call Method    ${channel}    close
