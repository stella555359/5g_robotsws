*** Settings ***
Documentation
...    Authors: Kamil Ostrzolek, Kinga Starczan, Aleksandra Radziejewska, Maria Podkalicka
...    Contact: kamil.ostrzolek@nokia.com, kinga.starczan@nokia.com, aleksandra.radziejewska@nokia.com, maria.podkalicka@nokia.com
...    This feature has been introduced to cover SFP and QSFP monitoring that is mainly used for troubleshooting
...    purposes or on new installation in case of SFP/QSFP optical interface problem between (a) Radio Units and BB
...    capacity (b) CU & DU (c) Radio Units. The diagnostics information gives a very good indication of the fibre link
...    quality between (a) radio and RAU (b) CU & DU. This feature supports all types of: SFP/SFP+/SFP28/QSFP which is
...    used by Nokia.

*** Keywords ***

Get SMOD SFP links
    ${links}=    admin.get_sfp_links
    ${notConnected}=    Get from dictionary    ${links}    notConnected
    ${numb_of_links2}=    Get Length    ${notConnected}
    &{SMOD_dict}=    Create dictionary
    @{SMOD}=    Create List
    Set Suite Variable    ${source}    ${links["notConnected"][${0}]["source"]}
    ${source_SMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    SMOD
    Run Keyword If    '${source_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    source
    Set To Dictionary    ${SMOD_dict}    ${0}    ${SMOD}
   [Return]    ${links}    ${SMOD_dict}

Check if static parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${port}     Get From List     ${list_of_links}      0
    Check if static parameters have a valid value for directions for SMOD   ${links}    ${dict_of_links}    ${port}

Check if static parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get from dictionary    ${dict_of_links}    ${port}
    ${direction}=       Get From List       ${list_of_directions}       0
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerHighAlarmThreshold"]["${direction}"]}
    ...    -100
    ...     100
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerLowAlarmThreshold"]["${direction}"]}
    ...    -100
    ...    100
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerHighWarnThreshold"]["${direction}"]}
    ...    -100
    ...    100
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerLowWarnThreshold"]["${direction}"]}
    ...    -100
    ...    100

Check if QSFP or SFP
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${port}     Get From List       ${list_of_links}    0
    ${physicalPort}    Check type of link  ${links}    ${dict_of_links}    ${port}
    [Return]    ${physicalPort}

Check type of link
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check physical port
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get from dictionary    ${dict_of_links}    ${port}
    ${direction}=       Get From List       ${list_of_directions}       0
    ${physicalPort}    admin.Get Parameters        ${links["connected"][${port}]["${direction}"]}    physicalPort
    ${physicalPort}    Get from dictionary    ${physicalPort}    physicalPort
    [Return]    ${physicalPort}

Initiate_SFP_QSFP_Monitoring(invocation_of_the_diagnostic)_for_ABIL(dynamic_data)
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_1}=    Check if dynamic parameters have a valid value for ports    ${links}    ${BBMOD}
    Sleep    60s
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_2}=    Check if dynamic parameters have a valid value for ports    ${links}    ${BBMOD}
    ${identic}    ${value}=    Run Keyword And Ignore Error    Dictionaries Should Be Equal    ${dynamic_1}    ${dynamic_2}
    Should be true    '${identic}' == 'FAIL'

Initiate_SFP_QSFP_monitoring(invocation_of_the_diagnostic)_for_CPRI-N_RU(dynamic_data)
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${physicalPort}    Check if QSFP or SFP  ${links}    ${BBMOD}
    ${dynamic_1}=    Check if dynamic parameters have a valid value for ports for RMOD   ${links}    ${RMOD}    ${physicalPort}
    Sleep    60s
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_2}=    Check if dynamic parameters have a valid value for ports for RMOD  ${links}    ${RMOD}    ${physicalPort}
    ${identic}    ${value}=    Run Keyword And Ignore Error    Dictionaries Should Be Equal    ${dynamic_1}    ${dynamic_2}
    Should be true    '${identic}' == 'FAIL'

