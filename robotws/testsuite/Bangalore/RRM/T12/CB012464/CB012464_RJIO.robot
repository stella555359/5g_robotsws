*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOOO
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
${CELL5}                5
${CELL6}                6
@{UE_RJIO}         1    2    3    4     5     6     7    8     9    10
@{NRPMQAP_IDS}      2
${FILTER}     3gpp.subcellid == 7 && UlData_UePuschReceiveRespPs_t.dtx == 0 && UlData_UePuschReceiveRespPs_t.fakeUe != True
${TOPOLOGY}     CLOUD_5G_O_E_AP_LOOO
@{CUSTOM_ALARMS}     4654    4655   61652    61524    61649    8000


*** Test Cases ***
[1][1.0] CB012464_RJIO_CVR_01
    [Tags]    QC_220541   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    This test case aims to verify the histogram and bin counters for the DL radio quality measurement
    ...                  after performing multiple Ping-Pong Intra frequency, Inter frequency Hand Over's using A2, A3
    ...                  and A5 measurement reports, IRAT HO using A2 and B2 measurement reports and Scell addition,
    ...                  release using A1 and A2 measurement reports.
    [Setup]    Prepare For CB012464 RJIO
    slog.Start Syslog  ${Log_Path}     SysLogCapRJIO.LOG
    FOR    ${ueid}    IN    @{UE_RJIO}
        UE Register Should Be Successful For SA    ${ueid}
        IF    int(${ueid}) <= 5
             DL Traffic Should Be Successful CB012464    ${DL_RT}    ${ueid}
             UL Traffic Should Be Successful CB012464    ${UL_RT}    ${ueid}
        ELSE
            Start Bursty Traffic    ${ueid}
        END
    END
    Add Pathloss With UL SINR Testmode And Activate With UE Testmode    1   1   150
    Add Pathloss With UL SINR Testmode And Activate With UE Testmode    2   1   150
    Add Pathloss With UL SINR Testmode And Activate With UE Testmode    3   1   150
    Add Pathloss With UL SINR Testmode And Activate With UE Testmode    4   1   150
    Add UE Time Advance Testmode And Activate   6   2
    Add UL Cell Noise Testmode      ProfId=3    cellId=5
    wtsrunner.UE Disp
    Wait For Next Full Pm Interval
    UE Meas Cfg Disp 	id=7
    Sleep   5s
	UE Measurement Send NR 		id=7 	meas_id=3 	event=A3 	phycell_id=51
	...		 nrsrp_nr=30 	srs_result=5:0:15:9
    Sleep   10s
	UE Meas Cfg Disp 	id=8
    Sleep   5s
	UE Measurement Send NR 		id=8 	meas_id=4 	event=A1	rs_type=ssb
	...	 srs_result=0:25:10:5 	srsrp_nr=127
    Sleep   10s
	UE Meas Cfg Disp 	id=9
    Sleep   5s
	UE Measurement Send NR 		id=9 	meas_id=3 	event=A3 	phycell_id=55
	...	 nrsrp_nr=30 	srs_result=0:40:66:100
    Sleep   10s
	UE Meas Cfg Disp 	id=9
    Sleep   5s
	UE Measurement Send NR 		id=9 	meas_id=3 	event=A3 	phycell_id=54
	...	 nrsrp_nr=30 	srs_result=0:100:105:50
    Sleep   10s
	UE Meas Cfg Disp 	id=10
    Sleep   5s
	UE Measurement Send NR 		id=10 	meas_id=1 	event=A2  	rs_type=ssb
	...	 srs_result=0:116:110:120
    Sleep   10s
	UE Meas Cfg Disp 	id=10
    Sleep   5s
	UE Measurement Send NR 		id=10 	meas_id=6 	event=A5 	phycell_id=52
	...	 nrsrp_nr=30 	srs_result=0:126:127:127
    Wait For Next Full Pm Interval
    Start Interface Mirroring With NR Phy Cellids       PhyCell=54
    Sleep   60s
    Stop Interface Mirroring With NR Phy Cellids
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    Log To Console      "All UEs Registered....."
    Verifying The PM Counters For CB012464 RJIO     ${pm_counter_file}      1
    Verifying The PM Counter For CB012464 CP Rank1			${CELL1}
    Verifying The PM Counter For CB012464 TA				${CELL1}
    Verifying The PM Counter For CB012464 CP Rank2          ${CELL3}
    ${SINAvg}       Calculate SINR Avg Value From BIP Log       CB012464_SIN.csv
    ${RIPAvg}       Calculate RIP Avg Value From BIP Log        CB012464_NOISE.csv
    Wait For Next Full Pm Interval
    ${pm_counter_file2}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file2}
    Verifying The PM Counter For CB012464E SIN RJIO     ${pm_counter_file2}      ${CELL5}    &{SINAvg}
    Verifying The PM Counter For CB012464E RIP RJIO     ${pm_counter_file2}      ${CELL5}    &{RIPAvg}
    FOR     ${ueid}     IN    @{UE_RJIO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    ${FID_LIST}    Get Alarm By Details
    log to console    \n${FID_LIST}
    Check if any unexpected alarm is raised    @{allowed_alarms}    ${FID_LIST}
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB012464 RJIO


*** Keywords ***
Start Bursty Traffic
    [Documentation]    This Keywords helps to start Bursty traffic
    [Arguments]       ${UE_ID}=${UE_ID}
    wtsrunner.trf_data_start     ue=${UE_ID}     pdu=1    qfi=1    trf_id= 1    size=42    burst=1    dir=ul    period_ms=8
    wtsrunner.trf_data_start     ue=${UE_ID}     pdu=1    qfi=1    trf_id= 1    size=42    burst=1    dir=dl    period_ms=8

Check If Any Unexpected Alarm Is Raised
    [Arguments]    @{allowed_alarms}    ${fid_list}
    ${unexpected}=    Create List
    FOR    ${alarm}    IN    @{fid_list}
        IF    ${alarm} not in @{allowed_alarms}
            Append To List    ${unexpected}    ${alarm}
        END
    END
    Log To Console    \nUnexpected alarms: ${unexpected}
    Run Keyword If    ${unexpected}    Fail    Unexpected alarms detected: ${unexpected}