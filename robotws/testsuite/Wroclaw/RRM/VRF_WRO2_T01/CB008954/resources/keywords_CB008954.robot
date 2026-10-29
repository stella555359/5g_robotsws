*** Settings ***
Documentation
...  Author:        Maciej Cupial
...  Contact:       maciej.cupial@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   functions and keywords

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         Collections
Library         String
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008954/resources/keywords_CB008954.py    WITH NAME    8954_lib
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.py    WITH NAME    pcap
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_cplane.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/cplane_collector.robot  # KW: Setup cplane tcpdump collector
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010443/resources/keywords_10443.robot    # KW: commissionings 10443
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords_10442.robot    # KW: commissionings 10442
Library         taf.sbts.oam.coam.admin  WITH NAME  coam

Library         pcap_cplane.pdml            WITH NAME   pdmlp
Library         taf.converters.pcaptopdml   WITH NAME   pcaptopdml


*** Variables ***
${BTS_ID}                ${tl.gnbs[0].instance_id}
${MAIN_SCF_PATH}         MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${RMOD4}            /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-4
${RMOD5}            /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-5
${CELL911}          /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-50050/NRCELL_R-4
${CELL922}          /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-50050/NRCELL_R-5
@{LTE_40040}             ${13}    ${14}


*** Keywords ***
Check average and max Tput    # based on multi_UE.robot
    ${av_tputs}   Await datatransfers finish
    ${max_tputs}  Get max tputs from data transfer statistics
    [Return]  ${av_tputs}  ${max_tputs}

Check Average Tput
    Attach UEs and start tput          ${UE}  udp  both  ${TPUT_TIME}  res=off
    ${avg_tputs}  ${max_tputs}          Check average and max Tput
    ${max_tput}=  Set Variable  ${max_tputs}[0]
    ${avg_tput}=  Set Variable  ${avg_tputs}[0]
    Log  <h1>MAX: ${max_tput}</h1><h1>AVG: ${avg_tput}</h1>     html=yes
    [Return]      ${avg_tput}

Check And Add Average Tput To ALL_BWPS_TPUT_LIST
    [Documentation]    Check average tput when specific EFS file is loaded. Collect cplane. Append tput value
    ...                to the list ALL_BWPS_TPUT_LIST
    [Arguments]    ${bwp}    ${ALL_BWPS_TPUT_LIST}
    Log To Console    \n__Check avg Tput for ${bwp}
    Setup cplane tcpdump collector    name=cplane_${bwp}
    Start cplane logs
    ${avg_tput}    Check Average Tput
    Stop cplane logs      log_dir=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/BWP_cplanes/
    Append To List  ${ALL_BWPS_TPUT_LIST}    ${avg_tput}
    Log    ${ALL_BWPS_TPUT_LIST}
    [Return]    ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/BWP_cplanes/cplane_${bwp}/cplane_${bwp}.pcap

Check Tput Dependencies
    [Documentation]    Check if throughput dependencies are met: bwp_L > bwp_M > bwp_S --> [bwp_L, bwp_M, bwp_S]
    ...    If len(ALL_BWPS_TPUT_LIST) == 0 OR len(ALL_BWPS_TPUT_LIST) >= 4: raise an error for amount of list elements
    [Arguments]    ${ALL_BWPS_TPUT_LIST}
    ${length}    Get Length    ${ALL_BWPS_TPUT_LIST}
    Run Keyword If    ${length} == ${1}    Log    Waiting for more data to compare throughput values (BWP_L added only)
    ...    ELSE IF    ${length} == ${2}    Log    Two throughput values will be compared: BWP_L > BWP_M
    ...        AND    Should Be True  ${ALL_BWPS_TPUT_LIST}[0] > ${ALL_BWPS_TPUT_LIST}[1]
    ...    ELSE IF    ${length} == ${3}    Run Keywords
    ...               Log    Three throughput values will be compared: BWP_L > BWP_S    #BWP_L > BWP_M > BWP_S
    ...        AND    Should Be True  ${ALL_BWPS_TPUT_LIST}[0] > ${ALL_BWPS_TPUT_LIST}[1] > ${ALL_BWPS_TPUT_LIST}[2]
    ...    ELSE    Fail    There is no elements in ALL_BWPS_TPUT_LIST list or more than expected

