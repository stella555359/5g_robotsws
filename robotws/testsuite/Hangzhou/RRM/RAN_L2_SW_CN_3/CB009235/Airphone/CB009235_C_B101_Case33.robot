*** Settings ***
Documentation     Author: zhaoyang.xu@nokia-sbell.com
...
...               QC case full name:
...               CB009235_C_B101_Case33_DL_MU-MIMO_Enhanced_Unpair_PM_counters_with_Invalid_SRS_and_LOW_CQI


Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    owner_zhaoxu
Test Timeout      60 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}     gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_9235.xml
${AIRPHONE_NAME}    AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_9235.xml
${WTS_NAME}    wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16DL8UL_9235.cfg
&{GNBMIRRORINGCONFIG}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt

@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${UE_NUM}         4
${PDU_ID}         1
${SLICE_ID}       1
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60

#common parameters config
${chBw}                                 text|100MHz|//*[@name\="chBw"]
${nrCellType}                           text|16DL8UL|//*[@name\="nrCellType"]
${frameStructureType}                   text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}                    text|2Symbols|//*[@name\="guardPeriodLength"]
${ulDlDataSlotRatio}                    text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}              text|98|//*[@name\="prachConfigurationIndex"]
${dlMimoMode}                           text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actFdmScheduling}                     text|true|//*[@name\="actFdmScheduling"]
${msg1FrequencyStart}                   text|0|//*[@name\="msg1FrequencyStart"]
#CB008247
${actDlSrsBm}                           text|true|//*[@name\="actDlSrsBm"]
${actBeamforming}                       text|true|//*[@name\="actBeamforming"]
${bSRS}                                 text|2|//*[@name\="bSRS"]
${cSRS}                                 text|63|//*[@name\="cSRS"]
${srsUePeriodicity}                     text|slots40|//*[@name\="srsUePeriodicity"]

#CB007113
${actBbPoolTddFr1}                      text|true|//*[@name\="actBbPoolTddFr1"]
${actShortBsrLimitAdaptation}           text|true|//*[@name\="actShortBsrLimitAdaptation"]
${allowSlowPrbPoolingStatNdmSrs}        text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]

#CB008305_DLMIMO
${actDlMuMimoEnh}                       text|true|//*[@name\="actDlMuMimoEnh"]
${dlMuMimoCorrThd}                      text|33|//*[@name\="dlMuMimoCorrThd"]
${dlMuMimoCqiThd}                       text|10|//*[@name\="dlMuMimoCqiThd"]
${dlMuMimoRankAdaption}                 text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
${dlMuMimoSpectralEffThd}               text|10|//*[@name\="dlMuMimoSpectralEffThd"]
${dlMuMimoTaperingH}                    text|25dB|//*[@name\="dlMuMimoTaperingH"]
${dlMuMimoTaperingV}                    text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
${dlMuMaxNumLayerPerMuRbg}              text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
${maxNumPuschAllocationPerSlot}         text|6|//*[@name\="maxNumPuschAllocationPerSlot"]
${maxNumPdschAllocationPerSlot}         text|6|//*[@name\="maxNumPdschAllocationPerSlot"]

#CB009235
${actMuAwareTdSch}                      text|true|//*[@name\="actMuAwareTdSch"]
${dlMuAwareCorrThd}                     text|20|//*[@name\="dlMuAwareCorrThd"]
${dlMuAwarePrbRatio}                    text|100|//*[@name\="dlMuAwarePrbRatio"]
${dlMuPairingPrbRatio}                  text|100|//*[@name\="dlMuPairingPrbRatio"]

#SRS NACK
${actSrsBeamFallbackByRetrx}            text|true|//*[@name\="actSrsBeamFallbackByRetrx"]
#change CQI
${dllaDeltaCqiMax}                      text|0|//*[@name\="dllaDeltaCqiMax"]
${dllaDeltaCqiMin}                      text|0|//*[@name\="dllaDeltaCqiMin"]
${dllaDeltaCqiStepdown}                 text|0|//*[@name\="dllaDeltaCqiStepdown"]


