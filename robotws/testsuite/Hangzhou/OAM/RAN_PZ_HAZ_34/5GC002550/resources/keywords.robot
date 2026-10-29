*** Settings ***
Documentation
...    Authors: Kamil Ostrzolek, Kinga Starczan, Aleksandra Radziejewska
...    Contact: kamil.ostrzolek@nokia.com, kinga.starczan@nokia.com, aleksandra.radziejewska@nokia.com
...    This feature has been introduced to cover SFP and QSFP monitoring that is mainly used for troubleshooting
...    purposes or on new installation in case of SFP/QSFP optical interface problem between (a) Radio Units and BB
...    capacity (b) CU & DU (c) Radio Units. The diagnostics information gives a very good indication of the fibre link
...    quality between (a) radio and RAU (b) CU & DU. This feature supports all types of: SFP/SFP+/SFP28/QSFP which is
...    used by Nokia.

Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    XML    use_lxml=Truee
Library    taf.sbts.oam.coam.admin   WITH NAME   admin
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ul.oam.netact.cm    WITH NAME    netact_lib
Library    taf.pdu    WITH NAME    pdu
Library    2550_resources.py

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
@{compliance_Code_list}  0  SFF_8472_REV_9_3  SFF_8472_REV_9_5  SFF_8472_REV_10_2  SFF_8472_REV_10_4  SFF_8472_REV_11_0
...    SFF_8472_REV_11_3  SFF_8472_REV_11_4  SFF_8472_REV_12_3    SFF_8636_REV_2_7    UNKNOWN    N/A
@{maxTransmissionRate_list}    0    ${None}    ${0}
@{vendor_list}    FINISAR CORP    FINISAR CORP.    SOURCEPHOTONICS    WTD    NOKIA
@{transmissionDistance_list}    None    N/A
@{txPower_list}    None    N/A    ${None}
${MRBTS_ID}=    ${tl.gnbs[0].instance_id}
${comm_timer}=    15 min
${arti}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${gNB_IP_MPLANE_LOCAL}=    192.168.255.1
${gNB_MPLANE_IF_PORT}=     443
${LOG_PATH}=				${CURDIR}/SCF_Directory
${SCF}              TL${tl.gnbs[0].instance_id}.xml
${GN_OAM_ADDR}=                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog      none
${PATH_Storage}    /home/ute/test_results/
${file_num}  7
*** Keywords ***
Preconditions
    Prepare and check TL
    ADMIN CLI connection
    Create Directory    /home/ute/test_results/${OUTPUT_DIR}

Postconditions
    ADMIN CLI disconnection
    Prepare and check TL

Prepare and check TL
    [Tags]      WIP
    [Documentation]    Supported TLs:
    ...    52,55,56,57,58,59,60,145,146,147,148,149,150,191,192,193,194,195,196,601,602
    ADMIN CLI connection
    #set suite variable    ${is_bts_ready}    False
    ${result}    ${release}    Run Keyword And Ignore Error    gnb_classical_hangzhou.Get sw build version
    ${release_result}    run keyword and return status    should contain any
    ...    ${release}
    ...    21A    20B    22R1    22R2    21B
    Set Suite Variable    ${release_result}
    ${is_site_ready}=    run keyword and return status    wait until keyword succeeds  10 min    20 sec
    ...   Check SMOD and BBMOD
    run keyword if    '${is_site_ready}'=='False'    FAIL   BTS is not ready for commissioning
    ${TLstate}=    run keyword and return status    gNB in onAir state
    #run keyword if   ${TLstate}    get and validate scf file
    run keyword if  not ${TLstate}    CI_interface.Common Suite Setup
    Check unwanted alarms
    Check if all RU are enabled
    [Teardown]    Run keywords    ADMIN CLI disconnection    AND
    ...                           Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master

Check unwanted alarms
    [Tags]      WIP
    ${active_alarms}    admin.get_active_alarms    timeout=60
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Perform correct commissioning
    [Tags]      WIP
    ${MRBTS_ID}=    convert to string     ${MRBTS_ID}
    ${upload_SCF}=    proper scf mapping    ${MRBTS_ID}
    ${True}=   convert to boolean   True
    admin.Perform Commissioning
        ...     scf_file=${upload_SCF}
        ...     skip_parameter_relation_errors=${True}
        ...     connection=default
        ...     timeout=900
    set suite variable    ${bts_is_ready}    False
    ${more_time_needed}=    run keyword and return status    variable should exist    ${AZQL}
    run keyword if    '${more_time_needed}'=='True'    set suite variable    ${comm_timer}    30 min
    ${OnAir_State_Reached}=    run keyword and return status    wait until keyword succeeds  ${comm_timer}    1 sec
    ...    Check gNB status after Commm
    run keyword if    '${OnAir_State_Reached}'=='False'    Reset site if OnAir cannot be reached
    run keyword if    '${OnAir_State_Reached}'=='False'    FAIL    OnAir status cannot be achieved

Check SMOD and BBMOD
    Check SMOD
    Check BBMOD

