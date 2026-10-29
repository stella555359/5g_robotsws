*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   CB011127 Commissioning Keywords
...               Scope : Common keywords for CB011127 commissioning
#
...               Test Case Scenario author   : vincent.boulet@nokia.com
...               Creation Date               : 2025-07-25
...               Modified Date               : 2025-11-05
#
#                 Version    Date       Author                          Notes
#                            FB25XX     vincent.boulet@nokia.com        Robot creation
#                            FB2514     vincent.boulet@nokia.com        Half-ABIP configuration (CB009142) with bbmodBoardConfigType is NRFDD_NRTDD
#                 0.1        FB2515     vincent.boulet@nokia.com        Robot creation and delivery for CRT
#                 0.2        FB2518     vincent.boulet@nokia.com        Typo correction
#                 1.0        FB2519     vincent.boulet@nokia.com        actRimCmMeaPeriodReport configuration into NRRIM_PROFILE in case of SBTS00
#                 1.1        FB2521     vincent.boulet@nokia.com        it is required that ulDlDataSlotRatio is not configured in case tdLte
#                 1.2        FB2522     vincent.boulet@nokia.com        Correction for SBTS25R3
#                 1.3        FB2522     vincent.boulet@nokia.com        nrRiMonitorWindow of NRRIM_PROFILE can be customized
#                                                                       nrRiMonitorInSSlotEnabled of NRRIM_PROFILE can be customized
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries

# Resources

# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Keywords ***
# Commissioning #
Set Suite Dist Name Variables For CB011127
    Dated Log New Line                ----Set Suite Dist Name Variables----
    # MRBTS
    ${dn_mrbts}=                      Set Variable    MRBTS-${TMRBTS_ID[0]}
    Set Suite Variable                ${dn_mrbts}
    Dated Log                         > dn_mrbts is ${dn_mrbts}
    # NRBTS
    ${dn_nrbts}=                      Set Variable    ${dn_mrbts}/NRBTS-${TNRBTS_ID[0]}
    Set Suite Variable                ${dn_nrbts}
    Dated Log                         > dn_nrbts is ${dn_nrbts}
    # BWP_PROFILE base name
    ${dn_bwp_profile_base}=           Set Variable    ${dn_nrbts}/BWP_PROFILE-
    Set Suite Variable                ${dn_bwp_profile_base}
    Dated Log                         > dn_bwp_profile_base is ${dn_bwp_profile_base}
    # NRPMRNL base name
    ${dn_nrpmrnl_base}=               Set Variable    ${dn_nrbts}/NRPMRNL-
    Set Suite Variable                ${dn_nrpmrnl_base}
    Dated Log                         > dn_nrpmrnl_base is ${dn_nrpmrnl_base}
    # BWP_PROFILE class
    ${cn_bwp_profile}=                Set Variable    com.nokia.srbts.nrbts:BWP_PROFILE
    Set Suite Variable                ${cn_bwp_profile}
    Dated Log                         > cn_bwp_profile is ${cn_bwp_profile}
    # PDCCH class
    ${cn_pdcch}=                      Set Variable    com.nokia.srbts.nrbts:PDCCH
    Set Suite Variable                ${cn_pdcch}
    Dated Log                         > cn_pdcch is ${cn_pdcch}
    # PDCCH_CONFIG_COMMON class
    ${cn_pdcch_config_common}=        Set Variable    com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON
    Set Suite Variable                ${cn_pdcch_config_common}
    Dated Log                         > cn_pdcch_config_common is ${cn_pdcch_config_common}
    # PDCCH_CONFIG_DEDICATED class
    ${cn_pdcch_config_dedicated}=     Set Variable    com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED
    Set Suite Variable                ${cn_pdcch_config_dedicated}
    Dated Log                         > cn_pdcch_config_dedicated is ${cn_pdcch_config_dedicated}
    # PDSCH class
    ${cn_pdsch}=                      Set Variable    com.nokia.srbts.nrbts:PDSCH
    Set Suite Variable                ${cn_pdsch}
    Dated Log                         > cn_pdsch is ${cn_pdsch}
    # NRRIM_PROFILE class
    ${cn_nrrim_profile}=              Set Variable    com.nokia.srbts.nrbts:NRRIM_PROFILE
    Set Suite Variable                ${cn_nrrim_profile}
    Dated Log                         > cn_nrrim_profile is ${cn_nrrim_profile}
    # BBMOD
    ${dn_bbmod}=                      Set Variable    ${dn_mrbts}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    Set Suite Variable                ${dn_bbmod}
    Dated Log                         > dn_bbmod is ${dn_bbmod}


Get Values From Object
    [Arguments]             ${dist_name}
    ...                     ${p_name}
    ...                     ${current_scf}=${None}

    #DEBUG_LOG#Dated Log              ----Get Values From Object----
    Run Keyword If    "${current_scf}" != "${None}"    SCF StartSession    scf_file=${current_scf}
    ${result}=                        Scf.SCF Get Single Value    dist_name=${dist_name}    p_name=${p_name}
    Run Keyword If    "${current_scf}" != "${None}"    SCF StopSession    scf_file=${current_scf}
    ${nb_match}=                      Get Length    ${result}
    [Return]                          ${nb_match}    ${result}


Get All Values From Object By Pattern
    [Arguments]             ${dist_name}=${None}
    ...                     ${p_name}=${None}
    ...                     ${list_name}=${None}
    ...                     ${current_scf}=${None}

    #DEBUG_LOG#Dated Log              ----Get All Values From Object By Pattern----
    Run Keyword If    "${current_scf}" != "${None}"    SCF StartSession    scf_file=${current_scf}
    ${result}=    multiscf.get_all_values_from_scf_by_pattern    dist_name=${dist_name}    p_name=${p_name}    list_name=${list_name}
    Run Keyword If    "${current_scf}" != "${None}"    SCF StopSession    scf_file=${current_scf}
    ${nb_match}=                      Get Length    ${result}
    [Return]                          ${nb_match}    ${result}


Get Dedicated Dist Name BWP_PROFILE For Cell
    [Arguments]             ${dn_nrcell}
    ...                     ${bwpdn_dedicated}
    ...                     ${bwp_param}=bwpDN
    ...                     ${bwp_type}=dedicated

    #DEBUG_LOG#Dated Log              ----Get Dedicated Dist Name BWP_PROFILE For Cell----
    ${nb_match}    ${result_bwpdn}    Get All Values From Object By Pattern    dist_name=${dn_nrcell}    p_name=${bwp_param}
    #DEBUG_LOG#Run Keyword If    ${nb_match} > 0
    #DEBUG_LOG#...    Dated Log       >> match for ${dn_nrcell}: ${bwp_param}= ${result_bwpdn}
    FOR    ${current_dn}    IN    @{result_bwpdn}
        #DEBUG_LOG#Dated Log          >> current_dn for BWP_PROFILE= ${current_dn}
        #
        ${nb_values}=                 Count Values In List    ${bwpdn_dedicated}    ${current_dn}
        ${current_param}=             Set Variable    bwpType
        ${nb_match}    ${result}      Get Values From Object    dist_name=${current_dn}    p_name=${current_param}
        #DEBUG_LOG#Dated Log          >> Get Values From Object ${current_dn}: ${current_param}= ${result}
        Run Keyword If    ${nb_values} == 0 and ${nb_match} > 0 and "${result}[0]" == "${bwp_type}"    Run Keywords
        ...        Dated Log          >> match for ${current_dn}: ${current_param}= ${result} nb_match= ${nb_match}
        ...    AND                    Append To List    ${bwpdn_dedicated}    ${current_dn}
    END
    ${nb_match}=                      Get Length    ${bwpdn_dedicated}
    [Return]                          ${nb_match}


SCF Validate NIDD And PDL Rules
    [Arguments]             ${scf_file}

    Dated Log New Line                ----SCF Validate NIDD And PDL Rules----
    ${dict_req}=                      OAM Validate SCF Online    scf_file=${scf_file}    skip_relation_errors=${True}
    #DEBUG_LOG#Dated Log              >> dict_req= ${dict_req}
    #DEBUG_LOG#Dated Log              >> request_msg= ${dict_req['requestMessage']}
    # in case no error # dict_req= {'time': '7:31:00 AM', 'requestId': 73745, 'requestStatus': 'completed', 'requestMessage':
    # {'niddValidationResult': {'logs': {'skippedElements': None, 'missingObjectsErrors': None, 'maxOccurrencesErrors': None,
    #  'definitionErrors': None}, 'status': 'OK'},
    #  'pdlValidationResult': {'logs': {'relationErrors': [], 'hardwareErrors': []}, 'status': 'OK'}}, 'errorCode': 0}
    ${req_id}=                        Set Variable    ${dict_req['requestId']}
    ${req_status}=                    Set Variable    ${dict_req['requestStatus']}
    ${req_err_code}=                  Set Variable    ${dict_req['errorCode']}
    Dated Log                         > Request ${req_id} is ${req_status} with error code= ${req_err_code}
    Should Be True                    "${req_status}" == "completed"
    # niddValidationResult
    ${nidd_res}=                      Set Variable    ${dict_req['requestMessage']['niddValidationResult']}
    ${nidd_res_status}=               Set Variable    ${nidd_res['status']}
    ${nidd_skipped_elem}=             Set Variable    ${nidd_res['logs']['skippedElements']}
    ${nidd_missing_obj_err}=          Set Variable    ${nidd_res['logs']['missingObjectsErrors']}
    ${nidd_max_err}=                  Set Variable    ${nidd_res['logs']['maxOccurrencesErrors']}
    ${nidd_def_err}=                  Set Variable    ${nidd_res['logs']['definitionErrors']}
    Run Keyword If    "${nidd_res_status}" != "OK" and "${nidd_skipped_elem}" != "${None}"
    ...    Dated Log                  > niddValidationResult - skippedElements not none
    ...    AND    Dated Log           > ${nidd_skipped_elem}
    Run Keyword If    "${nidd_res_status}" != "OK" and "${nidd_missing_obj_err}" != "${None}"
    ...    Dated Log                  > niddValidationResult - missingObjectsErrors not none
    ...    AND    Dated Log           > ${nidd_missing_obj_err}
    Run Keyword If    "${nidd_res_status}" != "OK" and "${nidd_max_err}" != "${None}"
    ...    Dated Log                  > niddValidationResult - maxOccurrencesErrors not none
    ...    AND    Dated Log           > ${nidd_max_err}
    Run Keyword If    "${nidd_res_status}" != "OK" and "${nidd_def_err}" != "${None}"
    ...    Dated Log                  > niddValidationResult - definitionErrors not none
    ...    AND    Dated Log           > ${nidd_def_err}
    # pdlValidationResult
    ${pdl_res}=                       Set Variable    ${dict_req['requestMessage']['pdlValidationResult']}
    ${pdl_res_status}=                Set Variable    ${pdl_res['status']}
    ${pdl_rel_err}=                   Set Variable    ${pdl_res['logs']['relationErrors']}
    ${pdl_rel_err_len}=               Get Length    ${pdl_rel_err}
    ${pdl_hw_err}=                    Set Variable    ${pdl_res['logs']['hardwareErrors']}
    ${pdl_hw_err_len}=                Get Length    ${pdl_hw_err}
    Run Keyword If    "${pdl_res_status}" != "OK" and ${pdl_rel_err_len} > 0    Run Keywords
    ...    Dated Log                  > pdlValidationResult:relationErrors is not 0, len= ${pdl_rel_err_len}
    ...    AND    Dated Log           > ${pdl_rel_err}
    Run Keyword If    "${pdl_res_status}" != "OK" and ${pdl_hw_err_len} > 0    Run Keywords
    ...    Dated Log                  > pdlValidationResult:hardwareErrors is not 0, len= ${pdl_hw_err_len}
    ...    AND    Dated Log           > ${pdl_hw_err}
    #
    ${status}=    Run Keyword If    "${pdl_res_status}" != "OK"    Set Variable    ${False}
    ...                       ELSE    Set Variable    ${True}
    [Return]                          ${status}    ${pdl_rel_err}
# --------------------------------------------------------------------------------------------------------------------------------------------------
Configure SCF Set Element
    [Arguments]             ${dist_name}
    ...                     ${elem_name}
    ...                     ${elem_val}
    ...                     ${scope}=Classical

    Run Keyword If    "${elem_val}" != "${None}"    Run Keywords
    ...                               SCF Set element               dist_name=${dist_name}
    ...                                                             element_name=${elem_name}
    ...                                                             element_value=${elem_val}
    ...                                                             scope=${scope}
    ...    AND    Dated Log           > SCF Set element ${dist_name}: ${elem_name}= ${elem_val}


Configure SCF Set Element In List
    [Arguments]             ${dist_name}
    ...                     ${list_name}
    ...                     ${elem_name}
    ...                     ${elem_val}
    ...                     ${scope}=Classical

    Run Keyword If    "${elem_val}" != "${None}"    Run Keywords
    ...                               SCF Set element in List       dist_name=${dist_name}
    ...                                                             list_name=${list_name}
    ...                                                             element_name=${elem_name}
    ...                                                             element_value=${elem_val}
    ...                                                             scope=${scope}
    ...    AND    Dated Log           > SCF Set element in List ${dist_name}: ${list_name}.${elem_name}= ${elem_val}


Start Session Full Commissioning For CB011127
    [Arguments]             ${test_name}=${None}

    Dated Log New Line                ----Start Session Full Commissioning----
    ${current_scf}=                   String.Replace string    ${scf_suite_setup_backup}    _Backup.xml    ${EMPTY}
    ${updated_scf}=                   Catenate    SEPARATOR=${EMPTY}    ${current_scf}_CB011127.xml
    ${std_output}=                    Run    command=cp ${scf_suite_setup_backup} ${updated_scf}
    SCF StartSession                  scf_file=${updated_scf}
    Dated Log                         > ${updated_scf}
    #
    # MRBTS.btsName / update / ${test_name}
    Configure SCF Set Element    dist_name=${dn_mrbts}    elem_name=btsName    elem_val=${test_name}
    [Return]                          ${updated_scf}


Stop Session Full Commissioning For CB011127
    [Arguments]             ${updated_scf}
    ...                     ${skip_errors}=${False}

    Dated Log New Line                ----Stop Session Full Commissioning----
    Dated Log                         > ${updated_scf}
    SCF StopSession                   scf_file=${updated_scf}
    ${result_scf_val}    ${result_pdl}    SCF Validate NIDD And PDL Rules    scf_file=${updated_scf}
    Run Keyword If    ${result_scf_val} == ${True}    Run Keywords    OAM Perform Full Commissioning    scf_file=${updated_scf}
    ...                                                             skip_relation_errors=${skip_errors}
    ...    AND                        OAM wait available
    ...    AND                        Run    command=rm -f ${updated_scf}    # Remove the working file
    ...    AND                        OAM Get SCF File    file=${updated_scf}    # Save the final oredered file
    ...    AND                        Set Suite Variable    ${updated_scf}
    #DEBUG_LOG#...  ELSE Dated Log    > ${result_pdl}
    [Return]                          ${result_scf_val}    ${result_pdl}


