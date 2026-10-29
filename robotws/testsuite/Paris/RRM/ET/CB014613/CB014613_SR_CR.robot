*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE] CB014613_SR_CR
...               \nPrerequisite :
#                 Scope          : Test Suite
#
...             \nTest Case Scenario author : vincent.boulet@nokia.com
...             \nCreation Date             : 2025-11-19
...             \nModified Date             : 2026-02-25
#
...             \nVersion    Date       Author                          Notes
...             \n0.1        FB2523     vincent.boulet@nokia.com        Robot creation and test cases for preparation
#                 0.2        FB2525     vincent.boulet@nokia.com        Continued preparation focused on CB014613
#                 0.3        FB2525     vincent.boulet@nokia.com        Continued preparation focused on CB014613 SR and CR
#                 0.4        FB2525     vincent.boulet@nokia.com        Check tddFrameStructure as prerequisite, grep expressions from SYSLOG's
#                 0.5        FB2526     vincent.boulet@nokia.com        CB014613_RJIO_CVR_001_A_1_PREP, Get NRCELL Parameters SR-CR and
#                                                                       \nCB014613_SR_A_3_PREP
#                 0.6        FB2601     vincent.boulet@nokia.com        Selection of RI detection mode based on parameter riStateReport
#                 0.7        FB2601     vincent.boulet@nokia.com        Online Modification NRRIM PROFILE Parameters SR-CR
#                 0.8        FB2601     vincent.boulet@nokia.com        CB014613_SR_A_1_PREP test case riStateReport=FM off, CM on
...             \n1.0        FB2605     vincent.boulet@nokia.com        Robot version for first execution
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED##CB011127##FAILED##[VRF_NPS_AUTO-248]##DEBUG_LOG##OBSOLETE#
#STOP_TEST#    > code to stop test execution by forcing an error:
#    Critical Step                     Should Be True    ${True} == ${False}
# Libraries

# Resources
Resource                              ./resources/robot/CB014613-Common-Keywords.robot

# Suites
Suite Setup                           Suite Setup SR-CR    keep_all_data_in_file=${True}
#Suite Teardown                        Suite Teardown
Test Teardown                         Test Teardown SR-CR   is_snapshot=${is_capture}[is_capture_snapshot]

*** Variables ***
# tests settings
&{CB014613_SETTINGS_CR_1}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For SR-CR
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=10                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=CB014613_SETTINGS_CR_1
...                                   total_nb_cell=6               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support
...                                   bsr_folder=${None}
...                                   bsr_target=${None}
...                                   RI_N_PW_10=${RI_N_PW_10}      # profil 10 to simulate low remote interference
...                                   RI_N_PW_1=${RI_N_PW_1}        # profil 1 to simulate high remote interference

&{TEST_SETTINGS_CR_1}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For SR-CR
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=20                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=TC_TEST_SETTINGS_CR_1
...                                   total_nb_cell=6               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support
...                                   bsr_folder=${None}
...                                   bsr_target=${None}

&{CB014613_SETTINGS_RJIO_5_1}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For SR-CR
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=10                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=CB014613_SETTINGS_RJIO_5_1
...                                   total_nb_cell=6               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support
...                                   bsr_folder=BSR    # https://gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr/-/tree/main/BSR?ref_type=heads
...                                   bsr_target=BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471_1.zip
...                                   syslog_grep_target=${CURDIR}/resources/scripts/syslog_grep_results.sh
...                                   RI_N_PW_10=${RI_N_PW_10}      # profil 10 to simulate low remote interference
...                                   RI_N_PW_1=${RI_N_PW_1}        # profil 1 to simulate high remote interference

&{CB014613_SETTINGS_TDD_GMC}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For SR-CR
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=10                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=0           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=CB014613_SETTINGS_TDD_GMC
...                                   total_nb_cell=6               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support
...                                   bsr_folder=BSR    # https://gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr/-/tree/main/BSR?ref_type=heads
...                                   bsr_target=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                                   syslog_grep_target=${CURDIR}/resources/scripts/syslog_grep_results.sh
...                                   RI_N_PW_10=${RI_N_PW_SS_10}   # profil 10 to simulate low remote interference (specific semi-static)
...                                   RI_N_PW_1=${RI_N_PW_SS_1}     # profil 1 to simulate high remote interference (specific semi-static)
# --------------------------------------------------------------------------------------------------------------------------------------------------
#*** Keywords ***
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Test Cases ***
[1] CB014613_CR_A_1_Check_Adjusted_RI_Detection_Thres_Per_Subband_Dynamically_Updated
##CB014613-A-1-Check_ Adjusted_RI_Detection_Thres_Per_Subband_Dynamically_Updated_FrameStructure_5GC001116_GuardPeriodLength_4Symbols
#USELESS#[Tags]    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB014613_SETTINGS_CR_1}
    ${param.test_name}=               Set Variable    TC_CB014613_CR_A_1
    Set To Dictionary                 ${param}    counter_constraint    CB014613_CR_A_1
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${False}
    ...                                                    is_capture_syslog=${False}
    ...                                                    is_capture_snapshot=${True}
    #
    # Prerequisite for internal testing
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Get NRCELL Parameters SR-CR from NRRIMINFO object
    FOR    ${position}    IN          @{list_position_nrcell_for_rimrs}
                                      Get Remote Interference State From NRRIMINFO    position_nrcell=${position}   ri_state=no RI   iteration_max=1
        ...                           confirm_detection=${False}
    END
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=22   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    # Update RAD debug parameters using OAM command like WebEM
    Step                              Set RAD Parameters CR    rad_0x58057A_val=4    rad_0x58057F_val=3
