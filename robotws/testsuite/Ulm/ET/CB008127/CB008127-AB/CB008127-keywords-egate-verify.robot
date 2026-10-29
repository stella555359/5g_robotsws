*** Settings ***
Documentation   This is a keyword file for CB008127 part egate verify
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***



Prepare Egate File For Verification
    [Documentation]    [PRIVATE]    prepare egate file for verification, remove empty lines, strip lines
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${egate_log_file}
    ${contents}    Get File           ${egate_log_file}
    Create File    ${resultDir}/egate.txt
    @{lines}       Split To Lines     ${contents}

    FOR   ${line}    IN    @{lines}
       ${length}    GetLength    ${line}
       IF  ${length} == 0    CONTINUE
       ${line_wo_blanks}     Strip String     ${line}
       Append To File    ${resultDir}/egate.txt    ${line_wo_blanks}\n
    END


Verify Single Pdu Setup
    [Documentation]    [PRIVATE]    verify single pdu setup contains a2-Threshold rsrp, a3-Offset rsrp, a5-Threshold1 rsrp, a5-Threshold2 rsrp
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}

    Log To Console    \nVerify events for UE${UE_id} pdu setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue${UE_id}.txt
    ${index}   Evaluate   ${ue_id}-1
    ${contents}    Get File           ${resultDir}/egate.txt

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA2
    ${search_for}   Set Variable   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[${index}],
    Log To Console    Check that "eventId eventA2" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA3
    ${search_for}   Set Variable   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[${index}],
    Log To Console    Check that "eventId eventA3" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA5
    ${search_for}   Set Variable   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[${index}],
    Log To Console    Check that "eventId eventA5" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}
    ${search_for}   Set Variable   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[${index}],
    Log To Console    Check that "eventId eventA5" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}


Verify Single A2 Measurement
    [Documentation]    [PRIVATE]    verify single A2 measurement contains a1-Threshold rsrp
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}

    Log To Console    \nVerify A2 measurement for UE${UE_id}
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue${UE_id}.txt
    ${index}   Evaluate   ${ue_id}-1
    ${contents}    Get File           ${resultDir}/egate.txt

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA1
    ${search_for}   Set Variable   a1-Threshold rsrp : ${a1MeashoSsbRsrq_a1ThresholdhoSsb}[${index}],
    Log To Console    Check that "eventId eventA1" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}


Verify Egate Logs T1
    [Documentation]    [PRIVATE]    verify egate log for
    ...                             AB_Configuration_of_A2_A3_A5_intraFreq_measurements_with_measurement_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider
    FOR   ${id}  IN   2  3  4  5  6  7  8  9
       Verify Single Pdu Setup         ue_id=${id}
       Verify Single A2 Measurement    ue_id=${id}
    END


Verify Egate Logs T2
    [Documentation]    [PRIVATE]    verify egate log for AB_Redirection_based_on_A2_measurements_upon_selected_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter value a2-Threshold rsrp for UE9 pdu setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue9.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[8]
    ...   ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[8]
       ${search_for}   Set Variable   a2-Threshold rsrp : ${value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify A2 for UE9, no redirect
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_no_redirect_ue9.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword And Continue On Failure   Should Not Contain    ${contents}    redirect   redirect found, although should not be contained

    Log To Console    \nVerify A2 for UE9, successful redirect
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue9.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${search_for}   Set Variable   UE9: Redirected carrier info is present in RRC Release
    Log To Console    Check that following string is contained "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${search_for}   Set Variable   UE9: Received RRCConnectionRelease with NR redirectedCarrierInfo=633364; redirect to gNB-3 cell 1 will be done
    Log To Console    Check that following string is contained "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}


Verify Egate Logs T3
    [Documentation]    [PRIVATE]    verify egate log for AB_Interworking_with_mobility_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter value a2-Threshold rsrp and rsrq for UE6 pdu setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue6.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   rsrp
    ...   rsrq
       ${search_for}   Set Variable   a2-Threshold ${value} : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[5],
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify A2 for UE6
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue6.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   rsrp
    ...   rsrq
       ${search_for}   Set Variable   a1-Threshold ${value} : ${a1MeashoSsbRsrq_a1ThresholdhoSsb}[5],
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T4
    [Documentation]    [PRIVATE]    verify egate log for
    ...                             AB_Configuration_of_intraFreq_measurements_A2_A3_A5_using_selected_measurement_profile_during_RRC_Resume
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify resume data in egate_log_resume_ue4.txt
    Prepare Egate File For Verification    ${resultDir}/egate_log_resume_ue4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}   IN
    ...   rrcResumeRequest1
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[3]
    ...   a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[3]
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[3]
    ...   a5-Threshold1 rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[3]
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[3]
    ...   rrcResumeComplete
    ...   UE4: UE performed resume procedure
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify "UE_INACTIVE" state in egate_log_ue_disp_ue4_log1.txt
    ${contents}    Get File           ${resultDir}/egate_log_ue_disp_ue4_log1.txt
    ${line_found}  Get Lines Matching Regexp    ${contents}   ^4${SPACE}  partial_match=true
    Run Keyword And Continue On Failure   Should Contain   ${line_found}   ${SPACE}UE_INACTIVE${SPACE}

    Log To Console    \nVerify "ACTIVE" state in egate_log_ue_disp_ue4_log2.txt
    ${contents}    Get File           ${resultDir}/egate_log_ue_disp_ue4_log2.txt
    ${line_found}  Get Lines Matching Regexp    ${contents}   ^4${SPACE}  partial_match=true
    Run Keyword And Continue On Failure   Should Contain   ${line_found}   ${SPACE}ACTIVE${SPACE}


