*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE] CB014613
...               Scope : Commissioning Keywords SR-CR
#
...               Test Case Scenario author   : vincent.boulet@nokia.com
...               Creation Date               : 2025-11-19
...               Modified Date               : 2026-02-25
#
#                 Version    Date       Author                          Notes
#                 0.1        FB2523     vincent.boulet@nokia.com        Robot creation and test cases for preparation
#                 0.2        FB2525     vincent.boulet@nokia.com        Continued preparation focused on CB014613
#                 0.3        FB2525     vincent.boulet@nokia.com        Continued preparation focused on CB014613 SR and CR
#                 0.4        FB2525     vincent.boulet@nokia.com        Check tddFrameStructure Parameters
#                 0.5        FB2526     vincent.boulet@nokia.com        Check tddFrameStructure Parameters update
#                 0.6        FB2601     vincent.boulet@nokia.com        Remove Restart.Wait Vcu And Vdu Available after commissioning
#                 0.7        FB2601     vincent.boulet@nokia.com        Online Modification NRRIM PROFILE Parameters SR-CR
#                 1.0        FB2605     vincent.boulet@nokia.com        Robot version for first execution
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                               Collections

# Resources

# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Keywords ***
# Commissioning #
Set Suite Dist Name Variables For SR-CR
    #
    Dated Log New Line                ${cc_blue}----Set Suite Dist Name Variables For SR-CR----${cc_normal}
    # MRBTS
    ${dn_mrbts}=                      Run Keyword If    ${isAic}
    ...                               Set Variable    MRBTS-${TMRBTS_ID_DU[0]}
    ...           ELSE                Set Variable    MRBTS-${TMRBTS_ID[0]}
    Set Suite Variable                ${dn_mrbts}
    Dated Log                         > dn_mrbts is ${dn_mrbts}
    #
    ${dn_mrbts_vcu}=                  Run Keyword If    ${isAic}
    ...                               Set Variable    MRBTS-${TMRBTS_ID_CU[0]}
    ...           ELSE                Set Variable    ${None}
    Set Suite Variable                ${dn_mrbts_vcu}
    Dated Log                         > dn_mrbts_vcu is ${dn_mrbts_vcu}
    # NRBTS
    ${dn_nrbts}=                      Run Keyword If    ${isAic}
    ...                               Set Variable    ${dn_mrbts}/NRBTS-${TNRBTS_ID_DU[0]}
    ...           ELSE                Set Variable    ${dn_mrbts}/NRBTS-${TNRBTS_ID[0]}
    Set Suite Variable                ${dn_nrbts}
    Dated Log                         > dn_nrbts is ${dn_nrbts}
    ${dn_nrbts_vcu}=                  Run Keyword If    ${isAic}
    ...                               Set Variable    ${dn_mrbts}/NRBTS-${TNRBTS_ID_CU[0]}
    ...           ELSE                Set Variable    ${None}
    Set Suite Variable                ${dn_nrbts_vcu}
    Dated Log                         > dn_nrbts_vcu is ${dn_nrbts_vcu}
    # BWP_PROFILE base name
    ${dn_bwp_profile_base}=           Set Variable    ${dn_nrbts}/BWP_PROFILE-
    Set Suite Variable                ${dn_bwp_profile_base}
    Dated Log                         > dn_bwp_profile_base is ${dn_bwp_profile_base}
    ${dn_bwp_profile_base_vcu}=       Run Keyword If    ${isAic}
    ...                               Set Variable    ${dn_nrbts_vcu}/BWP_PROFILE-
    ...           ELSE                Set Variable    ${None}
    Set Suite Variable                ${dn_bwp_profile_base_vcu}
    Dated Log                         > dn_bwp_profile_base_vcu is ${dn_bwp_profile_base_vcu}
    # NRPMRNL base name
    ${dn_nrpmrnl_base}=               Set Variable    ${dn_nrbts}/NRPMRNL-
    Set Suite Variable                ${dn_nrpmrnl_base}
    Dated Log                         > dn_nrpmrnl_base is ${dn_nrpmrnl_base}
    ${dn_nrpmrnl_base_vcu}=           Run Keyword If    ${isAic}
    ...                               Set Variable    ${dn_nrbts_vcu}/NRPMRNL-
    ...           ELSE                Set Variable    ${None}
    Set Suite Variable                ${dn_nrpmrnl_base_vcu}
    Dated Log                         > dn_nrpmrnl_base_vcu is ${dn_nrpmrnl_base_vcu}
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
    # PMCADM
    IF    ${isAic}
        ${dn_pmcadm}=                 Set Variable    MRBTS-${TMRBTS_ID_DU[0]}/MNL-1/MNLENT-1/PMCADM-1
        ${dn_pmcadm_vcu}=             Set Variable    MRBTS-${TMRBTS_ID_CU[0]}/MNL-1/MNLENT-1/PMCADM-1
    ELSE
        ${dn_pmcadm}=                 Set Variable    MRBTS-${TMRBTS_ID[0]}/MNL-1/MNLENT-1/PMCADM-1
        ${dn_pmcadm_vcu}=             Set Variable    ${None}
    END
    Set Suite Variable                ${dn_pmcadm}
    Dated Log                         > dn_pmcadm is ${dn_pmcadm}
    Set Suite Variable                ${dn_pmcadm_vcu}
    Dated Log                         > dn_pmcadm_vcu is ${dn_pmcadm_vcu}


Get Values From Object
    [Arguments]             ${dist_name}
    ...                     ${p_name}
    ...                     ${current_scf}=${None}
    ...                     ${scope}=Classical
    ...                     ${aicListEntity}=VDUVCU
    #
    Run Keyword If                    "${current_scf}" != "${None}"    SCF StartSession    scf_file=${current_scf}
    ${result}=                        Scf.SCF Get Single Value    dist_name=${dist_name}    p_name=${p_name}
    ...                               scope=${scope}    aicListEntity=${aicListEntity}
    Run Keyword If                    "${current_scf}" != "${None}"    SCF StopSession    scf_file=${current_scf}
    ${nb_match}=                      Get Length    ${result}
    [Return]                          ${nb_match}    ${result}


Get All Values From Object By Pattern
    [Arguments]             ${dist_name}=${None}
    ...                     ${p_name}=${None}
    ...                     ${list_name}=${None}
    ...                     ${current_scf}=${None}
    ...                     ${scope}=Classical
    ...                     ${aicListEntity}=VDUVCU
    #
    Run Keyword If                    "${current_scf}" != "${None}"    SCF StartSession    scf_file=${current_scf}
    ${result}=    multiscf.get_all_values_from_scf_by_pattern    dist_name=${dist_name}    p_name=${p_name}    list_name=${list_name}
    ...                               scope=${scope}    aicListEntity=${aicListEntity}
    Run Keyword If                    "${current_scf}" != "${None}"    SCF StopSession    scf_file=${current_scf}
    ${nb_match}=                      Get Length    ${result}
    [Return]                          ${nb_match}    ${result}


Check tddFrameStructure Parameters CR
    [Arguments]             ${dico}
    ...                     ${list_elem}
    #
    Dated Log                         ${cc_blue}----Check tddFrameStructure Parameters----${cc_normal}
    ${k_frameStructureType}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=frameStructureType
    ${k_guardPeriodLength}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=guardPeriodLength
    ${k_lteToNrFrameShift}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=lteToNrFrameShift
    ${k_ulDlDataSlotRatio}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=ulDlDataSlotRatio
    #
    FOR    ${current_elem}    IN      @{list_elem}
#DEBUG_LOG#
#       Dated Log                     >> tdd_frame_structure= ${current_elem}[0]
        FOR    ${tdd_frame_elem}    IN      @{current_elem}[0]
#DEBUG_LOG#
#           Dated Log                 >> tdd_frame_elem=${tdd_frame_elem}
#           Dated Log                 >> tdd_frame_elem.name=${tdd_frame_elem['name']}
            ${value_dict}=            Evaluate    json.loads('''${tdd_frame_elem['value']}''')    json
