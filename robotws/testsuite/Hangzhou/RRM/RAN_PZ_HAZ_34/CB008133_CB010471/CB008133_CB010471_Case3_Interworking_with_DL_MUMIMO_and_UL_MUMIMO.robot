*** Settings ***
Documentation     CB008133 case
Test Timeout      90 minutes    #testing will terminate if the case run time exceed 90 minutes
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
${scfc_name}          SCFC_BTS10317_powersaving_mumimo_CRT.xml
@{LOG_NAME_LIST}      gnb_snapshot
${ATT_FILE_PATH}      ${CURDIR}/att_8133_case03
${PHASE_FILE_PATH}    ${CURDIR}/phase_8133_case03
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
${scfc_configuration}                 ${CURDIR}/config/SCFC_BTS10317_powersaving_mumimo_CRT.xml
${swconfig_file}                      ${CURDIR}/config/swconfig.txt

*** Test Cases ***
CB008133_CB010471_Case3_Interworking_with_DL_MUMIMO_and_UL_MUMIMO
    #[Tags]    QC_361978
    Step1:Commission the above configuration on WebUI
    step2:wait cell into reducedEnergySaving status
    step3:attach UEs and send full buffer
    Step4:get PM counter and check cell status_notEnergySaving
    step5:stop all UE DL tput and check cell status_reducedEnergySaving
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
#    Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}    frequency=2450_1_ALL
    Stop Collecting GNB Syslog in 'before_onair' File


