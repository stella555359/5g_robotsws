*** Settings ***
Documentation
...  author:  Sara Nowak
...  contact: sara.nowak@nokia.com

Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     taf.rfrl.procedures.resources.python.config_operations.ConfigOperations    WITH NAME    config_operations
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/wro/test_specific_keywords.py
Resource    testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/wro/test_specific_keywords.robot

*** Variables ***
${GNB_IP}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GNB_ID}                     ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Test Setup CB009010
    [Arguments]     ${require_srb_3}=${TRUE}   ${require_anr_moi_allowed}=${FALSE}   ${require_ue}=${TRUE}
    ...             ${require_reset}=${FALSE}  ${max_ho_rerun}=3
    Set Test Variables   ${require_srb_3}   ${require_anr_moi_allowed}   ${require_ue}   ${max_ho_rerun}
    Run Keyword If   ${require_ue} == ${FALSE}   Preconditions Without Logs Collection
    ...   ELSE   Common Preconditions
    Run Keyword And Ignore Error  taf_admin.Teardown All Aliases For Admin
    Delete All Nrrel And Nradjnrcell Objects
    Set Initial Parameters   ${require_srb_3}    ${require_anr_moi_allowed}
    Run Keyword If   ${require_reset} == ${TRUE}   Perform Site Reset And Wait For OnAir State

Test Teardown CB009010
    Run Keyword If   ${require_ue} == ${TRUE}   detach
    Run Keyword If   ${require_anr_moi_allowed} == ${TRUE}
    ...    set_max_number_allowed_neighbour_relations    max_relations=20000
    Common Postconditions
    Teardown All Admin Sessions

Check ADJ_NRPLMNSET_NSA object exist with correctly set parameters
    [Documentation]     This keyword checks if ADJ_NRPLMNSET_NSA object exist with correctly set parameters
    ...                 :param nradjnrcell_id: id of NRADJNRCELL
    [Arguments]    ${nradjnrcell_id}=NRADJNRCELL-12288
    ${adj_nrplmnset_nsa_pattern}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjnrcell_id}/ADJ_NRPLMNSET_NSA-1
    Check cellReservedForOperatorUse parameter from scf    dist_name=${adj_nrplmnset_nsa_pattern}
    Check nrPlmnDNList parameter from scf    dist_name=${adj_nrplmnset_nsa_pattern}

Check cellReservedForOperatorUse parameter from scf
    [Documentation]     This keyword checks if cellReservedForOperatorUse parameter is set to reserved
    [Arguments]     ${dist_name}
    config_operations.connect                     alias=get_parameter
    ${cellReservedForOperatorUse_value}=          config_operations.get_parameter_value
    ...                                           dist_name=${dist_name}
    ...                                           param_name=cellReservedForOperatorUse
    config_operations.disconnect

    set test variable                             ${cellReservedForOperatorUse_value}
    Should be equal                               ${cellReservedForOperatorUse_value}    reserved

Check nrPlmnDNList parameter from scf
    [Documentation]     This keyword checks if nrPlmnDNList list contains NRPLMN-2
    [Arguments]     ${dist_name}
    config_operations.connect                     alias=get_parameter
    ${nrplmnlist_value}=                          config_operations.get_parameter_value
    ...                                           dist_name=${dist_name}
    ...                                           param_name=nrPlmnDNList
    config_operations.disconnect

    set test variable                             ${nrplmnlist_value}
    Should be equal                               ${nrplmnlist_value}[0]    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRPLMN-2

