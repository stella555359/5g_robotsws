*** Settings ***
Documentation       Test case for BOAM ET
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Setup       Common BTS Suite Setup
Suite Teardown    Common BTS Suite Teardown
Test Setup    Common BTS Test Setup
Test Teardown    Common BTS Test Teardown
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_Resource.robot
Force Tags        TEAM-BTS_MANO_SOAM5    FEATURE-CB006796    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    OWNER-xi.wu

*** Variables ***
${S_BTSID}    1
${TA_LOG_DIRECTORY}    /home/ute/logs


*** Test Cases ***
CB006796-B1_02-BTS should not fragment the additionalText when additionalText is not exceed 4k
#CB006796-A1_01-BTS should optimize the additionalText in the event-log
    [Documentation]
    ...    *****************
    ...    | 2022.4.24 | 5G22R4 | Gao Huike | first create |
    ...    BTS should optimize the additionalText in the event-log
	${additionalText}    Catenate    SEPARATOR=    {"MRBTS-1/MNL-1/AMGR-1/LUAC-1":{"webEMSessionLogoutTimer":800}
    ...    ,"MRBTS-1/MNL-1/MNLENT-1/SECADM-1":{"actSyncToFronthaul":true,"actSyncToRU":true}}
	Run Keyword And Ignore Error    ADMIN Perform Parameter Update    MRBTS-1/MNL-1/MNLENT-1/SECADM-1    actSyncToFronthaul    false
	Run Keyword And Ignore Error    ADMIN Perform Parameter Update    MRBTS-1/MNL-1/MNLENT-1/SECADM-1    actSyncToRU    false
	Run Keyword And Ignore Error    ADMIN Perform Parameter Update    MRBTS-1/MNL-1/AMGR-1/LUAC-1    webEMSessionLogoutTimer    900
	Create Delta    delta1
    Append Parameter Update To Delta    MRBTS-1/MNL-1/MNLENT-1/SECADM-1    actSyncToFronthaul    true    delta_id=delta1
	Append Parameter Update To Delta    MRBTS-1/MNL-1/MNLENT-1/SECADM-1    actSyncToRU    true    delta_id=delta1
	Append Parameter Update To Delta    MRBTS-1/MNL-1/AMGR-1/LUAC-1    webEMSessionLogoutTimer    800    delta_id=delta1
	${delta1_data}    Get Delta    delta1
	Log    ${delta1_data}
	Teardown with Emssim
    Setup with Emssim
    Clear Events
	Set Events Format
    ${timestampbegin}    get current date
    ${timestampbegin}    convert date    ${timestampbegin}    epoch
	${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
    Log    ${feedback}
    ${record}    Wait Until Keyword Succeeds    240s    10s    Get ATL Events    PLAN_ACTIVATE_IND    Nemuadmin    ${additionalText}
    ${length}    Get Length    ${record[0]['additionalText']}
	${case2}=    Run Keyword And Return Status    Should Be True    ${length} < 4000
    Set Suite Variable    ${case2}
    Teardown with Emssim

#CB006796-B1_02-BTS should not fragment the additionalText when additionalText is not exceed 4k
#    [Documentation]
#    ...    *****************
#    ...    | 2022.4.24 | 5G22R4 | Gao Huike | first create |
#    ...    BTS should optimize the additionalText in the event-log
	#${additionalText}    Set Variable    {"MRBTS-1/MNL-1/MNLENT-1/SECADM-1":{"actSyncToFronthaul":true}}
    #Run Keyword And Ignore Error    ADMIN Perform Parameter Update    MRBTS-1/MNL-1/MNLENT-1/SECADM-1    actSyncToFronthaul    false
	#Teardown with Emssim
    #Setup with Emssim
    #Clear Events
	#Set Events Format
    #${timestampbegin}    get current date
    #${timestampbegin}    convert date    ${timestampbegin}    epoch
    #ADMIN Perform Parameter Update    MRBTS-1/MNL-1/MNLENT-1/SECADM-1    actSyncToFronthaul    true
    #${record}    Wait Until Keyword Succeeds    240s    10s    Get ATL Events    PLAN_VALIDATE_IND    Nemuadmin    ${additionalText}
	#${length}    Get Length    ${record}
    #Should Be True    ${length} < 4000
    #Teardown with Emssim
#	Should Be True    ${case2}
#    Log    'Cover in A_a01'

#CB006796-C_ 01-BTS event-log file shall be compliant with OATS version2_1 schema
#    [Documentation]
#    ...    *****************
#    ...    | 2022.1.08 | 5G22R4 | Xi.wu | first create |
#    ...    BTS event-log file shall be compliant with OATS version2_1 schema
#	Process.Run Process    sudo sed -i 's/oats_2\.1/oats_1\.0/g' /opt/emssim/proxy/reg_socs/soc.xml    shell=True    cwd=/home/ute    timeout=5
#    Setup with Emssim
#    ${timestampbegin}    get current date
#    ${timestampbegin}    convert date    ${timestampbegin}    epoch
#    Clear Events
#    Set Events Format
#    Create ATL Log
#    ${timestampover}    get current date
#    ${timestampover}    convert date    ${timestampover}    epoch
#    Wait Until Keyword Succeeds    240s    10s    Get ATL Events-C    SSH Login operation    toor4nsn
#    Teardown with Emssim
#
#CB006796-C_ 02-NMS continue using oats1_0 for socdataformat to support legacy BTS
#    [Documentation]
#    ...    *****************
#    ...    | 2022.1.08 | 5G22R4 | Xi.wu | first create |
#    ...    BTS event-log file shall be compliant with OATS version2_1 schema
#	Process.Run Process    sudo sed -i 's/oats_1\.0/oats_2\.1/g' /opt/emssim/proxy/reg_socs/soc.xml    shell=True    cwd=/home/ute    timeout=5
#    Setup with Emssim
#    ${timestampbegin}    get current date
#    ${timestampbegin}    convert date    ${timestampbegin}    epoch
#    Clear Events
#    Set Events Format
#    Create ATL Log
#    ${timestampover}    get current date
#    ${timestampover}    convert date    ${timestampover}    epoch
#    Wait Until Keyword Succeeds    240s    10s    Get ATL Events-C    SSH Login operation    toor4nsn
#    Teardown with Emssim

*** Keywords ***
Get ATL Events
    [Arguments]    	${operation}    ${userName}    ${additionalText}
    ${timestampbegin}    get current date
    ${timestampbegin}    convert date    ${timestampbegin}    epoch
    ${Events}    Emss Receive All Message From BTS
	#${Events}    Get Events
	Log    ${Events}
	${EventLength}    Get Length    ${Events}
    FOR    ${i}    IN RANGE   ${EventLength}
        Create File    ${TA_LOG_DIRECTORY}${/}Event_${i}.xml    ${Events[${i}]}
        Should Contain    ${Events[${i}]}    schemaVersion="2.1"
        Should Contain    ${Events[${i}]}    interfaceVersion="2.1"
        ${record}=    Get Record with operation    ${TA_LOG_DIRECTORY}${/}Event_${i}.xml    ${operation}    ${additionalText}    ${userName}
        ${result}=    Run Keyword And Return Status    Should Not Be Empty    ${record}
        Run Keyword If    '${result}'=='True'    Exit For Loop
    END
    Should Be True    ${result}
    [Return]    ${record}

Emss Receive All Message From BTS
    [Arguments]    ${parameter}=ne3scommon:contentType    ${value}=oats
    ${Events}    Get Events
    @{list}    create list
    FOR    ${i}    IN    @{Events}
        ${result}=    Run Keyword And Return Status    Check Emss Receive Soap Message Value    ${i}    ${parameter}    ${value}
        ${num}=    Evaluate    ${num}+1
        Run Keyword If    '${result}'=='True'    Append To List    ${list}    ${Events[${num}]}
    END
    [Return]    ${list}


Get Record with operation
    [Arguments]    	${RUEM_File}    ${operation}    ${additionalText}    ${userName}
    ${record_list}    Gzip_uncompress.Filter Record In RUEM Log     ${RUEM_File}    ${operation}
	Log     ${record_list}
    @{record}    Create List
    FOR    ${entry}    IN    @{record_list}
        ${status}=    Run Keyword And Return Status    Check Record Details    ${entry}    ${operation}    ${additionalText}    ${userName}
        Run Keyword If    ${status}==True    Append To List    ${record}    ${entry}
    END
    Log    ${record}
    [Return]    ${record}

Check Record Details
    [Arguments]    ${record}    ${operation}    ${additionalText}    ${userName}=Nemuadmin    ${logStatus}=Success
    Should Not Be Empty    ${record['sessionTime']}
    Should Be Equal As Strings    ${record['userName']}    ${userName}
    Should Be Equal As Strings    ${record['logStatus']}    ${logStatus}
    Should Contain    ${record['operation']}    ${operation}
    Should Contain    ${record['additionalText']}    ${additionalText}
    Should Not Contain    ${record['additionalText']}    correlationId=
    Should Not Contain    ${record['additionalText']}    fragmentNumber=

Get ATL Events-C
    [Arguments]    	${operation}    ${userName}
    ${timestampbegin}    get current date
    ${timestampbegin}    convert date    ${timestampbegin}    epoch
    ${Events}    Get Events
	${EventLength}    Get Length    ${Events}
    FOR    ${i}    IN RANGE   ${EventLength}
        @{splitted}    Split String    ${Events[${i}]}    \n\r\n
        Create File    ${TA_LOG_DIRECTORY}${/}Event_${i}.xml     ${splitted[0]}
        ${record}=    Get Record with operation-C    ${TA_LOG_DIRECTORY}${/}Event_${i}.xml    ${operation}	   ${userName}
        ${result}=    Run Keyword And Return Status    Should Not Be Empty    ${record}
        Run Keyword If    '${result}'=='True'    Exit For Loop
    END
    Should Be True    ${result}
    Should Contain    ${Events[${i}]}    schemaVersion="2.1"
    Should Contain    ${Events[${i}]}    interfaceVersion="2.1"

Get Record with operation-C
    [Arguments]    	${RUEM_File}    ${operation}    ${userName}
    ${record_list}    Gzip_uncompress.Filter Record In RUEM Log     ${RUEM_File}    ${operation}
    Log     ${record_list}
    @{record}    Create List
    FOR    ${entry}    IN    @{record_list}
        ${status}=    Run Keyword And Return Status    Check Record Details-C    ${entry}    ${operation}    ${userName}
        Run Keyword If    ${status}==True    Append To List    ${record}    ${entry}
    END
    Log    ${record}
    [Return]    ${record}

Check Record Details-C
    [Arguments]    ${record}    ${operation}    ${userName}=toor4nsn    ${logStatus}=Success    ${clientAddress}=192.168.255.126
    Should Not Be Empty    ${record['sessionTime']}
    Should Be Equal As Strings    ${record['userName']}    ${userName}
    Should Be Equal As Strings    ${record['logStatus']}    ${logStatus}
    Should Contain    ${record['operation']}    ${operation}
    Should Be Equal As Strings    ${record['clientIPAddress']}    ${clientAddress}

Create ATL Log
    ${timestampbegin}    Get Timestamp
    Sleep    1s
    Connect To Bts
    #Disconnect to bts
    Sleep    1s
    ${timestampover}    Get Timestamp
    [Return]    ${timestampbegin}    ${timestampover}
