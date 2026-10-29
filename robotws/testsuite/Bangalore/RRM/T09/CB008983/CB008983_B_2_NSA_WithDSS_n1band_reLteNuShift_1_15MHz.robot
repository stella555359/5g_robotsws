*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author:            noble.iyeswariyam_edison@nokia.com
...             maintainer:        noble.iyeswariyam_edison@nokia.com
...
...             INTRODUCTION:      CB008983 RRM support for NR 1Tx DL 2Rx UL operation on Flexi FDD RFM
...             TEST SET NAME:     CB008983_B_2_NSA_WithDSS_15MHz
...                                This user scenario describes concurrent LTE and NR traffic within the LTE-NR DSS cell with reLteNuShift = 4
...             TESTING SPLIT:     See CB008983 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008983 CFAM
...             Requirement ID:    5G_RAN_USR_RRM_16674

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB008983_Resource.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Library          ../../../resources/python/avg_dl_data.py
#Library          BuiltIn.Log

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Test Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#Suite Teardown     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#Test Setup       Start_capture_testcase_default_logging
#...                 AND    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND      Check resource hanging
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/ET_CB008983-B_DSS_NSA_N1_15MHz_UL_1Layer.lua
${WTS_DIR}          /opt/iphy/latest
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}             11
${nwslice_ID}        1
${gw_ID}             1
${Pdu_session_ID}    1
${QFI_ID}            1
${TRF_ID}            1
${eNB_ID}            1
${eNB_target}        2
${cell_ID}           1
${st_ue_id}          1
${en_ue_id}          1
${numofLayer}        RANK1
${numprb}            79
${pdu_id}            1

${file_path}         ${WTS_DIR}/egate_console.log
#${file_path}        /opt/iphy/latest/egate_output.log
#${mimolayer}         2
${mimolayer}         4
${ss_pbch_power}     10
${overhead}          xOh6
${no_of_ports}       1
${cdm_type}          fd-CDM2
${density}           one
${v-Shift}           n1

${QFI_ID1}     1

${SCF_Path}    SCF_DU_Setup.xml
${SCFC}=    ${CURDIR}/config/SCF/CB008983_B_2_NSA_WithDSS_reLteNuShift_1_15MHz_scf.xml
${AP_XML}=    ${CURDIR}/config/SCF/CB008983_B_2_NSA_WithDSS_reLteNuShift_1_15MHz_iphy.xml

${NSA_Start_ue}=     12
${NSA_END_ue}=       15
${SA_UE_ID}=     1
${LOOP_COUNT}    4

${START_UE}    12
${END_UE}    15

${DL_RATE}       10
${UL_RATE}       8
${TRAFFIC_RATE}   mbps
${bearer_id}       2
${id}       2

*** Test Cases ***
[1]CB008983_B_2_NSA_WithDSS_reLteNuShift_1_15MHz
    [Tags]    QC_331947      QCD_MN_RAN    QCP_RAN_ET
    set test variable      ${LOG_PATH}
#    wtsrunner.sim_log_set    file=egate_output.log
    Configure DSS and cell seutp
    Sleep    3s
    Attach UE and start data
    Verify egate and TTI trace
    Register And Transfer Data Multiple Times     ${SA_UE_ID}     ${TRF_ID}     ${QFI_ID}    ${eNB_ID}
    ...    ${cell_ID}     ${NSA_Start_ue}    ${NSA_END_ue}
    Run keyword and ignore error    Validate DL Traffic For NSA   ue_id=${UE_ID}      dl_rate=10
    Run keyword and ignore error    Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=8
    Stop data and Detatch UE

*** Keywords ***
Configure DSS and cell seutp
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=dss_config
    Start CPRT Trace Capturing
    Enable Phase3 DSS   prb_list=${PRB_LIST_15M}    ALLOC_SUBFRAME=${ALLOC_SUBFRAME}   num_prb=${numprb}
	...    min_dss_ratio=75    max_dss_ratio=100    min_prb_ratio=30    max_prb_ratio=70
	Stop Collecting Syslog       NAME=dss_config
	Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_dss_config.pcap

