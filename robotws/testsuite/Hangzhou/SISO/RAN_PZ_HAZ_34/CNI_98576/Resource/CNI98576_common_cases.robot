*** Settings ***
Documentation    This is CNI98576 common keywords for CB006519-SR_B1_01_ST-SFP_auto-configuration_after_BTS_reset and
...              CB006519-SR_B2_06_monitoring_Diagnostic_data_for_DWDM_ST-SFP_from_BTS_WebEM
...              Please do not modify the file without notification to author
...              Contact: kaihui.fan@nokia-sbell.com
...              Squard: HZ SG4

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Variables    ../TestData/CNI98576_variables.py

*** Keywords ***
General_SiSo_SFP_auto-configuration_monitoring_Diagnostic_data_after_BTS_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to CB006519 "SFP controlled Fronthaul DWDM Auto-tuning" support
    ...    extended to RF7 (AVQL/E) radio
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.28.2023 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    log to console   Performing BTS Site Reset
    Perform BTS Site Reset
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    @{split_version}    string.split string   ${Active_SW_version}      separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}    Get Information about SFP links
    run keyword and continue on failure   Check SFP Vendor Info And SFP status for ports  ${links}  ${BBMOD}
    run keyword and continue on failure   Check SFP Vendor Info And SFP status for ports   ${links}  ${RMOD}
    run keyword and continue on failure   Check Tunable DWDM Parameters for ports   ${links}  ${BBMOD}
    run keyword and continue on failure   Check Tunable DWDM Parameters for ports   ${links}  ${RMOD}
    run keyword and continue on failure   Check if measurements parameters have a valid value for ports   ${links}  ${BBMOD}
    run keyword and continue on failure   Check if measurements parameters have a valid value for ports   ${links}  ${RMOD}
    # Make Call with all ue attached RU   with_peak=${False}
    # Comment this L3call as L3call with DWDM can be default covered by CB009936-CB012091.
    [Teardown]         Selenium Logout And Close Browser

General_SiSo_SFP_auto-configuration_monitoring_Diagnostic_data_after_RRU_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to CB006519 "SFP controlled Fronthaul DWDM Auto-tuning" support
    ...    extended to RF7 (AVQL/E) radio
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.28.2023 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    log to console   Performing RRU Reset
    Perform RU Module Reset for All RUs
    @{split_version}    string.split string   ${Active_SW_version}      separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}    Get Information about SFP links
    run keyword and continue on failure   Check SFP Vendor Info And SFP status for ports  ${links}  ${BBMOD}
    run keyword and continue on failure   Check SFP Vendor Info And SFP status for ports   ${links}  ${RMOD}
    run keyword and continue on failure   Check Tunable DWDM Parameters for ports   ${links}  ${BBMOD}
    run keyword and continue on failure   Check Tunable DWDM Parameters for ports   ${links}  ${RMOD}
    run keyword and continue on failure   Check if measurements parameters have a valid value for ports   ${links}  ${BBMOD}
    run keyword and continue on failure   Check if measurements parameters have a valid value for ports   ${links}  ${RMOD}
    Specific History Alarm Should Not Exist    fault_id=10    connection=GNB_OAM
    Make Call with all ue attached RU   with_peak=${False}
    [Teardown]         Selenium Logout And Close Browser

Perform RU Module Reset for All RUs
    [Arguments]    ${connection}=GNB_OAM
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    90 sec    5 sec    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Identify the ST-SFPs link port
    [Documentation]
    ...     This keyword identifies the link port ID of ST-SFPs module. "https://jiradc.ext.net.nokia.com/browse/LEOPARD-2001"
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${dwdm_link_list}    Create List
    FOR    ${port}    IN    @{list_of_links}
        ${dwdm_self_tuning_cap}    Get Dictionary Values    ${links["connected"][${port}]["details"]["dwdmParameters"]["dwdmSelfTuningCap"]}
        log to console    ${dwdm_self_tuning_cap}
        ${contains_false}=    Evaluate    False in ${dwdm_self_tuning_cap}
        Run Keyword If    '${contains_false}'=='False'    Append To List    ${dwdm_link_list}    ${port}
    END
    [Return]    ${dwdm_link_list}