Verify Egate Logs T5
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Interaction_with_CB009205_A1_based_traffic_steering_to_preferred_NR_layer_during_context_setup
    ...       :Autor: Sylvia Schneider
    ${search_for}   Set Variable    a1-Threshold rsrp : ${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[6],
    Log To Console    \nVerify parameter value "${search_for}" for UE7 pdu setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue7.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}


Verify Egate Logs T6
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_A1_based_traffic_steering_to_preferred_NR_layer_after_Xn_HO
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify parameter values in A3 measurement
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[4],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[4],
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[4],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[4],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[4],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${search_for}   Set Variable    Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    Log To Console    --check value "${search_for}" present
    Run Keyword And Continue On Failure      Should Contain   ${contents}    ${search_for}

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t6.xml
    Log To Console    \nget threshold values from ${resultDir}/SCF_final_t6.xml
    ${a2ThresholdhoSsbRsrpSA_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    Log To Console    NRCELL-2, list a2MeashoSsbRsrpSA, parameter a2ThresholdhoSsbRsrpSA has value "${a2ThresholdhoSsbRsrpSA_nrcell2}"
    ${a3OffsetSsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRCELL-2, list a3MeasSsbRsrp, parameter a3OffsetSsbRsrp has value "${a3OffsetSsbRsrp_nrcell2}"
    ${a5Threshold1SsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    Log To Console    NRCELL-2, list a5MeasSsbRsrp, parameter a5Threshold1SsbRsrp has value "${a5Threshold1SsbRsrp_nrcell2}"
    ${a5Threshold2SsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    Log To Console    NRCELL-2, list a5MeasSsbRsrp, parameter a5Threshold2SsbRsrp has value "${a5Threshold2SsbRsrp_nrcell2}"

    Log To Console    \nVerify parameter values in A4 measurement
    Prepare Egate File For Verification    ${resultDir}/A4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2ThresholdhoSsbRsrpSA_nrcell2},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_nrcell2},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrp_nrcell2},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrp_nrcell2},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values in A1 measurement, no A4 configured
    Prepare Egate File For Verification    ${resultDir}/A1_no_A4_configured.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword And Continue On Failure   Should Not Contain    ${contents}     eventA4


Verify Egate Logs T7
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Configuration_of_A2_A3_A5_intraFreq_measurements_during_Xn_HO_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify parameter values in A3 measurement
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrq : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[4],
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[4],
    ...   a3-Offset rsrq : ${a3MeasSsbRsrp_a3OffsetSsb}[4],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrp_a5Threshold1Ssb}[4],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrp_a5Threshold2Ssb}[4],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T8
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Configuration_of_A2_A3_A5_intraFreq_measurements_during_NG_HO_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify parameter values in A3 measurement
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[1],
    ...   a2-Threshold rsrq : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[1],
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[1],
    ...   a3-Offset rsrq : ${a3MeasSsbRsrp_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[1],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrp_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[1],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrp_a5Threshold2Ssb}[1],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T9
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_A1_based_traffic_steering_to_preferred_NR_layer_after_NG_HO
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify parameter values in A3 measurement
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[7],
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[7],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[7],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[7],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${search_for}   Set Variable    Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    Log To Console    --check value "${search_for}" present
    Run Keyword And Continue On Failure
    ...   Should Contain   ${contents}    ${search_for}

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t9.xml
    Log To Console    \nget threshold values from ${resultDir}/SCF_final_t9.xml
    ${a2ThresholdhoSsbRsrpSA_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    Log To Console    NRCELL-2, list a2MeashoSsbRsrpSA, parameter a2ThresholdhoSsbRsrpSA has value "${a2ThresholdhoSsbRsrpSA_nrcell2}"
    ${a3OffsetSsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRCELL-2, list a3MeasSsbRsrp, parameter a3OffsetSsbRsrp has value "${a3OffsetSsbRsrp_nrcell2}"
    ${a5Threshold1SsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    Log To Console    NRCELL-2, list a5MeasSsbRsrp, parameter a5Threshold1SsbRsrp has value "${a5Threshold1SsbRsrp_nrcell2}"
    ${a5Threshold2SsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    Log To Console    NRCELL-2, list a5MeasSsbRsrp, parameter a5Threshold2SsbRsrp has value "${a5Threshold2SsbRsrp_nrcell2}"

    Log To Console    \nVerify parameter values in A4 measurement
    Prepare Egate File For Verification    ${resultDir}/A4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2ThresholdhoSsbRsrpSA_nrcell2},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_nrcell2},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrp_nrcell2},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrp_nrcell2},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values in A1 measurement, no A4 configured
    Prepare Egate File For Verification    ${resultDir}/A1_no_A4_configured.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword And Continue On Failure   Should Not Contain    ${contents}     eventA4