Register And Transfer Data Multiple Times
    [Arguments]    ${SA_UE_ID}    ${TRF_ID}    ${QFI_ID}
    ...    ${eNB_ID}    ${cell_ID}    ${NSA_Start_ue}    ${NSA_END_ue}

    ${loop_end}=        Evaluate    ${LOOP_COUNT} + 1
    ${nsa_loop_end}=    Evaluate    ${NSA_END_ue} + 1

    FOR    ${index}    IN RANGE    1    ${loop_end}
        Log To Console    \n==== [ SA/NSA Test Loop Iteration: ${index} of ${LOOP_COUNT} ] ====
        BuiltIn.Log       ==== [ SA/NSA Test Loop Iteration: ${index} of ${LOOP_COUNT} ] ====    INFO

        # --- SA UE Registration and Data ---
        Run Keyword and Ignore Error    Start Collecting Syslog    NAME=ue_attach
        UE Register should be Successful    ue_id=${SA_UE_ID}
        Sleep    5s

        Trigger DL Data Traffic for SA    ue_id=${SA_UE_ID}    Traffic_rate=mbps    dl_rate=10    trf_id=${TRF_ID}
        Trigger UL Data Traffic for SA    ue_id=${SA_UE_ID}    Traffic_rate=mbps    ul_rate=8    trf_id=${TRF_ID}

        Stop Collecting Syslog    NAME=ue_attach
        Sleep    30s

        Run Keyword and Ignore Error    Validate DL Traffic For SA    ue_id=${SA_UE_ID}    dl_rate=8    qfi_id=${QFI_ID}
        Run Keyword and Ignore Error    Validate UL Traffic For SA    ue_id=${SA_UE_ID}    ul_rate=7    qfi_id=${QFI_ID}

        wtsrunner.uec_stats    type=cell_data_pdcp    enb=${eNB_ID}    cell=${cell_ID}    format=short
        Sleep    30s
        # --- NSA UEs Attach and Validation ---
        Log To Console    NSA UE Attach and Validation - Iteration ${index}
        BuiltIn.Log       NSA UE Attach and Validation - Iteration ${index}    INFO

        FOR    ${UE}    IN RANGE    ${NSA_Start_ue}    ${nsa_loop_end}
            WTS_Runner_Keywords.LTE Attach should be Successful    NSA_UE_ID=${UE}
            WTS_Runner_Keywords.UE Attach Should Be Successful    NSA_UE_ID=${UE}
            Sleep    2s
        END
        Sleep    30s
        Trigger DL Traffic For Multiple NSA UEs      ${NSA_Start_ue}    ${NSA_END_ue}    ${traffic_rate}
        ...    ${DL_RATE}      ${TRF_ID}
        Trigger UL Traffic For Multiple NSA UEs     ${NSA_Start_ue}   ${NSA_END_ue}    ${traffic_rate}
        ...    ${UL_RATE}      ${TRF_ID}
        Sleep    20s
        Validate DL Traffic For MultiUE for NSA    ${NSA_Start_ue}    ${NSA_END_ue}    10    2
        Validate UL Traffic For MultiUE for NSA    ${NSA_Start_ue}    ${NSA_END_ue}    8    2
        Sleep    10s
        # --- Final SA Validation Again ---
        Run Keyword and Ignore Error    Validate DL Traffic For SA    ue_id=${SA_UE_ID}    dl_rate=8    qfi_id=${QFI_ID}
        Run Keyword and Ignore Error    Validate UL Traffic For SA    ue_id=${SA_UE_ID}    ul_rate=7    qfi_id=${QFI_ID}

        UE Detach should be Successful for Multiple UEs     12     15
        UE Deregister should be Successful      ${SA_UE_ID}

        Log To Console    ==== [ Completed Iteration: ${index} ] ====
        BuiltIn.Log       ==== [ Completed Iteration: ${index} ] ====    INFO

    END

UE Detach should be Successful for Multiple UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}

    ${loop_end}=    Evaluate    ${end_ue_id} + 1
    FOR    ${UE_ID}    IN RANGE    ${start_ue_id}    ${loop_end}
        Log To Console    \nDetaching UE: ${UE_ID}
        UE Detach should be Successful    ${UE_ID}
        Sleep    2s    reason=wait for detach to complete
    END

