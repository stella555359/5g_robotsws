*** Settings ***
Documentation
...    = Author =
...    marek.kot@nokia.com
...    = Maintainer =
...    marek.kot@nokia.com
...    = Reviewer =
...    artur.czainski@nokia.com
...    lukasz.lechowicz@nokia.com
...    = Summary =
...    Purpose: Verify Mobility Auto Configuration for network level

*** Keywords ***
LTE4679-B_Neighbor_mobility_auto-configuration
    [Documentation]     Requirement: OM_LTE_SFS_RNL.21928, OM_LTE_SFS_RNL.21929
    [Timeout]    25min

    ${enb_id_1st}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_id_2nd}   Set Variable    ${testlines.${testline_id}.node2.enb_id}
    ${enb_c_plane_2nd}    Set Variable    ${testlines.${testline_id}.node2.cplane_ip_addr}
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id_1st}
    Enable CBRS Feature On eNB    alias=RAT_1ST
    Enable CBRS Feature On eNB    alias=RAT_2ND    target_enb=${testlines.${testline_id}.node2.enb_id}
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe02/SAS_Sim.conf
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For All Cells To Be OnAir    alias=RAT_2ND
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id_1st}
    Start Capturing Historical Alarms

    #Create LNADJ between eNB1 and eNB2
    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_lnadj_delta.json    ${OUTPUT_DIR}/FEVE_2_lnadj_delta.json
    ...    ENB_ID=${enb_id_1st}
    ...    NEIGHBOUR_ID=${enb_id_2nd}
    ...    C_PLANE=${enb_c_plane_2nd}
    Wait Until BTS Is Not Busy
    Run Keyword And Ignore Error    Perform Delta Recommissioning
    ...    ${OUTPUT_DIR}/FEVE_2_lnadj_delta.json    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST
    Wait Until Keyword Succeeds    3x    30s    Query Infomodel    alias=RAT_2ND
    ...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNADJ_A-* is [adjEnbId=${enb_id_1st}]

    #Prepare all neccessary variables
    ${cbsd_1st}   Get Random Cbsd Object    alias=RAT_1ST
    ${cbsd_2nd}   Get Random Cbsd Object    alias=RAT_2ND
    ${cell_id_1st}   Get Random Cell From Cbsd Object    ${cbsd_1st}    alias=RAT_1ST
    ${cell_id_2nd}   Get Random Cell From Cbsd Object    ${cbsd_2nd}    alias=RAT_2ND
    ${radio_id}   Set Variable    ${cbsd_2nd["assignedCbsdId"]}
    ${earfcn_2nd}   Get Earfcn Value By Cell Id    ${cell_id_2nd}    alias=RAT_2ND
    ${grant_2nd}   Get Grant Value By Cell Id    ${cell_id_2nd}    alias=RAT_2ND

    #Step 1
    #Create objects: LNREL, AMPLER, IRFIM, LNHOIF, REDRT
    #All mo have parameter which point to neighbour cell by using earfcn
    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_Precond_delta.json    ${OUTPUT_DIR}/FEVE_2_Precond_delta.json
    ...      ENB_ID=${enb_id_1st}    D_ENB_ID=${enb_id_2nd}
    ...      N_LNCEL_ID=${cell_id_2nd}    LNCEL_ID=${cell_id_1st}    N_EARFCN=${earfcn_2nd}

    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_Post_delta.json    ${OUTPUT_DIR}/FEVE_2_Post_delta.json
    ...      ENB_ID=${enb_id_1st}    LNCEL_ID=${cell_id_1st}

    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning    ${OUTPUT_DIR}/FEVE_2_Precond_delta.json    skip_parameter_relation_errors=${TRUE}     connection=RAT_1ST

    #Step 2
    Log    Terminate neighbour cell to change earfcn
    Terminate cell    radio_id=${radio_id}    grant=${grant_2nd}    cell_id=${cell_id_2nd}    earfcn=${earfcn_2nd}    alias=RAT_2ND

    Log    If earfcn for cell_1st == cell_2nd termiante grant again
    ${earfcn_2nd}   Wait Until Keyword Succeeds    4x    30s    Get Earfcn Value By Cell Id    ${cell_id_2nd}    alias=RAT_2ND
    ${earfcn_1st}   Wait Until Keyword Succeeds    4x    30s    Get Earfcn Value By Cell Id    ${cell_id_1st}    alias=RAT_1ST
    ${grant_2nd}   Get Grant Value By Cell Id    ${cell_id_2nd}    alias=RAT_2ND
    IF  ${earfcn_2nd}==${earfcn_1st}  Terminate cell  radio_id=${radio_id}  grant=${grant_2nd}  cell_id=${cell_id_2nd}  earfcn=${earfcn_2nd}
    ...  alias=RAT_2ND
    ${earfcn_2nd}   Wait Until Keyword Succeeds    4x    30s    Get Earfcn Value By Cell Id    ${cell_id_2nd}    alias=RAT_2ND

    #Step 3
    #eNB perform recommisioning of all earfcn in affected mo
    #All mo have parameter which point to neighbour cell by using new earfcn
    Check If All Objects Have New Earfcn    ${cell_id_1st}    ${earfcn_2nd}    alias=RAT_1ST

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Save And Check Historical Alarms   AND
    ...                           Perform Delta Recommissioning     delta_file=${OUTPUT_DIR}/FEVE_2_Post_delta.json
    ...                           skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Disable CBRS Feature On eNB    alias=RAT_1ST    AND
    ...                           Disable CBRS Feature On eNB    alias=RAT_2ND    target_enb=${testlines.${testline_id}.node2.enb_id}    AND
    ...                           Kill All SAS Processes

Terminate cell
    [Arguments]    ${radio_id}    ${grant}     ${cell_id}    ${earfcn}    ${alias}=RAT_1ST
    Send Command To SAS Manager    default    grant_terminate ${radio_id} ${grant}
    Wait Until Keyword Succeeds    6x    30s    Query Infomodel    alias=${alias}    timeout=10
    ...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_id}/LNCEL_TDD_A-* is [earfcn!=${earfcn}]
    Wait For All Cells To Be OnAir    alias=${alias}

Check If All Objects Have New Earfcn
    [Arguments]    ${cell_id}    ${new_earfcn}    ${alias}=RAT_1ST

    ${query}   Set Variable    /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_id}

    Wait Until Keyword Succeeds    20x    30s    Query Infomodel    alias=${alias}
    ...    query=check ${query}/AMLEPR_A-5 is [targetCarrierFreq=${new_earfcn}]
    Query Infomodel    alias=${alias}    query=check ${query}/IRFIM_A-5 is [dlCarFrqEut=${new_earfcn}]
    Query Infomodel    alias=${alias}    query=check ${query}/LNHOIF_A-5 is [eutraCarrierInfo=${new_earfcn}]
    Query Infomodel    alias=${alias}    query=check ${query}/REDRT_A-5 is [redirFreqEutra=${new_earfcn}]
