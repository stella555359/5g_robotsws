*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Search Btslog And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS23R4    owner-annie.nie    PY39
Library    CB010397.py
Resource          testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/resources/DevHZ5_resource.robot
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
...             Piotr Chyczewski        piotr.chyczewski@nokia.com
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
...                 [24.04.2023] - First draft
...                 [11.05.2023] - Version after review

*** Variables ***
${sleep_time}    2
@{A_a_enable}
...    LNBTS:actLBPowerSaving=true
...    LNBTS:actLBRTXPowerSaving=true
...    LNBTS:actMixedSOMethod=true
...    LNBTS:actOnlineTXSwitch=true
...    PSGRP-1:lbpsSOMethod=Cell Switch Off
...    PSGRP-2:lbpsSOMethod=TX Switch Off
...    PSGRP-3:lbpsSOMethod=Legacy Mixed Switch Off

@{ENABLE_lbpsLastCellSOEnabled}
...    PSGRP-1:lbpsLastCellSOEnabled=true
...    PSGRP-2:lbpsLastCellSOEnabled=true
...    PSGRP-3:lbpsLastCellSOEnabled=true

@{Unsuspend_PSGRP}
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended
...    PSGRP-2:lbpsPeriodList:lbpsSuspended=notSuspended
...    PSGRP-3:lbpsPeriodList:lbpsSuspended=notSuspended

@{Suspend_PSGRP}
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=suspended
...    PSGRP-2:lbpsPeriodList:lbpsSuspended=suspended
...    PSGRP-3:lbpsPeriodList:lbpsSuspended=suspended

@{Disable_lbpsLastCellSOEnabled}
...    PSGRP-1:lbpsLastCellSOEnabled=false
...    PSGRP-2:lbpsLastCellSOEnabled=false
...    PSGRP-3:lbpsLastCellSOEnabled=false

@{Disable_Flag}
...    LNBTS:actExtCellSOMethod=false
...    LNBTS:actLBPowerSaving=false
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS:actMixedSOMethod=false
...    LNBTS:actOnlineTXSwitch=false

@{PARAMS_IN_SWCONFIG}
#...    ${TEnbcRadLowLoadSwitchOffDelay}=3       # *10 secs
...    ${TEnbcRadLowLoadSwitchOffDelay}=2       # *10 secs
...    ${TEnbcRadHighLoadSwitchOnDelay}=3     # *10 secs
...    0x2f0000=1     #LIM debug
...    0x730011=1    # ERadIMS_Essential
...    0x300000=1     #mctrl
...    0x300001=1     #mctrl
...    0x30001C=1     #mctrl

${TEnbcRadLowLoadSwitchOffDelay}    0x110016    # *10 secs
${TEnbcRadHighLoadSwitchOnDelay}    0x110017    # *10 secs