Trigger DL and UL Traffic for NSA Multiple UEs
    [Documentation]    This keyword starts both DL and UL traffic for multiple UEs in NSA mode
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${traffic_rate}    ${dl_rate}    ${ul_rate}
    ...            ${bearer_id}=${bearer_id}     ${trf_id}=${TRF_ID}

    ${end_plus_one}=    Evaluate    ${end_ue_id} + 1
    FOR    ${ue}    IN RANGE    ${start_ue_id}    ${end_plus_one}
        Log To Console    \nTriggering DL and UL Traffic for UE ${ue}

        Trigger DL Traffic for NSA
        ...    ${ue}    ${traffic_rate}    ${dl_rate}
        ...    ${id}=${bearer_id}    ${trf_id}=${trf_id}

        Trigger UL Traffic for NSA
        ...    ${ue}    ${traffic_rate}    ${ul_rate}
        ...    ${id}=${bearer_id}    ${trf_id}=${trf_id}
    END

Trigger DL Traffic For Multiple NSA UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${traffic_rate}   ${dl_rate}    ${trf_id}


    ${loop_end}=    Evaluate    ${end_ue_id} + 1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${loop_end}
        Trigger DL Traffic for NSA
        ...    ${ue_id}    ${traffic_rate}    ${dl_rate}
        ...    id=${bearer_id}    trf_id=${trf_id}
    END

Trigger UL Traffic For Multiple NSA UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${traffic_rate}    ${ul_rate}    ${trf_id}

    ${loop_end}=    Evaluate    ${end_ue_id} + 1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${loop_end}
        Trigger UL Traffic for NSA
        ...    ${ue_id}    ${traffic_rate}    ${ul_rate}
        ...    id=${bearer_id}    trf_id=${trf_id}
    END


Validate DL Traffic For MultiUE for NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${NSA_Start_ue}   ${NSA_END_ue}     ${dl_rate}    ${id}
    FOR     ${ue_idx}   IN RANGE    ${NSA_Start_ue}    ${NSA_END_ue}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   id=${id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
    END

Validate UL Traffic For MultiUE for NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${NSA_Start_ue}   ${NSA_END_ue}       ${ul_rate}     ${id}
    FOR     ${ue_idx}   IN RANGE    ${NSA_Start_ue}    ${NSA_END_ue}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   id=${id}      dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END


Attach UE and start data
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_attach
    Start CPRT Trace Capturing
    LTE Attach should be Successful    NSA_UE_ID=${UE_ID}
    UE Attach should be Successful   NSA_UE_ID=${UE_ID}
    Sleep    5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=10       trf_id=${TRF_ID}
    Trigger UL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=8       trf_id=${TRF_ID}
    Stop Collecting Syslog       NAME=ue_attach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_attach.pcap
    Sleep    20s
    ${output2}    OperatingSystem.Get File    ${file_path}
    Run keyword and ignore error    Validate DL Traffic For NSA   ue_id=${UE_ID}      dl_rate=10
    Run keyword and ignore error    Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=8
    Verify 1TX config from egate_log     1    ${st_ue_id}    ${en_ue_id}    0
    wtsrunner.uec_stats     type=cell_data_pdcp    enb=${eNB_ID}     cell=${cell_ID}    format=short


Stop data and Deregister UE
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_detach
    Start CPRT Trace Capturing
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    Stop Collecting Syslog       NAME=ue_detach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_detach.pcap

Stop data and Detatch UE
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_detach
    Start CPRT Trace Capturing
    Stop Data Traffic for NSA    ue_id=${UE_ID}
    UE Detach should be Successful
    Stop Collecting Syslog       NAME=ue_detach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_detach.pcap

Verify egate and TTI trace
    Verify 1TX config from egate_log     1    ${st_ue_id}    ${en_ue_id}    0
    sleep  10s       reason=Wait for traffic to start
    Start L2 BIP Trace Capturing
    sleep  3s       reason=Wait to collect logs
    Stop L1L2 capture  ${CaptureL1L2}
#    Move File    ${LOG_PATH}/L1L2_GNB_FS_BO.pcap    ${LOG_PATH}/L1L2_GNB_FS_BO_ULDL_Data_UE.pcap
    ${crnti_list}     Create List
    ${numofLayer}    Create List     RANK1
    Log To Console    \nStartingTTICapture
    Capture TTI Traces and Validate numofLayers    ${LOG_PATH}    initial    ${crnti_list}     ${numofLayer}
    Log To Console    \nDoneTTICapture


#Change IPHY File Value
#    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "card"|tail -n 4|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
#    Run    ${c1}${c2}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}



Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