Verify Egate Logs T10
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Interworking_with_mobility_profiles_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t10.xml
    Log To Console    \nget threshold values from ${resultDir}/SCF_final_t10.xml
    ${a2ThresholdhoSsbRsrqSA_nrcell1}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a2MeashoSsbRsrqSA"]/item/p[@name="a2ThresholdhoSsbRsrqSA"]
    Log To Console    NRCELL-1, list a2MeashoSsbRsrqSA, parameter a2ThresholdhoSsbRsrqSA has value "${a2ThresholdhoSsbRsrqSA_nrcell1}"
    ${a1ThresholdhoSsbRsrqSA_nrcell1}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a1MeashoSsbRsrqSA"]/item/p[@name="a1ThresholdhoSsbRsrqSA"]
    Log To Console    NRCELL-1, list a1MeashoSsbRsrqSA, parameter a1ThresholdhoSsbRsrqSA has value "${a1ThresholdhoSsbRsrqSA_nrcell1}"

    Log To Console    \nVerify parameter values in A3 measurement
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[8],
    ...   a2-Threshold rsrq : ${a2ThresholdhoSsbRsrqSA_nrcell1},
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[8],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[8],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[8],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values in A2 measurement
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue9.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1MeashoSsbRsrq_a1ThresholdhoSsb}[8],
    ...   a1-Threshold rsrq : ${a1ThresholdhoSsbRsrqSA_nrcell1},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T11
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_InterRAT_handover_with_measurement_profiles
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values in A2 measurement
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue8.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   b2-Threshold1 rsrq : ${b2Threshold1hoRsrp_b2Threshold1hoRsrq}[7],
    ...   b2-Threshold2EUTRA rsrq : ${b2Threshold2hoRsrp_b2Threshold2hoRsrq}[7],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values after inter RAT handover
    Prepare Egate File For Verification    ${resultDir}/interRatHO.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrq : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[7],
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[7],
    ...   a3-Offset rsrq : ${a3MeasSsbRsrp_a3OffsetSsb}[7],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrp_a5Threshold1Ssb}[7],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrp_a5Threshold2Ssb}[7],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T12
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Removal_of_Inter_RAT_B2_measurement_with_measurement_profiles
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values in A2 measurement
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue9.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   b2-Threshold1 rsrp : ${b2Threshold1hoRsrp_b2Threshold1hoRsrq}[8],
    ...   b2-Threshold1 rsrq : ${b2Threshold1hoRsrp_b2Threshold1hoRsrq}[8],
    ...   b2-Threshold2EUTRA rsrp : ${b2Threshold2hoRsrp_b2Threshold2hoRsrq}[8],
    ...   b2-Threshold2EUTRA rsrq : ${b2Threshold2hoRsrp_b2Threshold2hoRsrq}[8],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values in A1 measurement
    Prepare Egate File For Verification    ${resultDir}/A1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${check}   Set Variable    a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[8],
    Log To Console    --check value "${check}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}   ${check}
    ${temp1}    Fetch From Right      ${contents}     measObjectToRemoveList
    ${temp2}    Fetch From Left       ${temp1}        },
    ${temp3}    Replace String   ${temp2}     \n     ${EMPTY}
    ${temp4}    Replace String   ${temp3}     {      ${EMPTY}
    @{id}   Split String    ${temp4}   ,
    Log To Console    --check measObjectToRemoveList contains value "2"
    Run Keyword And Continue On Failure   List Should Contain Value   ${id}   2
    Log To Console    --check measObjectToRemoveList contains value "3"
    Run Keyword And Continue On Failure   List Should Contain Value   ${id}   3
    Log To Console    --check measObjectToRemoveList contains only 2 items
    Run Keyword And Continue On Failure   Length Should Be    ${id}   2   wrong number of items in measObjectToRemoveList

    Log To Console    \nVerify measurement config contains no EventB2
    Prepare Egate File For Verification    ${resultDir}/disp_meas_config.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword And Continue On Failure   Should Not Contain   ${contents}    EventB2


Verify Egate Logs T13
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_InterRAT_handover_for_VoNR_call_with_no_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t13.xml
    Log To Console    \nget threshold values from ${resultDir}/SCF_final_t13.xml
    ${a2ThresholdHoSsbRsrpVoNr_nrcell1}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdHoSsbRsrpVoNr"]
    Log To Console    NRCELL-1, list a2MeashoSsbRsrqSA, parameter a2ThresholdHoSsbRsrpVoNr has value "${a2ThresholdHoSsbRsrpVoNr_nrcell1}"
    ${a1ThresholdHoSsbRsrpVoNr_nrcell1}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a1MeashoSsbRsrpSA"]/item/p[@name="a1ThresholdHoSsbRsrpVoNr"]
    Log To Console    NRCELL-1, list a1MeashoSsbRsrpSA, parameter a1ThresholdHoSsbRsrpVoNr has value "${a1ThresholdHoSsbRsrpVoNr_nrcell1}"

    ${b2Threshold1hoRsrpVoNr_NRHOIR}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRHOIR-1"]/p[@name="b2Threshold1hoRsrpVoNr"]
    Log To Console    NRHOIR-1, parameter b2Threshold1hoRsrpVoNr has value "${b2Threshold1hoRsrpVoNr_NRHOIR}"
    ${b2Threshold2hoRsrpVoNr_NRHOIR}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRHOIR-1"]/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrpVoNr"]
    Log To Console    NRHOIR-1, list eutraB2MeashoRsrp, parameter b2Threshold2hoRsrpVoNr has value "${b2Threshold2hoRsrpVoNr_NRHOIR}"

    ${a2ThresholdhoSsbRsrpSA_nrcell1}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    Log To Console    NRCELL-1, list a2MeashoSsbRsrpSA, parameter a2ThresholdhoSsbRsrpSA has value "${a2ThresholdhoSsbRsrpSA_nrcell1}"

    ${a3OffsetSsbRsrpVoNr_nrhoif-1}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrpVoNr"]
    Log To Console    NRCELL-1/NRHOIF-1, list a3MeasSsbRsrp, parameter a3OffsetSsbRsrpVoNr has value "${a3OffsetSsbRsrpVoNr_nrhoif-1}"
    ${a5Threshold1SsbRsrpVoNr_nrhoif-1}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrpVoNr"]
    Log To Console    NRCELL-1/NRHOIF-1, list a5MeasSsbRsrp, parameter a5Threshold1SsbRsrpVoNr has value "${a5Threshold1SsbRsrpVoNr_nrhoif-1}"
    ${a5Threshold2SsbRsrpVoNr_nrhoif-1}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrpVoNr"]
    Log To Console    NRCELL-1/NRHOIF-1, list a5MeasSsbRsrp, parameter a5Threshold2SsbRsrpVoNr has value "${a5Threshold2SsbRsrpVoNr_nrhoif-1}"

    Log To Console    \nVerify parameter values after pdu modify
    Prepare Egate File For Verification    ${resultDir}/pduSessionModify.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${check}   Set Variable    a2-Threshold rsrp : ${a2ThresholdHoSsbRsrpVoNr_nrcell1},
    Log To Console    --check value "${check}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}   ${check}

    Log To Console    \nVerify parameter values in A2 measurement
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue7.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1ThresholdHoSsbRsrpVoNr_nrcell1},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrpVoNr_nrhoif-1},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrpVoNr_nrhoif-1},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrpVoNr_nrhoif-1},
    ...   b2-Threshold1 rsrp : ${b2Threshold1hoRsrpVoNr_NRHOIR},
    ...   b2-Threshold2EUTRA rsrp : ${b2Threshold2hoRsrpVoNr_NRHOIR},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values after inter RAT handover
    Prepare Egate File For Verification    ${resultDir}/interRatHO.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[6],
    ...   a2-Threshold rsrp : ${a2ThresholdHoSsbRsrpVoNr_nrcell1},
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[6],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[6],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values after after pdu modify remove
    Prepare Egate File For Verification    ${resultDir}/pduSessionModify_del.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${search_for}   Set Variable    a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    Log To Console    --check value "${search_for}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}


