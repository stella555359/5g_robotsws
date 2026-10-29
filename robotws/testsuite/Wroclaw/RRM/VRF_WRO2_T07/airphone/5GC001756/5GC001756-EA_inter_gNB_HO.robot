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

Resource    ./resources/5GC001756-EA_HO_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-verify_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/ScoutMonitor.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
...           RF50    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup
...     vonr=${True}
...     inter_gnb_ho=${True}

*** Variables ***
${LUA_CFG}=     ${CURDIR}/config/SA_egate_2c_tdd_LO.lua

*** Test Cases ***
5GC001756-EA PCMD for SA - Xn inter gNB HO success
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is verification that target gNB-CU report correctly PCMD reports during below procedures:
    ...  Procedure: Successful Inter-gNB Intra-DU Handover
    ...
    ...  PCMD reports:
    ...     gNB-CU PDU Session Info Record is reported after successful Intra-DU Inter-Cell Handover
    ...     gNB-CU UE Setup Record is sent correctly after successful Intra-DU Inter-Cell Handover
    ...
    ...  == Precondition: ==
    ...	 - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - Trace Session with PCMD content is activated on gNB2 Cell-1 for CU
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for NRCELL-1
    ...  - Trace Recording Session for SA UE call is reported to TCE
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036,5G_RAN_USR_COM_3037
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B107 gNB-CU PDU Session Info Record for Inter-gNB mobility
    ...         - User Scenario#1 Successful Inter-gNB Handover
    ...     - 5GC001756-EA-B123 gNB-CU UE Setup Record for Inter-gNB mobility
    ...         - User Scenario#1 Successful Inter-gNB Handover
    ...
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
    ...
    ...         [13.08.2021] - Created TC
    ...         [13.08.2021] - Review closed

    [Setup]  Prepare test environment interHO
    [Tags]  EA1     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with two PDU sessions to simulated gNB3
    Clear PCMD records

    Set expected call flow for UE1 inter-gNB handover from gNB3 to gNB2
    UE1 triggers XNAP Inter-gNB Handover from simulated gNB3 to real gNB2
    Verify that XNAP Inter-gNB Handover was completed successfully for UE1

    Run keyword and Continue on Failure
    ...         Verify First CuUeSetupTraceRecord,PduSessionResourceInfoTraceRecord In inter-gNB HO Test EA1 During incoming HO

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "handover"
#        - "result" is set to "success"
#        - Successfully modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

#    Verify that gNB-CU UE Setup Record is sent correctly
#        - "result" set to "success"
#        - "UE setup reason" set to "other"
#        - RAN UE NGAP ID
#        - AMF UE NGAP ID
#        - Globally Unique AMF ID

    [Teardown]  Run keywords
    ...         Cleanup after test EA    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - Xn inter gNB HO fail
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is verification that target gNB-CU report correctly PCMD reports during below procedures:
    ...  Procedure: Unsuccessful Inter-gNB Handover due to lack of RRC: RRCReconfigurationComplete
    ...
    ...  PCMD reports:
    ...     gNB-CU PDU Session Info Record is reported after successful Intra-DU Inter-Cell Handover
    ...     gNB-CU reports UE Setup Record after successful Intra-DU Inter-Cell Handover
    ...
    ...  == Precondition: ==
    ...	 - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - Trace Session with PCMD content is activated on gNB2 Cell-1 for CU
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for NRCELL-1
    ...  - Trace Recording Session for SA UE call is reported to TCE
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036,5G_RAN_USR_COM_3037
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B107 gNB-CU PDU Session Info Record for Inter-gNB mobility
    ...         - User Scenario#14 Unsuccessful Inter-gNB Handover - failure - timerHOGuard timer expiry - lack of RRC: RRCReconfigurationComplete
    ...     - 5GC001756-EA-B123 gNB-CU UE Setup Record for Inter-gNB mobility
    ...         - User Scenario#12 Unsuccessful Inter-gNB Handover - failure - timerHOGuard timer expiry - lack of RRC: RRCReconfigurationComplete
    ...
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
    ...
    ...         [13.08.2021] - Created TC
    ...         [13.08.2021] - Review closed

    [Setup]  Prepare test environment interHO
    [Tags]  EA2     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with two PDU sessions to simulated gNB3

    Clear PCMD records

    Perform command to drop RRC: Reconfiguration Complete message
    Set expected call flow for failure UE1 inter-gNB handover from gNB3 to gNB2
    UE1 triggers XNAP Inter-gNB Handover from simulated gNB3 to real gNB2
    Verify that XNAP Inter-gNB Handover failed for UE1

    Run keyword and Continue on Failure
    ...         Verify First CuUeSetupTraceRecord,PduSessionResourceInfoTraceRecord In inter-gNB HO Test EA2 During incoming HO

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "handover"
#        - "result" is set to "miscFailure"
#        - Successfully modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of failed to setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