#DEBUG_LOG#
#           Dated Log                 >> tdd_frame_elem.value=${value_dict}
            # NRCELL.frameStructureType / check
            IF    ${k_frameStructureType} and "${tdd_frame_elem['name']}" == "frameStructureType"
                ${current_param}=     Set Variable    frameStructureType
                ${current_value}=     Set Variable    ${value_dict['currentValue']}
                Dated Log             > current_value for ${current_param}=${current_value}
                Should Be Equal       "${current_value}"    "${dico}[${current_param}]"
                Dated Log             > check of ${current_param} is successfully completed
            END
            # NRCELL.guardPeriodLength / check
            IF    ${k_guardPeriodLength} and "${tdd_frame_elem['name']}" == "guardPeriodLength"
                ${current_param}=     Set Variable    guardPeriodLength
                ${current_value}=     Set Variable    ${value_dict['currentValue']}
                Dated Log             > current_value for ${current_param}=${current_value}
                Should Be Equal       "${current_value}"    "${dico}[${current_param}]"
                Dated Log             > check of ${current_param} is successfully completed
            END
            # NRCELL.lteToNrFrameShift / check
            IF    ${k_lteToNrFrameShift} and "${tdd_frame_elem['name']}" == "lteToNrFrameShift"
                ${current_param}=     Set Variable    lteToNrFrameShift
                ${current_value}=     Set Variable    ${value_dict['currentValue']}
                Dated Log             > current_value for ${current_param}=${current_value}
                Should Be Equal       "${current_value}"    "${dico}[${current_param}]"
                Dated Log             > check of ${current_param} is successfully completed
            END
            # NRCELL.ulDlDataSlotRatio / check
            IF    ${k_ulDlDataSlotRatio} and "${tdd_frame_elem['name']}" == "ulDlDataSlotRatio"
                ${current_param}=     Set Variable    ulDlDataSlotRatio
                ${current_value}=     Set Variable    ${value_dict['currentValue']}
                Dated Log             > current_value for ${current_param}=${current_value}
                Should Be Equal       "${current_value}"    "${dico}[${current_param}]"
                Dated Log             > check of ${current_param} is successfully completed
            END
        END
        #
    END


Check tddFrameStructure Parameters
    [Arguments]             ${dico}
    ...                     ${list_elem}
    #
    Dated Log                         ${cc_blue}----Check tddFrameStructure Parameters----${cc_normal}
    ${k_frameStructureType}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=frameStructureType
    ${k_guardPeriodLength}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=guardPeriodLength
    ${k_lteToNrFrameShift}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=lteToNrFrameShift
    ${k_ulDlDataSlotRatio}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=ulDlDataSlotRatio
    #
    FOR    ${current_elem}    IN      @{list_elem}
#DEBUG_LOG#
#       Dated Log                     >> current_elem= ${current_elem}
        ${first_dico}=                Set Variable    ${current_elem}[0]
        Dated Log                     > ${first_dico}
        ${parameters}=                Set Variable    ${first_dico}[parameters]
        ${tdd_frame_structure}=       Set Variable    ${parameters}[tddFrameStructure]
        ${dico_tdd_frame_structure}=  Set Variable    ${tdd_frame_structure}[0]
#DEBUG_LOG#
#       Dated Log                     >> dico_tdd_frame_structure=${dico_tdd_frame_structure}
        # NRCELL.frameStructureType / check
        IF    ${k_frameStructureType}
            ${current_param}=         Set Variable    frameStructureType
            Should Be Equal           "${dico_tdd_frame_structure}[${current_param}]"    "${dico}[${current_param}]"
            Dated Log                 > check of ${current_param} is successfully completed
        END
        # NRCELL.guardPeriodLength / check
        IF    ${k_guardPeriodLength}
            ${current_param}=         Set Variable    guardPeriodLength
            Should Be Equal           "${dico_tdd_frame_structure}[${current_param}]"    "${dico}[${current_param}]"
            Dated Log                 > check of ${current_param} is successfully completed
        END
        # NRCELL.lteToNrFrameShift / check
        IF    ${k_lteToNrFrameShift}
            ${current_param}=         Set Variable    lteToNrFrameShift
            Should Be Equal           "${dico_tdd_frame_structure}[${current_param}]"    "${dico}[${current_param}]"
            Dated Log                 > check of ${current_param} is successfully completed
        END
        # NRCELL.ulDlDataSlotRatio / check
        IF    ${k_ulDlDataSlotRatio}
            ${current_param}=         Set Variable    ulDlDataSlotRatio
            Should Be Equal           "${dico_tdd_frame_structure}[${current_param}]"    "${dico}[${current_param}]"
            Dated Log                 > check of ${current_param} is successfully completed
        END
    END


Get Dedicated Dist Name BWP_PROFILE For Cell
    [Arguments]             ${dn_nrcell}
    ...                     ${bwpdn_dedicated}
    ...                     ${bwp_param}=bwpDN
    ...                     ${bwp_type}=dedicated
    ...                     ${scope}=Classical
    ...                     ${aicListEntity}=VDUVCU
    #
    ${nb_match}    ${result_bwpdn}    Get All Values From Object By Pattern    dist_name=${dn_nrcell}    p_name=${bwp_param}
        ...                           scope=${scope}    aicListEntity=${aicListEntity}
#DEBUG_LOG#
#   Run Keyword If                    ${nb_match} > 0
#   ...    Dated Log                  >> match for ${dn_nrcell}: ${bwp_param}= ${result_bwpdn}
    FOR    ${current_dn}    IN        @{result_bwpdn}
#DEBUG_LOG#
#       Dated Log                     >> current_dn for BWP_PROFILE= ${current_dn}
        #
        ${nb_values}=                 Count Values In List    ${bwpdn_dedicated}    ${current_dn}
        ${current_param}=             Set Variable    bwpType
        ${nb_match}    ${result}      Get Values From Object    dist_name=${current_dn}    p_name=${current_param}
        ...                           scope=${scope}    aicListEntity=${aicListEntity}
#DEBUG_LOG#
#       Dated Log                     >> Get Values From Object ${current_dn}: ${current_param}= ${result}
        IF    ${nb_values} == 0 and ${nb_match} > 0 and "${result}[0]" == "${bwp_type}"
            Dated Log                 >> match for ${current_dn}: ${current_param}= ${result} nb_match= ${nb_match}
                                      Append To List    ${bwpdn_dedicated}    ${current_dn}
        END
    END
    ${nb_match}=                      Get Length    ${bwpdn_dedicated}
    [Return]                          ${nb_match}


SCF Validate NIDD And PDL Rules
    [Arguments]             ${scf_file}
    #
    Dated Log New Line                ${cc_blue}----SCF Validate NIDD And PDL Rules----${cc_normal}
    ${dict_req}=                      OAM Validate SCF Online    scf_file=${scf_file}    skip_relation_errors=${True}
#DEBUG_LOG#
#   Dated Log                         >> dict_req= ${dict_req}
#   Dated Log                         >> request_msg= ${dict_req['requestMessage']}
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
    Run Keyword If                    "${nidd_res_status}" != "OK" and "${nidd_skipped_elem}" != "${None}"
    ...           Dated Log           > niddValidationResult - skippedElements not none
    ...    AND    Dated Log           > ${nidd_skipped_elem}
    Run Keyword If                    "${nidd_res_status}" != "OK" and "${nidd_missing_obj_err}" != "${None}"
    ...           Dated Log           > niddValidationResult - missingObjectsErrors not none
    ...    AND    Dated Log           > ${nidd_missing_obj_err}
    Run Keyword If                    "${nidd_res_status}" != "OK" and "${nidd_max_err}" != "${None}"
    ...           Dated Log           > niddValidationResult - maxOccurrencesErrors not none
    ...    AND    Dated Log           > ${nidd_max_err}
    Run Keyword If                    "${nidd_res_status}" != "OK" and "${nidd_def_err}" != "${None}"
    ...           Dated Log           > niddValidationResult - definitionErrors not none
    ...    AND    Dated Log           > ${nidd_def_err}
    # pdlValidationResult
    ${pdl_res}=                       Set Variable    ${dict_req['requestMessage']['pdlValidationResult']}
    ${pdl_res_status}=                Set Variable    ${pdl_res['status']}
    ${pdl_rel_err}=                   Set Variable    ${pdl_res['logs']['relationErrors']}
    ${pdl_rel_err_len}=               Get Length    ${pdl_rel_err}
    ${pdl_hw_err}=                    Set Variable    ${pdl_res['logs']['hardwareErrors']}
    ${pdl_hw_err_len}=                Get Length    ${pdl_hw_err}
    IF    "${pdl_res_status}" != "OK" and ${pdl_rel_err_len} > 0
        Dated Log                     > pdlValidationResult:relationErrors is not 0, len= ${pdl_rel_err_len}
        Dated Log                     > ${pdl_rel_err}
    END
    IF    "${pdl_res_status}" != "OK" and ${pdl_hw_err_len} > 0
        Dated Log                     > pdlValidationResult:hardwareErrors is not 0, len= ${pdl_hw_err_len}
        Dated Log                     > ${pdl_hw_err}
    END
    #
    ${status}=                        Run Keyword If    "${pdl_res_status}" != "OK"    Set Variable    ${False}
    ...           ELSE                Set Variable    ${True}
    [Return]                          ${status}    ${pdl_rel_err}
