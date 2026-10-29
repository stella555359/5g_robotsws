*** Settings ***
Library     OperatingSystem
Library     Collections
Library     DateTime
Library     String
Library     ta_attenuator
Library     taf.ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.qxdm_log_collector.QxdmLogCollector    WITH NAME    QXDM
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.qxdm_verification.qxdm_verification
Library     ./test_specific_keywords_CB006062.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/tti_verification/tti_streaming/tti_streaming.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Documentation  Set of keywords for feature CB006062 execution

*** Variables ***
${UE_MODE}  NSA

*** Keywords ***
CB006062 Suite Setup
    Set Suite Variable    ${test_name}    CB006062_suite_setup
    ${admin}=  taf_admin.Setup_Admin  alias=admin_gnb
    ${sw}=  taf_admin.Get_Sw_Version  connection=${admin}
    ${dlptrs_not_supported}=  Check If Dlptrs Not Supported  ${sw}
    ${is_it_newer_branch}=  Check If Newer Branch  ${sw}
    Set Global Variable  ${IS_IT_NEWER_BRANCH}  ${is_it_newer_branch}
    Set Global Variable  ${DLPTRS_NOT_SUPPORTED}  ${dlptrs_not_supported}
    Set Suite Variable    ${gNB_IP}    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    Set Initial Attenuation
    Prepare Ue
#    IF  '${UE_MODE}'=='NSA'  Change to SA
    [Teardown]  taf_admin.Teardown_Admin    connection=admin_gnb


CB006062 Suite Teardown
#    IF  '${UE_MODE}'=='SA'  Change to NSA
    Run Keyword And Ignore Error    taf_admin.Teardown_Admin    connection=admin_gnb
    Set Attenuation For All Cells  90dB
    Release Attenuator Cell    ${gnb_cells}


Common CB006062 Test Setup
    [Arguments]    ${subfeature}
    QXDM.Setup
    QXDM.Set Logging Filter   C:/auto/6062.dmc
    Set Attenuation   ${CELL_ALIAS}  10db
    Set Initial Scf Parameters    ${subfeature}
    Set TESTNAME without spaces
    Set Test Variable    ${LOG_PATH}    ${LOG_PATH}/${test_name}
    Run  mkdir -p ${LOG_PATH}
    Start Bts Log  btslog
    Collect SCF Before Test
    Start Logging


Teardown
    Run Keyword If Test Failed  Stop Logging And Gather Logs
    Run Keyword If Test Passed  Stop Logging
    Stop And Collect Btslog  btslog  ${LOG_PATH}
    QXDM.Shutdown
    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1
    Set Attenuation    ${CELL_ALIAS}    90dB
    Add Scout Scf Id To Test Data
    Make Snapshot If Test Failed
    Run Keyword And Ignore Error    interface.Common Step Trigger


Collect SCF Before Test
    taf_admin.Setup_Admin    bts_host=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    alias=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Collect_Scf    ${LOG_PATH}/scf/backup_scf.xml    connection=admin_gnb
    [Teardown]  taf_admin.Teardown_Admin    connection=admin_gnb


Start Logging
    Kill tcpdump on CU
    Start gnbMirroring
    Start Tcpdump On CU    filename=${test_name}_SCTP.pcap
    Log To Console    \nLogging Started...


Stop Logging
    Kill tcpdump on CU
    Stop gnbMirroring
    Log To Console    \nLogging Stopped...


Stop Logging And Gather Logs
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap
    Stop gnbMirroring And Gather L1L2 logs
    Log To Console    \nLogging Stopped...


Stop gnbMirroring
    Connect to ASIK
    ${abil_master_alias}=    Connect to ABIL MASTER
    ssh.Execute         command=killall tcpdump   connection=${abil_master_alias}


Make Snapshot If Test Failed
    Set TESTNAME without spaces
    Run Keyword If Test Failed   webUI_operations.make webui snapshot


Set Initial Attenuation
    ${cell_list}=   Create list   ${CELL_ALIAS}
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${CELL_ALIAS}    0dB
    Sleep  2s


Prepare Ue
    taf.ue.Require UE    UE_1    capabilities=REAL_ANDROID_UE
    taf.ue.Detach UE     UE_1
    Sleep    5s


Attach
    taf.ue.Attach UE    UE_1
    Log to Console    \nUE Attached!
    Sleep    10s


Check If TransformPrecoder=Enabled
    [Arguments]    ${log_name}
    Check RRC Message Enabled    txt_path=${log_name}


Check If TransformPrecoder=Disabled
    [Arguments]    ${log_name}
    Check RRC Message Disabled    txt_path=${log_name}


6062-BD_SA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_For_FDD_FR1-Tput_UL_DL_Check-1_Additional_DMRS-PTRS_OFF
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>77000
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_SA}    DT_UL_FALSE_LOW    DT_DL_FALSE_LOW
    ...                                          diag_log_false_low_mcs
    ${dt_ul_false_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
    ${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_SA}    ${4}    ${1}
    ...                            DT_UL_FALSE_PRECODER_ENABLED  DT_DL_FALSE_PRECODER_ENABLED    diag_log_false_precoder_enabled
	Check If TransformPrecoder=Enabled     ${qxdm_log}
    Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log     ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>83000
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_SA}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW
    ...                                          diag_log_true_low_mcs
    ${dt_ul_true_low}=   Get Average Throughput from QXDM log     ${qxdm_log}
    ${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_SA}    ${4}    ${1}
    ...                              DT_UL_TRUE_PRECODER_ENABLED  DT_DL_TRUE_PRECODER_ENABLED    diag_log_true_precoder_enabled
	Check If TransformPrecoder=Enabled     ${qxdm_log}
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1.07}    ${0.02}
    Compare Throughputs    ${dt_ul_false_low}    ${dt_ul_true_low}    ${1}    ${0.5}


6062-BF_SA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_PUSCH_256QAM_For_FDD_F1-Tput_UL_DL_Check-PTRS_OFF
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>102000
    Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>110000
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1.07}    ${0.02}


6062-B_SA-Basic_Support_Of_PUSCH_Data_And_DMRS_FDM_For_FDD_FR1-Tput_UL_DL_Check
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>81000
    Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>83000
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1}    ${0.02}


6062-B_SA_ActivationDeactivation_For_PUSCH_Data_And_DRMS_FDM
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>81000
	Check Antenna Ports Value    ${qxdm_log}   2
    Change Feature Activation And Reset UE State   enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>83000
	Check Antenna Ports Value    ${qxdm_log}   0
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_SA}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW
    ...                                          diag_log_true_low_mcs
	Check Antenna Ports Value    ${qxdm_log}   2
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1}    ${0.02}


6062-B_NSA_ActivationDeactivation_For_PUSCH_Data_And_DRMS_FDM
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_FALSE_HIGH_1    DT_DL_FALSE_HIGH_1
    ...                                          diag_log_false_high_mcs_1
    ${dt_ul_false_high_1}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high_1}>81000
	Check Antenna Ports Value    ${qxdm_log}    2
    Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>83000
	Check Antenna Ports Value    ${qxdm_log}    0
    Change Feature Activation And Reset UE State   disable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_FALSE_HIGH_2    DT_DL_FALSE_HIGH_2
    ...                                          diag_log_false_high_mcs_2
    ${dt_ul_false_high_2}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high_2}>81000
	Check Antenna Ports Value    ${qxdm_log}    2
    taf.ue.Detach UE    UE_1
    ${dt_set_1}=   Create List    ${dt_ul_false_high_1}    ${dt_ul_false_high_2}    ${dt_ul_false_high_2}
    ${dt_set_2}=    Create List   ${dt_ul_true_high}    ${dt_ul_false_high_1}    ${dt_ul_true_high}
    Compare Throughputs    ${dt_set_1}    ${dt_set_2}    ${1}    ${0.02}


