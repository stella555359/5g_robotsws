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
...                 [16.05.2023] - First draft
...                 [--.--.2023] - Version after review




*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    ${TEnbcRadLowLoadSwitchOffDelay}=3       # *10 secs
...    ${TEnbcRadHighLoadSwitchOnDelay}=3     # *10 secs
...    ${fix_random_time}=10
${TEnbcRadLowLoadSwitchOffDelay}    0x110016    # *10 secs
${TEnbcRadHighLoadSwitchOnDelay}    0x110017    # *10 secs
${fix_random_time}    0x100007

@{Disable_lbpsUseExtConfig}
...    PSGRP-2:lbpsCellList:lbpsUseExtConfig=true|lnCelId=3
...    PSGRP-2:lbpsCellList:lbpsCellSOOrder=50|lnCelId=3

...    PSGRP-2:lbpsCellList:lbpsUseExtConfig=false|lnCelId=4
...    PSGRP-2:lbpsCellList:lbpsCellSOOrder=70|lnCelId=4

...    PSGRP-2:lbpsCellList:lbpsUseExtConfig=false|lnCelId=8
...    PSGRP-2:lbpsCellList:lbpsCellSOOrder=100|lnCelId=8

...    PSGRP-3:lbpsCellList:lbpsUseExtConfig=false|lnCelId=5
...    PSGRP-3:lbpsCellList:lbpsCellSOOrder=50|lnCelId=5

...    PSGRP-3:lbpsCellList:lbpsUseExtConfig=false|lnCelId=6
...    PSGRP-3:lbpsCellList:lbpsCellSOOrder=70|lnCelId=6

...    PSGRP-3:lbpsCellList:lbpsUseExtConfig=false|lnCelId=9
...    PSGRP-3:lbpsCellList:lbpsCellSOOrder=100|lnCelId=9


