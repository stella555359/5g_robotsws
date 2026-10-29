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
...      - CB008083-A-B1: MSC 5G_CP_CONF_669 NG Setup Response with GUAMI-Type IE - Success case
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
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Library     resources/message_verifier.py
Variables   ./resources/amfconfigupdate_hex.py

Suite Setup
...     Run Setup     number_of_amfs=1

*** Variables ***
${LUA_CFG}=             ${CURDIR}/config/SA_TDD_2c_1gNBSim_guamiType_native.lua
${yaml_enable_1AMF}=    ${CURDIR}/config/yaml_config/setup_1AMF.yaml

*** Test Cases ***
CB008083-A-B1 Single AMF NG Setup Response with GuamiType set to native
    [Tags]    A-B1-2
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify that after AMF receives NGSetupRequest message, it responds by NGSetupResponse
	...  and includes GUAMI-Type IE within ServedGUAMIList.
	...	 gNB sets NRBTS.SERVEDAMF.guAMI.guamiType set to native.
	...  Message counters NG_CU_SETUP_REQUEST_SENT and NG_CU_SETUP_RESPONSE_RCV are reflecting correct values.
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Single AMF1 up and running
    ...  - Established NG connections AMF1-gNB2
    ...  - AMF1 is configured with 1 GUAMI (GUAMI1)
    ...  - GUAMI1 has status set to AVAILABLE
    ...  - NRBTS.actNgcFlexSaMode = false (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = false
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF.guAMI.guamiType = notSet
	...  - AMF1 configured to send guamiType = native
    ...
    ...  POSTCONDITION:
    ...  - NG-C link is setup and proper status is updated to OAM
    ...  - AMF responds by NGSetupResponse message with GUAMI type within ServedGUAMIList
	...  - gNB sets NRBTS.SERVEDAMF.guAMI.guamiType set to 'native'
	...  - Verify counters:
	...     - NG_CU_SETUP_REQUEST_SENT = 1
	...     - NG_CU_SETUP_RESPONSE_RCV = 1
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
    ...        [07.10.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate

    wait_for_rtpm_before_test  enb_id=1

	Reboot gNB and check radios availability
    Verify that NG link to AMF-1 is established

	Verify that ngap NGSetupRequest message contains mandatory IEs for AMF1
	Verify that ngap NGSetupResponse message contains mandatory IEs for AMF1

    Sleep  5

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native

    wait_for_rtpm_after_test  enb_id=1
    Check RTPM counters: NG_CU_SETUP_REQUEST_SENT 1, NG_CU_SETUP_RESPONSE_RCV 1

    [Teardown]   Run keywords
    ...        Cleanup after test A-B1   AND
    ...        rtpm deactivate

*** Keywords ***
Reboot gNB and check radios availability
    EXPECT FLOW[timeout=800]: AMF1 NGAP nGSetup after gNB reboot
    Trigger site reset
    Check radios availability
    PASS FLOW[timeout=800]: AMF1 NGAP nGSetup after gNB reboot
    Sleep  30
