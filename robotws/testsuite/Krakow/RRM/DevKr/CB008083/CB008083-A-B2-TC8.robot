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
...      - CB008083-A-B2: MSC 5G_CP_CONF_739 AMF Configuration Update with GUAMI-Type IE - Success case
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
...               [19.10.2022] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Resource    ./resources/CB008083_counters.robot
Variables   ./resources/amfconfigupdate_hex.py
Library     resources/message_verifier.py

Suite Setup
...     Run Setup     number_of_amfs=3

*** Variables ***
${LUA_CFG}=             ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC8.lua
${SKIP_COUNTERS}=       ${FALSE}

*** Test Cases ***
CB008083-A-B2 Multiple AMFs with AMF Configuration Update after first NG-C link setup attempt
    [Tags]    A-B2-8
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify that after AMF receives NGSetupRequest message, it responds by NGSetupResponse
	...  and NOT includes GUAMI-Type IE within ServedGUAMIList
	...  AMF1 reconfigured to add GUAMI2
	...  AMF2 reconfigured to add GUAMI3
	...  AMF3 reconfigured to add GUAMI1, GUAMI2, GUAMI4
	...	 AMF1 reconfigured to send guami-type for GUAMI1(native) and GUAMI2(mapped)
	...  AMF1 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-1.guAMI.guamiType to configured values
	...	 AMF2 reconfigured to send guami-type for GUAMI2(native) and GUAMI3(mapped)
	...  AMF2 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-2.guAMI.guamiType to configured values
	...	 AMF3 reconfigured to send guami-type for GUAMI1(mapped), GUAMI2(other) and GUAMI4(notSet)
	...  AMF3 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-3.guAMI.guamiType to configured values
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
    ...  - AMF1 is configured with 1 GUAMI (GUAMI1:notSet)
    ...  - AMF2 is configured with 1 GUAMI (GUAMI2:notSet)
    ...  - AMF3 is configured with 1 GUAMI (GUAMI1:notSet)
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMFs are configured with include_guami_type=on
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF.guAMI.guamiType = notSet
    ...
    ...  POSTCONDITION:
    ...  - NG-C link is setup and proper status is updated to OAM
    ...  - AMF sends the message NGAP: AmfConfigurationUpdate with the IE ServedGUAMIList
	...  - gNB-CU-CP stores the new ServedGUAMIList and responds back with NGAP: AMFConfigurationUpdateAcknowledge
	...  - Verify counters:
	...     - NG_CU_AMF_CONFIG_ACK_SENT = 6
	...     - NG_CU_AMF_CONFIG_UPD_RCV = 6
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  CB_FIM_31958, 5G_RAN_USR_RRM_17567
    ...       *BACKLOG ID: FCA_5G_L2L3-116441
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
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
    ...        [19.10.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate

    wait_for_rtpm_before_test  enb_id=1
    clear updates counter
    EXPECT FLOW: AMF1 NGAP aMFConfigurationUpdate
    EXPECT FLOW: AMF2 NGAP aMFConfigurationUpdate
    EXPECT FLOW: AMF3 NGAP aMFConfigurationUpdate

    Execute egate command   cmd=amf_config_update id=1 amfi=1:2:1,1:2:2
    Execute egate command   cmd=amf_config_update id=2 amfi=1:2:2,1:2:3
    Execute egate command   cmd=amf_config_update id=3 amfi=1:2:1,1:2:2,1:2:3,1:2:4

    PASS FLOW: AMF1 NGAP aMFConfigurationUpdate
    PASS FLOW: AMF2 NGAP aMFConfigurationUpdate
    PASS FLOW: AMF3 NGAP aMFConfigurationUpdate
    wait for number of updates          3
    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:not_set
    ...  guami:1-2-2,guami_type:not_set

    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:not_set
    ...  guami:1-2-3,guami_type:not_set

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:not_set
    ...  guami:1-2-2,guami_type:not_set
    ...  guami:1-2-3,guami_type:not_set
    ...  guami:1-2-4,guami_type:not_set

    clear updates counter
    Trigger AMF to change guamiType
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped
    wait for number of updates     1
    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped

    clear updates counter
    Trigger AMF to change guamiType
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped
    wait for number of updates     1
    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped

# Hex send guami-Type='other' due to lack of AP implementation
    clear updates counter
    EXPECT FLOW: AMF3 NGAP aMFConfigurationUpdate
    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF3_TC8}
    ...   source=amf:3
    ...   target=gnb:2
    Sleep  5
    PASS FLOW: AMF3 NGAP aMFConfigurationUpdate
    wait for number of updates       1
    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:mapped
    ...  guami:1-2-2,guami_type:other
    ...  guami:1-2-3,guami_type:mapped
    ...  guami:1-2-4,guami_type:not_set
    ...  skip_check_gnb_view=True

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:mapped
    ...  guami:1-2-2,guami_type:not_set
    ...  guami:1-2-3,guami_type:mapped
    ...  guami:1-2-4,guami_type:not_set
    ...  skip_check_ngc_view=True

    wait_for_rtpm_after_test  enb_id=1
    Check RTPM counters: NG_CU_AMF_CONFIG_UPD_RCV 6, NG_CU_AMF_CONFIG_ACK_SENT 6

    [Teardown]   Run keywords
    ...        Cleanup after test A-B2   AND
    ...        rtpm deactivate