6062-B_NSA_Basic_Support_Of_PUSCH_Data_And_DRMS_FDM_For_FDD_FR1-Tput_UL_DL_Check
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>81000
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_NSA}    DT_UL_FALSE_LOW    DT_DL_FALSE_LOW
    ...                                          diag_log_false_low_mcs
    Get Average Throughput from QXDM log   ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
	Change Feature Activation And Reset UE State   enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log   ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>83000
	Check Antenna Ports Value    ${qxdm_log}    0
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_NSA}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW
    ...                                          diag_log_true_low_mcs
    Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
	taf.ue.Detach UE   UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1}    ${0.02}


6062_BI_SA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_PUSCH_256QAM_And_Aperiodic_CSI_For_FDD_FR1-Tput_UL_DL_Check_PTRS_OFF
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>102000
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_WITH_CSI_SA}    DT_UL_FALSE_LOW    DT_DL_FALSE_LOW
    ...                                          diag_log_false_low_mcs
    ${dt_ul_false_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
    ${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_WITH_CSI_SA}    ${4}    ${1}
    ...                          DT_UL_FALSE_PRECODER_ENABLED    DT_DL_FALSE_PRECODER_ENABLED    diag_log_false_precoder_enabled
	Check If TransformPrecoder=Enabled    ${qxdm_log}
    Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_SA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>110000
    ${qxdm_log}=     Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_WITH_CSI_SA}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW
    ...                                           diag_log_true_low_mcs
    ${dt_ul_true_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
    ${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_WITH_CSI_SA}    ${4}    ${1}
    ...                          DT_UL_TRUE_PRECODER_ENABLED    DT_DL_TRUE_PRECODER_ENABLED   diag_log_true_precoder_enabled
	Check If TransformPrecoder=Enabled    ${qxdm_log}
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1.07}    ${0.02}
    Compare Throughputs    ${dt_ul_false_low}    ${dt_ul_true_low}    ${1}    ${0.5}
    Verify Aperiodic CSI In Snapshot    should_be_zero=${False}


6062_BI_NSA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_PUSCH_256QAM_And_Aperiodic_CSI_For_FDD_FR1
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>110000
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_NSA_BI}    DT_UL_FALSE_MIDDLE    DT_DL_FALSE_MIDDLE
    ...                                          diag_log_false_middle_mcs
    Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_WITH_CSI_NSA-BI}    DT_UL_FALSE_LOW    DT_DL_FALSE_LOW
    ...                                          diag_log_false_low_mcs
    ${dt_ul_false_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    0
    ${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_WITH_CSI_NSA-BI}    ${5}    ${1}
    ...                                     DT_UL_PRECODER_ENABLED  DT_DL_PRECODER_ENABLED   diag_log_precoder_enabled_false
	Check If TransformPrecoder=Enabled   ${qxdm_log}
	Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>111000
	Check Antenna Ports Value    ${qxdm_log}    0
	${qxdm_log}=    Save Throughput QXDM Logs    ${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_NSA_BI}    DT_UL_TRUE_MIDDLE    DT_DL_TRUE_MIDDLE
	...                                          diag_log_true_middle_mcs
	Get Average Throughput from QXDM log   ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_WITH_CSI_NSA-BI}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW
    ...                                          diag_log_true_low_mcs
    ${dt_ul_true_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}   0
	${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_WITH_CSI_NSA-BI}    ${5}    ${1}
    ...                 DT_UL_PRECODER_ENABLED  DT_DL_PRECODER_ENABLED   diag_log_precoder_enabled_true
	Check If TransformPrecoder=Enabled    ${qxdm_log}
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1}    ${0.02}
    Compare Throughputs    ${dt_ul_false_low}    ${dt_ul_true_low}    ${1}    ${0.5}
    Verify Aperiodic CSI In Snapshot    should_be_zero=${False}


