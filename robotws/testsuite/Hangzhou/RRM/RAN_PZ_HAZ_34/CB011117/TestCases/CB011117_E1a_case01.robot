*** Settings ***
Documentation     author: changyli
...               contact: changyan.li@nokia-sbell.com
...               squad group: SG13
Test Timeout      120 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup
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
#${SCFC_NAME}    SCFC_CB009235_case01.xml
${ATT_FILE_PATH}    att_9235_case01
${PHASE_FILE_PATH}    phase_9235_case01
${mcs_file_path}     all_11117
${scfc_configuration}    SCFC_11117.xml
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



*** Test Cases ***
CB011117_E1a_case001_one_PDSCH_DMRS_for_Ues_with_subband_BF
    Step1:Commission the above configuration on WebUI
    step2:attach UEs and send full buffer and check logs
    [Teardown]    AdministrativeState unlock cell  phy_cell_id=891    alias=unlock


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
    Modify GNB swconfig
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${parent_dir}/TestData/${scfc_configuration}    ${scfc_path}
    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------

#    Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}    frequency=2600_1_ALL
    AdministrativeState lock cell    phy_cell_id=891    alias=lock
    Stop Collecting GNB Syslog in 'before_onair' File


step2:attach UEs and send full buffer and check logs
    Log To Console   \n-------------step2:attach UEs--------------
    Start capture only gnb syslog in 'step2_attach_ue_check_log' file
    #Set UE pos

	Log To Console    UE attachs
	Spark UE Attach    ue_index=${1}    power_reset=true
	Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_attach'
	Spark UE Send DL Traffic    ue_index=${1}    send_traffic=1450MKbits/sec    send_duration=600    apn_address=wustatic

    Wait '10s' for stabible
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_traffic'

    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_dmrs_case01.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

    [Teardown]    Stop capture gnb and ap syslog in 'step2_attach_ue_check_log' file


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
    ...    frequency=2600_1_ALL


Convert cellsetup bip and check
    Log To Console   Convert cellsetup bip and check
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/cellsetup_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Modify GNB swconfig
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB011117/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node	0x59026A:1       #rdActNoAddDlDmrsSwitch
	add_txt_node	0x58096f:0x63       #rdWbSrsNoAddDlDmrsCorrThreshold
	add_txt_node	0x580970:0x62     #rdWbSrsAddDlDmrsCorrThreshold
	add_txt_node    0x58076a:1		# rdNumWbSrsMeas, default=5;
	#The minimum number of correlation metric before correlation is used for measure radio link variety,set to 1 ,corrAvg=current average.
	add_txt_node 	0x58077b:1		# rdNumSbSrsCorrCal, default=5
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt










