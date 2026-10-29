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
...               [25.10.2022] - Created TC
...               [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Resource    ./resources/CB008083_counters.robot
Variables   ./resources/amfconfigupdate_hex.py
Library     resources/message_verifier.py

Suite Setup
...     Run Setup     number_of_amfs=3

*** Variables ***
${LUA_CFG}=             ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC9.lua
${SKIP_COUNTERS}=       ${FALSE}

*** Test Cases ***
CB008083-A-B2 Multiple AMFs with AMF Configuration Update received after AMF Status Indication
    [Tags]    A-B2-9
    [Documentation]
    ...
    ...  DESCRIPTION: This test verify that AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type is sent
    ...  Test verify also that AMFstatusIndication is sent for AMF with unavailable GUAMI
    ...  gNB than sets NRBTS.SERVEDAMF.guAMI status to unavailable
	...  AMF1 reconfigured to add GUAMI1, GUAMI2
	...  AMF2 reconfigured to add GUAMI2, GUAMI3
	...  AMF3 reconfigured to add GUAMI1, GUAMI2
	...	 AMF1 reconfigured to send guami-type for GUAMI1(native) and GUAMI2(mapped)
	...  AMF1 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-1.guAMI.guamiType to configured values
	...	 AMF2 reconfigured to send guami-type for GUAMI2(native) and GUAMI3(mapped)
	...  AMF2 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-2.guAMI.guamiType to configured values
	...	 AMF3 reconfigured to send guami-type for GUAMI1(mapped), GUAMI3(other) and GUAMI4(mapped)
	...  AMF3 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-3.guAMI.guamiType to configured values
	...  AMFstatusIndication is sent for AMF1 with unavailable GUAMI1
    ...  gNB sets NRBTS.SERVEDAMF-1.guAMI status to unavailable for GUAMI1
	...  AMF1 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-1.guAMI.guamiType to configured values
	...  AMFstatusIndication is sent for AMF2 with unavailable GUAMI3
    ...  gNB sets NRBTS.SERVEDAMF-2.guAMI status to unavailable for GUAMI3
	...  AMF2 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
    ...  gNB sets NRBTS.SERVEDAMF-2.guAMI.guamiType to configured values
    ...  GUAMI3 GUAMI-Type has been properly set to mapped
	...  AMFstatusIndication is sent for AMF3 with unavailable GUAMI1
	...  gNB sets NRBTS.SERVEDAMF.guAMI status to unavailable for guami1 for AMF3
	...  Reconfigure AMF3 to send different guamiType for GUAMI1
	...  AMF3 configured to send guami-type for GUAMI1(native) and GUAMI3(other) and GUAMI4(mapped)
	...  AMF3 send AmfConfigurationUpdate message with ServedGUAMIList including GUAMI-Type as configured
	...  gNB sets NRBTS.SERVEDAMF-3.guAMI.guamiType to configured values
    ...
    ...  PRECONDITION:
    ...  - Real gNB is up and running
    ...  - Multiple AMF1, AMF2 and AMF3 up and running
    ...  - Established NG connections between each AMFs-gNB2
    ...  - AMF1 is configured with 2 GUAMIs (GUAMI1:notSet,GUAMI2:notSet)
    ...  - AMF2 is configured with 2 GUAMIs (GUAMI2:notSet,GUAMI3:notSet)
    ...  - AMF3 is configured with 2 GUAMIs (GUAMI1:notSet,GUAMI2:notSet)
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
	...     - NG_CU_AMF_CONFIG_ACK_SENT = 7
	...     - NG_CU_AMF_CONFIG_UPD_RCV = 7
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
    ...        [25.10.2022] - Created TC
    ...        [09.12.2022] - Approved by (Avadora Dumitrescu, https://collab.ext.net.nokia.com/ui#review:id=868839)


    [Setup]         rtpm activate

    wait_for_rtpm_before_test  enb_id=1

    EXPECT FLOW: AMF3 NGAP aMFConfigurationUpdate
    Execute egate command   cmd=amf_config_update id=3 amfi=1:2:1,1:2:3,1:2:4
    PASS FLOW: AMF3 NGAP aMFConfigurationUpdate

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:not_set
    ...  guami:1-2-3,guami_type:not_set
    ...  guami:1-2-4,guami_type:not_set

    Trigger AMF to change guamiType
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped
    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped

    Trigger AMF to change guamiType
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped
    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped

# Hex send guami-Type='other' due to lack of AP implementation
    EXPECT FLOW: AMF3 NGAP aMFConfigurationUpdate
    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF3_TC9}
    ...   source=amf:3
    ...   target=gnb:2
    Sleep  5
    PASS FLOW: AMF3 NGAP aMFConfigurationUpdate

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:mapped
    ...  guami:1-2-3,guami_type:other
    ...  guami:1-2-4,guami_type:mapped
    ...  skip_check_gnb_view=True

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:mapped
    ...  guami:1-2-3,guami_type:not_set
    ...  guami:1-2-4,guami_type:mapped
    ...  skip_check_ngc_view=True

#    send AMFStatusIndication
    Trigger AMFstatusIndication for AMF1 with unavailable GUAMI index-1

    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native,status:unavailable
    ...  guami:1-2-2,guami_type:mapped,status:available

    Trigger AMF to change guamiType
    ...  AMF1
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-2,guami_type:mapped
    AMF is configured with GUAMIs
    ...  AMF1
    ...  guami:1-2-1,guami_type:native,status:available
    ...  guami:1-2-2,guami_type:mapped,status:available

    Trigger AMFstatusIndication for AMF2 with unavailable GUAMI index-2

    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:native,status:available
    ...  guami:1-2-3,guami_type:mapped,status:unavailable

    Trigger AMF to change guamiType
    ...  AMF2
    ...  guami:1-2-2,guami_type:native
    ...  guami:1-2-3,guami_type:mapped
    AMF is configured with GUAMIs
    ...  AMF2
    ...  guami:1-2-2,guami_type:native,status:available
    ...  guami:1-2-3,guami_type:mapped,status:available

    Trigger AMFstatusIndication for AMF3 with unavailable GUAMI index-1

# Hex send guami-Type='other' due to lack of AP implementation
    EXPECT FLOW: AMF3 NGAP aMFConfigurationUpdate
    run command
    ...   send_hex
    ...   hex=${aMFConfigurationUpdate_AMF3_TC9_2}
    ...   source=amf:3
    ...   target=gnb:2
    Sleep  5
    PASS FLOW: AMF3 NGAP aMFConfigurationUpdate

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-3,guami_type:other
    ...  guami:1-2-4,guami_type:mapped
    ...  skip_check_gnb_view=True

    AMF is configured with GUAMIs
    ...  AMF3
    ...  guami:1-2-1,guami_type:native
    ...  guami:1-2-3,guami_type:not_set
    ...  guami:1-2-4,guami_type:mapped
    ...  skip_check_ngc_view=True

    wait_for_rtpm_after_test  enb_id=1
    Check RTPM counters: NG_CU_AMF_CONFIG_UPD_RCV 7, NG_CU_AMF_CONFIG_ACK_SENT 7

    [Teardown]   Run keywords
    ...        Cleanup after test A-B2   AND
    ...        rtpm deactivate
