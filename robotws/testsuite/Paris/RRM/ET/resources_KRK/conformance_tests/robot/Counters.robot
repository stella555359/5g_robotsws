*** Settings ***
Documentation                       Module to provide services to manage pmcounters

Resource          ../Pm/pmc.robot
Resource          Tools.robot

*** Variables ***
${pmCollectSubDir}            pm_files

*** Keywords ***

Collect PM files from BTS
    [Documentation]    Collect PM files and return the latest PM file with directory.
    ...                DEFINITIONS for counter name, object, object id inside a PM file:
    ...                A counter is defined by 1) Name 2) object associated or suppoted to this counter 3) id of this object
    ...                For instance M55308C18002 is supported by a object like this <DN>PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1</DN> (see PM xml file)
    ...                So the object is NRCELL and the id of this object is 1 (extracted from NRCELL-1)
    ...                If the object is <DN>PLMN-PLMN/MRBTS-1/NRBTS-2</DN>,
    ...                the object is NRBTS and the id of this object is 2 (extracted from NRBTS-2)
    [Arguments]    ${pm_files_path}
    ${pm_path}    Set variable    ${EMPTY}
    Empty dir if needed       ${pm_files_path}
    ${pm_path}    Extract Latest PM File From BTS    ${pm_files_path}
    Run Keyword If    '${pm_path}' == '${EMPTY}'   Fail		Collect Pm failed
    [Return]    ${pm_path}

Retrieve Latest Single Counter Value From Pm File
    [Documentation]   Retrieve the latest (chronological order) single counter value from a PM file
    ...               with arguments
    ...               ${pm_path}: complete path of PM xml
    ...               ${counter_name}: counter name
    [Arguments]    ${pm_path}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    get_latest_single_counter_value       ${pm_path}      ${counter_name}
    ${msg}=    set variable    KW: Retrieve Latest Single Counter Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log      ${msg}
    [Return]    ${counter_value_retrieved}

Retrieve Earliest Single Counter Value From Pm File
    [Documentation]   Retrieve earliest (chronological order) single counter value from a PM file
    ...               with arguments
    ...               ${pm_path}: complete path of PM xml
    ...               ${counter_name}: counter name
    [Arguments]    ${pm_path}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    get_earliest_single_counter_value       ${pm_path}      ${counter_name}
    ${msg}=    set variable    KW: Retrieve Earliest Single Counter Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log      ${msg}
    [Return]    ${counter_value_retrieved}

Retrieve Latest Single Counter Value From Pm File with CellID
    [Documentation]   Retrieve the latest (chronological order) single counter value from a PM file with CellID
    ...               with arguments
    ...               ${pm_path}: complete path of PM xml
    ...               ${counter_name}: counter name
    ...               ${CellID}: cell id
    [Arguments]    ${pm_path}    ${counter_name}   ${CellID}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    get_latest_single_counter_value_with_CellID       ${pm_path}      ${counter_name}   ${CellID}
    ${msg}=    set variable    KW: Retrieve Latest Single Counter Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log      ${msg}
    [Return]    ${counter_value_retrieved}


