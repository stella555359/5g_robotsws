*** Settings ***
Documentation   This is a keyword file for CB008127 part egate verify
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

prepare egate file for verification
    [Documentation]    [PRIVATE]    prepare egate file for verification, remove empty lines, strip lines
    ...       :Autor: Shruthi Shivaprasad
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
    ...        G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN
    ...       :Autor: Shruthi Shivaprasad

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

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t1.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t1.xml
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
    prepare egate file for verification    ${resultDir}/egate_A2_101.txt
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


    Log To Console    \nVerify a2 a3 a5 values for UE103
    prepare egate file for verification    ${resultDir}/sgNBadd_UE103.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[3],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[3],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[3],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[3],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[3],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END


    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t1.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t1.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
    ...   a2-Threshold rsrp     a2MeashoSsbRsrp          a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeasReleaseSsbRsrp     a2ThresholdReleaseSsbRsrp
       ${scf_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_text}  set variable   ${search_for} : ${scf_value},
       Log To Console    --check NRMEASPR_IAF-1 value "${search_text}" present
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


    Log To Console    \nVerify a2 a3 a5 values for UE102
    prepare egate file for verification    ${resultDir}/sgNBadd_UE102.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : 0,
    ...   a5-Threshold1 rsrp : 82,
    ...   a5-Threshold2 rsrp : 87,
    ...   a2-Threshold rsrp : 34,
    ...   a2-Threshold rsrp : 37,
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t1.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t1.xml
    ${xpath}   set variable  managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR   ${list}               ${param}                   ${value_name}   IN
    ...   a3MeasSsbRsrp         a3OffsetSsbRsrp            a3-Offset rsrp :
    ...   a5MeasSsbRsrp         a5Threshold1SsbRsrp        a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp         a5Threshold2SsbRsrp        a5-Threshold2 rsrp :
    ...   a2MeashoSsbRsrp       a2ThresholdhoSsbRsrp       a2-Threshold rsrp :
    ...   a2MeasReleaseSsbRsrp  a2ThresholdReleaseSsbRsrp  a2-Threshold rsrp :
       ${scf_value}   get element text    ${parsed_SCF}   xpath=.//${xpath}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${scf_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


verify egate logs t2
    [Documentation]    [PRIVATE]    verify egate log for
    ...        G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN_SPID
    ...       :Autor: Shruthi Shivaprasad

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

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t2.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t2.xml
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
    prepare egate file for verification    ${resultDir}/egate_A2_101.txt
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


    Log To Console    \nVerify a2 a3 a5 values for UE103
    prepare egate file for verification    ${resultDir}/sgNBadd_UE103.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[3],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[3],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[3],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[3],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[3],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END


    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t2.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t2.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
    ...   a2-Threshold rsrp     a2MeashoSsbRsrp          a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeasReleaseSsbRsrp     a2ThresholdReleaseSsbRsrp
       ${scf_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_text}  set variable   ${search_for} : ${scf_value},
       Log To Console    --check NRMEASPR_IAF-1 value "${search_text}" present
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


    Log To Console    \nVerify a2 a3 a5 values for UE102
    prepare egate file for verification    ${resultDir}/sgNBadd_UE102.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : 0,
    ...   a5-Threshold1 rsrp : 82,
    ...   a5-Threshold2 rsrp : 87,
    ...   a2-Threshold rsrp : 37,
    ...   a2-Threshold rsrp : 34,
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t2.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t2.xml
    ${xpath}   set variable  managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR   ${list}               ${param}                   ${value_name}   IN
    ...   a3MeasSsbRsrp         a3OffsetSsbRsrp            a3-Offset rsrp :
    ...   a5MeasSsbRsrp         a5Threshold1SsbRsrp        a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp         a5Threshold2SsbRsrp        a5-Threshold2 rsrp :
    ...   a2MeashoSsbRsrp       a2ThresholdhoSsbRsrp       a2-Threshold rsrp :
    ...   a2MeasReleaseSsbRsrp  a2ThresholdReleaseSsbRsrp  a2-Threshold rsrp :
       ${scf_value}   get element text    ${parsed_SCF}   xpath=.//${xpath}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${scf_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END


