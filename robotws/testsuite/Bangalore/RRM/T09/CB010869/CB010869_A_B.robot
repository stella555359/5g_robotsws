*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS23R4    owner-annie.nie    PY39


Documentation
...
...      author:            Geetha    geetha.k_r@nokia.com
...      maintainer:        Geetha    geetha.k_r@nokia.com
...
...      INTRODUCTION:    : This scenario validates that the gNB correctly determines the Cell TX paths Switch Off/On List
...                         for a Power Group when modifying threshold time window related parameters (add, delete, modify)
...                         and varying load during lbpsPeriod.

...       Requirement id -   OM_LTE_SFS_RNL.30394, OM_LTE_SFS_RNL.30395, OM_LTE_SFS_RNL.30396, OM_LTE_SFS_RNL.30397

Resource          resources/DevHZ5_resource.robot
Library           resources/CB010869.py
Library           ta_emss
Resource          resources/DevHZ5_startup.robot

Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    ${TEnbcRadLowLoadSwitchOffDelay}=3       # *10 secs shortening load measurement windows from 300/120 s to 30/30 s
...    ${TEnbcRadHighLoadSwitchOnDelay}=3     # *10 secs
${TEnbcRadLowLoadSwitchOffDelay}    0x110016    # *10 secs
${TEnbcRadHighLoadSwitchOnDelay}    0x110017    # *10 secs


*** Test Cases ***
[1][1.0] CB010869_A_B_Robustness_1_Load_Fluctuations_and_online_Parameter_change_for_LTE
    [Documentation]    This scenario validates that the gNB correctly determines the Cell TX paths Switch Off/On List
...                    for a Power Group when modifying threshold time window related parameters (add, delete, modify)
...                    and varying load during lbpsPeriod.


    [Tags]
    Attach ue and pump data
    Verify cell moved to notenergysaving state
    Verify cell moved to reducedenergy saving state
    Verify cell moved to energysaving state
    Verify cell moved to notenergysaving state_1


*** Keywords ***
Verify cell moved to notenergysaving state_1
    execute uex command    trf_data_start ue=11 qci=9 kbps=6000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=12 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=13 qci=9 kbps=6000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=14 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=15 qci=9 kbps=6000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=16 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell2 Enter Into notEnergySaving State
    Run Keyword And Ignore Error     Cell5 Enter Into notEnergySaving State
    Run Keyword And Ignore Error     Cell6 Enter Into notenergysaving State
    Cell7 Enter Into notEnergySaving State
    Run Keyword And Ignore Error     Cell8 Enter Into notEnergySaving State

Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=CB010397-A-d    cfg=cus.yaml

Cleanup after CB010397-A-d-1_4
    release all ues
    execute egate command    mme_warn_kill cell=9 enb=1 msg_id=1 msg_code=1\
    Common Test Teardown And Stop Capture Logs

Set lbpsPeriodList and lbpscsoPeriodlist for A-d-1_4
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

Attach ue and pump data
    Log To Console    -------- Step 1 --------
    execute uex command    ue_attach id=11,12 cell=7
    execute uex command    ue_attach id=13,14 cell=8
    execute uex command    ue_attach id=15,16 cell=9
    execute uex command    trf_data_start ue=11..16 qci=9 Mbps=7 dir=dl protocol=udp size=1400 trf_id=1 interval=500

Verify cell moved to notenergysaving state
    check cell stats
    Set lbpsPeriodList and lbpscsoPeriodlist for A-d-1_4
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
    Cell4 Enter Into notEnergySaving State
    Cell5 Enter Into notEnergySaving State
    Cell6 Enter Into notenergysaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

Verify cell moved to reducedenergy saving state
    execute uex command    trf_data_stop ue=11 qci=9
    execute uex command    trf_data_stop ue=13 qci=9
    execute uex command    trf_data_start ue=11 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_start ue=13 qci=9 kbps=4000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    execute uex command    trf_data_stop ue=15 qci=9
    execute uex command    trf_data_stop ue=16 qci=9
    execute uex command    trf_data_start ue=15..16 qci=9 kbps=3000 dir=dl protocol=udp size=1400 trf_id=1 interval=500
    check cell stats
    Cell1 Enter Into reducedEnergySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell7 Enter Into notEnergySaving State
    Cell8 Enter Into notEnergySaving State
    Cell9 Enter Into notEnergySaving State

Verify cell moved to energysaving state
    execute uex command    trf_data_stop ue=11..16 qci=9
    Cell1 Enter Into energySaving State
    Cell2 Enter Into energySaving State
    Cell3 Enter Into reducedEnergySaving State
    Cell4 Enter Into reducedEnergySaving State
    Cell5 Enter Into reducedEnergySaving State
    Cell6 Enter Into reducedEnergySaving State
    Cell7 Enter Into notEnergySaving State

Set lbpsCsoLoadThresList for A-d-1_4
    Set lbps Power Saving Period start for PSGRP-1,2,3 to 0 minutes from start and 90 minutes duration

Set lbps Power Saving Period start for PSGRP-1,2,3 to ${offset} minutes from start and ${duration} minutes duration
    Create New Plan
    Edit lbps PSGRP-1 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Edit lbps PSGRP-2 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Edit lbps PSGRP-3 period-1 time to current time + 0h${offset}min offset and duration: ${duration}min
    Apply planned changes

Edit lbps PSGRP-${PSGRP} period-${period} time to current time + ${hours_offset}h${minutes_offset}min offset and duration: ${duration}min
    ${planned_time}=  get psgrp planned time  ${hours_offset}  ${minutes_offset}
    Log to console  changing PSGRP-${PSGRP} period-${period} time to ${planned_time}, duration: ${duration}min
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsCsoLoadThresList.lbpsDayOfWeek=${planned_time}[0]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsCsoLoadThresList.lbpsStartTimeHour=${planned_time}[1]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsCsoLoadThresList.lbpsStartTimeMinute=${planned_time}[2]    enb_id=1
    Edit planned object attributes    PSGRP-${PSGRP}  lbpsCsoLoadThresList.lbpsDuration=${duration}           enb_id=1