Check SFP Vendor Info And SFP status for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}=    Identify the ST-SFPs link port    ${links}    ${dict_of_links}    #Get the list of ST-SFPs link port
    FOR    ${port}    IN    @{list_of_links}
        ${sfp_vendor_info}    Check SFP Vendor Info And SFP status   ${links}    ${dict_of_links}    ${port}
        log   ${sfp_vendor_info}
        log to console     \*SFP vendor info is ${sfp_vendor_info}   *\
    END
    [Return]    ${sfp_vendor_info}

Check SFP Vendor Info And SFP status
    [Arguments]    ${links}    ${dict_of_links}    ${port}    ${connection}=GNB_OAM
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        ${physicalPort_dict}    coam.Get Parameters        ${links["connected"][${port}]["${direction}"]}    physicalPort
        ...    timeout=20    connection=${connection}
        ${vendor_dict}    coam.Get Parameters        ${links["connected"][${port}]["${direction}"]}    vendorName
        ...    timeout=20    connection=${connection}
        ${vendorPartNumber_dict}    coam.Get Parameters        ${links["connected"][${port}]["${direction}"]}    vendorPartNumber
        ...    timeout=20    connection=${connection}
        ${sfp_vendor_info}   Create List   ${physicalPort_dict["physicalPort"]}   ${vendor_dict["vendorName"]}
        ...    ${vendorPartNumber_dict["vendorPartNumber"]}
        Should Not Be Equal As Strings  ${physicalPort_dict["physicalPort"]}   -   AND    Should not be empty   ${physicalPort_dict["physicalPort"]}
        Should Not Be Equal As Strings  ${vendor_dict["vendorName"]}   -   AND    Should not be empty   ${vendor_dict["vendorName"]}
        Should Not Be Equal As Strings  ${vendorPartNumber_dict["vendorPartNumber"]}   -   AND
        ...   Should not be empty   ${vendorPartNumber_dict["vendorPartNumber"]}
        ${physicalportname}  Set Variable   ${physicalPort_dict["physicalPort"]}
        ${portname}   Get Substring   ${physicalportname}   0      -1
        ${physicalPort}   Get Substring   ${physicalportname}  -1
        ${physicalPort_int}   Convert To Integer   ${physicalPort}
        Wait until Keyword Succeeds    2min  30s    Tunable DWDM SFP status Should be enabled   port_name=${portname}
        ...   physical_port=${physicalPort_int}
    END
    [Return]    ${sfp_vendor_info}

Check if measurements parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}=    Identify the ST-SFPs link port    ${links}    ${dict_of_links}    #Get the list of ST-SFPs link port
    FOR    ${port}    IN    @{list_of_links}
        Check if measurements parameters have a valid value for directions   ${links}    ${dict_of_links}    ${port}
    END

