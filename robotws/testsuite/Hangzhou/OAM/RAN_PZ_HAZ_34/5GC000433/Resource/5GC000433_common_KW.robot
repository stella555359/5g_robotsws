*** Settings ***
Documentation     author: Annie.hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000433/Resource/counter_time.py

*** Keywords ***
Modify Energy Consumption Counter Parameter
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify
    ...    Energy Consumption Measurement counter can be reported and updated correctly.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.03.2020 - - Created
    ...    *******************
    ...    Owner_ming-jim.jin@nokia-sbell.com
    [Arguments]    ${actPowerMeter}=true
    ...      ${intervalvalue}=15min
    ...      ${mtSBTSRfmEnergyMonitoring}=mtSBTSRfmEnergyMonitoring
    ...      ${mtSBTSRfModuleInputVoltageMeasurementInt}=mtSBTSRfModuleInputVoltageMeasurementInt
    ...      ${SBTS RF module input voltage measurement interval}=SBTS RF module input voltage measurement interval
    ...      ${SBTS RFM energy monitoring}=SBTS RFM energy monitoring
    #Wait Until Keyword Succeeds    2min    30s    COAM Navigate to login page via webUI
    wait until keyword succeeds    2min    30s    Selenium Login And Disable Screen Lock
    #Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled     abbr=actPowerMeter
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    p_name=actPowerMeter   value=${actPowerMeter}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM energy monitoring   p_name=mtSBTSSmEnergyMonitoring
    ...   value=${intervalvalue}
    append to list  ${modify_params}  ${item}
    ${release}    Get program version based on gNB active version
    ${pnvalue}=   Run Keyword If   "${release}"=="21A"
    ...    Set Variable       ${mtSBTSRfModuleInputVoltageMeasurementInt}
    ...    ELSE    Set Variable     ${mtSBTSRfmEnergyMonitoring}
    ${flitervalue}=   Run Keyword If   "${release}"=="21A"
    ...    Set Variable       ${SBTS RF module input voltage measurement interval}
    ...    ELSE    Set Variable     ${SBTS RFM energy monitoring}
    ${item}=   create dictionary  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=${flitervalue}     p_name=${pnvalue}
    ...    value=${intervalvalue}
    append to list    ${modify_params}    ${item}

    ${filterName}    Set Variable If   "${release}"=="SBTS22R1" or "${release}"=="SBTS22R2"   BTS energy monitoring
    ...    SBTS Energy Consumption
    ${item}=   create dictionary    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=${filterName}    p_name=mtBtsEnergyMonitoring
    ...    value=${intervalvalue}
    append to list  ${modify_params}  ${item}

    #Run Keyword If    '${currect_status}'!='${actPowerMeter}'    Modify Parameters On Webem    modify_params=${modify_params}
    Run keyword and continue on failure    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

Check_Energy_Measurement_Counter
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify
    ...    Energy Consumption Measurement counter can be reported and updated correctly.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.03.2020 - - Created
    ...    *******************
    ...    Owner_ming-jim.jin@nokia-sbell.com
    [Arguments]  ${counterid_list}
    #Modify Energy Consumption Counter Parameter
    #sleep  15min
    ${counter_time}    wait_for_quarters    num_quarters=1
    sleep    1min
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    #connect to common unit master
    run keyword and ignore error    selenium_coam.refresh_page
    #Selenium Login And Disable Screen Lock
    FOR  ${counterid}  IN  @{counterid_list}
         ${counter_value}    Get PM Counter value via Webem with time    counter_id=${counterid}   counter_time=${counter_time}
         ${counter_value}    convert to integer     ${counter_value}
         Should Be True    ${counter_value} >0
    END
    [Teardown]    Selenium Logout And Close Browser


Case Preparation
    log to console   \n*** set precondition: Energy_Consumption activate ***
    Modify Energy Consumption Counter Parameter
    sleep  15min

Check Energy_Measurement_Counter M40002C
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_2C0}    Get PM Counter value via Webem    counter_id=M40002C0    interval=${interval}
	Should be True    ${value_2C0} > 0
    ${value_2C1}    Get PM Counter value via Webem    counter_id=M40002C1    interval=${interval}
    Should be True    ${value_2C1} > 0
	${value_2C2}    Get PM Counter value via Webem    counter_id=M40002C2    interval=${interval}
	Should be True    ${value_2C2} > 0
    selenium logout and close browser

