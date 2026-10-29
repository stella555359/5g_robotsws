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
...               [12.10.2022] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Variables   ./resources/amfconfigupdate_hex.py
Library     resources/message_verifier.py

Suite Setup
...     Run Setup     number_of_amfs=1

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_1amf_TC5.lua

*** Test Cases ***
CB008083-A-B1 Single AMF multiple GUAMIs NG Setup Response
    [Tags]    A-B1-5
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify that after AMF1 receives NGSetupRequest message, it responds by NGSetupResponse
	...  and NOT includes GUAMI-Type IE within ServedGUAMIList
	...	 gNB does not set NRBTS.SERVEDAMF.guAMI.guamiType
	...  Lock NG link to AMF1
	...  AMF1 is configured to send guami-type: GUAMI4-mapped
	...  Unlock NG link to AMF1
	...  gNB sets NRBTS.SERVEDAMF.guAMI.guamiType for GUAMI4 to value that was configured in precondition
	...  Lock NG link to AMF1
	...  AMF1 is configured to send guamis-type: GUAMI1-native, GUAMI2-mapped, GUAMI3-other
	...  Unlock AMF1 link
	...  AMF1 receives NGSetupRequest message, it responds by NGSetupResponse with GUAMI-Types IE within ServedGUAMIList
	...  gNB sets NRBTS.SERVEDAMF.guAMI.guamiType for GUAMI1, GUAMI2 and GUAMI3 to value that was configured in precondition
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Single AMF1 up and running
    ...  - Established NG connections AMF1-gNB2
    ...  - AMF1 is configured with 4 GUAMIs (GUAMI1:native, GUAMI2:mapped, GUAMI3:other, GUAMI4:not_set)
    ...  - All GUAMIs has status set to AVAILABLE
    ...  - AMF1 is configured with include_guami_type=off
    ...  - NRBTS.actNgcFlexSaMode = true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval = true
	...	 - NRBTS.actEnhancedNgRanSupport = true
	...  - NRBTS.SERVEDAMF.guAMI.guamiType = not set
    ...
    ...  POSTCONDITION:
    ...  - NG-C link is setup and proper status is updated to OAM
    ...  - AMF responds by NGSetupResponse message with GUAMI type within ServedGUAMIList if include_guami_type=on
	...  - gNB sets NRBTS.SERVEDAMF.guAMI.guamiType set to value that was configured during the test
	...  - Verify counters:
	...     - NG_CU_SETUP_REQUEST_SENT = 2
	...     - NG_CU_SETUP_RESPONSE_RCV = 2
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
    ...        [12.10.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:not_set
    ...  guami:1-2-2,guami_type:not_set
    ...  guami:1-2-3,guami_type:not_set
    ...  guami:1-2-4,guami_type:not_set

    Lock NGAP link to AMF1

    wait_for_rtpm_before_test  enb_id=1
    Set AMF1 include_guami_type parameter to on

    EXPECT FLOW: AMF1 NGAP nGSetup
    Unlock NGAP link to AMF1
    PASS FLOW: AMF1 NGAP nGSetup

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:not_set
    ...  guami:1-2-2,guami_type:not_set
    ...  guami:1-2-3,guami_type:not_set
    ...  guami:1-2-4,guami_type:mapped

    Lock NGAP link to AMF1
    Execute egate command   cmd=amf_param id=1 ignore_ng=on

    Unlock NGAP link to AMF1

    Execute egate command   cmd=amf_param id=1 ignore_ng=off

    Expect Message Flow
    ...     AMF1:NGAP_NGSetupResponse
    ...     alias=AMF1_NGAP_NGSetupResponse
    ...     overall_timeout=10

    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF1_TC5}
    ...   source=amf:1
    ...   target=gnb:2

    Flow occurred as expected    alias=AMF1_NGAP_NGSetupResponse

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped
    ...  guami:1-2-3,guami_type:other
    ...  skip_check_gnb_view=True

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped
    ...  guami:1-2-3,guami_type:not_set
    ...  skip_check_ngc_view=True

    wait_for_rtpm_after_test  enb_id=1
    Check RTPM counters: NG_CU_SETUP_REQUEST_SENT 2, NG_CU_SETUP_RESPONSE_RCV 2

    [Teardown]   Run keywords
    ...        Cleanup after test A-B1   AND
    ...        rtpm deactivate
