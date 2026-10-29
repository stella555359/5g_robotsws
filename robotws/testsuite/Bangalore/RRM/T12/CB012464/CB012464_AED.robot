*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Vikash Kumar
...                 :contact  :   vikash.20.kumar@nokia.com
...                 :Feature  :   A ->  The purpose of the Test case is to measure the UL PUSCH residual BLER,
...                  MCS, RANK and Timing Advance PMQAP counters for all UL PUSCH transmission related
...                  to DRB with CP-OFDM 64QAM MCS table, CP-OFDM 256QAM MCS table and DFT-S-OFDM MCS table
...                  and validate them by comparing to legacy counters.
...                  E ->  This test case also validates AVG UL RIP and SINR counters introduced as part of CB012464-E.
...                  D ->  This test case aims to verify the histogram and bin counters for the DL radio quality measurement
...                  after performing multiple Ping-Pong Intra frequency, Inter frequency Handover's using A2, A3
...                  and A5 measurement reports, IRAT HO using A2 and B2 measurement reports and Scell addition,
...                  release using A1 and A2 measurement reports.

Resource          resources/Keywords/CB012464_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DL_RT}                20
${UL_RT}                20
${CELL1}                1
${CELL2}                2
${CELL3}                3
${CELL4}                4
${CELL7}                7
${CELL8}                8
${CELL10}               10
${CELL11}               11
${UE_SET1_Start}        1
${UE_SET1_End}          9
@{UE_D}         1    2    21    31    41    51    71   81   91


*** Test Cases ***
[1][1.0] CB012464_A_04_Verify_UL_PUSCH_residual_BLER_with_with_CP-OFDM_and_64QAM_MCS
    [Tags]    QC_171759   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    To measure the UL PUSCH residual BLER, MCS, RANK and Timing Advance PMQAP
    ...      counters for all UL PUSCH transmission related to DRB with CP-OFDM 64QAM MCS table,
    ...      CP-OFDM 256QAM MCS table and DFT-S-OFDM MCS table
    [Setup]    Prepare For CB012464
    slog.Start Syslog  ${Log_Path}     SysLogCapA.LOG
    Register Multiple UEs And Start UL AND DL Traffic     ${UE_SET1_Start}     ${UE_SET1_End}    ${DL_RT}    ${UL_RT}
    UE Disp
    Add Pathloss For Range of UEs
    Add TA And BLER Testmode For Range of UEs
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    De-Register Multiple UEs      ${UE_SET1_Start}      ${UE_SET1_End}
    Verifying The PM Counter For CB012464 CP64QAM		${CELL2}
    Verifying The PM Counter For CB012464 CP64QAM       ${CELL8}
    Verifying The PM Counter For CB012464 CP256QAM      ${CELL1}
    Verifying The PM Counter For CB012464 CP256QAM      ${CELL10}
    Verifying The PM Counter For CB012464 TA            ${CELL3}
    Verifying The PM Counter For CB012464 TA            ${CELL7}
    Deactivate TA And BLER Testmode For Range Of UEs    ${UE_SET1_Start}     ${UE_SET1_End}
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB012464

[1][1.0] CB012464_E_05_Verify_Avg_UL_RIP_SINR_counters_per_spatial_stream_for_multiple_UE
    [Tags]    QC_182839   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    To measure the Average of UL RIP and SINR Values per Spatial Streams
    [Setup]    Prepare For CB012464
    slog.Start Syslog  ${Log_Path}     SysLogCapE.LOG
    Register Multiple UEs And Start UL AND DL Traffic     ${UE_SET1_Start}     ${UE_SET1_End}    ${DL_RT}    ${UL_RT}
    Add UL Cell Noise Testmode
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Start Interface Mirroring With NR Phy Cellids
    Sleep   60s
    Stop Interface Mirroring With NR Phy Cellids
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    De-Register Multiple UEs      ${UE_SET1_Start}      ${UE_SET1_End}
    ${SINAvg}       Calculate SINR Avg Value From BIP Log       CB012464_SIN.csv
    ${RIPAvg}       Calculate RIP Avg Value From BIP Log        CB012464_NOISE.csv
    Verifying The PM Counter For CB012464E SIN     ${pm_counter_file}      ${CELL11}    &{SINAvg}
    Verifying The PM Counter For CB012464E RIP     ${pm_counter_file}      ${CELL11}    &{RIPAvg}
    Add UL Cell Noise Testmode    action=deactivate
    [Teardown]         Run Keyword And Ignore Error      Common Tear Down For CB012464