6062_BI_NSA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_PUSCH_256QAM_And_Aperiodic_CSI_For_FDD_FR1_PTRS_OFF
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>102000
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_NSA_BI}    DT_UL_FALSE_MIDDLE    DT_DL_FALSE_MIDDLE
    ...                                          diag_log_false_middle_mcs
    Get Average Throughput from QXDM log   ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_NSA-BI}    DT_UL_FALSE_LOW    DT_DL_FALSE_LOW
    ...                                          diag_log_false_low_mcs
    ${dt_ul_false_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    0
    ${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_NSA-BI}    ${5}    ${1}    DT_UL_PRECODER_ENABLED
    ...                                                  DT_DL_PRECODER_ENABLED   diag_log_precoder_enabled_false
	Check If TransformPrecoder=Enabled    ${qxdm_log}
	Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>110000
	Check Antenna Ports Value    ${qxdm_log}   0
	${qxdm_log}=    Save Throughput QXDM Logs    ${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_NSA_BI}    DT_UL_TRUE_MIDDLE    DT_DL_TRUE_MIDDLE
	...                                          diag_log_true_middle_mcs
	Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}   2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_NSA-BI}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW    diag_log_true_low_mcs
    ${dt_ul_true_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}   0
	${qxdm_log}=    Save Throughput QXDM Logs with Signal Attenuation    ${LOW_MCS_ATTENUATION_NSA-BI}    ${5}    ${1}    DT_UL_PRECODER_ENABLED
    ...                                                  DT_DL_PRECODER_ENABLED   diag_log_precoder_enabled_true
	Check If TransformPrecoder=Enabled    ${qxdm_log}
    taf.ue.Detach UE    UE_1
    Compare Throughputs    ${dt_ul_false_high}    ${dt_ul_true_high}    ${1.07}    ${0.02}
    Compare Throughputs    ${dt_ul_false_low}    ${dt_ul_true_low}    ${1}    ${0.5}
    Verify Aperiodic CSI In Snapshot    should_be_zero=${False}


6062-BH_NSA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_Aperiodic_CSI_For_FDD_FR1-Tput_UL_DL_Check
    Attach
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_FALSE_HIGH    DT_DL_FALSE_HIGH
    ...                                          diag_log_false_high_mcs
    ${dt_ul_false_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_false_high}>81000
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${MIDDLE_MCS_ATTENUATION_NSA}    DT_UL_FALSE_MIDDLE    DT_DL_FALSE_MIDDLE
    ...                                          diag_log_false_middle_mcs
    Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_NSA}    DT_UL_FALSE_LOW    DT_DL_FALSE_LOW
    ...                                          diag_log_false_low_mcs
    ${dt_ul_false_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
    Change Feature Activation And Reset UE State    enable
    ${qxdm_log}=    Save Throughput QXDM Logs    ${HIGH_MCS_ATTENUATION_NSA}    DT_UL_TRUE_HIGH    DT_DL_TRUE_HIGH
    ...                                          diag_log_true_high_mcs
    ${dt_ul_true_high}=   Get Average Throughput from QXDM log    ${qxdm_log}
    Should Be True    ${dt_ul_true_high}>83000
	Check Antenna Ports Value    ${qxdm_log}    0
	${qxdm_log}=    Save Throughput QXDM Logs    ${MIDDLE_MCS_ATTENUATION_NSA}    DT_UL_TRUE_MIDDLE    DT_DL_TRUE_MIDDLE
	...                                          diag_log_true_middle_mcs
	Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    0
    ${qxdm_log}=    Save Throughput QXDM Logs    ${LOW_MCS_ATTENUATION_NSA}    DT_UL_TRUE_LOW    DT_DL_TRUE_LOW
    ...                                          diag_log_true_low_mcs
    ${dt_ul_true_low}=   Get Average Throughput from QXDM log    ${qxdm_log}
	Check Antenna Ports Value    ${qxdm_log}    2
    taf.ue.Detach UE    UE_1
    Compare Throughputs     ${dt_ul_false_high}    ${dt_ul_true_high}    ${1}    ${0.02}
    Compare Throughputs     ${dt_ul_false_low}    ${dt_ul_true_low}    ${1}    ${0.5}
    Verify Aperiodic CSI In Snapshot    should_be_zero=${False}


Set Initial Scf Parameters
    [Arguments]    ${subfeature}
    ${params}=    Get SCF Params    ${subfeature}  ${IS_IT_NEWER_BRANCH}  ${DLPTRS_NOT_SUPPORTED}
    ${gnb_id}=    Set Variable    ${tl.gnbs[0].global_bts_id}
    taf_admin.Setup_Admin    bts_host=${gNB_IP}    alias=admin_gnb
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-${CELL_ALIAS[-1]}
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=admin_gnb
    [Teardown]  taf_admin.Teardown_Admin    connection=admin_gnb


Set actUlDataDmrsFdm To True
    [Arguments]    ${gNB_IP}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    ${gNB_ID}=${tl.gnbs[0].global_bts_id}   ${cell_id}=3
    ${params}=    change_ulDataDmrsFdm_true
    taf_admin.Setup_Admin    bts_host=${gNB_IP}    alias=admin_gnb
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id}
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=admin_gnb
    [Teardown]  taf_admin.Teardown_Admin    connection=admin_gnb


