*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         5GC001756: PCMD for SA
...         PCMD records provide per call measurements/statistics data.
...         PCMD provides a "summary" of the UE experience in the signaling, user plane, and RF domains.
...         Feature is mainly aimed at increasing PCMD fields to cover SA scenarios.
...
...      == TEST SET NAME ==
...         5GC001756
...
...      == TESTING SPLIT==
...            5GC001756-B
...            5GC001756-B-B101 Reporting SINR related gNB-DU UP PCMD
...            5GC001756-B-B102 Reporting Timing Advance related gNB-DU UP PCMD
...            5GC001756-B-B201 Reporting gNB-DU UP PCMDs - UP internal changes in deployment
...            5GC001756-D
...            5GC001756-D-B101 Reporting Timing Advance in contention-based RA gNB-DU UP PCMD
...            5GC001756-D-B102 Reporting gNB-DU UP PCMDs - SA user scenarios for legacy PCMDs
...            5GC001756-D-B103 Reporting SINR related gNB-DU UP PCMD in SA mode
...            5GC001756-EA
...            5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
...            5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
...            5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
...            5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
...            5GC001756-EA-B106 gNB-CU PDU Session Info Record for Intra-gNB mobility
...            5GC001756-EA-B107 gNB-CU PDU Session Info Record for Inter-gNB mobility
...            5GC001756-EA-B113 gNB-CU UeDuConnectivity Record for Intra-gNB Inter-DU Handover
...            5GC001756-EA-B114 gNB-CU UeDuConnectivity Record for Inter-gNB Handover (Target gNB)
...            5GC001756-EA-B116 gNB-CU UeDuConnectivity Record for RRC Re-establishment with the same gNB-DU
...            5GC001756-EA-B118 gNB-CU UeDuConnectivity Record for Initial Context Setup
...            5GC001756-EA-B119 gNB-CU UeDuConnectivity Record for PDU Session Resource Setup
...            5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
...            5GC001756-EA-B122 gNB-CU UE Setup Record for Intra-gNB mobility
...            5GC001756-EA-B123 gNB-CU UE Setup Record for Inter-gNB mobility
...            5GC001756-EA-B124 gNB-CU UE Setup Record for miscellaneous cases
...            5GC001756-EA-B125 gNB-CU Bearer Record for Initial Context Setup
...            5GC001756-EA-B126 gNB-CU Bearer Record for PDU Session Resource Setup
...            5GC001756-EA-B127 gNB-CU Bearer Record for PDU Session Resource Modification
...            5GC001756-EA-B128 gNB-CU Bearer Record for PDU Session Resource Release
...            5GC001756-EA-B129 gNB-CU Bearer Record for Intra-gNB mobility
...            5GC001756-EA-B130 gNB-CU Bearer Record for Inter-gNB mobility
...            5GC001756-EA-B201 DU UE context setup record reporting - Initial Context Setup
...            5GC001756-EA-B202 DU UE context setup record reporting - Intra/Inter gNB Inter DU HO target
...            5GC001756-EA-B203 DU UE context setup record reporting - Intra gNB Intra DU HO target
...            5GC0017656-G-B1 Uplane - Multiple Bearers reporting
...
...      == AUTHORS ==
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com
...
...      == REFERENCES ==
...         5GC001756 CFAM
...
...      == HISTORY ==
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
...
...       [30.07.2021] - Created TC
...       [30.07.2021] - Review closed

Resource    ./resources/5GC001756-EA_AMF_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-verify_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/ScoutMonitor.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
...           RF50    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup
...     multiple_amfs=${True}

*** Variables ***
${LUA_CFG}=     ${CURDIR}/config/SA_egate_2c_tdd_3AMF_LO.lua

