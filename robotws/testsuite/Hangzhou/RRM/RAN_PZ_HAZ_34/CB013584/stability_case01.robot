*** Settings ***
Documentation     Stability case
Test Timeout      180 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup
Test Teardown    SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABIOB1_ABIPB2_1xAEHC    7_5_UTE5G402T37374


Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot


*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${SCFC_NAME}    scf_stability_case01.xml
${UE_ID}       1
${UE_NUM_SA}    1

${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${NRCELL1_CELLID}    612155893

&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30     FILE_SIZE_MBYTES=100


*** Test Cases ***
stability_case01
     Step1:Commission the above configuration on WebUI
     step3:site reset and check starup time
     step4:site reset and check starup time lock ru
     step5:site reset and check starup time lock cells
     step6:site reset and check startup time lock bbmod



*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
    #Modify GNB swconfig
    ${Golden_SCF_Path}=    CI_commssion.Get SCF File Path    testline=${TL_NAME}    stream=${SW_VERSION}
    Set Test Variable    ${Golden_SCF_Path}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${Golden_SCF_Path}    ${scfc_path}
#    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#	    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
#	    set suite variable    ${dl_peak_tput}
#	    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Stop Collecting GNB Syslog in 'before_onair' File


step2:attach UEs and send full buffer and check logs
    [Arguments]    ${pre_throughput}
    Log To Console   \n-------------step2:attach UEs--------------

	FOR    ${num}    IN RANGE    0    ${UE_NUM_SA}
	    Log To Console    UE${num} attachs
        ${ue_type}    translate power ue type from testline    ${num}
	    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${num}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${num}    ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
        power_ue.Start traffic   ue_index=${num}    ue_type=${ue_type}   direction=dl   throughput=1200M    duration=1500
        power_ue.Start traffic   ue_index=${num}    ue_type=${ue_type}   direction=ul   throughput=450M    duration=1500
    END
#   record cell throughput and compare with previsous throughput
	Wait '10s' for stabible
	${cellsid}    create list    ${NRCELL1_CELLID}
	Log To Console   ${cellsid}
	#${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.9
	#${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.9
	${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=1m    check_source=aasyslog
     ${tput_result}   power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}   log=${tput_log}
     ...    target_throughput=200   target_avg_percent=0.98    min_percent=0.8    check_source=aasyslog
    ${tput}    Set Variable    ${tput_result}[0]
    ${exec_throughput}    Get from Dictionary    ${tput}    average
	${delta1}=     Evaluate    abs(${exec_throughput} - ${pre_throughput}) if ${pre_throughput} != 0 else 0
	${delta2}=     Evaluate     (${delta1}/${pre_throughput})*100 if ${pre_throughput} !=0 else 0
	Log To Console   Delta throughput from previous execution is : ${delta1} Mbps
     Log To Console   Delta of percentage from previous execution is : ${delta2} %

    Run Keyword If    ${delta2} > 10
    ...    Fail    Delta is more than 10%
    ${pre_throughput}    Set Variable    ${exec_throughput}
    Multi UE Detach And Stop Traffic
    [Return]    ${pre_throughput}


step3:site reset and check starup time
    # add allow alarm list
    Log To Console   \n-------------step3:site reset and check starup time--------------
    ${alarm_dict1}    Create Dictionary   faultId=${{int(61652)}}
    ${alarm_dict2}    Create Dictionary   faultId=${{int(4654)}}
    ${alarm_dict3}    Create Dictionary   faultId=${{int(61524)}}
    ${alarm_dict4}    Create Dictionary   faultId=${{int(4655)}}
    ${alarm_dict5}    Create Dictionary   faultId=${{int(61649)}}
    ${alarm_dict6}    Create Dictionary   faultId=${{int(4592)}}
    ${allow_alarms}    Create List    ${alarm_dict1}    ${alarm_dict2}    ${alarm_dict3}    ${alarm_dict4}    ${alarm_dict5}    ${alarm_dict6}
    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60
    Start capture only gnb syslog in 'after_onair' file
    ${pre_time}    Set Variable    0
    ${pre_throughput}    Set Variable    0
    ${delta_threshold}    Set Variable    20
    FOR	${i}	IN RANGE	2
        Perform BTS Site Reset
        Wait '30s' for stabible
        ${start_time}=    Get Time     epoch
        Wait until keyword succeeds    1500s    10s    Verify BTS Is Onair
        ${end_time}=     Get Time    epoch
        ${execution_time}=    Evaluate    ${end_time}-${start_time}
        ${delta1}=     Evaluate    abs(${execution_time} - ${pre_time}) if ${pre_time} != 0 else 0
        ${delta2}=     Evaluate     (${delta1}/${pre_time})*100 if ${pre_time} !=0 else 0

        Log To Console   Execution duration for ${i} reset : ${execution_time} seconds
        Log To Console   Delta seconds from previous execution is : ${delta1} seconds
        Log To Console   Delta of percentage from previous execution is : ${delta2} %

        ##fail case if the delta is large than threshold
        Run Keyword if    ${delta2} > ${delta_threshold}
        ...    Fail    Delta2 is large than 20%
        ${pre_time}    Set Variable    ${execution_time}

        ### check throuhgput after on air
        Wait '40s' for stabible
        ${pre_throughput2}    step2:attach UEs and send full buffer and check logs    ${pre_throughput}
        ${pre_throughput}   set variable   ${pre_throughput2}
    END
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60
    [Teardown]    COAM Teardown gnb connections
    Stop capture only gnb syslog in 'after_onair' file

step4:site reset and check starup time lock ru
    # add allow alarm list
    Log To Console   \n-------------step4:site reset and check starup time lock ru--------------
    ${alarm_dict1}    Create Dictionary   faultId=${{int(61652)}}
    ${alarm_dict2}    Create Dictionary   faultId=${{int(4654)}}
    ${alarm_dict3}    Create Dictionary   faultId=${{int(61524)}}
    ${alarm_dict4}    Create Dictionary   faultId=${{int(4655)}}
    ${alarm_dict5}    Create Dictionary   faultId=${{int(61649)}}
    ${alarm_dict6}    Create Dictionary   faultId=${{int(4592)}}
    ${allow_alarms}    Create List    ${alarm_dict1}    ${alarm_dict2}    ${alarm_dict3}    ${alarm_dict4}    ${alarm_dict5}    ${alarm_dict6}
    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60

    ${ru_index_list}    get all ru index
    Start capture only gnb syslog in 'after_onair' file
    #${pre_time}    Set Variable    0
    ${pre_throughput}    Set Variable    0
    ${delta_threshold}    Set Variable    20
    Set Global Variable      ${Active_SW_version}    ${SW_BRANCH}
    Selenium Login And Disable Screen Lock
    FOR	${i}	IN RANGE	2
        Perform all RRU block unblock    ${ru_index_list}
        Wait '30s' for stabible


        ### check throuhgput after on air
        ${pre_throughput2}    step2:attach UEs and send full buffer and check logs    ${pre_throughput}
        ${pre_throughput}   set variable   ${pre_throughput2}
    END
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60
    [Teardown]    Combine teardown
    Stop capture only gnb syslog in 'after_onair' file

step5:site reset and check starup time lock cells
    # add allow alarm list
    Log To Console   \n-------------step5:site reset and check starup time lock cells--------------
    ${alarm_dict1}    Create Dictionary   faultId=${{int(61652)}}
    ${alarm_dict2}    Create Dictionary   faultId=${{int(4654)}}
    ${alarm_dict3}    Create Dictionary   faultId=${{int(61524)}}
    ${alarm_dict4}    Create Dictionary   faultId=${{int(4655)}}
    ${alarm_dict5}    Create Dictionary   faultId=${{int(61649)}}
    ${alarm_dict6}    Create Dictionary   faultId=${{int(4592)}}
    ${allow_alarms}    Create List    ${alarm_dict1}    ${alarm_dict2}    ${alarm_dict3}    ${alarm_dict4}    ${alarm_dict5}    ${alarm_dict6}
    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/
    ...    connection=GNB_OAM    timeout=60

    Start capture only gnb syslog in 'after_onair' file
    #${pre_time}    Set Variable    0
    ${pre_throughput}    Set Variable    0
    ${delta_threshold}    Set Variable    20
    Set Global Variable      ${Active_SW_version}    ${SW_BRANCH}
    ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List    connection=GNB_OAM
    Selenium Login And Disable Screen Lock
    FOR	${i}	IN RANGE	2
        ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List    connection=GNB_OAM
        All Cells lock unlock    nr_cell_list=${nr_cell_list}    lte_cell_list=${lte_cell_list}    connection=GNB_OAM
        Wait '30s' for stabible


        ### check throuhgput after on air
        ${pre_throughput2}    step2:attach UEs and send full buffer and check logs    ${pre_throughput}
        ${pre_throughput}   set variable   ${pre_throughput2}
    END
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/
    ...    connection=GNB_OAM    timeout=60
    [Teardown]    Combine teardown
    Stop capture only gnb syslog in 'after_onair' file

All Cells lock unlock
     [Arguments]    ${nr_cell_list}    ${lte_cell_list}    ${connection}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
     FOR    ${cell}     IN     @{nr_cell_list}
        log to console    | cellid:${cell['globalCellId']} start lock...
        COAM Lock unclock Cell via Change Parameter    celltype=nr    cellid=${cell['globalCellId']}
        ...    operation=Locked    connection=${connection}
        wait until keyword succeeds   3min    30s
        ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}    connection=${connection}
        ...    expected_status='availabilitystatus': 'off line'
        wait until keyword succeeds   3min    30s
        ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}    connection=${connection}
        ...    expected_status='operationalstate': 'disabled'
