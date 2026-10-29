*** Settings ***
Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
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
...      CB008083-A Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...      - CB008083-A-B3: Successful AMF selection, the UE provides the registeredAMF IE with GUAMI-Type IE
...                       with or without the requested NSSAI
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
...               [12.11.2022] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Variables   ./resources/amfconfigupdate_hex.py
Library     resources/message_verifier.py

Suite Setup
...     Run Setup     number_of_amfs=3

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_B345_common.lua
${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}

*** Test Cases ***
CB008083-A-B3 RegisteredAMF GuamiType mapped only matching candidate unavailable
    [Tags]    A-B3-13
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify successful AMF procedure selection
    ...  UE provides the registeredAMF IE with GUAMI-Type IE with the requested NSSAI
    ...  Lock NGAP link to AMF1
    ...  Trigger AMF1 to send update with RelativeCapacity 2
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 2
    ...  Connect UE1 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2. Guami Type matches AMF1
	...  AMF2 is selected for UE1 (AMF1 is locked, AMF3 in different set)
	...  Configure actEnhancedNgRanSupport flag to False value
    ...  Connect UE2 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2. Guami Type matches AMF1
	...  AMF2 is selected for UE2 (AMF1 is locked, AMF3 in different set)
	...  Configure actEnhancedNgRanSupport flag to True value
	...  Set AMF1 include_guami_type parameter to on
	...  Unlock NGAP link to AMF1
	...  Setup AMF2 as default AMF
	...  Change AMF3 to be in the same set
    ...  Trigger AMF1 to send update with RelativeCapacity 1
    ...  Trigger AMF2 to send update with RelativeCapacity 255
    ...  Trigger AMF3 to send update with RelativeCapacity 1
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2. Guami Type matches AMF1 and AMF3(notSet)
	...  AMF1 or AMF3 is selected for UE3
	...  AMF2 is never being selected
	...  Configure actEnhancedNgRanSupport flag to False value
    ...  Trigger AMF1 to send update with RelativeCapacity 1
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 2
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2. Guami Type matches AMF1 and AMF3
	...  AMF3 or AMF2 or AMF1 is selected for UE4 (AMF3 is preferable due to better capacity)
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:native,GUAMI2:mapped) with capacity 2 (default amf)
    ...  - AMF2 is configured with 2 GUAMIs (GUAMI2:native,GUAMI3:mapped) with capacity 1
    ...  - AMF3 is configured with 2 GUAMIs from different set (GUAMI1:not set,GUAMI2:not set) with capacity 2
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=off
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF-1.guAMI.guamiType set (native, mapped)
	...  - NRBTS.SERVEDAMF-2.guAMI.guamiType set (native, mapped)
	...  - NRBTS.SERVEDAMF-3.guAMI.guamiType not set
	...  - NRBTS.SERVEDAMF does not have backupamf set for any guami
    ...
    ...  POSTCONDITION:
	...  AMF2 is selected for UE1 (AMF3 is in different set)
	...  AMF2 is selected for UE2 (AMF3 is in different set)
	...  AMF1 or AMF3 is selected for UE3 (AMF1 and AMF3 have equal capacity)
	...  AMF3 is selected for UE4 (AMF3 has best capacity)
	...  - Verify counters:
	...     - AMF_SELECTION_ATT = 80
	...     - AMF_SELECTION_SUCC = 80
	...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17720; CB_FIM_31958
    ...       *BACKLOG ID: FCA_5G_L2L3-116443
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
    ...        [12.11.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate

    Configure actEnhancedNgRanSupport flag to True value
    Setup AMF1 as default AMF
    Unlock NGAP links
    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped
    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-2,guami_type:native
    ...   guami:1-2-3,guami_type:mapped
    # change to different set
    Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-1-1,guami_type:not_set
    ...   guami:1-1-2,guami_type:not_set
    Trigger AMF1 to send update with RelativeCapacity 2
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 2
    Lock NGAP link to AMF1
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 2
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 2
    Verify SERVEDAMFs have no backup AMFs

    start rtpm collection interval

    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE1 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    AMF1 is never being selected
    AMF3 is never being selected
    Clear selected AMFs list

    Configure actEnhancedNgRanSupport flag to False value

    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE2 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    AMF1 is never being selected
    AMF3 is never being selected
    Clear selected AMFs list

    Configure actEnhancedNgRanSupport flag to True value
    Set AMF1 include_guami_type parameter to on     # by default is false for all amfs, configured in lua
    Unlock NGAP link to AMF1
    Setup AMF2 as default AMF
    # change to the same set
    Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-2-1,guami_type:not_set
    ...   guami:1-2-2,guami_type:not_set

    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 255
    Trigger AMF3 to send update with RelativeCapacity 1
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 255
    Verify SERVEDAMF-3 has RelativeCapacity set to 1

    AMF is configured with GUAMIs
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped

    Expect Keyword To Pass With Ratio
    ...      10
    ...      30
    ...      UE3 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF1 is selected
    AMF2 is never being selected
    AMF3 is being occasionally selected
    Clear selected AMFs list

    Configure actEnhancedNgRanSupport flag to False value

    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 2
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 2

    Expect Keyword To Pass With Ratio
    ...      8
    ...      30
    ...      UE4 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF3 is selected
    AMF1 is being occasionally selected
    AMF2 is being occasionally selected
    Clear selected AMFs list

    stop rtpm collection interval
    Wait and check RTPM counters: AMF_SELECTION_ATT 80, AMF_SELECTION_SUCC 80

    [Teardown]   Run keywords
    ...    Cleanup after test A-B3   AND
    ...    rtpm deactivate


