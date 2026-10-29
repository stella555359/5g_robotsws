*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    CONFIGURED    RAN_5G_TDD    RAN_5G    PY39
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :contact: cristinel.sava@nokia.com

Resource    ../5G001756_Keywords.robot
Resource    ../CaseResource/D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined.robot
Resource    ../CaseResource/D_15_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SUlSchedulingTraceRecord_Allfields.robot
Resource    ../CaseResource/D_16_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SDlSchedulingTraceRecord_Allfields.robot
Resource    ../CaseResource/D_17_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_ULRLCTraceRecord_Allfields.robot
Resource    ../CaseResource/D_18_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_DLRLCTraceRecord_Allfields.robot
Resource    ../CaseResource/D_19_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SBeamUsageTraceRecord_Allfields.robot
Resource    ../CaseResource/G_30_SA_ClassicalgNB_Streaming_PCMD_Uplane_Multiple_Bearers_report.robot
Resource    ../CaseResource/G_31_SA_ClassicalgNB_Streaming_PCMD_Uplane_measuremnt_report_period.robot
Resource    ../CaseResource/B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM.robot
Resource    ../CaseResource/5GC000376_BB_TestSuite_regression_new.robot
Resource    Resource/PCMD.robot
Resource    Resource/pm_logs_frame_07.robot
Resource    Resource/ERR_WRN_Check.robot
#Resource    Resource/Common.robot


Suite Setup    Run Keywords    sleep    1s
#...            AND             Setup WTS Esim Environment
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Log to console    1 Get Scfc File
...            AND             Get VM Password
...            AND             Log to console    2 Get VM Password
...            AND             Get VM IP
...            AND             Log to console    3 Get VM IP
...            AND             Start Vm Ethernet Interfaces
...            AND             Log to console    4 Start Vm Ethernet Interfaces
...            AND             Log to console    5 Start UTF sleep 20s
...            AND             Run  utf_lab-controller start
...            AND             sleep    20s
...            AND             Log to console    6 GET EMIL_LAST_FILE
...            AND             EMIL_LAST_FILE
...            AND             Start Tcpdump To Get PCMD   pcmd_file=ZZ_lmp.pcap
...            AND             Log to console    7 Start Tcpdump
...            AND             Run Keyword And Ignore Error    Wait Until Keyword Succeeds    120s    30s
                               ...    Find Scfc And Send Delta Commissioning    scfc_filename=delta_json_delete_TCE.json
...            AND             Log to console    8 Delta Commissioning Removed pcmd objects
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=Cell_Trace_Radu1.json
...            AND             Log to console    9 Delta Commissioning ADD pcmd objects
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Log to console    10 Get Scfc File scfc_after_delta.xml
...            AND             ERR_WRN_Check.Start BTSlogs Collection In Log Server
...            AND             Log to console    5 Syslog Capture Start
...            AND             Reach Onair without confirmation   lua_cfg=${CURDIR}/config/basic.cfg
...            AND             sleep    20s
...            AND             Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
...            AND             Log to console    11 Site UP
...            AND             5G001756_Keywords.Make L3CALL And Get ALL PCMD MSG
...            AND             Log to console    12 Make L3CALL And Get ALL PCMD MSG
...            AND             Log to console    13 GET EMIL_NEWEST_FILE
...            AND             EMIL_NEWEST_FILE
...            AND             Log to console    14 Covert Emil Logs to TXT1
...            AND             Covert Emil Logs to TXT1  local_dir=${OUTPUT_DIR}   connection=emil
...            AND             Common suite setup HZ
...            AND             Log to console    15 Make Common suite setup HZ
...            AND             Stop Tcpdump To Get PCMD    pcmd_file=ZZ_lmp.pcap
...            AND             sleep    5s
...            AND             Log to console    16 Stoped Tcpdump and Get PCMD pcmd_file=ZZ_lmp.pcap

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces

...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs




Test Teardown    Run Keyword  Common Test Teardown L3



*** Test Cases ***
5GC001756_D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_14
    D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
#    [Teardown]   Case Teardown: D_14
#
5GC001756_D_15_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SUlSchedulingTraceRecord_Allfields
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_15
    D_15_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SUlSchedulingTraceRecord_Allfields
#    [Teardown]   Case Teardown: D_15

5GC001756_D_16_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SDlSchedulingTraceRecord_Allfields
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_16
    D_16_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SDlSchedulingTraceRecord_Allfields
#    [Teardown]   Case Teardown: D_16

5GC001756_D_17_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_ULRLCTraceRecord_Allfields
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_17
    D_17_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_ULRLCTraceRecord_Allfields
#    [Teardown]   Case Teardown: D_17