Check Throughput Statuses When Emergency Call
    [Documentation]  Emergency call should be performed. In this case using KW: Start Voice Call.
    ...  When Tput is ongoing then Voice Call is performed. Tput should be freezed and Voice Call shoud be running.
    ...  Next, when Voice Call is stopped then after few seconds Tput should be unfreezed and ongoing again.
    ...  To perform Voice Call you have to set default app. On your UE go to Apps/Choose default apps / Phone app
    ...  for "Phone app" please choose "NAA"
    ...  Example of usage in wro8:  .../VRF_WRO2_T08/features/CB010850/resources/test_specific_keywords.robot
    Attach UEs to cell    ${UE}
    Start Voice Call    vc_alias=VC    ue_alias=${UE}[0]    to=911    duration=20s
    Sleep    5s
    Stop Voice Call    vc_alias=VC
    Sleep    10s
    Start DL for UEs    ${UE}
    Await datatransfers finish

Verify Throughput Value
    [Arguments]    ${bwp}    ${AVG_TPUT}    ${bwp_tput}
    Log to console  Arguments: ${bwp}    ${AVG_TPUT}    ${bwp_tput}
    Run Keyword If    '${bwp}' == 'M_80MHz'
    ...    Calculate Throughput Range For Specific BWP Profile  ${AVG_TPUT}  ${bwp_tput}  ${0.8}
    ...    ELSE IF    '${bwp}' == 'S_50MHz'
    ...    Calculate Throughput Range For Specific BWP Profile  ${AVG_TPUT}  ${bwp_tput}  ${0.5}
    ...    ELSE    Log    No action needed for L_100MHz

Calculate Throughput Range For Specific BWP Profile
    [Arguments]    ${AVG_TPUT}    ${bwp_tput}    ${bwp_percent}
    ${AVG_TPUT}    Convert To Number    ${AVG_TPUT}
    ${bwp_tput}    Convert To Number    ${bwp_tput}
    ${expected_tput}         Evaluate    ${AVG_TPUT} * ${bwp_percent}
    ${expected_tput_min}     Evaluate    ${expected_tput} - ${expected_tput} * ${0.2}
    ${expected_tput_max}    Evaluate    ${expected_tput} + ${expected_tput} * ${0.2}
    Log    <h1>MIN range: ${expected_tput_min} <br>tput: ${bwp_tput} <br>MAX range: ${expected_tput_max}</h1>   html=yes
    Should Be True    ${bwp_tput} >= ${expected_tput_min} and ${bwp_tput} <= ${expected_tput_max}


Lock Specific RU
    [Arguments]     ${ru_to_lock}    ${alias}=cOAM
    common_kw.Connect with runtime release    ${alias}
    Log To Console    ${RMOD5} is locking...
    coam.lock    dist_name=${ru_to_lock}    timeout=600s    connection=${alias}
    [Teardown]    coam.teardown          connection=${alias}

Unlock Specific RU
    [Arguments]     ${ru_to_unlock}    ${alias}=cOAM
    common_kw.Connect with runtime release    ${alias}
    Log To Console    ${RMOD5} is unlocking...
    coam.unlock    dist_name=${ru_to_unlock}    timeout=600s    connection=${alias}
    [Teardown]    coam.teardown          connection=${alias}

Verify Counters For Specific Bwp
    [Arguments]    ${bwp}
    Log to console     Verify Counters For Specific Bwp
    Run Keyword If    '${bwp}' == 'M_80MHz'
    ...    Verifying Counters CB5 Until Keyword Succeeds    ${CB5_BWP_M}
    ...    ELSE IF    '${bwp}' == 'S_50MHz'
    ...    Verifying Counters CB5 Until Keyword Succeeds   ${CB5_BWP_S}
    ...    ELSE    Verifying Counters CB5 Until Keyword Succeeds    ${CB5_BWP_L}