Initiate_SFP_QSFP_monitoring(invocation_of_the_diagnostic)_for_CPRI-N_SMOD(dynamic_data)
    ${links}    ${SMOD}=    Get SMOD SFP links
    ${dynamic_1}=   Check if dynamic parameters have a valid value for ports for SMOD   ${links}     ${SMOD}
    Sleep    60s
    ${links}    ${SMOD}=    Get SMOD SFP links
    ${dynamic_2}=    Check if dynamic parameters have a valid value for ports for SMOD  ${links}    ${SMOD}
    ${identic}    ${value}=    Run Keyword And Ignore Error    Dictionaries Should Be Equal    ${dynamic_1}    ${dynamic_2}
    Should be true    '${identic}' == 'FAIL'

Check if dynamic parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check dynamic parameters
     ...    and return it in dictionary to compare whether are refreshed
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${port}     Get From List       ${list_of_links}    0
    &{dynamic_port}=    Create dictionary
    ${dynamic_direction}=    Check if dynamic parameters have a valid value for directions for SMOD  ${links}
    ...    ${dict_of_links}     ${port}
    Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
    [Return]    ${dynamic_port}

Check if dynamic parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check dynamic parameters and return it in dictionary
    [Arguments]    ${links}    ${dict_of_links}     ${port}
    &{dynamic_direction}=    Create dictionary
    @{list_of_dynamic_params}=    Create List
    ${list_of_directions}=    Get from dictionary    ${dict_of_links}    ${port}
    ${direction}=       Get From List       ${list_of_directions}       0
    Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
    Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}    initialDestination
    Set Suite Variable   ${moduleTemperature}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
    Check if given value has a value in proper range   ${moduleTemperature}   20   65
    Set Suite Variable   ${TXSupplyVoltage}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
    Check if given value has a value in proper range   ${TXSupplyVoltage}   2000   4500
    Set Suite Variable   ${TXBiasCurrent}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"]}
    ${TXBiasCurrent}    Convert To String    ${TXBiasCurrent}
    ${TXBiasCurrent}    Remove String    ${TXBiasCurrent}     [
    ${TXBiasCurrent}    Remove String    ${TXBiasCurrent}     ]
    Check if given value has a value in proper range   ${TXBiasCurrent}   0   50
    Set Suite Variable   ${TXOpticalPower}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"]}
    Check if Optical Power Value Is Correct    ${TXOpticalPower}      0    2000
    Set Suite Variable   ${RXOpticalPower}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"]}
    Check if Optical Power Value Is Correct    ${RXOpticalPower}    0    2000
    Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
    ...    ${TXBiasCurrent}    ${RXOpticalPower}
    ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
    Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
    [Return]    ${dynamic_direction}

Check if given value has a value in proper range
    [Arguments]  ${value}  ${lower_bound}  ${higher_bound}
    Should be true  ${lower_bound}<=${value}<=${higher_bound}

Check if Optical Power Value Is Correct
    [Arguments]     ${opticalPower}    ${value_min}    ${value_max}
    FOR    ${index}    IN    @{opticalPower}
         Should be true    ${value_min}<=${index}<=${value_max}
    END

Check if parameters update values
    [Arguments]    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}     ${dynamic_1}
     ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
     ${dynamic_2}=    Check if dynamic parameters have a valid value for ports    ${links}     ${SMOD}
     ${identic}    ${value}=    Run Keyword And Ignore Error    Dictionaries Should Be Equal    ${dynamic_1}    ${dynamic_2}
     Should be true   '${identic}' == 'FAIL'

Check if static data SFP QSFP have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${port}     Get From List     ${list_of_links}      0
    Check if static data SFP QSFP have a valid value for directions for SMOD   ${links}    ${dict_of_links}    ${port}

