*** Settings ***
Documentation     author: Qian Jianwu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: jianwu.qian@nokia-sbell.com

Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${TS_CASE_LOG_PATH}     /home/ute/dir/
${UE_type}    ${tl.ues[-1].capabilities[-1]}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${scf_path}    ${commissionings_path}/HGZ/${testline_name}
${8T8R_scf_name}      SCF_8T8R_SBTS00.xml
${2cells_scf_name}    2cells_scf.xml
${WEBUI_ADDR}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${SCF_with_22R2}    SCF_SBTS22R2.xml
${SCF_with_22R3}    SCF_SBTS22R3.xml
${SCF_with_Trunk}    SCF_SBTS00.xml

*** Keywords ***
Common Case Setup For 6293
    log to console    \n***Common Case Setup For 6293***
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    Active related branch CPRI SCF and wait onair

Common Case Teardown For 6293
    log to console    \n***Common Case Teardown For 6293***
    Run Keyword And Ignore Error    UE Teardown
    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM selenium logout

UE Teardown
    log to console    \n***UE Teardown***
    UE Stop Traffic According To Direction
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Scf Commition And Wair For On-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
    log to console    \n***Scf commition and wair for on-air***
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air

Active related branch CPRI SCF and wait onair
    ${sbts_temp_22R2}    run keyword and return status     Should Contain   ${Active_SW_version}    SBTS22R2
    ${sbts_temp_22R3}    run keyword and return status     Should Contain   ${Active_SW_version}    SBTS22R3
    ${sbts_temp_trunk}    run keyword and return status     Should Contain   ${Active_SW_version}    SBTS22R4
	run keyword if
    ...    ${sbts_temp_22R2}==${True}    Active 22R2 SCF
    ...    ELSE IF      ${sbts_temp_22R3}==${True}    Active 22R3 SCF
	...    ELSE IF      ${sbts_temp_trunk}==${True}    Active trunk SCF

Active 22R2 SCF
    Scf commition and wair for on-air    scf_name=${scf_path}/${SCF_with_22R2}

Active 22R3 SCF
    Scf commition and wair for on-air    scf_name=${scf_path}/${SCF_with_22R3}

Active trunk SCF
    Scf commition and wair for on-air    scf_name=${scf_path}/${SCF_with_Trunk}

UE Prepare And Attach
    Log To Console    \n***UE Prepare And Attach***
    #Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    Log To Console    \n***UE start traffic***
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=1200    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=1200    ue_type=${ue_type}    iperf_type=via_command

UE Stop Traffic According To Direction
    [Arguments]    ${tp_direction}=both
    log to console      \n***UE Stop Traffic According To Direction***
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}

Change Single Parameter Online
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}    ${connection}=GNB_OAM
    log to console    \n***Change Single Parameter Online***
    coam.perform_parameter_recommissioning       ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=${connection}

Change Multiple Parameter Online
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}
    log to console    \n***Change Multiple Parameter Online***
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set Default Value For RFTHLD
    Log To Console    \n***Set Default Value For RFTHLD***
    Selenium Login With Version
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1
    ...    object_class_name=TEST    id_value=${1}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFTHLD    is_load_default_values=${True}    id_value=${1}    timeout=15
    selenium_coam.remove_element    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ...    filter_param=LTE band RF test thresholds
    ...    abbr=bandRfTestThresholds
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]  COAM selenium logout

