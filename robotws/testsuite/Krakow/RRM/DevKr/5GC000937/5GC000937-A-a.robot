*** Settings ***
Documentation
...
...      INTRODUCTION:  5GC000937: UE power saving Dynamic Bandwidth Part adaptation
...                     The aim of the feature is to allow power savings for UE with small throughput traffic.
...
...      TEST SET NAME: 5GC000937 - UE power saving Dynamic Bandwidth Part adaptation
...
...      TESTING SPLIT: 5GC000937-A Dynamic Bandwidth Part adaptation in SA Mode with no PUSCH fragmentation
...                     5GC000937-A-a UE capable of using Power Saving BWP connects to gNB cell with initial access
...                     5GC000937-A-b UE capable of using Power Saving BWP connects to gNB cell via HO
...                     5GC000937-A-c gNB switches UE BWP from large to Power Saving one using DCI
...                     5GC000937-A-d gNB switches UE BWP from Power Saving to large one using DCI
...                     5GC000937-A-e gNB BWP switchin for multiple UEs
...                     5GC000937-A-f Counters handling
...                     5GC000937-A-g RRC re-estabishment scenario
...                     5GC000937-C Interaction with CA
...                     5GC000937-W Performance and Capacity
...      CONTACTS:   Mateusz Matusik <mateusz.matusik@nokia.com>
...                  Marek Kieltyka <marek.kieltyka@nokia.com>
...                  Karolina Sroczyk <karolina.sroczyk@nokia.com>
...
...      REFERENCES:  5GC000937 CFAM
...                   https://nokia.sharepoint.com/:b:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0800-5GC0999/5GC000937%20UE%20Power%20saving%20Dynamic
...                   %20Bandwidth%20Part%20Adaptation/CP1/CFAM%205GC000937%20-CP1.pdf?csf=1&web=1&e=zjy0Eg
...
...      HISTORY:
...         [25.06.2021] - Create Test Suite
...         [18.08.2023] - switching test to agent-ca support

Resource    ./resources/5GC000937_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    CONFIGS_Krakow/5GC000937/trunk/937a_config.yml
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup   Prepare test suite   ute_ca=True

*** Variables ***
@{ACCEPTED_BTS_STATES}     Configured    IntegratedToRan    OnAir
${LUA_CFG}=   ${CURDIR}/config/SA/egate_2c.lua
${SCFC}=      ${CURDIR}/../../../../../custom-config/Krakow/5GC000937/trunk/2c_conf.xml
${AP_XML}=    ${CURDIR}/../../../../../custom-config/Krakow/5GC000937/trunk/iphy_2AEQE_2cells.xml

*** Test Cases ***
5GC000937-A-TC4_UE_with_incomplete_capabilities
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  == Info==
    ...  Test case purpose is to confirm that UE with incomplete capabilities doesn't configure power
    ...  saving BWP profile.
    ...
    ...  == Precondition: ==
    ...  gNB2 classical - real hardware - ABIO + ASIL
    ...  NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  UE - Airphone simulator
    ...  UE1-UE9 full power saving BWP capabilities
    ...  UE10-UE12 capabilities contain bwp-SameNumerology IE only
    ...  UE13-UE15 capabilities contain bwp-SwitchingDelay IE only
    ...
    ...  gNB2 up and running with one SA cell OnAir
    ...  NRCELL.actPowerSavingBwp=true
    ...  NRBTS.BWP_PROFILE for power saving is configured
    ...  NRCELL.cellBwpList includes power saving BWP
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in SA mode
    ...     HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...     REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_2081, 5G_CP_ARC_ALG_1978, 5G_CP_ARC_ALG_2798
    ...
    ...  REQUIRED LOGS:  NR_RRC pcap
    ...
    ...  CONTACTS:
    ...     Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
    ...     Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  REFERENCES:
    ...     Related CFAM US:
    ...        US5GC000937-A#B1 Single-UE Switch to power saving BWP and switch to large BWP
    ...
    ...  HISTORY:
    ...     [25.06.2021] - TC Create
    ...     [19.10.2021] - Adding additional requirements to test

#    [Setup]  Prepare test environment A4
    [Tags]  A4

    Attach UE11 with only bwp-SameNumerology configured
    Verify that UE11 did not configure power saving BWP during attach

    Attach UE14 with only bwp-SwitchingDelay configured
    Verify that UE14 did not configure power saving BWP during attach

    Attach 3 UEs with full BWP capabilities
    Verify that all 3 UEs did configure power saving BWP during attach

    [Teardown]  Cleanup after test A4

#Test was removed due to adaptation triggered by PR610582
*** comment ***
5GC000937-A-TC2_Alarm_when_gscn_has_incorrect_value
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  == Info==
    ...  Test case purpose is to confirm that alarm is raised when gscn value is is not compatibile with feature
    ...  activation.
    ...
    ...  == Precondition: ==
    ...  gNB2 classical - real hardware - ABIL + ASIK
    ...  NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  UE - Airphone simulator
    ...
    ...  gNB2 up and running with one SA cell OnAir
    ...  NRCELL.actPowerSavingBwp=true
    ...  NRBTS.BWP_PROFILE for power saving is configured
    ...  NRCELL.cellBwpList includes power saving BWP
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in SA mode
    ...     HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...     REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_2081
    ...
    ...  REQUIRED LOGS:  Alarm log
    ...
    ...  CONTACTS:
    ...     Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...     Karolina Sroczyk (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...
    ...  REFERENCES:
    ...     Related CFAM US:
    ...        US5GC000937-A#E1 Check configuration of gscn compatibility with feature activation
    ...
    ...  HISTORY:
    ...     [25.06.2021] - TC Create

    [Tags]  A2   SKIPRUN

    Set gscn to 7896 and send configuration to gNB
    Reboot gNB and check radios availability
    Verify that cell activation failed and 7516 alarm with IncorrectCellParameterConfiguration fault was raised

    [Teardown]  Cleanup after test A2
