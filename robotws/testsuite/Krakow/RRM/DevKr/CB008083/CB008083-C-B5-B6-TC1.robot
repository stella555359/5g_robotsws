*** Settings ***
Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Documentation
...
...      INTRODUCTION: The feature CB008083 will implement the following gNB enhancements on NG-C interface:
...      - Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...      - Maximum number of NG Setup Retries increased to 1000 (from 100)
...      - Controlled shutdown of the NG-C link , i.e. SCTP association is gracefully shutdown when
...          - NG-C link is locked, and NG Flex feature is not activated (currently supported when NG Flex
...            feature is activated)
...          - last SA cell is removed/deactivated8225
...      - Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...      TEST SET NAME:  CB008083-C
...
...      TESTING SCOPE:
...      CB008083-C Controlled shutdown of the NG-C link
...      -  CB008083-C-B5: MSC 5G_CP_OTH_681 Deletion of SA cell that is the last cell supporting of PLMN/SLICE of AMF
...                        cause graceful shutdown of NG-C link
...      -  CB008083-C-B6: MSC 5G_CP_OTH_681 Runtime addition of SA cell that is the first cell supporting of PLMN/SLICE
...                        of AMF cause establishment of NG-C
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
...               [05.01.2023] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

#Resource    ./resources/CB008083.robot
Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Resource    ./resources/CB008083_sctp_observers.robot
Resource    ta_messaging/single_message_observer.robot

Library     resources/message_verifier.py
#Library     resources/live_guami_view.py

Suite Setup
...     Run Setup     number_of_amfs=3    ff_enable=${True}         user_yaml=${setup_different_slice}

*** Variables ***
${LUA_CFG}=                             ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_last_slice.lua
${setup_different_slice}=               ${CURDIR}/config/yaml_config/setup_nwslice_TC11.yaml
${nrcell1_setup_with_different_slice}=  ${CURDIR}/config/yaml_config/add_NRCELL1_nwslice.yaml
${nrcell1_delete}=                      ${CURDIR}/config/yaml_config/del_NRCELL1.yaml