#    Step                              Set CPLANE RAD Parameters CR
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    #                                 actRimCmFmReport:
    ...                                                    dlMutingStateReport=FM on, CM off
    ...                                                    riStateReport=FM off, CM on          #FM on, CM off
    ...                                                    rimRsStateReport=FM on, CM off
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    # Update RIM RS configuration for cells where actNrRim is RI detection only
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=RI detection only
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=no mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    2    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=framework-0
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_fdd}=      Create List    1    2    3    4    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=disabled
    ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    # Update RAD non-debug parameters using AaShell command and online modification
    Dated Log                         > Set Rad Parameter Using Aashell for L2PS domain
#    ${rad_master_nonzero_values}=     Get Rad Value Using Aashell3    rad_param=0x58061c    domain_nom=ute-l2rt-a-0    domain_elem=ctr-l2rt
#    ${0x58061c_val}=                  Get Rad Parameter Dictionary    rad_params_list=${rad_master_nonzero_values}    rad_param_identifier=0x58061c
#    Dated Log                         >> 0x58061c_val= ${0x58061c_val}
#    ${0x58061d_val}=                  Get Rad Parameter Dictionary    rad_params_list=${rad_master_nonzero_values}    rad_param_identifier=0x58061d
#    Dated Log                         >> 0x58061d_val= ${0x58061d_val}
#    # rdRiDataTrimThreshold set to default value=15
#    Set Rad Parameter Using Aashell   rad_param_value=15    rad_param=0x58061c    domain_nom=ute-l2rt-a-0    domain_elem=ctr-l2rt
    # rdAutoRiThresBaseCalcInterval set to 20 minutes (default=0)
    Set Rad Parameter Using Aashell   rad_param_value=20    rad_param=0x58061d    domain_nom=ute-l2rt-a-0    domain_elem=ctr-l2rt
#    ${rad_master_nonzero_values}=     Get Rad Value Using Aashell3    rad_param=0x58061c    domain_nom=ute-l2rt-a-0    domain_elem=ctr-l2rt
#    ${0x58061c_val}=                  Get Rad Parameter Dictionary    rad_params_list=${rad_master_nonzero_values}    rad_param_identifier=0x58061c
#    Dated Log                         >> 0x58061c_val= ${0x58061c_val}
#    ${0x58061d_val}=                  Get Rad Parameter Dictionary    rad_params_list=${rad_master_nonzero_values}    rad_param_identifier=0x58061d
#    Dated Log                         >> 0x58061d_val= ${0x58061d_val}
    #
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Check NRCELL Parameters from NRCELL object for tddFrameStructure
    &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
    &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=tdLte
    ...                                                    guardPeriodLength=4Symbols
    ...                                                    lteToNrFrameShift=3ms
    Critical Step                     Check tddFrameStructure Parameters CR    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
    #
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    Should Be True                    ${is_alarm_present} == ${False}
    ${is_alarm_present}=              Set Variable    ${False}
    IF    ${isAic}
        # This step is not useful but it is just to test Is Alarm Present on CU
        ${is_alarm_present}=    Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1  confirm_presence=${False}  oam_type=${GNB_CU.oam}
    END
    Should Be True                    ${is_alarm_present} == ${False}
    #
    CB014613 Call And Then Traffic SR-CR    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
    ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
    ...                               bypassX2Setup=${False}
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB014613_SR_A_1_Check_Adjusted_RI_Detection_Thres_Per_Subband_Dynamically_Updated
##CB014613-A-1-Check_ Adjusted_RI_Detection_Thres_Per_Subband_Dynamically_Updated_FrameStructure_5GC001116_GuardPeriodLength_4Symbols
#USELESS#[Tags]    CLOUD_5G_O_E_AP_LOOO    VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB014613_SETTINGS_RJIO_5_1}
    ${param.test_name}=               Set Variable    TC_CB014613_SR_A_1
    Set To Dictionary                 ${param}    counter_constraint    CB014613_SR_A_1
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${False}
    ...                                                    is_capture_syslog=${True}
    ...                                                    is_capture_snapshot=${True}
    #
    # Prerequisite for internal testing and for checking PR868877
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Get NRCELL Parameters SR-CR from NRRIMINFO object
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=no RI
    ...                                                    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrriminfo_result}=              Get NRCELL Parameters SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    ...                               extra_dist_name=NRRIMINFO-1
    Dated Log New Line                ${cc_yellow}> Get NRRIMINFO Parameters SR-CR result=${nrriminfo_result}${cc_normal}
    #
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=22   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    # Update RAD debug and other parameters using swconfig.txt
    Step                              Set RAD Parameters SR    rad_0x58057A_val=4    rad_0x58057F_val=3    rad_0x58061C_val=15    rad_0x58061D_val=20
    # The following step is not useful for Classical but it is just for testing the online modification using keyword delivered by SWENG
    # Update RAD non-debug parameters using AaShell command and online modification
    # rdRiDataTrimThreshold set to default value=15
