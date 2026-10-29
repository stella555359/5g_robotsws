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
...             Pawel Nogiec            pawel.nogiec@nokia.com
...         EFS:
...             Marcin Biniek           marcin.biniek@nokia.com
...
...     REFERENCES:
...         CFAM:   https://gates.nsn-net.net/view/00026f09#o=0
...         FTS:    https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
...                 Doc.aspx?sourcedoc=%7B226114E7-651D-49C2-A67B-6BE39D7BFD1F%7D&file=FTS_HL_CB010397_MIMO%20muting%20and%20cell%
...                 20switch%20off%20cohabitation%20during%20same%20time%20window%20for%20LTE.docx&action=default&mobileredirect=
...                 true&cid=da8f292d-5019-4719-9ec0-5620221e0135
...
...         HISTORY:
...             [13.11.2023] - First draft
...             [22.11.2023] - Version after review

*** Variables ***
@{lockcell4}
...    LNCEL-4:administrativeState=locked
@{unlockcell4}
...    LNCEL-4:administrativeState=unlocked

*** Test Cases ***
CB010397-A-c-robustness - lock and block cells during switchingOff with CB008800 cell extended config and CB008745 activated
    [Documentation]
    ...     DESCRIPTION:
    ...     This test case verifies robust eNB behaviour when some cells are blocking and locking during switchingOff state.
    ...        SR003080 Power saving with online TX path switching off,
    ...        CB008800 'Extended Cell Switch Off Method' with cell level power saving parameters configured
    ...        and CB008746 with new calculation methods are enabled.
    ...
    ...     PRECONDITIONS:
    ...     eNB:
    ...         actLBPowerSaving    =   true        (LTE1103)
    ...         actLBRTXPowerSaving =   true        (LTE1203)
    ...         actMixedSOMethod    =   true        (CB010397)
    ...         actExtCellSOMethod  =   true        (CB008800)
    ...         actOnlineTXSwitch   =   true        (SR003080)
    ...         actLbpsCtrlLogicEnh =   true        (CB008745)
    ...
    ...         +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------+
    ...         | parameter        \     MOC: | PSGRP-1                           | PSGRP-2                           | PSGRP-3                     |
    ...         +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------+
    ...         | lbpsCellList \ lnCelId      |     1     |     2     |     7     |     3     |     4     |     8     |    5    |    6    |    9    |
    ...         +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------+
    ...         | lbpsCellSOOrder             |     50    |    100    |    100    |     50    |    100    |    100    |    50   |    100  |   100   |
    ...         | lbpsUseExtConfig            |    true   |   true    |   true    |    true   |   true    |   true    |   true  |   true  |  true   |
    ...         +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------+
    ...         | lbpsSOMethod                | Legacy Mixed Switch Off           | Legacy Mixed Switch Off           | Legacy Mixed Switch Off     |
    ...         | lbpsPeriodList [Day/Hr/Min] | Monday/01/00                      | Monday/01/00                      | Monday/01/00                |
    ...         | lbpsDuration      [min]     | 1                                 | 1                                 | 1                           |
    ...         | lbpsMaxLoad                 | 25                                | 25                                | 25                          |
    ...         | lbpsMinLoad                 | 10                                | 10                                | 10                          |
    ...         | lbpsRTXMaxLoad              | 25                                | 25                                | 25                          |
    ...         | lbpsRTXMinLoad              | 10                                | 10                                | 10                          |
    ...         | lbpsLastCellMinLoad         | 10                                | 10                                | 10                          |
    ...         | lbpsLastCellRTXMinLoad      | 10                                | 10                                | 10                          |
    ...         | lbpsLastCellSOEnabled       | true                              | true                              | true                        |
    ...         | lbpsLoadCalcMethod          | Max(G_N_comb, P)                  | Max(G_N_comb, P)                  | Max(G_N_comb, P)            |
    ...         | lbpsSOffTrRule              | SlidingAverage                    | SlidingAverage                    | SlidingAverage              |
    ...         | lbpsSOnTrRule               | SlidingAverage                    | SlidingAverage                    | SlidingAverage              |
    ...         | lbpsMonWinForCellSOff       | 60                                | 60                                | 60                          |
    ...         | lbpsMonWinForCellSOn        | 60                                | 60                                | 60                          |
    ...         | lbpsMonWinForRtxSOff        | 60                                | 60                                | 60                          |
    ...         | lbpsMonWinForRtxSOn         | 60                                | 60                                | 60                          |
    ...         +-----------------------------+-----------------------------------------------------------------------+-----------------------------+
    ...         | lbpsCelPeriodList \ LnCelId |     1     |     2     |     7     |     3     |     4     |     8     |   5   |     6    |     9    |
    ...         +-----------------------------+-----------------------------------+-----------------------------------+-----------------------------+
    ...         | lbpsCellDayOfWeek           |           |  everyDay |  everyDay |           |  everyDay |  everyDay |       | everyDay | everyDay |
    ...         | lbpsCellDuration            |           |     1     |     1     |           |     1     |     1     |       |    1     |    1     |
    ...         | lbpsCellSOMethod            |           |  Cell SO  |  Cell SO  |           |  Cell SO  |  Cell SO  |       | Cell SO  | Cell SO  |
    ...         | lbpsCellStartTimeHour       |           |     1     |     1     |           |     1     |     1     |       |    1     |    1     |
    ...         | lbpsCellStartTimeMinute     |           |     0     |     0     |           |     0     |     0     |       |    0     |    0     |
    ...         +-----------------------------+-----------------------------------------------------------------------+-----------------------------+
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
    ...                cell_1:  UE_1, UE_2
    ...                cell_3:  UE_3, UE_4
    ...                cell_5:  UE_5, UE_6
    ...             Start traffic with UEs to set load on PSGRP-1,2,3 below lbpsLastCellMinLoad;
    ...             Check and save current system time = start_time,
    ...             PSGRP-1,2,3  lbpsPeriodList= Day/Hour/Minute equals saved system time,  lbpsDuration= 30min
    ...             cell_2,7  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 30min
    ...             cell_6,9  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 30min
    ...             cell_4,8  lbpsCelPeriodList=  Day/Hour/Minute equals saved system time,  lbpsCellDuration= 30min
    ...    
    ...     Step 2. Wait up to 1.5 min until switchingOff state:
    ...                 cell_1 energySavingState = notEnergySaving
    ...                 cell_2 energySavingState = switchingOff    (change)
    ...                 cell_7 energySavingState = switchingOff    (change)
    ...                 cell_3 energySavingState = notEnergySaving
    ...                 cell_4 energySavingState = switchingOff    (change)
    ...                 cell_8 energySavingState = switchingOff    (change)
    ...                 cell_5 energySavingState = notEnergySaving
    ...                 cell_6 energySavingState = switchingOff    (change)
    ...                 cell_9 energySavingState = switchingOff    (change)
    ...             Block cell_2,6,9  during switchingOff state
    ...             Lock cell_4 during switchingOff state
    ...     Expected result:
    ...             After 1 minute:
    ...             cell_1  unlocked, unblocked
    ...             cell_2  unlocked, blocked (change)
    ...             cell_7  unlocked, unblocked
    ...             cell_3  unlocked, unblocked
    ...             cell_4  locked (change), unblocked
    ...             cell_8  unlocked, unblocked
    ...             cell_5  unlocked, unblocked
    ...             cell_6  unlocked, blocked (change)
    ...             cell_9  unlocked, blocked (change)
    ...    
    ...             cell_1  energySavingState = notEnergySaving
    ...             cell_2  energySavingState = notEnergySaving    (change)
    ...             cell_7  energySavingState = energySaving    (change)
    ...             cell_3  energySavingState = notEnergySaving
    ...             cell_4  energySavingState = notEnergySaving    (change)
    ...             cell_8  energySavingState = energySaving    (change)
    ...             cell_5  energySavingState = notEnergySaving
    ...             cell_6  energySavingState = notEnergySaving    (change)
    ...             cell_9  energySavingState = notEnergySaving    (change)
    ...    
    ...     Step 3. Adjust traffic with UEs to increase load on PSGRP-1,2,3 above lbpsMaxLoad
    ...             Unblock cell_2,6,9 and unlock cell_4
    ...     Expected result:
    ...             After 1.5 minutes:
    ...             cell_1  unlocked, unblocked
    ...             cell_2  unlocked, unblocked (change)
    ...             cell_7  unlocked, unblocked
    ...             cell_3  unlocked, unblocked
    ...             cell_4  unlocked (change), unblocked
    ...             cell_8  unlocked, unblocked
    ...             cell_5  unlocked, unblocked
    ...             cell_6  unlocked, unblocked (change)
    ...             cell_9  unlocked, unblocked (change)
    ...    
    ...             cell_1  energySavingState = notEnergySaving
    ...             cell_2  energySavingState = notEnergySaving
    ...             cell_7  energySavingState = notEnergySaving    (change)
    ...             cell_3  energySavingState = notEnergySaving
    ...             cell_4  energySavingState = notEnergySaving
    ...             cell_8  energySavingState = notEnergySaving    (change)
    ...             cell_5  energySavingState = notEnergySaving
    ...             cell_6  energySavingState = notEnergySaving
    ...             cell_9  energySavingState = notEnergySaving
    ...    
    ...     Step 4. Attach UEs to:
    ...                cell_2:  UE_11,  cell_7:  UE_12
    ...                cell_4:  UE_13,  cell_8:  UE_14
    ...                cell_6:  UE_15,  cell_9:  UE_16
    ...             Start traffic with these UEs
    ...     Expected result:
    ...             Attach is possible, traffic is sending
    ...             After 1.5 minutes:
    ...             cell_1  energySavingState = notEnergySaving
    ...             cell_2  energySavingState = notEnergySaving
    ...             cell_7  energySavingState = notEnergySaving
    ...             cell_3  energySavingState = notEnergySaving
    ...             cell_4  energySavingState = notEnergySaving
    ...             cell_8  energySavingState = notEnergySaving
    ...             cell_5  energySavingState = notEnergySaving
    ...             cell_6  energySavingState = notEnergySaving
    ...             cell_9  energySavingState = notEnergySaving
    ...
    ...     Step 5. Stop traffic with all UEs
    ...     Expected result:
    ...             After 2.5 minutes:
    ...             cell_1  energySavingState = notEnergySaving
    ...             cell_2  energySavingState = energySaving    (change)
    ...             cell_7  energySavingState = energySaving    (change)
    ...             cell_3  energySavingState = notEnergySaving
    ...             cell_4  energySavingState = energySaving    (change)
    ...             cell_8  energySavingState = energySaving    (change)
    ...             cell_5  energySavingState = notEnergySaving
    ...             cell_6  energySavingState = energySaving    (change)
    ...             cell_9  energySavingState = energySaving    (change)
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
    ...             Pawel Nogiec        pawel.nogiec@nokia.com
    ...
    ...  REFERENCES:
    ...      https://gates.nsn-net.net/view/00026f09#o=0
    ...
    ...  HISTORY:
    ...     [13.11.2023] - First draft
    ...     [22.11.2023] - Version after review

    [Tags]    c-robustness
    #  Step 1. Attach UEs
    #          Start traffic
    #          Set  lbpsPeriodList and lbpsCelPeriodList
    execute uex command    ue_attach id=1 cell=1
    execute uex command    ue_attach id=2 cell=1
    execute uex command    ue_attach id=3 cell=3
    execute uex command    ue_attach id=4 cell=3
    execute uex command    ue_attach id=5 cell=5
    execute uex command    ue_attach id=6 cell=5
    execute uex command    trf_data_start ue=1..6 dir=dl protocol=udp kbps=200 qci=9 size=1400 trf_id=1 interval=500
    execute uex command    get_cell_stats id=1 type=dl_mac unit=Mbps
    execute uex command    get_cell_stats id=3 type=dl_mac unit=Mbps
    execute uex command    get_cell_stats id=5 type=dl_mac unit=Mbps
    Set Power Saving Period start for PSGRP-1,2,3 to 1, cell_4,8 to 1 minutes from start and 30 minutes duration

    # Step 2. Wait up to 1.5 min until switchingOff state:
    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell2 Enter Into SwitchingOff State
    Cell4 Enter Into SwitchingOff State
    Cell6 Enter Into SwitchingOff State
    Cell7 Enter Into SwitchingOff State
    Cell8 Enter Into SwitchingOff State
    Cell9 Enter Into SwitchingOff State
    Block Cell2
    Block Cell6
    Block Cell9