Verify Egate Logs T14
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_A1_based_traffic_steering_to_preferred_NR_layer_after_RRC_Re_Establishment
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values after UE RRC reestablishment
    Prepare Egate File For Verification    ${resultDir}/ue_rrc_reestablish.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[3],
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[3],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[3],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[3],
    ...   a1-Threshold rsrp : ${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[3],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify parameter values in A1 measurement, no A4 configured
    Prepare Egate File For Verification    ${resultDir}/A1_no_A4_configured.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword And Continue On Failure   Should Not Contain    ${contents}     eventA4

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t14.xml
    Log To Console    \nget threshold values from ${resultDir}/SCF_final_t14.xml
    ${a2ThresholdhoSsbRsrpSA_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    Log To Console    NRCELL-2, list a2MeashoSsbRsrpSA, parameter a2ThresholdhoSsbRsrpSA has value "${a2ThresholdhoSsbRsrpSA_nrcell2}"
    ${a3OffsetSsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRCELL-2, list a3MeasSsbRsrp, parameter a3OffsetSsbRsrp has value "${a3OffsetSsbRsrp_nrcell2}"
    ${a5Threshold1SsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    Log To Console    NRCELL-2, list a5MeasSsbRsrp, parameter a5Threshold1SsbRsrp has value "${a5Threshold1SsbRsrp_nrcell2}"
    ${a5Threshold2SsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    Log To Console    NRCELL-2, list a5MeasSsbRsrp, parameter a5Threshold2SsbRsrp has value "${a5Threshold2SsbRsrp_nrcell2}"

    Log To Console    \nVerify parameter values in A4 measurement
    Prepare Egate File For Verification    ${resultDir}/A4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2ThresholdhoSsbRsrpSA_nrcell2},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_nrcell2},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrp_nrcell2},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrp_nrcell2},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T15
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_RRC_Re_Establishment_during_Xn_HO_with_measurement_profiles
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values after A3 incoming XN HO
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${search_reestablish}    Set Variable    message c1 : rrcReestablishmentRequest
    ${reestablish_parts}   Split String    ${contents}    ${search_reestablish}

    Log To Console    Verify parameter values before "${search_reestablish}"
    Verify Single T15 Reestablish Parts      reestablish_part=${reestablish_parts}[0]
    Log To Console    Verify parameter values after "${search_reestablish}"
    Verify Single T15 Reestablish Parts      reestablish_part=${reestablish_parts}[1]


Verify Single T15 Reestablish Parts
    [Documentation]    [PRIVATE]    verify single t15 reestablish parts
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${reestablish_part}
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[4],
    ...   a2-Threshold rsrq : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[4],
    ...   a3-Offset rsrq : ${a3MeasSsbRsrp_a3OffsetSsb}[4],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrp_a5Threshold1Ssb}[4],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrp_a5Threshold2Ssb}[4],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${reestablish_part}    ${search_for}
    END