Is Parameter A Dictionary Key
    [Arguments]             ${dict}
    ...                     ${parameter}

    ${key_flag}=                      Set Variable    ${False}
    FOR    ${key}    ${value}    IN    &{dict}
        ${key_flag}=    Run Keyword If    "${key}" == "${parameter}"    Set Variable    ${True}
        ...                         ELSE    Set Variable    ${False}
        Exit For Loop If              ${key_flag} == ${True}
    END
    [Return]                          ${key_flag}
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Create BWP_PROFILE
    [Arguments]             ${profil_id}
    ...                     ${dico_pdcch}

    ${current_dn}=                    Set Variable    ${dn_bwp_profile_base}${profil_id}
    Dated Log New Line                ----SCF Create BWP_PROFILE ${current_dn}----
    Dated Log                         >> ${dico_pdcch}
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}
    Run Keyword If    ${flag_object}    Run Keywords    SCF Remove object    dist_name=${current_dn}
    ...    AND    Dated Log           > SCF Remove object ${current_dn}
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_bwp_profile}
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_bwp_profile}
    #
    ${k_bwpType}=                     Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=bwpType
    ${k_cRbSizeDl}=                   Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=cRbSizeDl
    ${k_cRbStartDl}=                  Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=cRbStartDl
    ${k_cRbSizeUl}=                   Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=cRbSizeUl
    ${k_cRbStartUl}=                  Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=cRbStartUl
    # BWP_PROFILE.bwpType / add
    ${current_param}=                 Set Variable    bwpType
    ${current_value}=    Run Keyword If    ${k_bwpType}    Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    initial
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.locationAndBandwidthDl / add list
    ${current_list}=                  Set Variable    locationAndBandwidthDl
    ${current_cRbSize}=    Run Keyword If    ${k_cRbSizeDl}    Set Variable    ${dico_pdcch}[cRbSizeDl]    ELSE    Set Variable    coreset0
    ${current_cRbStart}=    Run Keyword If    ${k_cRbStartDl}    Set Variable    ${dico_pdcch}[cRbStartDl]    ELSE    Set Variable    coreset0
    &{dico_locationAndBandwidth}=     Create Dictionary    cRbSizeDl=${current_cRbSize}
    ...                                                    cRbStartDl=${current_cRbStart}
    SCF Add list                      dist_name=${current_dn}    list_name=${current_list}
    Dated Log                         > SCF Add list ${current_dn}: ${current_list}
    SCF Add items to list             dist_name=${current_dn}    list_name=${current_list}    elements=${dico_locationAndBandwidth}
    Dated Log                         > SCF Add items to list ${current_dn}: ${current_list}= ${dico_locationAndBandwidth}
    # BWP_PROFILE.locationAndBandwidthUl / add list
    ${current_list}=                  Set Variable    locationAndBandwidthUl
    ${current_cRbSize}=    Run Keyword If    ${k_cRbSizeUl}    Set Variable    ${dico_pdcch}[cRbSizeUl]    ELSE    Set Variable    sameAsDl
    ${current_cRbStart}=    Run Keyword If    ${k_cRbStartUl}    Set Variable    ${dico_pdcch}[cRbStartUl]    ELSE    Set Variable    sameAsDl
    &{dico_locationAndBandwidth}=     Create Dictionary    cRbSizeUl=${current_cRbSize}
    ...                                                    cRbStartUl=${current_cRbStart}
    SCF Add list                      dist_name=${current_dn}    list_name=${current_list}
    Dated Log                         > SCF Add list ${current_dn}: ${current_list}
    SCF Add items to list             dist_name=${current_dn}    list_name=${current_list}    elements=${dico_locationAndBandwidth}
    Dated Log                         > SCF Add items to list ${current_dn}: ${current_list}= ${dico_locationAndBandwidth}


SCF Create BWP_PROFILE_PDCCH
    [Arguments]             ${profil_id}
    ...                     ${dico_pdcch}

    ${current_dn}=                    Set Variable    ${dn_bwp_profile_base}${profil_id}/PDCCH-1
    Dated Log New Line                ----SCF Create BWP_PROFILE_PDCCH ${current_dn}----
    Dated Log                         >> ${dico_pdcch}
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}
    Run Keyword If    ${flag_object}    Run Keywords    SCF Remove object    dist_name=${current_dn}
    ...    AND    Dated Log           > SCF Remove object ${current_dn}
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_pdcch}
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_pdcch}
    #
    ${k_alSelection}=                 Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=alSelection
    ${k_dciDedicatedAggLevel}=        Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciDedicatedAggregationLevel
    ${k_dciPagingAggLevel}=           Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciPagingAggregationLevel
    ${k_dciRaCompletionAggLevel}=     Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciRaCompletionAggregationLevel
    ${k_dciRaMsg2AggLevel}=           Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciRaMsg2AggregationLevel
    ${k_dciSiAggLevel}=               Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciSiAggregationLevel
    ${k_downgradeAL16toAL8}=          Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=downgradeAL16toAL8
    ${k_downgradeALProactive}=        Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=downgradeALProactive
    # BWP_PROFILE/PDCCH.alSelection / add
    ${current_param}=                 Set Variable    alSelection
    ${current_value}=    Run Keyword If    ${k_alSelection}    Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    static
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.dciDedicatedAggregationLevel / add
    ${current_param}=                 Set Variable    dciDedicatedAggregationLevel
    ${current_value}=    Run Keyword If    ${k_dciDedicatedAggLevel}
    ...                               Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    AL4
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.dciPagingAggregationLevel / add
    ${current_param}=                 Set Variable    dciPagingAggregationLevel
    ${current_value}=    Run Keyword If    ${k_dciPagingAggLevel}    Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    AL4
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.dciRaCompletionAggregationLevel / add
    ${current_param}=                 Set Variable    dciRaCompletionAggregationLevel
    ${current_value}=    Run Keyword If    ${k_dciRaCompletionAggLevel}
    ...                               Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    AL4
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.dciRaMsg2AggregationLevel / add
    ${current_param}=                 Set Variable    dciRaMsg2AggregationLevel
    ${current_value}=    Run Keyword If    ${k_dciRaMsg2AggLevel}    Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    AL4
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.dciSiAggregationLevel / add
    ${current_param}=                 Set Variable    dciSiAggregationLevel
    ${current_value}=    Run Keyword If    ${k_dciSiAggLevel}    Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    AL4
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.downgradeAL16toAL8 / add
    ${current_param}=                 Set Variable    downgradeAL16toAL8
    ${current_value}=    Run Keyword If    ${k_downgradeAL16toAL8}
    ...                               Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    notAllowed
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE/PDCCH.downgradeALProactive / add
    ${current_param}=                 Set Variable    downgradeALProactive
    ${current_value}=    Run Keyword If    ${k_downgradeALProactive}
    ...                               Set Variable    ${dico_pdcch}[${current_param}]    ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}


SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON
    [Arguments]             ${profil_id}
    ...                     ${list_searchSpace}

    ${current_dn}=                    Set Variable    ${dn_bwp_profile_base}${profil_id}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Dated Log New Line                ----SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON ${current_dn}----
    Dated Log                         >> ${list_searchSpace}
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}
    Run Keyword If    ${flag_object}    Run Keywords    SCF Remove object    dist_name=${current_dn}
    ...    AND    Dated Log           > SCF Remove object ${current_dn}
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_pdcch_config_common}
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_pdcch_config_common}
    #
    # PDCCH_CONFIG_COMMON.searchSpaceCommon / add list
    ${current_list}=                  Set Variable    searchSpaceCommon
    SCF Add list                      dist_name=${current_dn}    list_name=${current_list}
    Dated Log                         > SCF Add list ${current_dn}: ${current_list}
    FOR    ${current_dico}    IN    @{list_searchSpace}
        ${k_coresetId}=               Is Parameter A Dictionary Key    dict=${current_dico}    parameter=coresetId
        ${k_dciFormat}=               Is Parameter A Dictionary Key    dict=${current_dico}    parameter=dciFormat
        ${k_duration}=                Is Parameter A Dictionary Key    dict=${current_dico}    parameter=duration
        ${k_monitoringSymbolWithinSlot}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=monitoringSymbolWithinSlot
        ${k_numOfPdcchCandidatesInAL16}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL16
        ${k_numOfPdcchCandidatesInAL2}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL2
        ${k_numOfPdcchCandidatesInAL4}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL4
        ${k_numOfPdcchCandidatesInAL8}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL8
        ${k_periodicity}=             Is Parameter A Dictionary Key    dict=${current_dico}    parameter=periodicity
        ${k_searchSpaceId}=           Is Parameter A Dictionary Key    dict=${current_dico}    parameter=searchSpaceId
        ${k_searchSpaceType}=         Is Parameter A Dictionary Key    dict=${current_dico}    parameter=searchSpaceType
        ${k_slotOffset}=              Is Parameter A Dictionary Key    dict=${current_dico}    parameter=slotOffset
        # PDCCH_CONFIG_COMMON.coresetId / add
        ${current_coresetId}=    Run Keyword If    ${k_coresetId}    Set Variable    ${current_dico}[coresetId]    ELSE    Set Variable    0
        # PDCCH_CONFIG_COMMON.dciFormat / add
        ${current_dciFormat}=    Run Keyword If    ${k_dciFormat}
        ...                           Set Variable    ${current_dico}[dciFormat]    ELSE    Set Variable    formats0-0-And-1-0
        # PDCCH_CONFIG_COMMON.duration / add
        ${current_duration}=    Run Keyword If    ${k_duration}    Set Variable    ${current_dico}[duration]    ELSE    Set Variable    1
        # PDCCH_CONFIG_COMMON.monitoringSymbolWithinSlot / add
        ${current_monitoringSymbolWithinSlot}=    Run Keyword If    ${k_monitoringSymbolWithinSlot}
        ...                           Set Variable    ${current_dico}[monitoringSymbolWithinSlot]    ELSE    Set Variable    symbol_0
        # PDCCH_CONFIG_COMMON.numOfPdcchCandidatesInAL16 / add
        ${current_numOfPdcchCandidatesInAL16}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL16}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL16]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_COMMON.numOfPdcchCandidatesInAL2 / add
        ${current_numOfPdcchCandidatesInAL2}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL2}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL2]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_COMMON.numOfPdcchCandidatesInAL4 / add
        ${current_numOfPdcchCandidatesInAL4}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL4}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL4]    ELSE    Set Variable    n2
        # PDCCH_CONFIG_COMMON.numOfPdcchCandidatesInAL8 / add
        ${current_numOfPdcchCandidatesInAL8}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL8}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL8]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_COMMON.periodicity / add
        ${current_periodicity}=    Run Keyword If    ${k_periodicity}    Set Variable    ${current_dico}[periodicity]    ELSE    Set Variable    sl5
        # PDCCH_CONFIG_COMMON.searchSpaceId / add
        ${current_searchSpaceId}=    Run Keyword If    ${k_searchSpaceId}
        ...                           Set Variable    ${current_dico}[searchSpaceId]    ELSE    Set Variable    1
        # PDCCH_CONFIG_COMMON.searchSpaceType / add
        ${current_searchSpaceType}=    Run Keyword If    ${k_searchSpaceType}
        ...                           Set Variable    ${current_dico}[searchSpaceType]    ELSE    Set Variable    Type0A
        # PDCCH_CONFIG_COMMON.slotOffset / add
        ${current_slotOffset}=    Run Keyword If    ${k_slotOffset}    Set Variable    ${current_dico}[slotOffset]    ELSE    Set Variable    0
        &{dico_searchSpaceCommon}=    Create Dictionary             coresetId=${current_coresetId}
        ...                                                         dciFormat=${current_dciFormat}
        ...                                                         duration=${current_duration}
        ...                                                         monitoringSymbolWithinSlot=${current_monitoringSymbolWithinSlot}
        ...                                                         numOfPdcchCandidatesInAL16=${current_numOfPdcchCandidatesInAL16}
        ...                                                         numOfPdcchCandidatesInAL2=${current_numOfPdcchCandidatesInAL2}
        ...                                                         numOfPdcchCandidatesInAL4=${current_numOfPdcchCandidatesInAL4}
        ...                                                         numOfPdcchCandidatesInAL8=${current_numOfPdcchCandidatesInAL8}
        ...                                                         periodicity=${current_periodicity}
        ...                                                         searchSpaceId=${current_searchSpaceId}
        ...                                                         searchSpaceType=${current_searchSpaceType}
        ...                                                         slotOffset=${current_slotOffset}
        SCF Add items to list         dist_name=${current_dn}    list_name=${current_list}    elements=${dico_searchSpaceCommon}
        Dated Log                     > SCF Add items to list ${current_dn}: ${current_list}= ${dico_searchSpaceCommon}
    END


SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED
    [Arguments]             ${profil_id}
    ...                     ${dico_coreset}
    ...                     ${list_searchSpace}

    ${current_dn}=                    Set Variable    ${dn_bwp_profile_base}${profil_id}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    Dated Log New Line                ----SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED ${current_dn}----
    Dated Log                         >> ${dico_coreset}
    Dated Log                         >> ${list_searchSpace}
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}
    Run Keyword If    ${flag_object}    Run Keywords    SCF Remove object    dist_name=${current_dn}
    ...    AND    Dated Log           > SCF Remove object ${current_dn}
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_pdcch_config_dedicated}
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_pdcch_config_dedicated}
    #
    # PDCCH_CONFIG_DEDICATED.coresetDedicated / add list
    ${current_list}=                  Set Variable    coresetDedicated
    ${k_coresetDedicated}=            Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=coresetDedicated
    Run Keyword If    not ${k_coresetDedicated}    Run Keywords    SCF Add list    dist_name=${current_dn}    list_name=${current_list}
    ...    AND    Dated Log           > SCF Add list ${current_dn}: ${current_list}
    ${k_cceToRegMapping}=             Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=cceToRegMapping
    ${k_coresetId}=                   Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=coresetId
    ${k_cRbStart}=                    Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=cRbStart
    ${k_duration}=                    Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=duration
    ${k_interleaverSize}=             Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=interleaverSize
    ${k_regBundleSize}=               Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=regBundleSize
    ${k_size}=                        Is Parameter A Dictionary Key    dict=${dico_coreset}    parameter=size
    # PDCCH_CONFIG_DEDICATED.cceToRegMapping / add
    ${current_cceToRegMapping}=    Run Keyword If    ${k_cceToRegMapping}
    ...                               Set Variable    ${dico_coreset}[cceToRegMapping]    ELSE    Set Variable    nonInterleaved
    # PDCCH_CONFIG_DEDICATED.coresetId / add
    ${current_coresetId}=    Run Keyword If    ${k_coresetId}    Set Variable    ${dico_coreset}[coresetId]    ELSE    Set Variable    1
    # PDCCH_CONFIG_DEDICATED.cRbStart / add
    ${current_cRbStart}=    Run Keyword If    ${k_cRbStart}    Set Variable    ${dico_coreset}[cRbStart]    ELSE    Set Variable    0
    # PDCCH_CONFIG_DEDICATED.duration / add
    ${current_duration}=    Run Keyword If    ${k_duration}    Set Variable    ${dico_coreset}[duration]    ELSE    Set Variable    1
    # PDCCH_CONFIG_DEDICATED.interleaverSize / add
    ${current_interleaverSize}=    Run Keyword If    ${k_interleaverSize}
    ...                               Set Variable    ${dico_coreset}[interleaverSize]    ELSE    Set Variable    none
    # PDCCH_CONFIG_DEDICATED.regBundleSize / add
    ${current_regBundleSize}=    Run Keyword If    ${k_regBundleSize}
    ...                               Set Variable    ${dico_coreset}[regBundleSize]    ELSE    Set Variable    n6
    # PDCCH_CONFIG_DEDICATED.size / add
    ${current_size}=    Run Keyword If    ${k_size}    Set Variable    ${dico_coreset}[size]    ELSE    Set Variable    96
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=${current_cceToRegMapping}
    ...                                                             coresetId=${current_coresetId}
    ...                                                             cRbStart=${current_cRbStart}
    ...                                                             duration=${current_duration}
    ...                                                             interleaverSize=${current_interleaverSize}
    ...                                                             regBundleSize=${current_regBundleSize}
    ...                                                             size=${current_size}
    Run Keyword If    not ${k_coresetDedicated}    Run Keywords    SCF Add items to list    dist_name=${current_dn}    list_name=${current_list}
    ...                                                             elements=${dico_coresetDedicated}
    ...    AND    Dated Log           > SCF Add items to list ${current_dn}: ${current_list}= ${dico_coresetDedicated}
    #
    # PDCCH_CONFIG_DEDICATED.searchSpaceDedicated / add list
    ${current_list}=                  Set Variable    searchSpaceDedicated
    SCF Add list                      dist_name=${current_dn}    list_name=${current_list}
    Dated Log                         > SCF Add list ${current_dn}: ${current_list}
    FOR    ${current_dico}    IN    @{list_searchSpace}
        ${k_coresetId}=               Is Parameter A Dictionary Key    dict=${current_dico}    parameter=coresetId
        ${k_dciFormat}=               Is Parameter A Dictionary Key    dict=${current_dico}    parameter=dciFormat
        ${k_duration}=                Is Parameter A Dictionary Key    dict=${current_dico}    parameter=duration
        ${k_monitoringSymbolWithinSlot}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=monitoringSymbolWithinSlot
        ${k_numOfPdcchCandidatesInAL1}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL1
        ${k_numOfPdcchCandidatesInAL16}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL16
        ${k_numOfPdcchCandidatesInAL2}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL2
        ${k_numOfPdcchCandidatesInAL4}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL4
        ${k_numOfPdcchCandidatesInAL8}=    Is Parameter A Dictionary Key    dict=${current_dico}    parameter=numOfPdcchCandidatesInAL8
        ${k_periodicity}=             Is Parameter A Dictionary Key    dict=${current_dico}    parameter=periodicity
        ${k_searchSpaceId}=           Is Parameter A Dictionary Key    dict=${current_dico}    parameter=searchSpaceId
        ${k_searchSpaceType}=         Is Parameter A Dictionary Key    dict=${current_dico}    parameter=searchSpaceType
        ${k_slotOffset}=              Is Parameter A Dictionary Key    dict=${current_dico}    parameter=slotOffset
        # PDCCH_CONFIG_DEDICATED.coresetId / add
        ${current_coresetId}=    Run Keyword If    ${k_coresetId}    Set Variable    ${current_dico}[coresetId]    ELSE    Set Variable    0
        # PDCCH_CONFIG_DEDICATED.dciFormat / add
        ${current_dciFormat}=    Run Keyword If    ${k_dciFormat}
        ...                           Set Variable    ${current_dico}[dciFormat]    ELSE    Set Variable    formats0-0-And-1-0
        # PDCCH_CONFIG_DEDICATED.duration / add
        ${current_duration}=    Run Keyword If    ${k_duration}    Set Variable    ${current_dico}[duration]    ELSE    Set Variable    1
        # PDCCH_CONFIG_DEDICATED.monitoringSymbolWithinSlot / add
        ${current_monitoringSymbolWithinSlot}=    Run Keyword If    ${k_monitoringSymbolWithinSlot}
        ...                           Set Variable    ${current_dico}[monitoringSymbolWithinSlot]    ELSE    Set Variable    symbol_0_1
        # PDCCH_CONFIG_DEDICATED.numOfPdcchCandidatesInAL1 / add
        ${current_numOfPdcchCandidatesInAL1}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL1}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL1]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_DEDICATED.numOfPdcchCandidatesInAL16 / add
        ${current_numOfPdcchCandidatesInAL16}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL16}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL16]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_DEDICATED.numOfPdcchCandidatesInAL2 / add
        ${current_numOfPdcchCandidatesInAL2}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL2}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL2]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_DEDICATED.numOfPdcchCandidatesInAL4 / add
        ${current_numOfPdcchCandidatesInAL4}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL4}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL4]    ELSE    Set Variable    n2
        # PDCCH_CONFIG_DEDICATED.numOfPdcchCandidatesInAL8 / add
        ${current_numOfPdcchCandidatesInAL8}=    Run Keyword If    ${k_numOfPdcchCandidatesInAL8}
        ...                           Set Variable    ${current_dico}[numOfPdcchCandidatesInAL8]    ELSE    Set Variable    n0
        # PDCCH_CONFIG_DEDICATED.periodicity / add
        ${current_periodicity}=    Run Keyword If    ${k_periodicity}    Set Variable    ${current_dico}[periodicity]    ELSE    Set Variable    sl1
        # PDCCH_CONFIG_DEDICATED.searchSpaceId / add
        ${current_searchSpaceId}=    Run Keyword If    ${k_searchSpaceId}
        ...                           Set Variable    ${current_dico}[searchSpaceId]    ELSE    Set Variable    1
        # PDCCH_CONFIG_DEDICATED.searchSpaceType / add
        ${current_searchSpaceType}=    Run Keyword If    ${k_searchSpaceType}
        ...                           Set Variable    ${current_dico}[searchSpaceType]    ELSE    Set Variable    Type3
        # PDCCH_CONFIG_DEDICATED.slotOffset / add
        ${current_slotOffset}=    Run Keyword If    ${k_slotOffset}    Set Variable    ${current_dico}[slotOffset]    ELSE    Set Variable    0
        &{dico_searchSpaceDedicated}=    Create Dictionary          coresetId=${current_coresetId}
        ...                                                         dciFormat=${current_dciFormat}
        ...                                                         duration=${current_duration}
        ...                                                         monitoringSymbolWithinSlot=${current_monitoringSymbolWithinSlot}
        ...                                                         numOfPdcchCandidatesInAL1=${current_numOfPdcchCandidatesInAL1}
        ...                                                         numOfPdcchCandidatesInAL16=${current_numOfPdcchCandidatesInAL16}
        ...                                                         numOfPdcchCandidatesInAL2=${current_numOfPdcchCandidatesInAL2}
        ...                                                         numOfPdcchCandidatesInAL4=${current_numOfPdcchCandidatesInAL4}
        ...                                                         numOfPdcchCandidatesInAL8=${current_numOfPdcchCandidatesInAL8}
        ...                                                         periodicity=${current_periodicity}
        ...                                                         searchSpaceId=${current_searchSpaceId}
        ...                                                         searchSpaceType=${current_searchSpaceType}
        ...                                                         slotOffset=${current_slotOffset}
        SCF Add items to list         dist_name=${current_dn}    list_name=${current_list}    elements=${dico_searchSpaceDedicated}
        Dated Log                     > SCF Add items to list ${current_dn}: ${current_list}= ${dico_searchSpaceDedicated}
    END


SCF Create BWP_PROFILE_PDSCH
    [Arguments]             ${profil_id}
    ...                     ${dico_pdsch}

    ${current_dn}=                    Set Variable    ${dn_bwp_profile_base}${profil_id}/PDSCH-1
    Dated Log New Line                ----SCF Create BWP_PROFILE_PDSCH ${current_dn}----
    Dated Log                         >> ${dico_pdsch}
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}
    Run Keyword If    ${flag_object}    Run Keywords    SCF Remove object    dist_name=${current_dn}
    ...    AND    Dated Log           > SCF Remove object ${current_dn}
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_pdsch}
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_pdsch}
    #
    ${k_pdschRat0RbgConfig}=          Is Parameter A Dictionary Key    dict=${dico_pdsch}    parameter=pdschRat0RbgConfig
    # BWP_PROFILE_PDSCH.pdschRat0RbgConfig / add
    ${current_param}=                 Set Variable    pdschRat0RbgConfig
    ${current_value}=    Run Keyword If    ${k_pdschRat0RbgConfig}
    ...                               Set Variable    ${dico_pdsch}[${current_param}]    ELSE    Set Variable    config1
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure NRDRB
    [Arguments]             ${dico}

    Dated Log New Line                ----SCF Configure NRDRB----
    ${k_allowedPdcchPowerBoostALDueCce}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=allowedPdcchPowerBoostALDueCce
    ${k_allowedPdcchPowerBoostALDueCfg}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=allowedPdcchPowerBoostALDueCfg
    ${dn_nrdrb_base}=                 Set Variable    ${dn_nrbts}/NRDRB-
    FOR    ${nrdrb_id}    IN RANGE    0    20
        ${current_dn}=                Set Variable    ${dn_nrdrb_base}${nrdrb_id}
        # NRDRB.allowedPdcchPowerBoostALDueCce / update
        ${current_param}=             Set Variable    allowedPdcchPowerBoostALDueCce
        ${nb_match}    ${result}      Get Values From Object    dist_name=${current_dn}    p_name=${current_param}
        Run Keyword If    ${nb_match} > 0 and ${k_allowedPdcchPowerBoostALDueCce}    Run Keywords
        ...    Dated Log              >> match for ${current_dn}: ${current_param}= ${result}
        ...    AND    Configure SCF Set Element    dist_name=${current_dn}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRDRB.allowedPdcchPowerBoostALDueCfg / update
        ${current_param}=             Set Variable    allowedPdcchPowerBoostALDueCfg
        ${nb_match}    ${result}      Get Values From Object    dist_name=${current_dn}    p_name=${current_param}
        Run Keyword If    ${nb_match} > 0 and ${k_allowedPdcchPowerBoostALDueCfg}    Run Keywords
        ...    Dated Log              >> match for ${current_dn}: ${current_param}= ${result}
        ...    AND    Configure SCF Set Element    dist_name=${current_dn}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    END


SCF Configure NRPMRNL
    [Arguments]             ${dico}

    Dated Log New Line                ----SCF Configure NRPMRNL----
    ${k_miNrCellUtilization}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrCellUtilization
    ${k_miNrPdcch}=                   Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrPdcch
    ${k_miNrPdcch2}=                  Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrPdcch2
    ${k_miNrRim}=                     Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrRim
    ${dn_nrpmrnl}=                    Set Variable    ${dn_nrpmrnl_base}1
    # NRPMRNL/miNrCellUtilization / update
    ${current_param}=                 Set Variable    miNrCellUtilization
    Run Keyword If    ${k_miNrCellUtilization}
        ...    Configure SCF Set Element    dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRPMRNL/miNrPdcch / update
    ${current_param}=                 Set Variable    miNrPdcch
    Run Keyword If    ${k_miNrPdcch}
        ...    Configure SCF Set Element    dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRPMRNL/miNrPdcch2 / update
    ${current_param}=                 Set Variable    miNrPdcch2
    Run Keyword If    ${k_miNrPdcch2}
        ...    Configure SCF Set Element    dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRPMRNL/miNrRim / update # CB009823 RIM framework-1 support
    ${current_param}=                 Set Variable    miNrRim
    Run Keyword If    ${k_miNrRim}
        ...    Configure SCF Set Element    dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]


SCF Configure BWP_PROFILE_PDCCH
    [Arguments]             ${dn_bwp_pdcch}
    ...                     ${dico_pdcch}

    Dated Log New Line                ----SCF Configure BWP_PROFILE_PDCCH----
    Dated Log                         >> ${dico_pdcch}
    ${k_alSelection}=                 Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=alSelection
    ${k_dciDedicatedAggLevel}=        Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciDedicatedAggregationLevel
    ${k_dciPagingAggLevel}=           Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciPagingAggregationLevel
    ${k_dciRaCompletionAggLevel}=     Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciRaCompletionAggregationLevel
    ${k_dciRaMsg2AggLevel}=           Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciRaMsg2AggregationLevel
    ${k_dciSiAggLevel}=               Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=dciSiAggregationLevel
    ${k_downgradeAL16toAL8}=          Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=downgradeAL16toAL8
    ${k_downgradeALProactive}=        Is Parameter A Dictionary Key    dict=${dico_pdcch}    parameter=downgradeALProactive
    # BWP_PROFILE/PDCCH.alSelection / update
    ${current_param}=                 Set Variable    alSelection
    ${current_value_alSelection}=     Run Keyword If    ${k_alSelection}    Set Variable    ${dico_pdcch}[${current_param}]
    Run Keyword If    ${k_alSelection}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.dciDedicatedAggregationLevel / update
    ${current_param}=                 Set Variable    dciDedicatedAggregationLevel
    Run Keyword If    ${k_dciDedicatedAggLevel}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.dciPagingAggregationLevel / update
    ${current_param}=                 Set Variable    dciPagingAggregationLevel
    Run Keyword If    ${k_dciPagingAggLevel}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.dciRaCompletionAggregationLevel / update
    ${current_param}=                 Set Variable    dciRaCompletionAggregationLevel
    Run Keyword If    ${k_dciRaCompletionAggLevel}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.dciRaMsg2AggregationLevel / update
    ${current_param}=                 Set Variable    dciRaMsg2AggregationLevel
    Run Keyword If    ${k_dciRaMsg2AggLevel}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.dciSiAggregationLevel / update
    ${current_param}=                 Set Variable    dciSiAggregationLevel
    Run Keyword If    ${k_dciSiAggLevel}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.downgradeAL16toAL8 / update
    ${current_param}=                 Set Variable    downgradeAL16toAL8
    Run Keyword If    ${k_downgradeAL16toAL8}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.downgradeALProactive / update
    ${current_param}=                 Set Variable    downgradeALProactive
    Run Keyword If    ${k_downgradeALProactive}
        ...    Configure SCF Set Element    dist_name=${dn_bwp_pdcch}    elem_name=${current_param}    elem_val=${dico_pdcch}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet / add list /  ONLY IF alSelection is dynamic
    ${current_list}=                  Set Variable    dynamicAggregationLevelSet
    # ${dn_bwp_pdcch}.${current_list}.aggregationLevelList / add / AL2_AL4
    # ${dn_bwp_pdcch}.${current_list}.cqiCorrectionUp / add / 10
    # ${dn_bwp_pdcch}.${current_list}.cqiDciCssAl1 / add / 159
    # ${dn_bwp_pdcch}.${current_list}.cqiDciCssAl16 / add / 159
    # ${dn_bwp_pdcch}.${current_list}.cqiDciCssAl2 / add / 159
    # ${dn_bwp_pdcch}.${current_list}.cqiDciCssAl4 / add / 159
    # ${dn_bwp_pdcch}.${current_list}.cqiDciCssAl8 / add / 159
    # ${dn_bwp_pdcch}.${current_list}.highOlcCqiOffset / add / 1
    # ${dn_bwp_pdcch}.${current_list}.lowOlcCqiOffset / add / 1
    # ${dn_bwp_pdcch}.${current_list}.pCqiErasureActTimer / add / 0
    # ${dn_bwp_pdcch}.${current_list}.pCqiErasureReduction / add / 0
    &{dict_dynamicAggregationLevelSet}=      Create Dictionary      aggregationLevelList=AL2_AL4
    ...                                                             cqiCorrectionUp=10
    ...                                                             cqiDciCssAl1=159
    ...                                                             cqiDciCssAl16=159
    ...                                                             cqiDciCssAl2=159
    ...                                                             cqiDciCssAl4=159
    ...                                                             cqiDciCssAl8=159
    ...                                                             highOlcCqiOffset=1
    ...                                                             lowOlcCqiOffset=1
    ...                                                             pCqiErasureActTimer=0
    ...                                                             pCqiErasureReduction=0
    Run Keyword If    ${k_alSelection} and "${current_value_alSelection}" == "dynamic"    Run Keywords
    ...    SCF Add List               dist_name=${dn_bwp_pdcch}    list_name=${current_list}
    ...    AND    Dated Log           > SCF Add List ${dn_bwp_pdcch}: ${current_list}    # 1st item creates automatically with default values
    ...    AND    SCF Add Items To List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elements=${dict_dynamicAggregationLevelSet}
    ...    AND    Dated Log           > SCF Add Items To List ${dn_bwp_pdcch}: ${current_list}: ${dict_dynamicAggregationLevelSet}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# CB012738 #
