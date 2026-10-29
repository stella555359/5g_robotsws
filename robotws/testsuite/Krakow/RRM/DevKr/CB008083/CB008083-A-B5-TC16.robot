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
...      CB008083-A Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...      - CB008083-A#B5: MSC 5G_CP_OTH_1213 Successful AMF selection, the UE provides the registeredAMF IE with
...                       GUAMI-Type IE associated AMF and backup AMF are unavailable, default AMF is selected
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
...               [21.11.2022] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Variables   ./resources/amfconfigupdate_hex.py
Library     resources/message_verifier.py

Suite Setup
...     Run Setup     number_of_amfs=3

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC16.lua
${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}

*** Test Cases ***
CB008083-A-B5 RegisteredAMF GuamiType mapped primary and backup down default selected
    [Tags]    A-B5-16
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify successful AMF procedure selection,
    ...  the UE provides the registeredAMF IE with GUAMI-Type IE associated AMF and backup AMF are unavailable,
    ...  default AMF is selected
    ...  SERVEDAMF-3 has backup AMF named 'AMF1' for 2 guamis
    ...  Setup AMF2 as default AMF
    ...  Lock NGAP link to AMF1
    ...  Lock NGAP link to AMF3
    ...  Trigger AMF1 to send update with RelativeCapacity 255
    ...  Trigger AMF2 to send update with RelativeCapacity 0
    ...  Trigger AMF3 to send update with RelativeCapacity 255
    ...  Trigger AMFstatusIndication for AMF2 with unavailable GUAMI index-1
    ...  Connect UE1 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1 and AMF3
    ...  AMF2 is selected as default even when has lowest capacity for UE1. Other links are down
    ...  Connect UE2 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  AMF2 is selected as default even when has lowest capacity for UE2. Other links are down
    ...  Setup AMF1 as default AMF
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1 and AMF3
    ...  Scenario leads to release UE3
    ...  Connect UE4 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  AMF2 is selected as default for UE4
    ...  Setup AMF2 as default AMF
    ...  Configure actEnhancedNgRanSupport flag to False value
    ...  Connect UE5 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1 and AMF3
    ...  AMF2 is selected as default for UE5
    ...  Connect UE6 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  AMF2 is selected as default for UE6
    ...  Setup AMF1 as default AMF
    ...  Connect UE7 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1 and AMF3
    ...  Scenario leads to release UE7
    ...  Connect UE8 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  Scenario leads to release UE8
    ...  Setup AMF2 as default AMF
    ...  Configure actEnhancedNgRanSupport flag to True value
    ...  Reach AMF2 guami configuration: guami:1-2-3,guami_type:mapped
    ...  Connect UE9 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1 and AMF3
    ...  AMF2 is selected as default for UE9
    ...  Connect UE10 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  AMF2 is selected as default for UE10
    ...  Setup AMF1 as default AMF
    ...  Connect UE11 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1 and AMF3
    ...  Scenario leads to release UE11
    ...  Connect UE12 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  Scenario leads to release UE12
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
	...  - SERVEDAMF-1 has no backup AMFs
	...  - SERVEDAMF-2 has no backup AMFs
	...  - SERVEDAMF-3 has backup AMF named 'AMF1' for 2 guamis
    ...
    ...  POSTCONDITION:
	...  AMF2 is selected for all UEs
	...  - Verify counters:
	...     - AMF_SELECTION_ATT = 120
	...     - AMF_SELECTION_SUCC = 120
	...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17722; CB_FIM_31958
    ...       *BACKLOG ID: FCA_5G_L2L3-116445
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
    ...        [21.11.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate

    Verify SERVEDAMF-3 has backup AMF named 'AMF1' for 2 guamis
    Configure actEnhancedNgRanSupport flag to True value
    Setup AMF2 as default AMF
    Unlock NGAP links
    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped
    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-2,guami_type:native
    ...   guami:1-2-3,guami_type:mapped

    # AMF3 configuration must be directly set by lua because both guami_type and backupamf cannot sent in update
    # due to airphone limitation
    AMF is configured with GUAMIs
    ...   AMF3
    ...   guami:1-2-1,guami_type:mapped
    ...   guami:1-2-2,guami_type:mapped
    ...   skip_check_ngc_view=True
    Verify SERVEDAMF-3 has backup AMF named 'AMF1' for 2 guamis
    Trigger AMF1 to send update with RelativeCapacity 255
    Trigger AMF2 to send update with RelativeCapacity 0
    Trigger AMF3 to send update with RelativeCapacity 255
    Lock NGAP link to AMF1
    Lock NGAP link to AMF3
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 255
    Verify SERVEDAMF-2 has RelativeCapacity set to 0
    Verify SERVEDAMF-3 has RelativeCapacity set to 255
    Verify SERVEDAMF-1 has no backup AMFs
    Verify SERVEDAMF-2 has no backup AMFs
    Verify SERVEDAMF-3 has backup AMF named 'AMF1' for 2 guamis
    Trigger AMFstatusIndication for AMF2 with unavailable GUAMI index-1
    AMF is configured with GUAMIs
    ...   AMF2
    ...   guami:1-2-2,guami_type:native,status:unavailable
    ...   guami:1-2-3,guami_type:mapped,status:available
    ...   skip_check_ngc_view=True

    start rtpm collection interval
    start collecting syslog         prefix=01_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE1 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    start collecting syslog         prefix=02_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE2 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    Setup AMF1 as default AMF

    # below leads to release as based on guami-type, backupamf for guami is also not available, the default also
    start collecting syslog         prefix=03_      filtered_lines=AmfSelector
    Run keyword and expect error
    ...      *No messages found in flow*
    ...      Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE3 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    # below leads to successfull selection as guami-type is matched to AMF2, but guami is unavailbale
    # -> then there is not backup -> then amf from the same set is selected, which also is AMF2
    start collecting syslog         prefix=04_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE4 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    Setup AMF2 as default AMF
    Configure actEnhancedNgRanSupport flag to False value


    # below leads to default amf as no guamis and avilable,  backupamf for guami is also not available,
    # the default is selected
    start collecting syslog         prefix=05_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE5 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    # below leads to default amf as no guamis and avilable,  backupamf for guami is also not available,
    # the default is selected
    start collecting syslog         prefix=06_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE6 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    Setup AMF1 as default AMF
    # below leads to release as no guamis and avilable,  backupamf for guami is also not available,
    # the default is also not available
    start collecting syslog         prefix=07_      filtered_lines=AmfSelector
    Run keyword and expect error
    ...      *No messages found in flow*
    ...      Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE7 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    # below leads to release as no guamis and avilable,  backupamf for guami is also not available,
    # the default is also not available
    start collecting syslog         prefix=08_      filtered_lines=AmfSelector
    Run keyword and expect error
    ...      *No messages found in flow*
    ...      Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE8 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    stop rtpm collection interval
    Wait and check RTPM counters: AMF_SELECTION_ATT 80, AMF_SELECTION_SUCC 50

    Setup AMF2 as default AMF
    Configure actEnhancedNgRanSupport flag to True value

    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-3,guami_type:mapped

    start rtpm collection interval          wait_for_next_minute_start=${True}

    # here default is selected, as backup amf is also unavailable
    start collecting syslog         prefix=09_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE9 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    # here default AMF is selected as there is no AMF matching 1-2-2 with native type anymore
    start collecting syslog         prefix=10_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE10 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    Setup AMF1 as default AMF


    # this fails as default , which is selected is not available
    start collecting syslog         prefix=11_      filtered_lines=AmfSelector
    Run keyword and expect error
    ...      *No messages found in flow*
    ...      Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE11 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    # this fails as default , which is selected is not available
    start collecting syslog         prefix=12_      filtered_lines=AmfSelector
    Run keyword and expect error
    ...      *No messages found in flow*
    ...      Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE12 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    stop rtpm collection interval
    Wait and check RTPM counters: AMF_SELECTION_ATT 40, AMF_SELECTION_SUCC 20

    [Teardown]   Run keywords
    ...          Cleanup after test A-B5    AND
    ...          Trigger AMFConfigurationUpdate for AMF2 to restore all guamis disabled by AMFStatusIndication   AND
    ...          rtpm deactivate


