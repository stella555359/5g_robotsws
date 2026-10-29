*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage the connexion to color boxes.
...
...            == Description ==
...            The principle is to open a connection of a given color on a color box.
...            Opening the connection creates a context that contains the connection to the box and its color.
...            Then it is possible to perform actions on the connection.
...            At the end it is possible to close the connection and free the context.
...
...            *Main keywords are:*.
...            | Open Color Session  | <boxe>    | <color>   |
...            | Execute Command     | <context> |
...            | Close Color Session | <context> |           |
...
...            *Constaints*.
...            The _color session_ openning is limited to the three colors:
...             - YELLOW
...             - RED
...             - GREEN
...
...            The commands that can be executed in a _color session_ depend on the color of the connection.
...
...            *Example:*.
...            | ${session 1} \ \ \ \ \ \ \ \ \ \ Open Color Session \ \ \ \ \ color=GREEN
...            | ${result} \ \ \ \ \ \ \ \ \ \ \ \ \ Execute Command \ \ \ \ \ \ \ \ \ context=${session 1}
...            | ${statut} \ \ \ \ \ \ \ \ \ \ \ \ \ Get Substring \ \ \ \ \ \ \ \ \ \ ${result} \ \ \ \ \ \ \ \ 0 \ \ \ \ \ \ 4
...            | Run keyword If \ \ \ \ \ \ \ \ ${statut} == '[OK]' \ \ \ \ Log to console \ \ \ Execution OK
...            | Close Color Session \ \ \ context=${session 1}

Library          Collections

*** Variables ***
@{Colors}        YELLOW    RED    GREEN

@{cmd_yellow}    List of yellow subcolor
...              Activate one yellow subcolor
...              Deactivate one yellow subcolor
...              Deactivate all yellow subcolors
...              Mixed all yellow subcolors

@{cmd_red}       List of red subcolor
...              Activate one red subcolor
...              Deactivate one red subcolor
...              Deactivate all red subcolors
...              Mixed all red subcolors

@{cmd_green}     List of green subcolor
...              Activate one green subcolor
...              Deactivate one green subcolor
...              Deactivate all green subcolors
...              Mixed all green subcolors

@{cmd_clors}     ${cmd_yellow}    ${cmd_red}    ${cmd_green}

${cpt_context}   0

@{contexts}


*** Keywords ***
Create New Context
    [Documentation]    INTERNAL USAGE
    [Arguments]           ${boxe}              ${color}
    &{context}=           Create Dictionary    boxe=${boxe}    color=${color}    id=${cpt_context}
    Append To List        ${contexts}          ${context}
    ${ret}=               Set Variable         ${cpt_context}
    ${res}=               Evaluate             ${cpt_context} + 1
    Set Suite Variable    ${cpt_context}       ${res}
    [Return]              ${ret}


Return Bad Context
    [Documentation]    INTERNAL USAGE
    [Return]           -1


Open Color Session
    [Documentation]    Open a _color session_ by connecting to a color box with an authorized color.
    ...                The keywords returns a number. If the number is greater than or equal to 0 then the session openning is performed.
    ...                Otherwise the session is not openned because there was an error.
    ...
    ...                *Argument details:*
    ...                 - boxe: Address of color box.
    ...                 - color: Color to open the _color session_.
    [Arguments]               ${boxe}    ${color}
    ${statut}         ${res}=    Run Keyword And Ignore Error    List Should Contain Value    list_=${Colors}    value=${color}
    ${ret}=           Run Keyword If    '${statut}' == 'PASS'
    ...                   Create New Context     boxe=${boxe}    color=${color}
    ...               ELSE
    ...                   Return Bad Context
    [Return]          ${ret}


Check Good Context
    [Documentation]    INTERNAL USAGE
    [Arguments]           ${ctx}              ${id}
    ${statut}    ${res}=    Run Keyword And Ignore Error    Dictionary Should Contain Item    dictionary=${ctx}    key=id    value=${id}
    ${found}=    Run Keyword If    '${statut}' == 'PASS'
    ...                Return From Keyword               ${id}
    ...          ELSE
    ...                Return From Keyword               -1
    [Return]     ${found}


Reset Context
    [Documentation]    INTERNAL USAGE
    [Arguments]           ${id}
    ${context}=          Get From List            list_=${contexts}    index=${id}
    Set To Dictionary    ${context}               id                   -1
    Set List Value       list_=${contexts}        index=${id}          value=${context}


Check Context Exist
    [Documentation]    INTERNAL USAGE
    [Arguments]           ${id}
    ${found}=        Set Variable     -1
    FOR    ${ctx}    IN        @{contexts}
        ${found}=    Run Keyword If    ${found} == -1
        ...                  Check Good Context     ctx=${ctx}    id=${id}
        ...          ELSE
        ...                  Return From Keyword    ${id}
    END
    [Return]     ${found}


Close Color Session
    [Documentation]    Close a _color session_ allready openned via the keyword 'Open Color Session'.
    ...                The keywords returns a number. If the context number is found then the session is closed and context number is returned.
    ...                Otherwise it is an erreor and -1 is returned.
    ...
    ...                *Argument details:*
    ...                 - context: Context number of the _color session_.
    [Arguments]      ${context}
    ${found}=        Check Context Exist     id=${context}
    Run Keyword If   ${found} > -1           Reset Context    id=${context}
    [Return]         ${found}


Execute Command
    [Documentation]    Execute a command on a _color session_.
    ...
    ...                *Argument details:*
    ...                 - context: Context number of the _color session_.
    [Arguments]      ${context}
    ${found}=        Check Context Exist     id=${context}
    ${ret}=          Run Keyword If          ${found} > -1
    ...                   Return From Keyword    '[OK]'
    ...              ELSE
    ...                   Return From Keyword    '[KO]'
    [Return]         ${ret}