Check if static data SFP QSFP have a valid value for directions for SMOD
   [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get from dictionary    ${dict_of_links}    ${port}
    ${direction}=       Get From List       ${list_of_directions}       0
    Check SFP Manufactury Date
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["dateCode"]["${direction}"]}
    List Should Contain Value    ${compliance_Code_list}
    ...     ${links["notConnected"][${port}]["details"]["hardwareParameters"]["complianceCode"]["${direction}"]}
    Set Suite Variable   ${vendor}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendor"]["${direction}"]}
    ${pre}    Fetch From Left    ${vendor}    ${SPACE}${SPACE}
    List Should Contain Value    ${vendor_list}      ${pre}
    Check if value is not empty or N/A
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendorPartNumber"]["${direction}"]}
    Check if value is not empty or N/A
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendorRevision"]["${direction}"]}
    Check if value is not empty or N/A
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["serialNumber"]["${direction}"]}
    Check if value is not empty or N/A
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["connectorType"]["${direction}"]}
    ${physicalPort}    admin.Get Parameters        ${links["notConnected"][${port}]["${direction}"]}    physicalPort
    ${physicalPort}    Get from dictionary    ${physicalPort}    physicalPort
    Check if value is not empty or N/A
    ...    ${physicalPort}
    Check if value is not empty or N/A
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["waveLength"]["${direction}"]}
    Check if value is not empty or N/A
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["transmissionRate"]["${direction}"]}

Check if value is not empty or N/A
    [Arguments]  ${value}
    Should Not Be Equal    ${value}    N/A
    Should not be empty    ${value}

Check if temperature parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${port}     Get From List       ${list_of_links}    0
    Check if temperature parameters have a valid value for directions for SMOD   ${links}    ${dict_of_links}    ${port}

Check if temperature parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get from dictionary    ${dict_of_links}    ${port}
    ${direction}=       Get From List       ${list_of_directions}       0
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["temperatureHighAlarmThreshold"]["${direction}"]}
    ...    -128
    ...    128
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["temperatureLowAlarmThreshold"]["${direction}"]}
    ...    -128
    ...    128

Check if Tx parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    ${port}     Get From List       ${list_of_links}    0
    Check if Tx parameters have a valid value for directions for SMOD  ${links}    ${dict_of_links}    ${port}


Check if Tx parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get from dictionary    ${dict_of_links}    ${port}
    ${direction}=       Get From List       ${list_of_directions}       0
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}
    ...    -100
    ...     100
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["${direction}"]}
    ...    -100
    ...     100
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}
    ...    -100
    ...     100
    Check if given value has a value in proper range
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}
    ...    -100
    ...     100

Check SFP Manufactury Date
   [Documentation]
    ...     This keyword check whether it argument is a valid date,
     ...    not older than 01.01.2015 and not newer than from last month
    [Arguments]    ${SFP_QSFP_Manufacturer_Date}
    ${man_year}=    Get Substring    ${SFP_QSFP_Manufacturer_Date}    0    2
    ${man_month}=    Get Substring    ${SFP_QSFP_Manufacturer_Date}    2    4
    ${man_day}=    Get Substring    ${SFP_QSFP_Manufacturer_Date}    4    6
    ${check_if_date_exist}=    Convert Date	    20${man_year}${man_month}${man_day} 00:00:00    exclude_millis=True
    ${man_year}=    Convert To Integer    ${man_year}
    ${man_month}=    Convert To Integer    ${man_month}
    ${current_date}=    Get Current Date    result_format=datetime
    ${short_cyear}=    Evaluate    ${current_date.year}-2000
    Should be true    14<${man_year}<=${short_cyear}
    Run Keyword If    ${man_year}==${short_cyear}    Should be true    ${man_month}<=${current_date.month}

Check quantity of RD files on BTS
    Connect Ssh To Asix
    ssh.Send Command    ls /tmp |grep RD.BTS    connection=asik
    ${files}=    ssh.read_output    connection=asik
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    Should be true    ${num_of_files}>4
    [Teardown]    Disconnect Ssh From Asix

Get snapshot and return parsed RD files
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${snapshot_path}    /home/ute/Downloads/s${time}/Snapshot_${time}.zip
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    admin.get_snapshot    target_file_name=${snapshot_path}
    OperatingSystem.Run    unzip ${snapshot_path} -d ${unzipped}
    ${amia_slot}=    Verify AMIA slot
    ${files}=    OperatingSystem.Run    ls /home/ute/Downloads/s${time}/ | grep _${amia_slot}011_part_
    ${RD_files_list}    Get correct file with PM    ${files}    ${amia_slot}
    ${parsed_files}=    Extract and parse RD files    ${RD_files_list}    ${unzipped_PM}
    [Return]     ${parsed_files}