SCF Configure NRCELL
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}

    Dated Log New Line                ----SCF Configure NRCELL----
    Dated Log                         > from ${list_nrcell}
    ${k_actPdcchPowerBoost}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=actPdcchPowerBoost
    ${k_cellDepType}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=cellDepType
    ${k_actPdcchSharingWithPdsch}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=actPdcchSharingWithPdsch
    ${k_actCceSplit}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=actCceSplit
    ${k_actPRBBlanking}=              Is Parameter A Dictionary Key    dict=${dico}    parameter=actPRBBlanking
    ${k_nbrOfBlankedPRBsHighEdgeDL}=  Is Parameter A Dictionary Key    dict=${dico}    parameter=nbrOfBlankedPRBsHighEdgeDL
    ${k_nbrOfBlankedPRBsHighEdgeUL}=  Is Parameter A Dictionary Key    dict=${dico}    parameter=nbrOfBlankedPRBsHighEdgeUL
    ${k_nbrOfBlankedPRBsLowEdgeDL}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=nbrOfBlankedPRBsLowEdgeDL
    ${k_nbrOfBlankedPRBsLowEdgeUL}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=nbrOfBlankedPRBsLowEdgeUL
    ${k_type0CoresetConfiguration}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=type0CoresetConfigurationIndex
    ${k_ssbScs}=                      Is Parameter A Dictionary Key    dict=${dico}    parameter=ssbScs
    ${k_reqMinNumPuschPrb}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=reqMinNumPuschPrb
    ${k_maxNumOfCaUsersNRCell}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfCaUsersNRCell
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    @{list_bwp_dedicated}=            Create List
    ${nb_bwp}=                        Set Variable    0
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell}=            Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        # NRCELL.cellDepType / check
        ${current_param}=             Set Variable    cellDepType
        ${current_value}=    Run Keyword If    ${k_cellDepType}    Set Variable    ${dico}[${current_param}]
        Run Keyword If    ${k_cellDepType}    Should Be True  "${list_nrcell[${internal_pos}].cellDepType}" == "${current_value}"
        # NRCELL.actPdcchPowerBoost / update
        ${current_param}=             Set Variable    actPdcchPowerBoost
        Run Keyword If    ${k_actPdcchPowerBoost}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.actPdcchSharingWithPdsch / update
        ${current_param}=             Set Variable    actPdcchSharingWithPdsch
        Run Keyword If    ${k_actPdcchSharingWithPdsch}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.actCceSplit / update
        ${current_param}=             Set Variable    actCceSplit
        Run Keyword If    ${k_actCceSplit}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.actPRBBlanking / update
        ${current_param}=             Set Variable    actPRBBlanking
        Run Keyword If    ${k_actPRBBlanking}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.nbrOfBlankedPRBsHighEdgeDL / update
        ${current_param}=             Set Variable    nbrOfBlankedPRBsHighEdgeDL
        Run Keyword If    ${k_nbrOfBlankedPRBsHighEdgeDL}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.nbrOfBlankedPRBsHighEdgeUL / update
        ${current_param}=             Set Variable    nbrOfBlankedPRBsHighEdgeUL
        Run Keyword If    ${k_nbrOfBlankedPRBsHighEdgeUL}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.nbrOfBlankedPRBsLowEdgeDL / update
        ${current_param}=             Set Variable    nbrOfBlankedPRBsLowEdgeDL
        Run Keyword If    ${k_nbrOfBlankedPRBsLowEdgeDL}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.nbrOfBlankedPRBsLowEdgeUL / update
        ${current_param}=             Set Variable    nbrOfBlankedPRBsLowEdgeUL
        Run Keyword If    ${k_nbrOfBlankedPRBsLowEdgeUL}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.type0CoresetConfigurationIndex / update
        ${current_param}=             Set Variable    type0CoresetConfigurationIndex
        Run Keyword If    ${k_type0CoresetConfiguration}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.ssbScs / update
        ${current_param}=             Set Variable    ssbScs
        Run Keyword If    ${k_ssbScs}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.reqMinNumPuschPrb / update
        ${current_param}=             Set Variable    reqMinNumPuschPrb
        Run Keyword If    ${k_reqMinNumPuschPrb}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.maxNumOfCaUsersNRCell / update
        ${current_param}=             Set Variable    maxNumOfCaUsersNRCell
        Run Keyword If    ${k_maxNumOfCaUsersNRCell}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        #
        ${nb_bwp}=                    Get Dedicated Dist Name BWP_PROFILE For Cell    dn_nrcell=${current_nrcell}
        ...                                                         bwpdn_dedicated=${list_bwp_dedicated}
        ...                                                         bwp_param=bwpDN
        ...                                                         bwp_type=dedicated
    END
    Dated Log                         >> result for list_bwp_dedicated= ${list_bwp_dedicated} nb_bwp= ${nb_bwp}
    Run Keyword If    ${nb_bwp} > 0   SCF Configure BWP_PROFILE_PDCCH    dn_bwp_pdcch=${list_bwp_dedicated[0]}/PDCCH-1    dico_pdcch=${dico}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# CB011127 #
SCF Create NRRIM PROFILE
    [Arguments]             ${profil_id}
    ...                     ${current_nrcell}
    ...                     ${dico_nrrim}
    ...                     ${rim}=framework-0

    ${current_dn}=                    Set Variable    ${current_nrcell}/NRRIM_PROFILE-${profil_id}
    Dated Log New Line                ----SCF Create BWP_PROFILE ${current_dn}----
    Dated Log                         >> ${dico_nrrim}
    ${branch_version}=                Set Variable    ${TLConfig.topo.getBranchName()}
    Dated Log                         >> branch_version=${branch_version}
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}
    Run Keyword If    ${flag_object}    Run Keywords    SCF Remove object    dist_name=${current_dn}
    ...    AND    Dated Log           > SCF Remove object ${current_dn}
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_nrrim_profile}
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_nrrim_profile}
    #
    ${k_actFastMuteSrsBeamForRi}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actFastMuteSrsBeamForRi
    ${k_actRiDetectTriggerDlMit}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRiDetectTriggerDlMitigation
    ${k_actRimAsymmetricIndic}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimAsymmetricIndication
    ${k_actRimCmMeaPeriodReport}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimCmMeaPeriodReport
    ${k_actRimMitigationExtend}=      Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimMitigationExtend
    ${k_actRimPdcchMutingOnSpec}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimPdcchMutingOnSpecialSlot
    ${k_actRimPowerReduction}=        Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimPowerReduction
    ${k_actRimSoftDlMuting}=          Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimSoftDlMuting
    ${k_actRsEnoughIndication}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRsEnoughIndication
    ${k_factorRsSequence}=            Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=factorRsSequence
    ${k_factorRsSequenceRs2}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=factorRsSequenceRs2
    ${k_globalF0ForRs}=               Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=globalF0ForRs
    ${k_highPrioRbTransInMutedS}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=highPrioRbTransInMutedSlots
    ${k_nrRiDisableMonPowerOfUS}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiDisableMonitorPowerOfUSlot
    ${k_nrRiMonDownhillEndSymbo}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiMonitorDownhillEndSymbol
    ${k_nrRiMonDownhillStartSym}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiMonitorDownhillStartSymbol
    ${k_nrRiMonInSSlotEnabled}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiMonitorInSSlotEnabled
    ${k_nrRiMonitorWindow}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiMonitorWindow
    ${k_nrRiThresBase}=               Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresBase
    ${k_nrRiThresDropHeight}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresDropHeight
    ${k_nrRiThresDropHeightSpec}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresDropHeightSpecialSlot
    ${k_nrRiThresDurationRatio}=      Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresDurationRatio
    ${k_nrRimMitigationScheme}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimMitigationScheme
    ${k_nrRimPowerRampingStep}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimPowerRampingStep
    ${k_nrRimRarTpcCommand}=          Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimRarTpcCommand
    ${k_numDetectedSetIdForMit}=      Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numDetectedSetIdForMitigation
    ${k_numRbForRs}=                  Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numRbForRs
    ${k_numRsType1SetId}=             Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numRsType1SetId
    ${k_numRsType2SetId}=             Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numRsType2SetId
    ${k_offsetRsSequence}=            Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=offsetRsSequence
    ${k_offsetRsSequenceRs2}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=offsetRsSequenceRs2
    ${k_repetitionRsType1}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=repetitionRsType1
    ${k_repetitionRsType2}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=repetitionRsType2
    ${k_rimDlMitigationManualTrig}=   Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimDlMitigationManualTrigger
    ${k_rimDlMutingMaxRange}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimDlMutingMaxRange
    ${k_rimRssiMeasInRiState0}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimRssiMeasInRiState0
    ${k_rsDetectionWindow}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsDetectionWindow
    ${k_rsDistanceThreshold}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsDistanceThreshold
    ${k_rsNearFarConfig}=             Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsNearFarConfig
    ${k_rsPattern1Period}=            Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsPattern1Period
    ${k_rsPattern2Period}=            Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsPattern2Period
    ${k_rsPowerOffset}=               Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsPowerOffset
    ${k_rsSetId}=                     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsSetId
    ${k_rsSetIdDisplayInFault}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsSetIdDisplayInFault
    ${k_rsTransTrigger}=              Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsTransTrigger
    ${k_rsType1NScId}=                Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsType1NScId
    ${k_rsType2NScId}=                Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rsType2NScId
    ${k_startRbForRs}=                Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=startRbForRs
    ${k_startFreqOffsetForRs}=        Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=startFreqOffsetForRs
    # BWP_PROFILE.actFastMuteSrsBeamForRi / add
    ${current_param}=                 Set Variable    actFastMuteSrsBeamForRi
    ${current_value}=    Run Keyword If    ${k_actFastMuteSrsBeamForRi}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRiDetectTriggerDlMitigation / add
    ${current_param}=                 Set Variable    actRiDetectTriggerDlMitigation
    ${current_value}=    Run Keyword If    ${k_actRiDetectTriggerDlMit}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRimAsymmetricIndication / add
    ${current_param}=                 Set Variable    actRimAsymmetricIndication
    ${current_value}=    Run Keyword If    ${k_actRimAsymmetricIndic}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRimCmMeaPeriodReport / add
    ${current_param}=                 Set Variable    actRimCmMeaPeriodReport
    ${current_value}=    Run Keyword If    ${k_actRimCmMeaPeriodReport}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    Run Keyword If                    "${branch_version}" != "SBTS25R3"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRimMitigationExtend / add
    ${current_param}=                 Set Variable    actRimMitigationExtend
    ${current_value}=    Run Keyword If    ${k_actRimMitigationExtend}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRimPdcchMutingOnSpecialSlot / add
    ${current_param}=                 Set Variable    actRimPdcchMutingOnSpecialSlot
    ${current_value}=    Run Keyword If    ${k_actRimPdcchMutingOnSpec}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRimPowerReduction / add
    ${current_param}=                 Set Variable    actRimPowerReduction
    ${current_value}=    Run Keyword If    ${k_actRimPowerReduction}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRimSoftDlMuting / add
    ${current_param}=                 Set Variable    actRimSoftDlMuting
    ${current_value}=    Run Keyword If    ${k_actRimSoftDlMuting}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.actRsEnoughIndication / add
    ${current_param}=                 Set Variable    actRsEnoughIndication
    ${current_value}=    Run Keyword If    ${k_actRsEnoughIndication}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.factorRsSequence / add
    ${current_param}=                 Set Variable    factorRsSequence
    ${current_value}=    Run Keyword If    ${k_factorRsSequence}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.factorRsSequenceRs2 / add
    ${current_param}=                 Set Variable    factorRsSequenceRs2
    ${current_value}=    Run Keyword If    ${k_factorRsSequenceRs2}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    1
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.globalF0ForRs / add
    ${current_param}=                 Set Variable    globalF0ForRs
    ${current_value}=    Run Keyword If    ${k_globalF0ForRs}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    633390
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.highPrioRbTransInMutedSlots / add
    ${current_param}=                 Set Variable    highPrioRbTransInMutedSlots
    ${current_value}=    Run Keyword If    ${k_highPrioRbTransInMutedS}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiDisableMonitorPowerOfUSlot / add
    ${current_param}=                 Set Variable    nrRiDisableMonitorPowerOfUSlot
    ${current_value}=    Run Keyword If    ${k_nrRiDisableMonPowerOfUS}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiMonitorDownhillEndSymbol / add
    ${current_param}=                 Set Variable    nrRiMonitorDownhillEndSymbol
    ${current_value}=    Run Keyword If    ${k_nrRiMonDownhillEndSymbo}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    11
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiMonitorDownhillStartSymbol / add
    ${current_param}=                 Set Variable    nrRiMonitorDownhillStartSymbol
    ${current_value}=    Run Keyword If    ${k_nrRiMonDownhillStartSym}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiMonitorInSSlotEnabled / add
    ${current_param}=                 Set Variable    nrRiMonitorInSSlotEnabled
    ${current_value}=    Run Keyword If    ${k_nrRiMonInSSlotEnabled}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiMonitorWindow / add
    ${current_param}=                 Set Variable    nrRiMonitorWindow
    ${current_value}=    Run Keyword If    ${k_nrRiMonitorWindow}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    5
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiThresBase / add
    ${current_param}=                 Set Variable    nrRiThresBase
    ${current_value}=    Run Keyword If    ${k_nrRiThresBase}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    -100
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiThresDropHeight / add
    ${current_param}=                 Set Variable    nrRiThresDropHeight
    ${current_value}=    Run Keyword If    ${k_nrRiThresDropHeight}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    6
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiThresDropHeightSpecialSlot / add
    ${current_param}=                 Set Variable    nrRiThresDropHeightSpecialSlot
    ${current_value}=    Run Keyword If    ${k_nrRiThresDropHeightSpec}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    6
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRiThresDurationRatio / add
    ${current_param}=                 Set Variable    nrRiThresDurationRatio
    ${current_value}=    Run Keyword If    ${k_nrRiThresDurationRatio}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    80
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRimMitigationScheme / add
    ${current_param}=                 Set Variable    nrRimMitigationScheme
    ${current_value}=    Run Keyword If    ${k_nrRimMitigationScheme}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    UL and DL mitigation
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRimPowerRampingStep / add
    ${current_param}=                 Set Variable    nrRimPowerRampingStep
    ${current_value}=    Run Keyword If    ${k_nrRimPowerRampingStep}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    dB6
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.nrRimRarTpcCommand / add
    ${current_param}=                 Set Variable    nrRimRarTpcCommand
    ${current_value}=    Run Keyword If    ${k_nrRimRarTpcCommand}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    8dB
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.numDetectedSetIdForMitigation / add
    ${current_param}=                 Set Variable    numDetectedSetIdForMitigation
    ${current_value}=    Run Keyword If    ${k_numDetectedSetIdForMit}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    1
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.numRbForRs / add
    ${current_param}=                 Set Variable    numRbForRs
    ${current_value}=    Run Keyword If    ${k_numRbForRs}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    48 RBs
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.numRsType1SetId / add
    ${current_param}=                 Set Variable    numRsType1SetId
    ${current_value}=    Run Keyword If    ${k_numRsType1SetId}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    65536 setIDs
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.numRsType2SetId / add
    ${current_param}=                 Set Variable    numRsType2SetId
    ${current_value}=    Run Keyword If    ${k_numRsType2SetId}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    65536 setIDs
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.offsetRsSequence / add
    ${current_param}=                 Set Variable    offsetRsSequence
    ${current_value}=    Run Keyword If    ${k_offsetRsSequence}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.offsetRsSequenceRs2 / add
    ${current_param}=                 Set Variable    offsetRsSequenceRs2
    ${current_value}=    Run Keyword If    ${k_offsetRsSequenceRs2}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    1
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.repetitionRsType1 / add
    ${current_param}=                 Set Variable    repetitionRsType1
    ${current_value}=    Run Keyword If    ${k_repetitionRsType1}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    r2
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.repetitionRsType2 / add
    ${current_param}=                 Set Variable    repetitionRsType2
    ${current_value}=    Run Keyword If    ${k_repetitionRsType2}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    r2
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rimDlMitigationManualTrigger / add
    ${current_param}=                 Set Variable    rimDlMitigationManualTrigger
    ${current_value}=    Run Keyword If    ${k_rimDlMitigationManualTrig}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    disabled
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rimDlMutingMaxRange / add
    ${current_param}=                 Set Variable    rimDlMutingMaxRange
    ${current_value}=    Run Keyword If    ${k_rimDlMutingMaxRange}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    DL+special slots
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rimRssiMeasInRiState0 / add
    ${current_param}=                 Set Variable    rimRssiMeasInRiState0
    ${current_value}=    Run Keyword If    ${k_rimRssiMeasInRiState0}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsDetectionWindow / add
    ${current_param}=                 Set Variable    rsDetectionWindow
    ${current_value}=    Run Keyword If    ${k_rsDetectionWindow}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    sloping based
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add element    dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...    AND    Dated Log           > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsDistanceThreshold / add
    ${current_param}=                 Set Variable    rsDistanceThreshold
    ${current_value}=    Run Keyword If    ${k_rsDistanceThreshold}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsNearFarConfig / add
    ${current_param}=                 Set Variable    rsNearFarConfig
    ${current_value}=    Run Keyword If    ${k_rsNearFarConfig}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    near-far config1
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsPattern1Period / add
    ${current_param}=                 Set Variable    rsPattern1Period
    ${current_value}=    Run Keyword If    ${k_rsPattern1Period}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    5ms
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsPattern2Period / add
    ${current_param}=                 Set Variable    rsPattern2Period
    ${current_value}=    Run Keyword If    ${k_rsPattern2Period}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    2.5ms
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsPowerOffset / add
    ${current_param}=                 Set Variable    rsPowerOffset
    ${current_value}=    Run Keyword If    ${k_rsPowerOffset}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsSetId / add
    ${current_param}=                 Set Variable    rsSetId
    ${current_value}=    Run Keyword If    ${k_rsSetId}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsSetIdDisplayInFault / add
    ${current_param}=                 Set Variable    rsSetIdDisplayInFault
    ${current_value}=    Run Keyword If    ${k_rsSetIdDisplayInFault}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    enabled
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsTransTrigger / add
    ${current_param}=                 Set Variable    rsTransTrigger
    ${current_value}=    Run Keyword If    ${k_rsTransTrigger}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Set Variable    RI trigger
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # BWP_PROFILE.rsType1NScId / add
    ${current_param}=                 Set Variable    rsType1NScId
    @{current_list}=    Run Keyword If    ${k_rsType1NScId}    Copy List    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Create List    1    2    3    4    5    6    7    8
    SCF Add list                      dist_name=${current_dn}    list_name=${current_param}
    SCF Add elements to list          dist_name=${current_dn}    list_name=${current_param}    elements=${current_list}
    Dated Log                         > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    # BWP_PROFILE.rsType2NScId / add
    ${current_param}=                 Set Variable    rsType2NScId
    @{current_list}=    Run Keyword If    ${k_rsType2NScId}    Copy List    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Create List    1    2    3    4    5    6    7    8
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add list    dist_name=${current_dn}    list_name=${current_param}
    ...    AND                        SCF Add elements to list    dist_name=${current_dn}    list_name=${current_param}    elements=${current_list}
    ...    AND    Dated Log           > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    # BWP_PROFILE.startRbForRs / add
    ${current_param}=                 Set Variable    startRbForRs
    @{current_list}=    Run Keyword If    ${k_startRbForRs}    Copy List    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Create List    0    48    96    144
    Run Keyword If    "${rim}" == "framework-0"    Run Keywords
    ...                               SCF Add list    dist_name=${current_dn}    list_name=${current_param}
    ...    AND                        SCF Add elements to list    dist_name=${current_dn}    list_name=${current_param}    elements=${current_list}
    ...    AND    Dated Log           > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    # BWP_PROFILE.startFreqOffsetForRs / add
    ${current_param}=                 Set Variable    startFreqOffsetForRs
    @{current_list}=    Run Keyword If    ${k_startFreqOffsetForRs}    Copy List    ${dico_nrrim}[${current_param}]
    ...                              ELSE    Create List    86
    Run Keyword If    "${rim}" == "framework-1"    Run Keywords
    ...                               SCF Add list    dist_name=${current_dn}    list_name=${current_param}
    ...    AND                        SCF Add elements to list    dist_name=${current_dn}    list_name=${current_param}    elements=${current_list}
    ...    AND    Dated Log           > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}