#    Block Cells [2,6,9] without verification
    Lock Cell-4
    check_status_of_cells    timeout=60
    ...  LNCEL-1=unlocked,unblocked,enabled  LNCEL-2=unlocked,blocked,disabled   LNCEL-7=unlocked,unblocked,disabled
    ...  LNCEL-3=unlocked,unblocked,enabled  LNCEL-4=locked,unblocked,disabled   LNCEL-8=unlocked,unblocked,disabled
    ...  LNCEL-5=unlocked,unblocked,enabled  LNCEL-6=unlocked,blocked,disabled   LNCEL-9=unlocked,blocked,disabled
    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into energySaving State
    Cell8 Enter Into energySaving State
    Cell9 Enter Into notEnergySaving State

    # Step 3. Adjust traffic with UEs to increase load on PSGRP-1,2,3 above lbpsMaxLoad
    #         Unblock cell_2,6,9 and unlock cell_4
    execute uex command    trf_data_stop ue=1..6 qci=9
    execute uex command    trf_data_start ue=1..6 qci=9 Mbps=15 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    Unblock Cell-2
    Unblock Cell-6
    Unblock Cell-9
    Unlock Cell-4
    check_status_of_cells    timeout=15    interval=5
    ...  LNCEL-1=unlocked,unblocked,enabled  LNCEL-2=unlocked,unblocked          LNCEL-7=unlocked,unblocked
    ...  LNCEL-3=unlocked,unblocked,enabled  LNCEL-4=unlocked,unblocked          LNCEL-8=unlocked,unblocked
    ...  LNCEL-5=unlocked,unblocked,enabled  LNCEL-6=unlocked,unblocked          LNCEL-9=unlocked,unblocked