Verify AMIA slot
    Connect Ssh To Asix
    ${hostname_var}     ssh.execute    command=hostname    connection=asik
    ${amia_slot}        Set Variable If    '${hostname_var.strip()}'=='fct-0a'    1    2
    Disconnect Ssh From Asix
    [Return]    ${amia_slot}

Get correct file with PM
    [Arguments]     ${files}    ${amia_slot}
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    ${second_file}    evaluate    ${num_of_files} - 1
    @{two_last_files}    create list   ${num_of_files}    ${second_file}
    @{RD_files_list}    create list
    FOR    ${no}    IN    @{two_last_files}
        ${PM_file}=    Get Lines Containing String    ${files}    _1011_part_${no}
        OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
        ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep RD.BTS.*xml.gz
        @{RD_files_split_list}=    Split String    ${RD_files}    \n
        ${PMfile}=    get length    ${RD_files_split_list}
        Run Keyword If    ${PMfile}>1    Append to List    ${RD_files_list}    @{RD_files_split_list}
        Exit for loop if    ${RD_files_list}
    END
    [Return]    ${RD_files_list}

Extract and parse RD files
    [Arguments]    ${RD_files_list}    ${unzipped_PM}
    FOR    ${file}    IN    @{RD_files_list}
        Run    gzip -d ${unzipped_PM}/${file}
        ${extracted_file}    Fetch From Left    ${file}    .gz
        ${parsed_files}    Parse Xml    ${unzipped_PM}/${extracted_file}
    END
    [Return]    ${parsed_files}

Get BBMODs info
    ${hw_info}   admin.get_detected_hw_info
    ${bbmod_info}   Create dictionary
    FOR    ${bbmod}   IN   @{hw_info['systemModules']}
        ${SFP}=    Get BBMOD SFP info    ${bbmod}
        Set To Dictionary   ${bbmod_info}    ${bbmod['id']['configuration']}=${SFP}
    END
    [Return]   ${bbmod_info}

Get BBMOD SFP info
     [Arguments]    ${bbmod}
    ${bbmod_SFP_info_list}   Create List
    ${ports}=    Get from dictionary    ${bbmod}    ports
    ${numb_of_ports}=    Get Length    ${ports}
    FOR   ${sfp}   IN RANGE   ${numb_of_ports}
        ${bbmod_SFP_info}=    Fetch From Right    ${ports[${sfp}]['id']['internal']}    BBMOD_R-
        ${bbmod_SFP_info}=    Fetch From Right    ${bbmod_SFP_info}    /
        ${bbmod_SFP_info}=    Remove String    ${bbmod_SFP_info}    _R
        ${SFP_length}    Get Length    ${bbmod_SFP_info}
        Run Keyword If    ${SFP_length}>6    Continue For Loop
        ${physical_port}    Set Variable    ${ports[${sfp}]['label']}
        ${physical_port}    Replace String       ${physical_port}    Q_RF    SFP-
        Append To List    ${bbmod_SFP_info_list}    ${physical_port}
    END
    [Return]   ${bbmod_SFP_info_list}

Get RMODs info
    ${hw_info}   admin.get_detected_hw_info
    ${rmod_info}   Create dictionary
    FOR    ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        ${SFP}=    Get RMOD SFP info    ${rmod}
        Set To Dictionary   ${rmod_info}    ${rmod['id']['configuration']}=${SFP}
    END
    [Return]   ${rmod_info}

Get RMOD SFP info
    [Arguments]    ${rmod}
    ${rmod_SFP_info_list}   Create List
    ${ports}=    Get from dictionary    ${rmod}    ports
    ${numb_of_ports}=    Get Length    ${ports}
    FOR   ${sfp}   IN RANGE   ${numb_of_ports}
        ${rmod_SFP_info}=    Fetch From Right    ${ports[${sfp}]['id']['internal']}    SFP_R-
        ${SFP_length}    Get Length    ${rmod_SFP_info}
        Run Keyword If    ${SFP_length}>1    Continue For Loop
        ${rmod_SFP_info}=    Catenate    SEPARATOR=    SFP-    ${rmod_SFP_info}
        Append To List    ${rmod_SFP_info_list}    ${rmod_SFP_info}
    END
    [Return]   ${rmod_SFP_info_list}