Verify Egate Logs T16
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Second_RRC_Reconfiguration_for_InterFreq_A2_after_Xn_handover_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values after A3 incoming XN HO
    Prepare Egate File For Verification    ${resultDir}/A3_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${search_HO}  Set Variable    Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    Log To Console    --check value "${search_HO}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_HO}

    ${rrc_parts}   Split String    ${contents}    ${search_HO}

    Log To Console    check values in 1st rrcReconfiguration message
    FOR   ${search_for}    IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[6],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[6],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc_parts}[0]    ${search_for}
    END

    Log To Console    check values in 2nd rrcReconfiguration message after ueCapabilityInformation
    ${rrc2_parts}   Split String    ${rrc_parts}[1]    ueCapabilityInformation
    ${search_for}    Set Variable   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    Log To Console    --check value "${search_for}" present
    Run Keyword And Continue On Failure   Should Contain   ${rrc2_parts}[2]    ${search_for}

    Log To Console    \nVerify parameter values after A2
    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t16.xml
    ${a3OffsetSsbRsrp_nrcell2}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRCELL-2, list a3MeasSsbRsrp, parameter a3OffsetSsbRsrp has value "${a3OffsetSsbRsrp_nrcell2}"
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue7.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_nrcell2},
    ...   a1-Threshold rsrp : ${a1MeashoSsbRsrq_a1ThresholdhoSsb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T17
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Second_RRC_Reconfiguration_for_A1_based_traffic_steering_after_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values after A3 incoming XN HO
    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${search_HO}  Set Variable    Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    Log To Console    --check value "${search_HO}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_HO}

    ${rrc_parts}   Split String    ${contents}    ${search_HO}

    Log To Console    check values in 1st rrcReconfiguration message
    FOR   ${search_for}    IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[6],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[6],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc_parts}[0]    ${search_for}
    END

    Log To Console    check values in 2nd rrcReconfiguration message after ueCapabilityInformation
    ${rrc2_parts}   Split String    ${rrc_parts}[1]    ueCapabilityInformation
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[6],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    ...   a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc2_parts}[2]    ${search_for}
    END

    Log To Console    \nVerify parameter values after A1 measurement report
    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t17.xml
    ${path_IEF}      Set Variable   ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1
    ${a4ThresholdSsbRsrp_IEF}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${path_IEF}"]/list[@name="a4MeasHigherPrioFreqSsbRsrp"]/item/p[@name="a4ThresholdSsbRsrp"]
    Log To Console    NRMEASPR_IEF-1, list a4MeasHigherPrioFreqSsbRsrp, parameter a4ThresholdSsbRsrp has value "${a4ThresholdSsbRsrp_IEF}"

    Prepare Egate File For Verification    ${resultDir}/A1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${search_a4}  Set Variable    a4-Threshold rsrp : ${a4ThresholdSsbRsrp_IEF}
    Log To Console    --check value "${search_a4}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_a4}


