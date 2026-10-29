*** Settings ***
Documentation   This is a keyword file for CB008127 part egate verify
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
    ...        CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_SgNB_addition_using_selected_meas_profile_for_NSA
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify a2 a3 a5 values for UE101
    prepare egate file for verification    ${resultDir}/sgNBadd_UE101.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[1],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[1],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nVerify a2 a3 a5 values for UE102
    prepare egate file for verification    ${resultDir}/sgNBadd_UE102.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[2],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[2],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[2],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[2],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[2],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END
    Log To Console    \nVerify a2 a3 a5 values for UE103
    prepare egate file for verification    ${resultDir}/sgNBadd_UE103.txt
    ${contents}    Get File           ${resultDir}/egate.txt

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_CD_t1.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t1.xml
    ${xpath}   set variable  managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR   ${list}               ${param}                   ${value_name}   IN
    ...   a3MeasSsbRsrp         a3OffsetSsbRsrp            a3-Offset rsrp :
    ...   a5MeasSsbRsrp         a5Threshold1SsbRsrp        a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp         a5Threshold2SsbRsrp        a5-Threshold2 rsrp :
    ...   a2MeashoSsbRsrp       a2ThresholdhoSsbRsrp       a2-Threshold rsrp :
    ...   a2MeasReleaseSsbRsrp  a2ThresholdReleaseSsbRsrp  a2-Threshold rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


verify egate logs t2
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_MeNB_initiated_SgNB_Modification_using_meas_profile
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify a2 a3 a5 values for UE101 sgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE101.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[1],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[1],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nVerify a2 a3 a5 values for UE101 sgNB modification
    prepare egate file for verification    ${resultDir}/egate_log_SgNB_modify.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrq : ${a3MeasSsbRsrq_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrq_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrq_a5Threshold2Ssb}[1],
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrq_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrq : ${a2MeasReleaseSsbRsrq_a2ThresholdReleaseSsb}[1],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END


verify egate logs t3
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CD_Configuration_of_A2_measurement_using_measurement_profile_upon_A1_measurement_report
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify a2 a3 a5 values for UE101 sgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE101.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[1],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[1],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_CD_t3.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t3.xml
    ${xpath}   set variable
    ...  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]/list[@name="a1MeashoSsbRsrp"]/item
    ${SCF_a1ThresholdhoSsbRsrp}   get element text    ${parsed_SCF}   xpath=.//${xpath}/p[@name="a1ThresholdhoSsbRsrp"]
    Log To Console    NRMEASPR_IAF-1/list a1MeashoSsbRsrp/param a1ThresholdhoSsbRsrp has value ${SCF_a1ThresholdhoSsbRsrp}
    ${xpath}   set variable  managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]
    ${SCF_a3OffsetSsbRsrp}   get element text    ${parsed_SCF}   xpath=.//${xpath}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRCELL-1/NRHOIF-1/list a3MeasSsbRsrp/param a3OffsetSsbRsrp has value ${SCF_a3OffsetSsbRsrp}
    ${SCF_a5Threshold1SsbRsrp}   get element text   ${parsed_SCF}   xpath=.//${xpath}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    Log To Console    NRCELL-1/NRHOIF-1/list a5MeasSsbRsrp/param a5Threshold1SsbRsrp has value ${SCF_a5Threshold1SsbRsrp}
    ${SCF_a5Threshold2SsbRsrp}   get element text   ${parsed_SCF}   xpath=.//${xpath}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    Log To Console    NRCELL-1/NRHOIF-1/list a5MeasSsbRsrp/param a5Threshold2SsbRsrp has value ${SCF_a5Threshold2SsbRsrp}

    Log To Console    \nVerify a1 a3 a5 values after A2 measurement
    prepare egate file for verification    ${resultDir}/egate_A2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a1-Threshold rsrp : ${SCF_a1ThresholdhoSsbRsrp},
    ...   a3-Offset rsrp : ${SCF_a3OffsetSsbRsrp},
    ...   a5-Threshold1 rsrp : ${SCF_a5Threshold1SsbRsrp},
    ...   a5-Threshold2 rsrp : ${SCF_a5Threshold2SsbRsrp},
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nVerify a1 a3 a5 values after A1 measurement
    prepare egate file for verification    ${resultDir}/egate_A1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    ${value}   set variable    a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    Log To Console    Check that "${value}" is contained
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}