Set actUlDataDmrsFdm To False
    [Arguments]    ${gNB_IP}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    ${gNB_ID}=${tl.gnbs[0].global_bts_id}   ${cell_id}=3
    ${params}=    change_ulDataDmrsFdm_false
    taf_admin.Setup_Admin    bts_host=${gNB_IP}    alias=admin_gnb
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id}
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=admin_gnb
    [Teardown]  taf_admin.Teardown_Admin    connection=admin_gnb


Save Throughput QXDM Logs
    [Arguments]    ${attenuation}=0    ${dt_name_UL}=DT_UL    ${dt_name_DL}=DT_DL    ${filename}=throughput_qxdm_log
    Set Attenuation   ${CELL_ALIAS}   ${attenuation}db
    log to console  attenuation set: ${attenuation}dB
    taf.ue.Start Data Transfer    dt_name=${dt_name_UL}   ue_alias=UE_1    direction=ul    duration=70s
    ...                           throughput=520Mbits/sec   packet_size=1400  qci=1
    taf.ue.Start Data Transfer    dt_name=${dt_name_DL}   ue_alias=UE_1    direction=dl    duration=70s
    ...                           throughput=50Mbits/sec   packet_size=1400   qci=2
    Sleep    30s    Iperf warm up
    QXDM.Start Log Collecting
    Sleep     30s
    QXDM.Stop Log Collecting
    taf.ue.Stop Data Transfer    dt_name=${dt_name_UL}
    taf.ue.Stop Data Transfer    dt_name=${dt_name_DL}
    ${filenames}=    QXDM.Download Log    filepath=${LOG_PATH}/${filename}
    RETURN    ${filenames[0][0]}


Save Throughput QXDM Logs with Signal Attenuation
    [Arguments]    ${end_attenuation}=90    ${step}=1    ${interval}=1    ${dt_name_UL}=DT_UL    ${dt_name_DL}=DT_DL
    ...            ${filename}=throughput_qxdm_log
    Set Attenuation   ${CELL_ALIAS}   0db
    taf.ue.Start Data Transfer    dt_name=${dt_name_UL}   ue_alias=UE_1    direction=ul    duration=70s
    ...                           throughput=520Mbits/sec   packet_size=1400  qci=1
    taf.ue.Start Data Transfer    dt_name=${dt_name_DL}   ue_alias=UE_1    direction=dl    duration=70s
    ...                           throughput=50Mbits/sec   packet_size=1400   qci=2
    Sleep    30s    Iperf warm up
    QXDM.Start Log Collecting
    Attenuate To Bad Radio Condition    ${end_attenuation}    ${step}    ${interval}
    Sleep     10s
    QXDM.Stop Log Collecting
    taf.ue.Stop Data Transfer    dt_name=${dt_name_UL}
    taf.ue.Stop Data Transfer    dt_name=${dt_name_DL}
    ${filenames}=    QXDM.Download Log    filepath=${LOG_PATH}/${filename}
    RETURN    ${filenames[0][0]}