*** Test Cases ***
CB008083-C-B5-B6 Lock of last SA cell in tac causes ngc shutdown and unlock causes setup
    [Tags]    C-B5-B6-TC1
    [Documentation]
    ...
    ...  DESCRIPTION: Test verifies that last cell supported slice of AMF is locking.
    ...  It cause graceful shutdown of NG-C link to this AMF.
    ...  Second part verifies that after unlock this cell, NGC link to AMF is setup and active.
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
	...  - SA+NSA NRCELL-1 and SA NRCELL-2 are active and barred
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:native,GUAMI2:mapped)
    ...  - AMF2 is configured with 2 GUAMIs (GUAMI2:native,GUAMI3:mapped)
    ...  - AMF3 is configured with 2 GUAMIs (GUAMI1:mapped,GUAMI2:native)
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=on
	...  - NRBTS.SERVEDAMF.guAMI.guamiType = notSet
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actEnhancedNgRanSupport = true (CB008083)
    ...  - SNSSAI-1.sd = 0xD143A5
    ...  - SNSSAI-1.nrPlmnDNList = 'NRPLMN-1'
    ...  - SNSSAI-2.sd = 0xD143A6
    ...  - SNSSAI-2.nrPlmnDNList = 'NRPLMN-1'
    ...  - TRACKINGAREA-200.snssaiDNList = 'SNSSAI-1'
    ...  - TRACKINGAREA-201.snssaiDNList = 'SNSSAI-2'
    ...  - NRCELL-1/NRPLMNSET_SA-1.nrPlmnDNList = 'NRPLMN-1'
    ...  - NRCELL-1/NRPLMNSET_SA-1.trackingAreaDN = 'TRACKINGAREA-201'
    ...  - NRCELL-2/NRPLMNSET_SA-1.nrPlmnDNList = 'NRPLMN-1'
    ...  - NRCELL-2/NRPLMNSET_SA-1.trackingAreaDN = 'TRACKINGAREA-200'
    ...  - SERVEDAMF-1.sd = '13714341'
    ...  - SERVEDAMF-2.sd = '13714342'
    ...  - SERVEDAMF-3.sd = '13714341'
    ...
    ...  POSTCONDITION:
    ...  - Lock NRCELL-1 cause graceful shutdown of NG-C link to AMF2
    ...  - No SCTP association for NG-C link with AMF2 is established
    ...  - NRCELL-1 linked to a locked SLICE is not OnAir
    ...  - Unlock NRCELL-1 cause establishment of NG-C link to AMF2
    ...  - NG-C link to AMF2 supported configuration for common SLICE that is also supported by gNB is ACTIVE
    ...  - NG-C SCTP association is established for NG-C link to AMF2
    ...  - NRCELL-1 that was unlocked is OnAir
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17566; CB_FIM_31958
    ...       *BACKLOG ID: FCA_5G_L2L3-130049
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Dawid Krawczuk        (Nokia - PL/Krakow) <dawid.krawczuk@nokia.com>
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
    ...        [05.01.2023] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)
    [Setup]     Create sctp json source

    Unlock NGAP links
    Sleep  10

    Verify SERVEDAMF-1 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-1 has 1 items in snssaiAMFList

    Verify SERVEDAMF-2 has 0x01-0xD143A6 in snssaiAMFList
    Verify SERVEDAMF-2 has 1 items in snssaiAMFList

    Verify SERVEDAMF-3 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-3 has 1 items in snssaiAMFList

    Log To Console    NRCELL-1 lock

    Expect that SCTP connection between 10.0.1.2 and 10.0.1.12 will be terminated
    edit object attributes      NRCELL-1   administrativeState=locked       bts_id=1
    # changes due to PR735173
    run keyword and ignore error      Verify that SCTP connection between 10.0.1.2 and 10.0.1.12 has been terminated
    run keyword and ignore error      Verify SERVEDAMF-2 has NGC link Inactive

    Log To Console    NRCELL-1 unlock

    Expect that SCTP connection between 10.0.1.2 and 10.0.1.12 will be established
    edit object attributes      NRCELL-1   administrativeState=unlocked       bts_id=1
    # changes due to PR735173
    run keyword and ignore error      Verify that SCTP connection between 10.0.1.2 and 10.0.1.12 has been established
    Verify SERVEDAMF-2 has NGC link Active

    Log To Console    check object requires locking

    Expect that SCTP connection between 10.0.1.2 and 10.0.1.12 will be terminated
    EXPECT FLOW[timeout=120]: AMF2 NGAP nGSetup
    Reconfigure pucchF3ModulationScheme to pi2bpsk for NRCELL-1
    # changes due to PR735173
    run keyword and ignore error      PASS FLOW[timeout=120]: AMF2 NGAP nGSetup
    # changes due to PR735173
    run keyword and ignore error      Verify that SCTP connection between 10.0.1.2 and 10.0.1.12 has been terminated
    Verify SERVEDAMF-2 has NGC link Active

    Log To Console    manual NRCELL-1 deletion

    Expect that SCTP connection between 10.0.1.2 and 10.0.1.12 will be terminated
    Configure     ${nrcell1_delete}       bts_id=1
    # changes due to PR735173
    run keyword and ignore error      Verify that SCTP connection between 10.0.1.2 and 10.0.1.12 has been terminated
    # changes due to PR735173
    run keyword and ignore error      Verify SERVEDAMF-2 has NGC link Inactive

    Log To Console    manual NRCELL-1 addition

    Expect that SCTP connection between 10.0.1.2 and 10.0.1.12 will be established
    Configure     ${nrcell1_setup_with_different_slice}       bts_id=1
    # changes due to PR735173
    run keyword and ignore error      Verify that SCTP connection between 10.0.1.2 and 10.0.1.12 has been established
    Verify SERVEDAMF-2 has NGC link Active

    [Teardown]   Run keywords
    ...        Cleanup after test C-B5-B6     AND
    ...        stop_all_json_sources