*** Test Cases ***
5GC001756-EA PCMD for SA - Successfull AMF reselection with different GUAMI
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful AMF reselection with backup AMF provided
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports UE Setup Record after successful AMF reselection
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - NRBTS.actNgcFlexSaMode is set to True
    ...  - AMF1 has backup AMF set to AMF2
    ...  - MRBTS/NRBTS/SERVEDAMF-1 object is configured
    ...  - MRBTS/NRBTS/SERVEDAMF-1.defaultAMF is set to true
    ...  - MRBTS/NRBTS/SERVEDAMF-1.backupAmfName is set to 'AMF2'
    ...  - MRBTS/NRBTS/SERVEDAMF-2 object is configured
    ...  - MRBTS/NRBTS/SERVEDAMF-2.defaultAMF is set to false
    ...  - AMF1 GUAMI is stored in MRBTS/NRBTS/SERVEDAMF-1/guAMI[1]
    ...  - AMF2 GUAMI is stored in MRBTS/NRBTS/SERVEDAMF-1/guAMI[2]
    ...  - guAMI[1] is different then guAMI[2]
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3037
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B124 gNB-CU UE Setup Record for miscellaneous cases
    ...         - User Scenario#2 Successful AMF reselection - backup AMF provided, different GUAMI
    ...
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
    ...
    ...         [28.09.2021] - Created TC
    ...         [28.09.2021] - Review closed

    [Setup]  Prepare test environment EA1
    [Tags]  EA1     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    Clear PCMD Records

    Lock NG-C link with AMF1

    Set expected call flow for successful AMF reselection for UE1
    Trigger UE1 to perform PDU1 session modification by adding QoS flow with 5QI-9
    Verify that backup AMF2 is reselected successfully for UE1
    Verify that QoS flow was successfully added for UE1 after AMF reselection

    Verify CuUeSetupTraceRecord In AMF reselection Test EA1 During successfull backup AMF reselect

#   gNB-CU reports UE Setup Record after successful AMF reselection:
#      - "result" set to "success"
#      - "trigger" set to "other"
#      - RAN UE NGAP ID
#      - Newly selected AMF UE NGAP ID
#      - Globally Unique AMF ID set to GUAMI of newly selected AMF (guAMI[2])

    [Teardown]  Run Keywords
    ...     Cleanup after test EA1    AND
    ...     Restart Scout Monitoring On Test Line If Needed    AND
    ...     Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - Unsuccessful AMF reselection
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Unuccessful AMF reselection with backup AMF not provided
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports UE Setup Record after unsuccessful AMF reselection
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - NRBTS.actNgcFlexSaMode is set to True
    ...  - MRBTS/NRBTS/SERVEDAMF-1 object is configured
    ...  - MRBTS/NRBTS/SERVEDAMF-1.backupAmfName is set to 'AMF2'
    ...  - MRBTS/NRBTS/SERVEDAMF-2 object is configured
    ...  - MRBTS/NRBTS/SERVEDAMF-2.administrativeState is set to Locked
    ...  - AMF1 GUAMI is stored in MRBTS/NRBTS/SERVEDAMF-1/guAMI[1]
    ...  - AMF2 GUAMI is stored in MRBTS/NRBTS/SERVEDAMF-1/guAMI[2]
    ...  - guAMI[1] is different then guAMI[2]
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3037
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B124 gNB-CU UE Setup Record for miscellaneous cases
    ...         - User Scenario#4 Unsuccessful AMF reselection
    ...
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
    ...
    ...         [06.10.2021] - Created TC
    ...         [06.10.2021] - Review closed

    [Setup]  Prepare test environment EA2
    [Tags]  EA2     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Clear PCMD Records

    Lock NG-C link with AMF1

    Set expected call flow for unsuccessful AMF reselection for UE1
    Trigger UE1 to perform PDU1 session modification by adding QoS flow with 5QI-9
    Verify that backup AMF2 is not reselected for UE1

    Verify CuUeSetupTraceRecord In AMF reselection Test EA2 During failure backup AMF reselection

#    gNB-CU reports UE Setup Record after unsuccessful AMF reselection:
#      - "result" set to "miscFailure"
#      - "trigger" set to "other"
#      - RAN UE NGAP ID
#      - AMF UE NGAP ID should not be sent
#      - Globally Unique AMF ID set to GUAMI of AMF2 (guAMI[2])

    [Teardown]  Run Keywords
    ...     Cleanup after test EA2    AND
    ...     Restart Scout Monitoring On Test Line If Needed    AND
    ...     Add Scout External Execution ID To Reporting Portal
