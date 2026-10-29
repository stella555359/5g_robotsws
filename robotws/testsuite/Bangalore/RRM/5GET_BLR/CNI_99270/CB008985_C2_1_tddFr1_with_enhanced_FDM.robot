*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CNI_99270/CB008985_FDM_CSIRS.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Varun
...              :contact: varun.khokhar@nokia.com
...         This CNI supports NR FR1 TDD super cell RRM part. The super cell is a logical cell created by several sub-cells.
...         The same Physical Cell ID (PCI) is assigned to each sub-cell of the super cell.
...         Each sub-cell of the super cell operates on the same carrier frequency without resource multiplexing
...         The aim of this test is to validates the data transmission with an increased number of allocations on
...         PDSCH and PUSCH per slot for TDD FR1 CPRI/eCPRI supercell deployments.

Library 		 ../CB008983/resources/verify_reconfig.py
#Library          resources/verify_reconfig.py
Library          OperatingSystem
Resource         ../CB008541/resources/CB008541_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
#Resource         ../resources/robot/Common_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
#Resource         resources/load_based_validation_keywords.resource
Resource         ../resources/robot/TTI_Traces.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/avg_dl_data.py
Library           ta5g_enb



Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run keywords    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

#Test Setup       Start_capture_testcase_default_logging
#Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
#${DELTA_FILE}              Delta_Conf_CB007859_A_3_007_10ue.json
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/basic2SupercellAZQP_setup.cfg
${iphy}              ${CURDIR}/resources/config/AHPF_iphy_working.xml
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic2SupercellAZQP_setup.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7881</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=30M    ul_traffic=30M
${UE_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${UE_NUM}                  1
${nwslice_ID}   1
${gw_ID}     1
${UE_PER_SLOT}              4
${UE_NUM_CHANGE}            2
${start_ue_id}         1
${end_ue_id}       1
${no_of_ue}        1
${file_path}     /opt/iphy/latest/egate_console.log
${st_ue_id}    1
${en_ue_id}    1
${no_of_reconf}     2
${INDEX2}     ${st_ue_id}


*** Test Cases ***
[1]CB008985_C2_1_tddFr1_with_enhanced_FDM
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt      btslog
    Create BeamForming profile attach UE and trigger data
    Run Keyword And Ignore Error      Validate DL Traffic For MultiUE for SA      1       1      170
    Run Keyword And Ignore Error      Validate UL Traffic For MultiUE for SA      1       1      170
    wtsrunner.ue_testmode_set_nr     id=1      testmode=beam_control      action=activate      profile_id=2
    ...      beamaction=switch    scell=2
	# wtsrunner.ue_testmode_set_nr     id=2      testmode=beam_control      action=activate      profile_id=2
	#...      beamaction=switch    scell=2
	# wtsrunner.ue_testmode_set_nr     id=3      testmode=beam_control      action=activate      profile_id=1
	# ...      beamaction=switch    scell=2
	# wtsrunner.ue_testmode_set_nr     id=4      testmode=beam_control      action=activate      profile_id=1
	# ...      beamaction=switch    scell=2
	Run Keyword And Ignore Error       Validate DL Traffic For MultiUE for SA      1       1      170
    Run Keyword And Ignore Error       Validate UL Traffic For MultiUE for SA      1       1      170
    #Start And Stop Tti Trace Streaming
	#Validate PM Counters_csirs
	Validate csirs in egate
	Stop Log      cprt      btslog       test_scenario=Scenario_1
	#Verify Beam Switch in AP Syslog     NAME=Scenario_1
    MultiUE Deregister should be Successful     1       1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Create BeamForming profile attach UE and trigger data
	log to console   Create BeamForming Profile...
    Create Beamforming Profile
    log to console   UE attach trigerring now...
    MultiUE Register should be Successful    1    1    1    1
    Sleep    5s
    wtsrunner.ue_testmode_set_nr    id=1    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
    Log to console    UE 1 beamforming profile is attached
    #wtsrunner.ue_testmode_set_nr    id=2    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
    #Log to console    UE 2 beamforming profile is attached
    #wtsrunner.ue_testmode_set_nr    id=3    testmode=beam_control     action=activate     profile_id=2      beamaction=attach
    #Log to console    UE 3 beamforming profile is attached
    #wtsrunner.ue_testmode_set_nr    id=4    testmode=beam_control     action=activate     profile_id=2      beamaction=attach
    #Log to console    UE 4 beamforming profile is attached
	MultiUE Trigger UL Traffic for SA    1    1    mbps    170    1
    MultiUE Trigger DL Traffic for SA    1    1    mbps    170    1


Create Beamforming Profile
    [Arguments]    ${ue_id}=1
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1     ueBeamIndexInitial=0,1,2,3,4,5,6,7     ssbeam_bestbeam=0      ssbeam_rsrp_best=-44
    ...   ssbeam_rsrp_avg=-50
    wtsrunner.beam_control_testmode_nr     profile_id=2     ueBeamIndexInitial=1,0,2,3,4,5,6,7     ssbeam_bestbeam=1      ssbeam_rsrp_best=-45
    ...   ssbeam_rsrp_avg=-50

Activate Beamforming Profile
    [Arguments]    ${ue_id}=1    ${profile}=1
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=${profile}      beamaction=attach
    Log to console    UE ${ue_id} beamforming profile is attached

Beamcontrol Beam Switch 2
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=2     ${scell_idx}=0     ${best_beam}=1
    Log to Console    Changing Beam
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=switch    scell=${scell_idx}
    Run Keyword and continue on failure    Check best beam     beam_profile_id=${beam_profile_id}    best_beam=${best_beam}

Validate csirs in egate
	log to console  Verifying egate_log
    verify_reconfig.check_reconfig_msg     ${file_path}     1
    ${output}     OperatingSystem.Get File    ${file_path}
    #${output}    OperatingSystem.Get File    Reconfig_MSG_1.txt
    FOR    ${INDEX}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
    ${output}    OperatingSystem.Get File   Reconfig_MSG_${INDEX2}.txt
    BuiltIn.Should Match Regexp     ${output}    reportConfigId 0.*\\n.*\\n.*\\n.*\\n.*\\n.*reportSlotConfig slots320 : 14
    BuiltIn.Should Match Regexp     ${output}    reportConfigId 0.*\\n.*\\n.*\\n.*\\n.*\\n.*reportSlotConfig slots320 : 14
    ${INDEX2}     Evaluate    ${INDEX2}+2
    END

Validate PM Counters_csirs
   Wait until the next Measurement Period starts
   ${PM_dir_1}=    PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb0
   PM_Counters.Check PM counter value equal     expected_value=1   pm_files_location=${PM_dir_1}   pi_id=M55308C22001   moc=NRCELL-1

Verify Beam Switch in AP Syslog
    [Arguments]     ${NAME}
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${NAME}.log | grep -i "switch primary beam"
    Should contain    ${status}     switch primary beam
    Log to Console    Beam Switch verified in AP syslog