# --------------------------------------------------------------------------------------------------------------------------------------------------
Configure SCF Set Element
    [Arguments]             ${dist_name}
    ...                     ${elem_name}
    ...                     ${elem_val}
    ...                     ${scope}=Classical
    ...                     ${bestEffort}=${True}
    ...                     ${aicListEntity}=VDUVCU
    #
    IF    "${elem_val}" != "${None}"
        SCF Set element               dist_name=${dist_name}    element_name=${elem_name}    element_value=${elem_val}    scope=${scope}
        ...                           bestEffort=${bestEffort}    aicListEntity=${aicListEntity}
        Dated Log                     > SCF Set element ${dist_name}: ${elem_name}= ${elem_val}
    END


Configure SCF Set Element In List
    [Arguments]             ${dist_name}
    ...                     ${list_name}
    ...                     ${elem_name}
    ...                     ${elem_val}
    ...                     ${scope}=Classical
    ...                     ${aicListEntity}=VDUVCU
    #
    IF    "${elem_val}" != "${None}"
        SCF Set element in List       dist_name=${dist_name}    element_name=${elem_name}    element_value=${elem_val}    list_name=${list_name}
        ...                           scope=${scope}    aicListEntity=${aicListEntity}
            Dated Log                 > SCF Set element in List ${dist_name}: ${list_name}.${elem_name}= ${elem_val}
    END


Start Session Full Commissioning SR-CR
    [Arguments]             ${test_name}=${None}
    #
    Dated Log New Line                ${cc_blue}----Start Session Full Commissioning SR-CR----${cc_normal}
    ${current_scf}=                   String.Replace string    ${scf_suite_setup_backup}    _BACKUP.xml    ${EMPTY}
    ${updated_scf}=                   Catenate    SEPARATOR=${EMPTY}    ${current_scf}_NEW.xml
    Dated Log                         > new scf= ${updated_scf}
    ${std_output}=                    Run    command=cp ${scf_suite_setup_backup} ${updated_scf}
    ${current_scf_vcu}=               Run Keyword If    ${isAic}    String.Replace string    ${scf_vcu_suite_setup_backup}    _BACKUP.xml   ${EMPTY}
    ${updated_scf_vcu}=               Run Keyword If    ${isAic}    Catenate    SEPARATOR=${EMPTY}    ${current_scf_vcu}_NEW.xml
    ...           ELSE                Set Variable    ${None}
    Dated Log                         > new scf vcu= ${updated_scf_vcu}
    ${std_output}=                    Run    command=cp ${scf_vcu_suite_setup_backup} ${updated_scf_vcu}
    Run Keyword If    ${isAic}        SCF StartSession    scf_file=${updated_scf}    second_scf_file=${updated_scf_vcu}
    ...           ELSE                SCF StartSession    scf_file=${updated_scf}
    #
    ${mode}=                          Set Variable    Classical
    IF    ${isAic}
        ${mode}=                      Set Variable    Both
    END
    # MRBTS.btsName / update / ${test_name}
    Configure SCF Set Element         dist_name=${dn_mrbts}    elem_name=btsName
    ...                               elem_val=${test_name}    scope=${mode}    bestEffort=${False}    aicListEntity=VDUVCU
    [Return]                          ${updated_scf}    ${updated_scf_vcu}


Stop Session Full Commissioning SR-CR
    [Arguments]             ${updated_scf}
    ...                     ${updated_scf_vcu}=${None}
    ...                     ${skip_errors}=${False}
    ...                     ${F1_wait_time}=15min
    #
    Dated Log New Line                ${cc_blue}----Stop Session Full Commissioning----${cc_normal}
#DEBUG_LOG#
#   Dated Log                         > ${updated_scf}
    Run Keyword If    ${isAic}        SCF StopSession    scf_file=${updated_scf}    second_scf_file=${updated_scf_vcu}
    ...           ELSE                SCF StopSession    scf_file=${updated_scf}
    ${result_scf_val}    ${result_pdl}    Run Keyword If    not ${isAic}    SCF Validate NIDD And PDL Rules    scf_file=${updated_scf}
    IF    ${isAic}
        ${result_scf_val}=            Set Variable    ${True}
        ${result_pdl}=                Set Variable    ${None}
    END
    IF    ${result_scf_val} == ${True} and ${isAic}
        OAM Perform Full Commissioning    scf_file=${updated_scf_vcu}    oam=${GNB_CU.oam}    skip_relation_errors=${skip_errors}
                                      OAM Perform Full Commissioning    scf_file=${updated_scf}    skip_relation_errors=${skip_errors}
                                      Restart.Wait Vcu And Vdu Available
                                      Restart.Restart Airphone
                                      Traced Sleep    duration=120s    msg=restart of Aiphone
                                      Restart.Wait Airphone Available
                                      Restart.F1 Wait Link AIC    timeout=${F1_wait_time}
                                      Traced Sleep    duration=300s    msg=activation of radio modules
                                      Setup.Get TL Info Struct
                                      Run    command=rm -f ${updated_scf_vcu}    # Remove the working file
                                      OAM Get Cu SCF File    file=${updated_scf_vcu}    # Save the final ordered file
                                      Set Suite Variable    ${updated_scf_vcu}
                                      Run    command=rm -f ${updated_scf}    # Remove the working file
                                      OAM Get SCF File    file=${updated_scf}    # Save the final ordered file
                                      Set Suite Variable    ${updated_scf}
    ELSE
        OAM Perform Full Commissioning    scf_file=${updated_scf}    skip_relation_errors=${skip_errors}
        OAM wait available
        Run    command=rm -f ${updated_scf}    # Remove the working file
        OAM Get SCF File    file=${updated_scf}    # Save the final ordered file
        Set Suite Variable    ${updated_scf}
    END
    [Return]                          ${result_scf_val}    ${result_pdl}


Is Parameter A Dictionary Key
    [Arguments]             ${dict}
    ...                     ${parameter}
    #
    ${key_flag}=                      Set Variable    ${False}
    FOR    ${key}    ${value}         IN    &{dict}
        ${key_flag}=                  Set Variable    ${False}
        IF    "${key}" == "${parameter}"
            ${key_flag}=              Set Variable    ${True}
        END
        Exit For Loop If              ${key_flag} == ${True}
    END
    [Return]                          ${key_flag}
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Create BWP_PROFILE
#CR_NOT_TESTED#SCF Create BWP_PROFILE_PDCCH
#CR_NOT_TESTED#SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON
#CR_NOT_TESTED#SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED
#CR_NOT_TESTED#SCF Create BWP_PROFILE_PDSCH
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Configure NRDRB


SCF Configure NRPMRNL
    [Arguments]             ${dico}
    #
    Dated Log New Line                ${cc_blue}----SCF Configure NRPMRNL----${cc_normal}
    ${k_miNrCellUtilization}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrCellUtilization
    ${k_miNrMacSduReport}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrMacSduReport
    ${k_miNrPdcch}=                   Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrPdcch
    ${k_miNrPdcch2}=                  Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrPdcch2
    ${k_miNrRim}=                     Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrRim
    ${k_miNrRim1}=                    Is Parameter A Dictionary Key    dict=${dico}    parameter=miNrRim1
    ${dn_nrpmrnl}=                    Set Variable    ${dn_nrpmrnl_base}1
    #
    ${mode}=                          Set Variable    Classical
    IF    ${isAic}
        ${mode}=                      Set Variable    Both
    END
    # NRPMRNL.miNrCellUtilization / update
    IF    ${k_miNrCellUtilization}
        ${current_param}=             Set Variable    miNrCellUtilization
        Configure SCF Set Element     dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRPMRNL.miNrMacSduReport / update
    IF    ${k_miNrMacSduReport}
        ${current_param}=             Set Variable    miNrMacSduReport
        Configure SCF Set Element     dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRPMRNL.miNrPdcch / update
    IF    ${k_miNrPdcch}
        ${current_param}=             Set Variable    miNrPdcch
        Configure SCF Set Element     dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRPMRNL.miNrPdcch2 / update
    IF    ${k_miNrPdcch2}
        ${current_param}=             Set Variable    miNrPdcch2
        Configure SCF Set Element     dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRPMRNL.miNrRim / update # CB009823 RIM framework-1 support
    IF    ${k_miNrRim}
        ${current_param}=             Set Variable    miNrRim
        Configure SCF Set Element     dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRPMRNL.miNrRim1 / update
    IF    ${k_miNrRim1}
        ${current_param}=             Set Variable    miNrRim1
        Configure SCF Set Element     dist_name=${dn_nrpmrnl}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END


