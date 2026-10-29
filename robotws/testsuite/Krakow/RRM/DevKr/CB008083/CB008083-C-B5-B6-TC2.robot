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
...          - last SA cell is removed/deactivated
...      - Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...      TEST SET NAME:  CB008083-A
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
...     Run Setup     number_of_amfs=3    ff_enable=${True}
#...            Create sctp json source

*** Variables ***
${LUA_CFG}=                                 ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_last_plmn.lua
${setup_nwslice_and_second_plmn}=           ${CURDIR}/config/yaml_config/setup_nwslice_second_plmn.yaml
${nrcell2_setup}=                           ${CURDIR}/config/yaml_config/add_NRCELL2.yaml
${nrcell2_delete}=                          ${CURDIR}/config/yaml_config/del_NRCELL2.yaml

*** Test Cases ***
CB008083-C-B5-B6 Lock of last SA cell in PLMN causes ngc shutdown and unlock causes setup
    [Tags]    C-B5-B6-TC2
    [Documentation]
    ...
    ...  DESCRIPTION: Test verifies that last cell supported PLMN of AMF is locking.
    ...  It cause graceful shutdown of NG-C link to this AMFs.
    ...  Second part verifies that after unlock this cell, NGC link to multiple AMFs are setup and active.
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
	...  - SA+NSA NRCELL-1 and SA NRCELL-2 are active and barred
    ...  - AMF1 is configured with 1 GUAMI (GUAMI1:notSet)
    ...  - AMF2 is configured with 1 GUAMI (GUAMI2:notSet)
    ...  - AMF3 is configured with 1 GUAMI (GUAMI3:notSet)
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=on
	...  - NRBTS.SERVEDAMF.guAMI.guamiType = notSet
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actEnhancedNgRanSupport = true (CB008083)
    ...  - SNSSAI-1.sd = 0xD143A5
    ...  - SNSSAI-1.nrPlmnDNList = 'NRPLMN-1'
    ...  - SNSSAI-2.sd = 0xD143A5
    ...  - SNSSAI-2.nrPlmnDNList = 'NRPLMN-2'
    ...  - TRACKINGAREA-200.snssaiDNList = 'SNSSAI-1'
    ...  - TRACKINGAREA-201.snssaiDNList = 'SNSSAI-2'
    ...  - NRCELL-1/NRPLMNSET_SA-1.nrPlmnDNList = 'NRPLMN-2'
    ...  - NRCELL-1/NRPLMNSET_SA-1.trackingAreaDN = 'TRACKINGAREA-201'
    ...  - NRCELL-2/NRPLMNSET_SA-1.nrPlmnDNList = 'NRPLMN-1'
    ...  - NRCELL-2/NRPLMNSET_SA-1.trackingAreaDN = 'TRACKINGAREA-200'
    ...  - SERVEDAMF-1.sd = '13714341'
    ...  - SERVEDAMF-2.sd = '13714341'
    ...  - SERVEDAMF-3.sd = '13714341'
    ...
    ...  POSTCONDITION:
    ...  - Lock NRCELL-1 cause graceful shutdown of NG-C links to AMF1 and AMF3
    ...  - No SCTP association for NG-C links with AMF1 and AMF3 are established
    ...  - NRCELL-1 linked to a locked PLMN is not OnAir
    ...  - Unlock NRCELL-1 cause establishment of NG-C links to AMF1 and AMF3
    ...  - NG-C links to AMF1 and AMF3 supported configuration for common SLICE that is also supported by gNB is ACTIVE
    ...  - NG-C SCTP association is established for NG-C links to AMF1 and AMF3
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


    [Setup]     Configure     ${setup_nwslice_and_second_plmn}       bts_id=1

    Unlock NGAP links
    Sleep  10

    Verify SERVEDAMF-1 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-1 has 1 items in snssaiAMFList
    Verify SERVEDAMF-1 has 311:489:3 in plmnSupportList
    Verify SERVEDAMF-1 has 1 items in plmnSupportList

    Verify SERVEDAMF-2 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-2 has 1 items in snssaiAMFList
    Verify SERVEDAMF-2 has 311:490:3 in plmnSupportList
    Verify SERVEDAMF-2 has 1 items in plmnSupportList

    Verify SERVEDAMF-3 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-3 has 1 items in snssaiAMFList
    Verify SERVEDAMF-3 has 311:489:3 in plmnSupportList
    Verify SERVEDAMF-3 has 1 items in plmnSupportList

    Log To Console    NRCELL-2 lock

#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be terminated
#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.13 will be terminated
    edit object attributes      NRCELL-2   administrativeState=locked       bts_id=1
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been terminated
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.13 has been terminated
    Verify SERVEDAMF-1 has NGC link Inactive
    Verify SERVEDAMF-3 has NGC link Inactive

    Log To Console    NRCELL-2 unlock

#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be established
#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.13 will be established
    edit object attributes      NRCELL-2   administrativeState=unlocked       bts_id=1
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been established
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.13 has been established
    Verify SERVEDAMF-1 has NGC link Active
    Verify SERVEDAMF-3 has NGC link Active

    Log To Console    check object requires locking

#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be terminated
#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.13 will be terminated
    EXPECT FLOW[timeout=120]: AMF1 NGAP nGSetup
    EXPECT FLOW[timeout=120]: AMF3 NGAP nGSetup
    Reconfigure pucchF3ModulationScheme to pi2bpsk for NRCELL-2
    PASS FLOW[timeout=120]: AMF1 NGAP nGSetup
    PASS FLOW[timeout=120]: AMF3 NGAP nGSetup
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been terminated
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.13 has been terminated
    Verify SERVEDAMF-1 has NGC link Active
    Verify SERVEDAMF-3 has NGC link Active

    Log To Console    manual NRCELL-2 deletion

#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be terminated
#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.13 will be terminated
    Configure     ${nrcell2_delete}       bzts_id=1
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been terminated
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.13 has been terminated
    Verify SERVEDAMF-1 has NGC link Inactive
    Verify SERVEDAMF-3 has NGC link Inactive

    Log To Console    manual NRCELL-2 addition

#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.11 will be established
#    Expect that SCTP connection between 10.0.1.2 and 10.0.1.13 will be established
    Configure     ${nrcell2_setup}       bzts_id=1
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.11 has been established
#    Verify that SCTP connection between 10.0.1.2 and 10.0.1.13 has been established
    Verify SERVEDAMF-1 has NGC link Active
    Verify SERVEDAMF-3 has NGC link Active

    [Teardown]   Run keywords
    ...        Cleanup after test C-B5-B6
