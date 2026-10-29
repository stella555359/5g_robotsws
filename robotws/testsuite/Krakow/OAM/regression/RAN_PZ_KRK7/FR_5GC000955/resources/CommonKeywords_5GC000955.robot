*** Settings ***
Library    XML
Library    random
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_lib
Library    taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.nms.netact    WITH NAME    netact_lib
Library    taf.config.scf    WITH NAME    scf
Library    PythonKeywords_5GC000955.py    WITH NAME    Python_KW
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${RESULTS}=        ${CURDIR}/TestResults
@{SFPid_range}=    1  99  32767
${HOST}=           ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${USERNAME}=       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${PASSWORD}=       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${PORT}=           443
${lterel_disc}=    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build


*** Keywords ***
Test preparation
    [Arguments]    ${sfpType}    #(S-sfp , Q-qsfp)
    ${bts_info}    admin_cli.get_bts_info
    Set test variable    ${bts_info}    ${bts_info}
    Set test variable    ${MRBTS_ID}    ${bts_info["mrbtsID"]}
    Set test variable    ${NRBTS_ID}    ${bts_info["nrBtsId"]}
    ${Subrack_position}    Set correct SMOD position in Subrack
    Set test variable    ${Subrack_position}    ${Subrack_position}
    ${BBMOD_id}    ${SFP_RF_label}    Get first active SFP    sfpType=${sfpType}
    Set test variable    ${BBMOD_id}    ${BBMOD_id}
    Set test variable    ${SFP_RF_label}    ${SFP_RF_label}
    ${SFP_id}    Evaluate    random.choice($SFPid_range)    random
    Set test variable    ${SFP_id}    ${SFP_id}
    @{LINE_list_id}    Run keyword if    "${sfpType}"=="S"   create list    1
    ...    ELSE IF    "${sfpType}"=="Q"    create list    1    2    3    4
    Set test variable    @{LINE_list_id}    @{LINE_list_id}

