*** Settings ***
Documentation   This is a keyword file for CB008731 force HO part egate verify
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

@{pdsch_ue81_after_irat_and_increase_traffic}      95   1 cell
@{pdsch_ue81_after_attach_all_Ues}                 24   1 cell
@{pdsch_ue81_after_A1_sCelladdition}               95   2 cells
@{pdsch_ue81_after_A2_sCellrelease}                90   1 cell

@{pusch_ue81_after_irat_and_increase_traffic}      18   1 cell
@{pusch_ue81_after_attach_all_Ues}                  7   1 cell
@{pusch_ue81_after_A1_sCelladdition}               18   2 cells
@{pusch_ue81_after_A2_sCellrelease}                15   1 cell


*** Keywords ***

Prepare Egate File For Verification
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


verify egate log force HO
    [Documentation]    [PRIVATE]    verify egate log force HO
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify events pdu setup

    ${parsed_SCF}    Parse Xml      ${resultBaseDir}/SCFC_CB8731_force_HO.xml
    ${xpath_IAF-1}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"]
    ${xpath_IEF-1}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"]
    ${xpath_IRF-1}   Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-1"]

    Prepare Egate File For Verification    ${resultDir}/egate_handover_5G_ue1.txt
    ${contents}    Get File                ${resultDir}/egate.txt

    ${search_HO}  Set Variable    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    Log To Console    --check value "${search_HO}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_HO}

    ${rrc_parts}   Split String    ${contents}    ${search_HO}

    Log To Console    check values in 1st rrcReconfiguration message
    FOR   ${search_for}         ${list}                  ${param}  IN
    ...   a2-Threshold rsrp     a2MeashoSsbRsrp          a2ThresholdhoSsbRsrp
    ...   a2-Threshold rsrp     a2MeasRedirectSsbRsrp    a2ThresholdRedirectSsbRsrp
    ...   a3-Offset rsrp        a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   a5-Threshold1 rsrp    a5MeasSsbRsrp            a5Threshold1SsbRsrp
    ...   a5-Threshold2 rsrp    a5MeasSsbRsrp            a5Threshold2SsbRsrp
        ${scf_value}    Get Element Text    ${parsed_SCF}   xpath=.//${xpath_IAF-1}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  Set Variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_IAF-1 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END

    Log To Console    check values in 2nd rrcReconfiguration message after ueCapabilityInformation
    ${rrc2_parts}   Split String    ${rrc_parts}[1]    ueCapabilityInformation
    ${scf_value}    Get Element Text    ${parsed_SCF}
    ...   xpath=.//${xpath_IAF-1}/list[@name="a1MeashoPrefNRLayerSsbRsrp"]/item/p[@name="a1ThresholdhoSsbRsrp"]
    ${search_for}    Set Variable   a1-Threshold rsrp : ${scf_value},
    Log To Console    --check value "${search_for}" present
    Run Keyword And Continue On Failure   Should Contain   ${rrc2_parts}[2]    ${search_for}


    Log To Console    \nVerify parameter values after A2
    Prepare Egate File For Verification    ${resultDir}/egate_log_A2.txt
    ${contents}    Get File                ${resultDir}/egate.txt

    FOR   ${search_for}         ${object}   ${list}                  ${param}  IN
    ...   a1-Threshold rsrp           IAF         a1MeashoSsbRsrp          a1ThresholdhoSsbRsrp
    ...   a3-Offset rsrp              IEF         a3MeasSsbRsrp            a3OffsetSsbRsrp
    ...   b2-Threshold2EUTRA rsrp     IRF         eutraB2MeashoRsrp        b2Threshold2hoRsrp
        ${scf_value}    Get Element Text    ${parsed_SCF}   xpath=.//${xpath_${object}-1}/list[@name="${list}"]/item/p[@name="${param}"]
        ${search_text}  Set Variable   ${search_for} : ${scf_value},
        Log To Console    --check NRMEASPR_${object}-1 value "${search_text}" present
        Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found
    END
    ${scf_value}    Get Element Text    ${parsed_SCF}   xpath=.//${xpath_IRF-1}/p[@name="b2Threshold1hoRsrp"]
    ${search_text}  Set Variable   b2-Threshold1 rsrp : ${scf_value},
    Log To Console    --check NRMEASPR_IRF-1 value "${search_text}" present
    Run Keyword And Continue On Failure   Should Contain   ${contents}    ${search_text}   msg=not found



Verify Egate Log Force HO TMO
    [Documentation]    [PRIVATE]    verify egate log force HO
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify throughput of UE81
    FOR    ${step}                       ${text}   IN
    ...    irat_and_increase_traffic     IRAT HO and increased traffic
    ...    attach_all_Ues                attach of all UEs
    ...    A1_sCelladdition              sCell addition with A1 measurement
    ...    A2_sCellrelease               sCell release with A2 measurement
        FOR    ${direction}    ${cmd}   IN
        ...    DL              pdsch
        ...    UL              pusch
           Get And Verify Throughput Forced HO TMO   ${direction}    ${cmd}   ${text}    ${step}
        END
    END


Get And Verify Throughput Forced HO TMO
    [Documentation]    [PRIVATE]    get and verify throughput TMO
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${direction}    ${cmd}   ${text}    ${step}
    Log To Console    --- check ${direction} throughput after ${text}
    ${contents}    Get File           ${resultDir}/egate_throughput_${cmd}_ue81_after_${step}.txt
    ${average_throughput}    Get Average Throughput  ${contents}  ${direction}   ${${cmd}_ue81_after_${step}}[1]
    Log To Console    Verify that average_throughput ${direction} is greater than ${${cmd}_ue81_after_${step}}[0] Mbit/s
    ${result}   Set Variable If   ${average_throughput} > ${${cmd}_ue81_after_${step}}[0]  Passed   Failed
    IF    '${result}'=='Failed'
    ...   Run Keyword And Continue On Failure    Fail    failed ${average_throughput} > ${${cmd}_ue81_after_${step}}[0]


Get Average Throughput
    [Documentation]    [PRIVATE]    get average throughput
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${contents}   ${direction}   ${numberOfCells}
    ${line}      Get Lines Containing String     ${contents}     ${numberOfCells}
    @{temp}      Split String                    ${line}
    ${average_throughput}   Set Variable   ${temp}[8]
    Log To Console    average ${direction} throughput ${numberOfCells} is ${average_throughput}
    RETURN   ${average_throughput}