#CR_NOT_TESTED#SCF Configure BWP_PROFILE_PDCCH
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure NRBTS
    [Arguments]             ${dico}
    #
    Dated Log New Line                ${cc_blue}----SCF Configure NRBTS----${cc_normal}
    ${k_reportingIntervalPm}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=reportingIntervalPm
    #
    ${k_actBpPoolExtensionTddFr1}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolExtensionTddFr1
    ${k_actBpPoolTddFr1}=             Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolTddFr1
    ${k_actBpPoolTddFr1AlgEnh}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolTddFr1AlgEnh
    ${k_actBpPoolTddFr1Enh}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=actBpPoolTddFr1Enh
    ${k_actNrRimRsResourcePooling}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=actNrRimRsResourcePooling
    ${k_actRtwpMeasurement}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=actRtwpMeasurement
    ${k_dlMutingStateReport}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=dlMutingStateReport
    ${k_riStateReport}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=riStateReport
    ${k_rimRsStateReport}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=rimRsStateReport
    #
    ${mode}=                          Set Variable    Classical
    IF    ${isAic}
        ${mode}=                      Set Variable    Both
    END
    # PMCADM.reportingIntervalPm / update
    IF    ${k_reportingIntervalPm}
        ${current_param}=             Set Variable    reportingIntervalPm
        Configure SCF Set Element     dist_name=${dn_pmcadm}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
        ...                           bestEffort=${False}    aicListEntity=VDUVCU
    END
    #
    # NRBTS.actBpPoolExtensionTddFr1 / update
    IF    ${k_actBpPoolExtensionTddFr1}
        ${current_param}=             Set Variable    actBpPoolExtensionTddFr1
        Configure SCF Set Element     dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRBTS.actBpPoolTddFr1 / update
    IF    ${k_actBpPoolTddFr1}
        ${current_param}=             Set Variable    actBpPoolTddFr1
        Configure SCF Set Element     dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRBTS.actBpPoolTddFr1AlgEnh / update
    IF    ${k_actBpPoolTddFr1AlgEnh}
        ${current_param}=             Set Variable    actBpPoolTddFr1AlgEnh
        Configure SCF Set Element     dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRBTS.actBpPoolTddFr1Enh / update
    IF    ${k_actBpPoolTddFr1Enh}
        ${current_param}=             Set Variable    actBpPoolTddFr1Enh
        Configure SCF Set Element     dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    # NRBTS.actNrRimRsResourcePooling / update
    IF    ${k_actNrRimRsResourcePooling}
        ${current_param}=             Set Variable    actNrRimRsResourcePooling
        Configure SCF Set Element     dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
        ...                           bestEffort=${False}    aicListEntity=VDU
    END
    # NRBTS.actRtwpMeasurement / update
    IF    ${k_actRtwpMeasurement}
        ${current_param}=             Set Variable    actRtwpMeasurement
        Configure SCF Set Element     dist_name=${dn_nrbts}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    END
    #
    ${current_list}=                  Set Variable    actRimCmFmReport
    # NRBTS.actRimCmFmReport.dlMutingStateReport / update
    IF    ${k_dlMutingStateReport}
        ${current_param}=             Set Variable    dlMutingStateReport
        Configure SCF Set Element In List    dist_name=${dn_nrbts}    list_name=${current_list}    elem_name=${current_param}
        ...                           elem_val=${dico}[${current_param}]    scope=${mode}    aicListEntity=VDU
    END
    # NRBTS.actRimCmFmReport.riStateReport / update
    IF    ${k_riStateReport}
        ${current_param}=             Set Variable    riStateReport
        Configure SCF Set Element In List    dist_name=${dn_nrbts}    list_name=${current_list}    elem_name=${current_param}
        ...                           elem_val=${dico}[${current_param}]    scope=${mode}    aicListEntity=VDU
    END
    # NRBTS.actRimCmFmReport.rimRsStateReport / update
    IF    ${k_rimRsStateReport}
        ${current_param}=             Set Variable    rimRsStateReport
        Configure SCF Set Element In List    dist_name=${dn_nrbts}    list_name=${current_list}    elem_name=${current_param}
        ...                           elem_val=${dico}[${current_param}]    scope=${mode}    aicListEntity=VDU
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
SCF Configure NRCELL
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}
    #
    Dated Log New Line                ${cc_blue}----SCF Configure NRCELL----${cc_normal}
    Dated Log                         > from ${list_nrcell}
    ${k_cellDepType}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=cellDepType
    ${k_actNrRim}=                    Is Parameter A Dictionary Key    dict=${dico}    parameter=actNrRim
    ${k_actVoNR}=                     Is Parameter A Dictionary Key    dict=${dico}    parameter=actVoNR
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    #
    ${mode}=                          Set Variable    Classical
    IF    ${isAic}
        ${mode}=                      Set Variable    Both
    END
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${dn_}=                       Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        # NRCELL.cellDepType / check
        IF    ${k_cellDepType}
            ${current_param}=         Set Variable    cellDepType
            ${current_value}=         Set Variable    ${dico}[${current_param}]
            Should Be True            "${list_nrcell[${internal_pos}].cellDepType}" == "${current_value}"
        END
        # NRCELL.actNrRim / update
        IF    ${k_actNrRim}
            ${current_param}=         Set Variable    actNrRim
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
            ...                       bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.actVoNR / update
        IF    ${k_actVoNR}
            ${current_param}=         Set Variable    actVoNR
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
            ...                       bestEffort=${False}    aicListEntity=VDU
        END
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
#[VRF_NPS_AUTO-261]# Closed
Online Modification NRRIM PROFILE Parameters SR-CR
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}
    ...                     ${profil_id}=1
    #
    Dated Log New Line                ${cc_blue}----Online Modification NRRIM PROFILE Parameters SR-CR----${cc_normal}
    Dated Log                         > from ${list_nrcell}
    ${k_actDynamicRiThresBaseCalc}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=actDynamicRiThresBaseCalc
    ${k_nrRiMonitorWindow}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiMonitorWindow
    ${k_riExpectedRssiRangeThres}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=riExpectedRssiRangeThres
    #
    @{list_parameter}=                Create List
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_dn}=                Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}/NRRIM_PROFILE-${profil_id}
        # NRCELL/NRRIM_PROFILE.actDynamicRiThresBaseCalc / modify
        IF    ${k_actDynamicRiThresBaseCalc}
            ${current_param}=             Set Variable    actDynamicRiThresBaseCalc
            ${current_value}=             Set Variable    ${dico}[${current_param}]
            IF    not ${isAic}
                ${dico_parameter}=        Create Dictionary    parameter=${current_param}    dist_name=${current_dn}    value=${current_value}
            ELSE
                ${dico_parameter}=        Create Dictionary    parameterName=${current_param}    operation=update    value=${current_value}
            END
            Dated Log                     ${cc_yellow}> Online modification is required for ${dico_parameter}${cc_normal}
            Append To List                ${list_parameter}    ${dico_parameter}
        END
        # NRCELL/NRRIM_PROFILE.nrRiMonitorWindow / modify
        IF    ${k_nrRiMonitorWindow}
            ${current_param}=             Set Variable    nrRiMonitorWindow
            ${current_value}=             Set Variable    ${dico}[${current_param}]
            IF    not ${isAic}
                ${dico_parameter}=        Create Dictionary    parameter=${current_param}    dist_name=${current_dn}    value=${current_value}
            ELSE
                ${dico_parameter}=        Create Dictionary    parameterName=${current_param}    operation=update    value=${current_value}
            END
            Dated Log                     ${cc_yellow}> Online modification is required for ${dico_parameter}${cc_normal}
            Append To List                ${list_parameter}    ${dico_parameter}
        END
        # NRCELL/NRRIM_PROFILE.riExpectedRssiRangeThres / modify
        IF    ${k_riExpectedRssiRangeThres}
            ${current_param}=             Set Variable    riExpectedRssiRangeThres
            ${current_value}=             Set Variable    ${dico}[${current_param}]
            IF    not ${isAic}
                ${dico_parameter}=        Create Dictionary    parameter=${current_param}    dist_name=${current_dn}    value=${current_value}
            ELSE
                ${dico_parameter}=        Create Dictionary    parameterName=${current_param}    operation=update    value=${current_value}
            END
            Dated Log                     ${cc_yellow}> Online modification is required for ${dico_parameter}${cc_normal}
            Append To List                ${list_parameter}    ${dico_parameter}
        END
        IF    not ${isAic}
            # OAM Set Params is no more compatible with CR since changes implemented with CB012840
            Oam.OAM Set Params            ${list_parameter}
        ELSE
            Oam.OAM Perform Object Recommissioning AIC    dist_name=${current_dn}    parameter=${list_parameter}
        END
    END