#    Set Rad Parameter Using Aashell    rad_param_value=15    rad_param=0x58061c
    # rdAutoRiThresBaseCalcInterval set to 20 minutes (default=0)
#    Set Rad Parameter Using Aashell    rad_param_value=20    rad_param=0x58061d
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    #                                 actRimCmFmReport:
    ...                                                    dlMutingStateReport=FM on, CM off
    ...                                                    riStateReport=FM off, CM on          #FM on, CM off
    ...                                                    rimRsStateReport=FM on, CM off
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    # Update RIM RS configuration for cells where actNrRim is RI detection only
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4    5    6    7    8
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=RI detection only
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=no mitigation    #UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    2    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=framework-0
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_fdd}=      Create List    1    2    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=disabled
    ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    #
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Check NRCELL Parameters from NRCELL object for tddFrameStructure
    &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
    &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=tdLte
    ...                                                    guardPeriodLength=4Symbols
    ...                                                    lteToNrFrameShift=0ms
    Critical Step                     Check tddFrameStructure Parameters    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
    #
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    IF    ${is_alarm_present} and '${param.bsr_target}' != '${None}'
                     Critical Step    Software Download BSR file SR    ${param}
    END
    #
    CB014613 Call And Then Traffic SR-CR    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
    ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
    ...                               bypassX2Setup=${True}
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB014613_SR_A_9_Check_Adjusted_RI_Detection_Thres_Empty_When_actDynamicRiThresBaseCalc_Online_Modified_To_False
##CB014613-A-9-Check_Adjusted_RI_Detection_Thres_Empty_When_actDynamicRiThresBaseCalc_Online_Modified_To_False
#USELESS#[Tags]    CLOUD_5G_I_MP_AP_LOOO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_GMC
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB014613_SETTINGS_TDD_GMC}
    ${param.test_name}=               Set Variable    TC_CB014613_SR_A_9
    Set To Dictionary                 ${param}    counter_constraint    CB014613_SR_A_9
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${False}
    ...                                                    is_capture_syslog=${True}
    ...                                                    is_capture_snapshot=${True}
    #
    Configure Parameter In WTS basic_setup File    identifier=set_ue simulated id=1    param=cell    value=1
    Configure Parameter In WTS basic_setup File    identifier=set_ue simulated id=2    param=cell    value=1
    Configure Parameter In WTS basic_setup File    identifier=set_ue simulated id=3    param=cell    value=2
    Configure Parameter In WTS basic_setup File    identifier=set_ue simulated id=4    param=cell    value=2
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=3    call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=4    call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    # Update RAD debug and other parameters using swconfig.txt
    Step                              Set RAD Parameters SR    rad_0x58057A_val=4    rad_0x58057F_val=3    rad_0x58061C_val=15    rad_0x58061D_val=25
    ...                               rad_0x10040_val=2
    Step                              Set CPLANE RAD Parameters SR
    # The following step is not useful for Classical but it is just for testing the online modification using keyword delivered by SWENG
    # Update RAD non-debug parameters using AaShell command and online modification
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    #                                 actRimCmFmReport:
    ...                                                    dlMutingStateReport=FM off, CM on
    ...                                                    riStateReport=FM off, CM on          #FM on, CM off
    ...                                                    rimRsStateReport=FM off, CM on
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    # Update RIM RS configuration for cells where actNrRim is RI detection only
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=RI detection only
    # and specific for 60MHz
    ...                                                    chBw=60MHz
    ...                                                    maxNumOfCaUsersNRCell=128
    ...                                                    maxNumOfNrDcSnUsers=250
    ...                                                    maxNumOfRrcSA=250
    ...                                                    maxNumOfUsersPerCell=250
    ...                                                    maxNumOfUsersPerNRCell=250
    ...                                                    pMax=230
    ...                                                    reqMinNumPuschPrb=1
    #
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=no mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=2.5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    2    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=framework-0
    # and specific for 60MHz
    ...                                                    chBw=60MHz
    ...                                                    maxNumOfCaUsersNRCell=128
    ...                                                    maxNumOfNrDcSnUsers=250
    ...                                                    maxNumOfRrcSA=250
    ...                                                    maxNumOfUsersPerCell=250
    ...                                                    maxNumOfUsersPerNRCell=250
    ...                                                    pMax=230
    ...                                                    reqMinNumPuschPrb=1
    #
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=2.5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=framework-0
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=2.5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=1
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=3
    ...                                                    rimDlMutingMaxRange=DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_next}=     Create List    4    5    6    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell_next}=              Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=disabled
    ...                                                    nrcell_tdd=${list_position_nrcell_next}
    Step                              SCF Configure NRCELL    ${dico_nrcell_next}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    #
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Check NRCELL Parameters from NRCELL object for tddFrameStructure
    &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
    &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=semiStatic
    ...                                                    guardPeriodLength=2Symbols
    ...                                                    ulDlDataSlotRatio=1/4
    Critical Step                     Check tddFrameStructure Parameters    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
    #
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    IF    ${is_alarm_present} and '${param.bsr_target}' != '${None}'
                     Critical Step    Software Download BSR file SR    ${param}
    END
    #
    CB014613 Call And Then Traffic SR A_9    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
    ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
    ...                               bypassX2Setup=${False}
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB014613_SR_A_12_Check_Adjusted_RI_Detection_Thres_Updated_When_nrRiMonitorWindow_Online_Modified
##CB014613-A-12-Check_Adjusted_RI_Detection_Thres_Updated_When_ nrRiMonitorWindow_Online_Modified
#USELESS#[Tags]    CLOUD_5G_O_E_AP_LOOO    VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB014613_SETTINGS_RJIO_5_1}
    ${param.test_name}=               Set Variable    TC_CB014613_SR_A_12
    Set To Dictionary                 ${param}    counter_constraint    CB014613_SR_A_12
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${False}
    ...                                                    is_capture_syslog=${True}
    ...                                                    is_capture_snapshot=${True}
    #
    # Prerequisite for internal testing and for checking PR868877
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Get NRCELL Parameters SR-CR from NRRIMINFO object
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=no RI
    ...                                                    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrriminfo_result}=              Get NRCELL Parameters SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    ...                               extra_dist_name=NRRIMINFO-1
    Dated Log New Line                ${cc_yellow}> Get NRRIMINFO Parameters SR-CR result=${nrriminfo_result}${cc_normal}
    #
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=22   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    # Update RAD debug and other parameters using swconfig.txt
    Step                              Set RAD Parameters SR    rad_0x58057A_val=4    rad_0x58057F_val=3    rad_0x58061C_val=15    rad_0x58061D_val=20
    ...                               rad_0x10040_val=2
    Step                              Set CPLANE RAD Parameters SR
    # The following step is not useful for Classical but it is just for testing the online modification using keyword delivered by SWENG
    # Update RAD non-debug parameters using AaShell command and online modification
    # rdRiDataTrimThreshold set to default value=15
