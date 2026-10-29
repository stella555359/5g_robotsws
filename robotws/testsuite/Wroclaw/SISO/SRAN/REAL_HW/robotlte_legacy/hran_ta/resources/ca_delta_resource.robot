
*** Keywords ***
Validate Delta Against SCF
    [Documentation]
    ...  KW Validates Delta against SCF file depending on ${mode}
    ...  ${mode} accepts 'excluded' or 'included' in case of Delta file
    ...  KW uses test Variables:
    ...  DELTA_JSON_FILE - json content to get it use method: json.loads('''${xxx}''')  json
    ...  SCF_XML - path to scf.xml
    ...
    ...  Author: Daniel.Bartkowiak@nokia.com

    [Arguments]  ${mode}
    [Timeout]  15 min
    Log  Validate Delta Against SCF  console=${TRUE}
    FOR  ${scf_object}  IN  @{DELTA_JSON_FILE}
      Log  Checking delta object with distName ${scf_object['distName']}  console=True
      Verify parameters values in SCF object  ${scf_object['distName']}  ${scf_object['parameters']}  ${mode}
    END
    Run Keyword If  "${mode}"=="excluded"  Log  All parameters in delta JSON have different values than parameters in SCF  console=${TRUE}
    Run Keyword If  "${mode}"=="included"  Log  All parameters in delta JSON have the same values than parameters in SCF  console=${TRUE}

Verify parameters values in SCF object
    [Documentation]
    ...  KW for simple check if parameter from given delta object has expected value in SCF text field.
    ...  KW supports parameter as list
    ...  Author: Daniel.Bartkowiak@nokia.com

    [Arguments]  ${object_dist_name}  ${object_parameters}  ${mode}
    FOR  ${parameter}  IN  @{object_parameters}
      Log  Checking ${parameter['parameterName']} parameter value in SCF  console=True
      ${is_list}=  Run Keyword And Return Status  Get From List  ${parameter['value']}  0
      Run Keyword If  ${is_list}
      ...  Check List Element    ${object_dist_name}  ${parameter}  ${mode}
      ...  ELSE
    ...  Check Single Element  ${object_dist_name}  ${parameter}  ${mode}
    END

Check List Element
    [Documentation]
    ...  Author: Daniel.Bartkowiak@nokia.com

    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}
    ${var_type}=  Evaluate  type(${parameter['value'][0]}).__name__
    Run Keyword If  "${var_type}"!="dict"  Check Simple List Element  ${object_dist_name}  ${parameter}  ${mode}
    ...  ELSE  Check List Of Dict Element  ${object_dist_name}  ${parameter}  ${mode}

Check List Of Dict Element
    [Documentation]
    ...  Author: Daniel.Bartkowiak@nokia.com

    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}
    FOR  ${list_element}  IN  @{parameter['value'][0]}
      ${value}=  Get From Dictionary  ${parameter['value'][0]}  ${list_element}
      ${status}=  Run Keyword And Return Status  Element Text Should Be  ${SCF_XML}  ${value}
      ...  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]/child::*/child::*[@name="${list_element}"]
      Run Keyword If  "${mode}"=="excluded" and ${status}     Fail  ${parameter['parameterName']} is included in SCF
      Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF
    END

Check Simple List Element
    [Documentation]
    ...  Author: Daniel.Bartkowiak@nokia.com

    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}
    FOR  ${list_element}  IN  @{parameter['value']}
      ${status}=  XML.Evaluate Xpath  ${SCF_XML}
      ...  boolean(//*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]/p[contains(text(), "${list_element}")])
      Run Keyword If  "${mode}"=="excluded" and ${status}     Fail  ${parameter['parameterName']} is included in SCF
      Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF
    END

Check Single Element
    [Documentation]
    ...  Author: Daniel.Bartkowiak@nokia.com

    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}
    ${status}=  Run Keyword And Return Status  Element Text Should Be
    ...  ${SCF_XML}  ${parameter['value']}  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]
    Run Keyword If  "${mode}"=="excluded" and ${status}     Fail  ${parameter['parameterName']} is included in SCF
    Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF

Perform Delta File Commissioning
    Log    \nBTS Delta commissioning procedure on bts_id node=${BTS_ID} started    console=${TRUE}
    Log    \nSource File = ${DELTA_JSON_FILE}.\nProcedure Parameters: Ignore Errors = ${ignore_errors}.    console=${TRUE}
    Run Keyword And Ignore Error    Wait Sw Update Possible
    ...    bts_ready=True
    ...    readiness_timeout=900
    ...    timeout=1000
    ...    connection=${BTS_ID}
    ${result}    Run Keyword And Continue On Failure    Perform Delta Recommissioning
    ...    delta_file=${DELTA_FOR_RECOMM}
    ...    skip_parameter_relation_errors=${IGNORE_ERRORS}
    ...    should_activate=True
    ...    timeout=${RECOMMISSIONING_TIMEOUT}
    ...    connection=${BTS_ID}
    ${status}    ${response}=    Run Keyword And Ignore Error
    ...  Set Variable    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    Run Keyword If       '${response}' != 'Success'    Log   Recommissioning failed due to  ${response}
    Should Be True       '${response}' == 'Success'
    Log    \nBTS template commissioning procedure on bts_id node=${BTS_ID} finished.     console=${TRUE}
    [Return]    ${status}   ${result}
