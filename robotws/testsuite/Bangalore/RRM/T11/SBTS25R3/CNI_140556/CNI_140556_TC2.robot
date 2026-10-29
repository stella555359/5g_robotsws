*** Settings ***

Variables        ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../resources/robot/TTI_Traces.robot
Library          ../../../../resources/python/CPRT_Capture.py
Resource         ../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Resource         ../../../../resources/robot/Airphone.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Resource         ../../../../resources/robot/common_log_collection.robot
Resource         ../../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../../resources/robot/BBpooling_MuMIMO.robot
Library          ../../../../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String

Library          ./tti_parser_dl_muting.py

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Update bsr package
##...                 AND     Start Log   btslog
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   60s

Suite Teardown      Run keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Stop Log   btslog    snapshot    sosreport

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This User Scenario verifies the correct DL symbols are muted in the gNB cell,
...                               which is configured with tdLTE without LTE to NR shift 8:2, interfering frame
...                               structure is semistatic 6:4 for SA call
...
...
...             TEST SET NAME:    CNI_140556
...             TESTING SPLIT:    Refer CNI_140556  Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI_140556 CFAM
...             Requirement ID:   12318599



*** Variables ***
${wts_cfg_file}     basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${nwslice_ID}   1

${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1


${TEST_NAME}     TC2
${CELL_ID}    1

${delta_filename}=      ${CURDIR}/config/delta_CNI_140556_enable.json
${delta_filename1}=      ${CURDIR}/config/delta_CNI_140556_disable.json

${bsr_dl_link}=         https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
${BSR_SW_FILE}=         BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
${tti_dir_name1}=       No_DL_muting
${tti_dir_name2}=       DL_muting
@{muted_slot}=     9   19

*** Test Cases ***
USCNI-140556#TC2_Verification_of_blanking_patterns_with_interference_and_with_Bilateral_agreement_SA
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   "SA UE attach"
##Step 1. Attach SA UE's with Feature Disable
    ${rnti_list}   MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id1}
    sleep     2s
    Log to console   ${rnti_list}
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger High DL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=750   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   300s
    Run Keyword and Continue on Failure    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=700
    Run Keyword and Continue on Failure    Validate UL Traffic For MultiUE for SA   ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=115
    Start Log    ttitrace
    sleep   2s
    ${tti_log_path_1}=     Stop Log    ttitrace      test_scenario=${tti_dir_name1}
    Decode TTI Trace    ${tti_dir_name1}
    ${muted_slot_count}=    Verify DL Muting in TTI Trace     ${tti_log_path_1}[ttitrace]/output_dl_formated.csv   ${muted_slot}
    Should Be True     ${muted_slot_count} >= 200
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
##Step 2. Attach SA UE's with Feature Enable
    ta5g_commissioning.Send Delta Commissioning    ${delta_filename}
    sleep   100s
    ${rnti_list}   MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id1}
    sleep     2s
    Log to console   ${rnti_list}
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger High DL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=750   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   300s
    Run Keyword and Continue on Failure    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=650
    Run Keyword and Continue on Failure    Validate UL Traffic For MultiUE for SA   ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=115
    Start Log    ttitrace
    sleep   2s
    ${tti_log_path_2}=     Stop Log    ttitrace      test_scenario=${tti_dir_name2}
    Decode TTI Trace    ${tti_dir_name2}
    ${muted_slot_count}=    Verify DL Muting in TTI Trace     ${tti_log_path_2}[ttitrace]/output_dl_formated.csv   ${muted_slot}
    Should be Equal as integers    ${muted_slot_count}     0
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    [Teardown]  Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...         AND   ta5g_commissioning.Send Delta Commissioning     ${delta_filename1}

*** Keywords ***
MultiUE Trigger High DL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    FOR   ${id}  IN RANGE   ${start_ue_id}    ${end_ue_id}+1
        Trigger High DL Traffic SA    ${id}    ${dl_rate}   ${pdu_id}   ${qfi_id}
    END


Trigger High DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
            Run Keyword if    ${loop}==0       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=${dl_rate_reminder}   ack_mode=off  cl_trf_stats=on
            Run Keyword if    ${loop}>0        wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=175   ack_mode=off  cl_trf_stats=on
            ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully


Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${bsr_dl_link}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    Run     sudo wget ${bsr_dl_link}/${BSR_SW_FILE} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

