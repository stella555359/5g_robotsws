*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED


Documentation
...     Feature:        CB010411
...     author:         prapulla.bt@nokia.com
...     maintainer:     prapulla.bt@nokia.com
...     INTRODUCTION:   CB010411
...     TEST SET NAME:  The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...     TESTING SPLIT:     See CB010411 testplan
...     CONTACTS:          I_MN_RAN_RD_VRF_BLR1_T09_GMS <I_MN_RAN_RD_VRF_BLR1_T09@internal.nsn.com>
...     REFERENCES:        CB010411 CFAM
...     Requirement ID:     5G_UP_ALG_1871;5G_UP_ALG_1878;5G_UP_ALG_1876;5G_UP_ALG_1874;5G_CP_IF_RRC_1822


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Library             ../resources/python/IphyUpdate.py
Library             ../CB010312/resources/verify_cs2_list.py
Resource           ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/Airphone.robot
Library          OperatingSystem


Suite Setup         Run keywords     Test Suite Setup
...                 AND              AIC Software Build Info
...                 AND              Fetch Taf Library used in TL
...                 AND              Log to console    vDU delta commissioning
...                 AND              Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND              Fast Delta Commission vCU Using Delta XML File      ${delta_vcu}

...                 AND              Update vDU TargetBDxml contents in AP_iphyxml    ${RMOD_name}    ${iphy_file_path}
...                 AND              Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                 AND              sleep     600s
...                 AND              Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                 AND              log to console   loading cfg file....
...                 AND              Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND              sleep    60s

Suite Teardown         Run keyword and continue on failure        Kill WTS processes Using WTS_Runner

*** Variables ***
${RMOD_name}       AEQP
${iphy_file_path}  ${CURDIR}/config/SBTS24R2/iphy_937_2cell.xml
${wts_cfg_file}    ${CURDIR}/config/wts/SANSA_2Cell_937.cfg
${vcu_file_path}   ${CURDIR}/config/SBTS24R2/Delta_937_CU_DC.xml
${vdu_file_path}   ${CURDIR}/config/SBTS24R2/Delta_937_DU_DC_2cell.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${SCFC}=                   Bangalore/RRM/ET/5GC000937/5GC000937_TC11_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/5GC000937/5GC000937_TC11_iphy.xml
${delta_vdu}     ${CURDIR}/config/SBTS24R2/Delta_937_DU_DC_2cell.xml
${delta_vcu}     ${CURDIR}/config/SBTS24R2/Delta_937_CU_DC.xml
${PM_dir1}
${PM_dir2}
${counter_value_cell1}


*** Test Cases ***
[1]5GC000937_TC_12_Counters_verify_multiUE_Switch_to_PS_BWP_on_low_DLUL_traffic_rate_and_switch_to_large_BWP_on_DL_traffic_increase
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console     ${LOG_PATH}
    ${TESTCASE_LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable     ${TESTCASE_LOG_PATH}
    ${CURRENT_SYSLOG_PATH}    Set Variable    ${TESTCASE_LOG_PATH}/Syslog_vDU
    set test variable       ${CURRENT_SYSLOG_PATH}
    Run Keyword And Continue on Failure   Start Syslog Monitoring
    Run Keyword And Continue on Failure   Start CPRT F1 Monitoring
    log to console    start data...
    ${crnti_list}=      MultiUE Register should be Successful    1  3
    sleep   10s
    Sync With Measurement Period    "vDU"
    MultiUE Trigger DL Traffic for SA    1  2    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1  2    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    3  3    Traffic_rate=mbps     dl_rate=2         trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    3  3    Traffic_rate=mbps     ul_rate=2         trf_id=${TRF_ID}
    sleep   10s
    Validate DL Traffic For MultiUE for SA    1  2     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    1  2     ul_rate=0.025
    Validate DL Traffic For MultiUE for SA    3  3     dl_rate=2
    Validate UL Traffic For MultiUE for SA    3  3     ul_rate=2

    sleep    1ms    reason=Wait for successful response from admin
    MultiUE Trigger UL Traffic for SA    1  2    Traffic_rate=mbps     ul_rate=2          trf_id=${TRF_ID2}
    wtsrunner.bearer_stats_clear     ue=${ue_id}    pdu=${Pdu_session_ID}
    sleep   20s      reason=Wait for successful BWP switch

	sleep   600s
    Log to Console    Verifying counters.....
	Run Keyword and continue on failure    Common_Keywords.Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    Run Keyword and continue on failure    Verify UL and DL ScheduledUes with counter_vDU    M55351C00001    M55351C00002
    ...    M55351C01001    M55351C01002    *MRBTS*

	Run Keyword And Continue on Failure   Stop and Collect CPRT F1 Monitoring
    Run Keyword And Continue on Failure   Stop and Collect Syslog Monitoring
	Validate UL Traffic For MultiUE for SA    1  2     ul_rate=2
    Validate DL Traffic For MultiUE for SA    1  2     dl_rate=0.025
    Validate DL Traffic For MultiUE for SA    3  3     dl_rate=2
    Validate UL Traffic For MultiUE for SA    3  3     ul_rate=2
    Stop MultiUE Data Traffic for SA     1  3
    MultiUE Deregister should be Successful   1  3

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1
Verify UL and DL ScheduledUes with counter_vDU
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}    ${PM_PCELL_COUNTER3}    ${PM_PCELL_COUNTER4}
    ...     ${pi_file_pattern}
	${path}   Set Variable    /home/ute/test_results/CB010411multiBWP937/${TEST_NAME}/gnb_pm_counters
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_1}==0
    Log to console     Counter is equal to 0
    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_2}==0
    ${actual_pm_values_3}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER3}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_3}==3
    Log to console     Counter is equal to 3
    ${actual_pm_values_4}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER4}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_4}==3
    Log to console     Counter is equal to 3


Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}
