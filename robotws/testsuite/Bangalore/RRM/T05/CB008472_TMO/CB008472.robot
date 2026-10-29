*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Rashmi Singh
...             :contact  : rashmi.singh@nokia.com
Resource        resources/Keywords/CB008472_KW.robot
Library         taf.wts.runner      WITH NAME   wtsrunner
Library         taf.sw.syslog       WITH NAME   slog


Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***

${before_HO_drb_ID_21}         before_HO_drb_ID_21
${after_HO_drb_ID_7}           after_HO_drb_ID_7
${before_HO_drb_ID}            before_HO_drb_ID
${after_InterGnHO_drb_ID_5}    after_InterGnHO_drb_ID_5
${after_HO_drb_ID_5}           after_HO_drb_ID_5
${after_HO_drb_ID_HO}          after_HO_drb_ID_HO
${LUA_FILE}        ${CURDIR}/resources/Keywords/scripts.lua
${SW_FlAG}=        0x8900C1 =1

*** Test Cases ***

[1]TC02 Verify Security keys refresh with DRB ID re-allocation due to DRB-ID shortage after PDU SESSION RELEASE
    [Documentation]    The purpose of this test case is to verify DRB ID reallocation after security key refresh triggered ,
    ...        by PDU session release when the number of unused DRB IDs falls below the threshold
    [Tags]   QC_274260     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Prepare For Test Case CB008472
    Start pcap collection in gNB CU      name=before_HO_drb_ID_21
    sleep    5s
    Register Multiple UEs       1       2
    Start data in Multiple UEs       1       2
    Pass Lua File       ${LUA_FILE}
    Initiate VoNR SA UEs     1       2
    Pass Lua File       ${LUA_FILE}
    Data validation before HO
    Perform PDU Session Setup and Release    1     15
    Pass Lua File       ${LUA_FILE}
    Wait For Next Full Pm Interval
    Pass Lua File       ${LUA_FILE}
    Verify Intra-HO     1    2
    Pass Lua File       ${LUA_FILE}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55147C00038   2     ATT_INTRA_CELL_HOS_DRTH
    ...     M55147C00039   2     SUCC_INTRA_CELL_HOS_DRTH
    ...     M55147C00003   2     ATT_INTRA_CELL_HOS
    ...     M55147C00004   2     SUCC_INTRA_CELL_HOS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${before_HO_drb_ID_21}    ${LOG_PATH}
    verify pcap drb_ID      /home/ute/logs/CB008472/before_HO_drb_ID_21/before_HO_drb_ID_21.pcap
    ...      e1ap.System_BearerContextModificationResponse && e1ap.dRB_ID == 20       6
    Start pcap collection in gNB CU      name=after_HO_drb_ID_7
    wtsrunner.Ue Pdu Session Setup    pdu=2    ue=1   nwslice=1   gw=1
    sleep     30s
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${after_HO_drb_ID_7}    ${LOG_PATH}
    verify pcap drb_ID      /home/ute/logs/CB008472/after_HO_drb_ID_7/after_HO_drb_ID_7.pcap
    ...      e1ap.System_BearerContextModificationResponse && e1ap.dRB_ID == 7        2
    Data validation after HO
    [Teardown]   Teardown for CB008472

