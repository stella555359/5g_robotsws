*** Settings ***
Documentation    Author:annie.hu@nokia-sbell.com

#Resource    taf/rfrl/common_resources/robot/coam.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
#Library      taf.gnb.oam.coam.admin    WITH NAME    coam

*** Keywords ***
SG5_Common_Suite_Setup
    [Arguments]    ${is_commission}=${False}
    robot_common_operations.Common Suite Setup
    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    Set Suite Variable    ${stream_version}
    Set Suite Variable    ${ue_length}     1
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    #Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_${BASIC_SCF}    is_commission=${is_commission}
    Verify TMO Gnb Ready And All Cell On Air
    Log to console    ${\n}----Verify all cells of enbs are on air----
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait until keyword succeeds    2 min    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
    END
    sleep    5s


Test case setup
    robot_common_operations.Common Case Setup
    #Common_setup_and_teardown.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${LTE_CELL_LIST}    Verify Gnb Type Cells Should Be Onair    cell_type=lte
    Set Test Variable    ${LTE_CELL_LIST}
    COAM Create log directory
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
    run keyword and ignore error    COAM Teardown gnb connections


Common Case Setup
    [Documentation]
    ...               1. Create case log path:${TS_CASE_LOG_PATH}
    ...               2. If ${is_commission}=True, will do commission for gnb
    ...               3. If two gnbs are exist for this testline and ${is_commission_for_second_gnb}=True, will do commission for gnb2
    [Arguments]     ${scf_name}=None    ${scf_name_for_second_gnb}=None
    ...             ${connection}=GNB_OAM0    ${is_commission}=False
    ...             ${connection_for_second_gnb}=GNB_OAM1    ${is_commission_for_second_gnb}=False
    ...             ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min     ${is_pdl_checking_needed}=${True}
    COAM Create log directory
    Run Keyword If    ${is_commission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name_for_second_gnb}
    ...                                     connection=${connection_for_second_gnb}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission}    Wait Gnb Ready And Cell On Air    gnb_id=${0}
    ...                                                                     timeout=${wait_gnb_up_timeout}
    ...                                                                     connection=${connection}
    Run Keyword If    ${is_commission_for_second_gnb}    Wait Gnb Ready And Cell On Air    gnb_id=${1}
    ...                                                                                    timeout=${wait_gnb_up_timeout}
    ...                                                                                    connection=${connection_for_second_gnb}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...                           Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}

Common Case Teardown
    [Documentation]
    [Arguments]     ${is_save_snapshot}=True    ${is_save_snapshot_for_second_gnb}=False
    ...             ${connection}=GNB_OAM0    ${connection_for_second_gnb}=GNB_OAM1
    ...             ${timeout}=900    ${alais}=ASIK Master0    ${alais_for_second_gnb}=ASIK Master1
    Run Keyword If    ${is_save_snapshot}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    Connect to Common Unit Master    alias=${alais}    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api    connection=${connection}
    ...                                                                                                     timeout=${timeout}
    Run Keyword If    ${is_save_snapshot_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    Connect to Common Unit Master    alias=${alais_for_second_gnb}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    ...                                                                  connection=${connection_for_second_gnb}
    ...                                                                  timeout=${timeout}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps -ef | grep admin_api |awk '{print $2}' | xargs kill -9
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais_for_second_gnb}    AND
    ...    csn.Reset Cache    AND    CI_interface.Common Case Teardown


#--- Common keywords for gnb ---#
Verify TMO Gnb Ready And All Cell On Air
    [Documentation]    Check ALL cells on air include: "lte", "wcdma", "gsm", "nr"
    [Arguments]    ${connection}=GNB_OAM
    Wait Gnb Ready And Cell On Air    timeout=10min    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}

Verify Gnb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=lte    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=30
    Log to console    ${\n}----Verify all ${cell_type} cells are on air----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}
    ...     Online    ignore_case=True
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}
    ...     enabled    ignore_case=True
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}




