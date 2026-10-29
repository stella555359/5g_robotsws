*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LO     VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD
...             RAN_5G_TDD    SBTS00    CONFIGURED   CRT   TOOLS_PROFILE_TTI_LEGACY

Documentation    :copyright: Nokia
...              :authors: Kshitij Tyagi
...              :contact: kshitij.tyagi@nokia.com
...         This user scenario describes the common gNB behavior at activation of the CB006878 feature when 5GC000937
...         is active and it verifies
...         the behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL traffic
...         rate and switch to large BWP on DL traffic increase.CB007113 sub-B already supports the unused PUCCH L1 PRB
...         Library allocated from BBRM can be used by PUSCH. CB007113 sub-J needs align with CB006878 which support
...         Library pCSI physical PRBs in frequency domain are available for PUSCH.
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16150

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         resources/load_based_validation_keywords.resource
Library          ./resources/check_cell_expected_prballocation.py

Suite Setup         Run keywords     Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
...                 AND     Prepare TL with all config files
...                 AND    Start WTS Using WTS_Runner           ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Setup.Get Sos Report

Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/configs/basic_setup_ASOE_4cell_gscn_ue1-4.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
###
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
${scf_file}      /home/ute/Downloads/.*xml*
${QFI_ID}    1
${TRF_ID2}    2
${TRF_ID}    1
${PM_dir1}
${PM_dir2}
${Low_data_counter_value_cell1}
${Low_data_counter_value_cell4}
${High_data_counter_value_cell1}
${High_data_counter_value_cell4}
@{PhysCellID}      50    51    52    53
${r&d_parameter}     0x420068=7;0x58069C=1;0x580612=1;0x580686=0xa;0x58057c = 0x2800;0x58057a = 0x4
${SCFC}=               ${CURDIR}/config/ASOE_SCF.xml
${AP_XML}=             ${CURDIR}/config/ASOE_IPHY.xml

*** Test Cases ***
[1]CB007113_J1_2_Verify_IWK_CB006878_with_mutipleBWP_LongPUCCH_configured_FR1_TDD
    [Documentation]   verifies the behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL
     ...    traffic rate and switch to large BWP on UL traffic increase in 4 cells.

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Log     btslog
    ${crnti_list}=      MultiUE Register should be Successful    1  4
    Set test variable     ${crnti_list}     ${crnti_list}
    Stop Log    btslog          test_scenario=ueattach_TC2
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=mbps     ul_rate=145          trf_id=${TRF_ID}
    Start low UL data in all cells
    Run Keyword And Continue On Failure     Capture TTI traces and validate BWPID for low data
    Wait Until Keyword Succeeds    60s    5sec    Collect 6878 counter for low data and verify
    Start high UL data in all cells
    Run Keyword And Continue On Failure     Capture TTI traces and validate BWPID for high data
    Collect 6878 counter for high data and verify
    Wait Until Keyword Succeeds    12 min    3 min     PRB Validation
    Stop MultiUE Data Traffic for SA     1  4
    MultiUE Deregister should be Successful   1  4

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Start low UL data in all cells
    Start Log       btslog
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    sleep   10s    reason=Wait for successful BWP switch
    Stop Log        btslog      test_scenario=ue_lowdata_TC2


Capture TTI traces and validate BWPID for low data
    ${bwpid}    Create List     2     2    2    2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata
    ...     ${crnti_list}     ${bwpid}    ${Branch_22R1}

Start high UL data in all cells
	Start Log        btslog
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=mbps     ul_rate=145          trf_id=${TRF_ID}
    Run Keyword And Continue On Failure    wtsrunner.bearer_stats_clear     ue=${ue_id}    pdu=${Pdu_session_ID}
    sleep   10s      reason=Wait for successful BWP switch
    Stop Log        btslog      test_scenario=ue_highdata_TC2

Capture TTI traces and validate BWPID for high data
    ${bwpid}    Create List     1     1    1    1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata
    ...     ${crnti_list}     ${bwpid}    ${Branch_22R1}

Collect 6878 counter for low data and verify
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Low_data_counter_value_cell1}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-1
    ${Low_data_counter_value_cell4}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-4
    Should be true      ${Low_data_counter_value_cell1} > ${Low_data_counter_value_cell4}

Collect 6878 counter for high data and verify
    Wait until the next Measurement Period starts
    ${PM_dir2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${High_data_counter_value_cell1}=    Get PM counter value    ${PM_dir2}    pi_id=M55308C10002    moc=NRCELL-1
    ${High_data_counter_value_cell4}=    Get PM counter value    ${PM_dir2}    pi_id=M55308C10002    moc=NRCELL-4
    Should be true      ${High_data_counter_value_cell1} > ${High_data_counter_value_cell4}


Collect TTI Traces
    [Arguments]    ${dir_name}     ${sleep_time}
    Start Log      ttitrace
	Sleep    ${sleep_time}s
    ${tti_log_path}    Stop Log      ttitrace   test_scenario=${dir_name}
    log to console   ${dir_name}
    log to console   ${tti_log_path}
	Decode TTI Trace    ${dir_name}
	[Return]    ${tti_log_path}

Verify expected PRB allocation
    FOR     ${cellid}    IN    @{PhysCellID}
        ${UL_Check}    Verify Expected PRB Allocation in UL    ${TTI_log_dir}[ttitrace]      ${cellid}    46    273    204
        ${DL_Check}    Verify Expected PRB Allocation in DL    ${TTI_log_dir}[ttitrace]      ${cellid}    48    273    273
    END

Verify Expected PRB Allocation in UL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in ul...
    ${Result}   check_cell_expected_prballocation.check_ulexpectedprb      ${csv_file_path}/output_ul_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}

Verify Expected PRB Allocation in DL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in dl...
    ${Result}   check_cell_expected_prballocation.check_dlexpectedprb      ${csv_file_path}/output_dl_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}
Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
PRB Validation
    ${TTI_log_dir}     Collect TTI Traces      dir_name=cell_idle     sleep_time=2
    set test variable    ${TTI_log_dir}
    Verify expected PRB allocation