#    Cell1 Enter Into notEnergySaving State
#    Cell3 Enter Into notEnergySaving State
#    Cell5 Enter Into notEnergySaving State
#    Cell2 Enter Into notEnergySaving State
#    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
#    Cell7 Enter Into notEnergySaving State
#    Cell8 Enter Into notEnergySaving State
#    Cell9 Enter Into notEnergySaving State

    # Step 4. Attach UEs:
    execute uex command    ue_attach id=11 cell=2
    execute uex command    ue_attach id=12 cell=7
    execute uex command    ue_attach id=13 cell=4
    execute uex command    ue_attach id=14 cell=8
    execute uex command    ue_attach id=15 cell=9
    execute uex command    trf_data_start ue=11..15 qci=9 kbps=1000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

    # Step 5. Stop traffic with all UEs
    execute uex command    trf_data_stop ue=1..6 qci=9
    execute uex command    trf_data_stop ue=11..15 qci=9
    execute uex command    ue_detach id=11..15
    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell2 Enter Into energySaving State
    Cell4 Enter Into energySaving State
    Cell6 Enter Into energySaving State
    Cell7 Enter Into energySaving State
    Cell8 Enter Into energySaving State
    Cell9 Enter Into energySaving State


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=CB010397-A-c
    create alias
    ${V_1}    catenate
    ...    ue_param id=1-20 release=15 category=12 category_dl=19 category_ul=15 supported_bands=1,2,3,38,40,41
    ...    pdcp_sn_extension=on ca_supported_bands=2:a:a|38:a:a|40:a:a
    ...    fgi=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
    execute uex command    ${V_1}

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
    Create MME alias    MME_1    mme_id=1    id_type=wts