5GC000955_Lock_Unlock_SFP_BBMOD_via_WebEM
    Log To Console    ${\n}--------create SFP via WebEM----------
    ${sfp_dn}    Create SFP LANE objs    ${MRBTS_ID}    ${BBMOD_id}    ${SFP_id}   ${LINE_list_id}    ${SFP_RF_label}
    Log To Console    ${\n}--------start lock SFP via WebEM----------
    Python_KW.lock_SFP_QSFP_LANEs    BBMOD   ${SFP_RF_label}   ${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Locked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    Log To Console    ${\n}--------start UNlock SFP via WebEM-------
    Python_KW.unlock_SFP_QSFP_LANEs    BBMOD    ${SFP_RF_label}    ${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Unlocked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    Wait Until Keyword Succeeds    20x    30sec    Verify Setup Of All Cells
    Log To Console    ${\n}--------delete SFP via WebEM----------
    ${sfp_dn}    Remove SFP obj    ${sfp_dn}

5GC000955_Lock_Unlock_SFP_BBMOD_via_CLI
    Lock_SFP_BBMOD_via_CLI
    Unlock_SFP_BBMOD_via_CLI
    Wait Until Keyword Succeeds    20x    30sec    Verify Setup Of All Cells

Lock_SFP_BBMOD_via_CLI
    [Arguments]    ${SFP_RF_id}=${None}    ${SFP_Lane_id}=${None}
    Run Keyword If    "${SFP_RF_id}"!="${None}"    Set test variable    ${SFP_RF_label}    ${SFP_RF_id}
    Run Keyword If    "${SFP_Lane_id}"!="${None}"    Set test variable    ${SFP_id}    ${SFP_Lane_id}
    ${admin_CLI_file}    Download Admin CLI zip file
    ${rc}    Run and return rc    rm -rf ${CURDIR}${/}temp_for_zip_extract
    ${rc}    Run and return rc    unzip ${CURDIR}${/}${admin_CLI_file} -d ${CURDIR}${/}temp_for_zip_extract
    #Set bts parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    param_name=actGeneralConnectivitySilver    param_value=true
    #actGeneralConnectivitySilver is removed from 24R2 onwards in NIDD
    Set bts parameter    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    param_name=actCli    param_value=true
    Log To Console    ${\n}--------create SFP LINEs---------
    ${sfp_dn}    Create SFP LANE objs    ${MRBTS_ID}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}    ${SFP_RF_label}
    Log To Console    ${\n}--------start LINEs Lock via CLI----------
    Lock unlock SFP QSFP LANEs via CLI
    ...    requestId=10    name=lock    MRBTS_ID=${MRBTS_ID}    BBMOD_id=${BBMOD_id}    SFP_id=${SFP_id}    LINE_list_id=${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Locked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}

Unlock_SFP_BBMOD_via_CLI
    [Arguments]    ${SFP_Lane_id}=${None}
    Run Keyword If    "${SFP_Lane_id}"!="${None}"    Set test variable    ${SFP_id}    ${SFP_Lane_id}
    ${sfp_dn}    Catenate    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_id}/SFP-${SFP_id}
    Log To Console    ${\n}--------start LINEs Unlock via CLI-------
    Lock unlock SFP QSFP LANEs via CLI
    ...    requestId=11    name=unlock    MRBTS_ID=${MRBTS_ID}    BBMOD_id=${BBMOD_id}    SFP_id=${SFP_id}    LINE_list_id=${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Unlocked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    Log To Console    ${\n}--------delete SFP----------
    ${sfp_dn}    Remove SFP obj    ${sfp_dn}

5GC000955_Lock_Unlock_QSFP_BBMOD_via_CLI
    ${admin_CLI_file}    Download Admin CLI zip file
    ${rc}    Run and return rc    rm -rf ${CURDIR}${/}temp_for_zip_extract
    ${rc}    Run and return rc    unzip ${CURDIR}${/}${admin_CLI_file} -d ${CURDIR}${/}temp_for_zip_extract
    #Set bts parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    param_name=actGeneralConnectivitySilver    param_value=true
    #actGeneralConnectivitySilver is removed from 24R2 onwards in NIDD
    Set bts parameter    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    param_name=actCli    param_value=true
    ${SFP_id}    Evaluate    random.choice($SFPid_range)    random
    log to console    ${\n}--------create QSFP LINEs Lock via CLI----------
    ${sfp_dn}    Create SFP LANE objs    ${MRBTS_ID}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}    ${SFP_RF_label}
    log to console    ${\n}--------start LINEs Lock via CLI----------
    Lock unlock SFP QSFP LANEs via CLI
    ...    requestId=10    name=lock    MRBTS_ID=${MRBTS_ID}    BBMOD_id=${BBMOD_id}    SFP_id=${SFP_id}    LINE_list_id=${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State     Locked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    log to console    ${\n}---------start LINEs Unlock via CLI-------
    Lock unlock SFP QSFP LANEs via CLI
    ...    requestId=11    name=unlock    MRBTS_ID=${MRBTS_ID}    BBMOD_id=${BBMOD_id}    SFP_id=${SFP_id}    LINE_list_id=${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Unlocked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    Wait Until Keyword Succeeds    20x    30sec    Verify Setup Of All Cells
    ${sfp_dn}    Remove SFP obj    ${sfp_dn}

5GC000955_Lock_Unlock_QSFP_BBMOD_via_WebEM
    [Documentation]    this keyword point to TC [1]5GC000955_Lock_Unlock_QSFP_BBMOD and is used in robustnest testing
    log to console    ${\n}--------create QSFP via WebEM----------
    ${sfp_dn}    Create SFP LANE objs    ${MRBTS_ID}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}    ${SFP_RF_label}
    log to console    ${\n}--------start lock QSFP via WebEM----------
    Lock_SFP_QSFP_LANEs    BBMOD    ${SFP_RF_label}    ${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Locked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    log to console    ${\n}--------start UNlock QSFP via WebEM-------
    Unlock_SFP_QSFP_LANEs    BBMOD    ${SFP_RF_label}    ${LINE_list_id}
    Wait Until Keyword Succeeds    5x    5sec
    ...    Check LINE State    Unlocked    ${MRBTS_ID}    ${Subrack_position}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}
    Wait Until Keyword Succeeds    20x    30sec    Verify Setup Of All Cells
    log to console    ${\n}--------delte QSFP via WebEM----------
    ${sfp_dn}    Remove SFP obj    ${sfp_dn}

5GC000955_Parameters_check_for_transmission_via_WebEM
    [Documentation]    this kw represents [1]5GC000955_Parameters_check_for_transmission
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}    Get Information about SFP links
    Check if static data SFP QSFP does not contain parameter for ports    ${links}    ${BBMOD}    maxTransmissionRate

