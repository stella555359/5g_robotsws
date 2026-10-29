*** Settings ***
Documentation    Suite description
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library     CB014547.py  WITH NAME  kw14547
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
*** Keywords ***


Check beamtype subband 14547
    [Arguments]    ${cellId}=501    ${should_be_subband}=True
    ${output}=  kw14547.check_beamtype   ${cellId}  ${should_be_subband}
    Should Be True  ${output}


Read counters value For 14547
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55330C00040  M55196C00010  M55196C00012  M55330C00017
    ...  M55330C00018  M55330C00020  M55330C00021
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   3  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters For 14547
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read Counters Value For 14547
    Log to console  ${counters}
    ${PDSCH_INI_TX_SUBBAND_BEAM_1}           get_counter_value_from_single_cell   ${counters}  501    M55330C00040
    ${PDSCH_INI_TX_SUBBAND_BEAM_2}           get_counter_value_from_single_cell   ${counters}  502    M55330C00040
    ${PDSCH_INI_TX_SUBBAND_BEAM_3}           get_counter_value_from_single_cell   ${counters}  503    M55330C00040
    ${PDSCH_INI_TX_SUBBAND_BEAM_4}           get_counter_value_from_single_cell   ${counters}  504    M55330C00040
    ${ACC_UE_CONF_SB_BF_TAS_SRS_1}         get_counter_value_from_single_cell   ${counters}  501    M55196C00010
    ${ACC_UE_CONF_SB_BF_TAS_SRS_2}         get_counter_value_from_single_cell   ${counters}  502    M55196C00010
    ${ACC_UE_CONF_SB_BF_TAS_SRS_3}         get_counter_value_from_single_cell   ${counters}  503    M55196C00010
    ${ACC_UE_CONF_SB_BF_TAS_SRS_4}         get_counter_value_from_single_cell   ${counters}  504    M55196C00010
    ${MAX_UE_CONF_SB_BF_TAS_SRS_1}               get_counter_value_from_single_cell   ${counters}  501    M55196C00012
    ${MAX_UE_CONF_SB_BF_TAS_SRS_2}               get_counter_value_from_single_cell   ${counters}  502    M55196C00012
    ${MAX_UE_CONF_SB_BF_TAS_SRS_3}               get_counter_value_from_single_cell   ${counters}  503    M55196C00012
    ${MAX_UE_CONF_SB_BF_TAS_SRS_4}               get_counter_value_from_single_cell   ${counters}  504    M55196C00012
    ${SLOT_UE_SCHD_SB_BF_1}               get_counter_value_from_single_cell   ${counters}  501    M55330C00017
    ${SLOT_UE_SCHD_SB_BF_2}               get_counter_value_from_single_cell   ${counters}  502    M55330C00017
    ${SLOT_UE_SCHD_SB_BF_3}               get_counter_value_from_single_cell   ${counters}  503    M55330C00017
    ${SLOT_UE_SCHD_SB_BF_4}               get_counter_value_from_single_cell   ${counters}  504    M55330C00017
    ${NUM_UE_SCHD_SB_BF_1}         get_counter_value_from_single_cell   ${counters}  501    M55330C00018
    ${NUM_UE_SCHD_SB_BF_2}         get_counter_value_from_single_cell   ${counters}  502    M55330C00018
    ${NUM_UE_SCHD_SB_BF_3}         get_counter_value_from_single_cell   ${counters}  503    M55330C00018
    ${NUM_UE_SCHD_SB_BF_4}         get_counter_value_from_single_cell   ${counters}  504    M55330C00018
    ${MAX_PDSCH_PRB_SCHD_SB_BF_1}               get_counter_value_from_single_cell   ${counters}  501    M55330C00020
    ${MAX_PDSCH_PRB_SCHD_SB_BF_2}               get_counter_value_from_single_cell   ${counters}  502    M55330C00020
    ${MAX_PDSCH_PRB_SCHD_SB_BF_3}               get_counter_value_from_single_cell   ${counters}  503    M55330C00020
    ${MAX_PDSCH_PRB_SCHD_SB_BF_4}               get_counter_value_from_single_cell   ${counters}  504    M55330C00020
    ${ACC_PDSCH_PRB_SCHD_SB_BF_1}               get_counter_value_from_single_cell   ${counters}  501    M55330C00021
    ${ACC_PDSCH_PRB_SCHD_SB_BF_2}               get_counter_value_from_single_cell   ${counters}  502    M55330C00021
    ${ACC_PDSCH_PRB_SCHD_SB_BF_3}               get_counter_value_from_single_cell   ${counters}  503    M55330C00021
    ${ACC_PDSCH_PRB_SCHD_SB_BF_4}               get_counter_value_from_single_cell   ${counters}  504    M55330C00021
    Should Be True      ${PDSCH_INI_TX_SUBBAND_BEAM_1}>0
    Should Be True      ${PDSCH_INI_TX_SUBBAND_BEAM_2}==0
    Should Be True      ${PDSCH_INI_TX_SUBBAND_BEAM_3}>0
    Should Be True      ${PDSCH_INI_TX_SUBBAND_BEAM_4}==0
    Should Be True      ${ACC_UE_CONF_SB_BF_TAS_SRS_1}>0
    Should Be True      ${ACC_UE_CONF_SB_BF_TAS_SRS_2}==0
    Should Be True      ${ACC_UE_CONF_SB_BF_TAS_SRS_3}>0
    Should Be True      ${ACC_UE_CONF_SB_BF_TAS_SRS_4}==0

    Should Be True      ${MAX_UE_CONF_SB_BF_TAS_SRS_1}>0
    Should Be True      ${MAX_UE_CONF_SB_BF_TAS_SRS_2}==0
    Should Be True      ${MAX_UE_CONF_SB_BF_TAS_SRS_3}>0
    Should Be True      ${MAX_UE_CONF_SB_BF_TAS_SRS_4}==0

    Should Be True      ${SLOT_UE_SCHD_SB_BF_1}>0
    Should Be True      ${SLOT_UE_SCHD_SB_BF_2}==0
    Should Be True      ${SLOT_UE_SCHD_SB_BF_3}>0
    Should Be True      ${SLOT_UE_SCHD_SB_BF_4}==0

    Should Be True      ${NUM_UE_SCHD_SB_BF_1}>0
    Should Be True      ${NUM_UE_SCHD_SB_BF_2}==0
    Should Be True      ${NUM_UE_SCHD_SB_BF_3}>0
    Should Be True      ${NUM_UE_SCHD_SB_BF_4}==0

    Should Be True      ${MAX_PDSCH_PRB_SCHD_SB_BF_1}>0
    Should Be True      ${MAX_PDSCH_PRB_SCHD_SB_BF_2}==0
    Should Be True      ${MAX_PDSCH_PRB_SCHD_SB_BF_3}>0
    Should Be True      ${MAX_PDSCH_PRB_SCHD_SB_BF_4}==0

    Should Be True      ${ACC_PDSCH_PRB_SCHD_SB_BF_1}>0
    Should Be True      ${ACC_PDSCH_PRB_SCHD_SB_BF_2}==0
    Should Be True      ${ACC_PDSCH_PRB_SCHD_SB_BF_3}>0
    Should Be True      ${ACC_PDSCH_PRB_SCHD_SB_BF_4}==0