verify egate logs t4
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_CD_Configuration_of_intraFreq_measurements_during_interMeNB_handover_with_PSCell_change_using_meas_profile
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify a2 a3 a5 values for UE101 sgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE101.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[1],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[1],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_CD_t3.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t4.xml
    ${xpath}   set variable
    ...  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]/list[@name="a1MeashoSsbRsrp"]/item
    ${SCF_a1ThresholdhoSsbRsrp}   get element text    ${parsed_SCF}   xpath=.//${xpath}/p[@name="a1ThresholdhoSsbRsrp"]
    Log To Console    NRMEASPR_IAF-1/list a1MeashoSsbRsrp/param a1ThresholdhoSsbRsrp has value ${SCF_a1ThresholdhoSsbRsrp}
    ${xpath}   set variable  managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]
    ${SCF_a3OffsetSsbRsrp}   get element text    ${parsed_SCF}   xpath=.//${xpath}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    Log To Console    NRCELL-1/NRHOIF-1/list a3MeasSsbRsrp/param a3OffsetSsbRsrp has value ${SCF_a3OffsetSsbRsrp}
    ${SCF_a5Threshold1SsbRsrp}   get element text   ${parsed_SCF}   xpath=.//${xpath}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
    Log To Console    NRCELL-1/NRHOIF-1/list a5MeasSsbRsrp/param a5Threshold1SsbRsrp has value ${SCF_a5Threshold1SsbRsrp}
    ${SCF_a5Threshold2SsbRsrp}   get element text   ${parsed_SCF}   xpath=.//${xpath}/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    Log To Console    NRCELL-1/NRHOIF-1/list a5MeasSsbRsrp/param a5Threshold2SsbRsrp has value ${SCF_a5Threshold2SsbRsrp}

    Log To Console    \nVerify a1 a3 a5 values after A2 measurement
    prepare egate file for verification    ${resultDir}/egate_A2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a1-Threshold rsrp : ${SCF_a1ThresholdhoSsbRsrp},
    ...   a3-Offset rsrp : ${SCF_a3OffsetSsbRsrp},
    ...   a5-Threshold1 rsrp : ${SCF_a5Threshold1SsbRsrp},
    ...   a5-Threshold2 rsrp : ${SCF_a5Threshold2SsbRsrp},
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nVerify a2 a3 a5 values for UE101 eNB and PS-Cell change
    prepare egate file for verification    ${resultDir}/egate_intraLteHo.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrq : ${a3MeasSsbRsrq_a3OffsetSsb}[1],
    ...   a5-Threshold1 rsrq : ${a5MeasSsbRsrq_a5Threshold1Ssb}[1],
    ...   a5-Threshold2 rsrq : ${a5MeasSsbRsrq_a5Threshold2Ssb}[1],
    ...   a2-Threshold rsrq : ${a2MeashoSsbRsrq_a2ThresholdhoSsb}[1],
    ...   a2-Threshold rsrq : ${a2MeasReleaseSsbRsrq_a2ThresholdReleaseSsb}[1],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END


verify egate logs t5
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_CD_Interaction_with_mobility_profiles_and_MFBI_during_PS_cell_change_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t5.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_NRHOIF-1}   set variable   managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]
    ${xpath_NRCELL-2}   set variable   managedObject[@distName="${bts_distName}/NRCELL-2"]

    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE104.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
    ...   a2-Threshold rsrq     a2MeashoSsbRsrq          a2ThresholdhoSsbRsrq
    ...   a2-Threshold rsrp     a2MeasReleaseSsbRsrp     a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_IAF-1 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify incoming inter-gNB PS cell change
    prepare egate file for verification    ${resultDir}/egate_A3_2.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
    ...   a2-Threshold rsrq     a2MeashoSsbRsrq          a2ThresholdhoSsbRsrq
    ...   a2-Threshold rsrp     a2MeasReleaseSsbRsrp     a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_IAF-1 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify A2 Measurement Report
    ${scf_IAF_a1_rsrq}  get element text    ${parsed_SCF}
    ...   xpath=.//${xpath_IAF-1}/list[@name="a1MeashoSsbRsrq"]/item/p[@name="a1ThresholdhoSsbRsrq"]
    ${SCF_NRHOIF1_a3_rsrq}   get element text    ${parsed_SCF}
    ...   xpath=.//${xpath_NRHOIF-1}/list[@name="a3MeasSsbRsrq"]/item/p[@name="a3OffsetSsbRsrq"]
    ${SCF_NRHOIF1_a5_th1_rsrq}   get element text    ${parsed_SCF}
    ...   xpath=.//${xpath_NRHOIF-1}/list[@name="a5MeasSsbRsrq"]/item/p[@name="a5Threshold1SsbRsrq"]
    ${SCF_NRHOIF1_a5_th2_rsrq}   get element text    ${parsed_SCF}
    ...   xpath=.//${xpath_NRHOIF-1}/list[@name="a5MeasSsbRsrq"]/item/p[@name="a5Threshold2SsbRsrq"]

    prepare egate file for verification    ${resultDir}/egate_A2.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a1-Threshold rsrq : ${scf_IAF_a1_rsrq},
    ...   a3-Offset rsrq : ${SCF_NRHOIF1_a3_rsrq},
    ...   a5-Threshold1 rsrq : ${SCF_NRHOIF1_a5_th1_rsrq}
    ...   a5-Threshold2 rsrq : ${SCF_NRHOIF1_a5_th2_rsrq}
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}   msg=not found
    END

    Log To Console    \nVerify intra-gNB PS cell change
    prepare egate file for verification    ${resultDir}/egate_A3_3.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
    ...   a2-Threshold rsrq     a2MeashoSsbRsrq          a2ThresholdhoSsbRsrq
    ...   a2-Threshold rsrp     a2MeasReleaseSsbRsrp     a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_NRCELL-2}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check NRCELL-2 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