Retrieve NRCell Counter Value From Pm File
    [Documentation]   Retrieve NRCell Counter (Counter with supported object = NRCELL) value from a PM file and return it
    ...               with arguments
    ...               ${pm_path}: complete path of PM xml
    ...               ${counter_name}: counter name
    [Arguments]    ${pm_path}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    Fetch From File Counter Value By Object
    ...                           ${pm_path}    NRCELL    ${counter_name}
    ${msg}=    set variable    KW: Retrieve NRCell Value From Pm File: Retrieve Counter failed for ${counter_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log		${msg}
    [Return]    ${counter_value_retrieved}

Retrieve Counter Value From Pm File For Object
    [Documentation]   Retrieve Counter (Counter with supported object defined in an argument) for an object value from a PM file
    ...               with arguments
    ...               ${pm_path}: complete path of PM xml
    ...               ${object_name}: counter supported object name
    ...               ${counter_name}: counter name
    [Arguments]    ${pm_path}    ${object_name}    ${counter_name}
    ${counter_value_retrieved}=    set variable    ${EMPTY}
    ${counter_value_retrieved}    Fetch From File Counter Value By Object
    ...                           ${pm_path}    ${object_name}    ${counter_name}
    ${msg}=    set variable    KW: Retrieve Value From Pm File For Object: Retrieve failed for ${counter_name} ${object_name}
    Run Keyword If    "${counter_value_retrieved}" == "${EMPTY}"   BuiltIn.log		${msg}
    [Return]    ${counter_value_retrieved}

Retrieve Counter Sum of Values From Pm Files For Object
    [Documentation]    Retrieve all values of a counter in all PM xml files
    ...                Return and provide the sum of all these values
    ...                with arguments
    ...                ${pm_path}: complete path of PM xml
    ...                &{expected_dict}: a dictonnay with keys : counter obj
    ...                for ex &{expected_dict}    obj=NRCELL   counter=M55308C18002
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${object_name}=     set variable    &{expected_dict}[obj]
    ${counter_name}=    set variable    &{expected_dict}[counter]
    ${sumCal}      Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...            ${pm_path}      ${object_name}      ${counter_name}
    [Return]    ${sumCal}

Retrieve Counter Sum of Values From Pm Files For Object with ID
    [Documentation]    Retrieve all value of a counter (supported by the object defined in an argument) in all PM xml files
    ...                in all PM xml files
    ...                calculate the sum of these values and return it
    ...                with arguments
    ...                ${pm_path}: complete path of PM xml
    ...                &{expected_dict}: a dictonnay with keys : counter obj objId
    ...                for ex &{expected_dict}    counter=M55118C05505   obj=NRCELL objId=1
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${object_name}=     set variable    &{expected_dict}[obj]
    ${counter_name}=    set variable    &{expected_dict}[counter]
	${object_id}=    set variable    &{expected_dict}[objId]
    ${sumCal}      Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...            ${pm_path}      ${object_name}      ${counter_name}    ${object_id}
    [Return]    ${sumCal}

Retrieve Sum of Values Counter From Pm Files with CellID
    [Documentation]    Retrieve all value of a counter (supported by the object NRCELL) in all PM xml files
    ...                calculate the sum of these values and return it
    ...                with arguments
    ...                ${pm_path}: complete path of PM xml
    ...                &{expected_dict}: a dictonnay with keys : counter objId
    ...                for ex &{expected_dict}    counter=M55118C05505   objId=1
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${counter_name}=    set variable    &{expected_dict}[counter]
	${object_id}=    set variable    &{expected_dict}[objId]
    ${sumCal}      Retrieve Sum of Values From A Pm File with CellID
    ...            ${pm_path}      ${counter_name}    ${object_id}
    [Return]    ${sumCal}

Verify Object Counter Sum Of Values
    [Documentation]    Retrieve all value of a counter in all PM xml files
    ...                calculate the sum of these values and compare it with an expected value
    ...                And verify if the sum is equal to the expected value and return the result
    ...                with arguments
    ...                ${pm_path}: complete path of PM xml
    ...                &{expected_dict}: a dictonnay with keys : counter obj expectedVal
    ...                for ex &{expected_dict}   counter=M55320C09009   obj=NRBTS     expectedVal=10
    [Arguments]    ${pm_path}     &{expected_dict}
    ${res}=    set variable    True
    ${objectName}=     set variable    &{expected_dict}[obj]
    ${counterName}=    set variable    &{expected_dict}[counter]
    ${iExpected}=     evaluate      &{expected_dict}[expectedVal]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                 ${pm_path}      ${objectName}    ${counterName}
    Debug Dated Log     valRetrieved= ${valRetrieved} iExpected= ${iExpected}
    ${res}=     evaluate    ${valRetrieved} == ${iExpected}
    [Return]    ${res}

Verify Object Counter Sum Of Values In A Range
    [Documentation]    Retrieve all value of a counter in all PM xml files
    ...                calculate the sum of these values and compare it with a range Min and Max
    ...                And verify if the sum is in the range and return the result
    ...                with arguments
    ...                ${pm_path}: complete path of PM xml
    ...                &{expected_dict}: a dictonnay with keys : counter obj min max
    ...                for ex &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    ${pm_path}     &{expected_dict}
    Debug Dated Log     pm_path= ${pm_path}
    # ${res}=    set variable    True
    ${objectName}=     set variable    &{expected_dict}[obj]
    ${counterName}=    set variable    &{expected_dict}[counter]
    ${iMin}=     evaluate      &{expected_dict}[min]
    ${iMax}=     evaluate      &{expected_dict}[max]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                ${pm_path}      ${objectName}    ${counterName}
    Debug Dated Log     valRetrieved= ${valRetrieved} iMin= ${iMin} iMax= ${iMax}
    # Compare ivalue with Min Max     ${valRetrieved}       ${iMin}       ${iMax}
    ${result}=       Run Keyword And Return Status     Compare ivalue with Min Max
    ...              ${valRetrieved}       ${iMin}       ${iMax}
    Debug Dated Log     result= ${result}
    [Return]    ${result}

Verify Object Counter with ID Sum Of Values In A Range
    [Documentation]                 Retrieve all value of a counter in all PM xml files
    ...                             calculate the sum of these values and compare it with a range
    ...                             with arguments
    ...                             ${pm_path}: complete path of PM xml
    ...                             ${pm_obj_id}: Counter object id
    ...                             &{expected_dict}: a dictonnay with keys : counter obj min max
    ...                             for ex &{expected_dict}   counter=M55320C09009   obj=NRBTS     min=9444      max=9555
    [Arguments]    ${pm_path}     ${pm_obj_id}      &{expected_dict}
    Debug Dated Log     pm_path= ${pm_path}
    Debug Dated Log     pm_obj_id= ${pm_obj_id}
    # ${res}=    set variable    True
    ${objectName}=     set variable    &{expected_dict}[obj]
    ${counterName}=    set variable    &{expected_dict}[counter]
    ${iMin}=     evaluate      &{expected_dict}[min]
    ${iMax}=     evaluate      &{expected_dict}[max]
    ${valRetrieved}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                ${pm_path}      ${objectName}    ${counterName}     ${pm_obj_id}
    Debug Dated Log     valRetrieved= ${valRetrieved} iMin= ${iMin} iMax= ${iMax}
    # Compare ivalue with Min Max     ${valRetrieved}       ${iMin}       ${iMax}
    ${result}=       Run Keyword And Return Status     Compare ivalue with Min Max
    ...              ${valRetrieved}       ${iMin}       ${iMax}
    Debug Dated Log     result= ${result}
    [Return]    ${result}

Check At Least One Value Is In Criteria From Pm Files For Object With ID
    [Documentation]                 Retrieve each value of a counter in all PM xml files
    ...                             Check if a least one value is fulfil the criteria defined with:
    ...                             expected_value and ${comparison} that could be '>=' '>' '<=' '<' '=='
    ...                             The counter to retrieve is defined with   &{expected_dict} that contains
    ...                             counter=<CounterName>    obj=<CounterSupprtedObject>     objId=<CounterSupprtedObject> example:
    ...                             counter=M55308C17002    obj=NRCELL     objId=1
    [Arguments]    ${pm_path}       ${expected_value}	    ${comparison}       &{expected_dict}
    Debug Dated Log          pm_path:${pm_path}
    ${object_name}=     set variable    &{expected_dict}[obj]
    ${counter_name}=    set variable    &{expected_dict}[counter]
 	${object_id}=    set variable    &{expected_dict}[objId]
    Set suite variable    ${curPmDir}    ${pm_path}/${pmCollectSubDir}
    ${sumCal}=  evaluate     0
    Debug Dated Log          curPmDir:${curPmDir}
    @{filesList}        List Directory      ${curPmDir}     *.xml
    ${counter_values}  Extract Counter Different Values From PM Files in dir
    ...     ${curPmDir}       ${object_name}    ${counter_name}        ${object_id}
	${nbFound}=    Set Variable    0
	FOR        ${elem}   IN  @{counter_values}
		${ret}=    Set Variable    ${False}
        Debug Dated Log  elem=${elem}
        ${ret}=  Compare with Expected Value  		${comparison}    ${expected_value}     ${elem}
        Debug Dated Log  ret=${ret}
		${nbFound}=      Run Keyword if      ${ret}==${True}        Evaluate     ${nbFound} + 1
        ...                 ELSE             Evaluate       ${nbFound} + 0
        Debug Dated Log  nbFound=${nbFound}
    END
    ${retKW}=       Run Keyword if      ${nbFound}>0        Set Variable   ${True}
    ...             ELSE        Set Variable   ${False}
    [Return]    ${retKW}

### internal usage only
Retrieve Counter Sum of Values From Pm Files For Object With Name
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${pm_path}    ${object_name}    ${counter_name}      ${object_id}=1
    Debug Dated Log          xxx_pm_path:${pm_path}
    Debug Dated Log          xxx_object_id:${object_id}
    Set suite variable    ${curPmDir}    ${pm_path}/${pmCollectSubDir}
    ${sumCal}=  evaluate     0
    Debug Dated Log          curPmDir:${curPmDir}
    @{filesList}        List Directory      ${curPmDir}     *.xml
    ${counter_values}  Extract Counter Different Values From PM Files in dir
        ...     ${curPmDir}       ${object_name}    ${counter_name}        ${object_id}
    FOR        ${counter_elem}   IN  @{counter_values}
        ${sumCal}=  evaluate   ${counter_elem}+${sumCal}
    END
    Debug Dated Log  sumCal= ${sumCal}
    [Return]    ${sumCal}

Retrieve Sum of Values From A Pm File with CellID
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${pm_path}    ${counter_name}      ${object_id}=1
    Debug Dated Log          xxx_pm_path:${pm_path}
    Debug Dated Log          xxx_object_id:${object_id}
    Set suite variable    ${curPmDir}    ${pm_path}/${pmCollectSubDir}
    ${sumCal}=  evaluate     0
    Debug Dated Log          curPmDir:${curPmDir}
    @{filesList}        List Directory      ${curPmDir}     *.xml
    Debug Dated Log          filesList:@{filesList}
    FOR        ${el}   IN  @{filesList}
        Set suite variable    ${fileToCheck}    ${pm_path}/${pmCollectSubDir}/${el}
        Debug Dated Log  fileToCheck= ${fileToCheck}
        ${sumInAFile}  Get Sum Of Counter Values With CellId
        ...     ${fileToCheck}    ${counter_name}        ${object_id}
        Debug Dated Log  sumInAFile= ${sumInAFile}
        ${sumCal}=  evaluate   ${sumInAFile}+${sumCal}
    END
    Debug Dated Log  sumCal= ${sumCal}
    [Return]    ${sumCal}

Empty dir if needed
    [Documentation]                 INTERNAL USAGE
    [Arguments]   ${pm_files_path}
    Remove Directory		${pm_files_path}    recursive=True

Compare value with Min Max
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${val}       ${vMin}     ${vMax}
    ${iVal}=    evaluate      ${val}
    ${iMin}=    evaluate      ${vMin}
    ${iMax}=    evaluate      ${vMax}
    should be true     ${iMin} < ${val}
    should be true     ${iMax} > ${val}

Compare ivalue with Min Max
    [Documentation]                 INTERNAL USAGE
    [Arguments]    ${val}       ${iMin}     ${iMax}
    should be true     ${iMin} <= ${val}
    should be true     ${iMax} >= ${val}

