*** Settings ***
Documentation     [PURPOSE] SQL query General keywords
Library          SSHLibrary


*** Keywords ***
Run Deletors
    [Documentation]    Short description.
    Run Sql Statement    exec TRC.COR_P_DELETORS.delete_traces

Run Sql Statement
    [Arguments]    ${sql}
    [Documentation]    Executes a single sql statement using sqlplus, returning the result.
    ${out} =    DoQuery    ${sql}
    [Return]    ${out}

DoQuery
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sql}: <description>
    ...        ${user}: <description>
    ...        ${password}: <description>
    ...
    ...    Returns:
    ...        ${out}: <description>
    [Arguments]    ${sql}    ${user}=${netact}[SDV_DB_OMC_USER]    ${password}=${netact}[SDV_DB_OMC_PASSWORD]
    ${query} =    Set Variable
    ...     echo -e "set feedback off\\n set pagesize 0\\n ${sql};" | sqlplus -s ${user}/${password}
    ${out}    ${err} =    SSHLibrary.Execute Command    ${query}    both
    Should Not Contain    ${err}    table or view does not exist
    Should Not Contain    ${out}    ORA
    [Return]    ${out}

RunSqlStatementForSys
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sql}: <description>
    ...
    ...    Returns:
    ...        ${out}: <description>
    [Arguments]    ${sql}
    ${out} =    DoQuery    ${sql}    SYSTEM    manager
    [Return]    ${out}

DoPlSqlQuery
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sql}: <description>
    ...        ${user}: <description>
    ...        ${password}: <description>
    ...
    ...    Returns:
    ...        ${out}: <description>
    [Arguments]    ${sql}    ${user}= ${netact}[SDV_DB_OMC_USER]   ${password}=${netact}[SDV_DB_OMC_PASSWORD]
    ${query} =    Set Variable
    ...     echo -e "set feedback off\\n set pagesize 0\\n ${sql}\n/\ncommit\n/" | sqlplus -s ${user}/${password}
    ${out}    ${err} =    SSHLibrary.Execute Command    ${query}    both
    Should Not Contain    ${err}    table or view does not exist
    Should Not Contain    ${out}    ORA
    [Return]    ${out}