Check Energy_Measurement_Counter M40003C
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
        @{split_version}    string.split string    ${Active_SW_version}    separator=_
        ${stream}    set variable     ${split_version}[0]
        ${count_path}=    Set Variable if   "${stream}"!="SBTS24R1"   MRBTS-${mrbtsID}/EQM-1/APEQM-1
    ...    BTS/MRBTS-${mrbtsID}
	${value_3C0}    Get PM Counter value via Webem    counter_id=M40003C0
        ...     dist_name=${count_path}/RMOD-1/SBTS RFM Energy Monitoring
	...     interval=${interval}
	Should be True    ${value_3C0} > 0
        ${value_3C1}    Get PM Counter value via Webem    counter_id=M40003C1
        ...     dist_name=${count_path}/RMOD-1/SBTS RFM Energy Monitoring
        ...     interval=${interval}
        Should be True    ${value_3C1} > 0
	${value_3C2}    Get PM Counter value via Webem    counter_id=M40003C2
	...     dist_name=${count_path}/RMOD-1/SBTS RFM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_3C2} > 0
	${value_3C3}    Get PM Counter value via Webem    counter_id=M40003C3
	...     dist_name=${count_path}/RMOD-1/SBTS RFM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_3C3} > 0
	${value_3C4}    Get PM Counter value via Webem    counter_id=M40003C4
	...     dist_name=${count_path}/RMOD-1/SBTS RFM Energy Monitoring
	...     interval=${interval}
	Should be True    ${value_3C4} > 0
	${value_3C5}    Get PM Counter value via Webem    counter_id=M40003C5
	...     dist_name=${count_path}/RMOD-1/SBTS RFM Energy Monitoring
	...     interval=${interval}
	Should be True    ${value_3C5} > 0
	${value_3C0}    Get PM Counter value via Webem    counter_id=M40003C0
        ...     dist_name=${count_path}/RMOD-7/SBTS RFM Energy Monitoring
	...     interval=${interval}
	Should be True    ${value_3C0} > 0
        ${value_3C1}    Get PM Counter value via Webem    counter_id=M40003C1
        ...     dist_name=${count_path}/RMOD-7/SBTS RFM Energy Monitoring
        ...     interval=${interval}
        Should be True    ${value_3C1} > 0
	${value_3C2}    Get PM Counter value via Webem    counter_id=M40003C2
	...     dist_name=${count_path}/RMOD-7/SBTS RFM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_3C2} > 0
	${value_3C3}    Get PM Counter value via Webem    counter_id=M40003C3
	...     dist_name=${count_path}/RMOD-7/SBTS RFM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_3C3} > 0
	${value_3C4}    Get PM Counter value via Webem    counter_id=M40003C4
	...     dist_name=${count_path}/RMOD-7/SBTS RFM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_3C4} > 0
	${value_3C5}    Get PM Counter value via Webem    counter_id=M40003C5
	...     dist_name=${count_path}/RMOD-7/SBTS RFM Energy Monitoring
	...     interval=${interval}
	Should be True    ${value_3C5} > 0
        selenium logout and close browser

Check Energy_Measurement_Counter M40004C
     [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
        @{split_version}    string.split string    ${Active_SW_version}    separator=_
        ${stream}    set variable     ${split_version}[0]
        ${count_path}=    Set Variable if   "${stream}"!="SBTS24R1"   MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...    SMOD/SMOD-1/CABINET-1
	${value_4C0}    Get PM Counter value via Webem    counter_id=M40004C0
	...     dist_name=${count_path}/SBTS SM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_4C0} > 0
        ${value_4C1}    Get PM Counter value via Webem    counter_id=M40004C1
        ...   dist_name=${count_path}/SBTS SM Energy Monitoring
        ...   interval=${interval}
        Should be True    ${value_4C1} > 0
	${value_4C2}    Get PM Counter value via Webem    counter_id=M40004C2
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C2} > 0
	${value_4C3}    Get PM Counter value via Webem    counter_id=M40004C3
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C3} > 0
	${value_4C4}    Get PM Counter value via Webem    counter_id=M40004C4
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C4} > 0
	${value_4C5}    Get PM Counter value via Webem    counter_id=M40004C5
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C5} > 0
        ${count_path}=    Set Variable if   "${stream}"!="SBTS24R1"   MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...    SMOD/SMOD-2/CABINET-1
	${value_4C0}    Get PM Counter value via Webem    counter_id=M40004C0
	...    dist_name=${count_path}/SBTS SM Energy Monitoring
	...    interval=${interval}
	Should be True    ${value_4C0} == 0
        ${value_4C1}    Get PM Counter value via Webem    counter_id=M40004C1
    ...   dist_name=${count_path}/SBTS SM Energy Monitoring
    ...   interval=${interval}
    Should be True    ${value_4C1} == 0
	${value_4C2}    Get PM Counter value via Webem    counter_id=M40004C2
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C2} == 0
	${value_4C3}    Get PM Counter value via Webem    counter_id=M40004C3
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C3} == 0
	${value_4C4}    Get PM Counter value via Webem    counter_id=M40004C4
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C4} > 0
	${value_4C5}    Get PM Counter value via Webem    counter_id=M40004C5
	...   dist_name=${count_path}/SBTS SM Energy Monitoring
	...   interval=${interval}
	Should be True    ${value_4C5} > 0
        selenium logout and close browser
Get PM Counter value via Webem
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${counter_id}    ${interval}   ${dist_name}=${None}  ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    ${current_time}   get time from gnb
    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${current_time}     ${end_time}
    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<=0
    ${value}    get_from_dictionary   ${content}    ${last_time}
    [Return]    ${value}
Get PM Counter value via Webem with time
    [Arguments]    ${counter_id}    ${counter_time}   ${dist_name}=${None}    ${counter_type}=BTS
    ...    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${STRING_VAR}    get_from_dictionary    ${content}    ${counter_time}
    ${INT_VAR}    Convert To Integer    ${STRING_VAR}
    [Return]    ${INT_VAR}