Save Throughput QXDM Logs with Signal Amplification
    [Arguments]    ${end_attenuation}=0    ${step}=1    ${interval}=1    ${dt_name_UL}=DT_UL    ${dt_name_DL}=DT_DL
    ...            ${filename}=throughput_qxdm_log
    Set Attenuation   ${CELL_ALIAS}   0db
    taf.ue.Start Data Transfer    dt_name=${dt_name_UL}   ue_alias=UE_1    direction=ul    duration=70s
    ...                           throughput=520Mbits/sec   packet_size=1400  qci=1
    taf.ue.Start Data Transfer    dt_name=${dt_name_DL}   ue_alias=UE_1    direction=dl    duration=70s
    ...                           throughput=50Mbits/sec   packet_size=1400   qci=2
    Sleep    30s    Iperf warm up
    QXDM.Start Log Collecting
    Strengthen Signal To Good Radio Condition    ${end_attenuation}    ${step}    ${interval}
    Sleep     10s
    QXDM.Stop Log Collecting
    taf.ue.Stop Data Transfer    dt_name=${dt_name_UL}
    taf.ue.Stop Data Transfer    dt_name=${dt_name_DL}
    ${filenames}=    QXDM.Download Log    filepath=${LOG_PATH}/${filename}
    RETURN    ${filenames[0][0]}


Attenuate To Bad Radio Condition
    [Arguments]    ${end_attenuation}=90    ${step}=1   ${interval}=1
    FOR    ${attenuation}  IN RANGE  0  ${end_attenuation}  ${step}
        Set Attenuation  ${CELL_ALIAS}  ${attenuation}db
        Sleep  ${interval}s
    END
    Set Attenuation   ${CELL_ALIAS}   ${end_attenuation}db


Strengthen Signal To Good Radio Condition
    [Arguments]    ${end_attenuation}=0    ${step}=1    ${interval}=1
    ${init_atten}=   Read Attenuation    ${CELL_ALIAS}
    ${end_loop_val}=   Evaluate   int(${init_atten} - ${end_attenuation})
    FOR    ${i}  IN RANGE   0   ${end_loop_val}   ${step}
       ${attenuation}=   Evaluate   int(${init_atten} - ${i})
       Set Attenuation   ${CELL_ALIAS}   ${attenuation}db
       Sleep   ${interval}s
    END
    Set Attenuation   ${CELL_ALIAS}   ${end_attenuation}db


Check Antenna Ports Value
    [Arguments]    ${log_path}    ${value}    ${match_all}=${True}
    get_antenna_ports_value    rrc_file=${log_path}    expected_value=${value}    match_all=${match_all}


Strengthen Signal and get RRC logs
    Start Ue logging     filename=diag_log_true_transformprecoder_disabled
    ...                  username=rafal.kaczmarski@nokia.com    password=    duration=${60}    ue_id=${1}
    Strengthen Signal To Good Radio Condition   0   4   1
    Stop Ue logging    ue_id=${1}


Change to NSA
    Sleep  20s  reason=wait after previous test's teardown
    Run Keyword And Ignore Error  Disconnect Additional Pdn  UE_1  5gsawro
    Change Network Mode     UE_1        NR_LTE
    Connect additional pdn  UE_1        5gwro1
    Set Global Variable     ${UE_MODE}  NSA


Change to SA
    Sleep  20s  reason=wait after previous test's teardown
    Run Keyword And Ignore Error  Disconnect Additional Pdn  UE_1  5gwro1
    Change Network Mode     UE_1        NR_only
    Connect Additional Pdn  UE_1        5gsawro
    Set Global Variable     ${UE_MODE}  SA


Get Average Throughput from QXDM log
    [Arguments]    ${qxdm_log}
    ${message_names}=    Create List    QTrace Messages
    ${param_names}=      Create List    avgphy
    ${data}=  Analyze QXDM Log    ${qxdm_log}   ${message_names}   ${param_names}
    Log   ${data}
    Log to Console    ${data['QTRACE_UL_NR_throughput']['avgphy']['avg']} Kbps
    RETURN   ${data['QTRACE_UL_NR_throughput']['avgphy']['avg']}


Change Feature Activation And Reset UE State
    [Arguments]    ${action}
    taf.ue.Detach UE    UE_1
	IF    '${action}'=='enable'    Set actUlDataDmrsFdm To True    ELSE    Set actUlDataDmrsFdm To False
    Set Initial Attenuation
    Attach
