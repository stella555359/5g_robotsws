*** Settings ***
Documentation   This is a keyword file for CB008699-FR2 part egate verify
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


verify egate log FR2
    [Documentation]    [PRIVATE]    verify egate log for
    ...        Partial_admission_control_for_Xn_handover_with_full_RRC_configuration
    ...       :Autor: Sylvia Schneider

    ${parsed_SCF}   parse xml    ${resultDir}/SCF_final_FR2.xml
    ${xpath_IAF-1}  set variable  managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_NRCELL-1}  set variable  managedObject[@distName="${bts_distName}/NRCELL-1"]

    Log To Console    \nVerify UE1 pdu session setup values are taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    prepare egate file for verification    ${resultDir}/egate_log_pdu_setup_UE1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify UE3 pdu session setup values are taken from NRCELL-1
    prepare egate file for verification    ${resultDir}/egate_log_pdu_setup_UE3.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_NRCELL-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify incoming Xn handover UE1 measurement report values taken from NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    prepare egate file for verification    ${resultDir}/egate_log_HO_UE1_cell50_2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${list}                   ${param}                        ${value_name}        IN
    ...   a3MeasSsbRsrp             a3OffsetSsbRsrp                 a3-Offset rsrp :
    ...   a5MeasSsbRsrp             a5Threshold1SsbRsrp             a5-Threshold1 rsrp :
    ...   a5MeasSsbRsrp             a5Threshold2SsbRsrp             a5-Threshold2 rsrp :
       ${SCF_value}   get element text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
       ${search_for}  set variable    ${value_name} ${SCF_value},
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END
    FOR   ${search_for}   IN
    ...   fullConfig true,
    ...   defaultDRB TRUE,
       Log To Console    Check that "${search_for}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_for}
    END