5GC000955_Lock_Unlock_SFP_BBMOD_with_abil_reset
    Lock_SFP_BBMOD_via_CLI    SFP_RF_id=S_RF2
    gnb_bbu.Wait For Site To Be Onair
    Wait Until Keyword Succeeds    120s    10s    gnb_cell.Verify Cell Status    gnb_id=${0}    cell_id=${2}
    ...    cell_status=Disabled    du_id=${0}
    Reset Abil
    gnb_bbu.Wait For Site To Be Onair
    Wait Until Keyword Succeeds    120s    10s    gnb_cell.Verify Cell Status    gnb_id=${0}    cell_id=${2}
    ...    cell_status=Disabled    du_id=${0}
    Unlock_SFP_BBMOD_via_CLI
    Wait Until Keyword Succeeds    180s    10s    gnb_cell.Verify All Cell Status

5GC000955_Lock_Unlock_SFP_BBMOD_with_site_reset
    Lock_SFP_BBMOD_via_CLI    SFP_RF_id=S_RF2
    gnb_bbu.Wait For Site To Be Onair    timeout=1200s
    Wait Until Keyword Succeeds    120s    10s    gnb_cell.Verify Cell Status    gnb_id=${0}    cell_id=${345}
    ...    cell_status=Disabled    du_id=${0}
    gnb_bbu.Reset gNB
    gnb_bbu.Wait For Site To Be Onair    timeout=1200s
    Wait Until Keyword Succeeds    120s    10s    gnb_cell.Verify Cell Status    gnb_id=${0}    cell_id=${345}
    ...    cell_status=Disabled    du_id=${0}
    Unlock_SFP_BBMOD_via_CLI
    Wait Until Keyword Succeeds    180s    10s    gnb_cell.Verify All Cell Status

5GC000955_Configure_QSFP_Lanes
    Remove all SFP objects
    5GC000955_Lock_Unlock_QSFP_BBMOD_via_CLI
    Remove all SFP objects
    log to console    ${\n}--------create QSFP via WebEM----------
    ${sfp_dn}    Create SFP LANE objs    ${MRBTS_ID}    ${BBMOD_id}    ${SFP_id}    ${LINE_list_id}    ${SFP_RF_label}

