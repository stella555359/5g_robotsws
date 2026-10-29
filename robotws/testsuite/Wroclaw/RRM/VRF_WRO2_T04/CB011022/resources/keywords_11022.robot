*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tput_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011022/resources/keywords_11022.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011022/resources/specific_keywords_11022.py    WITH NAME    adapsel
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/kpi.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011022/resources/mcs_dmrs_pm_counters.py

*** Variables ***
@{test_parameters}   dlDmrsType
...                  dlDmrsTypeAtConnectionDynSel
...                  actDlMcsTableAndDmrsSwitching


*** Keywords ***
Get BTSs settings
    ${distname}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${pcell}
    ${scells}   Create List   ${scell_1}  ${scell_2}  ${scell_3}
    ${scf}   kpi.download_scf
    Log To Console   \n CURRENT BTS SETTINGS
    FOR  ${p}  IN  @{test_parameters}
        ${value}   kpi.get_parameter_value_from_scf
        ...            parameter_dist_name=${distname}
        ...            parameter_abbreviation=${p}
        ...            path=${scf}
        Set Test Variable   ${${p}}   ${value}
        Log To Console    ${SPACE} PCELL:${pcell} - ${p}: ${value}
    END
    FOR  ${c}  IN  @{scells}
        ${value}   kpi.get_parameter_value_from_scf
        ...            parameter_dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${c}
        ...            parameter_abbreviation=actDlMcsTableAndDmrsSwitching
        ...            path=${scf}
        Set Test Variable   ${actDlMcsTableAndDmrsSwitching_scell_${c}}   ${value}
        Log To Console    ${SPACE} SCELL:${c} - actDlMcsTableAndDmrsSwitching: ${value}
    END
    ${value}   kpi.get_parameter_value_from_scf
    ...            parameter_dist_name=${bts_prefix}
    ...            parameter_abbreviation=dlMcsTabAndDmrsSwitchImpCells
    ...            path=${scf}
    Set Test Variable   ${dlMcsTabAndDmrsSwitchImpCells}   ${value}
    Log To Console    ${SPACE} actDlMcsTableAndDmrsSwitching: ${value}


Set Bad Radio Condition
    [Arguments]   ${on_radio}   ${required_rsrp}   ${scell}=None
    IF  '${scell}' == 'None'
        ${CELL_INFO}   Get UE Info   ${ue}  CELL_INFO
        ${ue_rsrp}   Set Variable   ${CELL_INFO}[dbm]
        ${attenuation}   Evaluate   ${ue_rsrp} - ${required_rsrp}
    ELSE
        ${attenuation}   Evaluate   ${rsrp_level}[${scell}] - ${required_rsrp}
    END
    Set Attenuation  ${attenuation}dB  ${ATTENUATOR['${on_radio}']['ports']}  confirm=${TRUE}


Check RSRP level on SCells
    ${scells}   Create List   ${scell_1}  ${scell_3}
    FOR  ${cell}  IN  @{scells}
        Check RSRP Level for Given Cell   ${cell}
    END