*** Test Cases ***
CB010397-A-a-1 - Legacy SO methods - SR003080 enabled, emergency call, ETWS interaction
    [Documentation]
    ...     DESCRIPTION:
    ...     This test case verifies legacy PSGRP Switch Off methods with lbpsLastCellSOEnabled = false
    ...     Power Saving features are triggered by feature flag, PSGRP suspend and traffic on cell, blocked by emergency call, ETWS messages.
    ...
    ...     PRECONDITIONS:
    ...     eNB:
    ...         actLBPowerSaving    =   true        (LTE1103)
    ...         actLBRTXPowerSaving =   true        (LTE1203)
    ...         actOnlineTXSwitch   =   true        (SR003080)
    ...         actMixedSOMethod    =   false       (CB010397)
    ...         actExtCellSOMethod  =   false       (CB008800)
    ...         actLbpsCtrlLogicEnh =   false       (CB008745)
    ...         actETWS             =   true
    ...         actCMAS             =   false
    ...         etwsPrimNotifBcDur  =   450 (7.5 minutes)

    ...         +------------------------+--------------------------------+--------------------------------+--------------------------------+
    ...         | parameter     \   MOC: | PSGRP-1                        | PSGRP-2                        | PSGRP-3                        |
    ...         +------------------------+--------------------------------+--------------------------------+--------------------------------+
    ...         | lbpsCellList           | cell_1 (lbpsCellSOOrder= 10),  | cell_3 (lbpsCellSOOrder= 30)   | cell_5 (lbpsCellSOOrder= 50)   |
    ...         |                        | cell_2 (lbpsCellSOOrder= 100)  | cell_4 (lbpsCellSOOrder= 100)  | cell_6 (lbpsCellSOOrder= 100)  |
    ...         |                        | cell_7 (lbpsCellSOOrder= 100)  | cell_8 (lbpsCellSOOrder= 100)  | cell_9 (lbpsCellSOOrder= 100)  |
    ...         | lbpsSOMethod           | Cell Switch Off                | Tx Switch Off                  | Legacy Mixed Switch Off        |
    ...         | lbpsPeriodList         | Monday/01/00 [Day/Hour/Minute] | Monday/01/00 [Day/Hour/Minute] | Monday/01/00 [Day/Hour/Minute] |
    ...         | lbpsDuration           | 1            [min]             | 1            [min]             | 1            [min]             |
    ...         | lbpsMaxLoad            | 25                             | 25                             | 25                             |
    ...         | lbpsMinLoad            | 10                             | 10                             | 10                             |
    ...         | lbpsRTXMaxLoad         | 30                             | 30                             | 30                             |
    ...         | lbpsRTXMinLoad         | 15                             | 15                             | 15                             |
    ...         | lbpsLastCellMinLoad    | 5                              | 5                              | 5                              |
    ...         | lbpsLastCellRTXMinLoad | 5                              | 5                              | 5                              |
    ...         | lbpsLastCellSOEnabled  | false                          | false                          | false                          |
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
    ...     Step 1. Enable feature CB010397 actMixedSOMethod,
    ...             PSGRP-1  lbpsSOMethod=   Cell Switch Off
    ...                      lbpsPeriodList= Day/Hour/Minute equals current system time
    ...                      lbpsDuration=   60min
    ...             PSGRP-2  lbpsSOMethod=   Tx Switch Off
    ...                      lbpsPeriodList= Day/Hour/Minute equals current system time
    ...                      lbpsDuration=   60min
    ...             PSGRP-3  lbpsSOMethod=   Legacy Mixed Switch Off
    ...                      lbpsPeriodList= Day/Hour/Minute equals current system time
    ...                      lbpsDuration=   60min
    ...     Expected result:
    ...             After max 7 minutes:
    ...             cell_1 energySavingState = energySaving    (change)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = energySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 2. Change lbpsSuspended = suspended for all PSGRP.lbpsPeriodList
    ...     Expected result:
    ...             After max 3 minutes all cells shall have energySavingState = notEnergySaving    (change)
    ...
    ...     Step 3. Set PSGRP-1,2,3 lbpsLastCellSOEnabled to true
    ...             Change lbpsSuspended = notSuspended for all PSGRP.lbpsPeriodList.
    ...             Send ETWS messages on cell_1, cell_3 and cell_5 for 450 seconds (7.5 minutes) (etwsPrimNotifBcDur)
    ...     Expected result:
    ...             After 6 to 7 minutes all cells shall have energySavingState = notEnergySaving
    ...
    ...     Step 4. Attach 1 UE per cell with establishment_cause=emergency to cell_1, cell_3 and cell_5 and prevent it from going to idle
    ...             starting low (~10) kbps traffic with QCI=1 VoLTE bearer (before ETWS messages ends)
    ...     Expected result:
    ...             After 6 to 7 minutes all cells shall have energySavingState = notEnergySaving
    ...
    ...     Step 5. Set PSGRP-1,2,3 lbpsLastCellSOEnabled to false
    ...             Detach all UEs ending emergency call.
    ...             Send ETWS messages on cell_1, cell_3 and cell_5 for 450 seconds (7.5 minutes) (etwsPrimNotifBcDur)
    ...     Expected result:
    ...             After 6 to 7 minutes all cells shall have energySavingState = notEnergySaving
    ...
    ...     Step 6. Attach 1 UE per cell with establishment_cause=emergency to cell_1, cell_3 and cell_5 and prevent it from going to idle
    ...             starting low (~10) kbps traffic with QCI=1 VoLTE bearer (before ETWS messages ends)
    ...     Expected result:
    ...             After 6 to 7 minutes all cells shall have energySavingState = notEnergySaving
    ...
    ...     Step 7. Detach all UEs ending emergency call.
    ...     Expected result:
    ...             After max 7 minutes:
    ...             cell_1 energySavingState = energySaving    (change)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = energySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 8. Attach UEs to:
    ...                 PSGRP-1:  cell_2:  UE_1, UE_2
    ...                 PSGRP-2:  cell_4:  UE_3, UE_4
    ...                 PSGRP-3:  cell_6:  UE_5, UE_6
    ...             Trigger traffic with UEs to increase load on PSGRP-2 above lbpsRTXMaxLoad and PSGRP-1,3 above lbpsMaxLoad
    ...     Expected result:
    ...             After 2 to 3 minutes:
    ...             cell_1 energySavingState = notEnergySaving    (change)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = notEnergySaving    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = notEnergySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 9. Adjust traffic with UEs to decrease load on PSGRP-2 below lbpsRTXMinLoad and PSGRP-1,3 below lbpsMinLoad
    ...     Expected result:
    ...             After 6 to 7 minutes:
    ...             cell_1 energySavingState = energySaving    (change)
    ...             cell_2 energySavingState = notEnergySaving
    ...             cell_7 energySavingState = notEnergySaving
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled) without cell reset    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...             cell_5 energySavingState = energySaving    (change)
    ...             cell_6 energySavingState = notEnergySaving
    ...             cell_9 energySavingState = notEnergySaving
    ...
    ...     Step 10. Send ETWS messages on cell_3 for 450 seconds (7.5 minutes) (etwsPrimNotifBcDur)
    ...             Trigger traffic with UEs 3, 4 to increase load on PSGRP-2 above lbpsRTXMaxLoad
    ...     Expected result:
    ...             After 7 minutes:
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...
    ...     Step 11. Attach 1 UE on cell_3 with establishment_cause=emergency and prevent it from going to idle
    ...             starting low (~10) kbps traffic with QCI=1 VoLTE bearer
    ...     Expected result:
    ...             After 3 minutes:
    ...             cell_3 energySavingState = reducedEnergySaving (1 Tx path enabled)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...
    ...     Step 12. Detach UE ending emergency call.
    ...     Expected result:
    ...             After max 3 minutes:
    ...             cell_3 energySavingState = notEnergySaving    (change)
    ...             cell_4 energySavingState = notEnergySaving
    ...             cell_8 energySavingState = notEnergySaving
    ...
    ...     Step 13. Detach all UEs. Disable feature CB010397, LTE1103 and LTE1203
    ...     Expected result:
    ...             After max 3 minutes all cells shall have energySavingState = notEnergySaving    (change)
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
    ...  CONTACTS:  Piotr Chyczewski    piotr.chyczewski@nokia.com
    ...             Jakub Kowalczyk     jakub.kowalczyk@nokia.com
    ...             Maciej Madej        maciej.madej@nokia.com
    ...             Pawel Nogiec        pawel.nogiec@nokia.com
    ...
    ...  REFERENCES:
    ...      https://gates.nsn-net.net/view/00026f09#o=0
    ...
    ...  HISTORY:
    ...     [24.04.2023] - First draft
    ...     [11.05.2023] - Version after review
    ...  R&D flags used:
    ...     TEnbcRadLowLoadSwitchOffDelay    0x110016=3
    ...     TEnbcRadHighLoadSwitchOnDelay    0x110017=3
    ...     shortening load measurement windows from 300/120 s to 30/30 s
    [Tags]    crt-true
    log to console    Step 1. Enable feature CB010397 actMixedSOMethod
    OnlineParamChange    ${A_a_enable}
    Set Power Saving Period start for PSGRP-1,2,3 to current time
    Cell1 Enter Into energySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into energySaving State
    Cell6 Enter Into notEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State
    log to console    Step 2.Set PSGRP-1,2,3 lbpsSuspended to suspended
    OnlineParamChange    ${Suspend_PSGRP}
    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    log to console    Step 3.Set PSGRP-1,2,3 lbpsLastCellSOEnabled to true, unsuspend PSGRP-1,2,3, and send ETMS on cell1,cell3,cell5
    OnlineParamChange    ${ENABLE_lbpsLastCellSOEnabled}
    Send ETWS on cell    cell_id=1          # alt ETWS and emergency PS blocker testing
    Send ETWS on cell    cell_id=3
    Send ETWS on cell    cell_id=5
    OnlineParamChange    ${Unsuspend_PSGRP}
     # etwsPrimNotifBcDur=180, assume that Set PSGRP-1,2,3 to notSuspended consumes 50 seconds
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    log to console   Step 4.Attach 1 UE per cell with establishment_cause=emergency to cell_1, cell_3 and cell_5 and start low traffic with VOLTE
    Emergency attach UEs to cell_1, cell_3 and cell_5 and run traffc on QCI-1 to start Emergency Call state on cells
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    # Step 5.
    OnlineParamChange    ${Disable_lbpsLastCellSOEnabled}
    Send ETWS on cell    cell_id=1
    Send ETWS on cell    cell_id=3
    Send ETWS on cell    cell_id=5
    release all ues
    # etwsPrimNotifBcDur=180, assume that Set PSGRP-1,2,3 to notSuspended consumes 50 seconds
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    # Step 6.
    Emergency attach UEs to cell_1, cell_3 and cell_5 and run traffc on QCI-1 to start Emergency Call state on cells
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    # Step 7.
    release all ues
    Cell1 Enter Into EnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell5 Enter Into EnergySaving State
    # Step 8. Trigger traffic with UEs to increase load on PSGRP-2 above lbpsRTXMaxLoad and PSGRP-1,3 above lbpsMaxLoad
    Hold 2 minute(s) for sib presence on cell_2,4,6
    execute uex command    ue_attach id=1-2 cell=2
    execute uex command    ue_attach id=3-4 cell=4
    execute uex command    ue_attach id=5-6 cell=6
    execute uex command    trf_data_start ue=1-4 dir=dl protocol=udp Mbps=12 qci=9 size=1400 interval=500 trf_id=1
    execute uex command    trf_data_start ue=5-6 dir=dl protocol=udp Mbps=9 qci=9 size=1400 interval=500 trf_id=2
    check cell stats
    Cell1 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    # Step 9. Adjust traffic with UEs to decrease load on PSGRP-2 below lbpsRTXMinLoad and PSGRP-1,3 below lbpsMinLoad
    execute uex command    trf_data_stop ue=1-6
    execute uex command    trf_data_start ue=1-4 dir=dl protocol=udp kbps=600 qci=9 size=1400 interval=500 trf_id=1
    execute uex command    trf_data_start ue=5-6 dir=dl protocol=udp kbps=600 qci=9 size=1400 interval=500 trf_id=2
    check cell stats
    Cell1 Enter Into EnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell5 Enter Into EnergySaving State
    execute uex command    trf_data_stop ue=1-6
    # Step 10. Send ETWS messages on cell_3 for 450 seconds (7.5 minutes) (etwsPrimNotifBcDur) #etwsPrimNotifBcDur=180
    #         Trigger traffic with UEs 3, 4 to increase load on PSGRP-2 above lbpsRTXMaxLoad
    Send ETWS on cell    cell_id=3
    execute uex command    trf_data_start ue=3-4 dir=dl protocol=udp Mbps=12 qci=9 size=1400 interval=500 trf_id=1
    check cell stats
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    # Step 11. Attach 1 UE on cell_3 with establishment_cause=emergency and prevent it from going to idle
    Emergency attach UEs to cell_3 and run traffc on QCI-1 to start Emergency Call state on cell
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    # Step 12. Detach UE ending emergency call.
    execute uex command    ue_detach id=23
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    # Step 13. Detach all UEs. Disable feature CB010397, LTE1103 and LTE1203
    execute uex command    ue_detach id=1-2
    execute uex command    ue_detach id=3-4
    execute uex command    ue_detach id=5-6
