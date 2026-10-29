*** Settings ***
Documentation
...   author: Dandan Fang
...   contact: dandan.fangzheng.4.liu@nokia-sbell.com
...   squad group: SG_01
...   Feature  in  program
...   SISO_COMMON_BASIC_PATH = 'testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/'
...   BASIC_PATH_5G = SISO_COMMON_BASIC_PATH + '5G'
...   BASIC_PATH_COMMON = SISO_COMMON_BASIC_PATH + 'Common'

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_power_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RU_lock_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI_with_L3call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Baseband_module_reset_via_WEBUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Baseband_module_lock_unlock_via_WEBUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB013394_SG01/Resources/L3_Call_Traffic_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

*** Variables ***
${AF_PATH}    ${None}

*** Keywords ***
CB013394 Suite preparation
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${NSA_SA}=SA     ${prepare_ue}=${True}
    ...            ${connection}=${CONNECTION_ALIAS}
    Variable Prepare and SCF Path Define

    Run keyword if    '${tl.attenuators}'!='[None]'
    ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA}    if_change_ENB_PA=${False}
    ...        NSA_SA=${NSA_SA}

    Suite common setup preparation       NSA_SA=${NSA_SA}    is_x2_check_from_enb_needed=${False}    prepare_ue=${prepare_ue}
    ...    scf_template_path=${SCF_DEFAULT_FILE_PATH}

    Variable Defined For Common Siso KW   connection=${connection}

Variable Defined For Common Siso KW
    [Arguments]    ${connection}=${CONNECTION_ALIAS}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}
    # Selenium Login And Disable Screen Lock - KW need follow variable, else log in fail.
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}

    #  ru_operation . Lock all RUs and check all status
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    # used by Block cells and check status
    set suite variable       ${X2_link_shutdown_time}      0

