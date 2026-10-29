*** Settings ***
Documentation     CB009235 peak case
Test Timeout      60 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup    allowed_faults_ids=49
Test Teardown    SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4

#Library     ../Resources/Reorder_CSV.py
#Library     ../Resources/CB009235_check.py

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


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

&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30     FILE_SIZE_MBYTES=100

${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
@{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio
...    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio

${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
@{titles_remuaware}    itf_DlMuMimoEnhReConfig.actMuAwareTdSch    itf_DlMuMimoEnhReConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhReConfig.dlMuAwarePrbRatio   itf_DlMuMimoEnhReConfig.dlMuPairingPrbRatio

#${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml

${ue_type_0}                ${tl.ues[0].capabilities[0]}
${max_num_pdsch_perslot}              text|4|//*[@name\="maxNumPdschAllocationPerSlot"]
${max_num_pusch_perslot}              text|4|//*[@name\="maxNumPuschAllocationPerSlot"]
${max_num_layer_permurbg}              text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
${NRCELL1_CELLID}      169033729



*** Test Cases ***
CB009235_A_B101_CASE01_feature_activation_deactivation
    Step1:Commission the above configuration on WebUI
    step2:attach UEs and send full buffer and check logs
#    step3:online change actMuAwareTdSch true and check logs
#    step4:online change actMuAwareTdSch false and check logs
#    step5:stop all UEs data and detach all UEs
    Stop capture only gnb syslog in 'after_onair' file


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
    ...    ${max_num_pdsch_perslot}    ${max_num_pusch_perslot}    ${max_num_layer_permurbg}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify vendor file and full commission for onair     ${scfc_path}
#    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
#    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${Golden_SCF_Path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
#    Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}    frequency=2450_1_ALL
    BlockingState block cell    phy_cell_id=891    alias=lock
    Stop Collecting GNB Syslog in 'before_onair' File

Modify vendor file and full commission for onair
	[Arguments]    ${scfc_path}
	Configure TL VM ETH
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path}
    Modify Vendor rfCool File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${scfc_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    TAF_ADMIN.teardown admin

Modify Vendor rfCool File
    [Arguments]    ${vendor_path}
    ${vendor_rfCool}    Set Variable    text|true|//*[@name\="disableSchedAssistRfCooling"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_rfCool}

step1:gnb ready for onair
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
	Set Suite Variable    ${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
#	Prepare environment
    Start capture only gnb syslog in 'after_onair' file


step2:attach UEs and send full buffer and check logs
    Log To Console   \n-------------step2:attach UEs--------------
    Start capture only gnb syslog in 'after_onair' file
    #Set UE pos

    ${cellsid}    create list    ${NRCELL1_CELLID}

	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true
	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=780MKbits/sec    send_duration=600    apn_address=wustatic
	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=780MKbits/sec    send_duration=600    apn_address=wustatic
	    ...    iperf_port=${tl.appserver.iperf_details.port}
	    #Run Keyword If   ${num}==1    Spark UE Check Tput    ue_index=${num}    expect_traffic=${dl_peak_tput}
        Run Keyword If   ${num}==1    Spark UE Check Tput    ue_index=${num}    expect_traffic=${dl_peak_tput}    check_source=aasyslog
	    ...    cells=${cellsid}
    #    Run Keyword If   ${num}==0    Spark UE Check Tput    ue_index=${num}    expect_traffic=1240
    END

    Wait '10s' for stabible
    Log To Console   ”Start GNB Ttitrace With Streaming Mode”
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_false'

  #  run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_false_case01.ini
  #  ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/


step3:online change actMuAwareTdSch true and check logs
    Log To Console   \n-------------step3:online change actMuAwareTdSch true and check ---------------
    Online change actMuAwareTdSch 'true' and check bip logs

    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_true'

    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_true_case01.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
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


Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
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
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/actmuaware_state_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

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
#    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    add_txt_node    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    add_txt_node    0x580539:10   #Num UE threshold,to collect trace
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt










