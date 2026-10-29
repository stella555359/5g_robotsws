*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS23R4    owner-annie.nie    PY39
Resource          ../../../resources/DevHZ5_resource.robot
Library    CB010397.py
Library    ta_emss


Documentation
...     INTRODUCTION:
...     The CB010397 feature introduces an additional mixed power saving operation mode to support both switch off options of MIMO Muting,
...     respectively Cell Switch Off, for a same cell during same period of time.
...
...     TEST SET NAME:
...
...     TESTING SCOPE:
...
...     CONTACTS:
...         ET:
...             Jakub Kowalczyk         jakub.kowalczyk@nokia.com
...             Maciej Madej            maciej.madej@nokia.com
...             Dawid Ziniewicz         dawid.ziniewicz@nokia.com
...         EFS:
...             Marcin Biniek           marcin.biniek@nokia.com
...             Rafał Kowalski          rafal.kowalski@nokia.com
...
...     REFERENCES:
...         CFAM:   https://gates.nsn-net.net/view/00026f09#o=0
...         FTS:    https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
...                 Doc.aspx?sourcedoc=%7B226114E7-651D-49C2-A67B-6BE39D7BFD1F%7D&file=FTS_HL_CB010397_MIMO%20muting%20and%20cell%
...                 20switch%20off%20cohabitation%20during%20same%20time%20window%20for%20LTE.docx&action=default&mobileredirect=
...                 true&cid=da8f292d-5019-4719-9ec0-5620221e0135
...
...         HISTORY:
...                 [15.05.2023] - First draft
...                 [22.06.2023] - Version after review



*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    ${TEnbcRadLowLoadSwitchOffDelay}=3       # *10 secs shortening load measurement windows from 300/120 s to 30/30 s
...    ${TEnbcRadHighLoadSwitchOnDelay}=3     # *10 secs
${TEnbcRadLowLoadSwitchOffDelay}    0x110016    # *10 secs
${TEnbcRadHighLoadSwitchOnDelay}    0x110017    # *10 secs


