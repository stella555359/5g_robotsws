*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup For Suite
#Test Teardown     Common Test Teardown For Suite
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB008015    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ6    SBTS00    SBTS23R1    SBTS22R4
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 8015_D_2T_1F_SCFC.xml
#${IPHY_XML}                  ${CURDIR}/config/wts/iphy_2T_1F.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts
#${WTS_CFG}                   8015_D_2T_1F.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${EGATE_PATH}                /opt/iphy/latest/egate_console.log
#
#*** Test Cases ***
#CB008015_D_024_SA_Cell_Edge_UE_Lock_TDD_Cell_Configured_A1_Based_Scell_Addition_Method_Gracefully_Handover
#    Two SA CA UE Attach And Scell Check For UE1 And UE4
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=600
#    Start SA DL Big Traffic Internal    ue_id=4    mbps=300
#    Wait Until Keyword Succeeds    2min    10s    Check Pcell And Scell Throughput For UE1 And UE4
#    Trigger A2 Event For UE1
#    Trigger A2 Event For UE4
#    Trigger A3 Event For UE1 And Check Handover Status
#    Wait Until Keyword Succeeds    2min    10s    Check UE1 Throughput 1st
#    Trigger A3 Event For UE4 And Check Handover Status
#    Wait Until Keyword Succeeds    2min    10s    Check UE1 Throughput 2nd
#    Wait Until Keyword Succeeds    2min    10s    Check UE4 Throughput
#
#CB008015_D_018_SA_Cell_Edge_UE_Lock_TDD_Cell_Configured_A1_Based_Scell_Addition_Method_Gracefully_Scell_Release
#    Two SA CA UE Attach And Scell Check For UE2 And UE3
#    Start SA DL Big Traffic Internal    ue_id=3    mbps=600
#    Start SA DL Big Traffic Internal    ue_id=2    mbps=300
#    Wait Until Keyword Succeeds    2min    30s    Check Pcell And Scell Throughput For UE2 And UE3
#    Trigger A2 Event And Verify Scell Release For UE2
#    Trigger A2 Event And Verify Scell Release For UE3
#    Check Throughput For 2UE After Scell Release
#
#CB008015_D_015_SA_Cell_Center_UE_Lock_TDD_Cell_Configured_A1_Based_Scell_Addition_Method_Gracefully
#    Four SA CA UE Attach And Scell Check
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=2    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=3    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=4    mbps=150
#    Wait Until Keyword Succeeds    2min    30s    Check Pcell And Scell Throughput For 4UE
#    Run Keyword And Ignore Error    Start And Stop Tti Trace
#    Enable Graceful Shutdown For Cell 1
#    Wait Until Keyword Succeeds    5min    30s    Verify Ue Detached
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#
#Common Test Setup For Suite
#    Reboot TL And Check Configured
#    Run Keyword And Ignore Error    Clean Edaemon And Egate
#    Suite Setup Start WTS And Check OnAir
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#    Common Test Setup
#
#Two SA CA UE Attach And Scell Check    ${ue_id_1}    ${ue_id_2}
#    [Arguments]    ${ue_id_1}=1    ${ue_id_2}=2
#    SA Attach    sa_ue_id=${ue_id_1}
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=${ue_id_1}    pcell_id=50    rsrp=95    mea_id=3
#    Check SA Scell PhysicalID With UE ID    ue_id=${ue_id_1}    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=${ue_id_2}
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=${ue_id_2}    pcell_id=50    rsrp=95    mea_id=3
#    Check SA Scell PhysicalID With UE ID    ue_id=${ue_id_2}    scell_physicalid=51    scell_index=1
#
#Two SA CA UE Attach And Scell Check For UE2 And UE3
#    SA Attach    sa_ue_id=2
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=2    pcell_id=51    rsrp=95    mea_id=2
#    Check SA Scell PhysicalID With UE ID    ue_id=2    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=3
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=3    pcell_id=52    rsrp=95    mea_id=2
#    Check SA Scell PhysicalID With UE ID    ue_id=3    scell_physicalid=50    scell_index=1
#
#Two SA CA UE Attach And Scell Check For UE1 And UE4
#    SA Attach    sa_ue_id=1
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=1    pcell_id=50    rsrp=95    mea_id=3
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=4
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=4    pcell_id=50    rsrp=95    mea_id=3
#    Check SA Scell PhysicalID With UE ID    ue_id=4    scell_physicalid=51    scell_index=1
#
#Trigger A2 Event For UE1
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 rs_type\=ssb scell\=1
#    ...    scell_rsrp\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#
#Trigger A2 Event For UE4
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id\=4 meas_id\=1 event\=A2 rs_type\=ssb scell\=1
#    ...    scell_rsrp\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#
#Trigger A3 Event For UE1 And Check Handover Status
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id=\1 event=\A3 rs_type=\ssb srsrp_nr=\20 phycell_id=\52
#    ...    nrsrp_nr=\80 meas_id=\5
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#
#Trigger A3 Event For UE4 And Check Handover Status
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE4: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id=\4 event=\A3 rs_type=\ssb srsrp_nr=\20 phycell_id=\52
#    ...    nrsrp_nr=\80 meas_id=\5
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#
#Check Pcell And Scell Throughput For UE1 And UE4
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=160
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=330
#    Check UE Pcell Scell TP On Target    ue_id=4    dir=dl    cell_type=pcell    scell_index=0    target_tp=160
#    Check UE Pcell Scell TP On Target    ue_id=4    dir=dl    cell_type=scell    scell_index=1    target_tp=70
#
#Check Pcell And Scell Throughput For UE2 And UE3
#    Check UE Pcell Scell TP On Target    ue_id=3    dir=dl    cell_type=pcell    scell_index=0    target_tp=300
#    Check UE Pcell Scell TP On Target    ue_id=3    dir=dl    cell_type=scell    scell_index=1    target_tp=150
#    Check UE Pcell Scell TP On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=60
#    Check UE Pcell Scell TP On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=150
#
#Check UE1 Throughput 1st
#    SA UE Check Throughput In A Range    UE_ID=1    dl_tp_max=380    dl_tp_min=320
#
#Check UE1 Throughput 2nd
#    SA UE Check Throughput In A Range    UE_ID=1    dl_tp_max=200    dl_tp_min=150
#
#Check UE4 Throughput
#    SA UE Check Throughput In A Range    UE_ID=4    dl_tp_max=200    dl_tp_min=150
#
#SA UE Check Throughput In A Range
#    [Arguments]    ${UE_ID}=11    ${dl_tp_max}=5    ${dl_tp_min}=5
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    Log    DL Troughput is ${dl_tp}    console=True
#    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_min}
#    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
#    Log To Console    The TPUT is bigger than min: ${dl_tp_min}M \n
#    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_max}
#    Should Be True    ${tp_delta}<=0    Throughtput is not in the accetable range
#    Log To Console    The TPUT is smaller than max: ${dl_tp_max}M \n
#
#Trigger A2 Event And Verify Scell Release For UE2
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    sCellToReleaseList
#    ${cmd}    Catenate    ue_measurement_send_nr id\=2 meas_id\=3 event\=A2 rs_type\=ssb
#    ...    scell\=1 scell_rsrp\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#
#Trigger A2 Event And Verify Scell Release For UE3
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    sCellToReleaseList
#    ${cmd}    Catenate    ue_measurement_send_nr id\=3 meas_id\=3 event\=A2 rs_type\=ssb
#    ...    scell\=1 scell_rsrp\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#
#Check Throughput For 2UE After Scell Release
#    Sleep    20s    reason=wait for Tput
#    SA UE Check Throughput In A Range    UE_ID=3    dl_tp_max=380    dl_tp_min=320
#    SA UE Check Throughput In A Range    UE_ID=2    dl_tp_max=90    dl_tp_min=70
#
#Check Pcell And Scell Throughput For 4UE
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=75
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=150
#    Check UE Pcell Scell TP On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=30
#    Check UE Pcell Scell TP On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=75
#    Check UE Pcell Scell TP On Target    ue_id=3    dir=dl    cell_type=pcell    scell_index=0    target_tp=150
#    Check UE Pcell Scell TP On Target    ue_id=3    dir=dl    cell_type=scell    scell_index=1    target_tp=75
#    Check UE Pcell Scell TP On Target    ue_id=4    dir=dl    cell_type=pcell    scell_index=0    target_tp=75
#    Check UE Pcell Scell TP On Target    ue_id=4    dir=dl    cell_type=scell    scell_index=1    target_tp=30
#
#Four SA CA UE Attach And Scell Check
#    SA Attach    sa_ue_id=1
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=1    pcell_id=50    rsrp=95    mea_id=3
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=2
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=2    pcell_id=51    rsrp=95    mea_id=2
#    Check SA Scell PhysicalID With UE ID    ue_id=2    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=3
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=3    pcell_id=52    rsrp=95    mea_id=2
#    Check SA Scell PhysicalID With UE ID    ue_id=3    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=4
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=4    pcell_id=50    rsrp=95    mea_id=3
#    Check SA Scell PhysicalID With UE ID    ue_id=4    scell_physicalid=51    scell_index=1
#
#Start And Stop Tti Trace
#    common_log_capture.Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=get ttitrace
#    common_log_capture.Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv
#    ...    ${OUTPUT_DIR}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
#    ...    ${OUTPUT_DIR}/ttitrace_streaming/output_ul_formated.csv
#
#Enable Graceful Shutdown For Cell 1
#    Log To Console    Enable graceful shutdown for cell 1...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    administrativeState    Shutting Down
#
#Suite Setup Start WTS And Check OnAir With Reboot
#    ${KW_status}    ${BTSonair_status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir
#    Run Keyword If    '${KW_status}'=='FAIL'    Not OnAir Workaround
#
#Not OnAir Workaround
#    Reboot TL And Check Configured
#    Run Keyword And Ignore Error    Clean Edaemon And Egate
#    Suite Setup Start WTS And Check OnAir
#
#Common Test Teardown For Suite
#    ute_wtssim.Execute Egate Command    reset
#    Common Test Teardown