[1]TC09 Verify DRB ID re-allocation after security keys refresh due to Xn based inter-gNB handover
    [Documentation]    The purpose of this test case is to verify DRB ID reallocation after security key refresh triggered ,
    ...        by PDU session release when the number of unused DRB IDs falls below the threshold
    [Tags]   QC_282610     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Prepare For Test Case CB008472_2
    Start pcap collection in gNB CU      name=before_HO_drb_ID
    sleep    5s
    Start Egate
    Set UE location and source GNB SIB periodicity
    Register UE      1
    Start data in UE    1
    Pass Lua File       ${LUA_FILE}
    Verify Data Before HO   1   1
    Perform multiple PDU Session Setup  2   16
    Pass Lua File       ${LUA_FILE}
    pdu session release for pdu2
    Wait For Next Full Pm Interval
    Perform and verify XN HO
    Pass Lua File       ${LUA_FILE}
    Verify Data After HO   1   1
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${before_HO_drb_ID}    ${LOG_PATH}
    sleep   10s
    Pass Lua File       ${LUA_FILE}
    Start pcap collection in gNB CU      name=after_InterGnHO_drb_ID_5
    wtsrunner.ue_pdu_session_setup     ue=1    pdu=2    nwslice=1   gw=1
    sleep   5s
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${after_InterGnHO_drb_ID_5}    ${LOG_PATH}
	verify pcap drb_ID      /home/ute/logs/CB008472/after_InterGnHO_drb_ID_5/after_InterGnHO_drb_ID_5.pcap
    ...      e1ap.System_BearerContextModificationResponse && e1ap.dRB_ID == 5       2
    Start pcap collection in gNB CU      name=after_HO_drb_ID_HO
    Verify Intracell_HO
    Verify Data After HO   1   1
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${after_HO_drb_ID_HO}    ${LOG_PATH}
    Start pcap collection in gNB CU      name=after_HO_drb_ID_5
    wtsrunner.ue_pdu_session_setup     ue=1    pdu=2    nwslice=1   gw=1
    sleep     30s
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${after_HO_drb_ID_5}    ${LOG_PATH}
	verify pcap drb_ID      /home/ute/logs/CB008472/after_HO_drb_ID_5/after_HO_drb_ID_5.pcap
    ...      e1ap.System_BearerContextModificationResponse && e1ap.dRB_ID == 5        2
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55147C00038   1     ATT_INTRA_CELL_HOS_DRTH
    ...     M55147C00039   1     SUCC_INTRA_CELL_HOS_DRTH
    ...     M55147C00003   1     ATT_INTRA_CELL_HOS
    ...     M55147C00004   1     SUCC_INTRA_CELL_HOS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB008472_2

[1]CA blind Scell addition as part of Security key Refresh triggered due to DRB-ID shortage
    [Documentation]    The purpose of this test case is to verify DRB ID reallocation after security key refresh triggered ,
    ...        by PDU session release when the number of unused DRB IDs falls below the threshold
    [Tags]   QC_323690     QCD_MN_RAN      QCP_RAN_VRF
     [Setup]    Prepare For Test Case CB008472_3
    Start pcap collection in gNB CU      name=before_HO_drb_ID
    sleep    5s
    Register UE and verify blind scell addition      1
    Start high data traffic in UE    1
    Verify Data Before HO   1   1
    pdu session setup and release for UE  2   14
    pdu session setup for pdu2
    Wait For Next Full Pm Interval
    Pass Lua File       ${LUA_FILE}
    Run Keyword And Ignore Error    Verify Intracell_HO and scell addition afterwards
    Run Keyword And Ignore Error    Verify Data After HO   1   1
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${before_HO_drb_ID}    ${LOG_PATH}
    Start pcap collection in gNB CU      name=after_HO_drb_ID_5
    wtsrunner.ue_pdu_session_setup     ue=1    pdu=2    nwslice=1   gw=1
    sleep     30s
    ${pcap_file_path}    Stop pcap collection in gNB 8472    ${after_HO_drb_ID_5}    ${LOG_PATH}
	verify pcap drb_ID      /home/ute/logs/CB008472/after_HO_drb_ID_5/after_HO_drb_ID_5.pcap
    ...      e1ap.System_BearerContextModificationResponse && e1ap.dRB_ID == 5        2
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55147C00038   1     ATT_INTRA_CELL_HOS_DRTH
    ...     M55147C00039   1     SUCC_INTRA_CELL_HOS_DRTH
    ...     M55147C00003   1     ATT_INTRA_CELL_HOS
    ...     M55147C00004   1     SUCC_INTRA_CELL_HOS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB008472_3