#    Disable actMixedSOMethod, actLBPowerSaving and actLBRTXPowerSaving features
    sleep    ${sleep_time}
    OnlineParamChange    ${Disable_Flag}
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell6 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
#    [Teardown]    OnlineParamChange    ${Disable_Flag}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=CB010397-A-a
    create alias
    ${V_1}    catenate
    ...    ue_param id=1-20 release=15 category=12 category_dl=19 category_ul=15 supported_bands=1,2,3,38,40,41
    ...    pdcp_sn_extension=on ca_supported_bands=2:a:a|38:a:a|40:a:a
    ...    fgi=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
    ${V_2}    catenate
    ...    ue_param id=21-30 release=15 category=12 category_dl=19 category_ul=15 supported_bands=1,2,3,38,40,41
    ...    pdcp_sn_extension=on ca_supported_bands=2:a:a
    ...    fgi=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
    execute uex command    ${V_1}
    execute uex command    ${V_2}

Modify Yaml
    Update Yaml    UEs/UE_sets/21    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/22    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/23    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/24    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/25    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/26    bearer: bearer_set_2
create alias
    create ue alias    UE_1    ue_id=1    id_type=cus
    create ue alias    UE_2    ue_id=2    id_type=cus
    create ue alias    UE_3    ue_id=3    id_type=cus
    create ue alias    UE_4    ue_id=4    id_type=cus
    create ue alias    UE_5    ue_id=5    id_type=cus
    create ue alias    UE_6    ue_id=6    id_type=cus
    create ue alias    UE_21    ue_id=21    id_type=cus
    create ue alias    UE_22    ue_id=22    id_type=cus
    create ue alias    UE_23    ue_id=23    id_type=cus
    create cell alias    CELL_1    cell_id=1   cell_type=cus
    create cell alias    CELL_2    cell_id=2   cell_type=cus
    create cell alias    CELL_3    cell_id=3   cell_type=cus
    create cell alias    CELL_4    cell_id=4   cell_type=cus
    create cell alias    CELL_5    cell_id=5   cell_type=cus
    create cell alias    CELL_6    cell_id=6   cell_type=cus
    create cell alias    CELL_7    cell_id=7   cell_type=cus
    create cell alias    CELL_8    cell_id=8   cell_type=cus

