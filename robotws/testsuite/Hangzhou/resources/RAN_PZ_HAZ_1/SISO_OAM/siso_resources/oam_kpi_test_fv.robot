*** Settings ***
Documentation    Suite description
...    Author:    Wu Amy;Sheng Haoyun-Lyle;Zhou Qiang;Lou Xingxin;Ding Lisa;Wu Nick
...    Maintainer:    Wu Amy;Sheng Haoyun-Lyle;Zhou Qiang;Lou Xingxin;Ding Lisa;Wu Nick

Resource    ./common_setup.robot
Resource    ./l3call.robot
Library     ./kpiReporter.py
Resource    ./reportportal.robot
Resource    ./UUF.robot

Library    taf.ul.oam_kpi_calculations   WITH NAME    oam_kpi
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
*** Keywords ***
OAM KPI L3Call
    [Arguments]    ${required_cells}=${Empty}     ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Cell Lock And Unlock KPI_16
    [Documentation]    Author:        xingxin.lou@nokia-sbell.com
    ...                Maintainer:    xingxin.lou@nokia-sbell.com
    ${kpi_names}    Create List     kpi16a    kpi16b
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${scf_path}    Set Variable    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ${connection}    Set Variable    ${CASE_NAME}_${bts_id}
        ${host_ip}   Get Scfc localIpAddr    ${scf_path}
        Selenium Login    url=https://${host_ip}   version=${NODE_CFG["${bts_id}"]["software_release"]}
        ...    alias=${connection}
        ${bbu_list}    ${rmod_list}    ${cell_list}    ${rmod_chain}    btsInfo    ${scf_path}
        Lock Cell     ${cell_list}    ${connection}
        Unlock Cell    ${cell_list}    ${connection}
        ${results}    Calculate KPIs    ${kpi_names}    ${connection}
        Selenium Logout    alias=${connection}
    END
    Check Historical Alarms    additional_allowed_alarms=EN DSS De-activated on partner side
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

