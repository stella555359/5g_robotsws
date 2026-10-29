*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation
...  AUTHOR          :   noble.iyeswariyam_edison@nokia.com
...  MAINTAINER      :   noble.iyeswariyam_edison@nokia.com
...  INTRODUCTION    :   CB014153-SR RIM partial slot based DL muting
...  TEST SET NAME   :   CB014153_A_B01_RIMRS_based_DL_mitigation_for_3rd_DL_slot_before_special_slot
...  TESTING SPLIT   :   Split-A
...  CONTACTS        :   noble.iyeswariyam_edison@nokia.com
...  REFERENCES      :   CB014153-CFAM
...  REQUIREMENT ID  :   12571891


Resource       ./CB014153_resource.robot


*** Variables ***
${wts_cfg_file}        ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${epc_log_path}    /tmp/
${r&d_parameter}       0x58057f=262223;0x58057a=4
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-55,-55,-60,-60,-60,-65,-65,-65,-70,-70,-75,-75,-80,-80,-80,-85,-85,-95,-95,-95,
...                       -95,-95,-95,-95,-95,-115,-115,-115,-115,-115,-115
${TLConfig.isUTE}   True
${tl.core}      ${None}
${file_path}     'output_dl.csv'  # Replace with your CSV file path
${field1}     slot           # Replace with the first field name
${field2}     dlFdSchedData.SLIV            # Replace with the second field name
${field3}     rnti
${output_file}     filtered_output.csv
${tddframe}     1
${slotnum}      3
${LOG_PATH}     /home/ute/logs/Logs/20260127_093550352520.CB014153_3DL_muting/partialslot



*** Test Cases ***
[1][1.0] CB014153-A#B01_RIM RS based DL mitigation for 3rd DL slot before special slot

    [Tags]    TC01
	[Setup]    Run keywords    Suite setup from scratch
    ...                 AND    Perform SCF Delta Commissioning with Delta_config_CB014153_FR1.json
	...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
	...                 AND    gnb.Perform gNB reboot
	...                 AND    Sleep   700s    reason=wait for RMOD to comeup
	...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    1

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    sleep  10s  reason=Wait for RIParameterexecution
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    RIM RS1 RS2 Detection and Mitigation and Check Alarm
    sleep  10s  reason=stable data
    Stop log    snapshot  test_scenario=snap
	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     wts_sim_keywords.Clean edaemon and egate
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB014153-B#IWK02_Verify the activation of the RIM DL partial slot muting with CB014133 NR RIM fault replacement
    [Tags]    TC02
	[Setup]    Run keywords    Suite setup from scratch
    ...                 AND     Update bsr package_TMO_65
    ...                 AND    Perform SCF Delta Commissioning with Delta_RIM.json
	...                 AND    Check gNB Bulid
	...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    1

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    sleep  10s  reason=Wait for RIParameterexecution
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    Start And Stop Tti Trace Per Cell    path=${LOG_PATH}/default    pysical_cell_ids=51   duration=2s
    Perform SCF Delta Commissioning with Delta_config_CB014153_B.json
    Activate RI and RIM-RS
    Check Tput    ue_id=1   scell_idx=0    dl_data=400    ul_data=60
    Start And Stop Tti Trace Per Cell    path=${LOG_PATH}/partialslot/    pysical_cell_ids=51   duration=2s
    Perform SCF Delta Commissioning with Delta_config_CB014153_B_RimCmFmReport.json
    Start And Stop Tti Trace Per Cell    path=${LOG_PATH}/partialslot_cm/    pysical_cell_ids=51   duration=2s
    Validate Alarm and PM counter and traffic
	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     wts_sim_keywords.Clean edaemon and egate
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB014153_TMOUS_CVR_003_SetID_detection_by_confiurig_RIM-RS_detection_threshold

    [Tags]    TC03
	[Setup]    Run keywords    Suite setup from scratch
    ...                 AND    Perform SCF Delta Commissioning with Delta_config_CB014153_C_FR1.json
	...                 AND    Sleep    100s
	...                 AND    Perform SCF Delta Commissioning with FrameStructure_1116_3ms_4GP.json
	...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
	...                 AND    gnb.Perform gNB reboot
	...                 AND    Sleep   700s    reason=wait for RMOD to comeup
	...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    1

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    sleep  10s  reason=Wait for RIParameterexecution
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    Start Log    btslog
    Perform SCF Delta Commissioning with HigherThreshold.json
    RIM RS1 RS2 Detection and Mitigation with Higher Rimrsthreshold and Check Alarm
    Verify The Counter for Special and 1 DL Slots with Higher Rimrsthreshold
    Perform SCF Delta Commissioning with LowerThreshold_C.json
    sleep   100s
    Log to Console    Counter Validation
    Verify The Counter for Special and 3 DL Slots with with Lower Rimrsthreshold
    Deactivate RI and RS1
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog
    sleep    5s
    sleep  10s  reason=stable data
    Stop log    snapshot  test_scenario=snap
	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     wts_sim_keywords.Clean edaemon and egate
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