#     Verify that gNB-CU reports UE Setup Record with
#        - "result" set to "miscFailure"
#        - "UE setup reason" set to "other"
#        - RAN UE NGAP ID
#        - Globally Unique AMF ID

    [Teardown]  Run keywords
    ...     Cleanup after test EA       AND
    ...     Restart Scout Monitoring On Test Line If Needed    AND
    ...     Add Scout External Execution ID To Reporting Portal    AND
    ...     Run keyword and ignore error        Restore AP by reset

5GC001756-EA PCMD for SA - Intra-cell Handover
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU does not send PCMD reports during below procedures:
    ...  Procedure: gNB-CU doesn't report UE Setup Record after successful intra-cell handover
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - Trace Session with PCMD content is activated on gNB2 Cell-1 for CU
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for NRCELL-1
    ...  - Trace Recording Session for SA UE call is reported to TCE
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
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
    ...     - 5GC001756-EA-B122 gNB-CU UE Setup Record for Intra-gNB mobility
    ...         - User Scenario#1 Intra-cell Handover
    ...
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
    ...
    ...         [13.08.2021] - Created TC
    ...         [13.08.2021] - Review closed

    [Setup]  Prepare test environment interHO
    [Tags]  EA3     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with two PDU sessions to simulated gNB3

    Clear PCMD records

    Set expected call flow for inter-gNB handover for UE1
    Set expected call flow for UE1 intra-cell handover

    Perform command to initiate UE1 reauthentication

    UE1 triggers XNAP Inter-gNB Handover from simulated gNB3 to real gNB2

    Verify that inter-gNB Handover was completed successfully for UE1
    Verify that AMF sends New Security Context Indicator in NGAP: Path Switch Request Acknowledge message for UE1
    Verify that intra cell intra gNB HO is performed successfully for UE1
    Verify that all requested PDU sessions for UE1 are admitted

    Verify that gNB-CU doesn't report CuUeSetupTraceRecord In intra-gNB HO Test EA3

    [Teardown]  Run keywords
    ...         Cleanup after test EA       AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal    AND
    ...         Run keyword and ignore error        Restore AP by reset

5GC001756-EA PCMD for SA - Xn inter gNB HO PDU Session Resource Release
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is verification that target gNB-CU report correctly PCMD reports during below procedures:
    ...  Procedure: Successful Inter-gNB Intra-DU Handover with PDU Session Resource Release after handover completion
    ...
    ...  PCMD reports:
    ...     gNB-CU PDU Session Info Record is reported after successful Intra-DU Inter-Cell Handover
    ...
    ...  == Precondition: ==
    ...	 - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - Trace Session with PCMD content is activated on gNB2 Cell-1 for CU
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for NRCELL-1
    ...  - Trace Recording Session for SA UE call is reported to TCE
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B107 gNB-CU PDU Session Info Record for Inter-gNB mobility
    ...         - User Scenario#3 Successful Inter-gNB Handover - PDU Session Resource Release after handover completion
    ...
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/5GC001756
    ...
    ...         [13.08.2021] - Created TC
    ...         [13.08.2021] - Review closed

    [Setup]  Prepare test environment interHO
    [Tags]  EA4     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with two PDU sessions to simulated gNB3

    Clear PCMD records

    Set expected call flow for UE1 inter-gNB handover from gNB3 to gNB2
    Set expected call flow for UE1 inter gNB HO PDU Session Resource Release

    Perform command to configures path switch acknowledgement parameter of a specific AMF
    UE1 triggers XNAP Inter-gNB Handover from simulated gNB3 to real gNB2

    Verify that XNAP Inter-gNB Handover was completed with success for UE1
    Verify that Path Switch Request Acknowledge from AMF containing PDUSessionResourceReleasedListPSAck IE with one of established PDU session
    Verify that PDU session indicated in Path Switch Request Acknowledge is released

    Run keyword and Continue on Failure
    ...         Verify PduSessionResourceInfoTraceRecord In inter-gNB HO Test EA4 During PDU session release

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#    "trigger" set to "handover"
#    "result" is set to "success"
#    List of successfully established PDU Session with:
#       - PDU Session Id
#       - S-NSSAI
#       - PDU Session Aggregated Maximum Bit Rate
#       - List of successfully to setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence
#    List of Failed to setup PDU Session (for PDU Sessions requested to be released by AMF) with:
#       - PDU Session Id
#       - S-NSSAI
#       - PDU Session Aggregated Maximum Bit Rate
#       - List of failed to setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence

    [Teardown]  Run keywords
    ...         Cleanup after test EA    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal
