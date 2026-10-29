*** Settings ***
Documentation   This is a keyword file for CB008127-F part egate verify
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***



prepare egate file for verification
    [Documentation]    [PRIVATE]    prepare egate file for verification, remove empty lines, strip lines
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${egate_log_file}
    ${contents}    Get File           ${egate_log_file}
    Create File    ${resultDir}/egate.txt
    @{lines}       Split to lines     ${contents}

    FOR   ${line}    IN    @{lines}
       ${length}    GetLength    ${line}
       IF  ${length} == 0    CONTINUE
       ${line_wo_blanks}     Strip String     ${line}
       Append To File    ${resultDir}/egate.txt    ${line_wo_blanks}\n
    END


verify egate logs t1
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_F_InterRAT_handover_for_VoNR_call_with_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}   parse xml    ${resultDir}/SCF_final_t1.xml
    ${xpath_IAF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_IAF-2}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2"]
    ${xpath_IEF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]
    ${xpath_IEF-2}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2"]
    ${xpath_IRF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-1"]
    ${xpath_IRF-2}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-2"]

    Log To Console    \nVerify pdu session setup values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    prepare egate file for verification    ${resultDir}/egate_log_start_pdu_ue3_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify 1st A2 measurement report values
    prepare egate file for verification    ${resultDir}/egate_log_A2_ue3_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${object}   ${list}                   ${param}                        ${value_name}        IN
    ...   IAF-1       a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   IEF-1       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IEF-1       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IEF-1       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-1}/p[@name="b2Threshold1hoRsrp"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that IRF-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-1}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrp"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that IRF-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    Log To Console    \nVerify PDU modify add 5QI-1 values
    prepare egate file for verification    ${resultDir}/pduSessionModify_qfi3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${object}   ${list}                   ${param}                        ${value_name}        IN
    ...   IAF-2       a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   IAF-2       a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   IAF-2       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IAF-2       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IAF-2       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
    ...   IEF-2       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IEF-2       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IEF-2       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-2}/p[@name="b2Threshold1hoRsrp"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that IRF-2 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-2}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrp"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that IRF-2 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    Log To Console    \nVerify incoming inter-RaT handover values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    prepare egate file for verification    ${resultDir}/interRatHO.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-2}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify 2nd A2 measurement report values
    prepare egate file for verification    ${resultDir}/egate_log_A2_ue3_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${object}   ${list}                   ${param}                        ${value_name}        IN
    ...   IAF-2       a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   IEF-2       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IEF-2       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IEF-2       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${xpath_NRHOIR-1}  set variable  managedObject[@distName="${bts_distName}/NRHOIR-1"]
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_NRHOIR-1}/p[@name="b2Threshold1hoRsrpVoNr"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that NRHOIR-1 VoNr "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}    get element text
    ...    ${parsed_SCF}   xpath=.//${xpath_NRHOIR-1}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrpVoNr"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that NRHOIR-1 VoNr "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    Log To Console    \nVerify values after PDU modify, remove 5QI-1
    prepare egate file for verification    ${resultDir}/pduSessionModify_del_qci3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${object}   ${list}                   ${param}                        ${value_name}        IN
    ...   IAF-1       a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   IAF-1       a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   IAF-1       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IAF-1       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IAF-1       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
    ...   IEF-1       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IEF-1       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IEF-1       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-1}/p[@name="b2Threshold1hoRsrp"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that IRF-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-1}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrp"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that IRF-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}


verify egate logs t2
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_F_Reselection_of_measurement_profile_based_on_5QI_and_CA_capability_criterions
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}   parse xml    ${resultDir}/SCF_final_t2.xml

    ${xpath_IAF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_IAF-3}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    ${xpath_IEF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]
    ${xpath_IEF-3}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-3"]
    ${xpath_IRF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-1"]
    ${xpath_IRF-3}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-3"]

    Log To Console    \nVerify 1st pdu session setup values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    prepare egate file for verification    ${resultDir}/egate_log_start_pdu_ue4_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify 2nd pdu session setup values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-3
    prepare egate file for verification    ${resultDir}/egate_log_start_pdu_ue4_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-3}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify A2 measurement report values
    prepare egate file for verification    ${resultDir}/egate_log_A2_ue4_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${object}   ${list}                   ${param}                        ${value_name}        IN
    ...   IAF-3       a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   IEF-3       a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   IEF-3       a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   IEF-3       a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-3}/p[@name="b2Threshold1hoRsrp"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that IRF-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IRF-3}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrp"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that IRF-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    ${parsed_SCF}   parse xml    ${resultDir}/SCFC_delta_modify_IAF-3_values.xml
    Log To Console    \nVerify A2 measurement report values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-3
    prepare egate file for verification    ${resultDir}/A1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-3}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify after pdu release, removal of voice bearer, report values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    prepare egate file for verification    ${resultDir}/release_Pdu.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


verify egate logs t3
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_F_Reselection_of_measurement_profile_based_on_5QI_and_CA_capability_criterions
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}   parse xml    ${resultDir}/SCF_final_t3.xml

    ${xpath_NRCELL-1}  set variable  managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_NRHOIF-1}  set variable  managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]
    ${xpath_NRHOIR-1}  set variable  managedObject[@distName="${bts_distName}/NRHOIR-1"]
    ${xpath_IAF-4}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-4"]

    Log To Console    \nVerify 1st pdu session setup values are taken from NRCELL-1
    prepare egate file for verification    ${resultDir}/egate_log_start_pdu_ue5_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_NRCELL-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify A2 measurement report values
    prepare egate file for verification    ${resultDir}/egate_log_A2_ue5_1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${object}   ${list}                   ${param}                        ${value_name}        IN
    ...   NRCELL-1    a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   NRHOIF-1    a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   NRHOIF-1    a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   NRHOIF-1    a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_NRHOIR-1}/p[@name="b2Threshold1hoRsrp"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that NRHOIR-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_NRHOIR-1}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrp"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that NRHOIR-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    Log To Console    \nVerify PDU modify voice bearer values are taken IAF-4
    prepare egate file for verification    ${resultDir}/pduSessionModify_qfi3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a1MeashoSsbRsrp           a1ThresholdhoSsbRsrp            a1-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-4}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that ${object} "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    ${SCF_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_NRHOIR-1}/p[@name="b2Threshold1hoRsrpVoNr"]
    ${search_for}   set variable    b2-Threshold1 rsrp : ${SCF_value},
    Log To Console    Check that NRHOIR-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    ${SCF_value}
    ...    get element text    ${parsed_SCF}   xpath=.//${xpath_NRHOIR-1}/list[@name="eutraB2MeashoRsrp"]/item/p[@name="b2Threshold2hoRsrpVoNr"]
    ${search_for}   set variable    b2-Threshold2EUTRA rsrp : ${SCF_value},
    Log To Console    Check that NRHOIR-1 "${search_for}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}

    Log To Console    \nVerify incoming inter-RaT handover values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-4
    prepare egate file for verification    ${resultDir}/interRatHO.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a2MeasRedirectSsbRsrp     a2ThresholdRedirectSsbRsrp      a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-4}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify after pdu release, removal of voice bearer, report values are taken from NRCELL-1
    prepare egate file for verification    ${resultDir}/pduSessionModify_del_qci3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a2MeashoSsbRsrp           a2ThresholdhoSsbRsrp            a2-Threshold rsrp :
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_NRCELL-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
