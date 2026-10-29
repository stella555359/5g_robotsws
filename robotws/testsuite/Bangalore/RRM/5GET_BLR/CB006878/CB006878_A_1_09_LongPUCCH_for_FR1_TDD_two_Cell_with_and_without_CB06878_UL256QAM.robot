*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Documentation
...             :copyright:        Nokia
...             author:            nagesh.k_v@nokia.com
...             maintainer:        nagesh.k_v@nokia.com
...
...             INTRODUCTION:     With CB006878, based on actual cell load (number of RCUs),
...                               the scheduler decides to allocate currently unused F3 resources for PUSCH transmissions in the cell.
...             TEST SET NAME:  CB006878_A_1_09_LongPUCCH_for_FR1_TDD_two_Cell_with_and_without_CB06878_UL256QAM
...                             This Test case is to verify the data Transfer rate with Max in UL with 256QAM and CB006878 feature Disable and enabled
...
...             TESTING SPLIT:    See CB006878 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB006878 CFAM
...             Requirement ID:
...             Ref TC:

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ./resources/CB006878_Resource.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
#...                 AND     Find Scfc And Fix And Send Full Commissioning
#...                           scfc_filename=scf_CB006878_256qam_fullcommissioning.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


#Test Setup       Start_capture_testcase_default_logging
#Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/256qam_config.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_256qam.xml
${sa_ue_id}      1
${sa_trf_id}    1
${TRF_ID}       1
${TRF_ID_1}       1
${TRF_ID_2}       2
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TEST_NAME}     256qam
${delta_file_name}   CB006878_Disable.json


*** Test Cases ***
[1]CB006878_A#1_09_LongPUCCH_for_FR1_TDD_two_Cell_with_and_without_CB06878_UL256QAM

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Link SCOUT SCF to Configuration ID for Reporting
    Perform SCF Delta Commissioning with ${delta_file_name}
	Trigger multiple UEs with the 256qam capable with CB006878 disabled
	Trigger multiple UEs with the 256qam capable with CB006878 enabled



*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Validate Max DL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Maximum data rate must be within 99% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Maximum Rate      ${bearer_stat_dl}    DL    ${dl_rate}

Check Maximum Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Maximum data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.06) > int(${output[0]}) > (${mbps} * 1000000 * 0.98)
    Run Keyword if    ${result}    Log to Console    ${dir} Maximum data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Maximum data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Maximum data rate failed!

Validate Max UL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Maximum data rate must be within 99% and 110% of expected rate
    ...                2. UL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Maximum Rate      ${bearer_stat_ul}    UL    ${ul_rate}

Trigger multiple UEs with the 256qam capable with CB006878 enabled
#    Perform SCF Delta Commissioning with CB006878_Enable.json
#	sleep	 50s
#    Start CPRT Trace Capturing
	#Step 1. Attach Single SA UE and start low DL data and Max UL data
    ${crnti_list}=      MultiUE Register should be Successful    2  2
#    Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC_6878.pcap
    MultiUE Trigger DL Traffic for SA    2  2    Traffic_rate=mbps     dl_rate=20          trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    2  2    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_1}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    2  2    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_2}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger DL Traffic for SA    3  4    Traffic_rate=mbps     dl_rate=20         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger UL Traffic for SA    3  4    Traffic_rate=mbps     ul_rate=142         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    sleep    30s
#    Validate DL Traffic For MultiUE for SA    1  2     dl_rate=20         qfi_id=${sa_qfi_id}
    Validate UL Traffic For SA    2     ul_rate=210         qfi_id=${sa_qfi_id}
#	Validate DL Traffic For MultiUE for SA    3  4     dl_rate=20         qfi_id=${sa_qfi_id}
#    Validate UL Traffic For MultiUE for SA    3  4     ul_rate=142         qfi_id=${sa_qfi_id}
#    Start L2 BIP Trace Capturing
#    sleep      2s
#    Stop L1L2 capture    ${CaptureL1L2}
    Stop MultiUE Data Traffic for SA     2  2
#    ${result_enable}    int(${output[0]})
    MultiUE Deregister should be Successful   2  2
#    Log to Console  ${CaptureL1L2}
#    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${LOG_PATH}/L1L2_GNB_FS_LO.pcap   ${13}    ${247}

Trigger multiple UEs with the 256qam capable with CB006878 disabled
#	Start CPRT Trace Capturing
	#Step 1. Attach Single SA UE and start low DL data and Max UL data
    ${crnti_list}=      MultiUE Register should be Successful    1  1
#    Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC1.pcap
    MultiUE Trigger DL Traffic for SA    1  1    Traffic_rate=mbps     dl_rate=20          trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_1}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_2}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger DL Traffic for SA    3  4    Traffic_rate=mbps     dl_rate=20         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger UL Traffic for SA    3  4    Traffic_rate=mbps     ul_rate=142         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    sleep      30s
#    Validate UL Traffic For SA    1  1     dl_rate=20         qfi_id=${sa_qfi_id}
    Validate UL Traffic For SA    1     ul_rate=200         qfi_id=${sa_qfi_id}
#	Validate DL Traffic For MultiUE for SA    3  4     dl_rate=20         qfi_id=${sa_qfi_id}
#    Validate UL Traffic For MultiUE for SA    3  4     ul_rate=142         qfi_id=${sa_qfi_id}
#    Start L2 BIP Trace Capturing
#    sleep      2s
#    Stop L1L2 capture    ${CaptureL1L2}
#    ${result_disable}      String . Get Regexp Matches ${bearer_stat}, Average data rate +(\\d+), 1
#    result Disable
#    Log to Console    ${output}
    Stop MultiUE Data Traffic for SA     1  1
    MultiUE Deregister should be Successful   1  1
#    Log to Console  ${CaptureL1L2}
#    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq without 6878     ${LOG_PATH}/L1L2_GNB_FS_LO.pcap   ${10}    ${253}
#    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/L1L2_GNB_FS_LO_without_6878.pcap


result Disable
    ${output} = String . Get Regexp Matches ${bearer_stat}, Average data rate +(\\d+), 1
Evaluate the results
    ${result} = BuiltIn . Evaluate  (int(${result_enable}) > int(${result_disable}))