#        wait until keyword succeeds   3min    20s
#        ...   ADMIN check NR cell availability Status    cell_index=${cell['globalCellId']}
#        ...    expected_status='administrativestate': 'loced'
#        Check other Cells Status except One      cellid=${cell['globalCellId']}

        log to console    | cellid:${cell['globalCellId']} start unlock...
        COAM Lock unclock Cell via Change Parameter    celltype=nr    cellid=${cell['globalCellId']}
        ...    operation=Unlocked    connection=${connection}
        wait until keyword succeeds   10m    1m
        ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}    connection=${connection}
        ...    expected_status='operationalstate': 'enabled'
#        Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
     FOR    ${cell}     IN     @{lte_cell_list}
         log to console    | cellid:${cell['globalCellId']} start lock...
         COAM Lock unclock Cell via Change Parameter    celltype=lte    cellid=${cell['globalCellId']}
         ...    operation=Locked    connection=${connection}
         wait until keyword succeeds   3m    30s
        ...   ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
        ...    expected_status='availabilitystatus': 'off line'
        wait until keyword succeeds   3m    30s
        ...   ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
        ...    expected_status='operationalstate': 'disabled'
#        wait until keyword succeeds   3min    20s
#        ...   ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
#        ...    expected_status='administrativestate': 'loced'
#         Check other Cells Status except One      cellid=${cell['globalCellId']}

         log to console    | cellid:${cell['globalCellId']} start unlock...
         COAM Lock unclock Cell via Change Parameter    celltype=lte    cellid=${cell['globalCellId']}
         ...    operation=Unlocked    connection=${connection}
         wait until keyword succeeds   10m    1m
         ...   ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='operationalstate': 'enabled'
         wait until keyword succeeds   10m    1m
         ...  ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='administrativestate': 'unlocked'
