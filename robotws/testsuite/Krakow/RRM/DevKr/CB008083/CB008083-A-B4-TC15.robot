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
...      - CB008083-A#B4: MSC 5G_CP_OTH_1213 Successful AMF selection, the UE provides the registeredAMF IE with GUAMI-Type
...                       IE with or without the requested NSSAI, default AMF is selected
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
${LUA_CFG}=             ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC15.lua
${setup_nwslice}=       ${CURDIR}/config/yaml_config/setup_nwslice_TC15.yaml
${counter_objects}=     ${CURDIR}/config/yaml_config/add_counter_objects.yaml

${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}

*** Test Cases ***
CB008083-A-B4 RegisteredAMF GuamiType mapped NSSAI present guami not found selection based on slice
    [Tags]    A-B4-15
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify successful AMF procedure selection
    ...  UE provides the registeredAMF IE with GUAMI-Type IE without the requested NSSAI
    ...  Trigger AMF1 to send update with RelativeCapacity 1
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 2
    ...  Connect UE1 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice not supported by any AMF
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF2 is selected as default for UE1
    ...  Connect UE2 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
    ...  - NSSAI-list corresponding to slice not supported by any AMF
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF2 is selected as default for UE2
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice supported by AMF1 and AMF3
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF3 is selected more frequently than AMF1 for UE3
    ...  Trigger AMF1 to send update with RelativeCapacity 2
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 1
    ...  Connect UE4 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice supported by AMF1 and AMF3
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF1 is selected more frequently than AMF3 for UE4
    ...  Lock NGAP link to AMF1
    ...  Connect UE5 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice supported by AMF1 and AMF3
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF3 is always selected for UE5
    ...  Unlock NGAP link to AMF1
    ...  Configure actEnhancedNgRanSupport flag to False value
    ...  Trigger AMF1 to send update with RelativeCapacity 1
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 2
    ...  Connect UE1 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice not supported by any AMF
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF2 is selected as default for UE1
    ...  Connect UE2 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to native
    ...  - NSSAI-list corresponding to slice not supported by any AMF
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF2 is selected as default for UE2
    ...  Connect UE3 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice supported by AMF1 and AMF3
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF3 is selected more frequently than AMF1 for UE3
    ...  Trigger AMF1 to send update with RelativeCapacity 2
    ...  Trigger AMF2 to send update with RelativeCapacity 1
    ...  Trigger AMF3 to send update with RelativeCapacity 1
    ...  Connect UE4 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice supported by AMF1 and AMF3
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF1 is selected more frequently than AMF3 for UE4
    ...  Lock NGAP link to AMF1
    ...  Connect UE5 to NRCELL-1. UE sends in RRC Setup Complete:
    ...  - registeredAMF field without PLMN IE and with amf-Identifier:1-2-7 encoded correctly accroding to guami-type sent
    ...  - guami type set to mapped
    ...  - NSSAI-list corresponding to slice supported by AMF1 and AMF3
	...  GUAMI corresponds to guami7, not supported by any AMF
	...  AMF3 is always selected for UE5
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:native,GUAMI2:mapped) with capacity 1
    ...  - AMF2 is configured with 2 GUAMIs (GUAMI2:native,GUAMI3:mapped) with capacity 1 (default amf)
    ...  - AMF3 is configured with 2 GUAMIs (GUAMI1:mapped,GUAMI2:mapped) with capacity 2
    ...  - NWSLICE-1 is configured and supported by AMF1 and AMF3
    ...  - NWSLICE-2 is configured and supported by AMF1-3
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=on
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF-1.guAMI.guamiType set (native, mapped)
	...  - NRBTS.SERVEDAMF-2.guAMI.guamiType set (native, mapped)
	...  - NRBTS.SERVEDAMF-3.guAMI.guamiType set  (mapped, mapped)
	...  - NRBTS.SERVEDAMF does not have backup amf set for any guami
    ...
    ...  POSTCONDITION:
	...  AMF2 is selected as default for UE1
	...  AMF2 is selected as default for UE1
	...  AMF3 is selected more frequently than AMF1 for UE3
	...  AMF1 is selected more frequently than AMF3 for UE4
	...  AMF3 is always selected for UE5
	...  - Verify counters:
	...     - AMF_SELECTION_ATT = 130
	...     - AMF_SELECTION_SUCC = 130
	...  Perform the same scenario with FF set to False
	...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17720; CB_FIM_31958
    ...       *BACKLOG ID: FCA_5G_L2L3-116444
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


    [Setup]  Prepare test environment TC15
    rtpm activate

    Unlock NGAP links
    Verify SERVEDAMF-1 has NGC link Active
    Verify SERVEDAMF-2 has NGC link Active
    Verify SERVEDAMF-3 has NGC link Active
    

    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped

    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-2,guami_type:native
    ...   guami:1-2-3,guami_type:mapped

    Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-2-1,guami_type:mapped
    ...   guami:1-2-2,guami_type:mapped

    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 2
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 2
    Verify SERVEDAMF-1 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-1 has 0x01-0xD143A6 in snssaiAMFList
    Verify SERVEDAMF-2 has 0x01-0xD143A6 in snssaiAMFList
    Verify SERVEDAMF-3 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-3 has 0x01-0xD143A6 in snssaiAMFList

    start rtpm collection interval

    start collecting syslog         prefix=01_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      AMF2 is selected after UE1 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF1 is never being selected
    AMF3 is never being selected
    Clear selected AMFs list

    start collecting syslog         prefix=02_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      AMF2 is selected after UE2 attach with nwslice and guamiType:native

    stop collecting syslog
    AMF1 is never being selected
    AMF3 is never being selected
    Clear selected AMFs list

    start collecting syslog         prefix=03_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      26
    ...      50
    ...      AMF3 is selected after UE3 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF1 is being occasionally selected
    AMF2 is never being selected
    Clear selected AMFs list

    Trigger AMF1 to send update with RelativeCapacity 2
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 1
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 2
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 1

    start collecting syslog         prefix=04_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      26
    ...      50
    ...      AMF1 is selected after UE4 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF3 is being occasionally selected
    AMF2 is never being selected
    Clear selected AMFs list

    Lock NGAP link to AMF1

    start collecting syslog         prefix=05_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      AMF3 is selected after UE5 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF2 is never being selected
    Clear selected AMFs list

    Log To Console    Verify AMF selection counters for actEnhancedNgRanSupport flag set to 'true'
    stop rtpm collection interval
    Wait and check RTPM counters: AMF_SELECTION_ATT 130, AMF_SELECTION_SUCC 130

    Log To Console      Change actEnhancedNgRanSupport flag to 'false'
    Configure actEnhancedNgRanSupport flag to False value

    Unlock NGAP links

    Reach AMF guami configuration
    ...   AMF1
    ...   guami:1-2-1,guami_type:native
    ...   guami:1-2-2,guami_type:mapped

    Reach AMF guami configuration
    ...   AMF2
    ...   guami:1-2-2,guami_type:native
    ...   guami:1-2-3,guami_type:mapped

    Reach AMF guami configuration
    ...   AMF3
    ...   guami:1-2-1,guami_type:mapped
    ...   guami:1-2-2,guami_type:mapped

    Trigger AMF1 to send update with RelativeCapacity 1
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 2
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 1
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 2
    Verify SERVEDAMF-1 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-1 has 0x01-0xD143A6 in snssaiAMFList
    Verify SERVEDAMF-2 has 0x01-0xD143A6 in snssaiAMFList
    Verify SERVEDAMF-3 has 0x01-0xD143A5 in snssaiAMFList
    Verify SERVEDAMF-3 has 0x01-0xD143A6 in snssaiAMFList

    start rtpm collection interval
    start collecting syslog         prefix=11_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      AMF2 is selected after UE1 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF1 is never being selected
    AMF3 is never being selected
    Clear selected AMFs list

    start collecting syslog         prefix=12_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      AMF2 is selected after UE2 attach with nwslice and guamiType:native

    stop collecting syslog
    AMF1 is never being selected
    AMF3 is never being selected
    Clear selected AMFs list

    start collecting syslog         prefix=13_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      26
    ...      50
    ...      AMF3 is selected after UE3 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF1 is being occasionally selected
    AMF2 is never being selected
    Clear selected AMFs list

    Trigger AMF1 to send update with RelativeCapacity 2
    Trigger AMF2 to send update with RelativeCapacity 1
    Trigger AMF3 to send update with RelativeCapacity 1
    discover_bts    bts_id=1
    Verify SERVEDAMF-1 has RelativeCapacity set to 2
    Verify SERVEDAMF-2 has RelativeCapacity set to 1
    Verify SERVEDAMF-3 has RelativeCapacity set to 1

    start collecting syslog         prefix=14_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      26
    ...      50
    ...      AMF1 is selected after UE4 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF3 is being occasionally selected
    AMF2 is never being selected
    Clear selected AMFs list

    Lock NGAP link to AMF1

    start collecting syslog         prefix=15_      filtered_lines=AmfSelector
    Expect Keyword To Pass With Ratio
    ...      10
    ...      10
    ...      AMF3 is selected after UE5 attach with nwslice and guamiType:mapped

    stop collecting syslog
    AMF2 is never being selected
    Clear selected AMFs list

    Log To Console    Verify AMF selection counters for actEnhancedNgRanSupport flag set to 'true'
    stop rtpm collection interval
    Wait and check RTPM counters: AMF_SELECTION_ATT 130, AMF_SELECTION_SUCC 130

    [Teardown]   Run keywords
    ...      Cleanup after test A-B4        AND
    ...      rtpm deactivate

