*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com

Library    Collections
Library    OperatingSystem
Library    DateTime
Library    taf.analyzer.pdml
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    testsuite.Wroclaw.RRM.resources.webui.WebuiInterface  WITH NAME  WebUI
Library    taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library    taf.collectors.tcpdump     WITH NAME    tcpdump
Library    taf.collectors.core        WITH NAME    core
Library    taf.analyzer.pdml          WITH NAME    pdml
Library    taf.collectors.btslog  WITH NAME   btslog

*** Keywords ***
Convert mW To dbm
    [Arguments]    ${val_W}
    [Documentation]     This KW converts mW to dbm.
    ...                 Argument         |   Value
    ...                 ---------------------------------
    ...                 val_W           |   [float]
    ${result} =   Evaluate    10*(math.log10(${val_W}))   math
    [Return]   ${result}


Convert dbm To mW
    [Arguments]    ${val_dbm}
    [Documentation]     This KW converts dbm to mW.
    ...                 Argument         |   Value
    ...                 ---------------------------------
    ...                 val_dbm           |   [float]
    ${res} =   Evaluate   10**((${val_dbm})/10.0)
    [Return]    ${res}


Is in interval
    [Arguments]    ${val}    ${min}    ${max}
    [Documentation]     This KW check if val is in interval [min, max]
    ...                 Argument      |   Value
    ...                 ---------------------------------
    ...                 val           |   [float]
    ...                 ---------------------------------
    ...                 min           |   [float]
    ...                 ---------------------------------
    ...                 max           |   [float]
    ${bool} =    Set variable if    ${val} >= ${min} and ${val} <= ${max}    ${TRUE}    ${FALSE}
    [Return]  ${bool}

Is greater than zero
    [Arguments]    ${val}
    ${bool} =    Set variable if    ${val} > 0    ${TRUE}    ${FALSE}
    [Return]  ${bool}

Check if values are within the margin of error
    [Arguments]    ${value1}    ${value2}    ${margin_of_error}
    ...            ${msg_pass}=__Test passed: Power values are in the margin of ${margin_of_error} dB error.
    ...            ${msg_fail}=Power values are out of the margin of ${margin_of_error} dB error.
    [Documentation]     This KW check if difference between value1 and value2 is bigger than the margin of error.
    ...                 Argument         |   Value
    ...                 ---------------------------------
    ...                 value1           |   [float]
    ...                 ---------------------------------
    ...                 value2           |   [float]
    ...                 ---------------------------------
    ...                 margin_of_error  |   [float]
    ${result} =   Evaluate    abs(${value1}-${value2})
    ${bool} =   Set variable if    ${result} < ${margin_of_error}    ${TRUE}    ${FALSE}
    Run keyword if      ${bool}
    ...                 Log to console  ${msg_pass}
    ...                 ELSE  Fail  msg=${msg_fail}