Variable Prepare and SCF Path Define
    [Documentation]    Author: Dandan Fang
    ...     Description: default dir scf and swconfig and log dir for ute cloud.
    ...     ${WORKSPACE_DIR} defined by Set variables for UTE cloud
    Set variables for UTE cloud
    ${stream}    ${build}     run keyword if    ${IS_UTE_ENV}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}

    set suite variable     ${SCF_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/SCF_${stream}.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/swconfig.txt

    import resource     ${CURDIR}/../Resources/CB013394_variables.robot

CB013394 Case Setup
    [Documentation]    Author: Dandan Fang
    ...    if the  ${if_commission_needed} is ${None},  then commission with specific configuration.
    ...    or check the configuration(band, chbw, multi_rat_config), if not as expected, then do commission with specific configuration.
    [Arguments]  ${NSA_SA}=SA   ${is_pdl_checking_needed}=${True}    ${scf_template_path}=${None}
    ...          ${connection}=${CONNECTION_ALIAS}
    Common case setup    NSA_SA=${NSA_SA}   is_pdl_checking_needed=${is_pdl_checking_needed}
    ...     scf_template_path=${scf_template_path}

    ${RMOD_INDEX_MAP}       coam_gnb_classical.get_ruIndexInGnbConf_map_to_ruindexInTLInitFile    connection_alias=${connection}
    Set Test Variable    ${RMOD_INDEX_MAP}

Adjust attenuator For L3 Call and Avoid Same Band Interference Due to Same Band
    [Documentation]    Author: Dandan Fang
    ...    AVQA,AVQD,AVQF all as N78 band and CC number as 4, It's difficult to widen the gap between frequency points
    ...    so when do  L3 call on one radio, we need to block signal from other radio unit
    [Arguments]  ${ru_used_for_l3}    ${gnb_index}=${GNB_INDEX}
    FOR    ${index}    ${rmod_index}    IN ENUMERATE    @{RMOD_INDEX_MAP}
        ${ruIndex_in_init}    Set Variable    ${RMOD_INDEX_MAP['${rmod_index}']['ru_index_in_init_file']}
        ${exp_pa_value}      Run Keyword If   '${ru_used_for_l3}'=='${rmod_index}'
        ...    Set Variable        ${INIT_PA[${GNB_INDEX}][${ruIndex_in_init}]}
        ...    ELSE      Set Variable       ${127}
        Set attenuator ports of specified RUs to same value
        ...     exp_pa_value=${exp_pa_value}    ru_idx_list=${ruIndex_in_init}
        ...     gnb_index=${gnb_index}
    END

CB013394_General_SiSo_RU_lock_unlock
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    [Arguments]      ${connection}=${CONNECTION_ALIAS}
    ${ru_index_list}    Get All RU Index
    ${all_Cells_List}    Get All Cell Id
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF rmod_index ${ru_index} Lock from GUI***
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        coam_gnb_classical.Perform RU lock via rest api   ru_idx=${ru_index}     timeout=${120}
        wait until keyword succeeds  1min  30sec  RU Should Be Locked  ru_index=${ru_index}    connection=${connection}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cellIds_SpecificRu}
        ${flag}    ${cells_On_Other_RUs}    getusefulid    ${cellIds_SpecificRu}    ${all_Cells_List}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cells_On_Other_RUs}
        Wait Until Keyword Succeeds    5min    10s    Get alarms to check
    END

    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        log to console    \n***RF rmod_index${ru_index} ${ru_type} unLock from GUI***
        Perform RU unlock via rest api   ru_idx=${ru_index}
        wait until keyword succeeds  1min  30sec  RU Should Be Unlocked  ru_index=${ru_index}    connection=${connection}
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cells_present_on_ru}    Run Keyword And Return Status   Should Not Be Empty    ${cellIds_SpecificRu}
        Continue For Loop If    '${cells_present_on_ru}'=='${False}'
        wait until keyword succeeds    5min    20sec   Cell status Should Be enabled    cell_list=${cellIds_SpecificRu}
        Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        Adjust attenuator For L3 Call and Avoid Same Band Interference Due to Same Band    ru_used_for_l3=${ru_index}
        Run Keyword And Continue On Failure      Do L3 Call and Traffic on Cells  ru_type=${ru_type}
        ...    cell_list=${cellIds_SpecificRu}      need_traffic_test=${False}     peak_check=${False}
    END
    [Teardown]  Teardown Unlock All RU   ru_index_list=${ru_index_list}

Teardown Unlock All RU
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${ru_index_list}     ${connection}=${CONNECTION_ALIAS}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Run Keyword And Ignore Error      Perform RU unlock via rest api   ru_idx=${ru_index}
        wait until keyword succeeds  1min  30sec  RU Should Be Unlocked  ru_index=${ru_index}    connection=${connection}
    END

CB013394 Block and UnBlock Cells and L3call With UL Traffic
    [Arguments]      ${check_alarm}=${True}   ${technology}=NR   ${gnb_index}=${0}
    wait until keyword succeeds    3x    5sec    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        log to console    \n***Do Cell BLock/Unblock on rmod_index ${ru_index} ${ru_type}***
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cells_present_on_ru}    Run Keyword And Return Status   Should Not Be Empty    ${cellIds_SpecificRu}
        Continue For Loop If    '${cells_present_on_ru}'=='${False}'
        Block cells and check status    block_list=${cellIds_SpecificRu}   check_alarm=${check_alarm}
        ...    technology=${technology}     gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${cellIds_SpecificRu}   check_alarm=${check_alarm}
        ...     technology=${technology}  gnb_type='${gNb_CuType}'  skip_deepsleep=${True}
        Adjust attenuator For L3 Call and Avoid Same Band Interference Due to Same Band    ru_used_for_l3=${ru_index}
        Run Keyword And Continue On Failure      Do L3 Call and Traffic on Cells  ru_type=${ru_type}  cell_list=${cellIds_SpecificRu}
            ...    need_traffic_test=${True}  data_transfer_direction=ul
    END
    [Teardown]   Unblock All CCs When Teardown