#    Set Rad Parameter Using Aashell    rad_param_value=15    rad_param=0x58061c
    # rdAutoRiThresBaseCalcInterval set to 20 minutes (default=0)
#    Set Rad Parameter Using Aashell    rad_param_value=20    rad_param=0x58061d
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    #                                 actRimCmFmReport:
    ...                                                    dlMutingStateReport=FM on, CM off
    ...                                                    riStateReport=FM off, CM on          #FM on, CM off
    ...                                                    rimRsStateReport=FM on, CM off
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    # Update RIM RS configuration for cells where actNrRim is RI detection only
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4    5    6    7    8
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=RI detection only
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=no mitigation    #UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=4    # 5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=2
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=1    #3
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    2    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=framework-0
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=4    # 5
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=2
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=1    #3
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_fdd}=      Create List    1    2    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=disabled
    ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    #
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Check NRCELL Parameters from NRCELL object for tddFrameStructure
    &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
    &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=tdLte
    ...                                                    guardPeriodLength=4Symbols
    ...                                                    lteToNrFrameShift=0ms
    Critical Step                     Check tddFrameStructure Parameters    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
    #
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    IF    ${is_alarm_present} and '${param.bsr_target}' != '${None}'
                     Critical Step    Software Download BSR file SR    ${param}
    END
    #
    CB014613 Call And Then Traffic SR A_12    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
    ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
    ...                               bypassX2Setup=${True}
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB014613_CR_A_14_Check_Adjusted_RI_Detection_Thres_Updated_When_rdRiDataTrimThreshold_Online_Modified
##CB014613-A-14-Check_Adjusted_RI_Detection_Thres_Updated_When_ rdRiDataTrimThreshold_Online_Modified
#USELESS#[Tags]    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB014613_SETTINGS_CR_1}
    ${param.test_name}=               Set Variable    TC_CB014613_CR_A_14
    Set To Dictionary                 ${param}    counter_constraint    CB014613_CR_A_14
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${False}
    ...                                                    is_capture_syslog=${False}
    ...                                                    is_capture_snapshot=${True}
    #
    # Prerequisite for internal testing and for checking PR868877
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Get NRCELL Parameters SR-CR from NRRIMINFO object
    FOR    ${position}    IN          @{list_position_nrcell_for_rimrs}
                                      Get Remote Interference State From NRRIMINFO    position_nrcell=${position}   ri_state=no RI   iteration_max=1
        ...                           confirm_detection=${False}
    END
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=22   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    # Update RAD debug parameters using OAM command like WebEM
    Step                              Set RAD Parameters CR    rad_0x58057A_val=4    rad_0x58057F_val=3
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    #                                 actRimCmFmReport:
    ...                                                    dlMutingStateReport=FM on, CM off
    ...                                                    riStateReport=FM off, CM on          #FM on, CM off
    ...                                                    rimRsStateReport=FM on, CM off
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    # Update RIM RS configuration for cells where actNrRim is RI detection only
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=RI detection only
    ...                                                    actRimPdcchMuting=disabled
    ...                                                    actRimPdcchMutingOnSpecialSlot=disabled
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=no mitigation    #UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=3
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=2
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=1
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    2    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=framework-0
    ...                                                    actRimPdcchMuting=disabled
    ...                                                    actRimPdcchMutingOnSpecialSlot=disabled
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=3
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=2
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=1
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_fdd}=      Create List    1    2    3    4    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=disabled
    ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    # Update RAD non-debug parameters using AaShell command and online modification
    Dated Log                         > Set Rad Parameter Using Aashell for L2PS domain
    # rdRiDataTrimThreshold set to default value=15
    Set Rad Parameter Using Aashell   rad_param_value=15    rad_param=0x58061c    domain_nom=ute-l2rt-a-0    domain_elem=ctr-l2rt
    # rdAutoRiThresBaseCalcInterval set to 12 minutes (default=0)
    Set Rad Parameter Using Aashell   rad_param_value=12    rad_param=0x58061d    domain_nom=ute-l2rt-a-0    domain_elem=ctr-l2rt
    #
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Check NRCELL Parameters from NRCELL object for tddFrameStructure
    &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
    &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=tdLte
    ...                                                    guardPeriodLength=4Symbols
    ...                                                    lteToNrFrameShift=3ms
    Critical Step                     Check tddFrameStructure Parameters CR    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
    #
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    Should Be True                    ${is_alarm_present} == ${False}
    ${is_alarm_present}=              Set Variable    ${False}
    IF    ${isAic}
        # This step is not useful but it is just to test Is Alarm Present on CU
        ${is_alarm_present}=    Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1  confirm_presence=${False}  oam_type=${GNB_CU.oam}
    END
    Should Be True                    ${is_alarm_present} == ${False}
    #
    CB014613 Call And Then Traffic SR-CR A_14    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
    ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
    ...                               bypassX2Setup=${False}
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB014613_SR_A_14_Check_Adjusted_RI_Detection_Thres_Updated_When_rdRiDataTrimThreshold_Online_Modified
##CB014613-A-14-Check_Adjusted_RI_Detection_Thres_Updated_When_ rdRiDataTrimThreshold_Online_Modified
#USELESS#[Tags]    CLOUD_5G_O_E_AP_LOOO    VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB014613_SETTINGS_RJIO_5_1}
    ${param.test_name}=               Set Variable    TC_CB014613_SR_A_14
    Set To Dictionary                 ${param}    counter_constraint    CB014613_SR_A_14
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${False}
    ...                                                    is_capture_syslog=${True}
    ...                                                    is_capture_snapshot=${True}
    #
    # Prerequisite for internal testing and for checking PR868877
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Get NRCELL Parameters SR-CR from NRRIMINFO object
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=no RI
    ...                                                    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrriminfo_result}=              Get NRCELL Parameters SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    ...                               extra_dist_name=NRRIMINFO-1
    Dated Log New Line                ${cc_yellow}> Get NRRIMINFO Parameters SR-CR result=${nrriminfo_result}${cc_normal}
    #
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=22   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=1         throughput_ul=1            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    # Update RAD debug and other parameters using swconfig.txt
    # rdRiDataTrimThreshold set to default value=15
    # rdAutoRiThresBaseCalcInterval set to 12 minutes (default=0)
    Step                              Set RAD Parameters SR    rad_0x58057A_val=4    rad_0x58057F_val=3    rad_0x58061C_val=15    rad_0x58061D_val=12
    ...                               rad_0x10040_val=2
    Step                              Set CPLANE RAD Parameters SR
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    #                                 actRimCmFmReport:
    ...                                                    dlMutingStateReport=FM on, CM off
    ...                                                    riStateReport=FM off, CM on          #FM on, CM off
    ...                                                    rimRsStateReport=FM on, CM off
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    # Update RIM RS configuration for cells where actNrRim is RI detection only
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4    5    6    7    8
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=RI detection only
    ...                                                    actRimPdcchMuting=disabled
    ...                                                    actRimPdcchMutingOnSpecialSlot=disabled
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=no mitigation    #UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=3
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=2
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=1
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    # Update RIM RS configuration for cells where actNrRim is framework-0
    @{list_position_nrcell_tdd}=      Create List    2    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=framework-0
    ...                                                    actRimPdcchMuting=disabled
    ...                                                    actRimPdcchMutingOnSpecialSlot=disabled
    ...                                                    factorRsSequence=2
    ...                                                    maxRsDetectDurationWithoutRi=30
    ...                                                    minDlMitigationDurationWoRi=10
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=0
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    actDynamicRiThresBaseCalc=true
    ...                                                    autoRiThresBaseCalcInterval=48
    ...                                                    nrRiMonitorWindow=3
    ...                                                    nrRiThresDurationRatio=50
    ...                                                    nrRiThresBase=-110
    ...                                                    nrRiThresDropHeight=3
    ...                                                    nrRiUpdateInterval=2
    ...                                                    numWinRiDetectForDlMitigation=1
    ...                                                    riExpectedRssiRangeThres=1
    ...                                                    rimDlMutingMaxRange=2DL+special slots
    ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_tdd}=      Create List    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=disabled
    ...                                                    actRimPdcchMuting=disabled
    ...                                                    actRimPdcchMutingOnSpecialSlot=disabled
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    @{list_position_nrcell_fdd}=      Create List    1    2    3    # 1= first nrcell, 2nd, 3rd, etc.
    &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA
    ...                                                    actNrRim=disabled
    ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    #
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    # Check NRCELL Parameters from NRCELL object for tddFrameStructure
    &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
    &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=tdLte
    ...                                                    guardPeriodLength=4Symbols
    ...                                                    lteToNrFrameShift=0ms
    Critical Step                     Check tddFrameStructure Parameters    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
    #
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    IF    ${is_alarm_present} and '${param.bsr_target}' != '${None}'
                     Critical Step    Software Download BSR file SR    ${param}
    END
    #
    CB014613 Call And Then Traffic SR-CR A_14    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
    ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
    ...                               bypassX2Setup=${True}
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------
#[1] CB014613_RJIO_CVR_001_A_1_PREP
##CB014613-A-15-Check_ Adjusted_RI_Detection_Thres_Per_Subband_Dynamically_Updated_RJIO_FrameStructure
#USELESS#[Tags]    CLOUD_5G_O_E_AP_LOOO    VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
#   #
#   Dated Log New Line                ----Test Initialization-------------------------------------------------------
#   GenericTest.Init Sequence         param=${CB014613_SETTINGS_RJIO_5_1}
#   ${param.test_name}=               Set Variable    TC_CB014613_RJIO_CVR_001_A_1_PREP
#   Set To Dictionary                 ${param}    counter_constraint    CB014613_RJIO_CVR_001_A_1_PREP
#   Step                              ${param.set_suite_dist_name_variables}
#   &{is_capture}=                    Create Dictionary    is_capture_core=${False}
#   ...                                                    is_capture_cprt=${False}
#   ...                                                    is_capture_l1l2=${True}
#   ...                                                    is_capture_tti=${False}
#   ...                                                    is_capture_syslog=${True}
#   ...                                                    is_capture_snapshot=${True}
#   #
#   Configure Parameter In WTS basic_setup File    identifier=set_ue simulated id=29    param=cell    value=3
#   Configure Parameter In WTS basic_setup File    identifier=set_ue simulated id=30    param=cell    value=3
#   #
#   &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
#   ...                               throughput=1         throughput_ul=1            throughput_gbr=0
#   &{dict_ue_2}=                     Create Dictionary    ue_id=2    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
#   ...                               throughput=1         throughput_ul=1            throughput_gbr=0
#   &{dict_ue_3}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
#   ...                               throughput=1         throughput_ul=1            throughput_gbr=0
#   &{dict_ue_4}=                     Create Dictionary    ue_id=22   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
#   ...                               throughput=1         throughput_ul=1            throughput_gbr=0
#   &{dict_ue_5}=                     Create Dictionary    ue_id=29   call_type=SA    original_cell=3    paging=${False}    csi_override_cqi=0
#   ...                               throughput=1         throughput_ul=1            throughput_gbr=0
#   &{dict_ue_6}=                     Create Dictionary    ue_id=30   call_type=SA    original_cell=3    paging=${False}    csi_override_cqi=0
#   ...                               throughput=1         throughput_ul=1            throughput_gbr=0
#   ${current_ues_settings}=          Create List
#   ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}    ${dict_ue_5}    ${dict_ue_6}
#   ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
#   ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
#   Dated Log New Line                > Test name is ${param.test_name}
#   #
#   # Update RAD debug and other parameters using swconfig.txt
#   Step                              Set RAD Parameters SR    rad_0x58057A_val=4    rad_0x58057F_val=3    rad_0x58061C_val=15   rad_0x58061D_val=20
#   Dated Log New Line                ----Test Commissioning--------------------------------------------------------
#   ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
#   #
#   &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
#   ...                                                    actNrRimRsResourcePooling=false
#   #                                 actRimCmFmReport:
#   ...                                                    dlMutingStateReport=FM on, CM off
#   ...                                                    riStateReport=FM off, CM on
#   ...                                                    rimRsStateReport=FM on, CM off
#   Step                              SCF Configure NRBTS    ${dico_nrbts}
#   #
#   # Update RIM RS configuration for cells where actNrRim is framework-1
#   @{list_position_nrcell_tdd}=      Create List    1    2    3    # 1= first nrcell, 2nd, 3rd, etc.
#   @{list_rsType1NScId}=             Create List    1    2    3    4    5    6    7    8
#   @{list_rsType2NScId}=             Create List    1    2    3    4    5    6    7    8
#   @{list_startFreqOffsetForRs}=     Create List    96    144
#   &{dico_nrcell}=                   Create Dictionary    cellDepType=SA
#   ...                                                    actNrRim=framework-1
#   ...                                                    actRimPdcchMutingOnSpecialSlot=true
#   ...                                                    factorRsSequence=2
#   ...                                                    factorRsSequenceRs2=2
#   ...                                                    globalF0ForRs=633390
#   ...                                                    maxRsDetectDurationWithoutRi=30
#   ...                                                    minDlMitigationDurationWoRi=10
#   ...                                                    nrRimMitigationScheme=UL and DL mitigation
#   ...                                                    nrRimRsUpdateInterval=3
#   ...                                                    numRbForRs=48 RBs
#   ...                                                    numRsType1SetId=524288 setIDs
#   ...                                                    numRsType2SetId=524288 setIDs
#   ...                                                    offsetRsSequence=0
#   ...                                                    offsetRsSequenceRs2=0
#   ...                                                    repetitionRsType1=r2
#   ...                                                    repetitionRsType2=r2
#   ...                                                    rsNearFarConfig=near only
#   ...                                                    rsPattern1Period=5ms
#   ...                                                    rsTransTrigger=RI trigger
#   ...                                                    rsType1NScId=${list_rsType1NScId}
#   ...                                                    rsType2NScId=${list_rsType2NScId}
#   ...                                                    startFreqOffsetForRs=${list_startFreqOffsetForRs}
#   ...                                                    actDynamicRiThresBaseCalc=false
#   ...                                                    autoRiThresBaseCalcInterval=168
#   ...                                                    nrRiMonitorWindow=5
#   ...                                                    nrRiThresDurationRatio=50
#   ...                                                    nrRiThresBase=-110
#   ...                                                    nrRiThresDropHeight=3
#   ...                                                    nrRiUpdateInterval=1
#   ...                                                    numWinRiDetectForDlMitigation=1
#   ...                                                    riExpectedRssiRangeThres=3
#   ...                                                    rimDlMutingMaxRange=2DL+special slots
#   ...                                                    rimDynamicSrsSlotOffsetEnabled=enabled
#   ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
#   Step                              SCF Configure NRCELL For RIM RS    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
#   #
#   @{list_position_nrcell_fdd}=      Create List    1    2    3    # 1= first nrcell, 2nd, 3rd, etc.
#   &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA
#   ...                                                    actNrRim=disabled
#   ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
#   Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
#   #
#   # Update NRPMRNL configuration
#   &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
#   ...                                                    miNrMacSduReport=5min
#   ...                                                    miNrRim=5min
#   Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
#   #
#   ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
#   ...                               skip_errors=${False}
#   Dated Log New Line                ------------------------------------------------------------------------------
#   #
#   # Check NRCELL Parameters from NRCELL object for tddFrameStructure
#   &{dico_nrcell}=                   Create Dictionary    tddFrameStructure=${None}
#   ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
#   ${nrcell_result}=                 Get NRCELL Parameters SR-CR    dico=${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
#   Dated Log New Line                ${cc_yellow}> Get NRCELL Parameters SR-CR result=${nrcell_result}${cc_normal}
#   &{dico_tddFrameStructure}=        Create Dictionary    frameStructureType=tdLte
#   ...                                                    guardPeriodLength=4Symbols
#   ...                                                    lteToNrFrameShift=0ms
#   Critical Step                     Check tddFrameStructure Parameters    dico=${dico_tddFrameStructure}    list_elem=${nrcell_result}
#   #
#   # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
#   Traced Sleep    duration=90s    msg=restart and possible update of the BSR package missing
#   ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
#   IF    ${is_alarm_present} and '${param.bsr_target}' != '${None}'
#                    Critical Step    Software Download BSR file SR    ${param}
#   END
#   #
#   CB014613 Call And Then Traffic SR-CR    param=${param}    ues_settings=${current_ues_settings}    capture_settings=${is_capture}
#   ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}
#   ...                               frameStructureType=${dico_tddFrameStructure}[frameStructureType]
#   ...                               bypassX2Setup=${True}
#   #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
#[1] CR_001_SA_call_w_traffic_ul_dl_ngbr
##USELESS#[Tags]    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
#   #
#   Dated Log New Line                ----Test Initialization-------------------------------------------------------
#   GenericTest.Init Sequence         param=${TEST_SETTINGS_CR_1}
#   ${param.test_name}=               Set Variable    TC_CR_001_SA
#   Set To Dictionary                 ${param}    counter_constraint    CR_001_SA
#   Step                              ${param.set_suite_dist_name_variables}
#   &{is_capture}=                    Create Dictionary    is_capture_core=${False}
#   ...                                                    is_capture_cprt=${False}
#   ...                                                    is_capture_l1l2=${True}
#   ...                                                    is_capture_tti=${True}
#   ...                                                    is_capture_syslog=${False}
#   ...                                                    is_capture_snapshot=${True}
#   #
#   &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
#   ...                               throughput=30        throughput_ul=15           throughput_gbr=0
#   &{dict_ue_2}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
#   ...                               throughput=30        throughput_ul=15           throughput_gbr=0
#   &{dict_ue_3}=                     Create Dictionary    ue_id=31   call_type=SA    original_cell=3    paging=${False}    csi_override_cqi=0
#   ...                               throughput=10        throughput_ul=3            throughput_gbr=0
#   &{dict_ue_4}=                     Create Dictionary    ue_id=41   call_type=SA    original_cell=4    paging=${False}    csi_override_cqi=0
#   ...                               throughput=10        throughput_ul=3            throughput_gbr=0
#   &{dict_ue_5}=                     Create Dictionary    ue_id=51   call_type=SA    original_cell=5    paging=${False}    csi_override_cqi=0
#   ...                               throughput=10        throughput_ul=3            throughput_gbr=0
#   &{dict_ue_6}=                     Create Dictionary    ue_id=61   call_type=SA    original_cell=6    paging=${False}    csi_override_cqi=0
#   ...                               throughput=10        throughput_ul=3            throughput_gbr=0
#   ${current_ues_settings}=          Create List
#   ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}    ${dict_ue_5}    ${dict_ue_6}
#   ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
#   ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
#   Dated Log New Line                > Test name is ${param.test_name}
#   #
#   Dated Log New Line                ----Test Commissioning--------------------------------------------------------
#   @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
#   @{list_position_nrcell_fdd}=      Create List    1    2    3    4    # 1= first nrcell, 2nd, 3rd, etc.
#   ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
#   #
#   &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
#   ...                                                    actNrRimRsResourcePooling=false
#   Step                              SCF Configure NRBTS    ${dico_nrbts}
#   #
#   &{dico_nrcell_tdd}=               Create Dictionary    cellDepType=SA+NSA
#   ...                                                    actNrRim=disabled
#   ...                                                    actVoNR=true
#   ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
#   Step                              SCF Configure NRCELL    ${dico_nrcell_tdd}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
#   #
#   &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA+NSA
#   ...                                                    actNrRim=disabled
#   ...                                                    actVoNR=true
#   ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
#   Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
#   #
#   # Update NRPMRNL configuration
#   &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
#   ...                                                    miNrMacSduReport=5min
#   ...                                                    miNrRim=5min
#   Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
#   #
#   ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
#   ...                               skip_errors=${False}
#   Dated Log New Line                ------------------------------------------------------------------------------
#   #
#   Call And Then Traffic SR-CR       ${param}    ${current_ues_settings}    ${is_capture}
#   #
#   #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CR_001_1_SA_call_w_traffic_for_captures_testing
##USELESS#[Tags]    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_CR_1}
    ${param.test_name}=               Set Variable    TC_CR_001_1_SA
    Set To Dictionary                 ${param}    counter_constraint    CR_001_SA
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${True}
    ...                                                    is_capture_syslog=${False}
    ...                                                    is_capture_snapshot=${True}
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=1    call_type=SA    original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=30        throughput_ul=15           throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=21   call_type=SA    original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=30        throughput_ul=15           throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=31   call_type=SA    original_cell=3    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=41   call_type=SA    original_cell=4    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    &{dict_ue_5}=                     Create Dictionary    ue_id=51   call_type=SA    original_cell=5    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    &{dict_ue_6}=                     Create Dictionary    ue_id=61   call_type=SA    original_cell=6    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}    ${dict_ue_2}    ${dict_ue_3}    ${dict_ue_4}    ${dict_ue_5}    ${dict_ue_6}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ------------------------------------------------------------------------------
    Call And Then Traffic For Captures Testing       ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CR_002_NSA_call_w_traffic_ul_dl_ngbr