Verify Egate Logs T18
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Second_RRC_Reconfiguration_using_measurement_profile_after_NG_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values after A3 incoming XN HO

    Prepare Egate File For Verification    ${resultDir}/A3.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${search_HO}  Set Variable    Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    Log To Console    check value "${search_HO}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_HO}

    ${rrc_parts}   Split String    ${contents}    ${search_HO}

    Log To Console    check values in 1st rrcReconfiguration message
    FOR   ${search_for}    IN
    ...   a3-Offset rsrq : ${a3MeasSsbRsrp_a3OffsetSsb}[6],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrp_a5Threshold1Ssb}[6],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrp_a5Threshold2Ssb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc_parts}[0]    ${search_for}
    END

    Log To Console    check values in 2nd rrcReconfiguration message after ueCapabilityInformation
    ${rrc2_parts}   Split String    ${rrc_parts}[1]    ueCapabilityInformation
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrq : ${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[6],
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    ...   a2-Threshold rsrq : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc2_parts}[2]    ${search_for}
    END


Verify Egate Logs T19
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Second_RRC_Reconfiguration_after_interRAT_HO_from_LTE_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify parameter values after incoming inter_RAT handover
    Prepare Egate File For Verification    ${resultDir}/interRatHO.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${search_HO}  Set Variable    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    Log To Console    check value "${search_HO}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_HO}

    ${rrc_parts}   Split String    ${contents}    ${search_HO}

    Log To Console    check values in 1st rrcReconfiguration message
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[6],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[6],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc_parts}[0]    ${search_for}
    END

    Log To Console    check values in 2nd rrcReconfiguration message
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[6],
    ...   a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc_parts}[1]    ${search_for}
    END

    Log To Console    \nVerify parameter values after 2nd A2
    ${parsed_SCF}    Parse Xml    ${resultDir}/SCFC_CB008127_t19.xml
    ${path_IEF}      Set Variable   ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1
    ${a3OffsetSsbRsrp_IEF}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${path_IEF}"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRMEASPR_IEF-1, list a3MeasSsbRsrp, parameter a3OffsetSsbRsrp has value "${a3OffsetSsbRsrp_IEF}"
    ${a5Threshold1SsbRsrp_IEF}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${path_IEF}"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    Log To Console    NRMEASPR_IEF-1, list a5MeasSsbRsrp, parameter a5Threshold1SsbRsrp has value "${a5Threshold1SsbRsrp_IEF}"
    ${a5Threshold2SsbRsrp_IEF}    Get Element Text    ${parsed_SCF}
    ...     xpath=.//managedObject[@distName="${path_IEF}"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    Log To Console    NRMEASPR_IEF-1, list a5MeasSsbRsrp, parameter a5Threshold2SsbRsrp has value "${a5Threshold2SsbRsrp_IEF}"

    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue7_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1MeashoSsbRsrq_a1ThresholdhoSsb}[6],
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_IEF},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrp_IEF},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrp_IEF},
    ...   b2-Threshold1 rsrq : ${b2Threshold1hoRsrp_b2Threshold1hoRsrq}[6],
    ...   b2-Threshold2EUTRA rsrq : ${b2Threshold2hoRsrp_b2Threshold2hoRsrq}[6],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


