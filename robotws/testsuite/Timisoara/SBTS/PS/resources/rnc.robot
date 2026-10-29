*** Settings ***
Library  taf.rnc.oms.nwi3

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  22.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-214 - resource file creation
...  13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-378 - new KW: Clean Pegasus Project In Workspace
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
Setup Connection to OMS
    [Documentation]  Setup OMS connection.

    Clean Pegasus Project In Workspace
    ${status}  Run Keyword And Return Status  Setup nwi3  ${tl.rncs[0].rnc_id}  ${tl.rncs[0].oms_ip.v4}
    ...  oms_password=${tl.rncs[0].logging_ssh_connection_details.password}
    IF  ${status}  Log To Console  NWI3 connection complete with RNC-${tl.rncs[0].rnc_id} OMS IP: ${tl.rncs[0].oms_ip.v4}


Set WBTS Values
    [Documentation]  Set given parameters values in WBTS object in OMS.
    [Arguments]  ${parameter}  ${value}

    Set WBTS Parameters  ${WBTS_ID}  ${parameter}=${value}
    Log To Console  Set the parameter ${parameter} for WBTS-${WBTS_ID} as ${value}
    Clean Pegasus Project In Workspace


Get WBTS Value
    [Documentation]  Get WBTS parameter value from OMS.
    [Arguments]  ${parameter}

    ${value}  Get WBTS Parameter  ${WBTS_ID}  ${parameter}
    Clean Pegasus Project In Workspace

    RETURN  ${value}


Clean Pegasus Project In Workspace
    [Documentation]  Clean up solution for execution error:
    ...  Pegasus execution error: Project with name: < pegasus_project > already exist in the workspace.
    [Arguments]  ${PEGASUS_PATH}=/tmp/Pegasus

    ${pegasus_exist}  Run Keyword And Return Status  OperatingSystem.Directory Should Not Exist  ${PEGASUS_PATH}
    IF  not ${pegasus_exist}  Run Keyword And Ignore Error  Run  rm -r ${PEGASUS_PATH}
