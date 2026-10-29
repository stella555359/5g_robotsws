*** Settings ***
Documentation
    ...     [Procedure]             "This testcase covers check for 10G,1G and 50G SFP"
    ...     [Date]                  "01-09-23"
    ...     [Author]                "Sushma R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "SFP"
    ...     [Feature_ID]            "RP000502,RP000371,CB007839"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-3907"
	...     [Config]    			"Basic SCF with ETHLK-1,2 and 3 connected with 10G,1G,50G SFP respectively"


Suite Setup		Setup Oamops
Suite Teardown	Teardown Oamops

Resource        ${CURDIR}/resources/common_keyword_sfp.robot


*** Variables ***
${counter}         0

*** Test Cases ***
[1]TRS_CB007839 SFP56 port information and paramets
    [Documentation]    This testcase is to verify the SFP functionality of a 50G SFP.
    Preconditions
    ${eifi_ports}=     Split String    ${port_list}
    FOR     ${i}     IN RANGE   0   3
        ${working_port}=    Set Variable        @{eifi_ports}[${i}]
        Set Suite Variable      ${working_port}     ${working_port}
        Vendor Details
    END
    Checking Tx and Rx Power
    Checking Important Parameters   ${all_data_1}   ${product_Code_1}
    Checking Important Parameters   ${all_data_2}    ${product_Code_2}
    Checking Important Parameters   ${all_data_3}    ${product_Code_3}


[1][1.0] TRS_Configuration and Enabling Parameters from Admin for delta changes using 10GBase-SR-RP000502
    [Documentation]    This testcase is to verify the SFP functionality of a 10G SFP,50G SFP with alarms
    ${eifi_ports} =     Split String    ${port_list}
    ${ethlk_mocs}=      Split String    ${moc_list}
    ${switch_ports}=    Split String    ${switch_port_list}
    ${ethlk_mocs_speed}=    Split String    ${moc_speeds_list}
    FOR     ${i}     IN RANGE   0   3
        Perform Recommissioning     type=param  param_path=@{ethlk_mocs}[${i}]:administrativeState   operation=update
        ...     value=unlocked
        Run Keyword if      '${i}'=='0'   Configure Switch    device=BHswitch
        ...     command_profile=disable_ports_@{switch_ports}[${i}]
        Run Keyword if      '${i}'=='1'   Configure Switch    device=EIF2switch
        ...     command_profile=disable_ports_@{switch_ports}[${i}]
        Run Keyword if      '${i}'=='2'   Change on other ASIM Setup    ${make_lock}
        sleep  30
        ${output}=      Verify Alarm     faultid=61029    should_exist=${True}  severity=critical
        Run Keyword If     '${i}'=='0'     Verify Alarm Name  ${output}   ${los_alarm_list}
        Run Keyword if      '${i}'=='0'   Configure Switch    device=BHswitch
        ...     command_profile=enable_ports_@{switch_ports}[${i}]
        Run Keyword If     '${i}'=='1'     Verify Alarm Name  ${output}    ${los_alarm_list_eif2}
        Run Keyword if      '${i}'=='1'   Configure Switch    device=EIF2switch
        ...     command_profile=enable_ports_@{switch_ports}[${i}]
        Run Keyword If     '${i}'=='2'     Verify Alarm Name  ${output}    ${los_alarm_list_eif3}
        Run Keyword if      '${i}'=='2'   Change on other ASIM Setup    ${make_unlock}
        Sleep   60
        Verify Alarm     faultid=61029    should_exist=${False}
        Perform Recommissioning      type=param          param_path=@{ethlk_mocs}[${i}]:speedAndDuplex
        ...     operation=update    value=@{ethlk_mocs_speed}[${i}]
        Run Keyword if      '${i}'=='0'   Configure Switch    device=BHswitch
        ...     command_profile=port_speed_change_@{switch_ports}[${i}]
        Run Keyword if      '${i}'=='1'   Configure Switch    device=EIF2switch
        ...     command_profile=port_speed_change_@{switch_ports}[${i}]
        Run Keyword If      '${i}'=='0'   Verify Alarm     faultid=4679   should_exist=${True}
        Run Keyword If      '${i}'=='0'   Verify Alarm     faultid=61029    should_exist=${True}
        Run Keyword if      '${i}'=='1'   Verify Alarm     faultid=4679   should_exist=${False}
        Run Keyword if      '${i}'=='1'   Verify Alarm     faultid=61029    should_exist=${False}
        Run Keyword if      '${i}'=='2'   Verify Alarm     faultid=61029    should_exist=${True}
        Run Keyword if      '${i}'=='2'   Verify Alarm     faultid=4679   should_exist=${False}
        Perform Recommissioning      type=param     param_path=@{ethlk_mocs}[${i}]:speedAndDuplex   operation=update
        ...     value=AUTODETECT
        Run Keyword if      '${i}'=='0'       Configure Switch    device=BHswitch
        ...     command_profile=port_speed_back_@{switch_ports}[${i}]
        Run Keyword if      '${i}'=='1'       Configure Switch    device=EIF2switch
        ...     command_profile=port_speed_back_@{switch_ports}[${i}]
        sleep   300
        Verify Alarm     faultid=4679   should_exist=${False}
        Verify Alarm     faultid=61029    should_exist=${False}
        Run Keyword If  '${i}'=='2'     Perform Recommissioning      type=param     param_path=ETHLK-3:speedAndDuplex
        ...     operation=update    value=${value_10gbit}
        Run Keyword If  '${i}'=='2'     Change speed on other ASIM setup    ${value_25gbit}
        Run Keyword if  '${i}'=='2'     Verify Alarm     faultid=61029    should_exist=${True}
        Run Keyword If  '${i}'=='2'     Perform Recommissioning      type=param     param_path=ETHLK-3:speedAndDuplex
        ...     operation=update    value=${value_AUTODETECT}
        Run Keyword If  '${i}'=='2'     Change speed on other ASIM setup    ${value_AUTODETECT}
        Sleep   60
        Run Keyword if  '${i}'=='2'     Verify Alarm     faultid=61029    should_exist=${False}
   END