Unblock All CCs When Teardown
    [Documentation]    Author: Dandan Fang
    [Arguments]   ${technology}=NR
    ${all_Cells_List}    Get All Cell Id
    FOR  ${cell_index}  IN  @{all_Cells_List}
        Run Keyword And Ignore Error        selenium_coam.unblock_cell    cell_idx=${cell_index}
        ...     technology=${technology}
    END
    [Teardown]    Run Keyword And Ignore Error     Selenium Logout And Close Browser

CB013394_General_SiSo_RU_module_reset_from_GUI
    [Arguments]      ${connection}=${CONNECTION_ALIAS}  ${gnb_index}=${0}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    wait until keyword succeeds    3x    5sec    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Online     ru_index=${ru_index}    connection=${connection}
        coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cells_present_on_ru}    Run Keyword And Return Status   Should Not Be Empty    ${cellIds_SpecificRu}
        Continue For Loop If    '${cells_present_on_ru}'=='${False}'
        ${cell_choosed_test}   Evaluate    random.choice(${cellIds_SpecificRu})   modules=random
        Adjust attenuator For L3 Call and Avoid Same Band Interference Due to Same Band    ru_used_for_l3=${ru_index}
        Run Keyword And Continue On Failure     Do L3 Call and Traffic on Cells  ru_type=${ru_type}
        ...     cell_list=${cell_choosed_test}      need_traffic_test=${True}     data_transfer_direction=dl
    END

    [Teardown]    Run Keyword And Ignore Error     Selenium Logout And Close Browser

CB013394 Online Cell addition deletion
    [Arguments]     ${connection}=${CONNECTION_ALIAS}  ${gnb_index}=${GNB_INDEX}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    wait until keyword succeeds    3x    5sec    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}  Convert To Integer    ${ru_index}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cellIds_SpecificRu_is_empty}    Run Keyword And Return Status
        ...      Should Be Equal As Strings    ${cellIds_SpecificRu}    []
        Continue For Loop If    ${cellIds_SpecificRu_is_empty}
        ${addition_deletion_cell}   Evaluate    random.choice(${cellIds_SpecificRu})   modules=random
        log to console    \n***RF index ${ru_index} ${ru_type} Cell ${addition_deletion_cell}Del Add from GUI***
        Online Cell addition deletion     addition_deletion_cell=${addition_deletion_cell}
        #attach only
        Adjust attenuator For L3 Call and Avoid Same Band Interference Due to Same Band    ru_used_for_l3=${ru_index}
        Run Keyword And Continue On Failure      Do L3 Call and Traffic on Cells  ru_type=${ru_type}
        ...    cell_list=${addition_deletion_cell}
        ...    need_traffic_test=${True}     data_transfer_direction=unidir_then_bidir
    END
    [Teardown]    Run Keyword And Ignore Error     Selenium Logout And Close Browser

Cell Del and Add Case Tear Down
    [Documentation]    Author: Dandan Fang
    ${is_scf_restore}    Set variable if    '${TEST STATUS}'=='FAIL'    ${True}    ${False}
    ${scf_file_path_for_restore}    Set variable if    ${is_scf_restore}    ${SCF_DEFAULT_FILE_PATH}    ${None}
    ${is_onair_check}    Set variable if    ${is_scf_restore}    ${True}    ${False}
    Common case teardown    is_scf_restore=${is_scf_restore}
    ...    scf_file_path_for_restore=${scf_file_path_for_restore}    is_onair_check=${is_onair_check}
    ...    detach_ue=${True}    is_btslog_required=${false}

 CB013394_Online_CellTye_Change
    [Arguments]     ${connection}=${CONNECTION_ALIAS}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}  Convert To Integer    ${ru_index}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cellIds_SpecificRu_is_empty}    Run Keyword And Return Status
        ...      Should Be Equal As Strings    ${cellIds_SpecificRu}    []
        Continue For Loop If    ${cellIds_SpecificRu_is_empty}

        ${target_cell}   set variable    ${cellIds_SpecificRu}[0]
        log to console    \n***RF index ${ru_index} ${ru_type} Cell ${target_cell} Celltype changed***
        run keyword and continue on failure     _Online_Modify_nrCellType_value_Via_REST_API    celltype=8DL4UL
        ...    cell_id=${target_cell}    connection=${connection}
        run keyword and continue on failure     _Online_Modify_nrCellType_value_Via_REST_API    celltype=16DL8UL
        ...    cell_id=${target_cell}    connection=${connection}
    END

