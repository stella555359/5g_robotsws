*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      INTRODUCTION:
...         5GC000937: UE power saving Dynamic Bandwidth Part adaptation
...         The aim of the feature is to allow power savings for UE with small throughput traffic.
...
...      TEST SET NAME:
...         5GC000937 - UE power saving Dynamic Bandwidth Part adaptation
...
...      TESTING SPLIT:
...       - 5GC000937-A Dynamic Bandwidth Part adaptation in SA Mode with no PUSCH fragmentation
...       - 5GC000937-A-a UE capable of using Power Saving BWP connects to gNB cell with initial access
...       - 5GC000937-A-b UE capable of using Power Saving BWP connects to gNB cell via HO
...       - 5GC000937-A-c gNB switches UE BWP from large to Power Saving one using DCI
...       - 5GC000937-A-d gNB switches UE BWP from Power Saving to large one using DCI
...       - 5GC000937-A-e gNB BWP switchin for multiple UEs
...       - 5GC000937-A-f Counters handling
...       - 5GC000937-A-g RRC re-estabishment scenario
...       - 5GC000937-C Interaction with CA
...       - 5GC000937-W Performance and Capacity
...
...      == AUTHORS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         5GC000937 CFAM
...         https://nokia.sharepoint.com/:b:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0800-5GC0999/5GC000937%20UE%20Power%20saving%20Dynamic
...         %20Bandwidth%20Part%20Adaptation/CP1/CFAM%205GC000937%20-CP1.pdf?csf=1&web=1&e=zjy0Eg
...
...      HISTORY:
...         [02.07.2021] - Create Test Suite
...         [18.08.2023] - switching test to agent-ca support

Resource    resources/5GC000937_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    CONFIGS_Krakow/5GC000937/trunk/937b_config.yml
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup   Prepare test suite   ute_ca=True

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA/egate_2c.lua
${SCFC}=      ${CURDIR}/../../../../../custom-config/Krakow/5GC000937/trunk/2c_conf.xml
${AP_XML}=    ${CURDIR}/../../../../../custom-config/Krakow/5GC000937/trunk/iphy_2AEQE_2cells.xml
&{phy_cell_id}=   1=50   2=51

*** Test Cases ***
5GC000937-A-TC5_Power_saving_configuration_during_HO
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to verify proper power saving BWP configuration in UE during HO. Test will verify
    ...  cases with HO into or from cell with and without power saving feature enabled.
    ...
    ...  == Precondition ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...  - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - NRCELL-1.actPowerSavingBwp=true
    ...  - NRCELL-2.actPowerSavingBwp=true
    ...  - NRBTS.BWP_PROFILE for power saving is configured
    ...  - UE1 capabilities support power saving BWP
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_2081
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, F1AP PCAP
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    Related CFAM US:
    ...       US5GC000937-A#B1 Single-UE Switch to power saving BWP and switch to large BWP
    ...
    ...  == HISTORY ==
    ...    [02.07.2021] - TC Create

    [Tags]  A5

    Attach UE1 with full BWP capabilities to gNB2 NRCELL-1
    Verify that UE1 did configure power saving BWP during attach

    UE1 triggers handover to gNB2 NRCELL-2 where actPowerSavingBwp is enabled
    Verify that power saving configuration is present in Handover Preparation IE over F1 interface
    Verify that UE1 configured power saving BWP after HO

    Detach UE1
    Set NRCELL-1 parameter actPowerSavingBwp to FALSE

    Attach UE1 to cell-2
    UE1 triggers handover to gNB2 NRCELL-1 where actPowerSavingBwp is disabled
    Verify that power saving configuration is present in Handover Preparation IE over F1 interface
    Verify that UE1 did not configure power saving BWP after HO

    UE1 triggers handover to gNB2 NRCELL-2 where actPowerSavingBwp is enabled
    Verify that power saving configuration is not present in Handover Preparation IE over F1 interface
    Verify that UE1 configured power saving BWP after HO

    [Teardown]  Cleanup after test A5