*** Test Cases ***
CB010397-A-e-1a - New Mixed Switch Off - CB008800 enabled with all Cell SO Methods
    [Documentation]
    ...     DESCRIPTION:
    ...     This test case verifies New Mixed Switch Off method when CB008800 'Extended Cell Switch Off Method' is enabled
    ...     with cell level power saving parameters configured.
    ...     Power Saving features are triggered by Load change and PSGRP/cell periods.
    ...
    ...     PRECONDITIONS:
    ...     eNB:
    ...         actLBPowerSaving    =   true        (LTE1103)
    ...         actLBRTXPowerSaving =   true        (LTE1203)
    ...         actMixedSOMethod    =   true        (CB010397)
    ...         actExtCellSOMethod  =   true        (CB008800)
    ...         actOnlineTXSwitch   =   true        (SR003080)
    ...         actLbpsCtrlLogicEnh =   false       (CB008745)
    ...
    ...    +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------------+
    ...    | parameter        \     MOC: | PSGRP-1                           | PSGRP-2                           | PSGRP-3                           |
    ...    +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------------+
    ...    | lbpsCellList \ lnCelId      |     1     |     2     |     7     |     3     |     4     |     8     |     5     |     6     |     9     |
    ...    +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------------+
    ...    | lbpsCellSOOrder             |     50    |     70    |    100    |     50    |     70    |    100    |     50    |     70    |    100    |
    ...    | lbpsUseExtConfig            |    true   |    true   |    true   |    true   |    true   |    true   |    true   |    true   |    true   |
    ...    +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------------+
    ...    | lbpsSOMethod                | Mixed Switch Off                  | Mixed Switch Off                  | Mixed Switch Off                  |
    ...    | lbpsPeriodList [Day/Hr/Min] | Monday/01/00                      | Monday/01/00                      | Monday/01/00                      |
    ...    | lbpsDuration      [min]     | 1                                 | 1                                 | 1                                 |
    ...    | lbpsMaxLoad                 | 25                                | 25                                | 25                                |
    ...    | lbpsMinLoad                 | 6                                 | 6                                 | 6                                 |
    ...    | lbpsRTXMaxLoad              | 30                                | 30                                | 30                                |
    ...    | lbpsRTXMinLoad              | 15                                | 15                                | 15                                |
    ...    | lbpsLastCellMinLoad         | 2                                 | 2                                 | 2                                 |
    ...    | lbpsLastCellRTXMinLoad      | 10                                | 10                                | 10                                |
    ...    | lbpsLastCellSOEnabled       | true                              | true                              | true                              |
    ...    +-----------------------------+-----------------------------------------------------------------------+-----------------------------------+
    ...    | lbpsCelPeriodList \ LnCelId |     1     |     2     |     7     |     3     |     4     |     8     |     5     |     6     |     9     |
    ...    +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------------+
    ...    | lbpsCellDayOfWeek           |   Monday  |   Monday  |   Monday  |   Monday  |   Monday  |   Monday  |   Monday  |   Monday  |   Monday  |
    ...    | lbpsCellDuration            |     1     |     1     |     1     |     1     |     1     |     1     |     1     |     1     |     1     |
    ...    | lbpsCellSOMethod            |Tx Paths SO|  Cell SO  |  Mixed SO |Tx Paths SO|  Cell SO  |  Mixed SO |  Mixed SO |  Cell SO  |Tx Paths SO|
    ...    | lbpsCellStartTimeHour       |     1     |     1     |     1     |     1     |     1     |     1     |     1     |     1     |     1     |
    ...    | lbpsCellStartTimeMinute     |     0     |     0     |     0     |     0     |     0     |     0     |     0     |     0     |     0     |
    ...    +-----------------------------+-----------------------------------------------------------------------+-----------------------------------+
    ...         cells in same PSGRP has to be configured to separate earfcns
    ...         All PSG cells are in notEnergySaving state
    ...
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
    ...
    ...     UEs:
    ...         No UEs attached to any cell
    ...
    ...     TEST SCENARIO:
    ...     Step 1. Attach UEs to:
    ...                cell_7:  UE_11, UE_12
    ...                cell_8:  UE_13, UE_14
    ...                cell_9:  UE_15, UE_16
    ...             Start traffic with UEs to set load on PSGRP-1,2 below lbpsRTXMinLoad but above lbpsMinLoad;
    ...             Start traffic with UEs to set load on PSGRP-3 below lbpsMinLoad;
    ...             Check and save current system time = start_time,
    ...             PSGRP-1,2,3  lbpsPeriodList= Day/Hour/Minute equals saved system time,  lbpsDuration= 90min
    ...             cell_1,2,7  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 90min
    ...             cell_5,6,9  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 90min
    ...             cell_3  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 10min
    ...             cell_4  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time + 15 min,  lbpsCellDuration= 10min
    ...             cell_8  lbpsCelPeriodList[0]=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 10min
    ...             cell_8  lbpsCelPeriodList[1]=  Day/Hour/Minute equals saved system time + 15 min,  lbpsCellDuration= 10min
    ...     Expected result:
    ...             After 6 to 6.5 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = energySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 2. Adjust traffic with UEs to decrease load on PSGRP-1,2 below lbpsLastCellRTXMinLoad but above lbpsMinLoad
    ...             Adjust traffic with UEs to increase load on PSGRP-3 above lbpsMaxLoad
    ...     Expected result:
    ...             After 2 to 2.5 minutes:
    ...             cell_5 energySavingState = notEnergySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...             After next 4 to 4.5 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...
    ...     Step 3. Adjust traffic with UEs to decrease load on PSGRP-1 below lbpsMinLoad
    ...             Adjust traffic with UEs to decrease load on PSGRP-2 below lbpsLastCellMinLoad
    ...             Adjust traffic with UEs to decrease load on PSGRP-3 below lbpsRTXMinLoad but above lbpsMinLoad
    ...     Expected result:
    ...             After next 6 to 6.5 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = energySaving    (change)
    ...             cell_7 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = energySaving    (change)
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 4. Wait until cell_3,8 PS period ends (20 minutes from start_time)
    ...     Expected result:
    ...             After max 1 minute:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = energySaving
    ...             cell_7 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_3 energySavingState = notEnergySaving without cell reset    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 5. Adjust traffic with UEs (detach) to decrease load on PSGRP-1 below lbpsLastCellMinLoad
    ...             Adjust traffic with UEs to decrease load on PSGRP-2,3 below lbpsLastCellRTXMinLoad and above lbpsMinLoad
    ...             Cell_4,8 PS period starts (25 minutes from start_time)
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = energySaving
    ...             cell_7 energySavingState = energySaving    (change)
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_5 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...
    ...     Step 6. Adjust traffic with UEs to decrease load on PSGRP-2,3 below lbpsMinLoad
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = energySaving
    ...             cell_7 energySavingState = energySaving
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = energySaving    (change)
    ...             cell_8 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_5 energySavingState = energySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...
    ...     Step 7. Adjust traffic with UEs (detach) to decrease load on PSGRP-2 below lbpsLastCellMinLoad
    ...             Adjust traffic with UEs to decrease load on PSGRP-3 below lbpsMinLoad
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = energySaving
    ...             cell_8 energySavingState = energySaving    (change)
    ...             cell_5 energySavingState = energySaving
    ...             cell_6 energySavingState = energySaving    (change)
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...
    ...     Step 8. Wait until cell_4,8 PS period ends (20+25=45 minutes from start_time)
    ...     Expected result:
    ...             After max 1 minute:
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = notEnergySaving    (change)
    ...             cell_8 energySavingState = notEnergySaving    (change)
    ...             cell_5 energySavingState = energySaving
    ...             cell_6 energySavingState = energySaving
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...
    ...     POSTCONDITIONS:
    ...             cell_1 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_2 energySavingState = energySaving
    ...             cell_7 energySavingState = energySaving
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = energySaving
    ...             cell_6 energySavingState = energySaving
    ...             cell_9 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...
    ...     Step 9. (A-e-5) Check and save current system time = start_time,
    ...             PSGRP-2,3  lbpsPeriodList= Day/Hour/Minute equals saved system time + 2 minutes,  lbpsDuration= 20min
    ...             cell_3  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time + 2 minutes,  lbpsCellDuration= 20min
    ...             Change lbpsUseExtConfig for cell_3 to true, for cell_4,5,6,8,9 to false
    ...     Expected result:
    ...             After max 1 minute:
    ...             cell_3 energySavingState = notEnergySaving
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = notEnergySaving
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 10. (A-e-5) Set traffic with UEs on PSGRP-2,3 below lbpsMinLoad
    ...     Expected result:
    ...             After 6 to 6.5 minutes from period start:
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = energySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
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
    ...
    ...  REFERENCES:
    ...      https://gates.nsn-net.net/view/00026f09#o=0
    ...
    ...  HISTORY:
    ...     [19.05.2023] - First draft
    ...     [--.--.2023] - Version after review

    Prepare test environment for CB010397-A-e-1a
    Log To Console    -------- Step 1 --------
    execute uex command    ue_attach id=11..12 cell=7
    execute uex command    ue_attach id=13..14 cell=8
    execute uex command    ue_attach id=15..16 cell=9
    execute uex command    trf_data_start ue=11..14 qci=9 Mbps=4 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=15..16 qci=9 kbps=1 dir=dl protocol=udp size=100 trf_id=1 interval=500
    Set Power Saving Period start for PSGRP-1,2,3 to current time
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into energySaving State
    Cell6 Enter Into notEnergySaving State
    Log To Console    -------- Step 2 --------
    #Adjust load on PSGRP-1 below lbpsLastCellRTXMinLoad but above lbpsMinLoad
    #Adjust load on PSGRP-2 below lbpsLastCellRTXMinLoad but above lbpsMinLoad
    execute uex command    trf_data_stop ue=11..16 qci=9
    execute uex command    trf_data_start ue=11..14 qci=9 Mbps=2 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    #    #Adjust traffic with UEs to increase load on PSGRP-3 above lbpsMaxLoad
    execute uex command    trf_data_start ue=15..16 qci=9 Mbps=10 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into reducedEnergySaving State
    Cell8 Enter Into reducedEnergySaving State
    Cell9 Enter Into notEnergySaving State


    Log To Console    -------- Step 3 --------
    #Adjust traffic with UEs to decrease load on PSGRP-1 below lbpsMinLoad
    execute uex command    trf_data_stop ue=11..16 qci=9
    execute uex command    trf_data_start ue=11..12 qci=9 kbps=500 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    #Adjust traffic with UEs to decrease load on PSGRP-3 below lbpsRTXMinLoad but above lbpsMinLoad
    execute uex command    trf_data_start ue=15..16 qci=9 Mbps=3 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    ue_detach id=13..14
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell2 Enter Into energySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into reducedEnergySaving State
    Cell8 Enter Into energySaving State
    Cell9 Enter Into notEnergySaving State

    Log To Console    -------- Step 4 --------
    #Wait until cell_3,8 PS period ends (20 minutes from start_time)
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into energySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into reducedEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    Log To Console    -------- Step 5 --------
    #Adjust traffic with UEs (detach) to decrease load on PSGRP-1 below lbpsLastCellMinLoad
    # Cell_4,8 PS period starts (25 minutes from start_time)
    execute uex command    ue_detach id=11..12
    execute uex command    ue_attach id=13..14 cell=8 rate=2