SCF Configure NRCELL For CB011127
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}

    Dated Log New Line                ----SCF Configure NRCELL----
    Dated Log                         > from ${list_nrcell}
    ${k_cellDepType}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=cellDepType
    ${k_actNrRim}=                    Is Parameter A Dictionary Key    dict=${dico}    parameter=actNrRim
    ${k_actNrRimRsResourcePooling}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=actNrRimRsResourcePooling
    ${k_actBpPoolExtensionTddFr1}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolExtensionTddFr1
    ${k_actBpPoolTddFr1}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolTddFr1
    ${k_actBpPoolTddFr1AlgEnh}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolTddFr1AlgEnh
    ${k_actBpPoolTddFr1Enh}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolTddFr1Enh
    ${k_actRtwpMeasurement}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=actRtwpMeasurement
    ${k_bbmodBoardConfigType}=        Is Parameter A Dictionary Key    dict=${dico}    parameter=bbmodBoardConfigType
    ${k_factorRsSequence}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=factorRsSequence
    ${k_factorRsSequenceRs2}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=factorRsSequenceRs2
    ${k_globalF0ForRs}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=globalF0ForRs
    ${k_nrRimMitigationScheme}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRimMitigationScheme
    ${k_nrRiMonInSSlotEnabled}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiMonitorInSSlotEnabled
    ${k_nrRiMonitorWindow}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiMonitorWindow
    ${k_numRbForRs}=                  Is Parameter A Dictionary Key    dict=${dico}    parameter=numRbForRs
    ${k_numRsType1SetId}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=numRsType1SetId
    ${k_numRsType2SetId}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=numRsType2SetId
    ${k_offsetRsSequence}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=offsetRsSequence
    ${k_offsetRsSequenceRs2}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=offsetRsSequenceRs2
    ${k_repetitionRsType1}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=repetitionRsType1
    ${k_repetitionRsType2}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=repetitionRsType2
    ${k_rsDetectionWindow}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=rsDetectionWindow
    ${k_rsNearFarConfig}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=rsNearFarConfig
    ${k_rsPattern1Period}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=rsPattern1Period
    ${k_rsPattern2Period}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=rsPattern2Period
    ${k_rsTransTrigger}=              Is Parameter A Dictionary Key    dict=${dico}    parameter=rsTransTrigger
    ${k_rsType1NScId}=                Is Parameter A Dictionary Key    dict=${dico}    parameter=rsType1NScId
    ${k_rsType2NScId}=                Is Parameter A Dictionary Key    dict=${dico}    parameter=rsType2NScId
    ${k_startRbForRs}=                Is Parameter A Dictionary Key    dict=${dico}    parameter=startRbForRs
    ${k_startFreqOffsetForRs}=        Is Parameter A Dictionary Key    dict=${dico}    parameter=startFreqOffsetForRs
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    @{list_bwp_dedicated}=            Create List
    ${nb_bwp}=                        Set Variable    0
    # NRBTS.actBpPoolExtensionTddFr1 / update
    ${current_param}=             Set Variable    actBpPoolExtensionTddFr1
    Run Keyword If    ${k_actBpPoolExtensionTddFr1}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRBTS.actBpPoolTddFr1 / update
    ${current_param}=             Set Variable    actBpPoolTddFr1
    Run Keyword If    ${k_actBpPoolTddFr1}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRBTS.actBpPoolTddFr1AlgEnh / update
    ${current_param}=             Set Variable    actBpPoolTddFr1AlgEnh
    Run Keyword If    ${k_actBpPoolTddFr1AlgEnh}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRBTS.actBpPoolTddFr1Enh / update
    ${current_param}=             Set Variable    actBpPoolTddFr1Enh
    Run Keyword If    ${k_actBpPoolTddFr1Enh}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRBTS.actNrRimRsResourcePooling / update
    ${current_param}=             Set Variable    actNrRimRsResourcePooling
    Run Keyword If    ${k_actNrRimRsResourcePooling}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRBTS.actRtwpMeasurement / update
    ${current_param}=             Set Variable    actRtwpMeasurement
    Run Keyword If    ${k_actRtwpMeasurement}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # BBMOD.bbmodBoardConfigType / update
    ${current_param}=             Set Variable    bbmodBoardConfigType
    Run Keyword If    ${k_bbmodBoardConfigType}
    ...    Configure SCF Set Element    dist_name=${dn_bbmod}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    #
    &{dico_nrrim_profile}=            Create Dictionary    lambda=null
    # NRCELL/NRRIM_PROFILE.factorRsSequence / update
    ${current_param}=                 Set Variable    factorRsSequence
    Run Keyword If    ${k_factorRsSequence}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.factorRsSequenceRs2 / update
    ${current_param}=                 Set Variable    factorRsSequenceRs2
    Run Keyword If    ${k_factorRsSequenceRs2}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.globalF0ForRs / update
    ${current_param}=                 Set Variable    globalF0ForRs
    Run Keyword If    ${k_globalF0ForRs}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRimMitigationScheme / update
    ${current_param}=                 Set Variable    nrRimMitigationScheme
    Run Keyword If    ${k_nrRimMitigationScheme}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiMonitorInSSlotEnabled / update
    ${current_param}=                 Set Variable    nrRiMonitorInSSlotEnabled
    Run Keyword If    ${k_nrRiMonInSSlotEnabled}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiMonitorWindow / update
    ${current_param}=                 Set Variable    nrRiMonitorWindow
    Run Keyword If    ${k_nrRiMonitorWindow}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numRbForRs / update
    ${current_param}=                 Set Variable    numRbForRs
    Run Keyword If    ${k_numRbForRs}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numRsType1SetId / update
    ${current_param}=                 Set Variable    numRsType1SetId
    Run Keyword If    ${k_numRsType1SetId}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numRsType2SetId / update
    ${current_param}=                 Set Variable    numRsType2SetId
    Run Keyword If    ${k_numRsType2SetId}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.offsetRsSequence / update
    ${current_param}=                 Set Variable    offsetRsSequence
    Run Keyword If    ${k_offsetRsSequence}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.offsetRsSequenceRs2 / update
    ${current_param}=                 Set Variable    offsetRsSequenceRs2
    Run Keyword If    ${k_offsetRsSequenceRs2}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.repetitionRsType1 / update
    ${current_param}=                 Set Variable    repetitionRsType1
    Run Keyword If    ${k_repetitionRsType1}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.repetitionRsType2 / update
    ${current_param}=                 Set Variable    repetitionRsType2
    Run Keyword If    ${k_repetitionRsType2}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsDetectionWindow / update
    ${current_param}=                 Set Variable    rsDetectionWindow
    Run Keyword If    ${k_rsDetectionWindow}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsNearFarConfig / update
    ${current_param}=                 Set Variable    rsNearFarConfig
    Run Keyword If    ${k_rsNearFarConfig}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsPattern1Period / update
    ${current_param}=                 Set Variable    rsPattern1Period
    Run Keyword If    ${k_rsPattern1Period}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsPattern2Period / update
    ${current_param}=                 Set Variable    rsPattern2Period
    Run Keyword If    ${k_rsPattern2Period}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsTransTrigger / update
    ${current_param}=                 Set Variable    rsTransTrigger
    Run Keyword If    ${k_rsTransTrigger}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsType1NScId / update
    ${current_param}=                 Set Variable    rsType1NScId
    Run Keyword If    ${k_rsType1NScId}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsType2NScId / update
    ${current_param}=                 Set Variable    rsType2NScId
    Run Keyword If    ${k_rsType2NScId}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.startRbForRs / update
    ${current_param}=                 Set Variable    startRbForRs
    Run Keyword If    ${k_startRbForRs}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.startFreqOffsetForRs / update
    ${current_param}=                 Set Variable    startFreqOffsetForRs
    Run Keyword If    ${k_startFreqOffsetForRs}    Set To Dictionary    ${dico_nrrim_profile}    ${current_param}    ${dico}[${current_param}]
    #
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell}=            Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        # NRCELL.cellDepType / check
        ${current_param}=             Set Variable    cellDepType
        ${current_value}=    Run Keyword If    ${k_cellDepType}    Set Variable    ${dico}[${current_param}]
        Run Keyword If    ${k_cellDepType}    Should Be True  "${list_nrcell[${internal_pos}].cellDepType}" == "${current_value}"
        # NRCELL.actNrRim / update
        ${current_param}=             Set Variable    actNrRim
        ${current_act_rim_rs}=    Run Keyword If    ${k_actNrRim}    Set Variable    ${dico}[${current_param}]
        ...                              ELSE    Set Variable    framework-0    # default value
        Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${current_act_rim_rs}
        #
        SCF Create NRRIM PROFILE    profil_id=1    current_nrcell=${current_nrcell}    dico_nrrim=${dico_nrrim_profile}    rim=${current_act_rim_rs}
        #
        ${nb_bwp}=                    Get Dedicated Dist Name BWP_PROFILE For Cell    dn_nrcell=${current_nrcell}
        ...                                                         bwpdn_dedicated=${list_bwp_dedicated}
        ...                                                         bwp_param=bwpDN
        ...                                                         bwp_type=dedicated
    END
    Dated Log                         >> result for list_bwp_dedicated= ${list_bwp_dedicated} nb_bwp= ${nb_bwp}
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure dynamicAggLevelSet
    [Arguments]             ${dn_bwp_pdcch}
    ...                     ${dico_dynAgg}

    Dated Log New Line                ----SCF Configure dynamicAggLevelSet----
    Dated Log                         > from ${dn_bwp_pdcch}
    ${k_aggregationLevelList}=        Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=aggregationLevelList
    ${k_cqiCorrectionUp}=             Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=cqiCorrectionUp
    ${k_cqiDciCssAl1}=                Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=cqiDciCssAl1
    ${k_cqiDciCssAl16}=               Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=cqiDciCssAl16
    ${k_cqiDciCssAl2}=                Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=cqiDciCssAl2
    ${k_cqiDciCssAl4}=                Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=cqiDciCssAl4
    ${k_cqiDciCssAl8}=                Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=cqiDciCssAl8
    ${k_highOlcCqiOffset}=            Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=highOlcCqiOffset
    ${k_lowOlcCqiOffset}=             Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=lowOlcCqiOffset
    ${k_pCqiErasureActTimer}=         Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=pCqiErasureActTimer
    ${k_pCqiErasureReduction}=        Is Parameter A Dictionary Key    dict=${dico_dynAgg}    parameter=pCqiErasureReduction
    ${current_list}=                  Set Variable    dynamicAggregationLevelSet
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.aggregationLevelList / update
    ${current_param}=                 Set Variable    aggregationLevelList
    Run Keyword If    ${k_aggregationLevelList}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.cqiCorrectionUp / update
    ${current_param}=                 Set Variable    cqiCorrectionUp
    Run Keyword If    ${k_cqiCorrectionUp}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.cqiDciCssAl1 / update
    ${current_param}=                 Set Variable    cqiDciCssAl1
    Run Keyword If    ${k_cqiDciCssAl1}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.cqiDciCssAl16 / update
    ${current_param}=                 Set Variable    cqiDciCssAl16
    Run Keyword If    ${k_cqiDciCssAl16}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.cqiDciCssAl2 / update
    ${current_param}=                 Set Variable    cqiDciCssAl2
    Run Keyword If    ${k_cqiDciCssAl2}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.cqiDciCssAl4 / update
    ${current_param}=                 Set Variable    cqiDciCssAl4
    Run Keyword If    ${k_cqiDciCssAl4}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.cqiDciCssAl8 / update
    ${current_param}=                 Set Variable    cqiDciCssAl8
    Run Keyword If    ${k_cqiDciCssAl8}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.highOlcCqiOffset / update
    ${current_param}=                 Set Variable    highOlcCqiOffset
    Run Keyword If    ${k_highOlcCqiOffset}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.lowOlcCqiOffset / update
    ${current_param}=                 Set Variable    lowOlcCqiOffset
    Run Keyword If    ${k_lowOlcCqiOffset}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.pCqiErasureActTimer / update
    ${current_param}=                 Set Variable    pCqiErasureActTimer
    Run Keyword If    ${k_pCqiErasureActTimer}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]
    # BWP_PROFILE/PDCCH.dynamicAggregationLevelSet.pCqiErasureReduction / update
    ${current_param}=                 Set Variable    pCqiErasureReduction
    Run Keyword If    ${k_pCqiErasureReduction}
    ...    Configure SCF Set Element In List    dist_name=${dn_bwp_pdcch}    list_name=${current_list}    elem_name=${current_param}
    ...                                                         elem_val=${dico_dynAgg}[${current_param}]


SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    [Arguments]             ${dico}
    ...                     ${list_position}
    ...                     ${list_nrcell}

    Dated Log New Line                ----SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet----
    Dated Log                         > from ${list_nrcell}
    @{list_bwp_dedicated}=            Create List
    ${nb_bwp}=                        Set Variable    0
    FOR    ${position}    IN    @{list_position}
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell}=            Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        ${nb_bwp}=                    Get Dedicated Dist Name BWP_PROFILE For Cell    dn_nrcell=${current_nrcell}
        ...                                                         bwpdn_dedicated=${list_bwp_dedicated}
        ...                                                         bwp_param=bwpDN
        ...                                                         bwp_type=dedicated
    END
    Dated Log                         >> result for list_bwp_dedicated= ${list_bwp_dedicated} nb_bwp= ${nb_bwp}
    Run Keyword If    ${nb_bwp} > 0   SCF Configure dynamicAggLevelSet    dn_bwp_pdcch=${list_bwp_dedicated[0]}/PDCCH-1    dico_dynAgg=${dico}


SCF Configure NRCELL BW
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}

    ${k_chBw}=                        Is Parameter A Dictionary Key    dict=${dico}    parameter=chBw
    ${k_chBwDl}=                      Is Parameter A Dictionary Key    dict=${dico}    parameter=chBwDl
    ${k_chBwUl}=                      Is Parameter A Dictionary Key    dict=${dico}    parameter=chBwUl
    Should Be True                    ${k_chBw} == ${True} or ${k_chBwDl} == ${True}
    Should Be True                    ${k_chBw} == ${True} or ${k_chBwUl} == ${True}
    Dated Log New Line                ----SCF Configure NRCELL BW----
    Dated Log                         > from ${list_nrcell}
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    ${k_dmrsTypeAPosition}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=dmrsTypeAPosition
    ${k_freqBandIndicatorNR}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=freqBandIndicatorNR
    ${k_gscnOrSsPbchArfcn}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=gscnOrSsPbchArfcn
    ${k_maxNumOfCaUsersNRCell}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfCaUsersNRCell
    ${k_msg1FrequencyStart}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=msg1FrequencyStart
    ${k_nrarfcn}=                     Is Parameter A Dictionary Key    dict=${dico}    parameter=nrarfcn
    ${k_nrarfcnDl}=                   Is Parameter A Dictionary Key    dict=${dico}    parameter=nrarfcnDl
    ${k_nrarfcnUl}=                   Is Parameter A Dictionary Key    dict=${dico}    parameter=nrarfcnUl
    ${k_prachConfigurationIndex}=     Is Parameter A Dictionary Key    dict=${dico}    parameter=prachConfigurationIndex
    ${k_reqMinNumPuschPrb}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=reqMinNumPuschPrb
    ${k_bwpDN_initial}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=bwpDN_initial
    ${k_bwpDN_dedicated}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=bwpDN_dedicated
    ${k_srsForBeamMgmt_bSRS}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=srsForBeamMgmt_bSRS
    ${k_srsForBeamMgmt_cSRS}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=srsForBeamMgmt_cSRS
    ${k_type0CoresetConfigIndex}=     Is Parameter A Dictionary Key    dict=${dico}    parameter=type0CoresetConfigurationIndex
    ${k_type0SearchSpaceConfIndex}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=type0SearchSpaceConfigurationIndex
    ${k_fPdcchMonOccsnPo}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=fPdcchMonOccsnPo
    ${k_tddFrameStructure}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=tddFrameStructure
    ${k_frameStructureType}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=frameStructureType
    ${k_guardPeriodLength}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=guardPeriodLength
    ${k_lteToNrFrameShift}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=lteToNrFrameShift
    ${k_tdLteUlDlConfig}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=tdLteUlDlConfig
    ${k_ulDlDataSlotRatio}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=ulDlDataSlotRatio
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        # Information from SWENG dictionary
        ${nr_cell_id}=                Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
        #
        ${current_nrcell}=            Set Variable    ${dn_nrbts}/NRCELL-${nr_cell_id}
        ${current_nrcell_fdd}=        Set Variable    ${current_nrcell}/NRCELL_FDD-1
        ${set_cell_id}=               Set Variable    set_cell id=${nr_cell_id} gnb=2
        # NRCELL.chBw / update
        ${current_param}=             Set Variable    chBw
        Run Keyword If    ${k_chBw}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL/NRCELL_FDD.chBwDl / update
        ${current_param}=             Set Variable    chBwDl
        Run Keyword If    ${k_chBwDl}
        ...    Configure SCF Set Element    dist_name=${current_nrcell_fdd}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL/NRCELL_FDD.chBwUl / update
        ${current_param}=             Set Variable    chBwUl
        Run Keyword If    ${k_chBwUl}
        ...    Configure SCF Set Element    dist_name=${current_nrcell_fdd}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.dmrsTypeAPosition / update
        ${current_param}=             Set Variable    dmrsTypeAPosition
        Run Keyword If    ${k_dmrsTypeAPosition}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.freqBandIndicatorNR / update
        ${current_param}=             Set Variable    freqBandIndicatorNR
        Run Keyword If    ${k_freqBandIndicatorNR}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.gscnOrSsPbchArfcn / update
        ${current_param}=             Set Variable    gscnOrSsPbchArfcn
        Run Keyword If    ${k_gscnOrSsPbchArfcn}    Run Keywords
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        ...    AND    Configure Parameter In WTS basic_setup File    identifier=${set_cell_id}    param=gscn    value=${dico}[${current_param}]
        ...    AND    Configure Parameter In AP iphy File    identifier=${nr_cell_id}    param=GSCN    value=${dico}[${current_param}]
        # NRCELL.maxNumOfCaUsersNRCell / update
        ${current_param}=             Set Variable    maxNumOfCaUsersNRCell
        Run Keyword If    ${k_maxNumOfCaUsersNRCell}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.msg1FrequencyStart / update
        ${current_param}=             Set Variable    msg1FrequencyStart
        Run Keyword If    ${k_msg1FrequencyStart}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.nrarfcn / update
        ${current_param}=             Set Variable    nrarfcn
        Run Keyword If    ${k_nrarfcn}    Run Keywords
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        ...    AND    Configure Parameter In WTS basic_setup File    identifier=${set_cell_id}    param=nr_arfcn
        ...                                                         value=${dico}[${current_param}]:${dico}[${current_param}]
        # NRCELL/NRCELL_FDD.nrarfcnDl / update
        ${current_param}=             Set Variable    nrarfcnDl
        Run Keyword If    ${k_nrarfcnDl}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL/NRCELL_FDD.nrarfcnUl / update
        ${current_param}=             Set Variable    nrarfcnUl
        Run Keyword If    ${k_nrarfcnUl}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        Run Keyword If    ${k_nrarfcnUl} and ${k_nrarfcnDl}    Configure Parameter In WTS basic_setup File    identifier=${set_cell_id}
        ...                                                         param=nr_arfcn    value=${dico}[nrarfcnUl]:${dico}[nrarfcnDl]
        # NRCELL.prachConfigurationIndex / update
        ${current_param}=             Set Variable    prachConfigurationIndex
        Run Keyword If    ${k_prachConfigurationIndex}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.reqMinNumPuschPrb / update
        ${current_param}=             Set Variable    reqMinNumPuschPrb
        Run Keyword If    ${k_reqMinNumPuschPrb}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.type0CoresetConfigurationIndex / update
        ${current_param}=             Set Variable    type0CoresetConfigurationIndex
        Run Keyword If    ${k_type0CoresetConfigIndex}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.type0SearchSpaceConfigurationIndex / update
        ${current_param}=             Set Variable    type0SearchSpaceConfigurationIndex
        Run Keyword If    ${k_type0SearchSpaceConfIndex}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.fPdcchMonOccsnPo / update
        ${current_list}=              Set Variable    fPdcchMonOccsnPo
        @{current_value}=    Run Keyword If    ${k_fPdcchMonOccsnPo}    Create List    ${dico}[${current_list}]
        Run Keyword If    ${k_fPdcchMonOccsnPo}    Run Keywords
        ...    SCF Remove list        dist_name=${current_nrcell}    list_name=${current_list}
        ...    AND                    SCF Add list    dist_name=${current_nrcell}    list_name=${current_list}
        ...    AND    Dated Log       > SCF Remove and Add list ${current_nrcell}: ${current_list}
        ...    AND    SCF Add elements to list    dist_name=${current_nrcell}    list_name=${current_list}    elements=${current_value}
        ...    AND    Dated Log       > SCF Add elements to list ${current_nrcell}: ${current_list}= ${current_value}
        # NRCELL.tddFrameStructure / remove + add
        ${current_list}=              Set Variable    tddFrameStructure
        &{dico_tddFrameStructure}=    Run Keyword If    ${k_tddFrameStructure}    Create Dictionary
        # NRCELL.tddFrameStructure.frameStructureType / update
        ${current_param}=             Set Variable    frameStructureType
        Run Keyword If    ${k_tddFrameStructure} and ${k_frameStructureType}
        ...                           Set To Dictionary    ${dico_tddFrameStructure}    ${current_param}    ${dico}[${current_param}]
        # NRCELL.tddFrameStructure.guardPeriodLength / update
        ${current_param}=             Set Variable    guardPeriodLength
        Run Keyword If    ${k_tddFrameStructure} and ${k_guardPeriodLength}
        ...                           Set To Dictionary    ${dico_tddFrameStructure}    ${current_param}    ${dico}[${current_param}]
        # NRCELL.tddFrameStructure.lteToNrFrameShift / update
        ${current_param}=             Set Variable    lteToNrFrameShift
        Run Keyword If    ${k_tddFrameStructure} and ${k_lteToNrFrameShift}
        ...                           Set To Dictionary    ${dico_tddFrameStructure}    ${current_param}    ${dico}[${current_param}]
        # NRCELL.tddFrameStructure.tdLteUlDlConfig / update
        ${current_param}=             Set Variable    tdLteUlDlConfig
        Run Keyword If    ${k_tddFrameStructure} and ${k_tdLteUlDlConfig}
        ...                           Set To Dictionary    ${dico_tddFrameStructure}    ${current_param}    ${dico}[${current_param}]
        # NRCELL.tddFrameStructure.ulDlDataSlotRatio / update
        ${current_param}=             Set Variable    ulDlDataSlotRatio
        Run Keyword If    ${k_tddFrameStructure} and ${k_ulDlDataSlotRatio} and "${dico}[${current_param}]" != "${None}"
        ...                           Set To Dictionary    ${dico_tddFrameStructure}    ${current_param}    ${dico}[${current_param}]
        Run Keyword If    ${k_tddFrameStructure}    Run Keywords
        ...                           SCF Remove list        dist_name=${current_nrcell}    list_name=${current_list}
        ...    AND                    SCF Add list    dist_name=${current_nrcell}    list_name=${current_list}
        ...    AND    Dated Log       > SCF Remove and Add list ${current_nrcell}: ${current_list}
        ...    AND    SCF Add items to list    dist_name=${current_nrcell}    list_name=${current_list}    elements=${dico_tddFrameStructure}
        ...    AND    Dated Log       > SCF Add items to list ${current_nrcell}: ${current_list}= ${dico_tddFrameStructure}
        # NRCELL.cellBwpList / remove list + add list
        ${current_list}=              Set Variable    cellBwpList
        &{dico_cellBwp_0}=            Create Dictionary             actPdcchCceFragmentControl=false
        ...                                                         actUpperThrAckNackFiltering=false
        ...                                                         actUpperThrAckNackHrFiltering=false
        ...                                                         bwpDN=${dn_bwp_profile_base}${dico}[bwpDN_initial]
        ...                                                         cellBwpId=0
        ...                                                         pdcchResourcePreference=peakRate
        &{dico_cellBwp_1}=            Create Dictionary             actPdcchCceFragmentControl=false
        ...                                                         actUpperThrAckNackFiltering=false
        ...                                                         actUpperThrAckNackHrFiltering=false
        ...                                                         bwpDN=${dn_bwp_profile_base}${dico}[bwpDN_dedicated]
        ...                                                         cellBwpId=1
        ...                                                         pdcchResourcePreference=peakRate
        Run Keyword If    ${k_bwpDN_initial} and ${k_bwpDN_dedicated}    Run Keywords
        ...                           SCF Remove list    dist_name=${current_nrcell}    list_name=${current_list}
        ...    AND                    SCF Add list    dist_name=${current_nrcell}    list_name=${current_list}
        ...    AND    Dated Log       > SCF Remove and Add list ${current_nrcell}: ${current_list}
        ...    AND    SCF Add items to list    dist_name=${current_nrcell}    list_name=${current_list}    elements=${dico_cellBwp_0}
        ...    AND    Dated Log       > SCF Add items to list ${current_nrcell}: ${current_list}= ${dico_cellBwp_0}
        ...    AND    SCF Add items to list    dist_name=${current_nrcell}    list_name=${current_list}    elements=${dico_cellBwp_1}
        ...    AND    Dated Log       > SCF Add items to list ${current_nrcell}: ${current_list}= ${dico_cellBwp_1}
        ###VBO###
        # NRCELL.srsForBeamMgmt_bSRS / update
        ${current_param}=             Set Variable    srsForBeamMgmt_bSRS
        ${current_bSRS}=    Run Keyword If    ${k_srsForBeamMgmt_bSRS}    Set Variable    ${dico}[${current_param}]
        ${current_list}=              Set Variable    srsForBeamMgmt
        Run Keyword If    ${k_srsForBeamMgmt_bSRS} and "${current_bSRS}" != "${None}"    Run Keywords
        ...    SCF Set element in List    dist_name=${current_nrcell}    list_name=${current_list}    element_name=bSRS
        ...                           element_value=${current_bSRS}
        ...    AND    Dated Log       > SCF Set element in List ${current_nrcell}: ${current_list}.bSRS= ${current_bSRS}
        # NRCELL.srsForBeamMgmt_cSRS / update
        ${current_param}=             Set Variable    srsForBeamMgmt_cSRS
        ${current_cSRS}=    Run Keyword If    ${k_srsForBeamMgmt_cSRS}    Set Variable    ${dico}[${current_param}]
        ${current_list}=              Set Variable    srsForBeamMgmt
        Run Keyword If    ${k_srsForBeamMgmt_cSRS} and "${current_cSRS}" != "${None}"    Run Keywords
        ...    SCF Set element in List    dist_name=${current_nrcell}    list_name=${current_list}    element_name=cSRS
        ...                                                         element_value=${current_cSRS}
        ...    AND    Dated Log       > SCF Set element in List ${current_nrcell}: ${current_list}.cSRS= ${current_cSRS}
        ###VBO###
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure Bandwidth TDD 20MHz
    [Arguments]             ${list_nrcell_to_configure}
    ...                     ${current_bwpDN_initial}=5
    ...                     ${current_bwpDN_dedicated}=50

    Dated Log New Line                ----SCF Configure Bandwidth TDD 40MHz----
    Dated Log                         > for nrcell in position ${list_nrcell_to_configure}
    # Configure NRCELL
    &{dico_cell_chBw}=                Create Dictionary             chBw=20MHz
    ...                                                             dmrsTypeAPosition=pos3
    ...                                                             freqBandIndicatorNR=78
    ...                                                             gscnOrSsPbchArfcn=7878
    ...                                                             maxNumOfCaUsersNRCell=42
    ...                                                             msg1FrequencyStart=8
    ...                                                             nrarfcn=636666
    ...                                                             prachConfigurationIndex=98
    ...                                                             reqMinNumPuschPrb=41
    ...                                                             bwpDN_initial=${current_bwpDN_initial}
    ...                                                             bwpDN_dedicated=${current_bwpDN_dedicated}
    ...                                                             srsForBeamMgmt_cSRS=13
    ...                                                             type0CoresetConfigurationIndex=0
    ...                                                             type0SearchSpaceConfigurationIndex=4
    ...                                                             nrcell_tdd=${list_nrcell_to_configure}
    SCF Configure NRCELL BW           ${dico_cell_chBw}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Configure initial BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ...                                                             cRbSizeDl=coreset0
    ...                                                             cRbStartDl=coreset0
    ...                                                             cRbSizeUl=sameAsDl
    ...                                                             cRbStartUl=sameAsDl
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=1
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             duration=3
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_initial}    list_searchSpace=${list_searchSpaceCommon}
    # Configure dedicated BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=dedicated
    ...                                                             cRbSizeDl=allRb
    ...                                                             cRbStartDl=crb0
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_bwp_profile}
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=4
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_dedicated}    list_searchSpace=${list_searchSpaceCommon}
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=nonInterleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=none
    ...                                                             regBundleSize=n6
    ...                                                             size=48
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n4
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}    dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_pdsch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDSCH      profil_id=${current_bwpDN_dedicated}    dico_pdsch=${dico_pdsch}
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure Bandwidth TDD 40MHz
    [Arguments]             ${list_nrcell_to_configure}
    ...                     ${current_bwpDN_initial}=5
    ...                     ${current_bwpDN_dedicated}=51

    Dated Log New Line                ----SCF Configure Bandwidth TDD 40MHz----
    Dated Log                         > for nrcell in position ${list_nrcell_to_configure}
    # Configure NRCELL
    &{dico_cell_chBw}=                Create Dictionary             chBw=40MHz
    ...                                                             freqBandIndicatorNR=78
    #...                                                            gscnOrSsPbchArfcn=7880
    ...                                                             maxNumOfCaUsersNRCell=170
    ...                                                             msg1FrequencyStart=0
    #...                                                            nrarfcn=636666
    ...                                                             prachConfigurationIndex=98
    ...                                                             reqMinNumPuschPrb=84
    ...                                                             bwpDN_initial=${current_bwpDN_initial}
    ...                                                             bwpDN_dedicated=${current_bwpDN_dedicated}
    ...                                                             srsForBeamMgmt_cSRS=25
    ...                                                             type0CoresetConfigurationIndex=10
    ...                                                             type0SearchSpaceConfigurationIndex=4
    ...                                                             nrcell_tdd=${list_nrcell_to_configure}
    SCF Configure NRCELL BW           ${dico_cell_chBw}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Configure initial BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ...                                                             cRbSizeDl=coreset0
    ...                                                             cRbStartDl=coreset0
    ...                                                             cRbSizeUl=sameAsDl
    ...                                                             cRbStartUl=sameAsDl
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=1
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_initial}    list_searchSpace=${list_searchSpaceCommon}
    # Configure dedicated BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=dedicated
    ...                                                             cRbSizeDl=allRb
    ...                                                             cRbStartDl=crb0
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_bwp_profile}
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=4
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_dedicated}    list_searchSpace=${list_searchSpaceCommon}
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=nonInterleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=none
    ...                                                             regBundleSize=n6
    ...                                                             size=96
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n4
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}    dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_pdsch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDSCH      profil_id=${current_bwpDN_dedicated}    dico_pdsch=${dico_pdsch}
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure Bandwidth TDD 100MHz 5GC001070
    [Arguments]             ${list_nrcell_to_configure}
    ...                     ${current_bwpDN_initial}=6
    ...                     ${current_bwpDN_dedicated}=67

    Dated Log New Line                ----SCF Configure Bandwidth TDD 100MHz 5GC001070----
    Dated Log                         > for nrcell in position ${list_nrcell_to_configure}
    # Configure NRCELL
    &{dico_cell_chBw}=                Create Dictionary             chBw=100MHz
    ...                                                             dmrsTypeAPosition=pos2
    ...                                                             freqBandIndicatorNR=78
    ...                                                             gscnOrSsPbchArfcn=7880
    ...                                                             maxNumOfCaUsersNRCell=250
    ...                                                             msg1FrequencyStart=14
    ...                                                             nrarfcn=636666
    ...                                                             prachConfigurationIndex=93
    ...                                                             reqMinNumPuschPrb=213
    ...                                                             bwpDN_initial=${current_bwpDN_initial}
    ...                                                             bwpDN_dedicated=${current_bwpDN_dedicated}
    ...                                                             srsForBeamMgmt_cSRS=63
    ...                                                             type0CoresetConfigurationIndex=10
    ...                                                             type0SearchSpaceConfigurationIndex=5
    ...                                                             tddFrameStructure=true
    ...                                                             frameStructureType=semiStatic
    ...                                                             guardPeriodLength=2Symbols
    ...                                                             ulDlDataSlotRatio=3/7
    ...                                                             nrcell_tdd=${list_nrcell_to_configure}
    SCF Configure NRCELL BW           ${dico_cell_chBw}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Configure initial BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ...                                                             cRbSizeDl=coreset0
    ...                                                             cRbStartDl=coreset0
    ...                                                             cRbSizeUl=sameAsDl
    ...                                                             cRbStartUl=sameAsDl
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    # Create initial BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_pdcch}
    # Create initial BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=2
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=1
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=2
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=0
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Configure dedicated BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=dedicated
    ...                                                             cRbSizeDl=allRb
    ...                                                             cRbStartDl=crb0
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_bwp_profile}
    # Create dedicated BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_pdcch}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=2
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=4
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=2
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=0
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_DEDICATED
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=nonInterleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=none
    ...                                                             regBundleSize=n6
    ...                                                             size=120
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n5
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    # Create dedicated BWP_PROFILE_PDSCH
    &{dico_pdsch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDSCH      profil_id=${current_bwpDN_dedicated}    dico_pdsch=${dico_pdsch}


SCF Configure Bandwidth TDD 100MHz 5GC001116
    [Arguments]             ${list_nrcell_to_configure}
    ...                     ${current_bwpDN_initial}=7
    ...                     ${current_bwpDN_dedicated}=77

    Dated Log New Line                ----SCF Configure Bandwidth TDD 100MHz 5GC001116----
    Dated Log                         > for nrcell in position ${list_nrcell_to_configure}
    ${branch_version}=                Set Variable    ${TLConfig.topo.getBranchName()}
    Dated Log                         >> branch_version=${branch_version}
    #new PDL rule w/ SBTS26R1_ENB_9999_251020_000009: it is required that ${NRCELL-X.tddFrameStructure-1.ulDlDataSlotRatio} is not configured
    ${ulDlDataSlotRatio}=             Run Keyword If    "${branch_version}" != "SBTS25R3"    Set Variable    ${None}
    ...                               ELSE    Set Variable    3/7
    # Configure NRCELL
    &{dico_cell_chBw}=                Create Dictionary             chBw=100MHz
    ...                                                             dmrsTypeAPosition=pos2
    ...                                                             freqBandIndicatorNR=78
    ...                                                             gscnOrSsPbchArfcn=7880
    ...                                                             maxNumOfCaUsersNRCell=250
    ...                                                             msg1FrequencyStart=14
    ...                                                             nrarfcn=636666
    ...                                                             prachConfigurationIndex=97
    ...                                                             reqMinNumPuschPrb=213
    ...                                                             bwpDN_initial=${current_bwpDN_initial}
    ...                                                             bwpDN_dedicated=${current_bwpDN_dedicated}
    ...                                                             srsForBeamMgmt_bSRS=2
    ...                                                             srsForBeamMgmt_cSRS=63
    ...                                                             type0CoresetConfigurationIndex=10
    ...                                                             type0SearchSpaceConfigurationIndex=5
    ...                                                             tddFrameStructure=true
    ...                                                             frameStructureType=tdLte
    ...                                                             guardPeriodLength=4Symbols
    ...                                                             ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ...                                                             lteToNrFrameShift=0ms
    ...                                                             tdLteUlDlConfig=tdLteConfig2
    ...                                                             nrcell_tdd=${list_nrcell_to_configure}
    SCF Configure NRCELL BW           ${dico_cell_chBw}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Configure initial BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ...                                                             cRbSizeDl=coreset0
    ...                                                             cRbStartDl=coreset0
    ...                                                             cRbSizeUl=sameAsDl
    ...                                                             cRbStartUl=sameAsDl
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    # Create initial BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_pdcch}
    # Create initial BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=4
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl10
    ...                                                             searchSpaceId=1
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=6
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=0
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Configure dedicated BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=dedicated
    ...                                                             cRbSizeDl=allRb
    ...                                                             cRbStartDl=crb0
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_bwp_profile}
    # Create dedicated BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_pdcch}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=4
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl10
    ...                                                             searchSpaceId=4
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=6
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=0
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_DEDICATED
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=nonInterleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=none
    ...                                                             regBundleSize=n6
    ...                                                             size=120
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n5
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    # Create dedicated BWP_PROFILE_PDSCH
    &{dico_pdsch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDSCH      profil_id=${current_bwpDN_dedicated}    dico_pdsch=${dico_pdsch}


SCF Configure Bandwidth TDD 100MHz 5GC001208
    [Arguments]             ${list_nrcell_to_configure}
    ...                     ${current_bwpDN_initial}=5
    ...                     ${current_bwpDN_dedicated}=57

    Dated Log New Line                ----SCF Configure Bandwidth TDD 100MHz 5GC001208----
    Dated Log                         > for nrcell in position ${list_nrcell_to_configure}
    # Configure NRCELL
    &{dico_cell_chBw}=                Create Dictionary             chBw=100MHz
    ...                                                             dmrsTypeAPosition=pos2
    ...                                                             freqBandIndicatorNR=78
    ...                                                             gscnOrSsPbchArfcn=7880
    ...                                                             maxNumOfCaUsersNRCell=250
    ...                                                             msg1FrequencyStart=15
    ...                                                             nrarfcn=636666
    ...                                                             prachConfigurationIndex=98
    ...                                                             reqMinNumPuschPrb=213
    ...                                                             bwpDN_initial=${current_bwpDN_initial}
    ...                                                             bwpDN_dedicated=${current_bwpDN_dedicated}
    ...                                                             srsForBeamMgmt_cSRS=63
    ...                                                             type0CoresetConfigurationIndex=10
    ...                                                             type0SearchSpaceConfigurationIndex=5
    ...                                                             tddFrameStructure=true
    ...                                                             frameStructureType=semiStatic
    ...                                                             guardPeriodLength=2Symbols
    ...                                                             ulDlDataSlotRatio=1/4
    ...                                                             nrcell_tdd=${list_nrcell_to_configure}
    SCF Configure NRCELL BW           ${dico_cell_chBw}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Configure initial BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ...                                                             cRbSizeDl=coreset0
    ...                                                             cRbStartDl=coreset0
    ...                                                             cRbSizeUl=sameAsDl
    ...                                                             cRbStartUl=sameAsDl
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    # Create initial BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_pdcch}
    # Create initial BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=1
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl20
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=5
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Configure dedicated BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=dedicated
    ...                                                             cRbSizeDl=allRb
    ...                                                             cRbStartDl=crb0
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_bwp_profile}
    # Create dedicated BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_pdcch}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl5
    ...                                                             searchSpaceId=4
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl20
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=5
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_DEDICATED
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=nonInterleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=none
    ...                                                             regBundleSize=n6
    ...                                                             size=120
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n5
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    # Create dedicated BWP_PROFILE_PDSCH
    &{dico_pdsch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDSCH      profil_id=${current_bwpDN_dedicated}    dico_pdsch=${dico_pdsch}


SCF Configure Bandwidth TDD 100MHz 5GC008406
    [Arguments]             ${list_nrcell_to_configure}
    ...                     ${current_bwpDN_initial}=7
    ...                     ${current_bwpDN_dedicated}=77

    Dated Log New Line                ----SCF Configure Bandwidth TDD 100MHz 5GC008406----
    Dated Log                         > for nrcell in position ${list_nrcell_to_configure}
    # Configure NRCELL
    &{dico_cell_chBw}=                Create Dictionary             chBw=100MHz
    ...                                                             dmrsTypeAPosition=pos2
    ...                                                             freqBandIndicatorNR=78
    ...                                                             gscnOrSsPbchArfcn=7880
    ...                                                             maxNumOfCaUsersNRCell=250
    ...                                                             msg1FrequencyStart=14
    ...                                                             nrarfcn=636666
    ...                                                             prachConfigurationIndex=148
    ...                                                             reqMinNumPuschPrb=239
    ...                                                             bwpDN_initial=${current_bwpDN_initial}
    ...                                                             bwpDN_dedicated=${current_bwpDN_dedicated}
    ...                                                             type0CoresetConfigurationIndex=10
    ...                                                             type0SearchSpaceConfigurationIndex=5
    ...                                                             tddFrameStructure=true
    ...                                                             frameStructureType=semiStatic
    ...                                                             guardPeriodLength=4Symbols
    ...                                                             ulDlDataSlotRatio=4/6
    ...                                                             nrcell_tdd=${list_nrcell_to_configure}
    SCF Configure NRCELL BW           ${dico_cell_chBw}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Configure initial BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ...                                                             cRbSizeDl=coreset0
    ...                                                             cRbStartDl=coreset0
    ...                                                             cRbSizeUl=sameAsDl
    ...                                                             cRbStartUl=sameAsDl
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    # Create initial BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_pdcch}
    # Create initial BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl10
    ...                                                             searchSpaceId=1
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=6
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl10
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=0
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Configure dedicated BWP_PROFILE
    &{dico_bwp_profile}=              Create Dictionary             bwpType=dedicated
    ...                                                             cRbSizeDl=allRb
    ...                                                             cRbStartDl=crb0
    SCF Create BWP_PROFILE            profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_bwp_profile}
    # Create dedicated BWP_PROFILE_PDCCH
    &{dico_pdcch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDCCH      profil_id=${current_bwpDN_dedicated}    dico_pdcch=${dico_pdcch}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl10
    ...                                                             searchSpaceId=4
    ...                                                             searchSpaceType=Type0A
    ...                                                             slotOffset=6
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    ...                                                             slotOffset=0
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             duration=3
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             periodicity=sl10
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    ...                                                             slotOffset=0
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON                      profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Create dedicated BWP_PROFILE_PDCCH CONFIG_DEDICATED
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=nonInterleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=none
    ...                                                             regBundleSize=n6
    ...                                                             size=120
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n5
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    # Create dedicated BWP_PROFILE_PDSCH
    &{dico_pdsch}=                    Create Dictionary             lambda=null
    SCF Create BWP_PROFILE_PDSCH      profil_id=${current_bwpDN_dedicated}    dico_pdsch=${dico_pdsch}
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure NRREL
    [Arguments]             ${dn_nrcell}
    ...                     ${rel_id}
    ...                     ${rel_mcc}
    ...                     ${rel_mnc}
    ...                     ${rel_lcr_id}

    Dated Log New Line                ----SCF Configure NRREL-${rel_id}----
    Dated Log                         > for ${dn_nrcell}
    # NRREL name
    ${dn_nrrel}=                      Set Variable    ${dn_nrcell}/NRREL-${rel_id}
    # NRREL class
    ${cn_nrrel}=                      Set Variable    com.nokia.srbts.nrbts:NRREL
    # NRREL.object / add
    ${flag_object}=                   SCF Is Object Exist    dist_name=${dn_nrrel}
    Run Keyword If    ${flag_object}    Run Keywords
    ...                               SCF Remove object    dist_name=${dn_nrrel}
    ...    AND    Dated Log           > SCF Remove object ${dn_nrrel}
    SCF Add object                    dist_name=${dn_nrrel}    class_name=${cn_nrrel}
    Dated Log                         > SCF Add object ${dn_nrrel}: class=${cn_nrrel}
    # NRREL.actA4ToA1BasedSCellFallbackNsa / update
    ${current_param}=                 Set Variable    actA4ToA1BasedSCellFallbackNsa
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=false
    # NRREL.cellIndividualSsbRsrpOffset / update
    ${current_param}=                 Set Variable    cellIndividualSsbRsrpOffset
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=0dB
    # NRREL.cellIndividualSsbRsrqOffset / update
    ${current_param}=                 Set Variable    cellIndividualSsbRsrqOffset
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=0dB
    # NRREL.gNbId / update
    ${current_param}=                 Set Variable    gNbId
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=${TMRBTS_ID[0]}
    # NRREL.gNbIdLength / update
    ${current_param}=                 Set Variable    gNbIdLength
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=22
    # NRELL.gnbPlmn / add list
    ${current_list}=                  Set Variable    gnbPlmn
    SCF Add list                      dist_name=${dn_nrrel}    list_name=${current_list}
    Dated Log                         > SCF Add list ${dn_nrrel}: ${current_list}
    ${len_mnc}=                       Get Length    ${rel_mnc}
    &{dico_gnb_plmn}=                 Create Dictionary    mcc=${rel_mcc}    mnc=${rel_mnc}    mncLength=${len_mnc}
    SCF Add items to list             dist_name=${dn_nrrel}    list_name=${current_list}    elements=${dico_gnb_plmn}
    Dated Log                         > SCF Add items to list ${dn_nrrel}: ${current_list}= ${dico_gnb_plmn}
    # NRREL.handoverAllowedSA / update
    ${current_param}=                 Set Variable    handoverAllowedSA
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=allowed
    # NRREL.handoverAllowedSARedCap / update
    ${current_param}=                 Set Variable    handoverAllowedSARedCap
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=forbidden
    # NRREL.isRplCellForPSCell / update
    ${current_param}=                 Set Variable    isRplCellForPSCell
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=false
    # NRREL.lcrId / update
    ${current_param}=                 Set Variable    lcrId
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=${rel_lcr_id}
    # NRREL.nrDcAllowed / update
    ${current_param}=                 Set Variable    nrDcAllowed
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=false
    # NRREL.removeNotAllowed / update
    ${current_param}=                 Set Variable    removeNotAllowed
    Configure SCF Set Element         dist_name=${dn_nrrel}    elem_name=${current_param}    elem_val=false


SCF Configure Handover Relations
    [Arguments]             ${pos_nrcell}
    ...                     ${dn_nrcell}
    ...                     ${id_nrcell}
    ...                     ${mcc_nrcell}
    ...                     ${mnc_nrcell}
    ...                     ${list_nrcell}

    Dated Log New Line                ----SCF Configure Handover Relations----
    Dated Log                         > for ${dn_nrcell}
    ${current_rel}=                   Set Variable    1
    FOR    ${position}    IN    @{pos_nrcell}
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell_id}=         Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
        ${current_dn_nrcell}=         Set Variable    ${dn_nrbts}/NRCELL-${current_nrcell_id}
        # NRCELL.lcriId / get
        ${current_param}=             Set Variable    lcrId
        ${nb_match}    ${current_lcr_id}     Get Values From Object    dist_name=${current_dn_nrcell}    p_name=${current_param}
        Should Be True    ${nb_match} > 0
        Dated Log                     >> match for ${current_dn_nrcell}: ${current_param}= ${current_lcr_id}
        Run Keyword If    ${current_nrcell_id} != ${id_nrcell}    SCF Configure NRREL    dn_nrcell=${dn_nrcell}
        ...                                                         rel_id=${current_rel}
        ...                                                         rel_mcc=${mcc_nrcell}
        ...                                                         rel_mnc=${mnc_nrcell}
        ...                                                         rel_lcr_id=${current_lcr_id}[0]
        ${current_rel}=    Run Keyword If    ${current_nrcell_id} == ${id_nrcell}    Set Variable    ${current_rel}
        ...                            ELSE    Evaluate    ${current_rel}+1
    END