RFM Reset KPI51
    [Arguments]    ${required_rfs}=${EMPTY}    ${test_loops}=${20}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    ${cell_cross_rru}    Check Is Cell Cross RRU
    ${cross_rf_sn_list}    Get Cross RF Serial Num List
    Remove Values From List    ${rf_list}    @{cross_rf_sn_list}
    ${test_loops_kpi}    Evaluate    int(len(${rf_list})/(len(${rf_list})+len(${cross_rf_sn_list}))*${test_loops})
    ${test_loops_cross}    Evaluate    ${test_loops}-${test_loops_kpi}
    ${rf_list}    Evaluate    (${rf_list}*${test_loops_kpi})[:${test_loops_kpi}]
    ${cross_rf_sn_list}    Evaluate    (${cross_rf_sn_list}*${test_loops_cross})[:${test_loops_cross}]
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset    ${fr_serial_number}
    END
    ${sts1}    ${kpi_dictionary}    Run Keyword And Ignore Error    Calculate Ru Reset KPI
    FOR    ${fr_serial_number}    IN    @{cross_rf_sn_list}
        Radio Reset    ${fr_serial_number}
    END
    Check Multinode Without Unexpect Alarm
    Run Keyword If    ${cell_cross_rru}    Check Historical Alarms    additional_allowed_alarms=Transmission path failure
    ...    ELSE    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Reset With Remove HWBIN KPI1
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    FOR    ${host_ip}    IN    @{host_ip_list}
         Setup eNB FSM Access    host=${BTS_HOST}    timeout=15    remote_host=${host_ip}
         ...    alias=rm_hwbin_${host_ip}
         execute_command_on_enb    cmd=rm -rf /ffs/run/config/hwf.bin.gz    alias=rm_hwbin_${host_ip}
    END
    Start time
    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    End time
    ${kpi1a}=  create dictionary
    ${kpi1b}=  create dictionary
    ${kpi1c}=  create dictionary
    FOR    ${bts_id}    IN    @{BTS_LIST}
         coam.collect_infomodel_log_from_current_session    ${TEST_LOGS_DIR_PATH}/kpi_${bts_id}.ims
         ...    connection=${CASE_NAME}_${bts_id}
         ${sts1}    ${kpi1a_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi1a     ${TEST_LOGS_DIR_PATH}/kpi_${bts_id}.ims
         ${sts1}    ${kpi1b_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi1b     ${TEST_LOGS_DIR_PATH}/kpi_${bts_id}.ims
         ${sts1}    ${kpi1c_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi1c     ${TEST_LOGS_DIR_PATH}/kpi_${bts_id}.ims
         Run Keyword And Ignore Error    Set To Dictionary    ${kpi1a}    ${bts_id}=${kpi1a_t['kpi1a'][0]['delta']}
         Run Keyword And Ignore Error    Set To Dictionary    ${kpi1b}    ${bts_id}=${kpi1b_t['kpi1b'][0]['delta']}
         Run Keyword And Ignore Error    Set To Dictionary    ${kpi1c}    ${bts_id}=${kpi1c_t['kpi1c'][0]['delta']}
    END
    set suite variable    ${kpi1a}
    set suite variable    ${kpi1b}
    set suite variable    ${kpi1c}
    Verify HW state
    Check Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    [Teardown]    teardown_all_aliases_for_enb_fsmaccess

BBMOD Reset KPI5
    [Documentation]    Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${timeout}=500s    ${bbmod_id_list}=${Empty}    ${test_loops}=${EMPTY}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Start time
        Reset BBMOD Until Onair    timeout=${timeout}    require_bbmod=${bbmod_id_list}    btsid=${bts_id}
        ...    test_loops=${test_loops}
        End time
    END
    set suite variable    ${kpi5_dic}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Delta Commissioning Kpi
    [Arguments]    ${para_list}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${teardown_para_list}    Create List
    Set Test Variable    ${TEARDOWN_PARA_LIST}    ${teardown_para_list}
    FOR    ${para}    IN    @{para_list}
        ${dist_name}    Split String    ${para["dist_name"]}    /
        ${bts_id}    Split String    ${dist_name[0]}    -
        Selenium Get Teardown Parameters    ${para}    ${bts_id[1]}
        ${is_para_exist}    Run Keyword And Return Status    Variable Should Exist    ${para["required_reset_bts_id"]}
        ${required_bts_id}    Set Variable If    ${is_para_exist}    ${para["required_reset_bts_id"]}    ${bts_id[1]}
        Multi Parameters Recommission And Check BTS Reset    ${para}    bts_id=${bts_id[1]}
        ...    require_reset=${para["require_reset"]}    required_bts_id=${required_bts_id}
    END
    [Teardown]    Multi Parameters Recommission And Check BTS Reset    ${TEARDOWN_PARA_LIST}
    ...    bts_id=${bts_id[1]}    require_reset=ignore

Delta Commissioning Kpi For SISO3
    [Arguments]    ${para_list}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${para_list}    Evaluate    ${para_list}
    ${online_change_paras}    Create List
    ${rat_reset_paras}    Create List
    ${site_reset_paras}    Create List
    FOR    ${para}    IN    @{para_list}
        ${dist_name_split}    Split String    ${para["dist_name"]}    /
        ${bts_id_split}    Split String    ${dist_name_split[0]}    -
        Set To Dictionary    ${para}    bts_id    ${bts_id_split[1]}
        Run Keyword If    '${para['reset_tag']}'=='online'    Append To List    ${online_change_paras}    ${para}
        ...    ELSE IF    '${para['reset_tag']}'=='rat_reset'    Append To List    ${rat_reset_paras}    ${para}
        ...    ELSE IF    '${para['reset_tag']}'=='site_reset'    Append To List    ${site_reset_paras}    ${para}
        ...    ELSE    FAIL    'reset_tag' is not 'online' or 'rat_reset' or 'site_reset'
    END
    Delta Commissioning Kpi For Multi BTS    ${online_change_paras}
    Delta Commissioning Kpi For Multi BTS    ${site_reset_paras}
    Delta Commissioning Kpi For Multi BTS    ${rat_reset_paras}

SW Upgrade And RollBack KPI2
    [Arguments]    ${upgrade}=YES    ${rollback}=YES    ${recover}=${RB_TO_TARGET}
    ...    ${target_builds}=${None}    ${L3Call}=NO
    log    ${target_builds}
#    ${TARGET_SW_VERSION_DICT}    Evaluate    ${target_builds}
#    ${btsIds}    Get Dictionary Keys    ${TARGET_SW_VERSION_DICT}
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    ${is_exits1}    Run Keyword And Return Status    Variable Should Exist    ${TARGET_SW_VERSION}
    ${is_exits2}    Run Keyword And Return Status    Variable Should Exist    ${REQUIRED_BTS_ID}
    Run Keyword If    "${is_exits1}"!="${True}" and "${is_exits2}"!="${True}"
    ...    Fail    Test Variable "TARGET_SW_VERSION" or "REQUIRED_BTS_ID" undefined
    ${target_sw_dict}    Run Keyword If    ${is_exits1}    Evaluate    ${TARGET_SW_VERSION}
    ${target_bts_ids}    Run Keyword If    ${is_exits1}    Get Dictionary Keys    ${target_sw_dict}
    ${required_bts_ids}    Run Keyword If    ${is_exits2}    Split String    ${REQUIRED_BTS_ID}    :
    ${btsIds}    Set Variable If    ${is_exits1}    ${target_bts_ids}    ${required_bts_ids}
    #FOR    ${host_ip}    IN    @{host_ip_list}
    #     Setup eNB FSM Access    host=${BTS_HOST}    timeout=15    remote_host=${host_ip}    alias=rm_ps_${host_ip}
    #     Run Keyword And Ignore Error    execute_command_on_enb    cmd=mount -o remount,rw /ffs/stb
    #     ...    alias=rm_ps_${host_ip}
    #     Run Keyword And Ignore Error    execute_command_on_enb    cmd=rm -r /ffs/stb/*    alias=rm_ps_${host_ip}
    #END
    ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${TOP50}
    Run Keyword IF    '${status}'=='FAIL'   Set Test Variable    ${TOP50}    False
    Run Keyword IF    '${TOP50}'=='True'    Start time
    ${btsNum}    Get Length    ${btsIds}
    #Logging Multinode Start KPI    pre_alias=kpi
    FOR    ${btsId}   IN    @{btsIds}
#        Set Test Variable    ${swVersion}    ${PRE_NODE_CFG['${btsId}']['software_active']}
        Set Test Variable    ${swVersion}    ${UTE_PUSHED_SW_VERSION}
#        ${swVersion}    Get From Dictionary    ${TARGET_SW_VERSION_DICT}    ${btsId}
#        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${CURRENT_SW_${btsId}}
#        Run Keyword IF    '${swVersion}'==''    Set Test Variable    ${swVersion}
#        ...    ${PRE_NODE_CFG['${btsId}']['software_active']}
#        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${PKG_TYPE}
#        ${type}    Set Variable If    '${status}'=='FAIL'    Normal    ${PKG_TYPE}
        ${sw_type}    Should Match Regexp    ${UTE_PUSHED_SW_VERSION}    SBTS\\w+_(\\w+)_\\d+_\\d+_\\d+
#        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${ENB_BUILD}
#        Run Keyword IF    '${status}'=='PASS'    Set Test Variable    ${swVersion}    ${ENB_BUILD}
        Run Keyword IF    '${upgrade}'=='YES'    Download SW Build    ${swVersion}    type=${sw_type[1]}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${matched_file}    Get Matches   ${files}    ${swVersion}*
        Run Keyword IF    '${upgrade}'=='YES'    Wait Until Keyword Succeeds    20 min    30 sec
        ...    coam.Update Software    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600
        ...    connection=${CASE_NAME}_${btsId}
    END
    Run Keyword IF    '${upgrade}'=='YES'    sleep    180s
    Run Keyword IF    '${upgrade}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...     Create Node Parameters From Current SCF
    Run Keyword IF    '${upgrade}'=='YES'    Run Keyword And Ignore Error
        ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
    Run Keyword IF    '${upgrade}'=='YES'    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${upgrade}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${upgrade}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${upgrade}'=='YES'    Check Alarms
        Run Keyword IF    '${upgrade}'=='YES'    Check Historical Alarms
        ${active_sw_version}    ${active_sw_release}    Get Node SW Build And Release   ${NODE_CFG["${btsId}"].node}
        Should Be True    "${active_sw_version}"=="${swVersion}"
    END
    ${NODE_INFO}    Get Dictionary Values    ${NODE_CFG}
    ${SingleSite}    Get From List    ${NODE_INFO}    0
    Set Test Variable    ${TBUILD}    ${SingleSite['software_active']}
    Run Keyword IF  '${TOP50}'=='True'    End time
    Set Test Variable    ${kpistatus}    PASS
    ${kpi2a}=  create dictionary
    ${kpi2b}=  create dictionary
    ${kpi2c}=  create dictionary
    ${kpi2d}=  create dictionary
    FOR    ${btsId}   IN    @{btsIds}
        ${last_dis_ims}    get_latest_disconnected_ims_file    ${btsId}    ${TEST_LOGS_DIR_PATH}/Admin_logs
        coam.collect_im_snapshot    target_file_name=${TEST_LOGS_DIR_PATH}/kpi_${btsId}.ims
        ...    connection=${CASE_NAME}_${btsId}
        ${all_ims}    Create List    ${last_dis_ims}    ${TEST_LOGS_DIR_PATH}/kpi_${btsId}.ims
        ${rstatus}    ${kpi2a_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi2a    ${all_ims}
        ${rstatus}    ${kpi2b_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi2b    ${all_ims}
        ${rstatus}    ${kpi2c_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi2c    ${all_ims}
        ${rstatus}    ${kpi2d_t}    Run Keyword And Ignore Error    oam_kpi.calculate_kpi2d    ${all_ims}
        Run Keyword IF    '${rstatus}'=='FAIL'    Set Test Variable    ${kpistatus}    FAIL
        ${rtstatus}    ${result}    Run Keyword And Ignore Error
        ...    Set To Dictionary    ${kpi2a}    ${bts_id}=${kpi2a_t['kpi2a'][0]['delta']}
        ${rtstatus}    ${result}    Run Keyword And Ignore Error
        ...    Set To Dictionary    ${kpi2b}    ${bts_id}=${kpi2b_t['kpi2b'][0]['delta']}
        ${rtstatus}    ${result}    Run Keyword And Ignore Error
        ...    Set To Dictionary    ${kpi2c}    ${bts_id}=${kpi2c_t['kpi2c'][0]['delta']}
        ${rtstatus}    ${result}    Run Keyword And Ignore Error
        ...    Set To Dictionary    ${kpi2d}    ${bts_id}=${kpi2d_t['kpi2d'][0]['delta']}
        Run Keyword IF    '${rtstatus}'=='FAIL'    Set Test Variable    ${kpistatus}    FAIL
    END
    set suite variable    ${kpi2a}
    set suite variable    ${kpi2b}
    set suite variable    ${kpi2c}
    set suite variable    ${kpi2d}
    Run Keyword IF    '${upgrade}'=='YES'    Wait Until Keyword Succeeds    600    30
    ...     Create Node Parameters From Current SCF
    Run Keyword IF    '${L3Call}'=='YES'    Make L3Call
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${rollback}'=='YES'    coam.rollback_software
        ...    connection=${CASE_NAME}_${btsId}    timeout=1200
    END
    Run Keyword IF    '${rollback}'=='YES'    sleep    180s
    Run Keyword IF    '${rollback}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Create Node Parameters From Current SCF
    Run Keyword IF    '${rollback}'=='YES'    Run Keyword And Ignore Error
        ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
    Run Keyword IF    '${rollback}'=='YES'    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${rollback}'=='YES'    Wait Until Keyword Succeeds    600    30
            ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${rollback}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${rollback}'=='YES'    Check Alarms
        Run Keyword IF    '${rollback}'=='YES'    Check Historical Alarms
    END
    FOR    ${btsId}   IN    @{btsIds}
        run keyword if    '${recover}'=='YES'    coam.rollback_software
        ...    connection=${CASE_NAME}_${btsId}    timeout=1200
    END
    Run Keyword IF    '${recover}'=='YES'    sleep    180s
    Run Keyword IF    '${recover}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Create Node Parameters From Current SCF
    Run Keyword IF    '${recover}'=='YES'    Run Keyword And Ignore Error
        ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
    Run Keyword IF    '${recover}'=='YES'    Run Keyword And Ignore Error    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${recover}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${recover}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${recover}'=='YES'    Check Alarms
        Run Keyword IF    '${recover}'=='YES'    Check Historical Alarms
    END
    [Teardown]    Run Keyword And Ignore Error  teardown_all_aliases_for_enb_fsmaccess