OnlineParamChange
    [Arguments]    ${delta_params}=${A_a_enable}
    Delta Commission Parameters    ${delta_params}
    cells should be onair

Emergency attach UEs to all cells and run traffc on QCI-1 to start Emergency Call state on all cells
    execute uex command    ue_attach id=21 cell=1 establishment_cause=emergency
    execute uex command    ue_attach id=22 cell=2 establishment_cause=emergency
    execute uex command    ue_attach id=23 cell=3 establishment_cause=emergency
    execute uex command    ue_attach id=24 cell=4 establishment_cause=emergency
    execute uex command    ue_attach id=25 cell=5 establishment_cause=emergency
    execute uex command    ue_attach id=26 cell=6 establishment_cause=emergency
    execute uex command    trf_data_start ue=21 dir=dl protocol=udp kbps=10 qci=1 trf_id=1
    execute uex command    trf_data_start ue=22 dir=dl protocol=udp kbps=10 qci=1 trf_id=2
    execute uex command    trf_data_start ue=23 dir=dl protocol=udp kbps=10 qci=1 trf_id=3
    execute uex command    trf_data_start ue=24 dir=dl protocol=udp kbps=10 qci=1 trf_id=4
    execute uex command    trf_data_start ue=25 dir=dl protocol=udp kbps=10 qci=1 trf_id=5
    execute uex command    trf_data_start ue=26 dir=dl protocol=udp kbps=10 qci=1 trf_id=6