#    execute uex command    trf_data_stop ue=13..16 qci=9
    execute uex command    trf_data_stop ue=15..16 qci=9
    execute uex command    trf_data_start ue=13..14 qci=9 Mbps=3 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=15..16 qci=9 Mbps=2 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell2 Enter Into energySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into energySaving State
    Cell8 Enter Into reducedEnergySaving State
    Cell9 Enter Into reducedEnergySaving State

    Log To Console    -------- Step 6 --------
    #Adjust traffic with UEs to decrease load on PSGRP-2,3 below lbpsMinLoad
    execute uex command    trf_data_stop ue=13..16 qci=9
    execute uex command    trf_data_start ue=13..16 qci=9 kbps=500 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into energySaving State
    Cell2 Enter Into energySaving State
    Cell4 Enter Into energySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into energySaving State
    Cell8 Enter Into reducedEnergySaving State
    Cell9 Enter Into reducedEnergySaving State

    Log To Console    -------- Step 7 --------
    #Adjust traffic with UEs (detach) to decrease load on PSGRP-2 below lbpsLastCellMinLoad
    #Adjust traffic with UEs to decrease load on PSGRP-3 below lbpsMinLoad
    execute uex command    ue_detach id=13..14
    execute uex command    trf_data_stop ue=15..16 qci=9
    execute uex command    trf_data_start ue=15..16 qci=9 kbps=100 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into energySaving State
    Cell4 Enter Into energySaving State
    Cell6 Enter Into energySaving State
    Cell8 Enter Into energySaving State
    Cell9 Enter Into reducedEnergySaving State

    Log To Console    -------- Step 8 --------
    #Wait until cell_4,8 PS period ends (10+15=25 minutes from start_time)
    check cell stats
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into energySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into energySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into reducedEnergySaving State
    execute uex command    ue_detach id=15..16

    Log To Console    -------- Step 9 --------
    #Set lbpsUseExtConfig for cells 4,5,6,8,9 to false
    OnlineParamChange    ${Disable_lbpsUseExtConfig}
    Set Power Saving Period start for PSGRP-2,3 and cell-3 to start in 2min
    execute uex command    ue_attach id=13..14 cell=8 rate=2
    execute uex command    ue_attach id=15..16 cell=9 rate=2
    execute uex command    trf_data_start ue=13..16 qci=9 Mbps=10 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    Log To Console    -------- Step 10 --------
    #Set traffic with UEs on PSGRP-2,3 below lbpsMinLoad
    execute uex command    trf_data_stop ue=13..16 qci=9
    execute uex command    trf_data_start ue=13..14 qci=9 Mbps=2 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=15..16 qci=9 Mbps=1 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell5 Enter Into energySaving State

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=CB010397-A-e    cfg=cus.yaml
    create alias

