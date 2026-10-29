*** Settings ***
Documentation      Author: zhaoyang.xu@nokia-sbell.com
...               CNI113494 base on CB008305 check ibler counters for DFT beam

Test Timeout      90 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup        SG13 Common Test Setup
Test Teardown     SG13 Common Test Teardown
Force Tags        spark    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
*** Variables ***
${CONFIG_DIR_PATH}       ${CURDIR}/config
@{LOG_NAME_LIST}         gnb_snapshot
${SCFC_NAME}             SCFC_CNI113494_case01.xml
${ATT_FILE_PATH}         ${CURDIR}/config/att_CNI113494_case01
${PHASE_FILE_PATH}       ${CURDIR}/config/phase_CNI113494_case01
${scfc_configuration}    ${CURDIR}/config/SCFC_CNI113494_case01.xml
${swconfig_file}         ${CURDIR}/config/swconfig.txt
${UE_ID}         1
${UE_NUM_SA}     3
${UE_ID_LIST}    1,2,3,4,5,6,7,8
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30     FILE_SIZE_MBYTES=100
${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
@{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio
...    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio
${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
@{titles_remuaware}    itf_DlMuMimoEnhReConfig.actMuAwareTdSch    itf_DlMuMimoEnhReConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhReConfig.dlMuAwarePrbRatio   itf_DlMuMimoEnhReConfig.dlMuPairingPrbRatio
${ue_type_0}                      ${tl.ues[0].capabilities[0]}
${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
${miNrDlHarq}                     text|5min|//*[@name\="miNrDlHarq"]
${miNrUlHarq}                     text|5min|//*[@name\="miNrUlHarq"]
${miNrDlHarqLowSEMCS}             text|5min|//*[@name\="miNrDlHarqLowSEMCS"]
${miNrUlHarqLowSEMCS}             text|5min|//*[@name\="miNrUlHarqLowSEMCS"]
${miNrUlHarqOne}                  text|5min|//*[@name\="miNrUlHarqOne"]
*** Test Cases ***
CNI113494_ST_Case1_Interworking_with_CB008305_check_BLER_counters_for_SRS_based_beam
    Step1:Commission the above configuration on WebUI
    step2:attach UEs and send full buffer and check logs
    Step3:get PM counter for CNI113494 ibler counters
	step4:stop all UEs data and detach all UEs
*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
    Modify GNB swconfig
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${scfc_configuration}    ${scfc_path}
    ${modify_list}    create list
    ...    ${miNrSrsQuality}    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}
	...    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}    ${miNrUlHarqOne}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}    frequency=2450_1_ALL
    Stop Collecting GNB Syslog in 'before_onair' File
step2:attach UEs and send full buffer and check logs
    Log To Console   \n-------------step2:attach UEs--------------
    Start capture only gnb syslog in 'ue_attach' file
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}
        Log To Console    UE${num} attachs
        Spark UE Attach    ue_index=${num}    power_reset=true
        Spark UE Send DL Traffic    ue_index=${num}    send_traffic=500MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
    END
    Wait '10s' for stabible
    Log To Console   ”Start GNB Ttitrace With Streaming Mode”
    #Start collect ttitrace
    #Wait for '1s' to stop ttitrace with name'tti_step2'
    Stop Collecting GNB Syslog in 'ue_attach' File
Step3:get PM counter for CNI113494 ibler counters
    Log To Console    \n-------------Step3:get PM counter for CNI113494 ibler counters--------------
    Start capture only gnb syslog in 'step3_pm_counters' file
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step3_pm_counters${/}
    Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
    Stop Collecting GNB Syslog in 'step3_pm_counters' File
step4:stop all UEs data and detach all UEs
    Log To Console   \n-------------step4:stop all UEs data and detach all UEs---------------
    Start capture only gnb syslog in 'step4_ue_detach' file
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}
    #    Spark UE Stop traffic    dl    ue_index=${num}
        Spark UE Detach    ue_index=${num}
    END
    Stop Collecting GNB Syslog in 'step4_ue_detach' File
Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}
    [Return]    ${dl_expect_pcell}[0]
Convert cellsetup bip and check
    Log To Console   Convert cellsetup bip and check
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/cellsetup_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
Modify GNB swconfig
    Log To Console    ${swconfig_file}
    setup_txt    src_file=${swconfig_file}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:1             #as PM counter period update to 15/15=1min
	add_txt_node   0x580264:0x3         #coma log
	add_txt_node   0x580477:1         #print beam calc log
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
Check_CNI113494_iBler_match_Legacy_counters
    [Arguments]    ${PM_counter_file}
	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
	Log To Console    \n----------------------end-------------------------
    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
	END
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
	END
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	END
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	END
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4-----
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	END
	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	END
	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
    Log To Console    \n----------------------end-------------------------
    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1}