*** Test Cases ***
CB010397-A-d-1_4 - New Mixed Switch Off - emergency call, CMAS, OTDOA interaction
    [Documentation]
    ...     DESCRIPTION:
    ...     This test case verifies new Mixed Switch Off method in interaction with features:
    ...     SR003080 Power saving with online TX path switching off
    ...     when CB008800 'Extended Cell Switch Off Method' is disabled
    ...     Power Saving features are triggered by Power Saving Periods and Load change in PS groups.
    ...     Power Saving features are triggered by traffic on cell, blocked by OTDOA cell, emergency call and CMAS messages.
    ...
    ...     PRECONDITIONS:
    ...     eNB:
    ...         actLBPowerSaving    =   true        (LTE1103)
    ...         actLBRTXPowerSaving =   true        (LTE1203)
    ...         actOnlineTXSwitch   =   true        (SR003080)
    ...         actMixedSOMethod    =   true        (CB010397)
    ...         actExtCellSOMethod  =   false       (CB008800)
    ...         actLbpsCtrlLogicEnh =   false       (CB008745)
    ...         actETWS             =   false
    ...         actCMAS             =   true
    ...         LNCEL-3.actOtdoa    =   true
    ...         LNCEL-5.actOtdoa    =   true
    ...
    ...         +------------------------+--------------------------------+--------------------------------+--------------------------------+
    ...         | parameter     \   MOC: | PSGRP-1                        | PSGRP-2                        | PSGRP-3                        |
    ...         +------------------------+--------------------------------+--------------------------------+--------------------------------+
    ...         | lbpsCellList           | cell_1 (lbpsCellSOOrder= 10)   | cell_3 (lbpsCellSOOrder= 30)   | cell_5 (lbpsCellSOOrder= 50)   |
    ...         |                        | cell_2 (lbpsCellSOOrder= 30)   | cell_4 (lbpsCellSOOrder= 40)   | cell_6 (lbpsCellSOOrder= 60)   |
    ...         |                        | cell_7 (lbpsCellSOOrder= 100)  | cell_8 (lbpsCellSOOrder= 100)  | cell_9 (lbpsCellSOOrder= 100)  |
    ...         | lbpsSOMethod           | Mixed Switch off               | Mixed Switch off               | Mixed Switch off               |
    ...         | lbpsPeriodList         | Monday/01/00 [Day/Hour/Minute] | Monday/01/00 [Day/Hour/Minute] | Monday/01/00 [Day/Hour/Minute] |
    ...         | lbpsDuration           | 1            [min]             | 1            [min]             | 1            [min]             |
    ...         | lbpsMaxLoad            | 25                             | 25                             | 25                             |
    ...         | lbpsMinLoad            | 10                             | 10                             | 10                             |
    ...         | lbpsRTXMaxLoad         | 30                             | 30                             | 30                             |
    ...         | lbpsRTXMinLoad         | 15                             | 15                             | 15                             |
    ...         | lbpsLastCellMinLoad    | 10                             | 10                             | 10                             |
    ...         | lbpsLastCellRTXMinLoad | 15                             | 15                             | 15                             |
    ...         | lbpsLastCellSOEnabled  | false                          | true                           | true                           |
    ...         +------------------------+--------------------------------+--------------------------------+--------------------------------+
    ...         cells in same PSGRP has to be configured to separate earfcns
    ...         All PSG cells are in notEnergySaving state
    ...     Cells:
    ...         cell_1  2x Tx paths
    ...         cell_2  2x Tx paths
    ...         cell_3  2x Tx paths
    ...         cell_4  4x Tx paths
    ...         cell_5  2x Tx paths
    ...         cell_6  8x Tx paths
    ...         cell_7  2x Tx paths
    ...         cell_8  2x Tx paths
    ...         cell_9  2x Tx paths
    ...     UEs:
    ...         No UEs attached to any cell
    ...
    ...     TEST SCENARIO:
    ...     Step 1. Attach UEs to:
    ...                 PSGRP-1:  cell_7:  UE_11, UE_12
    ...                 PSGRP-2:  cell_8:  UE_13, UE_14
    ...                 PSGRP-3:  cell_9:  UE_15, UE_16
    ...             Start traffic with UEs to set nonGBR load on PSGRP-1,2,3 above lbpsRTXMinLoad;
    ...             Check and save current system time = start_time,
    ...             PSGRP-1  lbpsPeriodList= Day/Hour/Minute equals saved system time
    ...                      lbpsDuration=   90min
    ...             PSGRP-2  lbpsPeriodList= Day/Hour/Minute equals saved system time
    ...                      lbpsDuration=   90min
    ...             PSGRP-3  lbpsPeriodList= Day/Hour/Minute equals saved system time
    ...                      lbpsDuration=   90min
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_1 energySavingState = notEnergySaving
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = notEnergySaving
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 2. Adjust traffic with UEs to decrease load on PSGRP-1,2,3 below lbpsRTXMinLoad but above lbpsMinLoad
    ...             Attach UE to cell_8 with establishment_cause=emergency and prevent it from going to idle
    ...                 starting low (~10) kbps traffic with QCI=1 VoLTE bearer
    ...             Start sending CMAS messages on cell_9
    ...     Expected result:
    ...             After 5 to 6 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 3. Adjust traffic with UEs to maintain load on PSGRP-1,2,3 below lbpsRTXMinLoad but above lbpsMinLoad after PSGRP capacity change
    ...     Expected result:
    ...             After 5 to 6 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = reducedEnergySaving (2 Tx path enabled) without cell reset    (change)
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_6 energySavingState = reducedEnergySaving (2 Tx path enabled) without cell reset    (change)
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 4. Adjust traffic with UEs to decrease load on PSGRP-1,2,3 below lbps[LastCell]MinLoad
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_1 energySavingState = energySaving    (change)
    ...             cell_2 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = reducedEnergySaving (2 Tx path enabled)
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_6 energySavingState = reducedEnergySaving (2 Tx path enabled)
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 5. Adjust traffic with UEs to increase load on PSGRP-1 above lbpsMaxLoad but below lbpsRTXMaxLoad
    ...             Detach UE from cell_8 ending emergency call.
    ...             Stop sending CMAS messages on cell_9
    ...     Expected result:
    ...             After 3 minute (PSGRP-2,3 load already calculated):
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = reducedEnergySaving (2 Tx path enabled)
    ...             cell_8 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_6 energySavingState = reducedEnergySaving (2 Tx path enabled)
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             After 2 to 3 minutes:
    ...             cell_1 energySavingState = notEnergySaving    (change)
    ...             cell_2 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_7 energySavingState = notEnergySaving
    ...
    ...     Step 6. Adjust traffic with UEs to decrease load on PSGRP-1 below lbpsMinLoad
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_1 energySavingState = energySaving    (change)
    ...             cell_2 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = reducedEnergySaving (2 Tx path enabled)
    ...             cell_8 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_6 energySavingState = reducedEnergySaving (2 Tx path enabled)
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...
    ...
    ...  TESTING TOOLS:  Real eNB, CUS, EPCSIM, EMSSIM
    ...
    ...  TEST ENVIRONMENT:
    ...    HARDWARE ID:
    ...
    ...  REQUIREMENTS COVERAGE:
    ...    REQUIREMENTS IN SCOPE: <See QC field Requirements>
    ...
    ...  BACKLOG ID:
    ...  REQUIRED LOGS:  Snapshot, IM, syslog, EPC logs
    ...  CONTACTS:  Jakub Kowalczyk     jakub.kowalczyk@nokia.com
    ...             Maciej Madej        maciej.madej@nokia.com
    ...             Dawid Ziniewicz     dawid.ziniewicz@nokia.com
    ...
    ...  REFERENCES:
    ...      https://gates.nsn-net.net/view/00026f09#o=0
    ...
    ...  HISTORY:
    ...     [15.05.2023] - First draft
    ...     [22.06.2023] - Version after review

    [Tags]
    # Step 1. Attach UEs, Start traffic, set lbpsPeriodList
    Log To Console    -------- Step 1 --------
    execute uex command    ue_attach id=11,12 cell=7
    execute uex command    ue_attach id=13,14 cell=8
    execute uex command    ue_attach id=15,16 cell=9
    execute uex command    trf_data_start ue=11..16 qci=9 Mbps=7 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Set lbpsPeriodList for A-d-1_4
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell6 Enter Into notenergysaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    # Step 2. Adjust traffic, Attach UE emergency, Start sending CMAS
    Log To Console    -------- Step 2 --------
    execute uex command    trf_data_stop ue=11..16 qci=9
    execute uex command    trf_data_start ue=11 qci=9 kbps=6000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=13 qci=9 kbps=6000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=12 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=14 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=15 qci=9 kbps=4500 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=16 qci=9 kbps=2000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    ue_attach id=28 cell=8 establishment_cause=emergency
    execute uex command    trf_data_start ue=28 qci=1 kbps=10 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    ${CMAS_command}    catenate
    ...    mme_warn_request cell=9 enb=1 msg_id=1 msg_code=1 warn_msg_contents_length=92 data_coding_scheme=1 rep_period=60 number=0
    execute egate command    ${CMAS_command}
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State
    # Step 3. Adjust traffic below lbpsRTXMinLoad but above lbpsMinLoad
    Log To Console    -------- Step 3 --------
    execute uex command    trf_data_stop ue=11 qci=9
    execute uex command    trf_data_stop ue=13 qci=9
    execute uex command    trf_data_start ue=11 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=13 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_stop ue=15 qci=9
    execute uex command    trf_data_stop ue=16 qci=9
    execute uex command    trf_data_start ue=15..16 qci=9 kbps=3000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into reducedEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    # Step 4. Adjust traffic below lbps[LastCell]MinLoad
    Log To Console    -------- Step 4 --------
    execute uex command    trf_data_stop ue=11..16 qci=9
    execute uex command    trf_data_start ue=11..12 qci=9 kbps=2000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=13..16 qci=9 kbps=500 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell1 Enter Into energySaving State
    Cell2 Enter Into reducedEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    # Step 5. Adjust traffic on PSGRP-1 above lbpsMaxLoad but below lbpsRTXMaxLoad
    Log To Console    -------- Step 5 --------
    execute uex command    trf_data_stop ue=11..12 qci=9
    execute uex command    trf_data_start ue=11 qci=9 kbps=6000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=12 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    ue_detach id=28
    execute egate command    mme_warn_kill cell=9 enb=1 msg_id=1 msg_code=1
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell8 Enter Into reducedEnergySaving State
    Cell9 Enter Into reducedEnergySaving State

    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into reducedEnergySaving State
    Cell9 Enter Into reducedEnergySaving State

    # Step 6. Adjust traffic with UEs to decrease load on PSGRP-1 below lbpsMinLoad
    Log To Console    -------- Step 6 --------
    execute uex command    trf_data_stop ue=11..12 qci=9
    execute uex command    trf_data_start ue=11..12 qci=9 kbps=2000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    Cell1 Enter Into energySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into reducedEnergySaving State
    Cell9 Enter Into reducedEnergySaving State
