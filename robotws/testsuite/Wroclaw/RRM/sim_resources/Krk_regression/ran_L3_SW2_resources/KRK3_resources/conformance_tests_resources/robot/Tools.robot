*** Settings ***
Library                             OperatingSystem
Library                             Collections
Library                             String
Library                             DateTime
Library                             ../python/StringTool.py

*** Variables ***

*** Keywords ***
#===================================
# TRACES
#===================================
Dated Log
    [Documentation]                 Trace a string into console, prefixed with a timestamp
    ...                             Example : Dated log     Starting CellSetup
    ...                             will generated in console following kinf of trace:
    ...                                  [15:59:18] Starting CellSetup
    ...                             If first is set to True, a CarriageReturn is previously printed
    ...                             to ensure trace will start on another line
    ...                             Deep is number of tab to be inserted after time stamp. Default nb is 0
    [Arguments]                     ${msg}                                      ${first}=${False}
    ...                             ${deep}=${0}
    StringTool.datedConsole         str=${msg}                                  deep=${deep}
    ...                             first=${first}

Dated log in file
    [Arguments]                     ${file}
    ...                             ${msg}                                      ${first}=${False}
    ...                             ${deep}=${0}
    StringTool.datedConsoleInFile   file=${LOG_PATH}/${file}                    str=${msg}
    ...                             deep=${deep}                                first=${first}


Dated Log New Line
    [Documentation]                 Invoke a Carriage return, then Trace a string into console, prefixed with a timestamp
    [Arguments]                     ${msg}
    Dated Log                       ${msg}                                      first=${True}

Traced Sleep
    [Documentation]                 Trace a log detailing duration of next sleep, then perform the sleep
    [Arguments]                     ${duration}                                 ${msg}=unspecified reason
    ${end_wait_time}                Get Current date                            increment=${duration}
    Dated Log                       Waiting ${duration} for ${msg} until ${end_wait_time}
    Sleep                           ${duration}

Set Debug Mode
    [Documentation]                 Set Debug Mode by setting global variable ${SUITE_DEBUG_MODE}
    ...                             before calling 'Debug Log Dated'
    [Arguments]                     ${val}=${True}
    Set Suite Variable              ${SUITE_DEBUG_MODE}    ${val}

Debug Dated Log
    [Documentation]                 Log with 'Dated Log' if debug mode is set by 'Set Debug Mode'
    ...                             Example of usage: 
    ...                             Set Debug Mode      ${True}    
    ...                             Debug Dated Log     Starting CellSetup
    [Arguments]                     ${msg}                                      ${first}=False
    ${result}=                      Run Keyword And Return Status    Variable Should Exist    ${SUITE_DEBUG_MODE}
    Run Keyword If                  ${result}==False       BuiltIn.log           INFO: 'Set Debug Mode' not set   
    ...                             ELSE                    Run Keyword If      ${SUITE_DEBUG_MODE}
    ...                                                     Dated Log           DEBUG: ${msg}        ${first}



#===================================
# Run KW
#===================================
Run Optional Action
    [Documentation]                 Run and trace an action ONLY if a condition is filled
    [Arguments]                     ${optional_operation}=None
    ...                             ${params}=
    Run Keyword If                  '${optional_operation}'!='None'
    ...                             Run and Trace Action
    ...                                 ${optional_operation}               ${params}

Run and Trace Action
    [Documentation]                 Run a KW (with some optional params),
    ...                             but put some traces in console before and after action
    [Arguments]                     ${optional_operation}=None
    ...                             ${params}=
    Dated log                       Starting ${optional_operation}
    Run Keyword And Ignore Error    ${optional_operation}    ${params}
    Dated log                       Ended ${optional_operation}

#===================================
# HTTP Proxy management
#===================================
Backup https proxy
    [Documentation]                 Perform a backup of environment variable <https_proxy>
    ${https_proxy}=                 Get Environment Variable                https_proxy         default=
    Set suite variable              ${https_proxy}
    Set Environment Variable        https_proxy                             ${EMPTY}

Restore https proxy
    [Documentation]                 Perform a restore of environment variable <https_proxy> previously saved
    Set Environment Variable        https_proxy                             ${https_proxy}

#===================================
# MISC
#===================================
Is Var Exist
    [Documentation]                 Check if a variable is defined in robot context
    ...                             Ex: ${status}     Is Var Exist            \${ASIK_SWITCH_TAGS}
    ...                             Will return True or False upon variable is defined
    [Arguments]                     ${var}
    ${status}                       run keyword and return status
    ...                             variable should exist       ${var}
    [Return]                        ${status}

Is Key Exist
    [Documentation]                 Check in a dictionary that a key exist
    [Arguments]                     ${var}
    ...                             ${key}
    ${status}                       run keyword and return status
    ...                             Dictionary should contain key
    ...                             ${var}      ${key}
    [Return]                        ${status}

Dictionary Get
    [Documentation]                 Perform a copy of a dictionary, and return new dictionary
     ...                            Interest is that original one is not modified
    [Arguments]                     ${dico}
    ${copyDico}                     Copy Dictionary     ${dico}
    [Return]                        ${copyDico}

Get Date Epoch
    [Documentation]                 Returns epoch date in string integer format 
    ${date} =                       Get Current Date            result_format=epoch
    ${int_epoch} =                  Convert To Integer          ${date}
    ${str_epoch} =                  Convert To String           ${int_epoch}
    [Return]                        ${str_epoch}

Set Suite Var
    [Arguments]                     ${name}                     ${value}
    # Dated log                       NAME=[${name}] VAL=[${value}]
    Set Suite variable              ${${name}}                  ${value}