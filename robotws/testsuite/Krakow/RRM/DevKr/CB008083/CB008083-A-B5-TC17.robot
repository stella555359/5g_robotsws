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

Suite Setup     Run Setup     number_of_amfs=2

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_B345_common.lua
${amf3_addition}=   ${CURDIR}/config/yaml_config/add_AMF3.yaml
${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}

*** Test Cases ***
CB008083-A-B5 RegisteredAMF GuamiType mapped NGC guami type field absence is treated as native in selection
    [Tags]    A-B5-17
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify successful AMF procedure selection,
    ...  the UE provides the registeredAMF IE with GUAMI-Type IE associated AMF and backup AMF are unavailable,
    ...  default AMF is selected
    ...  Setup AMF2 as default AMF with 2 amfs configured
    ...  Connect UE1 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1
    ...  AMF1 is selected for UE1 (AMF1 is selected because we select guami without taking care of the type)
    ...  Connect UE2 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF1
    ...  AMF1 is selected for UE2 (AMF1 is selected because we select guami without taking care of the type)
    ...  Reach AMF1 guami configuration guami:1-2-1,guami_type:native, guami:1-2-2,guami_type:mapped
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1
    ...  AMF1 is selected for UE3
    ...  Connect UE4 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF2
    ...  AMF2 is selected for UE3
    ...  Reach AMF1 guami configuration guami:1-2-1,guami_type:native, guami:1-2-2,guami_type:other
    ...  Connect UE5 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured at AMF1
    ...  AMF1 is selected for UE5
    ...  Connect UE6 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2, configured at AMF1
    ...  AMF1 is selected for UE6
    ...  Reach AMF1 guami configuration guami:1-2-1,guami_type:mapped
    ...  Connect UE7 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2
    ...  AMF2 is selected for UE7
    ...  Connect UE8 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
	...  GUAMI corresponds to GUAMI2
    ...  AMF2 is selected for UE7
    ...  Configure AMF3
    ...  Reach AMF3 guami configuration guami:1-2-1,guami_type:mapped,guami:1-2-1,guami_type:mapped
    ...  Connect UE9 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured in AMF3
    ...  AMF3 is selected for UE9
    ...  Reach AMF1 guami configuration guami:1-2-1,guami_type:native,guami:1-2-1,guami_type:other
    ...  Trigger AMF1 to send update with RelativeCapacity 1
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 2
    ...  Connect UE10 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured in AMF1 and AMF3
    ...  AMF3 is selected frequently than AMF1 for UE10 due to better capacity
    ...  AMF2 is never being selected
    ...  Reach AMF3 guami configuration guami:1-2-1,guami_type:mapped
    ...  Connect UE11 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-2 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
	...  GUAMI corresponds to GUAMI2, configured in AMF1
    ...  AMF1 is selected for UE11
    ...  AMF2 and AMF3 are never being selected
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1 and AMF2 up and running
    ...  - Established NG connections between each AMFs-gNB2
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:native,GUAMI2:notSet) with capacity 1
    ...  - AMF2 is configured with 1 GUAMI (GUAMI3:mapped) with capacity 1 (default amf)
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=on
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF-1.guAMI.guamiType set (native, notSet)
	...  - NRBTS.SERVEDAMF-2.guAMI.guamiType set (mapped)
	...  - Each SERVEDAMF has no backup AMFs
    ...
    ...  POSTCONDITION:
	...  successful AMF procedure selection occurr based on scenario
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
    ...       *BACKLOG ID: FCA_5G_L2L3-130841
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


    [Setup]     rtpm activate

    Configure actEnhancedNgRanSupport flag to True value
    Setup AMF2 as default AMF with 2 amfs configured
    Unlock NGAP links
    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:not_set
    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-3,guami_type:mapped
    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 1
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 1

    start rtpm collection interval
    start collecting syslog         prefix=01_1
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE1 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF1 is selected
    stop collecting syslog

    start collecting syslog         prefix=01_2
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE2 sends amf-Identifier:1-2-2,guami-Type:native and AMF1 is selected
    stop collecting syslog

    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped

    start collecting syslog         prefix=02_1
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE3 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF1 is selected
    stop collecting syslog

    start collecting syslog         prefix=02_2
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE4 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    clear_updates_counter
    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF1_TC17}
    ...   source=amf:1
    ...   target=gnb:2
    wait for number of updates   1

    AMF is configured with GUAMIs
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:other
    ...   skip_check_gnb_view=True

    AMF is configured with GUAMIs
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:not_set
    ...   skip_check_ngc_view=True

    start collecting syslog      prefix=03_1
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE5 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF1 is selected
    stop collecting syslog

    start collecting syslog      prefix=03_2
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE6 sends amf-Identifier:1-2-2,guami-Type:native and AMF1 is selected
    stop collecting syslog

    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:mapped

    start collecting syslog    prefix=04_1
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE7 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF2 is selected
    stop collecting syslog

    start collecting syslog    prefix=04_2
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE8 sends amf-Identifier:1-2-2,guami-Type:native and AMF2 is selected
    stop collecting syslog

    stop rtpm collection interval

    Configure          ${amf3_addition}       bts_id=1
    Sleep    30
    Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-2-1,guami_type:mapped
    ...   guami:1-2-2,guami_type:mapped

    Wait and check RTPM counters: AMF_SELECTION_ATT 80, AMF_SELECTION_SUCC 80


    start rtpm collection interval    wait_for_next_minute_start=${True}
    start collecting syslog    prefix=05
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE9 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF3 is selected
    stop collecting syslog

    clear_updates_counter
    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF1_TC17}
    ...   source=amf:1
    ...   target=gnb:2
    wait for number of updates   1

    AMF is configured with GUAMIs
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:other
    ...   skip_check_gnb_view=True

    AMF is configured with GUAMIs
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:not_set
    ...   skip_check_ngc_view=True

    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 2
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 2

    start collecting syslog    prefix=06
    Clear selected AMFs list
    Expect Keyword To Pass With Ratio
    ...      8
    ...      20
    ...      UE10 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF3 is selected
    stop collecting syslog
    AMF2 is never being selected
    AMF1 is being occasionally selected

    Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-2-1,guami_type:mapped

    start collecting syslog    prefix=07
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      UE11 sends amf-Identifier:1-2-2,guami-Type:mapped and AMF1 is selected
    stop collecting syslog

    stop rtpm collection interval
    Wait and check RTPM counters: AMF_SELECTION_ATT 40, AMF_SELECTION_SUCC 40

    [Teardown]   Run keywords
    ...          Cleanup after test A-B5    AND
    ...          Configure       {'DEL': 'SERVEDAMF', 'ID': '3'}            AND
    ...          rtpm deactivate