#         Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
      Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair    connection=${connection}
#      [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}


Perform all RRU block unblock
    [Arguments]    ${ru_index_list}
    #Selenium Login And Disable Screen Lock
    FOR  ${lock_id}  IN  @{ru_index_list}
        Sleep    3s
        ${operate_list}    create list    ${lock_id}
        Lock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
        Unlock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
    END

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=0
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}
    [Return]    ${dl_expect_pcell}[0]

Add RD
    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt


Set UE pos
    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${ATT_FILE_PATH}    ${parent_dir}/TestData/${PHASE_FILE_PATH}
    ...    frequency=2450_1_ALL

Multi UE Detach And Stop Traffic
    [Arguments]    ${ue_num}=1
    FOR    ${ue_no}    IN RANGE    0    ${ue_num}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
        #Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    power_reset=true
        Run Keyword And Continue On Failure    Qualcom detach    Detach_UE_num=1
    END

Common Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}

Qualcom detach
     [Arguments]    ${Detach_UE_num}=4
     FOR    ${ue_index}    IN RANGE    0    ${Detach_UE_num}
         Log To Console    UE${ue_index} detach
         ${ue_type}    translate power ue type from testline    ${ue_index}
	     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
         power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

Modify GNB swconfig
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

Combine teardown
    COAM Teardown gnb connections
    Selenium Logout And Close Browser

