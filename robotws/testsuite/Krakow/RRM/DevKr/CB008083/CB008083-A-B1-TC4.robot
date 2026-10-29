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
...     Run Setup     number_of_amfs=3

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC4.lua

*** Test Cases ***
CB008083-A-B1 Multiple AMFs NG Setup Response after first NG-C link setup attempt
    [Tags]    A-B1-4
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify that after AMF receives NGSetupRequest message, it responds by NGSetupResponse
	...  and includes GUAMI-Type IE within ServedGUAMIList for each AMF
	...	 gNB sets NRBTS.SERVEDAMF.guAMI.guamiType for each AMF to value that was configured in precondition
	...  Message counters NG_CU_SETUP_REQUEST_SENT and NG_CU_SETUP_RESPONSE_RCV are reflecting correct values
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1-3 up and running
    ...  - Established NG connections for each AMF to gNB2
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:native, GUAMI2:mapped)
    ...  - AMF2 is configured with 2 GUAMIs (GUAMI2:native, GUAMI3:mapped)
    ...  - AMF3 is configured with 3 GUAMIs (GUAMI1:mapped, GUAMI3:other, GUAMI4:not_set)
    ...  - GUAMI1-4 has status set to AVAILABLE
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF.guAMI.guamiType = notSet
    ...
    ...  POSTCONDITION:
    ...  - NG-C links are setup and proper status is updated to OAM
    ...  - AMF responds by NGSetupResponse message with GUAMI type within ServedGUAMIList for each AMF
	...  - gNB sets NRBTS.SERVEDAMF.guAMI.guamiType set to value that was configured in preconditions for each AMF
	...  - Verify counters:
	...     - NG_CU_SETUP_REQUEST_SENT = 3
	...     - NG_CU_SETUP_RESPONSE_RCV = 3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17566; CB_FIM_31958
    ...       *BACKLOG ID: FCA_5G_L2L3-116440
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

    EXPECT FLOW[timeout=800]: AMF1 NGAP nGSetup afer gNB reboot
    EXPECT FLOW[timeout=800]: AMF2 NGAP nGSetup afer gNB reboot

    Trigger site reset
    Check radios availability
    Sleep  30

    PASS FLOW[timeout=800]: AMF1 NGAP nGSetup afer gNB reboot
    PASS FLOW[timeout=800]: AMF2 NGAP nGSetup afer gNB reboot

    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established

	Verify that ngap NGSetupRequest message contains mandatory IEs for AMF1
	Verify that ngap NGSetupResponse message contains mandatory IEs for AMF1

	Verify that ngap NGSetupRequest message contains mandatory IEs for AMF2
	Verify that ngap NGSetupResponse message contains mandatory IEs for AMF2

    Execute egate command   cmd=amf_param id=3 ignore_ng=off

    Expect Message Flow
    ...     AMF3:NGAP_NGSetupResponse
    ...     alias=AMF3_NGAP_NGSetupResponse
    ...     overall_timeout=10

    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF1_TC4}
    ...   source=amf:3
    ...   target=gnb:2

    Flow occurred as expected    alias=AMF3_NGAP_NGSetupResponse
    Sleep  15

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

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped

    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped

    wait_for_rtpm_after_test  enb_id=1

    Check RTPM counters: NG_CU_SETUP_REQUEST_SENT 3, NG_CU_SETUP_RESPONSE_RCV 3

    [Teardown]   Run keywords
    ...        Cleanup after test A-B1   AND
    ...        rtpm deactivate