# CB011127 #
SCF Create NRRIM PROFILE
    [Arguments]             ${profil_id}
    ...                     ${current_nrcell}
    ...                     ${dico_nrrim}
    ...                     ${rim}=framework-0

    ${current_dn}=                    Set Variable    ${current_nrcell}/NRRIM_PROFILE-${profil_id}
    Dated Log New Line                ${cc_blue}----SCF Create NRRIM PROFILE ${current_dn}----${cc_normal}
    Dated Log                         >> ${dico_nrrim}
    #
    ${mode}=                          Set Variable    Classical
    IF    ${isAic}
        ${mode}=                      Set Variable    Both
    END
    # add object
    ${flag_object}=                   SCF Is Object Exist    dist_name=${current_dn}    scope=${mode}    aicListEntity=VDU
    IF    ${flag_object}
                                      SCF Remove object    dist_name=${current_dn}    scope=${mode}    aicListEntity=VDU
        Dated Log                     > SCF Remove object ${current_dn}
    END
    SCF Add object                    dist_name=${current_dn}    class_name=${cn_nrrim_profile}    scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add object ${current_dn}: class=${cn_nrrim_profile}
    #
    ${k_actFastMuteSrsBeamForRi}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actFastMuteSrsBeamForRi
    ${k_actPartialSlotMuting}=        Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actPartialSlotMuting
    ${k_actRiDetectTriggerDlMit}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRiDetectTriggerDlMitigation
    ${k_actRiPilotDlMute}=            Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRiPilotDlMute
    ${k_actRimAsymmetricIndic}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimAsymmetricIndication
    ${k_actRimCmMeaPeriodReport}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimCmMeaPeriodReport
    ${k_actRimMitigationExtend}=      Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimMitigationExtend
    ${k_actRimPdcchMuting}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actRimPdcchMuting
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
    ${k_nrRiThresDropHeightSpec}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresDropHeightSpecialSlot
    ${k_nrRiThresDurationRatio}=      Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresDurationRatio
    ${k_nrRimMitigationScheme}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimMitigationScheme
    ${k_nrRimPowerRampingStep}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimPowerRampingStep
    ${k_nrRimRarTpcCommand}=          Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimRarTpcCommand
    ${k_nrRimRsUpdateInterval}=       Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRimRsUpdateInterval
    ${k_numDetectedSetIdForMit}=      Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numDetectedSetIdForMitigation
    ${k_numRbForRs}=                  Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numRbForRs
    ${k_numRsType1SetId}=             Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numRsType1SetId
    ${k_numRsType2SetId}=             Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numRsType2SetId
    ${k_offsetRsSequence}=            Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=offsetRsSequence
    ${k_offsetRsSequenceRs2}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=offsetRsSequenceRs2
    ${k_repetitionRsType1}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=repetitionRsType1
    ${k_repetitionRsType2}=           Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=repetitionRsType2
    ${k_riPilotPeriod}=               Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=riPilotPeriod
    ${k_riPilotWindow}=               Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=riPilotWindow
    ${k_rimDlMitigationManualTrig}=   Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimDlMitigationManualTrigger
    ${k_rimRsDetectionThreshold}=     Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimRsDetectionThreshold
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
    #
    ${k_actDynamicRiThresBaseCalc}=   Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=actDynamicRiThresBaseCalc
    ${k_autoRiThresBaseCalcInterv}=   Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=autoRiThresBaseCalcInterval
    ${k_minDlMitigationDuratWoRi}=    Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=minDlMitigationDurationWoRi
    ${k_maxRsDetectDuratWithoutRi}=   Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=maxRsDetectDurationWithoutRi
    ${k_nrRiThresBase}=               Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresBase
    ${k_nrRiThresDropHeight}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiThresDropHeight
    ${k_nrRiUpdateInterval}=          Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=nrRiUpdateInterval
    ${k_numWinRiDetectForDlMitigat}=  Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=numWinRiDetectForDlMitigation
    ${k_riExpectedRssiRangeThres}=    Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=riExpectedRssiRangeThres
    ${k_rimDlMutingMaxRange}=         Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimDlMutingMaxRange
    ${k_rimDynamicSrsSlotOffsetEna}=  Is Parameter A Dictionary Key    dict=${dico_nrrim}    parameter=rimDynamicSrsSlotOffsetEnabled
    #
    # NRCELL/NRRIM_PROFILE.actFastMuteSrsBeamForRi / add
    ${current_param}=                 Set Variable    actFastMuteSrsBeamForRi
    ${current_value}=    Run Keyword If    ${k_actFastMuteSrsBeamForRi}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actPartialSlotMuting / add
    ${current_param}=                 Set Variable    actPartialSlotMuting
    ${current_value}=    Run Keyword If    ${k_actPartialSlotMuting}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRiDetectTriggerDlMitigation / add
    ${current_param}=                 Set Variable    actRiDetectTriggerDlMitigation
    ${current_value}=    Run Keyword If    ${k_actRiDetectTriggerDlMit}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRiPilotDlMute / add
    ${current_param}=                 Set Variable    actRiPilotDlMute
    ${current_value}=    Run Keyword If    ${k_actRiPilotDlMute}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimAsymmetricIndication / add
    ${current_param}=                 Set Variable    actRimAsymmetricIndication
    ${current_value}=    Run Keyword If    ${k_actRimAsymmetricIndic}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimCmMeaPeriodReport / add
    ${current_param}=                 Set Variable    actRimCmMeaPeriodReport
    ${current_value}=    Run Keyword If    ${k_actRimCmMeaPeriodReport}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimMitigationExtend / add
    ${current_param}=                 Set Variable    actRimMitigationExtend
    ${current_value}=    Run Keyword If    ${k_actRimMitigationExtend}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimPdcchMuting / add
    ${current_param}=                 Set Variable    actRimPdcchMuting
    ${current_value}=    Run Keyword If    ${k_actRimPdcchMuting}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    disabled
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimPdcchMutingOnSpecialSlot / add
    ${current_param}=                 Set Variable    actRimPdcchMutingOnSpecialSlot
    ${current_value}=    Run Keyword If    ${k_actRimPdcchMutingOnSpec}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimPowerReduction / add
    ${current_param}=                 Set Variable    actRimPowerReduction
    ${current_value}=    Run Keyword If    ${k_actRimPowerReduction}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRimSoftDlMuting / add
    ${current_param}=                 Set Variable    actRimSoftDlMuting
    ${current_value}=    Run Keyword If    ${k_actRimSoftDlMuting}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.actRsEnoughIndication / add
    ${current_param}=                 Set Variable    actRsEnoughIndication
    ${current_value}=    Run Keyword If    ${k_actRsEnoughIndication}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.factorRsSequence / add
    ${current_param}=                 Set Variable    factorRsSequence
    ${current_value}=    Run Keyword If    ${k_factorRsSequence}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.factorRsSequenceRs2 / add
    ${current_param}=                 Set Variable    factorRsSequenceRs2
    ${current_value}=    Run Keyword If    ${k_factorRsSequenceRs2}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    1
    IF    "${rim}" == "framework-1"
        SCF Add element  dist_name=${current_dn}  element_name=${current_param}  element_value=${current_value}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    END
    # NRCELL/NRRIM_PROFILE.globalF0ForRs / add
    ${current_param}=                 Set Variable    globalF0ForRs
    ${current_value}=    Run Keyword If    ${k_globalF0ForRs}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    633390
    IF    "${rim}" == "framework-1"
        SCF Add element  dist_name=${current_dn}  element_name=${current_param}  element_value=${current_value}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    END
    # NRCELL/NRRIM_PROFILE.highPrioRbTransInMutedSlots / add
    ${current_param}=                 Set Variable    highPrioRbTransInMutedSlots
    ${current_value}=    Run Keyword If    ${k_highPrioRbTransInMutedS}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiDisableMonitorPowerOfUSlot / add
    ${current_param}=                 Set Variable    nrRiDisableMonitorPowerOfUSlot
    ${current_value}=    Run Keyword If    ${k_nrRiDisableMonPowerOfUS}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiMonitorDownhillEndSymbol / add
    ${current_param}=                 Set Variable    nrRiMonitorDownhillEndSymbol
    ${current_value}=    Run Keyword If    ${k_nrRiMonDownhillEndSymbo}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    11
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiMonitorDownhillStartSymbol / add
    ${current_param}=                 Set Variable    nrRiMonitorDownhillStartSymbol
    ${current_value}=    Run Keyword If    ${k_nrRiMonDownhillStartSym}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiMonitorInSSlotEnabled / add
    ${current_param}=                 Set Variable    nrRiMonitorInSSlotEnabled
    ${current_value}=    Run Keyword If    ${k_nrRiMonInSSlotEnabled}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiMonitorWindow / add
    ${current_param}=                 Set Variable    nrRiMonitorWindow
    ${current_value}=    Run Keyword If    ${k_nrRiMonitorWindow}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    5
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiThresDropHeightSpecialSlot / add
    ${current_param}=                 Set Variable    nrRiThresDropHeightSpecialSlot
    ${current_value}=    Run Keyword If    ${k_nrRiThresDropHeightSpec}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    6
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiThresDurationRatio / add
    ${current_param}=                 Set Variable    nrRiThresDurationRatio
    ${current_value}=    Run Keyword If    ${k_nrRiThresDurationRatio}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    80
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRimMitigationScheme / add
    ${current_param}=                 Set Variable    nrRimMitigationScheme
    ${current_value}=    Run Keyword If    ${k_nrRimMitigationScheme}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    UL and DL mitigation
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRimPowerRampingStep / add
    ${current_param}=                 Set Variable    nrRimPowerRampingStep
    ${current_value}=    Run Keyword If    ${k_nrRimPowerRampingStep}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    dB6
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRimRarTpcCommand / add
    ${current_param}=                 Set Variable    nrRimRarTpcCommand
    ${current_value}=    Run Keyword If    ${k_nrRimRarTpcCommand}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    8dB
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRimRsUpdateInterval / add
    ${current_param}=                 Set Variable    nrRimRsUpdateInterval
    ${current_value}=    Run Keyword If    ${k_nrRimRsUpdateInterval}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    5
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.numDetectedSetIdForMitigation / add
    ${current_param}=                 Set Variable    numDetectedSetIdForMitigation
    ${current_value}=    Run Keyword If    ${k_numDetectedSetIdForMit}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    1
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.numRbForRs / add
    ${current_param}=                 Set Variable    numRbForRs
    ${current_value}=    Run Keyword If    ${k_numRbForRs}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    48 RBs
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.numRsType1SetId / add
    ${current_param}=                 Set Variable    numRsType1SetId
    ${current_value}=    Run Keyword If    ${k_numRsType1SetId}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    65536 setIDs
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.numRsType2SetId / add
    ${current_param}=                 Set Variable    numRsType2SetId
    ${current_value}=    Run Keyword If    ${k_numRsType2SetId}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    65536 setIDs
    IF    "${rim}" == "framework-1"
        SCF Add element  dist_name=${current_dn}  element_name=${current_param}  element_value=${current_value}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    END
    # NRCELL/NRRIM_PROFILE.offsetRsSequence / add
    ${current_param}=                 Set Variable    offsetRsSequence
    ${current_value}=    Run Keyword If    ${k_offsetRsSequence}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.offsetRsSequenceRs2 / add
    ${current_param}=                 Set Variable    offsetRsSequenceRs2
    ${current_value}=    Run Keyword If    ${k_offsetRsSequenceRs2}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    1
    IF    "${rim}" == "framework-1"
        SCF Add element  dist_name=${current_dn}  element_name=${current_param}  element_value=${current_value}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    END
    # NRCELL/NRRIM_PROFILE.repetitionRsType1 / add
    ${current_param}=                 Set Variable    repetitionRsType1
    ${current_value}=    Run Keyword If    ${k_repetitionRsType1}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    r2
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.repetitionRsType2 / add
    ${current_param}=                 Set Variable    repetitionRsType2
    ${current_value}=    Run Keyword If    ${k_repetitionRsType2}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    r2
    IF    "${rim}" == "framework-1"
        SCF Add element  dist_name=${current_dn}  element_name=${current_param}  element_value=${current_value}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    END
    # NRCELL/NRRIM_PROFILE.riPilotPeriod / add
    ${current_param}=                 Set Variable    riPilotPeriod
    ${current_value}=    Run Keyword If    ${k_riPilotPeriod}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    1
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.riPilotWindow / add
    ${current_param}=                 Set Variable    riPilotWindow
    ${current_value}=    Run Keyword If    ${k_riPilotWindow}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    100
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rimDlMitigationManualTrigger / add
    ${current_param}=                 Set Variable    rimDlMitigationManualTrigger
    ${current_value}=    Run Keyword If    ${k_rimDlMitigationManualTrig}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    disabled
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rimRsDetectionThreshold / add
    ${current_param}=                 Set Variable    rimRsDetectionThreshold
    ${current_value}=    Run Keyword If    ${k_rimRsDetectionThreshold}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    20
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rimRssiMeasInRiState0 / add
    ${current_param}=                 Set Variable    rimRssiMeasInRiState0
    ${current_value}=    Run Keyword If    ${k_rimRssiMeasInRiState0}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    false
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsDetectionWindow / add
    ${current_param}=                 Set Variable    rsDetectionWindow
    ${current_value}=    Run Keyword If    ${k_rsDetectionWindow}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    sloping based
    IF    "${rim}" == "framework-1"
        SCF Add element  dist_name=${current_dn}  element_name=${current_param}  element_value=${current_value}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    END
    # NRCELL/NRRIM_PROFILE.rsDistanceThreshold / add
    ${current_param}=                 Set Variable    rsDistanceThreshold
    ${current_value}=    Run Keyword If    ${k_rsDistanceThreshold}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsNearFarConfig / add
    ${current_param}=                 Set Variable    rsNearFarConfig
    ${current_value}=    Run Keyword If    ${k_rsNearFarConfig}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    near-far config1
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsPattern1Period / add
    ${current_param}=                 Set Variable    rsPattern1Period
    ${current_value}=    Run Keyword If    ${k_rsPattern1Period}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    5ms
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsPattern2Period / add
    ${current_param}=                 Set Variable    rsPattern2Period
    ${current_value}=    Run Keyword If    ${k_rsPattern2Period}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    2.5ms
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsPowerOffset / add
    ${current_param}=                 Set Variable    rsPowerOffset
    ${current_value}=    Run Keyword If    ${k_rsPowerOffset}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsSetId / add
    ${current_param}=                 Set Variable    rsSetId
    ${current_value}=    Run Keyword If    ${k_rsSetId}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    0
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsSetIdDisplayInFault / add
    ${current_param}=                 Set Variable    rsSetIdDisplayInFault
    ${current_value}=    Run Keyword If    ${k_rsSetIdDisplayInFault}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    enabled
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsTransTrigger / add
    ${current_param}=                 Set Variable    rsTransTrigger
    ${current_value}=    Run Keyword If    ${k_rsTransTrigger}    Set Variable    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Set Variable    RI trigger
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rsType1NScId / add
    ${current_param}=                 Set Variable    rsType1NScId
    @{current_list}=    Run Keyword If    ${k_rsType1NScId}    Copy List    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Create List    1    2    3    4    5    6    7    8
    SCF Add list                      dist_name=${current_dn}    list_name=${current_param}    scope=${mode}    aicListEntity=VDU
    SCF Add elements to list          dist_name=${current_dn}    list_name=${current_param}    elements=${current_list}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    # NRCELL/NRRIM_PROFILE.rsType2NScId / add
    ${current_param}=                 Set Variable    rsType2NScId
    @{current_list}=    Run Keyword If    ${k_rsType2NScId}    Copy List    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Create List    1    2    3    4    5    6    7    8
    IF    "${rim}" == "framework-1"
        SCF Add list                  dist_name=${current_dn}    list_name=${current_param}    scope=${mode}    aicListEntity=VDU
        SCF Add elements to list  dist_name=${current_dn}   list_name=${current_param}  elements=${current_list}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    END
    # NRCELL/NRRIM_PROFILE.startRbForRs / add
    ${current_param}=                 Set Variable    startRbForRs
    @{current_list}=    Run Keyword If    ${k_startRbForRs}    Copy List    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Create List    0    48    96    144
    IF    "${rim}" == "framework-0"
        SCF Add list                  dist_name=${current_dn}    list_name=${current_param}    scope=${mode}    aicListEntity=VDU
        SCF Add elements to list  dist_name=${current_dn}  list_name=${current_param}  elements=${current_list}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    END
    # NRCELL/NRRIM_PROFILE.startFreqOffsetForRs / add
    ${current_param}=                 Set Variable    startFreqOffsetForRs
    @{current_list}=    Run Keyword If    ${k_startFreqOffsetForRs}    Copy List    ${dico_nrrim}[${current_param}]
    ...                               ELSE    Create List    86
    IF    "${rim}" == "framework-1"
        SCF Add list                  dist_name=${current_dn}    list_name=${current_param}    scope=${mode}    aicListEntity=VDU
        SCF Add elements to list  dist_name=${current_dn}   list_name=${current_param}  elements=${current_list}  scope=${mode}  aicListEntity=VDU
        Dated Log                     > SCF Add elements to list ${current_dn}: ${current_param}= ${current_list}
    END
    #
    # NRCELL/NRRIM_PROFILE.actDynamicRiThresBaseCalc / add
    ${current_param}=                 Set Variable    actDynamicRiThresBaseCalc
    ${current_value}=                 Set Variable    false    # default
    IF    ${k_actDynamicRiThresBaseCalc}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.autoRiThresBaseCalcInterval / add
    ${current_param}=                 Set Variable    autoRiThresBaseCalcInterval
    ${current_value}=                 Set Variable    168    # default
    IF    ${k_autoRiThresBaseCalcInterv}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.minDlMitigationDurationWoRi / add
    ${current_param}=                 Set Variable    minDlMitigationDurationWoRi
    ${current_value}=                 Set Variable    10    # default
    IF    ${k_minDlMitigationDuratWoRi}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.maxRsDetectDurationWithoutRi / add
    ${current_param}=                 Set Variable    maxRsDetectDurationWithoutRi
    ${current_value}=                 Set Variable    30    # default
    IF    ${k_maxRsDetectDuratWithoutRi}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiThresBase / add
    ${current_param}=                 Set Variable    nrRiThresBase
    ${current_value}=                 Set Variable    -100    # default
    IF    ${k_nrRiThresBase}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiThresDropHeight / add
    ${current_param}=                 Set Variable    nrRiThresDropHeight
    ${current_value}=                 Set Variable    6    # default
    IF    ${k_nrRiThresDropHeight}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.nrRiUpdateInterval / add
    ${current_param}=                 Set Variable    nrRiUpdateInterval
    ${current_value}=                 Set Variable    5    # default
    IF    ${k_nrRiUpdateInterval}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.numWinRiDetectForDlMitigation / add
    ${current_param}=                 Set Variable    numWinRiDetectForDlMitigation
    ${current_value}=                 Set Variable    1    # default
    IF    ${k_numWinRiDetectForDlMitigat}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.riExpectedRssiRangeThres / add
    ${current_param}=                 Set Variable    riExpectedRssiRangeThres
    ${current_value}=                 Set Variable    3    # default
    IF    ${k_riExpectedRssiRangeThres}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rimDlMutingMaxRange / add
    ${current_param}=                 Set Variable    rimDlMutingMaxRange
    ${current_value}=                 Set Variable    DL+special slots    # default
    IF    ${k_rimDlMutingMaxRange}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}
    # NRCELL/NRRIM_PROFILE.rimDynamicSrsSlotOffsetEnabled / add
    ${current_param}=                 Set Variable    rimDynamicSrsSlotOffsetEnabled
    ${current_value}=                 Set Variable    enabled    # default
    IF    ${k_rimDynamicSrsSlotOffsetEna}
        ${current_value}=             Set Variable    ${dico_nrrim}[${current_param}]
    END
    SCF Add element                   dist_name=${current_dn}    element_name=${current_param}    element_value=${current_value}
    ...                               scope=${mode}    aicListEntity=VDU
    Dated Log                         > SCF Add element ${current_dn}: ${current_param}= ${current_value}