create alias
    create ue alias    UE_1    ue_id=1    id_type=cus
    create ue alias    UE_2    ue_id=2    id_type=cus
    create ue alias    UE_3    ue_id=3    id_type=cus
    create ue alias    UE_4    ue_id=4    id_type=cus
    create ue alias    UE_5    ue_id=5    id_type=cus
    create ue alias    UE_6    ue_id=6    id_type=cus
    create ue alias    UE_21    ue_id=11    id_type=cus
    create ue alias    UE_22    ue_id=12    id_type=cus
    create ue alias    UE_23    ue_id=13    id_type=cus
    create cell alias    CELL_1    cell_id=1   cell_type=cus
    create cell alias    CELL_2    cell_id=2   cell_type=cus
    create cell alias    CELL_3    cell_id=3   cell_type=cus
    create cell alias    CELL_4    cell_id=4   cell_type=cus
    create cell alias    CELL_5    cell_id=5   cell_type=cus
    create cell alias    CELL_6    cell_id=6   cell_type=cus
    create cell alias    CELL_7    cell_id=7   cell_type=cus
    create cell alias    CELL_8    cell_id=8   cell_type=cus
    create cell alias    CELL_9    cell_id=9   cell_type=cus

Prepare test environment for CB010397-A-e-1a
    Create New Plan
    ${planned_time}=  get psgrp planned time  0  0
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellDuration[0]=90          enb_id=1

    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeHour[1]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeMinute[1]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellDuration[1]=90          enb_id=1

    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeHour[2]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeMinute[2]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellDuration[2]=90          enb_id=1

    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellDuration[0]=90           enb_id=1

    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeHour[1]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeMinute[1]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellDuration[1]=90           enb_id=1

    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeHour[2]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeMinute[2]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellDuration[2]=90           enb_id=1

    #cell-3
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[0]=10           enb_id=1

    #cell-4
    ${planned_time}=  get psgrp planned time  0  15
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[1]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[1]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[1]=10           enb_id=1

    #cell-8 period 1
    ${planned_time}=  get psgrp planned time  0  0
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[2]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[2]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[2]=10           enb_id=1

    #cell-8 period 2
    ${planned_time}=  get psgrp planned time  0  15
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[3]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[3]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[3]=10           enb_id=1

    Apply planned changes
    Log To Console    TC CB010397-A-e-1 started