_Online_Modify_nrCellType_value_Via_REST_API
    [Documentation]    Author: Dandan Fang
    ...    Arguments:
    ...    ${celltype}: The new value to set for nrCellType.
    ...    ${cell_id}: The identifier of the cell to modify.
    ...    ${connection} (optional): The connection alias to use. Defaults to ${CONNECTION_ALIAS}.
    [Arguments]     ${celltype}  ${cell_id}   ${connection}=${CONNECTION_ALIAS}
    log to console    start modify cell-${cell_id} nrCellType as ${celltype}
    ${params_for_update}=    Create List
    ${dist_name}=    Set Variable    ${dn_nrbts}/NRCELL-${cell_id}
    ${param}=    Create Dictionary    dist_name=${dist_name}    parameter=nrCellType    value=${celltype}
    Append To List    ${params_for_update}    ${param}
    ${timeout}=    Set Variable    5min
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${GNB_INDEX}    connection=${CONNECTION_ALIAS}
    Wait Until Keyword Succeeds    5min    10s    Get alarms to check

Update RMOD Cablink LinkSpeed Dynamically
    [Arguments]   ${rmod_index}
    # [{'cablink_index': 7, 'linkSpeed': 'eCpri50'}, {'cablink_index': 6, 'linkSpeed': 'eCpri25'}]
    ${cablink_info_list}=    coam_gnb_classical.get_cablink_index_by_rmod    rmod_index=${rmod_index}    connection_alias=${CONNECTION_ALIAS}
    run keyword and continue on failure     _Online_Modify_LinkSpeed_value_Via_REST_API    cablink_info_list=${cablink_info_list}   recovery=${False}
    run keyword and continue on failure     _Online_Modify_LinkSpeed_value_Via_REST_API    cablink_info_list=${cablink_info_list}   recovery=${True}

_Online_Modify_LinkSpeed_value_Via_REST_API
    [Arguments]   ${cablink_info_list}    ${recovery}=${False}    ${connection}=${CONNECTION_ALIAS}
    ${params_for_update}=    Create List
    FOR    ${cablink_info}    IN    @{cablink_info_list}
        log to console  cablink info: ${cablink_info}
        ${cablink_index}=    Set Variable    ${cablink_info}[cablink_index]
        ${original_speed}=    Set Variable    ${cablink_info}[linkSpeed]
        ${cablink_dn}=    Set Variable    ${DN_MRBTS}/EQM-1/HWTOP-1/CABLINK-${cablink_index}
        ${target_speed}=  Run Keyword If    ${recovery}    Set Variable    ${original_speed}
        ...    ELSE IF    '${original_speed}'=='eCpri50'    Set Variable    eCpri25
        ...    ELSE IF    '${original_speed}'=='eCpri25'    Set Variable    eCpri50
        ${param}=    Create Dictionary    dist_name=${cablink_dn}    parameter=linkSpeed    value=${target_speed}
        Append To List    ${params_for_update}    ${param}
    END
    # Modify speed , will trigger bts reset, so timeout set as 480.
    # add FID10, due to rest api modify linkspeed, FID10 will be triggered before BTS Reset. So choose ignore FID10
    # PR876573 resolved, so remove code.
    # AlarmWatchdog.add_allow_alarms     fault_id=10
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=480    connection=${connection}
    # AlarmWatchdog.remove_allow_alarms    fault_id=10
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${GNB_INDEX}    connection=${connection}
    Wait Until Keyword Succeeds    5min    10s    Get alarms to check

 CB013394_Online_Modify_tiltOffset_For_Specific_RU
    [Arguments]     ${ru_index_list}     ${connection}=${CONNECTION_ALIAS}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}  Convert To Integer    ${ru_index}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cellIds_SpecificRu_is_empty}    Run Keyword And Return Status
        ...      Should Be Equal As Strings    ${cellIds_SpecificRu}    []
        Continue For Loop If    ${cellIds_SpecificRu_is_empty}
        ${current_tiltOffset_value}=     Get_beam_info_value_for_specific_ru_Via_REST_API
        ...    cells_list_under_same_ru=${cellIds_SpecificRu}    connection=${connection}
        ${new_tiltOffset_value}=    Evaluate    ${current_tiltOffset_value}+${1}
        run keyword and continue on failure   Online_Modify_tiltOffset_Via_REST_API   tiltOffset_value=${new_tiltOffset_value}
        ...    cell_list=${cellIds_SpecificRu}    connection=${connection}
        # recovery to old value
        run keyword and continue on failure   Online_Modify_tiltOffset_Via_REST_API   tiltOffset_value=${current_tiltOffset_value}
        ...    cell_list=${cellIds_SpecificRu}    connection=${connection}
    END

