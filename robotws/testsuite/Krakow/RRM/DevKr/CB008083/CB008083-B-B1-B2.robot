*** Settings ***
Documentation
...   == COPYRIGHT ==
...      Nokia Networks
...
...   == INTRODUCTION ==
...   The feature CB008083 will implement the following gNB enhancements on NG-C interface:
...   - Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...   - Maximum number of NG Setup Retries increased to 1000 (from 100)
...   - Controlled shutdown of the NG-C link , i.e. SCTP association is gracefully shutdown when
...  	- NG-C link is locked, and NG Flex feature is not activated (currently supported when NG Flex feature is activated)
...  	- last SA cell is removed/deactivated
...   - Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...   == TEST SET NAME ==
...      CB008083_NG_enhancements_for_multi-vendor_AMF_support
...
...   == TESTING SPLIT==
...
...
...   == AUTHORS ==
...    - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...    - Marek Kieltyka <marek.kieltyka@nokia.com>
...    - Michal Szymakowski <michal.szymakowski@nokia.com>
...    - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...   == MAINTAINER ==
...    - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...   == REFERENCES ==
...      CB008083 CFAM
...
...   == HISTORY ==
...      [07.10.2022] - Create Test Suite

#Resource    ./resources/CB008083.robot
Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Resource    ta_messaging/single_message_observer.robot

Library     resources/message_verifier.py
#Library     resources/live_guami_view.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...     Run Setup     number_of_amfs=4

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_4amf_B.lua
${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}

*** Test Cases ***
CB008083-B-B1-B2 NG Setup Resquest retries
    [Tags]    B-TC1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test consists of four parts:
    ...  1) Verification that if AMF responds with NG Setup Failure for NG Setup Request messages from gNB,
    ...     and it will respond with NG Setup Response for the last request, NG link will be established and
    ...     EFaultId_NGSetupStopRetryAl will not be raised on AMF.
    ...  2) Verification that if AMF responds with NG Setup Failure for NG Setup Request messages from gNB,
    ...     and number of retries reaches maxNumOfNgSetupRequestRetries value, gNB will stop sending NG Setup Request,
    ...     NG link will not be active and EFaultId_NGSetupStopRetryAl will be raised on AMF.
    ...  3) Verification that if AMF does not respond for NG Setup Request messages from gNB before TimerNGSetupGuard
    ...     expiration, and it will respond with NG Setup Response for the last request, NG link will be established
    ...     and EFaultId_NGSetupStopRetryAl will not be raised on AMF.
    ...  4) Verification that if AMF does not respond for NG Setup Request messages from gNB, and number of retries
    ...     reaches maxNumOfNgSetupRequestRetries value, gNB will stop sending NG Setup Request, NG link will not be
    ...     active and EFaultId_NGSetupStopRetryAl will be raised on AMF.
	...
    ...  == Precondition ==
    ...  - Real gNB2 is up and running
    ...  - Four AMFs are up and running
    ...  - Established NG connections: AMF1-gNB2, AMF2-gNB2, AMF3-gNB2, AMF4-gNB2
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.ngSetupRespTmr = 1
    ...  - NRBTS.maxNumOfNgSetupRequestRetries = 110
	...
    ...  == Postcondition ==
    ...  - NG-C link with AMF1 is setup and proper status is updated to OAM
    ...  - NG-C link with AMF3 is setup and proper status is updated to OAM
    ...  - EFaultId_NGSetupStopRetryAl is raised on AMF2
    ...  - EFaultId_NGSetupStopRetryAl is raised on AMF4
	...  - Verify counters:
	...     - NG_CU_SETUP_FAIL_RCV
    ...     - NG_CU_SETUP_GUARD_TIMER_EXPIRY
	...     - NG_CU_SETUP_REQUEST_SENT
	...     - NG_CU_SETUP_RESPONSE_RCV
	...
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  #ToDo
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - CB008083-B#B1: MSC 5G_CP_CONF_669 NG Setup Failure received from AMF
    ...     - CB008083-B#B2: MSC 5G_CP_CONF_669 NG Setup Timeout - TimerNGSetupGuard expiration
    ...
    ...  == HISTORY ==
    ...     [18.10.2022]  - Created TC

    [Setup]     Prepare test environment B-TC1

    Observe NGSetupRequest for 111 occurrences for 200s for owner AMF1
    Observe NGSetupFailure for 110 occurrences for 200s for owner AMF1
    Observe NGSetupResponse for 1 occurrences for 200s for owner AMF1

    Observe NGSetupRequest for 111 occurrences for 200s for owner AMF2
    Observe NGSetupFailure for 111 occurrences for 200s for owner AMF2

    Observe NGSetupRequest for 111 occurrences for 200s for owner AMF3
    Observe NGSetupResponse for 1 occurrences for 200s for owner AMF3

    Observe NGSetupRequest for 111 occurrences for 200s for owner AMF4

    Reset NG link to AMF1
    Reset NG link to AMF2
    Reset NG link to AMF3
    Reset NG link to AMF4

    Get awaited messages
    ...  NGSetupRequest
    ...  owner_alias=AMF1
    ...  subscriber_owner_alias=AMF1
    ...  occurrences=111

    Get awaited messages
    ...  NGSetupFailure
    ...  owner_alias=AMF1
    ...  subscriber_owner_alias=AMF1
    ...  occurrences=110

    Get awaited messages
    ...  NGSetupResponse
    ...  owner_alias=AMF1
    ...  subscriber_owner_alias=AMF1
    ...  occurrences=1


    Get awaited messages
    ...  NGSetupRequest
    ...  owner_alias=AMF2
    ...  subscriber_owner_alias=AMF2
    ...  occurrences=111

    Get awaited messages
    ...  NGSetupFailure
    ...  owner_alias=AMF2
    ...  subscriber_owner_alias=AMF2
    ...  occurrences=111


    Get awaited messages
    ...  NGSetupRequest
    ...  owner_alias=AMF3
    ...  subscriber_owner_alias=AMF3
    ...  occurrences=111

    Get awaited messages
    ...  NGSetupResponse
    ...  owner_alias=AMF3
    ...  subscriber_owner_alias=AMF3
    ...  occurrences=1


    Get awaited messages
    ...  NGSetupRequest
    ...  owner_alias=AMF4
    ...  subscriber_owner_alias=AMF4
    ...  occurrences=111

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counters: NG_CU_SETUP_REQUEST_SENT 444, NG_CU_SETUP_RESPONSE_RCV 2
    ...                 Check counters: NG_CU_SETUP_GUARD_TIMER_EXPIRY 221, NG_CU_SETUP_FAIL_RCV 221

    Verify that fault 7317 is raised for AMF2
    Verify that fault 7317 is raised for AMF4

    [Teardown]   Cleanup after test B-TC1

*** Keywords ***