Check if measurements parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    ${measurements_prefix}   Set Variable   ${links["connected"][${port}]["data"]["measurements"]}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${TXSupplyVoltage}
        ...    ${measurements_prefix["TXSupplyVoltage"]["${direction}"]}
        Should Not Be Equal As Strings  ${TXSupplyVoltage}   -   AND    Should not be empty   ${TXSupplyVoltage}
        Set Suite Variable   ${TXBiasCurrent}
        ...    ${measurements_prefix["TXBiasCurrent"]["${direction}"]}
        Should Not Be Equal As Strings  ${TXBiasCurrent}[0]   -   AND    Should not be empty   ${TXBiasCurrent}[0]
        Set Suite Variable   ${TXOpticalPowerDBM}
        ...    ${measurements_prefix["TXOpticalPowerDBM"]["${direction}"]}
        Should Not Be Equal As Strings  ${TXOpticalPowerDBM}[0]   -   AND    Should not be empty   ${TXOpticalPowerDBM}[0]
        Set Suite Variable   ${TXOpticalPowerUW}
        ...    ${measurements_prefix["TXOpticalPowerUW"]["${direction}"]}
        Should Not Be Equal As Strings  ${TXOpticalPowerUW}[0]   -   AND    Should not be empty   ${TXOpticalPowerUW}[0]
        Set Suite Variable   ${moduleTemperature}
        ...    ${measurements_prefix["moduleTemperature"]["${direction}"]}
        Should Not Be Equal As Strings  ${moduleTemperature}   -   AND    Should not be empty   ${moduleTemperature}
        Set Suite Variable   ${RXOpticalPowerDBM}
        ...    ${measurements_prefix["RXOpticalPowerDBM"]["${direction}"]}
        Should Not Be Equal As Strings  ${RXOpticalPowerDBM}[0]   -   AND    Should not be empty   ${RXOpticalPowerDBM}[0]
        Set Suite Variable   ${RXOpticalPowerUW}
        ...    ${measurements_prefix["RXOpticalPowerUW"]["${direction}"]}
        Should Not Be Equal As Strings  ${RXOpticalPowerUW}[0]   -   AND    Should not be empty   ${RXOpticalPowerUW}[0]
    END

Check Tunable DWDM Parameters for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}=    Identify the ST-SFPs link port    ${links}    ${dict_of_links}    #Get the list of ST-SFPs link port
    FOR    ${port}    IN    @{list_of_links}
        Check Tunable DWDM Parameters For Directions  ${links}   ${dict_of_links}   ${port}
    END

Check Tunable DWDM Parameters For Directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tunable DWDM parameters with SFPS
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    ${dwdm_parameters_prefix}   Set Variable   ${links["connected"][${port}]["details"]["dwdmParameters"]}
    FOR    ${direction}    IN    @{list_of_directions}
        Check Tunable DWDM Parameters   ${dwdm_parameters_prefix}   ${direction}
    END

Check Tunable DWDM Parameters
    [Documentation]
    ...     This keyword make a for loop to check DWDM parameter is defined value
    [Arguments]   ${link_dwdm_parameters}   ${direction}
    FOR    ${dwdm_parameter_key}    IN    @{DWDM_PARAMETERS_DICT.keys()}
        ${dwdm_parameter_value}   Set Variable   ${link_dwdm_parameters["${dwdm_parameter_key}"]["${direction}"]}
        ${dwdm_reference_value}=    Get From Dictionary   ${DWDM_PARAMETERS_DICT}   ${dwdm_parameter_key}
        Should Be Equal As Strings   ${dwdm_parameter_value}   ${dwdm_reference_value}   ignore_case=True
    END

Tunable DWDM SFP status Should be enabled
    [Documentation]
    ...        check the SFP's status should be enbaled after unlocked
    [Arguments]    ${port_name}=S_RF    ${physical_port}=1
    ${sfp_port_info}=        selenium_coam.get_physical_ports_info   port_name=${port_name}    physical_port=${physical_port}
    ${status}    set variable    ${sfp_port_info}[Status]
    should be equal    ${status}[Operational state]    enabled
    should be equal    ${status}[Administrative state]    Unlocked
    should be equal    ${status}[Usage state]    Active

Make Call with all ue attached RU
    [Arguments]  ${connection}=GNB_OAM   ${duration}=${100}    ${with_peak}=${True}
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${with_peak}    duration=${duration}
        ...    connection=${connection}
    END

Specific History Alarm Should Not Exist
   [Arguments]   ${fault_id}=10       ${connection}=GNB_OAM
   ${historical_alarms}=   coam.get_historic_alarms   connection=${connection}     timeout=100   load_history=${True}
   ${alarm_num}    Get Length    ${historical_alarms}
   ${present_status}    Set Variable    ${False}
   FOR  ${alarm}  IN  @{historical_alarms}
      Exit For Loop If    ${alarm_num}==${0}
      ${present_status}    Run Keyword And Return Status
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}
     Exit For Loop If    ${present_status}
   END
   Run Keyword If    ${present_status}    Fail    faultId ${faultId} is present on gnb.