ADMIN check NR cell status
    [Arguments]    ${cell_index}   ${connection}    ${expected_status}=unblocked
    ${nrcell}   COAM Get Managed Objects   class_name=NRCELL_R    connection=${connection}
    FOR  ${cellinfo}   IN  @{nrcell}
         ${nrcell_r}    Run Keyword If   ${cellinfo['distName'].count('NRCELL_R-${cell_index}')} > 0
         ...   set variable    ${cellinfo['distName']}
         exit for loop if   ${cellinfo['distName'].count('NRCELL_R-${cell_index}')} > 0
    END
    ${output}    COAM Get Cell Info   cell_id=${nrcell_r}    connection=${connection}
    ${output}    convert to string    ${output}
    should contain    ${output.lower()}    ${expected_status}

step6:site reset and check startup time lock bbmod
    Log To Console   \n-------------step6:site reset and check starup time lock bbmod--------------
    # add allow alarm list
    ${alarm_dict1}    Create Dictionary   faultId=${{int(61652)}}
    ${alarm_dict2}    Create Dictionary   faultId=${{int(4654)}}
    ${alarm_dict3}    Create Dictionary   faultId=${{int(61524)}}
    ${alarm_dict4}    Create Dictionary   faultId=${{int(4655)}}
    ${alarm_dict5}    Create Dictionary   faultId=${{int(61649)}}
    ${alarm_dict6}    Create Dictionary   faultId=${{int(4592)}}
    ${allow_alarms}    Create List    ${alarm_dict1}    ${alarm_dict2}    ${alarm_dict3}    ${alarm_dict4}    ${alarm_dict5}    ${alarm_dict6}
    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}
    ...    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60

    Start capture only gnb syslog in 'after_onair' file
    #${pre_time}    Set Variable    0
    ${pre_throughput}    Set Variable    0
    ${delta_threshold}    Set Variable    20
    Set Global Variable      ${Active_SW_version}    ${SW_BRANCH}
    ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List    connection=GNB_OAM
    ${Golden_SCF_Path}=    CI_commssion.Get SCF File Path    testline=${TL_NAME}    stream=${SW_VERSION}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell    source=${Golden_SCF_Path}
    Selenium Login And Disable Screen Lock
    FOR	${i}	IN RANGE	2
        ${BB_Mod_info}    Get BBMODs info    alias=GNB_OAM
#        All Cells lock unlock    keycheck=${False}    nr_cell_list=${nr_cell_list}    lte_cell_list=${lte_cell_list}    connection=GNB_OAM
        All BBMODs Lock UnLock    bbmods_info=${BB_Mod_info}
        Wait '30s' for stabible


        ### check throuhgput after on air
        ${pre_throughput2}    step2:attach UEs and send full buffer and check logs    ${pre_throughput}
        ${pre_throughput}   set variable   ${pre_throughput2}
    END
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}
    ...    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60
    [Teardown]    Combine teardown
    Stop capture only gnb syslog in 'after_onair' file

All BBMODs Lock UnLock
     [Arguments]    ${bbmods_info}
#    return from keyword if    len(${bbmod_cell_mapping})==${0}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${bbmod}     IN     @{bbmods_info}
        ${bbmod_r}      fetch from right     ${bbmod['internal']}     /
#        continue for loop if   '${bbmod_r}' not in ${bbmod_cell_mapping}
        COAM Lock BBMOD      dist_name=${bbmod['internal']}
        Wait Until Keyword Succeeds   5m   15s   BBMOD RU Cell Status should Disabled
        ...   bbmod_operation=lock     dist_name=${bbmod['configuration']}
        sleep    30s
#        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
        COAM Unlock BBMOD      dist_name=${bbmod['internal']}
        Wait Until Keyword Succeeds   15m   30s   BBMOD RU Cell Status should Enabled   dist_name=${bbmod['configuration']}
#        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair

BBMOD RU Cell Status should Enabled
     [Arguments]     ${dist_name}
     ${bbmod_index}     fetch from right     ${dist_name}     -
     &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=COAM
     Should be equal as strings    ${bbmod_status['status']['operationalState'].lower()}       enabled
     ...    msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}