check cell stats
    execute uex command    get_cell_stats id=7 type=dl_mac unit=Mbps
    execute uex command    get_cell_stats id=8 type=dl_mac unit=Mbps
    execute uex command    get_cell_stats id=9 type=dl_mac unit=Mbps

Set Power Saving Period start for PSGRP-1,2,3 to current time
   Create New Plan
    Edit PSGRP-1 period-1 time to current time + 0h0min offset and duration: 60min
    Edit PSGRP-2 period-1 time to current time + 0h0min offset and duration: 60min
    Edit PSGRP-3 period-1 time to current time + 0h0min offset and duration: 60min
    Apply planned changes


Set Power Saving Period start for PSGRP-2,3 and cell-3 to start in 2min
   Create New Plan
    ${planned_time}=  get psgrp planned time  0  2
    Edit PSGRP-2 period-1 time to current time + 0h2min offset and duration: 60min
    Edit PSGRP-3 period-1 time to current time + 0h2min offset and duration: 60min
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[0]=10           enb_id=1
    Apply planned changes

Set Power Saving Period start for cell-3 to start in 2min
    Create New Plan
    ${planned_time}=  get psgrp planned time  0  2
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[0]=10           enb_id=1
    Apply planned changes


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
#    Cells Should Be Onair    check_sib=${False}

Edit PSGRP-${PSGRP} period-${period} time to current time + ${hours_offset}h${minutes_offset}min offset and duration: ${duration}min
    ${planned_time}=  get psgrp planned time  ${hours_offset}  ${minutes_offset}
    Log to console  changing PSGRP-${PSGRP} period-${period} time to ${planned_time}, duration: ${duration}min
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDayOfWeek=${planned_time}[0]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeHour=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeMinute=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDuration=${duration}           enb_id=1


Cell${number} Enter Into notEnergySaving State
    ${cell_info}  Get Cell Info  ${number}
    ${SWITCH_TIMEOUT}  Set Variable If  ${cell_info["pipes_num"]}==8  ${SWITCHON_TIMEOUT_8PIPES}  ${SWITCHON_TIMEOUT_4PIPES_2PIPES}
    Wait Until Keyword Succeeds  ${SWITCH_TIMEOUT}  10 s  Energy Saving State Should Be  ${number}  notEnergySaving
    ${onair}  Run Keyword And Return Status  Query Infomodel  //CELL_M-${number} is [stateInfo.proceduralState=OnAirDone]