Verify Enb Type Cells Should Be Onair
    [Documentation]
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm".
    [Arguments]    ${cell_type}    ${connection}    ${timeout}=30
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}
    ...     unlocked    ignore_case=True
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}
    ...     enabled    ignore_case=True
    END

Check_gNB_Startup_log
    [Arguments]  ${connection}=GNB_OAM
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    ${startup_command} =    set variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_command} =  set variable
    ...       xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    ${startup_log} =    Check Startup Defualt Log On ASIK
    ...    startup_cmd=${startup_command}    startup_xz_cmd=${startup_xz_command}    info=startService loading from hwf is disabled
    run keyword and ignore error  csn.disconnect    connection=ASIK Master


Modify Swconfig File
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${para_update}    ${local_path}=${TS_LOG_PATH_BASE}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master


Verify Enb All Cell On Air
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${timeout}=30
    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
	${output}    enblte.get_bts_info    connection=${connection}
    @{rat_type_list}    Create List
    ${ratState_list}    Get Dictionary Keys    ${output['ratState']}
    FOR    ${item}    IN    @{ratState_list}
        ${value}    Get From Dictionary    ${output['ratState']}    ${item}
        Run Keyword If    '${value}' != 'NO_CELLS'    Append To List    ${rat_type_list}    ${item}
    END
    FOR    ${rat_type}    IN    @{rat_type_list}
        Verify Enb Type Cells Should Be Onair    cell_type=${rat_type}    connection=${connection}    timeout=${timeout}
    END
	[Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}



Get Parameter Value From SCF
    [Arguments]     ${parameter}
    ...              ${dist_name}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ${parameter_value}    coam_parameter.get_single_value_from_scf_file    parameter=${parameter}
    ...              dist_name=${dist_name}
    ...              connection=${connection}
    [Return]    ${parameter_value}


Verify Data Continues On LTE
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${data_switch_time}    ${expect_data_amount}    ${dl_ul_type}=DL
    ${counter_string}    Set Variable If    '${dl_ul_type}'=='DL'
    ...                  {'M8012C76': '[LSP01034B11] CELLS/LNCEL-${anchore_enb_cellid}/LTE_Cell_Throughput/MAC_SDU_VOL_DL_DTCH'}
    ...                  {'M8012C71': '[LSP01034B11] CELLS/LNCEL-${anchore_enb_cellid}/LTE_Cell_Throughput/MAC_SDU_VOL_UL_DTCH'}
    ${ul_dl_tput_counter}    Evaluate    [${counter_string}]
#    Verify Counter Added As Expected    counter_info_dict_list=${ul_dl_tput_counter}
#    ...                                 counter_generatd_time=${data_switch_time}
#    ...                                 expect_added_value=${expect_data_amount}
#    ...                                 gnb_enb_type=enb
#    ...                                 counter_duration=15
    ${required_counter_values}    Get Required Counter Values    counter_info_dict_list=${ul_dl_tput_counter}
    ...                                                          counter_generatd_time=${data_switch_time}
    ...                                                          gnb_enb_type=enb
    ...                                                          counter_duration=15
    Log    counter info: ${required_counter_values}, effective duration ${available_duration}.
    ${counter_value}    Get Dictionary Values    ${required_counter_values}
    ${expect_data_amount}     Convert To Number    ${expect_data_amount}
    ${counter_value}    Convert To Number    ${counter_value[0]}
    Should Be True    ${counter_value}>=${expect_data_amount}    msg=Data switched to LTE is not meet the requirement.




eNB Login Page Via WebUI
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box

Wait Gnb Ready And Cell On Air
    [Timeout]    30 min
    [Documentation]    Description: Wait GNB cell on air , and each single cell status in cell on air status
    [Arguments]    ${gnb_id}=0    ${timeout}=20 min    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                                   gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'
    ...    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check X2 link status from GNB    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}