*** Keywords ***
Prepare test environment TC15
    Setup AMF2 as default AMF
    Configure   ${setup_nwslice}
    Configure   ${counter_objects}
    Configure actEnhancedNgRanSupport flag to True value

${amf_alias:AMF\d+} is selected after UE${ue_id:\d+} attach with nwslice and guamiType:${guamiType}
    Run Keyword if  ${ue_id} == 1
    ...    Execute egate command
    ...    cmd=ue_nr_rrc_setup_param id=1 if_contains=any action=send_hex hex=rrc_setup_complete:${UE1_rrcSetupComplete_hex}
    Run Keyword if  ${ue_id} == 2
    ...    Execute egate command
    ...    cmd=ue_nr_rrc_setup_param id=2 if_contains=any action=send_hex hex=rrc_setup_complete:${UE2_rrcSetupComplete_hex}
    Run Keyword if  ${ue_id} == 3
    ...    Execute egate command
    ...    cmd=ue_nr_rrc_setup_param id=3 if_contains=any action=send_hex hex=rrc_setup_complete:${UE3_rrcSetupComplete_hex}
    Run Keyword if  ${ue_id} == 4
    ...    Execute egate command
    ...    cmd=ue_nr_rrc_setup_param id=4 if_contains=any action=send_hex hex=rrc_setup_complete:${UE4_rrcSetupComplete_hex}
    Run Keyword if  ${ue_id} == 5
    ...    Execute egate command
    ...    cmd=ue_nr_rrc_setup_param id=5 if_contains=any action=send_hex hex=rrc_setup_complete:${UE5_rrcSetupComplete_hex}

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete with nwslice and guamiType
    Observe InitialUEMessage for 1 occurrences for 5s
    Execute egate command   cmd=ue_register id=${ue_id}

    Run And Teardown On Failed
    ...     Detach and kill UE${ue_id}
    ...     PASS FLOW[timeout\=10]: UE_${ue_id} NR-RRC RRCSetupComplete with nwslice and guamiType
    ...     Execute egate command
    ...     cmd=ue_nr_rrc_setup_param id=${ue_id} include_nwslice=off if_contains=any action=none registered_amf=none
    Run And Teardown On Failed
    ...     Detach and kill UE${ue_id}
    ...     Verify that for UE${ue_id} RRCSetupComplete message contains nwslice and guamiType set to ${guamiType}
    Run And Teardown On Failed
    ...     Detach and kill UE${ue_id}
    ...     check_that_message_owner_is_matching_expected_owner
    ...     InitialUEMessage
    ...     ${amf_alias}
    ...     ${selected_AMFs_list}

    Detach and kill UE${ue_id}
    Execute egate command
    ...     cmd=ue_nr_rrc_setup_param id=${ue_id} include_nwslice=off if_contains=any action=none registered_amf=none

Verify that for UE${ue_id:\d+} RRCSetupComplete message contains nwslice and guamiType set to ${guamiType}
    ${flow_alias}=     Get flow name
    ...     RRCSetupComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ((guami-Type eq '${guamiType}')
    ...     and
    ...     (sst-SD is present))
    ...     message_alias=RRCSetupComplete
    ...     flow_alias=${flow_alias}
