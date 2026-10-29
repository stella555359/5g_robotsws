*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    pip install taf.collectors.l2stream3==1.1.2
...    pip install taf.converters.eventdecoder
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1462 -L trace check_gnb_state.robot
Resource         ./../common_setup_teardown.robot
Library      ./../scripts/python/format_ttitrace_table.py

*** Variables ***
${UE_ID}                1    #11 for NSA
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${ASP_BOARD_TYPE}    ABIO
*** Test Cases ***

Prepare Testline
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
    Set Suite Variable    ${UE_ID}    ${UE_ID}

Make Onair
    Run Keyword If    '${GNBCUTYPE}'=='SA' or '${GNBCUTYPE}'=='SANSA'    Hard Reboot Testline
    Verify Coam Site Is Ready
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Verify Cell Setup

Test 5G UE Attach
    5G UE Attach

Test 5G UE Start Traffic
    5G UE Start Traffic

Test TTitrace With Streaming Mode
    Start Ttitrace With Streaming Mode
    Sleep    1s    wait to catch ttitrace...
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
    Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv    ${OUTPUT_DIR}/ttitrace_streaming/output_dl_combine.csv
    Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv    ${OUTPUT_DIR}/ttitrace_streaming/output_ul_combine.csv

Test Ttitrace With Snapshot Mode Catch Continously
    Catch Ttitrace Log    1s
    Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/ttittrace_snapshot_c/
    Format Tti In Snapshot Mode    ${OUTPUT_DIR}/ttittrace_snapshot_c/full_dl.csv    ${OUTPUT_DIR}/ttittrace_snapshot_c/output_dl_combine.csv
    Format Tti In Snapshot Mode    ${OUTPUT_DIR}/ttittrace_snapshot_c/full_ul.csv    ${OUTPUT_DIR}/ttittrace_snapshot_c/output_ul_combine.csv
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/ttittrace_snapshot_c/full_dl.csv    ${OUTPUT_DIR}/ttittrace_snapshot_c/format/
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/ttittrace_snapshot_c/full_ul.csv    ${OUTPUT_DIR}/ttittrace_snapshot_c/format/

Test Ttitrace With Snapshot Mode Keyword Dividely
    Start GNB TTI Trace
    Sleep    1s    wait to catch ttitrace...
    Stop GNB TTI Trace
    Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/ttittrace_snapshot_d/
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/ttittrace_snapshot_d/full_dl.csv    ${OUTPUT_DIR}/ttittrace_snapshot_d/format/
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/ttittrace_snapshot_d/full_ul.csv    ${OUTPUT_DIR}/ttittrace_snapshot_d/format/

Test Parser Ttitrace
    ${numOf5qi1Prb_list}=    Ttitrace Filter Source Column Return Self Column    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb     ["0", "", "0.0"]    except    yes
    ${rnti_list}=    Ttitrace Filter Source Column Return Other Column    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb     ["0", "", "0.0"]    except    rnti    yes
    ${sfn_list}=    Ttitrace Filter Source Column Return Other Column    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb     ["0", "", "0.0"]    except    sfn    no
    ${interval}=    Ttitrace Count Interval    ${sfn_list}    no

Test 5G UE Detach
    5G UE Detach

*** Keywords ***
Suite Setup Update GNB
    Clean Up Env
    Create Suite Directory
    Get All Testline Information And Set Suite Variable
    Print Testline Info Ahead Of Report

5G UE Attach
    Run Keyword If    '${GNBCUTYPE}'=='SA'    Ue Attach SA
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Ue Attach NSA

5G UE Start Traffic
    Run Keyword If    '${GNBCUTYPE}'=='SA'    Start Traffic SA
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Start Traffic NSA

5G UE Detach
    Run Keyword If    '${GNBCUTYPE}'=='SA'    Ue Detach SA
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Ue Detach NSA

Ue Attach NSA
    NSA LTE Attach    ${UE_ID}    #${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed

Start Traffic NSA
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
    Sleep    5s    reason=Keep the traffic stable
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5

Ue Attach SA
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}

Start Traffic SA
    SA Start DL Traffic    10    5
    SA Start UL Traffic    10    5
    SA Check Average Traffic Bigger Than Target    dl    5
    SA Check Average Traffic Bigger Than Target    ul    5

Ue Detach NSA
    NSA LTE Detach    ${UE_ID}

Ue Detach SA
    SA 5G Detach    ${UE_ID}