Verify Handover Procedure
    [Documentation]     M55147C00001: CELLS/NRCELL-4/NMOCU/TOT_INTRA_FREQ_HO_DECISION_A3S
    ...    M55145C00301: CELLS/NRCELL-4/MCC-310_MNC-260/NRANS/ATT_INTRA_DU_HO_SA_PLMN
    ...    M55145C00302: CELLS/NRCELL-4/MCC-310_MNC-260/NRANS/SUCC_INTRA_DU_HO_SA_PLMN
    &{handover_counters}    Get counters    ${HANDOVER}
    &{nmocu_counters}       pu.get last counters values  ${handover_counters['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NMOCU']}
    &{nrans_counters}       pu.get last counters values
    ...    ${handover_counters['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['MCC-310']['MNC-260']['NRANS']}

    pu.check counters are greater than zero   ${nmocu_counters}
    pu.check counters are greater than zero   ${nrans_counters}

Verifying Counters CB5 Until Keyword Succeeds
    [Documentation]
    ...  BWP_L: M55139C02504 - GNB_SA_DU_ADM_SUCC_BWP3, M55166C00512 - NRRC_RCFG_CMP_BWP3_RCVD
    ...  BWP_M: M55139C02502 - GNB_SA_DU_ADM_SUCC_BWP2, M55166C00004 - NRRC_RCFG_CMP_BWP2_RCVD
    ...  BWP_S: M55139C02501 - GNB_SA_DU_ADM_SUCC_BWP1, M55166C00003 - NRRC_RCFG_CMP_BWP1_RCVD
    ...  paths: CELLS/NRCELL-x/RSADU/    and     CELLS/NRCELL-x/NRCCD/
    [Arguments]    ${counters_CB5}
    Log to console      Verifying Counters CB5 Until Keyword Succeeds
    Wait Until Keyword Succeeds    10min    30s    Verify Counters CB5    ${counters_CB5}

Verify Counters CB5
    [Arguments]    ${input_counters_CB5}
    &{counters_CB5}        Get counters    ${input_counters_CB5}
    &{rsadu_counters}      pu.get last counters values  ${counters_CB5['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['RSADU']}
    &{nrccd_counters}      pu.get last counters values  ${counters_CB5['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NRCCD']}
    pu.check counters are greater than zero   ${rsadu_counters}
    pu.check counters are greater than zero   ${nrccd_counters}

Perform Many Attach Detach
    Log To Console  Multi attach-detach is ongoing...
    FOR    ${idx}  IN RANGE    ${5}
        Log to console      idx:${idx}
        Attach Ue  ${UE}[0]
        Detach UE  ${UE}[0]
    END

Verify Counters When Second BWP Active
    [Documentation]
    ...  All counters for BWP2 and all BWP1 (except: M55166C00001, M55166C00003) should be > 0.
    ...  All counters for BWP3 + M55166C00001 + M55166C00003 should be = 0.
    [Arguments]    ${CB2_higher_than_zero}    ${CB2_equals_zero}
    Log to console    __Checking counters values...
    Wait Until Keyword Succeeds    10min    30s    Verify Counters CB2    ${CB2_higher_than_zero}    ${CB2_equals_zero}

Verify Counters CB2
    [Arguments]    ${input_CB2_higher_than_zero}    ${input_CB2_equals_zero}
    &{CB2_higher_than_zero}     Get counters    ${input_CB2_higher_than_zero}
    &{CB2_equals_zero}          Get counters    ${input_CB2_equals_zero}

    &{NCELA_counters}  pu.get last counters values  ${CB2_higher_than_zero['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NCELA']}
    &{NRCCD_counters}  pu.get last counters values  ${CB2_higher_than_zero['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NRCCD']}
    &{CB2_higher_than_zero}    8954_lib.merge_dicts    ${NCELA_counters}    ${NRCCD_counters}

    &{NCELA_counters}  pu.get last counters values  ${CB2_equals_zero['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NCELA']}
    &{NRCCD_counters}  pu.get last counters values  ${CB2_equals_zero['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NRCCD']}
    &{CB2_equals_zero}    8954_lib.merge_dicts    ${NCELA_counters}    ${NRCCD_counters}

    pu.check counters are zero    ${CB2_equals_zero}
    pu.check counters are greater than zero   ${CB2_higher_than_zero}


Perform 10442/10443 Activation
    [Documentation]    Activate 10442 and 10443 feature
    ${lte_cell_id}    Set Variable    40044
    ${global_5g_cell_id}    Set Variable    5
    Activate 10442
    Activate 10443
    Wait For LTE And 5G Energy Saving Cells Are In Power Saving State
    ...    ${lte_cell_id}
    ...    ${global_5g_cell_id}
    Wait for lbpsGuardTimerNrAct


Perform 10442/10443 Deactivation
    [Documentation]    Deactivate 10442 and 10443 feature
    Log to console  Perform 10442/10443 Deactivation
#    Deactivate 10442    # TODO
    Deactivate 10443


Verify PS Counters When Small BWP Active
    [Documentation]    Counters {DB2_BWP_S} must be > 0 and M55110C00037 = 0. Wait until keyword succeeds.
    [Arguments]    ${DB2_BWP_S}    ${DB2_BWP_S_zero}
    Log to console    __Checking counters values...
    Wait Until Keyword Succeeds    10min    30s    Verify Counters DB2    ${DB2_BWP_S}    ${DB2_BWP_S_zero}


Verify Counters DB2
    [Documentation]    Counters {DB2_BWP_S} must be > 0 and M55110C00037 = 0
    [Arguments]    ${input_DB2_BWP_S}    ${input_DB2_BWP_S_zero}

    &{DB2_BWP_S}        Get counters    ${input_DB2_BWP_S}
    &{DB2_BWP_S_zero}   Get counters    ${input_DB2_BWP_S_zero}
    Log to console  &{DB2_BWP_S}    &{DB2_BWP_S_zero}
#
#    &{*_counters}  pu.get last counters values  ${DB2_BWP_S['BTS']['CELLS']['NRCELL-4']['*']}
#    &{*_counters}  pu.get last counters values  ${DB2_BWP_S['BTS']['CELLS']['NRCELL-4']['*']}
#    &{DB2_BWP_S}    8954_lib.merge_dicts    ${NCELA_counters}    ${NRCCD_counters}
#
#    &{_counters}  pu.get last counters values  ${DB2_BWP_S_zero['BTS']['CELLS']['NRCELL-4']['NCELA']}
#    &{_counters}  pu.get last counters values  ${DB2_BWP_S_zero['BTS']['CELLS']['NRCELL-4']['NRCCD']}
#    &{DB2_BWP_S_zero}    8954_lib.merge_dicts    ${NCELA_counters}    ${NRCCD_counters}
#
#    pu.check counters are zero    ${DB2_BWP_S_zero}
#    pu.check counters are greater than zero   ${DB2_BWP_S}


Block Specific Cell
    [Arguments]    ${cell_to_block}    ${alias}=cOAM
    common_kw.Connect with runtime release    ${alias}
    Log To Console    __Cell ${cell_to_block} is blocking...
    coam.block_cell   dist_name=${cell_to_block}   connection=${alias}  timeout=300
    [Teardown]    coam.teardown          connection=${alias}


Unblock Specific Cell
    [Arguments]    ${cell_to_unblock}    ${alias}=cOAM
    common_kw.Connect with runtime release    ${alias}
    Log To Console    __Cell ${cell_to_unblock} is unblocking...
    coam.unblock_cell   dist_name=${cell_to_unblock}   connection=${alias}  timeout=300
    [Teardown]    coam.teardown          connection=${alias}


Verify Counters CB8 For Specific Bwp
    [Arguments]    ${bwp}
    Log to console    Verify Counters CB8 For Specific Bwp
    Run Keyword If    '${bwp}' == 'M_80MHz'
    ...    Verifying Counters CB8 Until Keyword Succeeds    ${CB8_M}    ${HO_NSA}
    ...    ELSE IF    '${bwp}' == 'S_50MHz'
    ...    Verifying Counters CB8 Until Keyword Succeeds   ${CB8_S}    ${HO_NSA}
    ...    ELSE    Verifying Counters CB8 Until Keyword Succeeds    ${CB8_L}    ${HO_NSA}


Verifying Counters CB8 Until Keyword Succeeds
    [Documentation]
    ...  BWP_L: M55166C00511 - NRRC_RRC_RECONF_BWP3_SENT, M55166C00512 - NRRC_RCFG_CMP_BWP3_RCVD
    ...  BWP_M: M55166C00002 - NRRC_RRC_RECONF_BWP2_SENT, M55166C00004 - NRRC_RCFG_CMP_BWP2_RCVD
    ...  BWP_S: M55166C00001 - NRRC_RRC_RECONF_BWP1_SENT, M55166C00003 - NRRC_RCFG_CMP_BWP1_RCVD
    ...  paths: MRBTS-50050/NRBTS-50050/NRCELL-4/NRCCD/
    [Arguments]    ${counters_CB8}    ${HO_NSA}
    Log To Console    __Waiting until 'Verify Counters CB8' succeeds...
    Wait Until Keyword Succeeds    10min    30s    Verify Counters CB8    ${counters_CB8}    ${HO_NSA}

Verify Counters CB8
    [Arguments]    ${input_counters_CB8}    ${input_HO_NSA}
    &{counters_CB8}     Get counters    ${input_counters_CB8}
    &{HO_NSA}           Get counters    ${input_HO_NSA}
    &{NCCCD_counters}  pu.get last counters values  ${counters_CB8['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NRCCD']}
    &{HO_NSA_counters}  pu.get last counters values
    ...    ${HO_NSA['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['MCC-310']['MNC-260']['NRANS']}
    Log    ${NCCCD_counters}
    Log    ${HO_NSA_counters}
    &{counters_CB8}    8954_lib.merge_dicts    ${NCCCD_counters}    ${HO_NSA_counters}
    pu.check counters are greater than zero   ${counters_CB8}


Perform commissioning 8954
    [Documentation]    Commissioning for 8954. Just turning on PRB Blanking CB009915
    [Arguments]    ${actPRBBlanking}=true
    Log To Console     __Activate PRB blanking
    ds.Initialise delta store
    ${cell_dists}       ah.Get cells distname list
    FOR    ${cell_id}    IN    @{cell_dists}
        ds.Add param to delta    ${MAIN_SCF_PATH}/${cell_id}    actPRBBlanking         value=${actPRBBlanking}
    END
    ${delta}            ds.Collect delta store
    ah.Recommission with delta from admin  ${delta}
    Verify If All Cells Are Onair


Verifying Counters CB7 Until Keyword Succeeds
    [Documentation]
    ...  Only BWP_L (BWP3) ins this scenario:
    ...  M55166C00511 - NRRC_RRC_RECONF_BWP3_SENT, M55166C00512 - NRRC_RCFG_CMP_BWP3_RCVD
    ...  M55308C00081 - ACC_UE_DL_SCH_SLOT_BWP3, M55308C00082 - MAX_UE_DL_SCH_SLOT_BWP3
    ...  paths: MRBTS-*/NRBTS-*/NRCELL-*/NRCCD
    ...         MRBTS-*/NRBTS-*/NRCELL-*/NCELA
    [Arguments]    ${CB7}
    Log To Console    __Waiting until 'Verify Counters CB7' succeeds...
    Wait Until Keyword Succeeds    10min    20s    Verify Counters CB7    ${CB7}


Verify Counters CB7
    [Arguments]    ${input_CB7}
    &{CB7}   Get counters    ${input_CB7}
    &{NRCCD_c}  pu.get last counters values  ${CB7['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-5']['NRCCD']}
    &{NCELA_c}  pu.get last counters values  ${CB7['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-5']['NCELA']}
    Log    ${NRCCD_c}
    Log    ${NCELA_c}
    &{counters_CB7}    8954_lib.merge_dicts    ${NRCCD_c}    ${NCELA_c}
    pu.check counters are greater than zero   ${counters_CB7}


Verifying Counters H Until Keyword Succeeds
    [Documentation]
    ...  M55351C00001 - MAX_UE_ACTIVE_PWR_SAVING_BWP, M55351C00002 - AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...  M55351C01001 - MAX_UE_CONFIG_2BWP, M55351C01002 - AVG_UE_CONFIG_2BWP
    ...  paths: MRBTS-[]/NRBTS-[]/NRCELL-[]/DBWP
    Log To Console    __Waiting until 'Verify Counters H' succeeds...
    Wait Until Keyword Succeeds    10min    20s    Verify Counters H


Verify Counters H
    &{H}   Get counters    ${H_IWK}
    &{DBWP_c}  pu.get last counters values  ${H['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['DBWP']}
    Log    ${DBWP_c}
    pu.check counters are zero    ${DBWP_c}


# from testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB006898/resources/keywords.robot
Lock all LTE cells
    ${dist_names}       Create list
    ${objects}          coam.Get managed objects    class_name=LNCEL_A   connection=${ENB_CONNECTION_ALIAS}
    FOR    ${object}   IN    @{objects}
        ${dist_name_a}  Fetch from right    ${object['distName']}    SCF-1/
        ${dist_name}    Remove string  ${dist_name_a}  _A
        Append to list  ${dist_names}  ${dist_name}
    END

    FOR   ${cell}   IN   @{dist_names}
        coam.block_cell   dist_name=${cell}   connection=${ENB_CONNECTION_ALIAS}  timeout=300
    END


Unlock all LTE locked cells
    ${dist_names}       Create list
    ${objects}          coam.Get managed objects    class_name=LNCEL_A   connection=${ENB_CONNECTION_ALIAS}
    FOR    ${object}   IN    @{objects}
        ${dist_name_a}  Fetch from right    ${object['distName']}    SCF-1/
        ${dist_name}    Remove string  ${dist_name_a}  _A
        Append to list  ${dist_names}  ${dist_name}
    END

    FOR   ${cell}   IN   @{dist_names}
        ${status}   coam.get cell specific info   cell_id=${cell}   connection=${ENB_CONNECTION_ALIAS}
        ${cell_status}   set variable   '${status['status']['blockingState']}'
        Run keyword if   ${cell_status} == 'Blocked'   coam.unblock_cell   dist_name=${cell}   connection=${ENB_CONNECTION_ALIAS}
        ...                                            timeout=300
    END