verify egate logs t6
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_CD_Interaction_with_MFBI_and_A1_based_traffic_steering_to_preferred_NR_layer_after_SgNB_addition
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t6.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_NRCELL-1}   set variable   managedObject[@distName="${bts_distName}/NRCELL-1"]

    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE104.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrp        IAF-1            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a3-Offset rsrq        NRCELL-1         a3MeasSsbRsrq                  a3OffsetSsbRsrq
    ...   a5-Threshold1 rsrp    IAF-1            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold1 rsrq    NRCELL-1         a5MeasSsbRsrq                  a5Threshold1SsbRsrq
    ...   a5-Threshold2 rsrp    IAF-1            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
    ...   a5-Threshold2 rsrq    NRCELL-1         a5MeasSsbRsrq                  a5Threshold2SsbRsrq
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrq     NRCELL-1         a2MeashoSsbRsrq                a2ThresholdhoSsbRsrq
    ...   a2-Threshold rsrq     NRCELL-1         a2MeasReleaseSsbRsrq           a2ThresholdReleaseSsbRsrq
    ...   a1-Threshold rsrp     IAF-1            a1MeashoPrefNRLayerSsbRsrp     a1ThresholdhoSsbRsrp
    ...   a1-Threshold rsrq     NRCELL-1         a1MeashoPrefNRLayerSsbRsrq     a1ThresholdhoSsbRsrq
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify intra-gNB PS cell change
    prepare egate file for verification    ${resultDir}/egate_A4.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a2-Threshold rsrp     IAF-1            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


verify egate logs t7
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_PX_NSA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t7.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_IEF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]

    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE101.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrp        IAF-1            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IAF-1            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IAF-1            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     IAF-1            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify A2 Measurement Report
    prepare egate file for verification    ${resultDir}/egate_A2.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a1-Threshold rsrp     IAF-1            a1MeashoSsbRsrp                a1ThresholdhoSsbRsrp
    ...   a3-Offset rsrp        IEF-1            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IEF-1            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IEF-1            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


verify egate logs t8
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t8.xml

    ${xpath_IAF-3}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE104.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrp        IAF-3            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IAF-3            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IAF-3            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
    ...   a2-Threshold rsrp     IAF-3            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     IAF-3            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_IEF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]
    Log To Console    \nVerify A2 Measurement Report
    prepare egate file for verification    ${resultDir}/egate_A2.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrp        IAF-1            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IAF-1            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IAF-1            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
    ...   a1-Threshold rsrp     IAF-1            a1MeashoSsbRsrp                a1ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     IAF-1            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
    ...   a3-Offset rsrp        IEF-1            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IEF-1            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IEF-1            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


verify egate logs t9
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_CD_t9.xml

    ${xpath_IAF-3}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE105.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrp        IAF-3            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IAF-3            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IAF-3            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
    ...   a2-Threshold rsrp     IAF-3            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     IAF-3            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    ${xpath_IEF-2}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2"]
    Log To Console    \nVerify A2 Measurement Report
    prepare egate file for verification    ${resultDir}/egate_A2.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a1-Threshold rsrp     IAF-3            a1MeashoSsbRsrp                a1ThresholdhoSsbRsrp
    ...   a3-Offset rsrp        IEF-2            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IEF-2            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IEF-2            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    ${xpath_IAF-2}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2"]
    Log To Console    \nVerify intra HO
    prepare egate file for verification    ${resultDir}/intra_HO.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrp        IAF-2            a3MeasSsbRsrp                  a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    IAF-2            a5MeasSsbRsrp                  a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    IAF-2            a5MeasSsbRsrp                  a5Threshold2SsbRsrp
    ...   a1-Threshold rsrp     IAF-2            a1MeashoSsbRsrp                a1ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     IAF-2            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END