Emergency attach UEs to cell_1, cell_3 and cell_5 and run traffc on QCI-1 to start Emergency Call state on cells
    execute uex command    ue_attach id=21 cell=1 establishment_cause=emergency
    execute uex command    ue_attach id=23 cell=3 establishment_cause=emergency
    execute uex command    ue_attach id=25 cell=5 establishment_cause=emergency
    execute uex command    trf_data_start ue=21 dir=dl protocol=udp kbps=10 qci=1 trf_id=1
    execute uex command    trf_data_start ue=23 dir=dl protocol=udp kbps=10 qci=1 trf_id=2
    execute uex command    trf_data_start ue=25 dir=dl protocol=udp kbps=10 qci=1 trf_id=3

Emergency attach UEs to cell_3 and run traffc on QCI-1 to start Emergency Call state on cell
    execute uex command    ue_attach id=23 cell=3 establishment_cause=emergency
    execute uex command    trf_data_start ue=23 dir=dl protocol=udp kbps=10 qci=1 size=1400 interval=500 trf_id=2

Send ETWS on cell
    [Arguments]    ${cell_id}
    Run Wts Command  mme_warn_request  enb=1
    ...    msg_id=1  msg_code=1
    ...    type=earthquake  popup=1  alert=1  concurrent=0
    ...    cell=${cell_id}

