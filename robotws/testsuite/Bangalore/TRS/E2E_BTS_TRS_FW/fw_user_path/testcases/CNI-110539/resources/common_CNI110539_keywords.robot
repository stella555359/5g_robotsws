*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***

RU not detected after reset
    Run Keyword And Ignore Error   Reset      operation=reset_unit     dist_name=${ERMOD}      reset_type=Hard
    ...     timeout=120    verify_bts=${False}
    Poweroff_RF    RRB1        ${RRB1['PrimaryBTSPortID']}
    BuiltIn.Sleep   250
    verify fault10 supplementary info
    Poweron_RF    RRB1        ${RRB1['PrimaryBTSPortID']}
    BuiltIn.Sleep   500
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

RU was disconnected
    Perform Recommissioning    type=delta    delta_file=${DeleteCablink}        timeout=200    alias=default
    BuiltIn.Sleep   120
    verify fault10 supplementary info2
    Perform Recommissioning    type=delta    delta_file=${AddCablink}        timeout=500    alias=default
    BuiltIn.Sleep    600
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

RU not detected after BTS startup
    Poweroff_RF     RRB1        ${RRB1['PrimaryBTSPortID']}
    BuiltIn.Sleep   100
    Reset Bts       should_be_onair=${False}
    BuiltIn.Sleep   1500
    verify fault10 supplementary info3
    Poweron_RF    RRB1        ${RRB1['PrimaryBTSPortID']}
    BuiltIn.Sleep    500
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

RU connection was lost in runtime
    Poweroff_RF     RRB1        ${RRB1['PrimaryBTSPortID']}
    BuiltIn.Sleep    150
    verify fault10 supplementary info1
    Poweron_RF     RRB1        ${RRB1['PrimaryBTSPortID']}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

Poweroff_RF
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access         remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 0
    BuiltIn.Sleep   120
    [Teardown]  Teardown Remote Access

Poweron_RF
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access         remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 1
    BuiltIn.Sleep   120
    [Teardown]  Teardown Remote Access

verify fault10 supplementary info
    ${output}=  Verify Ems Alarm    config_device=netact       faultid=10      should_exist=${True}          alias=lab1042_omc_user
    Log  ${output}
    ${len}=     Get Length      ${output}
    FOR   ${i}   IN RANGE   0   ${len}
          Log   ${output}[${i}]
          Run Keyword If      ${output}[${i}][FAULT ID]==10  Set Suite Variable      ${supp_info}        ${output}[${i}]
          ${supp_info}=     Exit For Loop IF   ${output}[${i}][FAULT ID]==10
    END
    Log   ${supp_info}[SUPPL ALARM INFO]
    Should contain       ${supp_info}[SUPPL ALARM INFO]    RU not detected after reset

verify fault10 supplementary info1
    ${output}=  Verify Ems Alarm    config_device=netact       faultid=10      should_exist=${True}       alias=lab1042_omc_user
    Log  ${output}
    ${len}=     Get Length      ${output}
    FOR   ${i}   IN RANGE   0   ${len}
          Log   ${output}[${i}]
          Run Keyword If      ${output}[${i}][FAULT ID]==10  Set Suite Variable      ${supp_info}        ${output}[${i}]
          ${supp_info}=     Exit For Loop IF   ${output}[${i}][FAULT ID]==10
    END
    Log   ${supp_info}[SUPPL ALARM INFO]
    Should contain       ${supp_info}[SUPPL ALARM INFO]    RU connection was lost in runtime

verify fault10 supplementary info2
    ${output}=  Verify Ems Alarm    config_device=netact       faultid=10      should_exist=${True}       alias=lab1042_omc_user
    Log  ${output}
    ${len}=     Get Length      ${output}
    FOR   ${i}   IN RANGE   0   ${len}
          Log   ${output}[${i}]
          Run Keyword If      ${output}[${i}][FAULT ID]==10  Set Suite Variable      ${supp_info}        ${output}[${i}]
          ${supp_info}=     Exit For Loop IF   ${output}[${i}][FAULT ID]==10
    END
    Log   ${supp_info}[SUPPL ALARM INFO]
    Should contain       ${supp_info}[SUPPL ALARM INFO]    RU was disconnected

verify fault10 supplementary info3
    ${output}=  Verify Ems Alarm    config_device=netact       faultid=10      should_exist=${True}       alias=lab1042_omc_user
    Log  ${output}
    ${len}=     Get Length      ${output}
    FOR   ${i}   IN RANGE   0   ${len}
          Log   ${output}[${i}]
          Run Keyword If      ${output}[${i}][FAULT ID]==10  Set Suite Variable      ${supp_info}        ${output}[${i}]
          ${supp_info}=     Exit For Loop IF   ${output}[${i}][FAULT ID]==10
    END
    Log   ${supp_info}[SUPPL ALARM INFO]
    Should contain       ${supp_info}[SUPPL ALARM INFO]    RU not detected after BTS startup