[1][1.0] CB012464_D_22_Verify_Counter_update_for_the_DL_radio_quality_measurement_after_multiple_ping_pong_HO_scell_addition_and_release
    [Tags]    QC_196577    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    This test case aims to verify the histogram and bin counters for the DL radio quality measurement
    ...                  after performing multiple Ping-Pong Intra frequency, Inter frequency Hand Over's using A2, A3
    ...                  and A5 measurement reports, IRAT HO using A2 and B2 measurement reports and Scell addition,
    ...                  release using A1 and A2 measurement reports.
    [Setup]    Prepare For CB012464D
    slog.Start Syslog  ${Log_Path}     SysLogCapD.LOG
    FOR     ${ueid}     IN    @{UE_D}
        UE Register Should Be Successful For SA    ${ueid}
        Log    Starting Downlink and Uplink Traffic for UE ${ueid}
        DL Traffic Should Be Successful CB012464    ${DL_RT}    ${ueid}
        UL Traffic Should Be Successful CB012464    ${UL_RT}    ${ueid}
        Log To Console      Starting Dl and Ul Traffic for UE ${ueid} for diff QoS
    END
    UE Disp
    Log To Console      "All UEs Registered....."
    Wait For Next Full Pm Interval
    UE Meas CFG Disp    id=1
    UE Measurement Send NR      id=1    meas_id=1       event=A2
    ...      srs_result=0:18:18:20      phycell_id=51
    Sleep    10s
    UE Meas CFG Disp    id=1
    UE Measurement Send NR      id=1    meas_id=9       event=B2
    ...      srs_result=1:0:18:18       phycell_id=12   nrsrp_nr=35     nrsrq_nr=30
    Sleep    10s
    UE Meas CFG Disp    id=2
    UE Measurement Send NR      id=2    meas_id=1       event=A2
    ...      srs_result=2:5:5:5         rs_type=ssb
    Sleep    10s
    UE Meas CFG Disp    id=2
    UE Measurement Send NR      id=2    meas_id=6       event=A3
    ...      srs_result=3:10:15:9       phycell_id=57   nrsrp_nr=30
    Sleep    10s
    UE Meas CFG Disp    id=2
    UE Measurement Send NR      id=2    meas_id=9       event=A2
    ...      srs_result=0:18:18:18      rs_type=ssb
    Sleep    10s
    UE Meas CFG Disp    id=2
    UE Measurement Send NR      id=2    meas_id=16      event=A5
    ...      srs_result=0:25:26:27      phycell_id=51   nrsrp_nr=30
    Sleep    10s
    UE Meas CFG Disp    id=21
    UE Measurement Send NR      id=21   meas_id=4       event=A5
    ...      srs_result=4:30:30:30      phycell_id=54   srsrp_nr=10       srsrq_nr=10     nrsrp_nr=30
    Sleep    10s
    UE Meas CFG Disp    id=21
    UE Measurement Send NR      id=21   meas_id=3       event=A3
    ...      srs_result=3:40:39:38      phycell_id=52   srsrp_nr=10       srsrq_nr=10     nrsrp_nr=30
    Sleep    10s
    UE Measurement Send NR      id=31   meas_id=5       event=A1
    ...      srs_result=5:30:45:41       rs_type=ssb    srsrp_nr=127
    Sleep    10s
    UE Meas CFG Disp    id=31
    UE Measurement Send NR      id=31   meas_id=6       event=A2
    ...      srs_result=2:52:54:59       scell=1        scell_rsrp=40     scell_rsrq=0
    Sleep    10s
    UE Meas CFG Disp    id=71
    UE Measurement Send NR      id=71   meas_id=5       event=A1
    ...      srs_result=0:40:66:100      srsrp_nr=127   rs_type=ssb
    Sleep    10s
    UE Meas CFG Disp    id=71
    UE Measurement Send NR      id=71   meas_id=6       event=A2
    ...      srs_result=0:30:50:49      scell=1         scell_rsrp=40     scell_rsrq=0
    Sleep    10s
    UE Meas CFG Disp    id=81
    UE Measurement Send NR      id=81   meas_id=4       event=A5
    ...      srs_result=0:110:103:108   phycell_id=61   srsrp_nr=10    srsrq_nr=10     nrsrp_nr=30
    Sleep    10s
    UE Meas CFG Disp    id=81
    UE Measurement Send NR      id=81   meas_id=3       event=A3
    ...      srs_result=0:126:127:127   phycell_id=60   srsrp_nr=10    srsrq_nr=10     nrsrp_nr=30
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    FOR     ${ueid}     IN    @{UE_D}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    Verifying The PM Counters For CB012464D      ${pm_counter_file}      1
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB012464D