step2:wait cell into reducedEnergySaving status
    Log To Console    \n-------------step2:wait cell into reducedEnergySaving status--------------
    sleep    360    #Wait cell enter into powerReduced status

    ${remian_time}    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remian_time}    evaluate    ${remian_time}+60
    Wait Throughput Timer  ${remian_time}
    ${passed}=  Run Keyword And Return Status  Download Latest Pmcounter  local_path=${TEST_LOG_DIRECTORY()}${/}step2/    source_path=/tmp/
    Run Keyword If  not ${passed}  Download Latest Pmcounter  local_path=${TEST_LOG_DIRECTORY()}${/}step2/  source_path=/tmp/  suffix=gz
    ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST_LOG_DIRECTORY()}/step2/*.xz
    ...    ELSE    remove_file    ${TEST_LOG_DIRECTORY()}/step2/*.gz
    ${counter_file}    list files in directory    ${TEST_LOG_DIRECTORY()}/step2/    pattern=*.ANY.*
    set test variable    ${counter_file}
    ${Count_M55601C02002}    get_counter_value_from_counter_file    ${TEST_LOG_DIRECTORY()}/step2/${counter_file[0]}    M55601C02002    1
    log    4UE\_MCS\_total\_pm\_counter\_ul\_nonca\_throughput\_open\_ulmumimo ${Count_M55601C02002}    console=${True}
    set_test_variable    ${Count_M55601C02002}
    Should Be True    ${Count_M55601C02002} > 0


step3:attach UEs and send full buffer
    Log To Console    \n-------------step3:attach UEs and send full buffer--------------
    Start capture only gnb syslog in 'after_onair' file
    Spark UE Attach    ue_index=1    power_reset=true
    Spark UE Send DL Traffic    ue_index=1    send_traffic=1150MKbits/sec    send_duration=1200    apn_address=wustatic
    ...    ue_mode=None
    Spark UE Send UL Traffic    ue_index=1    send_traffic=180MKbits/sec    send_duration=1200    apn_address=wustatic
    ...    ue_mode=None
    Spark UE Attach    ue_index=2    power_reset=true
    Spark UE Send DL Traffic    ue_index=2    send_traffic=1150MKbits/sec    send_duration=1200    apn_address=wustatic
    ...    ue_mode=None
    Spark UE Send UL Traffic    ue_index=2    send_traffic=180MKbits/sec    send_duration=1200    apn_address=wustatic
    ...    ue_mode=None


Step4:get PM counter and check cell status_notEnergySaving
    Log To Console    \n-------------Step4:get PM counter and check cell status_notEnergySaving--------------
    Wait '240s' for stabible    #check if cell into powerReducedStatus

    #: FOR    ${num}    IN RANGE    0    2
    #\    Run Keyword If   ${num}==0    Spark UE Check Tput    ue_index=${num}    expect_traffic > 100
    #\    Run Keyword If    ${num}==0    Spark UE Check Tput    ue_index=${num}    expect_traffic < 1000

    ${remian_time}    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remian_time}    evaluate    ${remian_time}+60
    Wait Throughput Timer  ${remian_time}
    ${passed}=  Run Keyword And Return Status  Download Latest Pmcounter  local_path=${TEST_LOG_DIRECTORY()}${/}step4/    source_path=/tmp/
    Run Keyword If  not ${passed}  Download Latest Pmcounter  local_path=${TEST_LOG_DIRECTORY()}${/}step4/  source_path=/tmp/  suffix=gz
    ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST_LOG_DIRECTORY()}/step4/*.xz
    ...    ELSE    remove_file    ${TEST_LOG_DIRECTORY()}/step4/*.gz
    ${counter_file}    list files in directory    ${TEST_LOG_DIRECTORY()}/step4/    pattern=*.ANY.*
    set test variable    ${counter_file}
    ${Count_M55601C02002}    get_counter_value_from_counter_file    ${TEST_LOG_DIRECTORY()}/step4/${counter_file[0]}    M55601C02002    1
    log    4UE\_MCS\_total\_pm\_counter\_ul\_nonca\_throughput\_open\_ulmumimo ${Count_M55601C02002}    console=${True}
    set_test_variable    ${Count_M55601C02002}
    Should Be True    ${Count_M55601C02002} == 0

step5:stop all UE DL tput and check cell status_reducedEnergySaving
    Log To Console    \n-------------step5:stop all UE DL tput and check cell status_reducedEnergySaving--------------
    Spark UE Stop traffic    dl    ue_index=1    ue_mode=None
    Spark UE Stop traffic    dl    ue_index=2    ue_mode=None
#    Spark UE Detach    ue_index=1
#    Spark UE Detach    ue_index=2
    sleep    420    #Wait cell enter into powerReduced status

    ${remian_time}    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remian_time}    evaluate    ${remian_time}+60
    Wait Throughput Timer  ${remian_time}
    ${passed}=  Run Keyword And Return Status  Download Latest Pmcounter  local_path=${TEST_LOG_DIRECTORY()}${/}step5/    source_path=/tmp/
    Run Keyword If  not ${passed}  Download Latest Pmcounter  local_path=${TEST_LOG_DIRECTORY()}${/}step5/  source_path=/tmp/  suffix=gz
    ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST_LOG_DIRECTORY()}/step5/*.xz
    ...    ELSE    remove_file    ${TEST_LOG_DIRECTORY()}/step5/*.gz
    ${counter_file}    list files in directory    ${TEST_LOG_DIRECTORY()}/step5/    pattern=*.ANY.*
    set test variable    ${counter_file}
    ${Count_M55601C02002}    get_counter_value_from_counter_file    ${TEST_LOG_DIRECTORY()}/step5/${counter_file[0]}    M55601C02002    1
    log    4UE\_MCS\_total\_pm\_counter\_ul\_nonca\_throughput\_open\_ulmumimo ${Count_M55601C02002}    console=${True}
    set_test_variable    ${Count_M55601C02002}
    Should Be True    ${Count_M55601C02002} > 0

step6:stop all UEs data and detach all UEs
    Log To Console   \n-------------step6:stop all UEs data and detach all UEs---------------
    #Spark UE Stop traffic    dl    ue_index=1
    Spark UE Detach    ue_index=1
    #Spark UE Stop traffic    dl    ue_index=2
    Spark UE Detach    ue_index=2

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}
    [Return]    ${dl_expect_pcell}[0]

Set UE pos
    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${ATT_FILE_PATH}    ${parent_dir}/TestData/${PHASE_FILE_PATH}
    ...    frequency=2450_1_ALL