#    [Teardown]    Cleanup after CB010397-A-d-1_4


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=CB010397-A-d    cfg=cus.yaml

Cleanup after CB010397-A-d-1_4
    release all ues
    execute egate command    mme_warn_kill cell=9 enb=1 msg_id=1 msg_code=1\
    Common Test Teardown And Stop Capture Logs

Set lbpsPeriodList for A-d-1_4
    Set Power Saving Period start for PSGRP-1,2,3 to 0 minutes from start and 90 minutes duration

Set Power Saving Period start for PSGRP-1,2,3 to ${offset} minutes from start and ${duration} minutes duration
    Create New Plan
    Edit PSGRP-1 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Edit PSGRP-2 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Edit PSGRP-3 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Apply planned changes


Edit PSGRP-${PSGRP} period-${period} time to current time + ${hours_offset}h${minutes_offset}min offset and duration: ${duration}min
    ${planned_time}=  get psgrp planned time  ${hours_offset}  ${minutes_offset}
    Log to console  changing PSGRP-${PSGRP} period-${period} time to ${planned_time}, duration: ${duration}min
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDayOfWeek=${planned_time}[0]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeHour=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeMinute=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDuration=${duration}           enb_id=1

check cell stats
    execute uex command    get_cell_stats id=7 type=dl_mac unit=Mbps
    execute uex command    get_cell_stats id=8 type=dl_mac unit=Mbps
    execute uex command    get_cell_stats id=9 type=dl_mac unit=Mbps