Verify Egate Logs T20
    [Documentation]    [PRIVATE]    verify egate log for
    ...        AB_Measurement_profile_selection_without_freqBandIndicatorNR
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify events for UE2 pdu setup and A2 measurement, 1st run, NRMEASPR_MA_SA-2 is selected
    Verify Pdu A2 T20   run=1    threshold_index=2
    Log To Console    \nVerify events for UE2 pdu setup and A2 measurement, 2nd run, NRMEASPR_MA_SA-1 is selected
    Verify Pdu A2 T20   run=2    threshold_index=1


Verify Pdu A2 T20
    [Documentation]    [PRIVATE]    verify pdu A2 t20
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${run}    ${threshold_index}
    Log To Console    --- Verify events for UE2 pdu setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue2_${run}.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA2
    ${search_for}   Set Variable   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[${threshold_index}],
    Log To Console    Check that "eventId eventA2" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA3
    ${search_for}   Set Variable   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[${threshold_index}],
    Log To Console    Check that "eventId eventA3" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA5
    ${search_for}   Set Variable   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[${threshold_index}],
    Log To Console    Check that "eventId eventA5" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}
    ${search_for}   Set Variable   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[${threshold_index}],
    Log To Console    Check that "eventId eventA5" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}

    Log To Console    --- Verify A2 measurement for UE2
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue2_${run}.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${temp_1}    Fetch From Right      ${contents}     eventId eventA1
    ${search_for}   Set Variable   a1-Threshold rsrp : ${a1MeashoSsbRsrq_a1ThresholdhoSsb}[${threshold_index}],
    Log To Console    Check that "eventId eventA1" contains "${search_for}"
    Run Keyword And Continue On Failure   Should Contain   ${temp_1}    ${search_for}


Verify Egate Logs T21
    [Documentation]    [PRIVATE]    verify egate logs t21
    ...       :Autor: Sylvia Schneider

    Log To Console    --- Verify events for UE4 pdu setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[2],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[2],
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[2],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[2],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[2],
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    --- Verify for reestablishment, that measIdToRemoveList contains value 1
    Prepare Egate File For Verification    ${resultDir}/ue_rrc_reestablish.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch From Right      ${contents}     measIdToRemoveList
    ${temp2}    Fetch From Left       ${temp1}        },
    ${temp3}    Replace String   ${temp2}     \n     ${EMPTY}
    ${temp4}    Replace String   ${temp3}     {      ${EMPTY}
    ${item_measIdToRemoveList}    Replace String   ${temp4}     }      ${EMPTY}
    Run Keyword And Continue On Failure
    ...   Should Be Equal    ${item_measIdToRemoveList}    1