#bwp
${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
${pattern}    CA_P2_8x4_t2r4_n2

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6

${PROFILE1_SRS}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-720,-720,-720,-720
${PROFILE2_SRS}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-720,-720,-720,-720


*** Test Cases ***
CB009235_C_B101_Case33_DL_MU-MIMO_Enhanced_Unpair_PM_counters_with_Invalid_SRS_and_LOW_CQI
    Step1:Commission the above configuration on WebUI
    Step2:Attach 6UEs_rank4
    Step3:UE1-UE6 start little DL and UL nonGBR traffic
    Step4:check PM counter
    Step5:UE1-UE6 start full buffer DL and UL nonGBR traffic
    Step6:check PM counter again
	Step7:change UE1-UE2 SRS power and UE3-UE4 CQI less than dlMuMimoCqiTh
	Step8:check PM counter again

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB009235    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${chBw}    ${nrCellType}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
    ...    ${prachConfigurationIndex}    ${dlMimoMode}    ${actFdmScheduling}    ${msg1FrequencyStart}
    ...    ${actDlSrsBm}    ${actBeamforming}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
    ...    ${actBbPoolTddFr1}    ${actShortBsrLimitAdaptation}    ${allowSlowPrbPoolingStatNdmSrs}
    ...    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}     ${dlMuMimoRankAdaption}
    ...    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
    ...    ${dlMuMaxNumLayerPerMuRbg}     ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot}
    ...    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}     ${dlMuPairingPrbRatio}
    ...    ${actSrsBeamFallbackByRetrx}
	...    ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
	...    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

 Step2:Attach 6UEs_rank4
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    #Start GNB BIP Log
    Set UEs Pos
    Attach SA ue with capability to 5g cell    6    ${pattern}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    Wait Throughput Timer    3
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:UE1-UE6 start little DL and UL nonGBR traffic
    Start Collect GNB and AP Syslog in 'Step3_little_nonGBR' File
    FOR    ${ID}    IN RANGE    1    7
        Airphone SA Start Data Traffic    ${ID}    DL    5M    trf_id=1    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    ${ID}    UL    1M    trf_id=1    pdu_id=1    duration=${3600}
    END

    Wait Throughput Timer    20
	FOR    ${ID}    IN RANGE    1    7
	    ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
	    ${ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pusch    tput_type=ave
    END
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_little_nonGBR${/}   unzip=TRUE

	#Start GNB BIP Log
    #Wait Throughput Timer    2
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_little_nonGBR${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_little_nonGBR${/}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_little_nonGBR${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_little_nonGBR' File

Step4:check PM counter
    Start Collect GNB and AP Syslog in 'step4_check_pmcounter' File
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}step4_check_pmcounter/
    ${MU_MIMO_8layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34011    cell_id=1
    ${MU_MIMO_6layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34009    cell_id=1
    ${MU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34007    cell_id=1
    ${MU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34005    cell_id=1
    ${MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34012    cell_id=1
    ${MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34013    cell_id=1
    ${MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34014    cell_id=1
    ${MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34015    cell_id=1
    ${DL_SUCC_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34030    cell_id=1
    ${FAIL_BWP_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34031    cell_id=1
    ${FAIL_TRAF_TYPE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34032    cell_id=1
    ${FAIL_SRS_BEAM_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34033    cell_id=1
    ${FAIL_LOW_CQI_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34034    cell_id=1
    ${FAIL_LOW_PRB_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34035    cell_id=1
    ${FAIL_HIGH_CORR_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34036    cell_id=1
    ${FAIL_SE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34037    cell_id=1
    ${FAIL_OTHER_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34038    cell_id=1
    run keyword and continue on failure    should_be_true    ${FAIL_LOW_PRB_counter}>0
    [Teardown]    Stop Collect GNB and AP Syslog in 'step4_check_pmcounter' File

Step5:UE1-UE6 start full buffer DL and UL nonGBR traffic
    Start Collect GNB and AP Syslog in 'Step5_full_buffer' File
    FOR    ${ID}    IN RANGE    1    5
        Airphone SA Start Data Traffic    1    DL    170M    trf_id=${ID}    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    1    UL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
	    Airphone SA Start Data Traffic    2    DL    170M    trf_id=${ID}    pdu_id=1    duration=${3600}
	    Airphone SA Start Data Traffic    2    UL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
	    Airphone SA Start Data Traffic    3    DL    170M    trf_id=${ID}    pdu_id=1    duration=${3600}
	    Airphone SA Start Data Traffic    3    UL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    4    DL    170M    trf_id=${ID}    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    4    UL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
    END
    Wait Throughput Timer    20
	FOR    ${ID}    IN RANGE    1    7
	    ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
    END
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5_full_buffer${/}   unzip=TRUE
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/Step5_full_buffer
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/Step5_full_buffer/tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_full_buffer' File
Step6:check PM counter again
    Start Collect GNB and AP Syslog in 'Step6_pm_counter' File
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step6_pm_counter/
    ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34023    cell_id=1
    ${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34019    cell_id=1
    ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34015    cell_id=1
    ${MU_MIMO_8layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34011    cell_id=1
    ${MU_MIMO_6layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34009    cell_id=1
    ${MU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34007    cell_id=1
    ${MU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34005    cell_id=1
    ${SU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34004    cell_id=1
    ${SU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34002    cell_id=1
    ${MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34012    cell_id=1
    ${MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34013    cell_id=1
    ${MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34014    cell_id=1
    ${MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34015    cell_id=1
    ${DL_SUCC_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34030    cell_id=1
    ${FAIL_BWP_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34031    cell_id=1
    ${FAIL_TRAF_TYPE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34032    cell_id=1
    ${FAIL_SRS_BEAM_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34033    cell_id=1
    ${FAIL_LOW_CQI_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34034    cell_id=1
    ${FAIL_LOW_PRB_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34035    cell_id=1
    ${FAIL_HIGH_CORR_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34036    cell_id=1
    ${FAIL_SE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34037    cell_id=1
    ${FAIL_OTHER_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34038    cell_id=1
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_pm_counter' File
Step7:change UE1-UE2 SRS power and UE3-UE4 CQI less than dlMuMimoCqiTh
    Start Collect GNB and AP Syslog in 'Step7_change_SRS_power' File
    Airphone Execute Egate Command    ${PROFILE1_SRS}
    Airphone Execute Egate Command    ${PROFILE2_SRS}
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
    Wait Throughput Timer    2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=10 cqi\=3 cqi_mode\=fixed
    Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=10
    Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=10
    #Airphone Execute Egate Command    ue_testmode_set_nr id\=5 testmode\=csi_override action\=activate profile_id\=10
    #Airphone Execute Egate Command    ue_testmode_set_nr id\=6 testmode\=csi_override action\=activate profile_id\=10
    Wait Throughput Timer    20
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step7_change_SRS_power${/}   unzip=TRUE
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/Step7_change_SRS_power
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/Step7_change_SRS_power/tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_change_SRS_power' File
Step8:check PM counter again
    Start Collect GNB and AP Syslog in 'Step8_pm_counter' File
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step8_pm_counter/
    ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34023    cell_id=1
    ${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34019    cell_id=1
    ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34015    cell_id=1
    ${MU_MIMO_8layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...    counter_id=M55308C34011    cell_id=1
    ${MU_MIMO_6layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34009    cell_id=1
    ${MU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34007    cell_id=1
    ${MU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34005    cell_id=1
    ${SU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34004    cell_id=1
    ${SU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34002    cell_id=1
    ${MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34012    cell_id=1
    ${MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34013    cell_id=1
    ${MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34014    cell_id=1
    ${MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34015    cell_id=1

    ${DL_SUCC_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34030    cell_id=1
    ${FAIL_BWP_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34031    cell_id=1
    ${FAIL_TRAF_TYPE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34032    cell_id=1
    ${FAIL_SRS_BEAM_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34033    cell_id=1
    ${FAIL_LOW_CQI_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34034    cell_id=1
    ${FAIL_LOW_PRB_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34035    cell_id=1
    ${FAIL_HIGH_CORR_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34036    cell_id=1
    ${FAIL_SE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34037    cell_id=1
    ${FAIL_OTHER_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
	...   counter_id=M55308C34038    cell_id=1
    #run keyword and continue on failure    should_be_true    ${FAIL_SRS_BEAM_counter}>0
    run keyword and continue on failure    should_be_true    ${FAIL_LOW_CQI_counter}>0
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_pm_counter' File
Set UEs Pos
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command    ${SET_PROFILE1}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command    ${SET_PROFILE2}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command    ${SET_PROFILE3}
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command    ${SET_PROFILE4}
    airphone_execute_egate_command    ${PROFILE5}
    airphone_execute_egate_command    ${SET_PROFILE5}
    airphone_execute_egate_command    ${PROFILE6}
    airphone_execute_egate_command    ${SET_PROFILE6}