Get SMODs info
    ${hw_info}   admin.get_detected_hw_info
    ${smod_info}   Create dictionary
    FOR    ${smod}   IN   @{hw_info['systemModules']}
        ${SFP}=    Get SMOD SFP info    ${smod}
        Set To Dictionary   ${smod_info}    ${smod['id']['configuration']}=${SFP}
    END
    [Return]   ${smod_info}

Get SMOD SFP info
    [Arguments]    ${smod}
    ${smod_SFP_info_list}   Create List
    ${ports}=    Get from dictionary    ${smod}    ports
    ${numb_of_ports}=    Get Length    ${ports}
    FOR   ${sfp}   IN RANGE   ${numb_of_ports}
        ${smod_SFP_info}=    Fetch From Right    ${ports[${sfp}]['id']['internal']}    SFP_R-
        ${SFP_length}    Get Length    ${smod_SFP_info}
        Run Keyword If    ${SFP_length}>1    Continue For Loop
        ${smod_SFP_info}=    Catenate    SEPARATOR=    SFP-    ${smod_SFP_info}
        Append To List    ${smod_SFP_info_list}    ${smod_SFP_info}
    END
    [Return]   ${smod_SFP_info_list}

Check counters from SFP monitoring- file iteration
    [Arguments]    ${parsed_files}    ${MOD_SFP_dict}    ${measurementType}
    FOR    ${file}    IN    @{parsed_files}
        ${MOD_list}    Get Dictionary Keys    ${MOD_SFP_dict}
        Check counters from SFP monitoring- MOD iteration    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    END

Check counters from SFP monitoring- MOD iteration
    [Arguments]    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    FOR    ${MOD}    IN    @{MOD_list}
        @{SFP_list}    Get From Dictionary    ${MOD_SFP_dict}    ${MOD}
        Should Not Be Empty    ${SFP_list}
        Check counters from SFP monitoring- SFP iteration    ${MOD}    ${file}    ${measurementType}    ${SFP_list}
    END

Check counters from SFP monitoring- SFP iteration
    [Arguments]    ${MOD}    ${file}    ${measT}    ${SFP_list}
    FOR    ${SFP}    IN    @{SFP_list}
        ${status}    Run Keyword And Return Status
    ...    Check counters from SFP monitoring- QSFP vein iteration    ${MOD}    ${file}    ${measT}    ${SFP}
        Exit For Loop If    '${status}'=='True'
    END
        Should Be Equal    '${status}'    'True'

Check counters from SFP monitoring- QSFP vein iteration
    [Arguments]    ${MOD}    ${file}    ${measT}    ${SFP}
    FOR    ${vein}    IN RANGE    1    5
        ${vein}    Set Variable If    '${measT}'=='SFPSM'    ${EMPTY}    ${vein}
        ${TEMPERATURE}    Get Element Text    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}${vein}"]/*[@measurementType="${measT}"]/${measT}_TEMPERATURE
        ${XCVR_TX_SUPPLY_VOLTAGE}    Get Element Text    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}${vein}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_SUPPLY_VOLTAGE
        ${XCVR_TX_BIAS_CURRENT}    Get Element Text    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}${vein}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_BIAS_CURRENT
        ${XCVR_TX_PWR}    Get Element Text    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}${vein}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_PWR
        ${XCVR_RX_OPT_PWR}    Get Element Text    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}${vein}"]/*[@measurementType="${measT}"]/${measT}_XCVR_RX_OPT_PWR
        Should Be True    -128<=${TEMPERATURE}<=128
        Should Be True    0<=${XCVR_TX_SUPPLY_VOLTAGE}<=100
        Should Be True    0<=${XCVR_TX_BIAS_CURRENT}<1000
        Should Be True    -100<=${XCVR_TX_PWR}<=100
        Should Be True    -100<=${XCVR_RX_OPT_PWR}<=100
        Exit For Loop If    '${measT}'=='SFPSM'
    END