SCF Configure Intra Frequency Handover SA
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}

    Dated Log New Line                ----SCF Configure Intra Frequency Handover SA----
    Dated Log                         > from ${list_nrcell}
    ${k_actIntraFreqHoSA}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=actIntraFreqHoSA
    ${k_timerXnDataFwdGuard}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=timerXnDataFwdGuard
    ${k_a3MeasEnabled}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=a3MeasEnabled
    ${k_miNrRelReportCu}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrRelReportCu
    ${k_absThreshSsbRsrpCons}=        Is Parameter A Dictionary Key    dict=${dico}    parameter=absThreshSsbRsrpConsolidation
    ${k_sMeasConfigSsbRsrp}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=sMeasConfigSsbRsrp
    ${k_a3HysteresisSsbRsrp}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=a3HysteresisSsbRsrp
    ${k_a3OffsetSsbRsrp}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=a3OffsetSsbRsrp
    ${k_a3TimeToTriggerSsbRsrp}=      Is Parameter A Dictionary Key    dict=${dico}    parameter=a3TimeToTriggerSsbRsrp
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    # NRMOPR_SA name
    ${dn_nrmopr_sa}=                  Set Variable    ${dn_nrbts}/NRMOPR_SA-1
    Dated Log                         > dn_nrmopr_sa is ${dn_nrmopr_sa}
    # NRPMRNL name
    ${dn_nrpmrnl}=                    Set Variable    ${dn_nrbts}/NRPMRNL-1
    Dated Log                         > dn_nrpmrnl is ${dn_nrpmrnl}
    # NRCELL.actIntraFreqHoSA / update
    ${current_param}=                 Set Variable    actIntraFreqHoSA
    Run Keyword If    ${k_actIntraFreqHoSA}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRCELL.timerXnDataFwdGuard / update
    ${current_param}=                 Set Variable    timerXnDataFwdGuard
    Run Keyword If    ${k_timerXnDataFwdGuard}
    ...    Configure SCF Set Element    dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRCELL.a3MeasEnabled / update
    ${current_param}=                 Set Variable    a3MeasEnabled
    Run Keyword If    ${k_a3MeasEnabled}
    ...    Configure SCF Set Element    dist_name=${dn_nrmopr_sa}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    # NRCELL.miNrRelReportCu / update
    ${current_param}=                 Set Variable    miNrRelReportCu
    Run Keyword If    ${k_miNrRelReportCu}
    ...    Configure SCF Set Element    dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell}=            Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        # NRCELL.a3MeasEnabled / update
        ${current_param}=             Set Variable    a3MeasEnabled
        Run Keyword If    ${k_a3MeasEnabled}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.absThreshSsbRsrpConsolidation / update
        ${current_param}=             Set Variable    absThreshSsbRsrpConsolidation
        Run Keyword If    ${k_absThreshSsbRsrpCons}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        # NRCELL.sMeasConfigSsbRsrp / update
        ${current_param}=             Set Variable    sMeasConfigSsbRsrp
        Run Keyword If    ${k_sMeasConfigSsbRsrp}
        ...    Configure SCF Set Element    dist_name=${current_nrcell}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
        #
        # NRCELL.a3MeasSsbRsrp / add list
        ${current_list}=              Set Variable    a3MeasSsbRsrp
        &{dico_a3MeasSsbRsrp}=    Run Keyword If    ${k_a3HysteresisSsbRsrp} and ${k_a3OffsetSsbRsrp} and ${k_a3TimeToTriggerSsbRsrp}
        ...                           Create Dictionary    a3HysteresisSsbRsrp=${dico}[a3HysteresisSsbRsrp]
        ...                                                         a3OffsetSsbRsrp=${dico}[a3OffsetSsbRsrp]
        ...                                                         a3TimeToTriggerSsbRsrp=${dico}[a3TimeToTriggerSsbRsrp]
        ...    ELSE                  Create Dictionary    a3HysteresisSsbRsrp=2    a3OffsetSsbRsrp=4    a3TimeToTriggerSsbRsrp=ms40
        SCF Add list                  dist_name=${current_nrcell}    list_name=${current_list}
        Dated Log                     > SCF Add list ${current_nrcell}: ${current_list}
        SCF Add items to list         dist_name=${current_nrcell}    list_name=${current_list}    elements=${dico_a3MeasSsbRsrp}
        Dated Log                     > SCF Add items to list ${current_nrcell}: ${current_list}= ${dico_a3MeasSsbRsrp}
        #
        # NRBTS.mcc / get
        ${current_param}=             Set Variable    mcc
        ${nb_match}    ${val_mcc}     Get Values From Object    dist_name=${dn_nrbts}    p_name=${current_param}
        Should Be True    ${nb_match} > 0
        Dated Log                     >> match for ${dn_nrbts}: ${current_param}= ${val_mcc}
        # NRBTS.mnc / get
        ${current_param}=             Set Variable    mnc
        ${nb_match}    ${val_mnc}     Get Values From Object    dist_name=${dn_nrbts}    p_name=${current_param}
        Should Be True    ${nb_match} > 0
        Dated Log                     >> match for ${dn_nrbts}: ${current_param}= ${val_mnc}
        # Configure NRREL
        SCF Configure Handover Relations    pos_nrcell=${dico}[${nrcell_key}]    dn_nrcell=${current_nrcell}
        ...                                                         id_nrcell=${list_nrcell[${internal_pos}].nrCellId}
        ...                                                         mcc_nrcell=${val_mcc}[0]
        ...                                                         mnc_nrcell=${val_mnc}[0]
        ...                                                         list_nrcell=${list_nrcell}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
