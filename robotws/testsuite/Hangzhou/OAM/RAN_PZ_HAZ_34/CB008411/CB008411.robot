*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/Common.robot

Suite Setup   CB008411 Common Suite Setup
Suite Teardown   CB008411 Common Suite Teardown


*** Test Cases ***
CB008411_A_Subscriber_Trace_with_PCMD_content_CA
    [Setup]   Case Setup: CB008411_A_Subscriber_Trace_with_PCMD_content_CA
    Log To Console   CB008411_A_Subscriber_Trace_with_PCMD_content_CA

    Start Tcpdump To Get PCMD   pcmd_file=PCMD_CA.pcap

    ute_wtssim.Setup Egate   egate_port=20000   tool_dir=${WTS_DIR}   ssh_pass=${WTS_PASSWORD}
    Initial Context Setp Request

    Log To Console   SigSpark UE Attach
    operate_spark   command=attach
    Sleep   100s
    operate_spark   command=detach

    Stop Tcpdump To Get PCMD   pcmd_file=PCMD_CA.pcap
    Stop Subscriber trace for ICS

    Check multi tracerecords   tracerecords=${cucp_tracerecords}   host=sba  traceId=00:00:01  capture_file_path=${OUTPUT_DIR}/PCMD_CA.pcap
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=00:00:01  capture_file_path=${OUTPUT_DIR}/PCMD_CA.pcap
    Check multi tracerecords   tracerecords=${du_tracerecords}   host=sba  traceId=00:00:01  capture_file_path=${OUTPUT_DIR}/PCMD_CA.pcap

    [Teardown]   Case Teardown: CB008411_A_Subscriber_Trace_with_PCMD_content_CA


CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP
    [Setup]   Case Setup: CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP
    Log To Console   CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP

    Start Tcpdump To Get PCMD   pcmd_file=PCMD_CUUP.pcap

    ute_wtssim.Setup Egate   egate_port=20000   tool_dir=${WTS_DIR}   ssh_pass=${WTS_PASSWORD}
    Initial Context Setp Request

    Log To Console   SigSpark UE Attach
    operate_spark   command=attach
    Sleep   100s
    operate_spark   command=detach

    Stop Tcpdump To Get PCMD   pcmd_file=PCMD_CUUP.pcap
    Stop Subscriber trace for ICS

    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=00:00:01  capture_file_path=${OUTPUT_DIR}/PCMD_CUUP.pcap

    [Teardown]   Case Teardown: CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP


CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER
    [Setup]   Case Setup: CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER
    Log To Console   CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER

    Start Tcpdump To Get PCMD   pcmd_file=PCMD_HO.pcap

    ute_wtssim.Setup Egate   egate_port=20000   tool_dir=${WTS_DIR}   ssh_pass=${WTS_PASSWORD}
    Initial Context Setp Request

    Log To Console   SigSpark UE Attach
    operate_spark   command=attach
    Sleep   100s
    operate_spark   command=detach

    Stop Tcpdump To Get PCMD   pcmd_file=PCMD_HO.pcap
    Stop Subscriber trace for ICS

    Check multi tracerecords   tracerecords=${du_tracerecords}   host=sba  traceId=00:00:01  capture_file_path=${OUTPUT_DIR}/PCMD_HO.pcap

    [Teardown]   Case Teardown: CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER



*** Keyword ***
Case Setup: CB008411_A_Subscriber_Trace_with_PCMD_content_CA
    Log To Console   Case Setup: CB008411_A_Subscriber_Trace_with_PCMD_content_CA
    Wait Until Keyword Succeeds    3x   30s   COAM Login

    Log To Console   Perform SCF Commission: SCF_SBTS00_SBA_CA.xml
    COAM SCF Commission   filepath=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_SBA_CA.xml

    Log To Console    COAM Check BTS OnAir
    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS OnAir
    Sleep   60s


Case Teardown: CB008411_A_Subscriber_Trace_with_PCMD_content_CA
    Log To Console   Case Teardown: CB008411_A_Subscriber_Trace_with_PCMD_content_CA
    Run Keyword And Ignore Error   COAM Logout



Case Setup: CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP
    Log To Console   Case Setup: CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP
    Wait Until Keyword Succeeds    3x   30s   COAM Login

    Log To Console   Perform SCF Commission: SCF_SBTS00_SBA_CUUP.xml
    COAM SCF Commission   filepath=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_SBA_CUUP.xml

    Log To Console    COAM Check BTS OnAir
    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS OnAir
    Sleep   60s


Case Teardown: CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP
    Log To Console   Case Teardown: CB008411_B_Subscriber_Trace_with_PCMD_content_CUUP
    Run Keyword And Ignore Error   COAM Logout



Case Setup: CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER
    Log To Console   Case Setup: CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER
    Wait Until Keyword Succeeds    3x   30s   COAM Login

    Log To Console   Perform SCF Commission: SCF_SBTS00_SBA_HO.xml
    COAM SCF Commission   filepath=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_SBA_HO.xml

    Log To Console    COAM Check BTS OnAir
    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS OnAir
    Sleep   60s


Case Teardown: CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER
    Log To Console   Case Teardown: CB008411_B_Subscriber_Trace_with_PCMD_content_Intra_gNB_HANDOVER
    Run Keyword And Ignore Error   COAM Logout