Cell${number} Enter Into switchingOff State
    ${cell_info}    Get Cell Info    ${number}
    ${SWITCH_TIMEOUT}    Set Variable If    ${cell_info["pipes_num"]}==8    ${SWITCHOFF_TIMEOUT_8PIPES}    ${SWITCHOFF_TIMEOUT_4PIPES_2PIPES}
    Wait Until Keyword Succeeds    ${SWITCH_TIMEOUT}    10 s    Energy Saving State Should Be    ${number}    switchingOff
    ${active_pipes_exp}    Set Variable If    ${cell_info["pipes_num"]}==2    1    2

Lock Cell-4
    delta commission parameters    ${lockcell4}

Unlock Cell-4
    delta commission parameters    ${unlockcell4}

Set Power Saving Period start for PSGRP-1,2,3 to ${offset}, cell_4,8 to ${offset_2} minutes from start and ${duration} minutes duration
    Create New Plan
    Edit PSGRP-1 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Edit PSGRP-2 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Edit PSGRP-3 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    ${planned_time}=  get psgrp planned time  0  ${offset}
    ${planned_time_2}=  get psgrp planned time  0  ${offset_2}
    Log to console  changing lbpsCelPeriodList time to ${planned_time}, duration: ${duration}min
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellDuration[0]=${duration}          enb_id=1

    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeHour[1]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellStartTimeMinute[1]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-1  lbpsCelPeriodList.lbpsCellDuration[1]=${duration}          enb_id=1

    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellDuration[0]=${duration}           enb_id=1

    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeHour[1]=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellStartTimeMinute[1]=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-3  lbpsCelPeriodList.lbpsCellDuration[1]=${duration}           enb_id=1

    Log to console  changing lbpsCelPeriodList time to ${planned_time_2}, duration: ${duration}min
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[0]=${planned_time_2}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[0]=${planned_time_2}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[0]=${duration}           enb_id=1

    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeHour[1]=${planned_time_2}[1]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellStartTimeMinute[1]=${planned_time_2}[2]    enb_id=1
    Edit planned object attributes    PSGRP-2  lbpsCelPeriodList.lbpsCellDuration[1]=${duration}           enb_id=1

    Apply planned changes

Edit PSGRP-${PSGRP} period-${period} time to current time + ${hours_offset}h${minutes_offset}min offset and duration: ${duration}min
    ${planned_time}=  get psgrp planned time  ${hours_offset}  ${minutes_offset}
    Log to console  changing PSGRP-${PSGRP} period-${period} time to ${planned_time}, duration: ${duration}min
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDayOfWeek=${planned_time}[0]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeHour=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeMinute=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDuration=${duration}           enb_id=1


Unblock Cell-${number}
  ${nrcel_id}  Get cell id by configuration id  LTE  ${number}
  Unblock_cell  ${nrcel_id}
  Assert  NRCEL  ${nrcel_id}  blockingState=Unblocked