Check SMOD
    ${bts_info}=  admin.get_fsm_info
    set suite variable    ${SMOD_status}    valid
    FOR    ${SMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${SMOD["status"]["operationalState"]}
        Run keyword if  ${release_result}    set suite variable    ${availabilityStatus}
        ...    ${SMOD["status"]["availabilityStatus"]}
        ${enabled}    Set Variable If    ${release_result}    Enabled    enabled
        run keyword if    '${operationalState}'!='${enabled}'    set suite variable    ${SMOD_status}    invalid
        run keyword if    ${release_result}    run keyword if    '${availabilityStatus}'!='Online'
        ...    set suite variable    ${SMOD_status}    invalid
    END
    should be equal as strings  ${SMOD_status}    valid

Check BBMOD
    ${bts_info}=  admin.get_fbb_info
    set suite variable    ${BBMOD_status}    valid
    FOR    ${BBMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${BBMOD["status"]["operationalState"]}
        Run keyword if  ${release_result}
        ...    set suite variable    ${availabilityStatus}    ${BBMOD["status"]["availabilityStatus"]}
        ${enabled}    Set Variable If    ${release_result}    Enabled    enabled
        run keyword if    '${operationalState}'!='${enabled}'    set suite variable    ${BBMOD_status}    invalid
        run keyword if    ${release_result}    run keyword if    '${availabilityStatus}'!='Online'
        ...    set suite variable    ${BBMOD_status}    invalid
    END
    should be equal as strings  ${BBMOD_status}    valid

Check gNB status after Commm
    [Documentation]    This keywords will check: OnAir state, error 23 and 10.
    ${onAir_state}=    run keyword and return status    gNB in onAir state
    run keyword if    '${onAir_state}'=='True'    return from keyword
    ${alarm_list_actual}=    Check unwanted alarms
    ${is_23_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    run keyword if    '${is_23_active}'=='True'    Perform_update
    ${is_10_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    10
    run keyword if    '${is_10_active}'=='True'    Check PDU and set RU power reset
    ${onAir_state_after_check}=    run keyword and return status    gNB in onAir state
    run keyword if    '${onAir_state_after_check}'=='True'    return from keyword
    FAIL    No onAir state

Check if alarm exist
    [Arguments]    ${alarm_list}    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='False'    FAIL

Perform_update
    ${SMOD_version}=    Get SMOD version
    ${actual_SW}=      Get Current Soft version
    ${Downloaded_SW}=        Download Soft           ${actual_SW}    ${SMOD_version}
    Perform Soft Update     ${Downloaded_SW}
    wait until keyword succeeds  10 min    1 min    gNB in onAir state

Get Current Soft version
    ${SW}=              admin.get_sw_version
    ${SW1}=             Replace String      ${SW}       _00000    .
    ${SW2}=             Replace String      ${SW1}      _0000    .
    ${SW3}=             Replace String      ${SW2}      _000     .
    ${SW4}=             Replace String      ${SW3}      _00     .
    ${SW5}=             Replace String      ${SW4}      _0     .
    ${SW6}=             Replace String      ${SW5}      _     .
    ${SW7}=             Fetch From Right    ${SW6}      GNB.
    ${SW8}=             Replace String      ${SW7}      .800.    0.800.
    [Return]            ${SW8}

Get SMOD version
    ${SMOD_name}=    admin.get_fsm_info
    ${SMOD_name}=    set variable    ${SMOD_name[0]["productName"]}
    ${SMOD_name}=    fetch from left    ${SMOD_name}    ${SPACE}
    ${SMOD_name}=    catenate    SEPARATOR=    _    ${SMOD_name}    _ABIL.zip
    [Return]    ${SMOD_name}

Download Soft
    [Arguments]         ${SW_Version}    ${SMOD_version}
    ${version}=         Fetch From Right    ${SW_Version}   .
    ${fetcher}=         Catenate       .${version}
    ${branch}=          Remove String     ${SW_Version}    ${fetcher}
    ${pkg}=             Set Variable If
    ...                 ${branch}==8.1840    .zip
    ...                 ${branch}==0.800     .zip
    ...                 ${branch}==9.1800    .zip
    ...                 ${branch}==10.1800    .zip
    ${sw_name}=         Catenate    AirScale-${SW_Version}${pkg}
    ${sw_url}=          Catenate    sudo wget ${arti}${SW_Version}/${sw_name} -nv -P ${CURDIR}
    ${res}=             Run         ${sw_url}
    [Return]            ${sw_name}

Perform Soft Update
    [Arguments]         ${sw}
    ${sw_name}=             Catenate    ${CURDIR}/${sw}
    admin.update_software     sw_package=${sw_name}     should_activate=True    timeout=1200

Check PDU and set RU power reset
    [Arguments]    ${model}=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}
    ...               ${ip_pdu}=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
    ...               ${port}=${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
    ...               ${version}=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.version}
    run keyword if    "Gude"=="${model}"
    ...    Set Gude PDU power off RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power off RU    ${model}    ${ip_pdu}    ${port}
    sleep    10s
    run keyword if    "Gude"=="${model}"
    ...    Set Gude PDU power on RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power on RU    ${model}    ${ip_pdu}    ${port}
    wait until keyword succeeds    10 min    1 min    Check if RU's is not in disabled state

Set Gude PDU power off RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set PDU power off RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu       model=${model}    host=${host}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set Gude PDU power on RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Set PDU power on RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu       model=${model}    host=${host}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Check if RU's is not in disabled state
    ${bts_info}=  admin.get_frm
    set suite variable    ${RUs_status}    invalid
    FOR    ${RU}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${RU["status"]["operationalState"]}
        ${availabilityStatus}    Set Variable    None
        Run keyword if  ${release_result}    
        ...    set suite variable    ${availabilityStatus}    ${RU["status"]["availabilityStatus"]}
        ${disabled}    Set Variable If    ${release_result}    Disabled    disabled
        ${notinstalled}    Set Variable If    ${release_result}    NotInstalled    not installed
        run keyword if    '${operationalState}'!='${disabled}'    set suite variable    ${RUs_status}    valid
        run keyword if    '${availabilityStatus}'!='${notinstalled}'    set suite variable    ${RUs_status}    valid
    END
    should not be equal as strings  ${RUs_status}    invalid

Reset site if OnAir cannot be reached
    [Documentation]    This keyword will trigger site reset when OnAir state cannot be achieved and faults 10 and 23
    ...    wasn't found
    Reset site via webUI
    ${OnAir_lc}=    run keyword and return status    wait until keyword succeeds    5 min    1 min    gNB in onAir state
    run keyword if    '${OnAir_lc}'=='True'    set suite variable    ${OnAir_State_Reached}    True

Check if all RU are enabled
    [Documentation]    This keyword will check status of all RU's. If more than one will have state othe than enabled
    ...   warning log will be created. This keyword will not trigger RMOD reset.
    ${RU_info}=  admin.get_frm
    ${list_of_disabled_RUs}=    Create list
    FOR     ${RU}    IN    @{RU_info}
        set suite variable    ${valid}    True
        set suite variable    ${RU_number}    ${RU["id"]["configuration"]}
        ${RU_number}=    Fetch from right    ${RU_number}    /
        set suite variable    ${operationalState}    ${RU["status"]["operationalState"]}
        Run keyword if  ${release_result}
        ...    set suite variable    ${availabilityStatus}    ${RU["status"]["availabilityStatus"]}
        ${enabled}    Set Variable If    ${release_result}    Enabled    enabled
        run keyword if    '${operationalState}'!='${enabled}'    set suite variable    ${valid}    False
        Run keyword if  ${release_result}    run keyword if    '${availabilityStatus}'!='Online'
        ...    set suite variable    ${valid}    False
        run keyword if    '${valid}'=='False'    append to list    ${list_of_disabled_RUs}    ${RU_number}
    END
    ${empty_RU_list}=    run keyword and return status    should be empty    ${list_of_disabled_RUs}
    run keyword if    '${empty_RU_list}'=='False'    run keywords    
    ...    log   Not all RUs were enabled. List of malfunction RUs:
    ...    level=WARN    AND    log list    ${list_of_disabled_RUs}    level=WARN
    
Get SMOD SFP links
    ${links}=    admin.get_sfp_links
    ${notConnected}=    Get From Dictionary    ${links}    notConnected
    ${numb_of_links2}=    Get Length    ${notConnected}
    &{SMOD_dict}=    Create Dictionary
    FOR    ${x}    IN RANGE    ${numb_of_links2}
        @{SMOD}=    Create List
        Set Suite Variable    ${source}    ${links["notConnected"][${x}]["source"]}
        ${source_SMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    SMOD
        Run Keyword If    '${source_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    source
        Set To Dictionary    ${SMOD_dict}    ${x}    ${SMOD}
    END
   [Return]    ${links}    ${SMOD_dict}

Get Information about SFP links
    [Documentation]
    ...     This keyword create 3 dictionaries, where a key is a number of a link and a values
    ...     are directions (source/destination or both)
    ${links}=    admin.get_sfp_links
    ${connected}=    Get From Dictionary    ${links}    connected
    ${numb_of_links}=    Get Length    ${connected}
    &{SMOD_dict}=    Create Dictionary
    &{BBMOD_dict}=    Create Dictionary
    &{RMOD_dict}=    Create Dictionary
    FOR    ${x}    IN RANGE    ${numb_of_links}
        @{SMOD}=    Create List
        @{BBMOD}=    Create List
        @{RMOD}=    Create List
        Set Suite Variable    ${source}    ${links["connected"][${x}]["source"]}
        Set Suite Variable    ${destination}    ${links["connected"][${x}]["destination"]}
        ${source_SMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    SMOD
        ${source_BBMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    BBMOD
        ${source_RMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    RMOD
        ${destiny_SMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${destination}    SMOD
        ${destiny_BBMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${destination}    BBMOD
        ${destiny_RMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${destination}    RMOD
        Run Keyword If    '${source_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    source
        Run Keyword If   '${source_BBMOD_match}' == 'PASS'    Append To List    ${BBMOD}    source
        Run Keyword If    '${source_RMOD_match}' == 'PASS'    Append To List    ${RMOD}    source
        Run Keyword If    '${destiny_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    destination
        Run Keyword If   '${destiny_BBMOD_match}' == 'PASS'    Append To List    ${BBMOD}    destination
        Run Keyword If    '${destiny_RMOD_match}' == 'PASS'    Append To List    ${RMOD}    destination
        Set To Dictionary    ${RMOD_dict}    ${x}    ${RMOD}
        Set To Dictionary    ${BBMOD_dict}    ${x}    ${BBMOD}
        Set To Dictionary    ${SMOD_dict}    ${x}    ${SMOD}
        Set Suite Variable    ${source_SMOD_match}    'FAIL'
        Set Suite Variable    ${source_BBMOD_match}    'FAIL'
        Set Suite Variable    ${source_RMOD_match}    'FAIL'
        Set Suite Variable    ${destiny_SMOD_match}    'FAIL'
        Set Suite Variable    ${destiny_BBMOD_match}    'FAIL'
        Set Suite Variable    ${destiny_RMOD_match}    'FAIL'
    END
    [Return]    ${links}    ${SMOD_dict}    ${BBMOD_dict}    ${RMOD_dict}

Check if static parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if static parameters have a valid value for directions   ${links}    ${dict_of_links}    ${port}
    END
    
Check if static parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${rxPowerHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerHighAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerHighAlarmThreshold}<=100
        Set Suite Variable   ${rxPowerLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerLowAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerLowAlarmThreshold}<=100
        Set Suite Variable   ${rxPowerHighWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerHighWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerHighWarnThreshold}<=100
        Set Suite Variable   ${rxPowerLowWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerLowWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerLowWarnThreshold}<=100
    END
    
Check if optical power value is correct
    [Arguments]    ${opticalPower}    ${value_min}    ${value_max}
    FOR    ${index}    IN    @{opticalPower}
        Should be True    ${value_min}<=${index}<=${value_max}
    END
    
Check if dynamic parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check dynamic parameters
     ...    and return it in dictionary to compare whether are refreshed
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    &{dynamic_port}=    Create Dictionary
    FOR    ${port}    IN    @{list_of_links}
        ${dynamic_direction}=    Check if dynamic parameters have a valid value for directions   ${links}
    ...    ${dict_of_links}    ${port}
        Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
    END
    [Return]    ${dynamic_port}

Check if dynamic parameters have a valid value for directions
   [Documentation]
    ...   This keyword make a for loop to select a proper direction to check dynamic parameters and return it in dictionary
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    &{dynamic_direction}=    Create Dictionary
    @{list_of_dynamic_params}=    Create List
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
        Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}
        ...    initialDestination
        Set Suite Variable   ${moduleTemperature}
    ...    ${links["connected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
        Should Be True  20<=${moduleTemperature}<=70
        Set Suite Variable   ${TXSupplyVoltage}
    ...    ${links["connected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
        Should Be True  2000<=${TXSupplyVoltage}<=4500
        Set Suite Variable   ${TXBiasCurrent}
    ...    ${links["connected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"]}
        ${TXBiasCurrent}    2550_resources.Get parameter value    ${TXBiasCurrent}
        Should Be True  0<=${TXBiasCurrent}<=50
        Set Suite Variable   ${TXOpticalPower}
    ...    ${links["connected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"]}
        Check if optical power value is correct     ${TXOpticalPower}    100    2000
        Set Suite Variable   ${RXOpticalPower}
    ...    ${links["connected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"]}
        Check if optical power value is correct    ${RXOpticalPower}    100    2000
        Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
    ...    ${TXBiasCurrent}    ${RXOpticalPower}
    ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
        Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
    END
    [Return]    ${dynamic_direction}

Check if static data SFP QSFP have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if static data SFP QSFP have a valid value for directions   ${links}    ${dict_of_links}    ${port}
    END
    
Check if static data SFP QSFP have a valid value for directions
   [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${SFP_QSFP_Manufacturer_Date}
    ...    ${links["connected"][${port}]["details"]["staticParameters"]["dateCode"]["${direction}"]}
        Check SFP Manufactury Date    ${SFP_QSFP_Manufacturer_Date}
        Set Suite Variable   ${compliance_Code}
    ...    ${links["connected"][${port}]["details"]["hardwareParameters"]["complianceCode"]["${direction}"]}
        List Should Contain Value    ${compliance_Code_list}      ${compliance_Code}
        Set Suite Variable   ${vendor}
    ...    ${links["connected"][${port}]["details"]["hardwareParameters"]["vendor"]["${direction}"]}
        ${pre}    Fetch From Left    ${vendor}    ${SPACE}${SPACE}
        List Should Contain Value    ${vendor_list}      ${pre}
        Set Suite Variable   ${vendorPartNumber}
    ...    ${links["connected"][${port}]["details"]["hardwareParameters"]["vendorPartNumber"]["${direction}"]}
        Should Not Be Equal    ${vendorPartNumber}    N/A
        Should not be empty    ${vendorPartNumber}
        Set Suite Variable   ${vendorRevision}
    ...    ${links["connected"][${port}]["details"]["hardwareParameters"]["vendorRevision"]["${direction}"]}
        Should Not Be Equal    ${vendorRevision}    N/A
        Should Not Be Empty    ${vendorRevision}
        Set Suite Variable   ${serialNumber}
    ...    ${links["connected"][${port}]["details"]["hardwareParameters"]["serialNumber"]["${direction}"]}
        Should Not Be Equal    ${serialNumber}    N/A
        Should Not Be Empty    ${serialNumber}
        Set Suite Variable    ${connectorType}
    ...    ${links["connected"][${port}]["details"]["hardwareParameters"]["connectorType"]["${direction}"]}
        Should Not Be Equal    ${connectorType}    N/A
        Should Not Be Empty    ${connectorType}
        ${physicalPort}    admin.Get Parameters        ${links["connected"][${port}]["${direction}"]}    physicalPort
        ${physicalPort}    Get From Dictionary    ${physicalPort}    physicalPort
        Should Not Be Equal    ${physicalPort}    N/A
        Should Not Be Empty    ${physicalPort}
        Set Suite Variable   ${waveLength}
    ...    ${links["connected"][${port}]["details"]["staticParameters"]["waveLength"]["${direction}"]}
        Should Not Be Equal    ${waveLength}    N/A
        Should Not Be Empty    ${waveLength}
        Set Suite Variable   ${transmissionMode}
    ...    ${links["connected"][${port}]["details"]["staticParameters"]["transmissionMode"]["${direction}"]}
        Should Not Be Empty    ${transmissionMode}
        Set Suite Variable   ${transmissionRate}
    ...    ${links["connected"][${port}]["details"]["staticParameters"]["transmissionRate"]["${direction}"]}
        Should Not Be Equal    ${transmissionRate}    N/A
        Should Not Be Empty    ${transmissionRate}
    END

Check if temperature parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if temperature parameters have a valid value for directions   ${links}    ${dict_of_links}    ${port}
    END
    
Check if temperature parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${temperatureHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["temperatureHighAlarmThreshold"]["${direction}"]}
        Should Be True  -128<=${temperatureHighAlarmThreshold}<=128
        Set Suite Variable   ${temperatureLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["temperatureLowAlarmThreshold"]["${direction}"]}
        Should Be True  -128<=${temperatureLowAlarmThreshold}<=128
    END
    
Check if Tx parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if Tx parameters have a valid value for directions   ${links}    ${dict_of_links}    ${port}
    END
    
Check if Tx parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${txPowerHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerHighAlarmThreshold}<=100
        Set Suite Variable   ${txPowerLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerLowAlarmThreshold}<=100
        Set Suite Variable   ${txPowerHighWarnThreshold}
      ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerHighWarnThreshold}<=100
        Set Suite Variable   ${txPowerLowWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerLowWarnThreshold}<=100
    END
    
Check if Tx parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if Tx parameters have a valid value for directions for SMOD   ${links}    ${dict_of_links}    ${port}
    END
    
Check if Tx parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${txPowerHighAlarmThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerHighAlarmThreshold}<=100
        Set Suite Variable   ${txPowerHighAlarmThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["unit"]}
        Log                   \ntxPowerHighAlarmThreshold ${txPowerHighAlarmThreshold} ${txPowerHighAlarmThresholdunit}
        Set Suite Variable   ${txPowerLowAlarmThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerLowAlarmThreshold}<=100
        Set Suite Variable   ${txPowerLowAlarmThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["unit"]}
        Log                   \ntxPowerLowAlarmThreshold ${txPowerLowAlarmThreshold} ${txPowerLowAlarmThresholdunit}
        Set Suite Variable   ${txPowerHighWarnThreshold}
      ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerHighWarnThreshold}<=100
        Set Suite Variable   ${txPowerHighWarnThresholdunit}
      ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["unit"]}
        Log                   \ntxPowerHighWarnThreshold ${txPowerHighWarnThreshold} ${txPowerHighWarnThresholdunit}
        Set Suite Variable   ${txPowerLowWarnThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerLowWarnThreshold}<=100      
        Set Suite Variable   ${txPowerLowWarnThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["unit"]}
        Log                   \ntxPowerLowWarnThreshold ${txPowerLowWarnThreshold} ${txPowerLowWarnThresholdunit}
    END

Check quantity of RD files on BTS
    Connect Ssh To Asix
    ssh.Send Command    ls /tmp |grep RD.BTS.*xml.gz    connection=asik
    ${files}=    ssh.read_output    connection=asik
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    Should Be True    ${num_of_files}>4
    [Teardown]    Disconnect Ssh From Asix
Get snapshot and return parsed RD files
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${snapshot_path}    /home/ute/Downloads/s${time}/Snapshot_${time}.zip
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    admin.get_snapshot    target_file_name=${snapshot_path}
    OperatingSystem.Run    unzip ${snapshot_path} -d ${unzipped}
    ${amia_slot}=    Verify AMIA slot
    ${va}  set variable  /home/ute/Downloads/s${time}/snapshot_file_list.txt | head -10| grep _${amia_slot}011_part_
    ${files_tmp}  OperatingSystem.Run  grep -B 10 RD.BTS.*xml.gz ${va}
    # ${file_tmp}  Set Variable  ${files_tmp.split("\r\n")[0]}
    ${files}  Fetch From Left  ${files_tmp}  :
    ${RD_files_list}    Get correct file with PM    ${files}
    ${parsed_files}=    keywords.Extract and parse RD files    ${RD_files_list}    ${unzipped_PM}
    [Return]     ${parsed_files}

Get correct file with PM
    [Arguments]     ${files}
    @{RD_files_list}    create list
    OperatingSystem.Run    unzip ${unzipped}/${files} -d ${unzipped_PM}
    ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep RD.BTS.*xml.gz
    @{RD_files_split_list}=    Split String    ${RD_files}    \n
    ${PMfile}=    get length    ${RD_files_split_list}
    Run Keyword If    ${PMfile}>1    Append to List    ${RD_files_list}    @{RD_files_split_list}
    [Return]    ${RD_files_list}

Extract and parse RD files
    [Arguments]    ${RD_files_list}    ${unzipped_PM}
    FOR    ${file}    IN    @{RD_files_list}
        Run    gzip -d ${unzipped_PM}/${file}
        ${extracted_file}    Fetch From Left    ${file}    .gz
        ${parsed_files}    XML.Parse Xml    ${unzipped_PM}/${extracted_file}
    END
    [Return]    ${parsed_files}
Check counters from SFP monitoring- file iteration
    [Arguments]    ${parsed_files}    ${MOD_SFP_dict}    ${measurementType}
    FOR    ${file}    IN    @{parsed_files}
        ${MOD_list}    Get Dictionary Keys    ${MOD_SFP_dict}
        keywords.Check counters from SFP monitoring- MOD iteration    ${MOD_SFP_dict}    ${MOD_list}    ${file}
        ...    ${measurementType}
    END

Check counters from SFP monitoring- MOD iteration
    [Arguments]    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    FOR    ${MOD}    IN    @{MOD_list}
        @{SFP_list}    Get From Dictionary    ${MOD_SFP_dict}    ${MOD}
        keywords.Check counters from SFP monitoring- SFP iteration    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measurementType}
        ...    ${SFP_list}
    END

Check counters from SFP monitoring- SFP iteration
    [Arguments]    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measT}    ${SFP_list}
    FOR    ${SFP}    IN    @{SFP_list}
        #Run Keyword If  '/RMOD' in '${MOD}'  Set Test Variable  ${SFP}  ${SFP}/LANE-1 
        @{TEMPERATURE}    XML.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_TEMPERATURE
        @{XCVR_TX_SUPPLY_VOLTAGE}    XML.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_SUPPLY_VOLTAGE
        @{XCVR_TX_BIAS_CURRENT}    XML.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_BIAS_CURRENT
        @{XCVR_TX_PWR}    XML.Get Elements Texts    ${file}
    ...   //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_PWR
        @{XCVR_RX_OPT_PWR}    XML.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_RX_OPT_PWR
        Run keyword if  ${release_result}    Should Be True    -128<=${TEMPERATURE[0]}<=128
        Should Be True    0<=${XCVR_TX_SUPPLY_VOLTAGE[0]}<=100
        Run keyword if  ${release_result}    Should Be True    0<=${XCVR_TX_BIAS_CURRENT[0]}<1000
        Run keyword if  ${release_result}    Should Be True    -100<=${XCVR_TX_PWR[0]}<=100
        Run keyword if  ${release_result}    Should Be True    -100<=${XCVR_RX_OPT_PWR[0]}<=100
    END
     
Get BBMODs info
    [Arguments]
    ${hw_info}   admin.get_detected_hw_info
    ${bbmod_info}   Create Dictionary
    FOR    ${bbmod}   IN   @{hw_info['basebandModules']}
        ${SFP}=    Get BBMOD SFP info    ${bbmod}
        Continue For Loop If    '${bbmod['status']['usageState']}'=='Idle'
        Set To Dictionary   ${bbmod_info}    ${bbmod['id']['configuration']}=${SFP}
    END
    [Return]   ${bbmod_info}

Get BBMOD SFP info
    [Arguments]    ${bbmod}
    ${bbmod_SFP_info_list}   Create List
    ${ports}=    Get From Dictionary    ${bbmod}    ports
    ${numb_of_ports}=    Get Length    ${ports}
    FOR   ${sfp}   IN RANGE   ${numb_of_ports}
        ${bbmod_SFP_info}=    Fetch From Right    ${ports[${sfp}]['id']['internal']}    BBMOD_R-
        ${bbmod_SFP_info}=    Fetch From Right    ${bbmod_SFP_info}    /
        ${bbmod_SFP_info}=    Remove String    ${bbmod_SFP_info}    _R
        ${SFP_length}    Get Length    ${bbmod_SFP_info}
        Run Keyword If    ${SFP_length}>6    Continue For Loop
        Append To List    ${bbmod_SFP_info_list}    ${bbmod_SFP_info}
    END
    [Return]   ${bbmod_SFP_info_list}

Get RMODs info
    [Arguments]
    ${hw_info}   admin.get_detected_hw_info
    ${rmod_info}   Create Dictionary
    FOR    ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        ${SFP}=    Get RMOD SFP info    ${rmod}
        Set To Dictionary   ${rmod_info}    ${rmod['id']['configuration']}=${SFP}
    END
    [Return]   ${rmod_info}

Verify AMIA slot
    Connect Ssh To Asix
    ${hostname_var}     ssh.execute    command=hostname    connection=asik
    ${amia_slot}        Set Variable If    '${hostname_var.strip()}'=='fct-0a'    1    2
    Disconnect Ssh From Asix
    [Return]    ${amia_slot}

Check if static parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if static parameters have a valid value for directions for SMOD   ${links}    ${dict_of_links}    ${port}
    END

Check if static parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword makes a for loop to select a proper direction
    ...     to verify static parameters values for SMOD.
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${rxPowerHighAlarmThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerHighAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerHighAlarmThreshold}<=100
        Set Suite Variable   ${rxPowerHighAlarmThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerHighAlarmThreshold"]["unit"]}
        Log                   \nrxPowerHighAlarmThreshold ${rxPowerHighAlarmThreshold} ${rxPowerHighAlarmThresholdunit} 
        Set Suite Variable   ${rxPowerLowAlarmThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerLowAlarmThreshold"]["${direction}"]}
        Set Suite Variable   ${rxPowerLowAlarmThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerLowAlarmThreshold"]["unit"]}
        Should Be True  -100<=${rxPowerLowAlarmThreshold}<=100
        Log                   \nrxPowerLowAlarmThreshold ${rxPowerLowAlarmThreshold} ${rxPowerLowAlarmThresholdunit} 
        Set Suite Variable   ${rxPowerHighWarnThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerHighWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerHighWarnThreshold}<=100
        Set Suite Variable   ${rxPowerHighWarnThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerHighWarnThreshold"]["unit"]}
        Log                   \nrxPowerHighWarnThreshold ${rxPowerHighWarnThreshold} ${rxPowerHighWarnThresholdunit}
        Set Suite Variable   ${rxPowerLowWarnThreshold}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerLowWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerLowWarnThreshold}<=100
        Set Suite Variable   ${rxPowerLowWarnThresholdunit}
    ...    ${links["notConnected"][${port}]["details"]["thresholds"]["rxPowerLowWarnThreshold"]["unit"]}
        Log                   \nrxPowerLowWarnThresholdunit ${rxPowerLowWarnThreshold} ${rxPowerLowWarnThresholdunit}
    END

Check if static data SFP QSFP have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        keywords.Check if static data SFP QSFP have a valid value for directions for SMOD   ${links}
        ...    ${dict_of_links}    ${port}
    END

Check if static data SFP QSFP have a valid value for directions for SMOD
   [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${SFP_QSFP_Manufacturer_Date}
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["dateCode"]["${direction}"]}
        Check SFP Manufactury Date    ${SFP_QSFP_Manufacturer_Date}
        Set Suite Variable   ${compliance_Code}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["complianceCode"]["${direction}"]}
        List Should Contain Value    ${compliance_Code_list}      ${compliance_Code}
        Set Suite Variable   ${vendor}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendor"]["${direction}"]}
        ${pre}    Fetch From Left    ${vendor}    ${SPACE}${SPACE}
        List Should Contain Value    ${vendor_list}      ${pre}
        Set Suite Variable   ${vendorPartNumber}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendorPartNumber"]["${direction}"]}
        Should Not Be Equal    ${vendorPartNumber}    N/A
        Should not be empty    ${vendorPartNumber}
        Set Suite Variable   ${vendorRevision}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendorRevision"]["${direction}"]}
        Should Not Be Equal    ${vendorRevision}    N/A
        Should Not Be Empty    ${vendorRevision}
        Set Suite Variable   ${serialNumber}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["serialNumber"]["${direction}"]}
        Should Not Be Equal    ${serialNumber}    N/A
        Should Not Be Empty    ${serialNumber}
        Set Suite Variable    ${connectorType}
    ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["connectorType"]["${direction}"]}
        Should Not Be Equal    ${connectorType}    N/A
        Should Not Be Empty    ${connectorType}
        ${physicalPort}    admin.Get Parameters    ${links["notConnected"][${port}]["${direction}"]}    physicalPort
        ${physicalPort}    Get From Dictionary    ${physicalPort}    physicalPort
        Should Not Be Equal    ${physicalPort}    N/A
        Should Not Be Empty    ${physicalPort}
        Set Suite Variable   ${waveLength}
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["waveLength"]["${direction}"]}
        Should Not Be Equal    ${waveLength}    N/A
        Should Not Be Empty    ${waveLength}
        Set Suite Variable   ${waveLengthunit}
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["waveLength"]["unit"]}
        Log                   \nwaveLength ${waveLength} ${waveLengthunit}  
        Set Suite Variable   ${transmissionRate}
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["transmissionRate"]["${direction}"]}
        Should Not Be Equal    ${transmissionRate}    N/A
        Should Not Be Empty    ${transmissionRate}
        Set Suite Variable   ${transmissionRateunit}
    ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["transmissionRate"]["unit"]}
        Log                   \ntransmissionRate ${transmissionRate} ${transmissionRateunit}
        Run keyword if    ${release_result}    Set Suite Variable   ${transmissionMode}
        ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["transmissionMode"]["${direction}"]}
        Run keyword if    ${release_result}    Should Not Be Equal    ${transmissionMode}    N/A
        Run keyword if    ${release_result}    Should Not Be Empty    ${transmissionMode}
    END
    
Initiate_SFP_QSFP_monitoring(invocation_of_the_diagnostic)_for_CPRI-N_SMOD(dynamic_data)
    ${links}    ${SMOD}=    Get SMOD SFP links
    ${dynamic_1}=   Check if dynamic parameters have a valid value for ports for SMOD   ${links}     ${SMOD}
    Sleep    90s
    ${links}    ${SMOD}=    Get SMOD SFP links
    ${dynamic_2}=    Check if dynamic parameters have a valid value for ports for SMOD  ${links}    ${SMOD}
    ${identic}    ${value}=    Run Keyword And Ignore Error    Dictionaries Should Be Equal    ${dynamic_1}
    ...    ${dynamic_2}
    Should Be True    '${identic}' == 'FAIL'

Check if dynamic parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check dynamic parameters
     ...    and return it in dictionary to compare whether are refreshed
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    &{dynamic_port}=    Create Dictionary
    FOR    ${port}    IN    @{list_of_links}
        ${dynamic_direction}=    Check if dynamic parameters have a valid value for directions for SMOD  ${links}
    ...    ${dict_of_links}    ${port}
        Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
    END
    [Return]    ${dynamic_port}

Check if dynamic parameters have a valid value for directions for SMOD
   [Documentation]
    ...     This keyword make a for loop to select a proper direction to check dynamic parameters and return it in dictionary
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    &{dynamic_direction}=    Create Dictionary
    @{list_of_dynamic_params}=    Create List
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
        Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}
        ...    initialDestination
        Set Suite Variable   ${moduleTemperature}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
        Should Be True  20<=${moduleTemperature}<=65
        Set Suite Variable   ${moduleTemperatureunit}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["moduleTemperature"]["unit"]}
        Log                   \nmoduleTemperature ${moduleTemperature} ${moduleTemperatureunit}
        Set Suite Variable   ${TXSupplyVoltage}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
        Should Be True  2000<=${TXSupplyVoltage}<=4500
        Set Suite Variable   ${TXSupplyVoltageunit}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["unit"]}
        Log                   \nTXSupplyVoltage ${TXSupplyVoltage} ${TXSupplyVoltageunit}
        Set Suite Variable   ${TXBiasCurrent}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"]}
        ${TXBiasCurrent}    2550_resources.Get parameter value    ${TXBiasCurrent}
        Should Be True  0<=${TXBiasCurrent}<=50
        Set Suite Variable   ${TXBiasCurrentunit}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["unit"]}
        Log                   \nTXBiasCurrent ${TXBiasCurrent} ${TXBiasCurrentunit}
        Set Suite Variable   ${TXOpticalPower}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"]}
       Check if Optical Power Value Is Correct    ${TXOpticalPower}      0    2000
        Set Suite Variable   ${TXOpticalPowerunit}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["TXOpticalPower"]["unit"]}
        Log                   \nTXOpticalPower ${TXOpticalPower} ${TXOpticalPowerunit}
        Set Suite Variable   ${RXOpticalPower}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"]}
        Check if Optical Power Value Is Correct    ${RXOpticalPower}    0    2000
        Set Suite Variable   ${RXOpticalPowerunit}
    ...    ${links["notConnected"][${port}]["data"]["measurements"]["RXOpticalPower"]["unit"]}
        Log                   \nRXOpticalPower ${RXOpticalPower} ${RXOpticalPowerunit}        
        Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
    ...    ${TXBiasCurrent}    ${RXOpticalPower}
    ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
        Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
    END
    [Return]    ${dynamic_direction}
    
