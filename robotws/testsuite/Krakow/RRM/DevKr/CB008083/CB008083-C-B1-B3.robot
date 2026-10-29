*** Settings ***
Documentation
...
...      INTRODUCTION: The feature CB008083 will implement the following gNB enhancements on NG-C interface:
...      - Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...      - Maximum number of NG Setup Retries increased to 1000 (from 100)
...      - Controlled shutdown of the NG-C link , i.e. SCTP association is gracefully shutdown when
...          - NG-C link is locked, and NG Flex feature is not activated (currently supported when NG Flex
...            feature is activated)
...          - last SA cell is removed/deactivated
...      - Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...      TEST SET NAME:  CB008083-C
...
...      TESTING SCOPE:
...      CB008083-C Controlled shutdown of the NG-C link
...      - CB008083-C#B1: MSC 5G_CP_CONF_901 NG-C Link Lock
...      - CB008083-C#B3: MSC 5G_CP_CONF_901 NG-C Link Unlock
...
...      CONTACTS:
...      CFAM Leader        : Mateusz Basiejko      (Nokia - PL/Krakow) <mateusz.basiejko@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Dawid Krawczuk        (Nokia - PL/Krakow) <dawid.krawczuk@nokia.com>
...                           Malgorzata Konior     (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
...                           Marek Kieltyka        (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/000263b7#o=0
...                     FTS link:              http://nok.it/CB008083_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008083-SR
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
...
...               [07.10.2022] - Created TC
...               [13.01.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=875040)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Resource    ta_messaging/single_message_observer.robot
Resource    ./resources/CB008083_sctp_observers.robot

Library     resources/message_verifier.py
#Library     resources/live_guami_view.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...     Run Setup     number_of_amfs=1  user_yaml=${cell_to_sa_yaml}  ff_enable=${True}

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SANSA_TDD_2c_1eNBSim_1AMF_C.lua
${remove_cell_yaml}=   ${CURDIR}/config/yaml_config/del_NRCELL.yaml
${cell_to_sa_yaml}=   ${CURDIR}/config/yaml_config/reconf_NRCELL_SA.yaml

*** Test Cases ***
CB008083-C-B1-B3 Single AMF NG-C Link lock and unlock independent from actNgcFlexSaMode
    [Tags]    C-TC1
    [Documentation]
    ...
    ...  DESCRIPTION: Test verifies that NG-C link is unlocked independent from actNgcFlexSaMode if actEnhancedNgRanSupport
    ...               is enabled simultaneously with link unlock. CB008083 feature flag is disabled from the beginning.
    ...               Second part verifies that NG-C link with single AMF is locked independent from actNgcFlexSaMode.
	...
    ...  PRECONDITION:
    ...  - Real gNB2 is up and running
    ...  - AMF1 is up and running
    ...  - SIM eNB1 is up and running
    ...  - SCTP association for NG-C link between gNB2 and AMF1 is not established
    ...  - NG-C link AMF1-gNB2 is locked
    ...  - SA+NSA NRCELL-1 and SA NRCELL-2 are active and barred
    ...  - X2 link between eNB1 and gNB2 is established
    ...  - NRBTS.actNgcFlexSaMode = false (5GC000740)
    ...  - NRBTS.actEnhancedNgRanSupport = true (CB008083)
	...
    ...  POSTCONDITION:
    ...  - SCTP association for NG-C link with AMF1 is established
    ...  - NG-C link with AMF1 is active and unlocked
    ...  - NSA UE16 is active
    ...  - SA+NSA NRCELL-1 and SA NRCELL-2 are active and unbarred
	...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17723; 5G_RAN_USR_RRM_17847
    ...       *BACKLOG ID: FCA_5G_L2L3-119454; FCA_5G_L2L3-119456
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Malgorzata Konior     (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/000263b7#o=0
    ...  FTS link:              http://nok.it/CB008083_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008083-SR
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
    ...
    ...        [09.10.2022] - Created TC
    ...        [13.01.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=875040)

    [Setup]     Run keywords
    ...    Prepare test environment C-TC1   AND
    ...    Create sctp json source

    EXPECT FLOW[timeout=120]: AMF1 NGAP nGSetup
    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be established

    Unlock NGAP link to AMF1

    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been established
    PASS FLOW[timeout=120]: AMF1 NGAP nGSetup
    Verify SERVEDAMF-1 has NGC link Active
    Verify that NRCELL-1 operationalState is enabled
    Verify that NRCELL-1 barringStatus is unbarred
    Verify that NRCELL-2 operationalState is enabled
    Verify that NRCELL-2 barringStatus is unbarred

    LTE attach NR-UE16
    Start gNB Addition Procedure for NSA NR-UE16 with NRCELL-1

    EXPECT FLOW[timeout=120]: gNB2 X2AP endcPartialReset
    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be terminated

    Lock NGAP link to AMF1
    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been terminated
    FAIL FLOW[timeout=120]: gNB2 X2AP endcPartialReset
    Verify SERVEDAMF-1 has NGC link Inactive
    Verify that NRCELL-1 operationalState is enabled
    Verify that NRCELL-1 barringStatus is barred
    Verify that NRCELL-2 operationalState is disabled
    Verify that NRCELL-2 barringStatus is unbarred

    EXPECT FLOW[timeout=120]: AMF1 NGAP nGSetup
    EXPECT FLOW[timeout=120]: gNB2 X2AP endcPartialReset
    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be established

    Unlock NGAP link to AMF1

    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been established
    PASS FLOW[timeout=120]: AMF1 NGAP nGSetup
    FAIL FLOW[timeout=120]: gNB2 X2AP endcPartialReset
    Verify SERVEDAMF-1 has NGC link Active
    Verify that NRCELL-1 operationalState is enabled
    Verify that NRCELL-1 barringStatus is unbarred
    Verify that NRCELL-2 operationalState is enabled
    Verify that NRCELL-2 barringStatus is unbarred

    [Teardown]   Run keywords
    ...          Cleanup after test C-TC1    AND
    ...          stop_all_json_sources

*** Keywords ***
