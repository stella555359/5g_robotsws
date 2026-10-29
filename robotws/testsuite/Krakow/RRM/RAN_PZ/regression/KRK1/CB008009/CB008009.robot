*** Settings ***
Documentation
...    This test suite is to cover CB008009 feature regression.
...    author:  Szymon Skorupski, Justyna Klinger-Obszarny
...    contact: szymon.skorupski@nokia.com, justyna.klinger-obszarny@nokia.com


Library     ta5g_pm_counters
Library     ute_fsmaccess
Library     ta_emss
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK1/CB008009/resources/keywords.robot
Variables   resources/variables.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    CRT    CLOUD_5G_CLASSICAL_ASILL_ABIPB1_3xAHEB    PY36

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${TRAFFIC_DURATION_SEC}    10s
${protocol}                udp
${deviation}               10%
${UE_1_alias}              ANDROID_UE_1
${UE_2_alias}              ANDROID_UE_2
${capabilities_ue_1}         SAMSUNG_S22_1
${capabilities_ue_2}         SAMSUNG_S22_2

*** Test Cases ***
CB008009-A_7 DL throughput distribution counters on NSA
    [TIMEOUT]    20h
    [Documentation]
    ...  Set parameters for feature activation:
    ...    * actThpDist=1
    ...    * actIpThpt=1
    ...    * thpTimeCalc=enabled
    ...    * reportingIntervalPm=5
    ...
    ...  Feature configuration parameters:
    ...    * durationThresDiscardDL set to default value (40ms) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...    * volThresDiscardDl set to default value (8000 kBs) ) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...  Defining distribution BINs:
    ...    * thpHistScale set to Linear
    ...    * histDownlinkMaxRange set to default 1000000 kbit/s (1 Gbit/s)
    ...    * histDownlinkMinRange set to default 100 kbit/s (0.1 Mbit/s)

    Activate CB008009 feature parameters
    Prepare UE      ue_alias=${UE_1_alias}      capabilities=${capabilities_ue_1}
    DL nonPMQAP tput distribution BIN counters verification for single UE scenario
    ...     ue_alias=${UE_1_alias}      direction=dl     tput_duration=${TRAFFIC_DURATION_SEC}   deviation=${deviation}


CB008009-A_8 DL throughput distribution counters on NSA with PMQAP profile
    [Documentation]
    ...  Set parameters for feature activation:
    ...    * actThpDist=1
    ...    * actIpThpt=1
    ...    * thpTimeCalc=enabled
    ...    * reportingIntervalPm=5
    ...
    ...  Configure NRPMQAP functionality:
    ...    * different PLMNs (mmc, mnc) - (1:1 now and 244:8) are configured
    ...    * QOS profile (PLMN, QCI/5QI) are configured - step 4
    ...
    ...  Feature configuration parameters:
    ...    * urationThresDiscardDL set to default value (40ms) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...    * volThresDiscardDl set to default value (8000 kBs) ) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...
    ...  Defining distribution BINs:
    ...    * thpHistScale set to Linear
    ...    * histDownlinkMaxRange set to default 1000000 kbit/s (1Gbit/s)
    ...    * histDownlinkMinRange set to default 100 kbit/s (0.1Mbit/s)

    Activate CB008009 feature parameters
    Prepare UE      ue_alias=${UE_1_alias}      capabilities=${capabilities_ue_1}
    DL PMQAP tput distribution BIN counters verification for single UE scenario
    ...     ue_alias=${UE_1_alias}      direction=dl     tput_duration=${TRAFFIC_DURATION_SEC}   deviation=${deviation}

CB008009-B_10 UL throughput distribution counters on NSA
    [Documentation]
    ...  Set parameters for feature activation:
    ...    * actThpDist=1
    ...    * actIpThpt=1
    ...    * thpTimeCalc=enabled
    ...    * reportingIntervalPm=5
    ...
    ...  Configure NRPMQAP functionality:
    ...    * different PLMNs (mmc, mnc) - (1:1 now and 244:8) are configured
    ...    * QOS profile (PLMN, QCI/5QI) are configured - step 4
    ...
    ...  Feature configuration parameters:
    ...    * urationThresDiscardUL set to default value (40ms) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...    * volThresDiscardUl set to default value (8000 kBs) ) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...
    ...  Defining distribution BINs:
    ...    * thpHistScale set to Linear
    ...    * histUplinkMaxRange set to default 1000000 kbit/s (100Mbit/s)
    ...    * histUplinkMinRange set to default 10000 kbit/s (10Mbit/s)

    Activate CB008009 feature parameters
    Prepare UE      ue_alias=${UE_1_alias}      capabilities=${capabilities_ue_1}
    UL PMQAP tput distribution BIN counters verification for single UE scenario
    ...     ue_alias=${UE_1_alias}      direction=ul     tput_duration=${TRAFFIC_DURATION_SEC}   deviation=${deviation}


CB008009-B_11 UL throughput distribution counters on NSA with PMQAP profile
    [Documentation]
    ...  Set parameters for feature activation:
    ...    * actThpDist=1
    ...    * actIpThpt=1
    ...    * thpTimeCalc=enabled
    ...    * reportingIntervalPm=5
    ...
    ...  Feature configuration parameters:
    ...    * durationThresDiscardUL set to default value (40ms) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...    * volThresDiscardUl set to default value (8000 kBs) ) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...  Defining distribution BINs:
    ...    * thpHistScale set to Linear
    ...    * histUplinkMaxRange set to default 1000000 kbit/s (1 Gbit/s)
    ...    * histUplinkMinRange set to default 100 kbit/s (0.1 Mbit/s)

    Activate CB008009 feature parameters
    Prepare UE      ue_alias=${UE_1_alias}      capabilities=${capabilities_ue_1}
    Ul nonPMQAP tput distribution BIN counters verification for single UE scenario
    ...     ue_alias=${UE_1_alias}      direction=ul     tput_duration=${TRAFFIC_DURATION_SEC}   deviation=${deviation}
