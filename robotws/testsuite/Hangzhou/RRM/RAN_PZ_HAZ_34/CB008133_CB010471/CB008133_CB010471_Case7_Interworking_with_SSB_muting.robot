*** Settings ***
Documentation      Author: zhaoyang.xu@nokia-sbell.com
...                CB008133 and CB010471 function enable,mute SSB beam ID0/1
Test Timeout      90 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup        SG13 Common Test Setup
Test Teardown     SG13 Common Test Teardown
Force Tags        spark    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config/
#${scfc_name}          SCFC_BTS10317_powersaving_SSB_mute.xml
${scfc_name}          SCFC_BTS10317_powersaving_mumimo_CRT
@{LOG_NAME_LIST}      gnb_snapshot
${ATT_FILE_PATH}      att_8133_case03
${PHASE_FILE_PATH}    phase_8133_case03
${UE_ID}       1
${UE_NUM_SA}     2
${UE_ID_LIST}    1,2,3,4,5,6,7,8
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All

&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'    L2HI_MIRRORING='true'    L2RT_MIRRORING='true'
...    CPRT_MIRRORING='false'    NUMBER_OF_FILES=30    FILE_SIZE_MBYTES=100
${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
@{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio
${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
@{titles_remuaware}    itf_DlMuMimoEnhReConfig.actMuAwareTdSch    itf_DlMuMimoEnhReConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhReConfig.dlMuAwarePrbRatio   itf_DlMuMimoEnhReConfig.dlMuPairingPrbRatio
#${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
${ue_type_0}                          ${tl.ues[0].capabilities[0]}
${max_num_pdsch_perslot}              text|16|//*[@name\="maxNumPdschAllocationPerSlot"]
${max_num_pusch_perslot}              text|16|//*[@name\="maxNumPuschAllocationPerSlot"]
${max_num_layer_permurbg}             text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
#${actDlMuMimoEnh}                     text|false|//*[@name\="actDlMuMimoEnh"]
${scfc_configuration}                 ${CURDIR}/config/SCFC_BTS10317_powersaving_mumimo_CRT.xml
${swconfig_file}                      ${CURDIR}/config/swconfig.txt

*** Test Cases ***
CB008133_CB010471_Case7_Interworking_with_SSB_muting
    Step1:Commission the above configuration on WebUI
    step2:attach UEs and send full buffer and check logs
    Step3:get PM counter and check cell status_notEnergySaving
    step4:stop UE1 DL tput and check cell status_reducedEnergySaving
    step5:send UE1 DL tput again and check cell status_notEnergySaving
    step6:stop all UEs data and detach all UEs


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console    \n--------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    GNB Upload Swconfig           ${swconfig_file}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    ${modify_list}    create list
    ...    ${max_num_pdsch_perslot}    ${max_num_pusch_perslot}    ${max_num_layer_permurbg}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console    \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Stop Collecting GNB Syslog in 'before_onair' File


step2:attach UEs and send full buffer and check logs
    Log To Console    \n-------------step2:attach UEs--------------
    Start capture only gnb syslog in 'ue_attach' file
    Spark UE Attach    ue_index=1    power_reset=true
    Spark UE Send DL Traffic    ue_index=1    send_traffic=115MKbits/sec    send_duration=600    apn_address=wustatic
    ...    ue_mode=None
    Spark UE Attach    ue_index=2    power_reset=true
    Spark UE Send DL Traffic    ue_index=2    send_traffic=1150MKbits/sec    send_duration=600    apn_address=wustatic
    ...    ue_mode=None
    Wait '10s' for stabible
    Log To Console   ”Start GNB Ttitrace With Streaming Mode”
    #Start collect ttitrace
    #Wait for '1s' to stop ttitrace with name'tti_false'
    Stop Collecting GNB Syslog in 'ue_attach' File

Step3:get PM counter and check cell status_notEnergySaving
    Log To Console    \n-------------Step3:get PM counter and check cell status_notEnergySaving--------------
    Start capture only gnb syslog in 'step3_notEnergySaving' file
    Wait '240s' for stabible    #check if cell into powerReducedStatus
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step3_notEnergySaving${/}
    ${Count_M55601C02002}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55601C02002    cell_id=1
    set_test_variable    ${Count_M55601C02002}
    run keyword and continue on failure   Should Be True    ${Count_M55601C02002} == 0
    Stop Collecting GNB Syslog in 'step3_notEnergySaving' File

step4:stop UE1 DL tput and check cell status_reducedEnergySaving
    Log To Console    \n-------------step4:stop UE5 DL tput and check cell status_powerReducedStatus--------------
    Start capture only gnb syslog in 'step4_reducedEnergySaving' file
    Spark UE Stop traffic    dl    ue_index=2    apn_address=wustatic    ue_mode=None
    Wait '300s' for stabible    #Wait cell enter into powerReduced status

	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step4_reducedEnergySaving${/}
    ${Count_M55601C02002}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55601C02002    cell_id=1
    set_test_variable    ${Count_M55601C02002}
    run keyword and continue on failure   Should Be True    ${Count_M55601C02002} > 0
    Stop Collecting GNB Syslog in 'step4_reducedEnergySaving' File

step5:send UE1 DL tput again and check cell status_notEnergySaving
    Log To Console    \n-------------step5:send UE5 DL tput again and check cell status_notEnergySaving--------------
    Start capture only gnb syslog in 'step5_notEnergySaving' file
    Spark UE Send DL Traffic    ue_index=2    send_traffic=1150MKbits/sec    send_duration=800    apn_address=wustatic
    ...    ue_mode=None
    Wait '240s' for stabible    #wait cell enter into notEnergySaving status

	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step5_notEnergySaving${/}
    ${Count_M55601C02002}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55601C02002    cell_id=1
    set_test_variable    ${Count_M55601C02002}
    run keyword and continue on failure    Should Be True    ${Count_M55601C02002} == 0

    Stop Collecting GNB Syslog in 'step5_notEnergySaving' File


step6:stop all UEs data and detach all UEs
    Log To Console   \n-------------step6:stop all UEs data and detach all UEs---------------
	Start capture only gnb syslog in 'step6_detach_ue' file
    #Spark UE Stop traffic    dl    ue_index=0
    Spark UE Detach    ue_index=1
    #Spark UE Stop traffic    dl    ue_index=1
    Spark UE Detach    ue_index=2
    Stop Collecting GNB Syslog in 'step6_detach_ue' File


Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}
    [Return]    ${dl_expect_pcell}[0]
