*** Settings ***

Documentation   This is a Robot Test Suite for feature: Get Historic Alarms
...             Get Historic Alarms and spot critcal alarms
...             Team: 'I_MN_RAN_RD_VRF_ULM_VT2_GMS'
...             Email: 'I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.sbts.oam.coam.admin.interface.admin      WITH NAME    admin

Resource   ../sqd63/common_keywords.robot
Resource   ../../../resources/Common/testline.robot

Suite Setup      Log testline Status


*** Variables ***
#Below given FaultID are sample ones, needs to be updated with reuired FaultID later.

@{7132_FaultID_List}     13   34   67   23                        # List of FaultID for the alarmId 7132
@{7102_FaultID_List}     45   47   32   49   52                   # List of FaultID for the alarmId 7102
@{7865_FaultID_List}     87   76   44   49   52                   # List of FaultID for the alarmId 7865
@{7107_FaultID_List}     90   7307   77   7304   7305             # List of FaultID for the alarmId 7107
@{7115_FaultID_List}     23   73   4592   34                      # List of FaultID for the alarmId 7115
&{available_alarms}     ${7132}= ${7132_FaultID_List}
    ...                 ${7102}= ${7102_FaultID_List}
    ...                 ${7865}= ${7865_FaultID_List}
    ...                 ${7107}= ${7107_FaultID_List}
    ...                 ${7115}= ${7115_FaultID_List}


*** Test Cases ***
Retrival of alarm history for all gNBs

    [Documentation]    Retrive all historical alarms from all gNBs and returns two json files, one with all historic alarms and
	...                another with specific alarms.
	...                Setting up OAM connection, Arguments passed passed are:
	...                | node_id            | Id of gNB [0.. ] |
	...                | node_type          | gnb |
    [Tags]             history

	${resultTestDir}=    testline.Get testcase log directory
    Set test variable  ${resultTestDir}
    ${gnb_num}   Get Length   ${tl.gnbs}
    Log to console    number of gNBs: ${gnb_num}
    ${ctl}=    common_keywords.Get current testline name
    FOR    ${gnb_id}   IN RANGE   ${gnb_num}
        ${historic_alarms_ouputfile_name}=     Catenate    SEPARATOR=_   ${ctl}    gnb    ${gnb_id}
        ...                                                              list_of_entire_historic_alarms.json
        ${required_alarms_outputfile_name}=  Catenate    SEPARATOR=_     ${ctl}    gnb    ${gnb_id}
		...                                                              OutputFile_list_of_received_alarms.json
		${oam_alias}    connect.Setup OAM http session     node_id=${gnb_id}    node_type=gnb
        Obtain Alarm History And Save Data To File    oam_alias=${oam_alias}
        ...                                                 historical_alarms_file=${historic_alarms_ouputfile_name}
        ...                                                 required_alarms_file=${required_alarms_outputfile_name}
        admin.teardown    connection=${oam_alias}
    END


*** Keywords ***
Log testline Status
    testline.Set Console Output      # enable console output
    Log Variables
    testline.Check TL Infos


Obtain Alarm History And Save Data To File
    [Documentation]    Obtain of all historical alarms and returns two json files, one with all historic alarms and
	...                another with specific alarms.
	...                Argumements are
	...                | oam_alias | OAM connection |
	...                | historical_alarms_file | Output file with list of all alarm history |
	...                | required_alarms_file | Output file with list of specific required alarms |
    ...                Retrival of list of historical alarms using get_historic_alarms with paramters:
    ...                | connection | using oam_alias connection |
    ...                | timeout | Timeout for the operation, eg. 120 (seconds) |
    ...                | severity | Alarm severity (critical, major, minor or warning), if None then returns all alarms |
    ...                | load_history | Load entire history |
    ...                historic_alarms_json is a json file containing all historic alarms.
	...                received_alarms_json is a json file containing only specific alarms.
    [Arguments]    ${oam_alias}     ${historical_alarms_file}=list_of_entire_historic_alarms.json
    ...                             ${required_alarms_file}=OutputFile_list_of_required_alarms.json
    Log to console    Available alarms :${available_alarms}
    ${historical_alarms}=    admin.get_historic_alarms    connection=${oam_alias}    timeout=120   load_history=${True}
    Log to console    \n
    Log to console    Historical Alarms: ${historical_alarms}
    ${historical_alarms_length}=    Get Length   ${historical_alarms}
    Log to console    Historical Alarms Length : ${historical_alarms_length}
    ${resultTestDir}=    testline.Get testcase log directory
    ${historic_alarms_json}=    Evaluate    json.dumps(${historical_alarms}, indent=4)    json
    Create File    ${resultTestDir}/${historical_alarms_file}    content=${historic_alarms_json}
    ${received_alarms}=    Create Dictionary
    ${received_alarm_list}=    Create List
    FOR    ${element}    IN     @{historical_alarms}
        Log    ${element}
        ${alarm_id}=    Get From Dictionary    ${element}    alarmId
        ${fault_id}=    Get From Dictionary    ${element}    faultId
        ${configObjectName}=    Get From Dictionary    ${element}    configObjectName
        ${distName}=    Get From Dictionary    ${element}    distName
        Log to console    Alarm_ID: ${alarm_id}
        Log to console    Fault_ID: ${fault_id}
        ${unique_key_generation}=    Catenate    SEPARATOR=_   ${alarm_id}   ${configObjectName}   ${distName}
        Log     ${unique_key_generation}
        ${available_fault_id}=    IF   ${alarm_id} in ${available_alarms}   Get From Dictionary    ${available_alarms}    ${alarm_id}
        Log to console    Available faultId for received alarm ID : ${available_fault_id}
        IF     "${fault_id}" in "${available_fault_id}"    Set To Dictionary   ${received_alarms}  ${unique_key_generation}=${element}
    END
    Log to console    \n
    Log to console  Required alarm:${received_alarms}
    ${received_alarms_length}=    Get Length   ${received_alarms}
    Log to console    Received Alarms Length : ${received_alarms_length}
    Append to list  ${received_alarm_list}    ${received_alarms}
    ${received_alarms_json}=    Evaluate    json.dumps(${received_alarm_list}, indent=4)    json
    Create File    ${resultTestDir}/${required_alarms_file}    content=${received_alarms_json}