Get_beam_info_value_for_specific_ru_Via_REST_API
    [Documentation]    Author: Dandan Fang
    ...    Arguments:
    ...    ${cell_id}: The identifier of the cell to read.
    ...    ${connection} (optional): The connection alias to use. Defaults to ${CONNECTION_ALIAS}.
    [Arguments]     ${cells_list_under_same_ru}   ${connection}=${CONNECTION_ALIAS}
    Connect to gnb coam via ssl
    ${beamSet_info}=    Create List
    @{MOs_NRCELL_A}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}    timeout=300s
    # performance inprovement by regex match
    ${cellId_regex} =    Evaluate    '|'.join(str(x) for x in ${cells_list_under_same_ru})
    @{tiltOffset_list}=    Create List
    FOR    ${index}  ${value}    IN ENUMERATE   @{MOs_NRCELL_A}
        ${dist_name} =    Get From Dictionary    ${value}    distName
        ${is_match} =    Evaluate   re.search(r'${cellId_regex}', '${dist_name}')
        IF    ${is_match}
            ${parameters} =   Get From Dictionary    ${value}   parameters
            ${beamSet} =    Get From Dictionary    ${parameters}    beamSet
            ${tiltOffset_value} =    Get From Dictionary    ${beamSet}    tiltOffset
            Append To List    ${tiltOffset_list}    ${tiltOffset_value}
        END
    END

    ${cell_tiltoffset_set}=  Evaluate   set(@{tiltOffset_list})
    ${length_set} =    Get Length    ${cell_tiltoffset_set}
    Should Be Equal    ${length_set}    ${1}
    [Return]    ${tiltOffset_list[0]}

Online_Modify_tiltOffset_Via_REST_API
    [Documentation]    Author: Dandan Fang
    ...    Arguments:
    ...    ${celltype}: The new value to set for tiltOffset.
    ...    ${cell_id}: The identifier of the cell to modify.
    ...    ${connection} (optional): The connection alias to use. Defaults to ${CONNECTION_ALIAS}.
    [Arguments]     ${tiltOffset_value}  ${cell_list}   ${connection}=${CONNECTION_ALIAS}  ${timeout}=5min
    log to console    start modify cell-${cell_list} tiltOffset as ${tiltOffset_value}
    ${params_for_update}=    Create List
    FOR  ${cell_id}  IN  @{cell_list}
        ${tiltOffset_dict}  create Dictionary    tiltOffset=${tiltOffset_value}
        ${value_list}    Create List    ${tiltOffset_dict}
        ${beamset_dict}    evaluate
        ...    dict(dist_name='${DN_NRBTS}/NRCELL-${cell_id}', parameter='beamSet', value=${value_list})
        Append To List    ${params_for_update}    ${beamset_dict}
    END

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${GNB_INDEX}    connection=${CONNECTION_ALIAS}
    Wait Until Keyword Succeeds    5min    10s    Get alarms to check