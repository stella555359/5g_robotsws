*** Settings ***
Documentation           Suite description

Resource                ../Setup.robot
Resource                ../Oam.robot
Resource                ../Tools.robot
# RDH RF50: Library                 ../../../../RRM/ET/resources/python/robot_extension.py   WITH NAME       robot_extension


Suite Setup             Suite Setup from scratch    listBackupFiles=${FD_ALL}
...                                                 keepAllUeDataInCfgFile=${True}

Suite Teardown          Suite Teardown

*** Variables ***
#8940  PM counters
&{8940_Num_PRBs_6_layers_MU_MIMO_DL}      PM_ID=M55308C34009
...                                         CELL_1_Expected=9000000
...                                         CELL_2_Expected=0
...                                         CELL_3_Expected=0


*** Test Cases ***
Test Of New KW
    [Tags]                  DEBUG
    Dated Log New Line                          Test KW "Run Keyword And Warn On Failure"
    Check 8940 PM Counters Expected values      ${8940_Num_PRBs_6_layers_MU_MIMO_DL}
    Dated Log New Line                          End of Test


*** Keywords ***
Check 8940 PM Counters Expected values
    [Documentation]                 To Check 8940 PM counter values are as exepected
    [Arguments]                     ${8940_PM_Counters_Expected}

    Dated Log New Line              Case 1: The counter value is set beyond the max value : 20031963
    ${Value_PM_Counter_Cell_1}      set variable    20031963
# RDH RF50:     ${status}    ${message}         robot_extension.Run Keyword And Warn On Failure
# RDH RF50:
    ${status}    ${message}         BuiltIn.Run Keyword And Warn On Failure
    ...                                 Compare Counters to Reference       value=${Value_PM_Counter_Cell_1}
    ...                                                                     reference=${8940_PM_Counters_Expected.CELL_1_Expected}
    ...                                                                     pm_name=${8940_PM_Counters_Expected.PM_ID}
    ...                                                                     cell=1
    ...                                                                     delta=35
    Run keyword if                  '${status}'=='FAIL'
    ...                             Dated Log                               >>> INCORRECT VALUE FOR COUNTER - PLEASE TAKE ACTION TO UNDERSTAND WHY !

    Dated Log New Line              Case 2: The counter value is set below the min value : 2321991
    ${Value_PM_Counter_Cell_1}      set variable    5061994
# RDH RF50:     ${status}    ${message}         robot_extension.Run Keyword And Warn On Failure
# RDH RF50:
    ${status}    ${message}         BuiltIn.Run Keyword And Warn On Failure
    ...                                 Compare Counters to Reference       value=${Value_PM_Counter_Cell_1}
    ...                                                                     reference=${8940_PM_Counters_Expected.CELL_1_Expected}
    ...                                                                     pm_name=${8940_PM_Counters_Expected.PM_ID}
    ...                                                                     cell=1
    ...                                                                     delta=35
    Run keyword if                  '${status}'=='FAIL'
    ...                             Dated Log                               >>> INCORRECT VALUE FOR COUNTER - PLEASE TAKE ACTION TO UNDERSTAND WHY !

    Dated Log New Line              Case 3: The counter value is set between the min and max values : 9091989
    ${Value_PM_Counter_Cell_1}      set variable    5061994
# RDH RF50:     ${status}    ${message}         robot_extension.Run Keyword And Warn On Failure
# RDH RF50:
    ${status}    ${message}         BuiltIn.Run Keyword And Warn On Failure
    ...                                 Compare Counters to Reference       value=${Value_PM_Counter_Cell_1}
    ...                                                                     reference=${8940_PM_Counters_Expected.CELL_1_Expected}
    ...                                                                     pm_name=${8940_PM_Counters_Expected.PM_ID}
    ...                                                                     cell=1
    ...                                                                     delta=35
    Run keyword if                  '${status}'=='FAIL'
    ...                             Dated Log                               >>> INCORRECT VALUE FOR COUNTER - PLEASE TAKE ACTION TO UNDERSTAND WHY !



Compare Counters to Reference
    [Arguments]        ${value}      ${reference}      ${pm_name}      ${cell}     ${delta}=1

    ${ref_min}         Evaluate       ((100 - ${delta})/100) * ${reference}
    ${ref_max}         Evaluate       ((100 + ${delta})/100) * ${reference}

    Run Keyword If     ${value} >= ${ref_min} and ${value} <= ${ref_max}
    ...                Dated Log
    ...            Value for counter ${pm_name} is correct for cell ${cell} == ref min ${ref_min} < reported value ${value} < ref max ${ref_max} ==
    ...   ELSE IF        ${value} <= ${ref_min}
    ...                  FAIL    Value for counter ${pm_name} is not correct for cell ${cell} == reported value : ${value} < ref min ${ref_min} ==
    ...   ELSE IF        ${value} >= ${ref_max}
    ...                  FAIL    Value for counter ${pm_name} is not correct for cell ${cell} == reported value : ${value} > ref max ${ref_max} ==