verify egate logs t3
    [Documentation]    [PRIVATE]    verify egate log for
    ...        G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN_SPID
    ...       :Autor: Shruthi Shivaprasad

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

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t3.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t3.xml
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
    prepare egate file for verification    ${resultDir}/egate_A2_101.txt
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


    Log To Console    \nVerify a2 a3 a5 values for UE103
    prepare egate file for verification    ${resultDir}/sgNBadd_UE103.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : ${a3MeasSsbRsrp_a3OffsetSsb}[3],
    ...   a5-Threshold1 rsrp : ${a5MeasSsbRsrp_a5Threshold1Ssb}[3],
    ...   a5-Threshold2 rsrp : ${a5MeasSsbRsrp_a5Threshold2Ssb}[3],
    ...   a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[3],
    ...   a2-Threshold rsrp : ${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[3],
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END


    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t3.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t3.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
    ...   a2-Threshold rsrp     a2MeashoSsbRsrp          a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeasReleaseSsbRsrp     a2ThresholdReleaseSsbRsrp
       ${scf_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_text}  set variable   ${search_for} : ${scf_value},
       Log To Console    --check NRMEASPR_IAF-1 value "${search_text}" present
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END


    Log To Console    \nVerify a2 a3 a5 values for UE102
    prepare egate file for verification    ${resultDir}/sgNBadd_UE102.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   a3-Offset rsrp : 0,
    ...   a5-Threshold1 rsrp : 82,
    ...   a5-Threshold2 rsrp : 87,
    ...   a2-Threshold rsrp : 37,
    ...   a2-Threshold rsrp : 37,
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nexpected threshold values from ${resultDir}/SCF_final_G_t3.xml
    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t3.xml
    ${xpath}   set variable  managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR   ${list}               ${param}                   ${value_name}   IN
    ...   a3MeasSsbRsrp         a3OffsetSsbRsrp            a3-Offset rsrp :
    ...   a5MeasSsbRsrp         a5Threshold1SsbRsrp        a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp         a5Threshold2SsbRsrp        a5-Threshold2 rsrp :
    ...   a2MeashoSsbRsrp       a2ThresholdhoSsbRsrp       a2-Threshold rsrp :
    ...   a2MeasReleaseSsbRsrp  a2ThresholdReleaseSsbRsrp  a2-Threshold rsrp :
       ${scf_value}   get element text    ${parsed_SCF}   xpath=.//${xpath}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${scf_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

verify egate logs t4
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_G_Reselection_of measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${expected_measIdToRemoveList}

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t4.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    ${xpath_IEF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]

    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE103.txt
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

    Log To Console    \nVerify A2 Measurement Report UE103
    prepare egate file for verification    ${resultDir}/egate_A2_103.txt
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

    Log To Console    \nVerify A2 Measurement Report UE104
    prepare egate file for verification    ${resultDir}/egate_A2_UE104.txt
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

    Log To Console    \nVerify A1 Measurement Report UE103
    prepare egate file for verification    ${resultDir}/egate_A1_103.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify A1 Measurement Report UE104
    prepare egate file for verification    ${resultDir}/egate_A1_UE104.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify A1 measIdToRemoveList

    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     measIdToRemoveList
    ${temp2}    Fetch from left       ${temp1}        },
    ${temp3}    Replace String   ${temp2}     \n     ${EMPTY}
    ${temp4}    Replace String   ${temp3}     {      ${EMPTY}

    ${all_parts}    Split String      ${temp4}        ,
    ${egate_measIdToRemoveList}    Create List
    FOR    ${part}    IN    @{all_parts}
      Append To List    ${egate_measIdToRemoveList}  ${part}
    END
    ${length_expected}    get length     ${expected_measIdToRemoveList}
    ${length_egateLog}    get length     ${egate_measIdToRemoveList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_expected}     ${length_egateLog}
    ...   number of events in measIdToRemoveList incorrect
    FOR   ${item}   IN      @{expected_measIdToRemoveList}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${egate_measIdToRemoveList}    ${item}   ${item} not present
    END

    Log To Console    \nVerify A2 Measurement Report UE105
    prepare egate file for verification    ${resultDir}/egate_A2_105.txt
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

    Log To Console    \nVerify A1 Measurement Report UE105
    prepare egate file for verification    ${resultDir}/egate_A1_105.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

verify egate logs t5
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB008127_G_Reselection_of measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration_mobility_profile
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${expected_measIdToRemoveList}

    ${parsed_SCF}    parse xml    ${resultDir}/SCF_final_G_t5.xml
    ${xpath_IAF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"]
    ${xpath_IEF-1}   set variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]

    Log To Console    \nVerify SgNB addition
    prepare egate file for verification    ${resultDir}/sgNBadd_UE103.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a3-Offset rsrq        IAF-1            a3MeasSsbRsrq                  a3OffsetSsbRsrq
    ...   a5-Threshold1 rsrq    IAF-1            a5MeasSsbRsrq                  a5Threshold1SsbRsrq
    ...   a5-Threshold2 rsrq    IAF-1            a5MeasSsbRsrq                  a5Threshold2SsbRsrq
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     IAF-1            a2MeasReleaseSsbRsrp           a2ThresholdReleaseSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify A2 Measurement Report UE103
    prepare egate file for verification    ${resultDir}/egate_A2_103.txt
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

    Log To Console    \nVerify A1 Measurement Report UE103
    prepare egate file for verification    ${resultDir}/egate_A1_103.txt
    ${contents}    Get File                ${resultDir}/egate.txt
    FOR   ${search_for}         ${object}        ${list}                        ${param}  IN
    ...   a2-Threshold rsrp     IAF-1            a2MeashoSsbRsrp                a2ThresholdhoSsbRsrp
        ${scf_value}    get element text    ${parsed_SCF}   xpath=.//${xpath_${object}}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  set variable   ${search_for} : ${scf_value},
        Log To Console    --check ${object} value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    \nVerify A1 measIdToRemoveList

    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     measIdToRemoveList
    ${temp2}    Fetch from left       ${temp1}        },
    ${temp3}    Replace String   ${temp2}     \n     ${EMPTY}
    ${temp4}    Replace String   ${temp3}     {      ${EMPTY}

    ${all_parts}    Split String      ${temp4}        ,
    ${egate_measIdToRemoveList}    Create List
    FOR    ${part}    IN    @{all_parts}
      Append To List    ${egate_measIdToRemoveList}  ${part}
    END
    ${length_expected}    get length     ${expected_measIdToRemoveList}
    ${length_egateLog}    get length     ${egate_measIdToRemoveList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_expected}     ${length_egateLog}
    ...   number of events in measIdToRemoveList incorrect
    FOR   ${item}   IN      @{expected_measIdToRemoveList}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${egate_measIdToRemoveList}    ${item}   ${item} not present
    END
