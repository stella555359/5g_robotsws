*** Settings ***
Documentation     Stability case
Test Timeout      120 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup
Test Teardown    SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABIOB1_ABIPB2_1xAEHC    7_5_UTE5G402T37374

# this case is test for all cell  lock/unblock stability

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
${SCFC_NAME}    SCFC_CB009235_case01.xml
${ATT_FILE_PATH}    att_9235_case01
${PHASE_FILE_PATH}    phase_9235_case01
${UE_ID}       1
${PORT}    5002
${UE_NUM_SA}         1
${UE_ID_LIST}    1,2,3,4,5,6,7,8
${LOW_UE_ID}    4
${HIGH_UE_ID}    6
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${NRCELL1_CELLID}          612335616
${NRCELL2_CELLID}          612335618
${iperf_port}    33001

&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
...    L2RT_MIRRORING='true'   CPRT_MIRRORING='false'    NUMBER_OF_FILES=30     FILE_SIZE_MBYTES=100

${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
@{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio

${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
@{titles_remuaware}    itf_DlMuMimoEnhReConfig.actMuAwareTdSch    itf_DlMuMimoEnhReConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhReConfig.dlMuAwarePrbRatio   itf_DlMuMimoEnhReConfig.dlMuPairingPrbRatio

#${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml

${ue_type_0}                ${tl.ues[0].capabilities[0]}
${max_num_pdsch_perslot}              text|4|//*[@name\="maxNumPdschAllocationPerSlot"]
${max_num_pusch_perslot}              text|4|//*[@name\="maxNumPuschAllocationPerSlot"]
#${max_num_layer_permurbg}              text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]



*** Test Cases ***
Case03_check startup time and throughput change after lock and unlock cell
#    Step1:Commission the above configuration on WebUI
#    step2:attach UEs and send full buffer and check logs
     step3:site reset and check starup time
#    step3:online change actMuAwareTdSch true and check logs
#    step4:online change actMuAwareTdSch false and check logs
#    step5:stop all UEs data and detach all UEs
#    Stop capture only gnb syslog in 'after_onair' file


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
    ${modify_list}    create list
    ...    ${max_num_pdsch_perslot}    ${max_num_pusch_perslot}
    #...    ${max_num_pdsch_perslot}    ${max_num_pusch_perslot}    ${max_num_layer_permurbg}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
#    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${Golden_SCF_Path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
#    Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}    frequency=2450_1_ALL
#    BlockingState block cell    phy_cell_id=891    alias=lock
    Stop Collecting GNB Syslog in 'before_onair' File

step1:gnb ready for onair
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
#	Set Suite Variable    ${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
#	Prepare environment
    Start capture only gnb syslog in 'after_onair' file


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


 #   Wait '10s' for stabible
#    Log To Console   ”Start GNB Ttitrace With Streaming Mode”
#    Start collect ttitrace
#    Wait for '1s' to stop ttitrace with name'tti_false'

  #  run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_false_case01.ini
  #  ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

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

step3:online change actMuAwareTdSch true and check logs
    Log To Console   \n-------------step3:online change actMuAwareTdSch true and check ---------------
    Online change actMuAwareTdSch 'true' and check bip logs

    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_true'

    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_true_case01.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#    run keyword and continue on failure    reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_true_dl.csv
#     #debug log
#    run keyword and continue on failure    get_ue_scheduled_times    ${TEST_LOG_DIRECTORY()}/9235_enable/tti_true_dl.csv


step4:online change actMuAwareTdSch false and check logs
    Log To Console   \n-------------step4:online change actMuAwareTdSch false and check---------------
    Online change actMuAwareTdSch 'false' and check bip logs
#    run keyword and continue on failure    Check UEs average throughput

step5:stop all UEs data and detach all UEs
    Log To Console   \n-------------step5:stop all UEs data and detach all UEs---------------
    FOR    ${num}    IN RANGE    0    ${UE_NUM_SA}
        Spark UE Stop traffic    dl    ue_index=${num}
        Spark UE Detach    ue_index=${num}
    END


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
    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${ATT_FILE_PATH}
    ...    ${parent_dir}/TestData/${PHASE_FILE_PATH}    frequency=2450_1_ALL

#    Qualcomm prepare gnb onair

online change actMuAwareTdSch '${state}' and check bip logs
    Start collect 'actMuAwareTdSch_${state}' tcpdump
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-10317/NRBTS-10317/NRCELL-1/NRDLMUMIMO-1    actMuAwareTdSch    true    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online
    Stop collect 'actMuAwareTdSch_${state}' tcpdump
    Wait '30s' for stabible
    Run Keyword If    '${state}'=='true'    set suite variable     ${9235_state}    1
    ...    ELSE    set suite variable     ${9235_state}    0
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/actMuAwareTdSch_${state}.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/actMuAwareTdSch_${9235_state}.csv    ${filter_cell_reconfiguration_req}    ${titles_remuaware}
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/actmuaware_state_bip.ini
    ...   log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Convert cellsetup bip and check
    Log To Console   Convert cellsetup bip and check
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/cellsetup_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Modify GNB swconfig
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    add_txt_node    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    add_txt_node    0x580539:10   #Num UE threshold,to collect trace
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt


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




Combine teardown
    COAM Teardown gnb connections
    Selenium Logout And Close Browser