5GC001756_D_18_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_DLRLCTraceRecord_Allfields
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_18
    D_18_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_DLRLCTraceRecord_Allfields
#    [Teardown]   Case Teardown: D_18

5GC001756_D_19_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SBeamUsageTraceRecord_Allfields
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_19
    D_19_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SBeamUsageTraceRecord_Allfields
#    [Teardown]   Case Teardown: D_19

5GC001756_G_30_SA_ClassicalgNB_Streaming_PCMD_Uplane_Multiple_Bearers_report
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: G_30
    G_30_SA_ClassicalgNB_Streaming_PCMD_Uplane_Multiple_Bearers_report
#    [Teardown]   Case Teardown: G_30

5GC001756_G_31_SA_ClassicalgNB_Streaming_PCMD_Uplane_measuremnt_report_period
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Timeout]  1h
#    [Setup]   Case Setup: G_31
    G_31_SA_ClassicalgNB_Streaming_PCMD_Uplane_measuremnt_report_period
#    [Teardown]   Case Teardown: G_31

5GC001756_B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_1_PCMD_ulTimeUeSched_SUlSchedulingTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_1_PCMD_ulTimeUeSched_SUlSchedulingTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_3_PCMD_ulBadMacPdusIniTx_SUlSchedulingTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_3_PCMD_ulBadMacPdusIniTx_SUlSchedulingTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

#5GC000376_BB_4_PCMD_ulBadMacPdusLastTx _SUlSchedulingTraceRecord_Counter
#    [Documentation]   Author: liangliang.heng@nokia-sbell.com
#    [1]5GC000376_BB_4_PCMD_ulBadMacPdusLastTx _SUlSchedulingTraceRecord_Counter
##    [Teardown]   Case Teardown: B_3
#
#5GC000376_BB_7_PCMD_ulMacPdusIniTx_SUlSchedulingTraceRecord_Counter
#    [Documentation]   Author: liangliang.heng@nokia-sbell.com
#    [1]5GC000376_BB_7_PCMD_ulMacPdusIniTx_SUlSchedulingTraceRecord_Counter
##    [Teardown]   Case Teardown: B_3

5GC000376_BB_2_PCMD_dlTimeUeSched_SDlSchedulingTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_2_PCMD_dlTimeUeSched_SDlSchedulingTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_5_PCMD_dlBadMacPdusIniTx_SDlSchedulingTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_5_PCMD_dlBadMacPdusIniTx_SDlSchedulingTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

#5GC000376_BB_6_PCMD_dlBadMacPdusLastTx_SDlSchedulingTraceRecord_Counter
#    [Documentation]   Author: liangliang.heng@nokia-sbell.com
#    [1]5GC000376_BB_6_PCMD_dlBadMacPdusLastTx_SDlSchedulingTraceRecord_Counter
##    [Teardown]   Case Teardown: B_3

#5GC000376_BB_8_PCMD_dlMacPdusIniTx_SDlSchedulingTraceRecord_Counter
#    [Documentation]   Author: liangliang.heng@nokia-sbell.com
#    [1]5GC000376_BB_8_PCMD_dlMacPdusIniTx_SDlSchedulingTraceRecord_Counter
##    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_9_PCMD_ulRlcPduTxBytes_UL_RLCTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_9_PCMD_ulRlcPduTxBytes_UL_RLCTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_10_PCMD_ulRlcTxTime_UL_RLCTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_10_PCMD_ulRlcTxTime_UL_RLCTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_11_PCMD_dlRlcPduTxBytes_DL_RLCTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_11_PCMD_dlRlcPduTxBytes_DL_RLCTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_12_PCMD_dlRlcTxTime_DL_RLCTraceRecord_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_12_PCMD_dlRlcTxTime_DL_RLCTraceRecord_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_24_PCMD_sumOfWbCqi_SDlSchedulingTraceRecor_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_24_PCMD_sumOfWbCqi_SDlSchedulingTraceRecor_Counter
#    [Teardown]   Case Teardown: B_3

[1]5GC000376_BB_25_PCMD_numOfWbCqiSamples_ DlSchedulingTraceRecor_Counter
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [1]5GC000376_BB_25_PCMD_numOfWbCqiSamples_ DlSchedulingTraceRecor_Counter
#    [Teardown]   Case Teardown: B_3


#5GC001756_B_1_NSA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_SINR
#    [Documentation]   Author: liangliang.heng@nokia-sbell.com
#    [1]5GC001756_B_1_NSA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_SINR
##    [Teardown]   Case Teardown: B_3


#5GC001756_B_2_NSA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance
#    [Documentation]   Author: liangliang.heng@nokia-sbell.com
#    [1]5GC001756_B_2_NSA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance
##    [Teardown]   Case Teardown: B_3
    sleep    1s
