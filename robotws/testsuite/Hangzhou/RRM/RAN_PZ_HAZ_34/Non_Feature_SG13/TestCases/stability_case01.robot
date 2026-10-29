*** Settings ***
Documentation     Stability case
Test Timeout      120 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup
Test Teardown    SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABIOB1_ABIPB2_1xAEHC    7_5_UTE5G402T37374


Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${SCFC_NAME}    scf_stability_case01.xml
${UE_ID}       1
${UE_NUM_SA}    1

${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${NRCELL1_CELLID}          612335616
${NRCELL2_CELLID}          612335618
&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30     FILE_SIZE_MBYTES=100


*** Test Cases ***
5GC000545_ET_C005_Dynamic_Transform_Precoder_Switching_With_Pi2BPSK_PTRS_Enable_TDD_NSA
     Step1:Commission the above configuration on WebUI
     step3:site reset and check starup time



*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
    Modify GNB swconfig
    ${Golden_SCF_Path}=    CI_commssion.Get SCF File Path    testline=${TL_NAME}    stream=${SW_VERSION}
    Set Test Variable    ${Golden_SCF_Path}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${Golden_SCF_Path}    ${scfc_path}
#    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Stop Collecting GNB Syslog in 'before_onair' File


step2:attach UEs and send full buffer and check logs
    [Arguments]    ${pre_throughput}
    Log To Console   \n-------------step2:attach UEs--------------

	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true
	    Wait '10s' for stabible
	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=1630MKbits/sec    send_duration=180    apn_address=dxdata4
#	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=830MKbits/sec    send_duration=180    apn_address=dxdata4
	    ...    ue_mode=None

    END

#   record cell throughput and compare with previsous throughput
	Wait '10s' for stabible
	${cellsid}    create list    ${NRCELL1_CELLID}    ${NRCELL2_CELLID}
	Log To Console   ${cellsid}
	${tput_result}    Spark UE Check Tput    ue_index=${num}    min_percent=0.75    expect_traffic=1450
	...    check_source=aasyslog    duration=2m    cells=${cellsid}    actCarrierAggregation=true
    ${tput}    Set Variable    ${tput_result}[0]
    ${exec_throughput}    Get from Dictionary    ${tput}    average

	${delta1}=     Evaluate    abs(${exec_throughput} - ${pre_throughput}) if ${pre_throughput} != 0 else 0
	${delta2}=     Evaluate     (${delta1}/${pre_throughput})*100 if ${pre_throughput} !=0 else 0

	Log To Console   Delta throughput from previous execution is : ${delta1} Mbps
    Log To Console   Delta of percentage from previous execution is : ${delta2} %

    Run Keyword If    ${delta2} > 10
    ...    Fail    Delta is more than 10%
    ${pre_throughput}    Set Variable    ${exec_throughput}
    [Return]    ${pre_throughput}

step3:site reset and check starup time
    # add allow alarm list

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


Modify GNB swconfig
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
