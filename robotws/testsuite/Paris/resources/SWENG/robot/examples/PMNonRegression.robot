*** Settings ***
Documentation                       KW for PM non regression

Resource                            ../Counters.robot

*** Variables ***
## for PM
${Counter1}     M55112C02001
${expectedVal1}     0
${C_OBJ_ID}         1
&{CSUM_EXPECTED_VAL}    counter=M55601C00001   obj=NRCELL     expectedVal=300
&{CIN_RANGE_EXPECTED_VAL}    counter=M55601C00001   obj=NRCELL     min=400      max=7100
# Aic
&{C30_EXPECTED_VAL}    counter=M55331C00001   obj=NRCELL     objId=1      max=1100
#values
&{C500_EXPECTED_VAL}    counter=M55601C00001   obj=NRCELL     objId=1      max=1100
&{CSUM_DU1_EXPECTED_VAL}    counter=M55601C00001   obj=NRCELL     objId=1      expectedVal=300
&{C40_EXPECTED_VAL}    counter=M55112C00002   obj=NRCELL     objId=1      max=1100

*** Keywords ***
# ===============================================================================================
# KWs for PM
# ===============================================================================================

Step PM Start collect
    Run Keyword If                  ${isAic}                               Run Keywords
    ...                             Dated Log                              AIC --> PM start collect no needed
    ...       AND                   Return From Keyword                    SUCCESS

    ${waitTime}                    set variable                480s
    Traced Sleep                    duration=${waitTime}                    msg=wait PM
    ${pm_path}                      Set Variable                 ${LOG_PATH}/pm_files
    Set Suite Variable              ${pm_path}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${pm_path}
    Set Suite Variable              ${pm_latest}
    Dated log                       pm_path=${pm_path}

Step PM Check Latest
    Run Keyword If                  ${isAic}                               PM Check Latest Aic
    ...     ELSE                    PM Check Latest Classical

PM Check Latest Classical
    ${Value1}=    Counters.Retrieve Latest Single Counter Value From Pm File     ${pm_latest}       ${Counter1}
    Dated log                       counter=${Counter1}
    Dated log                       value_retrieved=${Value1}
    ${i_Value1}=    evaluate      ${Value1}
    ${i_expectedVal1}=    evaluate      ${expectedVal1}
    Dated log                       expected_value=${i_expectedVal1}
    should be true    ${i_Value1} == ${i_expectedVal1}

PM Check Latest Aic
    PM Check Latest Aic vDU
    PM Check Latest Aic vCU

PM Check Latest Aic vDU
    ${Value1}=    Counters.Retrieve Latest Single Counter Value From Pm Files For Object and Id on vDU     &{C30_EXPECTED_VAL}
    Dated log                       value_retrieved=${Value1}
    ${i_Value1}=    evaluate      ${Value1}
    ${i_expectedVal1}=    evaluate      ${expectedVal1}
    Dated log                       expected_value=${i_expectedVal1}
    should be true    ${i_Value1} == ${i_expectedVal1}

PM Check Latest Aic vCU
    ${Value1}=    Counters.Retrieve Latest Single Counter Value From Pm Files For Object and Id on vCU     &{C500_EXPECTED_VAL}
    Dated log                       value_retrieved=${Value1}
    ${i_Value1}=    evaluate      ${Value1}
    ${i_expectedVal1}=    evaluate      ${expectedVal1}
    Dated log                       retrieved_value_should_be_superior_expected_value=${i_expectedVal1}
    should be true    ${i_Value1} > ${i_expectedVal1}

Step PM Check Sum
    Run Keyword If                  ${isAic}                               PM Check Sum Aic
    ...     ELSE                    PM Check Sum Classical

PM Check Sum Classical
    ${Value1}    Counters.Retrieve Counter Sum of Values From Pm Files For Object        ${pm_path}     &{CSUM_EXPECTED_VAL}
    Dated log                       counter=${CSUM_EXPECTED_VAL}[counter]
    Dated log                       value_retrieved=${Value1}
    ${iVal2}=    evaluate      ${CSUM_EXPECTED_VAL}[expectedVal]
    Dated log                      superior_than_expected_value=${iVal2}
    should be true    ${Value1} > ${iVal2}

PM Check Sum Aic
    ${Value1}    Counters.Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU         &{CSUM_DU1_EXPECTED_VAL}
    Dated log                       counter=${CSUM_EXPECTED_VAL}[counter]
    Dated log                       value_retrieved=${Value1}
    ${iVal2}=    evaluate      ${CSUM_EXPECTED_VAL}[expectedVal]
    Dated log                      superior_than_expected_value=${iVal2}
    should be true    ${Value1} > ${iVal2}

Step PM Check In A Range
    Run Keyword If                  ${isAic}                               PM Check Criteria Aic
    ...     ELSE                    PM Check In A Range Classical

PM Check In A Range Classical
    ${Value1}    Counters.Verify Object Counter Sum Of Values In A Range        ${pm_path}     &{CIN_RANGE_EXPECTED_VAL}
    Dated log                       counter=${CIN_RANGE_EXPECTED_VAL}[counter]
    Dated log                       min=${CIN_RANGE_EXPECTED_VAL}[min]
    Dated log                       max=${CIN_RANGE_EXPECTED_VAL}[max]
    Dated log                       Check_result=${Value1}

PM Check Criteria Aic
    ${mycomparison}=        Set Variable         '>='
    ${ret}=      Counters.Check At Least One Value Is In Criteria From Pm Files For Object With ID on vCU
    ...                      ${expectedVal1}       ${mycomparison}         &{C40_EXPECTED_VAL}
    Dated log                       ret=${ret}

Step PM Check In A Range Multi
    ${pm_path}                      Set Variable                 ${LOG_PATH}/pm_files
    ${Value1}    Counters.Verify Object Counter with ID Sum Of Values In A Range Multi        a_pm_path=${pm_path}     &{CIN_RANGE_EXPECTED_VAL}
    Dated log                       counter=${CIN_RANGE_EXPECTED_VAL}[counter]
    Dated log                       min=${CIN_RANGE_EXPECTED_VAL}[min]
    Dated log                       max=${CIN_RANGE_EXPECTED_VAL}[max]
    Dated log                       Check_result=${Value1}

    ${Value1}    Counters.Verify Object Counter with ID Sum Of Values In A Range Multi
    ...                 a_pm_path=${pm_path}    a_pm_obj_id=${NRBTS_ID}      &{CIN_RANGE_EXPECTED_VAL}
    Dated log                       counter=${CIN_RANGE_EXPECTED_VAL}[counter]
    Dated log                       min=${CIN_RANGE_EXPECTED_VAL}[min]
    Dated log                       max=${CIN_RANGE_EXPECTED_VAL}[max]
    Dated log                       Check_result=${Value1}

    ${Value1}    Counters.Verify Object Counter with ID Sum Of Values In A Range Multi
    ...                 a_pm_path=${pm_path}    a_pm_obj_id=${NRBTS_ID}      aicEntity=DU       &{CIN_RANGE_EXPECTED_VAL}
    Dated log                       counter=${CIN_RANGE_EXPECTED_VAL}[counter]
    Dated log                       min=${CIN_RANGE_EXPECTED_VAL}[min]
    Dated log                       max=${CIN_RANGE_EXPECTED_VAL}[max]
    Dated log                       Check_result=${Value1}