Check if QSFP or SFP
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        ${physicalPort}    Check type of link  ${links}    ${dict_of_links}    ${port}
    
    END
    [Return]    ${physicalPort}

Check type of link
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check physical port
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        ${physicalPort}    admin.Get Parameters        ${links["connected"][${port}]["${direction}"]}    physicalPort
        ${physicalPort}    Get From Dictionary    ${physicalPort}    physicalPort
    END
    [Return]    ${physicalPort}

Check if Tx parameters have a valid value for ports for BBMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}     ${physicalPort}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if Tx parameters have a valid value for directions for BBMOD  ${links}    ${dict_of_links}    ${port}
        ...    ${physicalPort}
    END

Check if Tx parameters have a valid value for directions for BBMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}     ${physicalPort}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If  '${physicalPort}'=='Q_RF2' or '${physicalPort}'=='Q_RF1'
        ...    Run Keywords
        ...   Set Suite Variable   ${txPowerHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}      ${txPowerHighAlarmThreshold}    AND
        ...    Set Suite Variable   ${txPowerLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}      ${txPowerLowAlarmThreshold}    AND
        ...    Set Suite Variable     ${txPowerHighWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}       ${txPowerHighWarnThreshold}    AND
        ...    Set Suite Variable    ${txPowerLowWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}       ${txPowerLowWarnThreshold}
        ...    ELSE
        ...    Run Keywords
        ...    Set Suite Variable   ${txPowerHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}  AND
        ...   Should Be True  -100<=${txPowerHighAlarmThreshold}<=100    AND
        ...   Set Suite Variable   ${txPowerLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["${direction}"]}  AND
        ...   Should Be True  -100<=${txPowerLowAlarmThreshold}<=100    AND
        ...   Set Suite Variable   ${txPowerHighWarnThreshold}
      ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}  AND
        ...   Should Be True  -100<=${txPowerHighWarnThreshold}<=100    AND
        ...   Set Suite Variable   ${txPowerLowWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}    AND
        ...   Should Be True  -100<=${txPowerLowWarnThreshold}<=100
    END

