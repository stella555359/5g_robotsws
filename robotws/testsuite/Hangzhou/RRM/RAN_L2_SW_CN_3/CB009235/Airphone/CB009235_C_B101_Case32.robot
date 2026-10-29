*** Settings ***
Documentation     Author: zhaoyang.xu@nokia-sbell.com
...
...               QC case full name:
...               CB009235_C_B101_Case32_DL_MU-MIMO_Enhanced_Unpair_PM_counters_with_BWP_and_Traffic
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_zhaoxu
Test Timeout      60 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}       gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_MultipleDedicatedBWPs_9235.xml
${AIRPHONE_NAME}    ap_iphy_9235_case32.xml
${WTS_NAME}       wts_9235_case32.cfg
${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}    gnb_snapshot    egatelog\
#common parameter config
${cellDepType}                          text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                 text|100MHz|//*[@name\="chBw"]
${nrarfcn}                              text|636666|//*[@name\="nrarfcn"]
${gscnOrSsPbchArfcn}                    text|7880|//*[@name\="gscnOrSsPbchArfcn"]
${nrCellType}                           text|8DL8UL|//*[@name\="nrCellType"]
${frameStructureType}                   text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}                    text|2Symbols|//*[@name\="guardPeriodLength"]
${ulDlDataSlotRatio}                    text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}              text|98|//*[@name\="prachConfigurationIndex"]
${dlMimoMode}                           text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actMultipleDedicatedBWPs}             text|true|//*[@name\="actMultipleDedicatedBWPs"]
#CB008247
${actDlSrsBm}                           text|true|//*[@name\="actDlSrsBm"]
${actBeamforming}                       text|true|//*[@name\="actBeamforming"]
${bSRS}                                 text|1|//*[@name\="bSRS"]
${cSRS}                                 text|63|//*[@name\="cSRS"]
${srsUePeriodicity}                     text|slots40|//*[@name\="srsUePeriodicity"]
${basicBeamSet}                         text|beamSet_6|//*[@name\="basicBeamSet"]
${msg1FrequencyStart}                   text|30|//*[@name\="msg1FrequencyStart"]
${actUlPtrs}                            text|false|//*[@name\="actUlPtrs"]
${actDlPtrs}                            text|false|//*[@name\="actDlPtrs"]

#CB007113
${actBbPoolTddFr1}                      text|true|//*[@name\="actBbPoolTddFr1"]
${actShortBsrLimitAdaptation}           text|true|//*[@name\="actShortBsrLimitAdaptation"]
${allowSlowPrbPoolingStatNdmSrs}        text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]

#CB008305_DLMIMO
${actDlMuMimoEnh}                       text|true|//*[@name\="actDlMuMimoEnh"]
${dlMuMimoCorrThd}                      text|50|//*[@name\="dlMuMimoCorrThd"]
${dlMuMimoCqiThd}                       text|10|//*[@name\="dlMuMimoCqiThd"]
${dlMuMimoRankAdaption}                 text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
${dlMuMimoSpectralEffThd}               text|10|//*[@name\="dlMuMimoSpectralEffThd"]
${dlMuMimoTaperingH}                    text|25dB|//*[@name\="dlMuMimoTaperingH"]
${dlMuMimoTaperingV}                    text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
${dlMuMaxNumLayerPerMuRbg}              text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
${maxNumPuschAllocationPerSlot}         text|4|//*[@name\="maxNumPuschAllocationPerSlot"]
${maxNumPdschAllocationPerSlot}         text|4|//*[@name\="maxNumPdschAllocationPerSlot"]

#CB009235
${actMuAwareTdSch}                      text|true|//*[@name\="actMuAwareTdSch"]
${dlMuAwareCorrThd}                     text|20|//*[@name\="dlMuAwareCorrThd"]
${dlMuAwarePrbRatio}                    text|100|//*[@name\="dlMuAwarePrbRatio"]
${dlMuPairingPrbRatio}                  text|100|//*[@name\="dlMuPairingPrbRatio"]

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5
...    trigger_puxch_update\=0 test_type=SRS
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5
...    trigger_puxch_update\=0 test_type=SRS