Get Information about SFP links
    [Documentation]
    ...    This keyword create 3 dictionaries, where a key is a number of a link and a values
    ...    are directions (source/destination or both)
    ${links}    admin_cli.get_sfp_links
    ${connected}    Get From Dictionary    ${links}    connected
    ${numb_of_links}    Get Length    ${connected}
    Should Be True    ${numb_of_links}>0
    &{SMOD_dict}    Create Dictionary
    &{BBMOD_dict}    Create Dictionary
    &{RMOD_dict}    Create Dictionary
    FOR    ${x}    IN RANGE    ${numb_of_links}
        @{SMOD}    Create List
        @{BBMOD}    Create List
        @{RMOD}    Create List
        Set Suite Variable    ${source}    ${links["connected"][${x}]["source"]}
        Set Suite Variable    ${destination}    ${links["connected"][${x}]["destination"]}
        ${source_SMOD_match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${source}    SMOD
        ${source_BBMOD_match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${source}    BBMOD
        ${source_RMOD_match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${source}    RMOD
        ${destiny_SMOD_match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${destination}    SMOD
        ${destiny_BBMOD_match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${destination}    BBMOD
        ${destiny_RMOD_match}    ${value}    Run Keyword And Ignore Error    Should Contain    ${destination}    RMOD
        Run Keyword If    '${source_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    source
        Run Keyword If    '${source_BBMOD_match}' == 'PASS'    Append To List    ${BBMOD}    source
        Run Keyword If    '${source_RMOD_match}' == 'PASS'    Append To List    ${RMOD}    source
        Run Keyword If    '${destiny_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    destination
        Run Keyword If    '${destiny_BBMOD_match}' == 'PASS'    Append To List    ${BBMOD}    destination
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

Check if static data SFP QSFP does not contain parameter for ports
    [Documentation]
    ...    This keyword make a for loop to select a proper link to check if static data SFP QSFP doesn't have parameter
    [Arguments]    ${links}    ${dict_of_links}    ${parameter}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        ${keys}    Get Dictionary Keys    ${links["connected"][${port}]["details"]["staticParameters"]}
        List Should Not Contain Value    ${keys}    ${parameter}
    END

Remove all SFP objects
    [Documentation]    this keyword remove all ..SFP/LINE objects
    ${scf_file}    admin_cli.get_scf
    ${REGEX_SFP_DIST}    get regexp matches
    ...    ${scf_file}    pattern=MRBTS-\[0-9\]+/EQM-\[1 4\]/APEQM-1/CABINET-1/BBMOD-\[1-6\]/SFP-\[0-9\]+\"
    FOR  ${dn}    IN    @{REGEX_SFP_DIST}
        ${DIST_NAME}    Fetch from left    ${dn}    "
        Remove SFP obj    ${DIST_NAME}
    END

Check LINE State
    [Documentation]    this keyword verified ..SFP/LINE administrativeState
    [Arguments]    ${state}    ${MRBTS_ID}    ${subrack_pos}    ${BBMOD_id}     ${SFP_id}    ${lines}
    ${currentNp_dict}    admin_cli.get_parameters  dist_name=/MRBTS-1/RAT-1/BTS_L-${subrack_pos}/BTS_CONF-1
    ...                                            pattern=currentNp
    ${cNp}    Get From Dictionary    ${currentNp_dict}    currentNp
    FOR    ${line}    IN    @{lines}
        ${lane_obj}    admin_cli.get_parameters
    ...    dist_name=${cNp}/SCF-1/MRBTS_A-${MRBTS_ID}/EQM_A-1/APEQM_A-1/CABINET_A-1/BBMOD_A-${BBMOD_id}/SFP_A-${SFP_id}/LANE_A-${line}
    ...    pattern=administrativeState
        should be equal as strings    ${lane_obj['administrativeState']}    ${state}
    END

Lock unlock SFP QSFP LANEs via CLI
    [Documentation]    Kw lock or unlock SFP or QSFP LINES via CLI
    [Arguments]    ${requestId}    ${name}    ${BBMOD_id}    ${MRBTS_ID}    ${SFP_id}    ${LINE_list_id}
    ${sw_rel}=    Get gNB Release

    FOR    ${id}    IN    @{LINE_list_id}
        Run keyword if    '${sw_rel}' in ['SBTS22R3', 'SBTS22R2', 'SBTS22R1']    Set test variable    ${parameters}
    ...    "distName": "MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_id}/SFP-${SFP_id}/LANE-${id}"
    ...    ELSE    Set test variable    ${parameters}
    ...    "distNames": ["MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_id}/SFP-${SFP_id}/LANE-${id}"]
        Set test variable    ${DATA}    {"requestId": ${requestId}, "parameters": {"name":"${name}", "parameters":{${parameters}}}}
        ${command}    Catenate    ${CURDIR}${/}temp_for_zip_extract${/}admin-cli.sh --bts-username='${USERNAME}' --bts-password='${PASSWORD}'
    ...  --bts-host='${HOST}' --bts-port='${PORT}' --data='${DATA}' --format='human'
        ${rc}    Run and Return Rc    ${command}
        Should Be Equal	${rc}	${0}
    END

Download Admin CLI zip file
    [Documentation]    Kw download AdminCLI zip file
    ${SW_Version}    admin_cli.get_sw_version
    ${is_CommonBuild}=    Run keyword and return status    Should Contain    ${SW_Version}    SBTS
    ${is_TrunkBuild}=    Run keyword and return status    Should Contain    ${SW_Version}    _9999_
    Set test variable    ${is_CommonBuild}
    Set test variable    ${is_TrunkBuild}
    ${Downloaded_file}=    Run keyword if
    ...    ${is_CommonBuild}==True    Get CommonBuild AdminCLI    ${is_Trunk_Build}
    ...    ELSE IF
    ...    ${is_CommonBuild}==False and ${is_Trunk_Build}==False    Get Non CommonTrunk AdminCLI
    ...    ELSE
    ...    Fail    Keyword not support BTS SW version
    [Return]    ${Downloaded_file}

Get CommonBuild AdminCLI
    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
    [Arguments]    ${is_Trunk_Build}
    ${SW_Version}    admin_cli.get_sw_version
    ${build_ver}=    Run keyword if
    ...    ${is_Trunk_Build}==True    Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...    ELSE    Set variable    ${SW_Version}
    ${release}    Fetch from left    ${build_ver}    _ENB_
    ${fileExists}    Python_KW.file_exists    ${CURDIR}/${build_ver}_ADMIN_CLI.zip
    Run Keyword If    ${fileExists} is False    Run    wget ${lterel_disc}/${release}/${build_ver}/${build_ver}_ADMIN_CLI.zip -nv -P ${CURDIR}
    ${fileExists}    Python_KW.file_exists     ${CURDIR}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings    ${fileExists}    True
    [Return]    ${build_ver}_ADMIN_CLI.zip

Get Non CommonTrunk AdminCLI
    [Documentation]    Kw download non Common Trunk AdminCLI from arifactory disc
    ${SW_Version}=    Get Current Soft version
    Run    rm ${CURDIR}/index.html*
    Run    wget ${arti}${SW_Version}/ -P ${CURDIR}/
    ${file}    Run    grep -oP '".*ADMIN_CLI.zip"' ${CURDIR}/index.html | tr -d '"'
    ${fileExists}    Python_KW.file_exists    ${CURDIR}/${file}
    Run Keyword If    ${fileExists} is False    Run    wget ${arti}${SW_Version}/${file} -nv -P ${CURDIR}
    ${fileExists}    Python_KW.file_exists    ${CURDIR}/${file}
    Should Be Equal As Strings    ${fileExists}    True
    [Return]    ${file}

Get first active SFP
    [Documentation]    Kw return bbmod id and rf label for first active sfp #(S-sfp , Q-qsfp)
    [Arguments]    ${sfpType}
    ${bts_info}    admin_cli.get_bts_info
    ${BBMOD_RF_id_list}    BBMOD SFP type active    ${sfpType}
    ${BBMOD_id}     Get Dictionary Keys    ${BBMOD_RF_id_list[0]}
    ${BBMOD_id}     Set variable    ${BBMOD_id[0]}
    ${SFP_RF_label}    Get Dictionary Values    ${BBMOD_RF_id_list[0]}
    ${SFP_RF_label}    Set variable    ${SFP_RF_label[0]}
    [Return]    ${BBMOD_id}    ${SFP_RF_label}

Set bts parameter
    [Documentation]    Kw set BTS parameter.
    [Arguments]    ${dist_name}    ${param_name}    ${param_value}
    admin_cli.perform_parameter_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${param_name}
    ...    value=${param_value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    Log To Console    ${\n}Parameter ${param_name} is set to ${param_value}

Check SFP object exist
    [Documentation]
    ...    Kw return if SFP object exist for given BBMOD id and SFP label
    [Arguments]    ${BBMOD_id}    ${SFP_RF_label}
    ${scf_file}    admin_cli.get_scf
    ${REGEX_SFP_DIST}    get regexp matches
    ...    ${scf_file}    pattern=MRBTS-\[0-9\]+/EQM-\[1 4\]/APEQM-1/CABINET-1/BBMOD-\[1-6\]/SFP-\[0-9\]+\"
    ${LENGTH}    Get Length    ${REGEX_SFP_DIST}
    ${passed}    Run Keyword And Return Status    Should Be True    ${LENGTH}>0
    ${DIST_NAME}  Set Variable  ${EMPTY}
    FOR    ${X}    IN RANGE    0    ${LENGTH}
        ${DIST_NAME}    Get From List   ${REGEX_SFP_DIST}    ${X}
        ${DIST_NAME}    Fetch From Left    ${DIST_NAME}    "
        ${hwPortId}    Get Element Text    ${scf_file}
    ...    xpath=cmData/managedObject[@distName='${DIST_NAME}']/p[@name="hwPortId"]
        ${passed}    Run Keyword And Return Status    should be equal as strings    ${SFP_RF_label}    ${hwPortId}
        Exit For Loop If    '${passed}' == 'True'
        ${DIST_NAME}    Set Variable    ${EMPTY}
   END
   [Return]    ${passed}    ${DIST_NAME}

BBMOD SFP type active
    [Documentation]
    ...    Kw retrun bbmod and SFP for active SFP type (S-sfp , Q-Qsfp)
    [Arguments]    ${sfp_type}
    ${obj_connected}    admin_cli.get_sfp_links
    ${links}    Set Variable    ${obj_connected["connected"]}
    ${bbmodID_RFlabelID_list}    Create List
    FOR    ${obj_dict}    IN    @{links}
        ${bbmod_rflabel}    Create_Dictionary
        ${dest}    Set Variable    ${obj_dict["data"]["linkPorts"]["destination"]}
        ${bbmod}    Fetch From Right    ${dest}    BBMOD-
        ${bbmod_id}    Fetch From Left    ${bbmod}    (
        ${RF_label}    Fetch From Right    ${bbmod}    /
        ${active_sfp_type}    Fetch From Left    ${RF_label}    _
        Run Keyword If    '${sfp_type}' == '${active_sfp_type}'    Run Keywords
        ...    Set To Dictionary    ${bbmod_rflabel}    ${bbmod_id}    ${RF_label}    AND
        ...    Append To List    ${bbmodID_RFlabelID_list}    ${bbmod_rflabel}
    END
    Should not be empty    ${bbmodID_RFlabelID_list}    msg=List is empty. Please check if BTS use active SFP type (S-sfp , Q-Qsfp)
    [Return]    ${bbmodID_RFlabelID_list}

Create SFP LANE objs
    [Arguments]    ${MRBTS_ID}    ${BBMOD_id}    ${SFP_id}     ${LINE_list_id}    ${SFP_RF_label}
    ${passed}    ${SFP_distName}    Check SFP object exist    ${BBMOD_id}    ${SFP_RF_label}
    Run Keyword If    ${passed}    Remove SFP obj    ${SFP_distName}
    ${DN}    Catenate    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_id}/SFP-${SFP_id}
    ${dict1}    create dictionary    parameterName=hwPortId
    ...                              operation=update
    ...                              value=${SFP_RF_label}
    ${dict2}       create dictionary    parameterName=sfpId
    ...                                 operation=update
    ...                                 value=${SFP_id}
    @{parameter_list}    create list    ${dict1}    ${dict2}
    admin_cli.perform_object_recommissioning    dist_name=${DN}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${False}    #${False} due tu PDL should be false
    ...                                         should_activate=True
    ...                                         parameter=@{parameter_list}
    FOR    ${line}    IN    @{LINE_list_id}
        Create LANE    ${DN}/LANE-${line}
    END
    [Return]    ${DN}

Remove SFP obj
    [Arguments]    ${DN}
    ${SFP_id}=    get regexp matches    ${DN}    pattern=SFP-\[1-9\]+
    ${dict}=    Create dictionary    parameterName=sfpId
    ...                              operation=update
    ...                              value=${SFP_id[0]}
    @{parameter_list}=    create list    ${dict}
    admin_cli.perform_object_recommissioning    dist_name=${DN}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         should_activate=True
    ...                                         parameter=@{parameter_list}

Create LANE
    [Arguments]    ${DN}
    ${dict1}=    create dictionary    parameterName=administrativeState
    ...                               operation=update
    ...                               value=Unlocked
    @{parameter_list}    create list    ${dict1}
    admin_cli.perform_object_recommissioning    dist_name=${DN}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=True
    ...                                         parameter=@{parameter_list}

Loop for robustness execution
    [Arguments]    ${test_name}    ${loop_amount}
    ${status_of_execution}    create list
    set test variable    ${exec_number}    0
    FOR    ${i}    IN RANGE    ${loop_amount}
        ${TC_status}    run keyword and return status    ${test_name}
        Append To List    ${status_of_execution}    ${TC_status}
    END
    Check if one of executions fails    ${status_of_execution}
    log    ${status_of_execution}

Check if one of executions fails
    [Arguments]    ${status_of_execution}
    FOR    ${exec}    IN    @{status_of_execution}
        should not be equal as strings    '${exec}'    'False'
    END

ADMIN CLI connection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Common keyword to established connection with ADMIN API of tested gNB.
    ...     As arguments it takes:
    ...                            - bts_host - by default is 192.168.255.1
    ...                            - bts_port - by default is 443
    ...                            - username - by default is Nemuadmin
    ...                            - password - by default is nemuuser
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    ${bts_host}=${HOST}    ${bts_port}=${PORT}
    ...            ${username}=${USERNAME}  ${password}=${PASSWORD}  ${connection}=default
    admin_cli.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}
    ...                     password=${password}    name=${connection}

ADMIN CLI disconnection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Disconnects connection to gNB ADMIN
    ...     As argument it takes:
    ...                           - list of indicated connections to be closed. If the list is empty,
    ...                             KW closes all existing connections.
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    @{connection}
    Run Keyword If    ${connection}==[]    admin_cli.Teardown_all_aliases_for_admin
    ...    ELSE    Close Indicated Connection    ${connection}

Close Indicated Connection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Disconnects connection indicated by user as argument of keyword ADMIN CLI disconnection
    ...     As argument it takes:
    ...                           - Alias of the connection which to be closed.
    ...    ------------------------------------------------------------------------------------------
    [Arguments]    ${connection}
    FOR    ${connection_name}    IN    @{connection}
        admin_cli.teardown_admin    connection=${connection_name}
    END

Set correct SMOD position in Subrack
    [Arguments]    ${connection}=default
    ${smodPosition}    admin_cli.get_smod_position    connection=${connection}
    ${positionNumber}=    set variable if
    ...    'left' == '${smodPosition}'    1
    ...    'right' == '${smodPosition}'    4
    [Return]    ${positionNumber}

Get Current Soft version
    ${SW}=    admin_cli.get_sw_version
    ${SW1}=    Replace String    ${SW}    _00000    .
    ${SW2}=    Replace String    ${SW1}    _0000    .
    ${SW3}=    Replace String    ${SW2}    _000    .
    ${SW4}=    Replace String    ${SW3}    _00    .
    ${SW5}=    Replace String    ${SW4}    _0    .
    ${SW6}=    Replace String    ${SW5}    _    .
    ${is_trunk}    run keyword and return status    Should Contain    ${SW6}    ..800
    ${SW7}=    Fetch From Right    ${SW6}    GNB.
    ${SW_trunk}=    run keyword if    ${is_trunk}==True    Replace String    ${SW7}    .800.    0.800.
    run keyword if    ${is_trunk}==True    set suite variable    ${SW7}    ${SW_trunk}
    [Return]    ${SW7}

Get gNB Release
    admin_cli.connect to    bts_host=${HOST}    bts_port=443    name=coam_admin
    ${release_version}=    admin_cli.get_sw_release_name    connection=coam_admin
    admin_cli.teardown    connection=coam_admin
    [Return]    ${release_version}

Reset Abil
    reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1    reset_type=Warm    force_radio_reset=True
    ...    timeout=300

5GC000955_Lock_All_SFP_QSFP_BBMOD_via_CLI
    [Arguments]    ${BBMOD_RF_id_list}
    ${List_SFP_QSFP_Ids}    Create List

    FOR    ${BBMOD_RF_id}    IN    @{BBMOD_RF_id_list}
        ${BBMOD_id}    Get Dictionary Keys    ${BBMOD_RF_id}
        ${SFP_RF_label_list}    Get Dictionary Values    ${BBMOD_RF_id}
        ${SFP_RF_label}    Set variable    ${SFP_RF_label_list[0][0]}
        ${SFP_id}    Set variable    ${SFP_RF_label_list[0][1]}
        @{LINE_list_id}    Run keyword if    "${SFP_RF_label[0]}"=="S"    create list    1
        ...    ELSE IF    "${SFP_RF_label[0]}"=="Q"    create list    1    2    3    4
        Set test variable    @{LINE_list_id}    @{LINE_list_id}
        Lock_SFP_BBMOD_via_CLI    SFP_RF_id=${SFP_RF_label}    SFP_Lane_id=${SFP_id}
    END
    Set test variable    @{List_SFP_QSFP_Ids}    @{List_SFP_QSFP_Ids}

5GC000955_Unlock_All_SFP_QSFP_BBMOD_via_CLI
    [Arguments]    ${BBMOD_RF_id_list}
    FOR    ${BBMOD_RF_id}    IN    @{BBMOD_RF_id_list}
        ${BBMOD_id}    Get Dictionary Keys    ${BBMOD_RF_id}
        ${SFP_RF_label_list}    Get Dictionary Values    ${BBMOD_RF_id}
        ${SFP_RF_label}    Set variable    ${SFP_RF_label_list[0][0]}
        ${SFP_id}    Set variable    ${SFP_RF_label_list[0][1]}
        @{LINE_list_id}    Run keyword if    "${SFP_RF_label[0]}"=="S"    create list    1
        ...    ELSE IF    "${SFP_RF_label[0]}"=="Q"    create list    1    2    3    4
        Set test variable    @{LINE_list_id}    @{LINE_list_id}

        UnLock_SFP_BBMOD_via_CLI    SFP_Lane_id=${SFP_id}
    END
    Wait Until Keyword Succeeds    360s    10s    Verify Setup Of All Cells

Get all active SFP_QSFP
    ${obj_connected}    admin_cli.get_sfp_links
    ${links}    Set Variable    ${obj_connected["connected"]}
    ${bbmodID_RFlabelID_list}    Create List
    ${SFPid_list}   Set Variable    @{SFPid_range}
    FOR    ${obj_dict}    IN    @{links}
        ${bbmod_rflabel}    Create_Dictionary
        ${dest}    Set Variable    ${obj_dict["data"]["linkPorts"]["destination"]}
        ${bbmod}    Fetch From Right    ${dest}    BBMOD-
        ${bbmod_id}    Fetch From Left    ${bbmod}    (
        ${RF_label}    Fetch From Right    ${bbmod}    /
        ${SFPid}    Remove From List    ${SFPid_list}   -1
        ${RF_label_ID}    Create List    ${RF_label}    ${SFPid}
        Set To Dictionary    ${bbmod_rflabel}    ${bbmod_id}    ${RF_label_ID}
        Append To List    ${bbmodID_RFlabelID_list}    ${bbmod_rflabel}
    END
    Should not be empty    ${bbmodID_RFlabelID_list}    msg=List is empty. Please check if BTS use active SFP type
    [Return]    ${bbmodID_RFlabelID_list}