Verify Value For RFTHLD
    [Arguments]  ${totalRFPowerHighThreshold}=${120}    ${totalRFPowerLowThreshold}=${0.1}    ${rFPowerErrorHighThreshold}=${8}
    ...    ${rFPowerErrorLowThreshold}=${-8}    ${rxAntennaRSSIHighThreshold}=${-30}    ${rxAntennaRSSILowThreshold}=${-110}
    ...    ${rxAntennaRTWPHighThreshold}=${-30}    ${rxAntennaRTWPLowThreshold}=${-110}    ${txAntennaVSWRHighThreshold}=${3}
    Log To Console    \n***Verify Value For RFTHLD***
    Selenium Login With Version
    ${modify_params}    create list
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Total RF power high threshold    p_name=totalRFPowerHighThreshold    value=${totalRFPowerHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Total RF power low threshold    p_name=totalRFPowerLowThreshold    value=${totalRFPowerLowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}  create dictionary    dist_name=${dist_name}
    ...    filter_param=RF power error high threshold    p_name=rFPowerErrorHighThreshold    value=${rFPowerErrorHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}  create dictionary    dist_name=${dist_name}
    ...    filter_param=RF Power error low threshold    p_name=rFPowerErrorLowThreshold    value=${rFPowerErrorLowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=High RSSI threshold    p_name=rxAntennaRSSIHighThreshold    value=${rxAntennaRSSIHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Low RSSI threshold    p_name=rxAntennaRSSILowThreshold    value=${rxAntennaRSSILowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=RTWP high threshold    p_name=rxAntennaRTWPHighThreshold    value=${rxAntennaRTWPHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=RTWP low threshold    p_name=rxAntennaRTWPLowThreshold    value=${rxAntennaRTWPLowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=TX antenna VSWR high threshold    p_name=txAntennaVSWRHighThreshold    value=${txAntennaVSWRHighThreshold}
    append to list    ${modify_params}    ${item}
    Change Multiple Parameter Online    modify_params=${modify_params}    is_activate=${False}
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_definition_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${11}
    selenium_coam.undo_changes
    [Teardown]  COAM selenium logout

Set RSSI Threshold
    [Arguments]    ${low_RSSI_threshold}=${-150}    ${high_RSSI_threshold}=${-30}
    Log To Console    \n***Set RSSI Threshold***
    Selenium Login With Version
    ${modify_params}    create list
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=High RSSI threshold    p_name=rxAntennaRSSIHighThreshold    value=${high_RSSI_threshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Low RSSI threshold    p_name=rxAntennaRSSILowThreshold    value=${low_RSSI_threshold}
    append to list    ${modify_params}    ${item}
    Change Multiple Parameter Online    modify_params=${modify_params}    is_activate=${True}
    [Teardown]  COAM selenium logout

Set SINR Threshold
    [Arguments]    ${low_SINR_threshold}=${1.5}    ${high_SINR_threshold}=${3.5}
    Log To Console    \n***Set RSSI Threshold***
    Selenium Login With Version
    ${modify_params}    create list
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Uplink threshold for disabling transform precoder for a UE
    ...    p_name=ulTransPrecodeOffSinrThresh    value=${high_SINR_threshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Uplink threshold for disabling transform precoder for a UE
    ...    p_name=ulTransPrecodeOnSinrThresh    value=${low_SINR_threshold}
    append to list    ${modify_params}    ${item}
    Change Multiple Parameter Online    modify_params=${modify_params}    is_activate=${True}
    [Teardown]  COAM selenium logout

Add RFREQ Dist
    [Arguments]    ${id_value}=${1}    ${targetLnCelId}=${None}
    Log To Console    \n***Add RFREQ Dist***
    Selenium Login With Version
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFREQ    id_value=${id_value}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ-${id_value}
    ...    abbr=targetCellType    filter_param=Target cell type for the test    new_value=NR
    Run keyword if   ${targetLnCelId}!=${None}  selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ-${id_value}
    ...    abbr=targetLnCelId    filter_param=Target cell test identifier    new_value=${targetLnCelId}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]  COAM selenium logout

Add RFSTATREQ Dist
    [Arguments]    ${id_value}=${1}
    Log To Console    \n***Add RFREQ Dist***
    Selenium Login With Version
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFSTATREQ    id_value=${id_value}    timeout=15
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]  COAM selenium logout

Get RFRES Result
    [Arguments]    ${RFREQ_id}=${1}    ${RFRES_id}=${1}
    Log To Console    \n***Get RFRES Result***
    Connect to gnb coam via ssl
    @{test_result}    coam.get_managed_objects    class_name=RFRES_R    connection=GNB_OAM
    #&{return_result}    Create Dictionary
    FOR  ${result_in_test}  IN  @{test_result}
	  ${result}=    Run Keyword And Return Status   should contain  ${result_in_test}[distName]
	  ...    RFREQ_CONF_M-${RFREQ_id}/RFRES_R-${RFRES_id}
      exit for loop if    ${result} == True
    END
    [Return]    ${result_in_test}[parameters]
    [Teardown]    coam.teardown    connection=GNB_OAM

Validate RFREQ Parameter
    [Arguments]    ${id_value}=${1}    ${cell_num}=${1}
    Log To Console    \n***Validate RFREQ Parameter***
    Selenium Login With Version
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFREQ    id_value=${id_value}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ-${id_value}
    ...    abbr=targetCellType    filter_param=Target cell type for the test    new_value=NR
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ-${id_value}
    ...    abbr=targetCellId    filter_param=Target cell test identifier    new_value=${-1}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ-${id_value}
    ...    abbr=targetCellId    filter_param=Target cell test identifier    new_value=${cell_num}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${0}
    ${cell_num_invalid}    evaluate    ${cell_num} + ${1}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ-${id_value}
    ...    abbr=targetCellId    filter_param=Target cell test identifier    new_value=${cell_num_invalid}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${1}
    [Teardown]  Run Keywords    selenium_coam.undo_changes    AND    COAM selenium logout

Validate RFSTATREQ Parameter
    [Arguments]    ${id_value}=${1}    ${RU_num}=${1}
    Log To Console    \n***Validate RFSTATREQ Parameter***
    Selenium Login With Version
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFSTATREQ    id_value=${id_value}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-${id_value}
    ...    abbr=targetRModId    filter_param=Target Radio Module test identifier    new_value=${-1}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-${id_value}
    ...    abbr=targetRModId    filter_param=Target Radio Module test identifier    new_value=${RU_num}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${0}
    ${RU_num_invalid}    evaluate    ${RU_num} + ${1}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-${id_value}
    ...    abbr=targetRModId    filter_param=Target Radio Module test identifier    new_value=${RU_num_invalid}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${1}
    [Teardown]  Run Keywords    selenium_coam.undo_changes    AND    COAM selenium logout

Get RU Temperature
    [Arguments]    ${ru_index}=${1}
    Log To Console    \n***Get RU Temperature***
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    csn.send command    command=echo "/ action create ThermometerDevice /PulsarPam1 /module/ASC1_internal_BMR "|frmonShellClient localhost 2000
    ...    connection=RU_${ru_index}
    ${temperature}    csn.execute    echo "/PulsarPam1 get temperature"|frmonShellClient localhost 2000    connection=RU_${ru_index}
    csn.Disconnect    connection=RU_${ru_index}
    @{tmp_1}    split string    ${temperature}    separator=.
	${tmp_2}    split string    ${tmp_1}[0]    separator=
    [Return]    ${tmp_2}[-1]
    [Teardown]    csn.Disconnect  connection=ASIK Master

Perform RU Reset via WebEM
    [Arguments]    ${ru_index}=${1}
    Log To Console    \n***Perform RU Reset via WebEM***
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    20min    1min    COAM Check GNB cell on air
    [Teardown]    coam.teardown    connection=GNB_OAM