${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3



*** Test Cases ***
CB009235_C_B101_Case32_DL_MU-MIMO_Enhanced_Unpair_PM_counters_with_BWP_and_Traffic
    Step1:Commission the above configuration on WebUI
    Step2:Attach MU eligible UE1 in cell1
    Step3:UE1 start full buffer GBR traffic
	Step4:Attach UE2 capability is restricted in small bwp
	Step5:Check Pm counter
	#Step6:Detach ues

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
	modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${nrarfcn}    ${gscnOrSsPbchArfcn}    ${nrCellType}
	...    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
    ...    ${prachConfigurationIndex}    ${dlMimoMode}    ${actMultipleDedicatedBWPs}
    ...    ${actDlSrsBm}    ${actBeamforming}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}    ${basicBeamSet}
	...    ${msg1FrequencyStart}    ${actUlPtrs}    ${actDlPtrs}
    ...    ${actBbPoolTddFr1}    ${actShortBsrLimitAdaptation}    ${allowSlowPrbPoolingStatNdmSrs}
    ...    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}     ${dlMuMimoRankAdaption}
    ...    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
    ...    ${dlMuMaxNumLayerPerMuRbg}     ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot}
    ...    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}     ${dlMuPairingPrbRatio}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
    ...    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File


Step2:Attach MU eligible UE1 in cell1
	Start Collect GNB and AP Syslog in 'Step2_attach' File
	Attach Sa Ue With Capability    1
	Wait Throughput Timer    3
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File


Step3:UE1 start full buffer GBR traffic
	Start Collect GNB and AP Syslog in 'Step3_GBR' File
	airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=2 by\=amf
    Wait Throughput Timer    2
	airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=3 by\=amf
    Wait Throughput Timer    2
	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=50 dir\=dl protocol\=tcp seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=50 dir\=dl protocol\=tcp seconds\=3600
    Wait Throughput Timer    10
	${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    type=pdsch    tput_type=ave
	${ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    type=pusch    tput_type=ave
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_GBR${/}   unzip=TRUE
	#Start GNB BIP Log
	#Wait Throughput Timer    2
	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_GBR${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_GBR${/}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_GBR${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_GBR' File

Step4:Attach UE2 capability is restricted in small bwp
    Start Collect GNB and AP Syslog in 'Step4_attach' File
	Attach Sa Ue With Capability    2
	Set UEs Position
	Airphone SA Start Data Traffic    2    DL    100M    trf_id=1    pdu_id=1    duration=${3600}
	Airphone SA Start Data Traffic    2    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
	Wait Throughput Timer    10
	${UE1_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    type=pdsch    tput_type=ave
	${UE1_ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    type=pusch    tput_type=ave
	${UE2_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=2    type=pdsch    tput_type=ave
	${UE2_ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=2    type=pusch    tput_type=ave
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4_attach${/}   unzip=TRUE
	#Start GNB BIP Log
	#Wait Throughput Timer    2
	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_attach${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_attach${/}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_attach${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_attach' File
Step5:Check Pm counter
    Start Collect GNB and AP Syslog in 'Step5_pm_counter' File
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}Step5_pm_counter${/}
    Set Suite Variable    ${PM_counter_file}
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
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    5
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_pm_counter${/}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_pm_counter${/}tti
	should_be_true    ${FAIL_BWP_counter}>0
	should_be_true    ${FAIL_TRAF_TYPE_counter}>0
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_pm_counter' File
Step6:Detach ues
    Detach '2'UE
Set UEs Position
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command    ${SET_PROFILE1}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command    ${SET_PROFILE2}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command    ${SET_PROFILE3}
get UE throughput by egate
    :FOR    ${u}    IN RANGE     1    3
	    ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
	    ${ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pusch    tput_type=ave
Attach Sa Ue With Capability
    [Arguments]    ${ue_id}
    Airphone SA Attach    ue_id=${ue_id}
    airphone_set_traffic_type    ${ue_id}    1    internal
    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
    Wait '2s' for stable running