Connect Ssh To Asix
    [Documentation]
    ...  Establish connection with ASIx via SSH
    ssh.Connect To
    ...    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=asik

Disconnect Ssh From Asix
    [Documentation]
    ...  Break connection with ASIx via SSH
    ssh.Disconnect      connection=asik
    
ADMIN CLI connection
    [Documentation]
    ...     Common keyword to established connection with ADMIN API of tested gNB
    admin.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}     bts_port=${gNB_MPLANE_IF_PORT}

ADMIN CLI disconnection
    [Documentation]
    ...     Disconnects connection to gNB ADMIN
    admin.teardown

gNB in onAir state
    coam_gnb_classical.Connect to gnb coam via ssl
    COAM Check GNB cell on air
    coam_gnb_classical.COAM Teardown gnb connections
    
get and validate scf file
    Log                   \nGet scf file ${SCF} and copy it to ${CURDIR}/SCF_Directory
    Set Environment Variable               https_proxy                 ${empty}
    create directory        ${LOG_PATH}
    admin.get_current_scf_file    ${LOG_PATH}     ${SCF}
    scf.load_scf          ${CURDIR}/SCF_Directory/${SCF}
    ${result}=            admin.validate_scf                ${CURDIR}/SCF_Directory/${SCF}
    Log                   Validation result = ${result}
    Run Keyword And Ignore Error     OperatingSystem.Run
    ...    sed -i '/"${tl.gnbs[0].instance_id}"/d' ${CURDIR}/2550_resources.py     
    Run Keyword And Ignore Error     OperatingSystem.Run    
    ...    sed -i '/{/a\\\t\\t\\"${tl.gnbs[0].instance_id}": "${CURDIR}/SCF_Directory/${SCF}",' ${CURDIR}/2550_resources.py
    [return]              ${result}

Collect logs after test
    [Arguments]    ${case_name}
    ${SAVE LOG DIRECTORY}=    Catenate    ${PATH_Storage}/${case_name}
    Run Keyword And Continue On Failure  create directory    ${SAVE LOG DIRECTORY}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}        
