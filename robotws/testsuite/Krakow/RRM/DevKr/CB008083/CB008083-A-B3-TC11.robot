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
...               [03.11.2022] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Variables   ./resources/amfconfigupdate_hex.py
Library     resources/message_verifier.py

Suite Setup
...     Run Setup     number_of_amfs=3

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC11.lua
${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}

*** Test Cases ***
CB008083-A-B3 RegisteredAMF GuamiType mapped SSAI_list not considered in selection
    [Tags]    A-B3-11
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify successful AMF procedure selection
    ...  UE provides the registeredAMF IE with GUAMI-Type IE with and without the requested NSSAI
    ...  Trigger AMF1 to send update with RelativeCapacity 1
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 255
	...  Lock NG link to AMF-3
    ...  Connect UE1 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  - NSSAI-list corresponding to slice supported only by AMF2  (NWSLICE-2)
	...  GUAMI corresponds to GUAMI2
	...  AMF1 is selected instead of AMF2 for UE1 (NSSAI list is not considered if available AMF found by RegisteredAMF)
    ...  Connect UE2 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-1 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  - NSSAI-list corresponding to slice supported only by AMF2  (NWSLICE-2)
	...  GUAMI corresponds to GUAMI1
	...  AMF1 is selected instead of AMF2 for UE2 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  Setup AMF1 as default AMF with 2 amfs configured
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:notSet encoded correctly accroding to guami-type sent
    ...  - guami type set to notSet
	...  - NSSAI-list corresponding to slice supported only by AMF2  (NWSLICE-2)
	...  GUAMI corresponds to GUAMI1
	...  AMF2 is selected instead of AMF1 for UE3 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  Configure actEnhancedNgRanSupport flag to False value
    ...  Setup AMF2 as default AMF with 2 amfs configured
    ...  Connect UE4 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  - NSSAI-list corresponding to slice supported only by AMF2  (NWSLICE-2)
	...  GUAMI corresponds to GUAMI2
	...  AMF1 is selected instead of AMF2 for UE4 (NSSAI list is not considered if available AMF found by RegisteredAMF)
    ...  Connect UE5 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-1 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  - NSSAI-list corresponding to slice supported only by AMF2  (NWSLICE-2)
	...  GUAMI corresponds to GUAMI1
	...  AMF1 is selected instead of AMF2 for UE5 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  Setup AMF1 as default AMF with 2 amfs configured
    ...  Connect UE6 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:notSet encoded correctly accroding to guami-type sent
    ...  - guami type set to notSet
	...  - NSSAI-list corresponding to slice supported only by AMF2  (NWSLICE-2)
	...  GUAMI corresponds to GUAMI1
	...  AMF2 is selected instead of AMF1 for UE6 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:native,GUAMI2:mapped) with capacity 10
    ...  - AMF2 is configured with 2 GUAMIs (GUAMI2:native,GUAMI3:mapped) with capacity 1 (default amf)
    ...  - AMF3 is configured with 2 GUAMIs (GUAMI1:mapped,GUAMI2:mapped) with capacity 255
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=on
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF-1.guAMI.guamiType set (native, mapped)
	...  - NRBTS.SERVEDAMF-2.guAMI.guamiType set (native, mapped)
	...  - NRBTS.SERVEDAMF-3.guAMI.guamiType set  (mapped, mapped)
	...  - NRBTS.SERVEDAMF does not have backupamf set for any guami
	...  - NRBTS.SERVEDAMF-3.administrativestate locked
    ...
    ...  POSTCONDITION:
	...  AMF1 is selected instead of AMF2 for UE1 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  AMF1 is selected instead of AMF2 for UE2 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  AMF2 is selected instead of AMF1 for UE3 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  AMF1 is selected instead of AMF2 for UE4 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  AMF1 is selected instead of AMF2 for UE5 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  AMF2 is selected instead of AMF1 for UE6 (NSSAI list is not considered if available AMF found by RegisteredAMF)
	...  - Verify counters:
	...     - AMF_SELECTION_ATT = 60
	...     - AMF_SELECTION_SUCC = 60
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
    ...        [03.11.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate
    Configure actEnhancedNgRanSupport flag to True value
    Setup AMF2 as default AMF with 2 amfs configured
    Unlock NGAP links
    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped

    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-2,guami_type:native
    ...   guami:1-2-3,guami_type:mapped

    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 255
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 255
    Verify SERVEDAMF-1 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-2 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-2 has 0x01-0xD143A6 in snssaiAMFList

    start rtpm collection interval
    # s-NSSAI-List:0x01:0xD143A6
    start collecting syslog         prefix=01_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE1 sends amf-Identifier:1-2-2,guami-Type:mapped,s-NSSAI-List:0x01-0xD143A6 and AMF1 is selected
    stop collecting syslog
    AMF2 is never being selected
    Clear selected AMFs list

    start collecting syslog         prefix=02_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE2 sends amf-Identifier:1-2-1,guami-Type:native,s-NSSAI-List:0x01-0xD143A6 and AMF1 is selected
    stop collecting syslog
    AMF2 is never being selected
    Clear selected AMFs list

    Setup AMF1 as default AMF with 2 amfs configured

    start collecting syslog         prefix=03_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE3 sends amf-Identifier:not_set,guami-Type:not_set,s-NSSAI-List:0x01-0xD143A6 and AMF2 is selected
    stop collecting syslog
    AMF1 is never being selected
    Clear selected AMFs list

    Configure actEnhancedNgRanSupport flag to False value
    Setup AMF2 as default AMF with 2 amfs configured

    start collecting syslog         prefix=04_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE4 sends amf-Identifier:1-2-1,guami-Type:mapped,s-NSSAI-List:0x01-0xD143A6 and AMF1 is selected
    stop collecting syslog
    AMF2 is never being selected
    Clear selected AMFs list

    start collecting syslog         prefix=05_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE5 sends amf-Identifier:1-2-1,guami-Type:native,s-NSSAI-List:0x01-0xD143A6 and AMF1 is selected
    stop collecting syslog
    AMF2 is never being selected
    Clear selected AMFs list

    Setup AMF1 as default AMF with 2 amfs configured

    start collecting syslog         prefix=06_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE6 sends amf-Identifier:not_set,guami-Type:not_set,s-NSSAI-List:0x01-0xD143A6 and AMF2 is selected
    stop collecting syslog
    AMF1 is never being selected
    Clear selected AMFs list

    stop rtpm collection interval

    Wait and check RTPM counters: AMF_SELECTION_ATT 60, AMF_SELECTION_SUCC 60

    [Teardown]   Run keywords
    ...        Cleanup after test A-B3   AND
    ...        rtpm deactivate