Verify Egate Logs T22
    [Documentation]    [PRIVATE]    verify egate logs t22
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t22.xml
    ${xpath_IAF-5}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-5"]
    ${xpath_IAF-7}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-7"]

    Log To Console    --- Verify events after incoming Xn handover
    Prepare Egate File For Verification    ${resultDir}/A3_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${search_HO}  Set Variable    Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    Log To Console    --check value "${search_HO}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_HO}

    ${rrc_parts}   Split String    ${contents}    ${search_HO}

    Log To Console    \ncheck values in 1st rrcReconfiguration message
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
        ${scf_value}    Get Element Text    ${parsed_SCF}   xpath=.//${xpath_IAF-5}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  Set Variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_IAF-5 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc_parts}[0]    ${search_text}
    END

    Log To Console    \ncheck values in 2nd rrcReconfiguration message after ueCapabilityInformation
    ${rrc2_parts}   Split String    ${rrc_parts}[1]    ueCapabilityInformation
    FOR   ${search_for}         ${list}                       ${param}  IN
    ...   a1-Threshold rsrp     a1MeashoPrefNRLayerSsbRsrp    a1ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeashoSsbRsrp               a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeasRedirectSsbRsrp         a2ThresholdRedirectSsbRsrp
        ${scf_value}    Get Element Text    ${parsed_SCF}   xpath=.//${xpath_IAF-5}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  Set Variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_IAF-5 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${rrc2_parts}[2]    ${search_text}
    END

    Log To Console    \n--- Verify A2 measurement
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue7.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    ${a1ThresholdhoSsbRsrp_IAF-5}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-5}/list[@name="a1MeashoSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    ${search_for}   Set Variable   a1-Threshold rsrp : ${a1ThresholdhoSsbRsrp_IAF-5},
    Log To Console    --check NRMEASPR_IAF-5 value "${search_for}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    ${a3OffsetSsbRsrp_nrhoif-1}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    ${search_for}   Set Variable   a3-Offset rsrp : ${a3OffsetSsbRsrp_nrhoif-1},
    Log To Console    --check NRCELL-1/NRHOIF-1 value "${search_for}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    Log To Console    \n--- Verify events after intra-gNB Handover
    Prepare Egate File For Verification    ${resultDir}/A3_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a2-Threshold rsrp     a2MeashoSsbRsrp          a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeasRedirectSsbRsrp    a2ThresholdRedirectSsbRsrp
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
        ${scf_value}    Get Element Text    ${parsed_SCF}   xpath=.//${xpath_IAF-7}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  Set Variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_IAF-7 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}
    END


Verify Egate Logs T23
    [Documentation]    [PRIVATE]    verify egate logs t23
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    Parse Xml    ${resultDir}/SCF_final_t23.xml
    ${xpath_IAF-3}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    ${a2ThresholdhoSsbRsrp_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a2MeashoSsbRsrp"]/item/p[@name="a2ThresholdhoSsbRsrp"]
    ${a2ThresholdRedirectSsbRsrp_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    ${a3OffsetSsbRsrp_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    ${a5Threshold1SsbRsrp_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    ${a5Threshold2SsbRsrp_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    ${a1ThresholdhoSsbRsrp_hoPref_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a1MeashoPrefNRLayerSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    ${a1ThresholdhoSsbRsrp_ho_IAF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-3}/list[@name="a1MeashoSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]

    ${xpath_IAF-4}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-4"]
    ${a1ThresholdhoSsbRsrp_hoPref_IAF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-4}/list[@name="a1MeashoPrefNRLayerSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    ${a1ThresholdhoSsbRsrp_IAF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-4}/list[@name="a1MeashoPrefNRLayerSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    ${a2ThresholdRedirectSsbRsrp_IAF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-4}/list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    ${a3OffsetSsbRsrp_IAF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-4}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    ${a5Threshold1SsbRsrp_IAF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-4}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    ${a5Threshold2SsbRsrp_IAF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IAF-4}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]

    ${xpath_IEF-1}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]
    ${a3OffsetSsbRsrp_IEF-1}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IEF-1}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]

    ${xpath_IEF-2}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2"]
    ${a3OffsetSsbRsrp_IEF-2}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IEF-2}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]

    ${xpath_IRF-3}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-3"]
    ${b2Threshold1hoRsrq_IRF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IRF-3}/p[@name="b2Threshold1hoRsrq"]
    ${b2Threshold2hoRsrq_IRF-3}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IRF-3}/list[@name="eutraB2MeashoRsrq"]/item/p[@name="b2Threshold2hoRsrq"]

    ${xpath_IRF-4}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-4"]
    ${b2Threshold1hoRsrq_IRF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IRF-4}/p[@name="b2Threshold1hoRsrq"]
    ${b2Threshold2hoRsrq_IRF-4}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//${xpath_IRF-4}/list[@name="eutraB2MeashoRsrq"]/item/p[@name="b2Threshold2hoRsrq"]

    Log To Console    --- Verify events after 1st PDU setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu_ue4_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a2-Threshold rsrp : ${a2ThresholdhoSsbRsrp_IAF-3},
    ...   a2-Threshold rsrp : ${a2ThresholdRedirectSsbRsrp_IAF-3},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_IAF-3},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrp_IAF-3},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrp_IAF-3},
    ...   a1-Threshold rsrp : ${a1ThresholdhoSsbRsrp_hoPref_IAF-3},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    --- Verify events after A2 measurement
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2_ue4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1ThresholdhoSsbRsrp_ho_IAF-3},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_IEF-1},
    ...   b2-Threshold1 rsrq : ${b2Threshold1hoRsrq_IRF-3},
    ...   b2-Threshold2EUTRA rsrq : ${b2Threshold2hoRsrq_IRF-3},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    --- Verify events after 2nd PDU setup
    Prepare Egate File For Verification    ${resultDir}/egate_log_start_pdu2_ue4.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   a1-Threshold rsrp : ${a1ThresholdhoSsbRsrp_hoPref_IAF-4},
    ...   a1-Threshold rsrp : ${a1ThresholdhoSsbRsrp_IAF-4},
    ...   a2-Threshold rsrp : ${a2ThresholdRedirectSsbRsrp_IAF-4},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_IAF-4},
    ...   a5-Threshold1 rsrp : ${a5Threshold1SsbRsrp_IAF-4},
    ...   a5-Threshold2 rsrp : ${a5Threshold2SsbRsrp_IAF-4},
    ...   a3-Offset rsrp : ${a3OffsetSsbRsrp_IEF-2},
    ...   b2-Threshold1 rsrq : ${b2Threshold1hoRsrq_IRF-4},
    ...   b2-Threshold2EUTRA rsrq : ${b2Threshold2hoRsrq_IRF-4},
        Log To Console    --check value "${search_for}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