##USELESS#[Tags]    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_CR_1}
    ${param.test_name}=               Set Variable    TC_CR_002_NSA
    Set To Dictionary                 ${param}    counter_constraint    CR_002_NSA
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${True}
    ...                                                    is_capture_syslog=${False}
    ...                                                    is_capture_snapshot=${True}
    #
    &{dict_ue_1}=                     Create Dictionary    ue_id=101  call_type=NSA   original_cell=1    paging=${False}    csi_override_cqi=0
    ...                               throughput=30        throughput_ul=15           throughput_gbr=0
    &{dict_ue_2}=                     Create Dictionary    ue_id=121  call_type=NSA   original_cell=2    paging=${False}    csi_override_cqi=0
    ...                               throughput=30        throughput_ul=15           throughput_gbr=0
    &{dict_ue_3}=                     Create Dictionary    ue_id=231  call_type=SNA   original_cell=3    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    &{dict_ue_4}=                     Create Dictionary    ue_id=241  call_type=NSA   original_cell=4    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    &{dict_ue_5}=                     Create Dictionary    ue_id=251  call_type=NSA   original_cell=5    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    &{dict_ue_6}=                     Create Dictionary    ue_id=261  call_type=NSA   original_cell=6    paging=${False}    csi_override_cqi=0
    ...                               throughput=10        throughput_ul=3            throughput_gbr=0
    ${current_ues_settings}=          Create List
    ...                               ${dict_ue_1}   ${dict_ue_2}   ${dict_ue_3}   ${dict_ue_4}   ${dict_ue_5}    #FAILED#${dict_ue_6}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    0
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_position_nrcell_fdd}=      Create List    1    2    3    4    # 1= first nrcell, 2nd, 3rd, etc.
    ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    #
    &{dico_nrbts}=                    Create Dictionary    reportingIntervalPm=5min
    ...                                                    actNrRimRsResourcePooling=false
    Step                              SCF Configure NRBTS    ${dico_nrbts}
    #
    &{dico_nrcell_tdd}=               Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=disabled
    ...                                                    actVoNR=true
    ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_tdd}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    #
    &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=disabled
    ...                                                    actVoNR=true
    ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    #
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrMacSduReport=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}    updated_scf_vcu=${scf_vcu_file}
    ...                               skip_errors=${False}
    Dated Log New Line                ------------------------------------------------------------------------------
    Call And Then Traffic SR-CR       ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