SCF Configure NRCELL For RIM RS
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}

    Dated Log New Line                ${cc_blue}----SCF Configure NRCELL----${cc_normal}
    Dated Log                         > from ${list_nrcell}
    ${k_cellDepType}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=cellDepType
    ${k_actNrRim}=                    Is Parameter A Dictionary Key    dict=${dico}    parameter=actNrRim
    # and specific for 60MHz
    ${k_chBw}=                        Is Parameter A Dictionary Key    dict=${dico}    parameter=chBw
    ${k_maxNumOfCaUsersNRCell}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfCaUsersNRCell
    ${k_maxNumOfNrDcSnUsers}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfNrDcSnUsers
    ${k_maxNumOfRrcSA}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfRrcSA
    ${k_maxNumOfUsersPerCell}=        Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfUsersPerCell
    ${k_maxNumOfUsersPerNRCell}=      Is Parameter A Dictionary Key    dict=${dico}    parameter=maxNumOfUsersPerNRCell
    ${k_pMax}=                        Is Parameter A Dictionary Key    dict=${dico}    parameter=pMax
    ${k_reqMinNumPuschPrb}=           Is Parameter A Dictionary Key    dict=${dico}    parameter=reqMinNumPuschPrb
    #
    ${k_bbmodBoardConfigType}=        Is Parameter A Dictionary Key    dict=${dico}    parameter=bbmodBoardConfigType
    ${k_factorRsSequence}=            Is Parameter A Dictionary Key    dict=${dico}    parameter=factorRsSequence
    ${k_factorRsSequenceRs2}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=factorRsSequenceRs2
    ${k_globalF0ForRs}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=globalF0ForRs
    ${k_nrRimMitigationScheme}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRimMitigationScheme
    ${k_nrRimRsUpdateInterval}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRimRsUpdateInterval
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
    #
    ${k_actDynamicRiThresBaseCalc}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=actDynamicRiThresBaseCalc
    ${k_autoRiThresBaseCalcInterv}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=autoRiThresBaseCalcInterval
    ${k_minDlMitigationDuratWoRi}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=minDlMitigationDurationWoRi
    ${k_maxRsDetectDuratWithoutRi}=   Is Parameter A Dictionary Key    dict=${dico}    parameter=maxRsDetectDurationWithoutRi
    ${k_nrRiThresDurationRatio}=      Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiThresDurationRatio
    ${k_nrRiThresBase}=               Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiThresBase
    ${k_nrRiThresDropHeight}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiThresDropHeight
    ${k_nrRiUpdateInterval}=          Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRiUpdateInterval
    ${k_numWinRiDetectForDlMitigat}=  Is Parameter A Dictionary Key    dict=${dico}    parameter=numWinRiDetectForDlMitigation
    ${k_riExpectedRssiRangeThres}=    Is Parameter A Dictionary Key    dict=${dico}    parameter=riExpectedRssiRangeThres
    ${k_rimDlMutingMaxRange}=         Is Parameter A Dictionary Key    dict=${dico}    parameter=rimDlMutingMaxRange
    ${k_rimDynamicSrsSlotOffsetEna}=  Is Parameter A Dictionary Key    dict=${dico}    parameter=rimDynamicSrsSlotOffsetEnabled
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    #
    ${mode}=                          Set Variable    Classical
    IF    ${isAic}
        ${mode}=                      Set Variable    Both
    END
    # BBMOD.bbmodBoardConfigType / update
    ${current_param}=                 Set Variable    bbmodBoardConfigType
    Run Keyword If                    ${k_bbmodBoardConfigType}    Configure SCF Set Element    dist_name=${dn_bbmod}
    ...                               elem_name=${current_param}    elem_val=${dico}[${current_param}]    scope=${mode}
    #
    &{dico_nrrim}=                    Create Dictionary    lambda=null
    # NRCELL/NRRIM_PROFILE.factorRsSequence / update
    ${current_param}=                 Set Variable    factorRsSequence
    Run Keyword If                    ${k_factorRsSequence}         Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.factorRsSequenceRs2 / update
    ${current_param}=                 Set Variable    factorRsSequenceRs2
    Run Keyword If                    ${k_factorRsSequenceRs2}      Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.globalF0ForRs / update
    ${current_param}=                 Set Variable    globalF0ForRs
    Run Keyword If                    ${k_globalF0ForRs}            Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRimMitigationScheme / update
    ${current_param}=                 Set Variable    nrRimMitigationScheme
    Run Keyword If                    ${k_nrRimMitigationScheme}    Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRimRsUpdateInterval / update
    ${current_param}=                 Set Variable    nrRimRsUpdateInterval
    Run Keyword If                    ${k_nrRimRsUpdateInterval}    Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiMonitorInSSlotEnabled / update
    ${current_param}=                 Set Variable    nrRiMonitorInSSlotEnabled
    Run Keyword If                    ${k_nrRiMonInSSlotEnabled}    Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiMonitorWindow / update
    ${current_param}=                 Set Variable    nrRiMonitorWindow
    Run Keyword If                    ${k_nrRiMonitorWindow}        Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numRbForRs / update
    ${current_param}=                 Set Variable    numRbForRs
    Run Keyword If                    ${k_numRbForRs}               Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numRsType1SetId / update
    ${current_param}=                 Set Variable    numRsType1SetId
    Run Keyword If                    ${k_numRsType1SetId}          Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numRsType2SetId / update
    ${current_param}=                 Set Variable    numRsType2SetId
    Run Keyword If                    ${k_numRsType2SetId}          Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.offsetRsSequence / update
    ${current_param}=                 Set Variable    offsetRsSequence
    Run Keyword If                    ${k_offsetRsSequence}         Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.offsetRsSequenceRs2 / update
    ${current_param}=                 Set Variable    offsetRsSequenceRs2
    Run Keyword If                    ${k_offsetRsSequenceRs2}      Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.repetitionRsType1 / update
    ${current_param}=                 Set Variable    repetitionRsType1
    Run Keyword If                    ${k_repetitionRsType1}        Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.repetitionRsType2 / update
    ${current_param}=                 Set Variable    repetitionRsType2
    Run Keyword If                    ${k_repetitionRsType2}        Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsDetectionWindow / update
    ${current_param}=                 Set Variable    rsDetectionWindow
    Run Keyword If                    ${k_rsDetectionWindow}        Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsNearFarConfig / update
    ${current_param}=                 Set Variable    rsNearFarConfig
    Run Keyword If                    ${k_rsNearFarConfig}          Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsPattern1Period / update
    ${current_param}=                 Set Variable    rsPattern1Period
    Run Keyword If                    ${k_rsPattern1Period}         Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsPattern2Period / update
    ${current_param}=                 Set Variable    rsPattern2Period
    Run Keyword If                    ${k_rsPattern2Period}         Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsTransTrigger / update
    ${current_param}=                 Set Variable    rsTransTrigger
    Run Keyword If                    ${k_rsTransTrigger}           Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsType1NScId / update
    ${current_param}=                 Set Variable    rsType1NScId
    Run Keyword If                    ${k_rsType1NScId}             Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rsType2NScId / update
    ${current_param}=                 Set Variable    rsType2NScId
    Run Keyword If                    ${k_rsType2NScId}             Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.startRbForRs / update
    ${current_param}=                 Set Variable    startRbForRs
    Run Keyword If                    ${k_startRbForRs}             Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.startFreqOffsetForRs / update
    ${current_param}=                 Set Variable    startFreqOffsetForRs
    Run Keyword If                    ${k_startFreqOffsetForRs}     Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    #
    # NRCELL/NRRIM_PROFILE.actDynamicRiThresBaseCalc / update
    ${current_param}=                 Set Variable    actDynamicRiThresBaseCalc
    Run Keyword If                    ${k_actDynamicRiThresBaseCalc}  Set To Dictionary  ${dico_nrrim}  ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.autoRiThresBaseCalcInterval / update
    ${current_param}=                 Set Variable    autoRiThresBaseCalcInterval
    Run Keyword If                    ${k_autoRiThresBaseCalcInterv}  Set To Dictionary  ${dico_nrrim}  ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.minDlMitigationDurationWoRi / update
    ${current_param}=                 Set Variable    minDlMitigationDurationWoRi
    Run Keyword If                    ${k_minDlMitigationDuratWoRi}   Set To Dictionary  ${dico_nrrim}  ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.maxRsDetectDurationWithoutRi / update
    ${current_param}=                 Set Variable    maxRsDetectDurationWithoutRi
    Run Keyword If                    ${k_maxRsDetectDuratWithoutRi}  Set To Dictionary  ${dico_nrrim}  ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiThresDurationRatio / update
    ${current_param}=                 Set Variable    nrRiThresDurationRatio
    Run Keyword If                    ${k_nrRiThresDurationRatio}     Set To Dictionary  ${dico_nrrim}  ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiThresBase / update
    ${current_param}=                 Set Variable    nrRiThresBase
    Run Keyword If                    ${k_nrRiThresBase}            Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiThresDropHeight / update
    ${current_param}=                 Set Variable    nrRiThresDropHeight
    Run Keyword If                    ${k_nrRiThresDropHeight}      Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.nrRiUpdateInterval / update
    ${current_param}=                 Set Variable    nrRiUpdateInterval
    Run Keyword If                    ${k_nrRiUpdateInterval}       Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.numWinRiDetectForDlMitigation / update
    ${current_param}=                 Set Variable    numWinRiDetectForDlMitigation
    Run Keyword If                    ${k_numWinRiDetectForDlMitigat}  Set To Dictionary  ${dico_nrrim}  ${current_param}  ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.riExpectedRssiRangeThres / update
    ${current_param}=                 Set Variable    riExpectedRssiRangeThres
    Run Keyword If                    ${k_riExpectedRssiRangeThres}  Set To Dictionary  ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rimDlMutingMaxRange / update
    ${current_param}=                 Set Variable    rimDlMutingMaxRange
    Run Keyword If                    ${k_rimDlMutingMaxRange}      Set To Dictionary   ${dico_nrrim}   ${current_param}   ${dico}[${current_param}]
    # NRCELL/NRRIM_PROFILE.rimDynamicSrsSlotOffsetEnabled / update
    ${current_param}=                 Set Variable    rimDynamicSrsSlotOffsetEnabled
    Run Keyword If                    ${k_rimDynamicSrsSlotOffsetEna}  Set To Dictionary  ${dico_nrrim}  ${current_param}  ${dico}[${current_param}]
    #
    FOR    ${position}    IN          @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${dn_}=                       Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        # NRCELL.cellDepType / check
        ${current_param}=             Set Variable    cellDepType
        ${current_value}=             Run Keyword If    ${k_cellDepType}    Set Variable    ${dico}[${current_param}]
        Run Keyword If                ${k_cellDepType}    Should Be True  "${list_nrcell[${internal_pos}].cellDepType}" == "${current_value}"
        # NRCELL.actNrRim / update
        ${current_param}=             Set Variable    actNrRim
        ${current_act_rim_rs}=        Run Keyword If    ${k_actNrRim}    Set Variable    ${dico}[${current_param}]
        ...                           ELSE    Set Variable    framework-0    # default value
        Configure SCF Set Element     dist_name=${dn_}    elem_name=${current_param}    elem_val=${current_act_rim_rs}
        ...                           scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        #
        # NRCELL.chBw / update
        ${current_param}=             Set Variable    chBw
        IF    ${k_chBw}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.maxNumOfCaUsersNRCell / update
        ${current_param}=             Set Variable    maxNumOfCaUsersNRCell
        IF    ${k_maxNumOfCaUsersNRCell}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.maxNumOfNrDcSnUsers / update
        ${current_param}=             Set Variable    maxNumOfNrDcSnUsers
        IF    ${k_maxNumOfNrDcSnUsers}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.maxNumOfRrcSA / update
        ${current_param}=             Set Variable    maxNumOfRrcSA
        IF    ${k_maxNumOfRrcSA}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.maxNumOfUsersPerCell / update
        ${current_param}=             Set Variable    maxNumOfUsersPerCell
        IF    ${k_maxNumOfUsersPerCell}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.maxNumOfUsersPerNRCell / update
        ${current_param}=             Set Variable    maxNumOfUsersPerNRCell
        IF    ${k_maxNumOfUsersPerNRCell}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.pMax / update
        ${current_param}=             Set Variable    pMax
        IF    ${k_pMax}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        # NRCELL.reqMinNumPuschPrb / update
        ${current_param}=             Set Variable    reqMinNumPuschPrb
        IF    ${k_reqMinNumPuschPrb}
            Configure SCF Set Element    dist_name=${dn_}    elem_name=${current_param}    elem_val=${dico}[${current_param}]
            ...                       scope=${mode}    bestEffort=${False}    aicListEntity=VDU
        END
        #
        SCF Create NRRIM PROFILE      profil_id=1    current_nrcell=${dn_}    dico_nrrim=${dico_nrrim}    rim=${current_act_rim_rs}
        #
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Configure dynamicAggLevelSet
#CR_NOT_TESTED#SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet
#CR_NOT_TESTED#SCF Configure NRCELL BW
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Configure Bandwidth TDD 20MHz
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Configure Bandwidth TDD 40MHz
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Configure Bandwidth TDD 100MHz 5GC001070
#CR_NOT_TESTED#SCF Configure Bandwidth TDD 100MHz 5GC001116
#CR_NOT_TESTED#SCF Configure Bandwidth TDD 100MHz 5GC001208
#CR_NOT_TESTED#SCF Configure Bandwidth TDD 100MHz 5GC008406
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR_NOT_TESTED#SCF Configure NRREL
#CR_NOT_TESTED#SCF Configure Handover Relations
#CR_NOT_TESTED#SCF Configure Intra Frequency Handover SA
# --------------------------------------------------------------------------------------------------------------------------------------------------