Hold ${time} minute(s) for sib presence on cell_${cell_id}
    Run Uex Command    get_sib_status
    Run Keyword and Ignore Error    Run Uex Command    wait_for_ovhd  cell=${cell_id}  timeout=${time}
    Run Uex Command    get_sib_status
    Log To Console    sib present on cell_${cell_id}

Set Power Saving Period start for PSGRP-1,2,3 to current time
    Create New Plan
    Edit PSGRP-1 period-1 time to current time + 0h0min offset and duration: 90min
    Edit PSGRP-2 period-1 time to current time + 0h0min offset and duration: 90min
    Edit PSGRP-3 period-1 time to current time + 0h0min offset and duration: 90min
    Apply planned changes

Edit PSGRP-${PSGRP} period-${period} time to current time + ${hours_offset}h${minutes_offset}min offset and duration: ${duration}min
    ${planned_time}=  get psgrp planned time  ${hours_offset}  ${minutes_offset}
    Log to console  changing PSGRP-${PSGRP} period-${period} time to ${planned_time}, duration: ${duration}min
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDayOfWeek=${planned_time}[0]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeHour=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsStartTimeMinute=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsPeriodList.lbpsDuration=${duration}           enb_id=1

check cell stats
    Execute Uex Command    get_cell_stats id=2 type=pdsch scell=all
    Execute Uex Command    get_cell_stats id=4 type=pdsch scell=all
    Execute Uex Command    get_cell_stats id=6 type=pdsch scell=all

Search Btslog And Stop Capture Logs
    ${PR821503}    catenate
    ...    oldSuggestedEnergySaving: SwitchingOffRtx],
    ...    [oldEnergySavingState: NotEnergySaving],
    ...    [suggestedEnergySaving: NotEnergySaving],
    ...    [energySavingState: SwitchingOffRtx
    execute cmd on pc    grep -i oldSuggestedEnergySaving ${SAVE LOG DIRECTORY}/btslog*.LOG
    ${out}    execute cmd on pc    grep -F -i '${PR821503}' ${SAVE LOG DIRECTORY}/btslog*.LOG
    run keyword if    '${out}' != ''    log    PR821503 reproduced and fixed    level=WARN
    common test teardown and stop capture logs





