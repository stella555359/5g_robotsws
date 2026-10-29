*** Settings ***
Documentation     [PURPOSE] ssh connection General keywords
Library  SSHLibrary


*** Variables ***
${DEFAULT}      DEFAULT
${ROOT}         ROOT


*** Keywords ***
Open SSH Connection
    [Documentation]    Short description.
    SSHLibrary.open connection   ${netact}[SDV_WEBSPHERE_APPSERVER_PRIMARY_IP]    alias=${DEFAULT}
    SSHLibrary.login    ${netact}[SDV_DESKTOP_ADMIN_USER]    ${netact}[SDV_DESKTOP_ADMIN_PASSWORD]

Close SSH Connection
    [Documentation]    Short description.
    SSHLibrary.Close All Connections

Open SSH Connection As Root
    [Documentation]    Short description.
    SSHLibrary.open connection    ${netact}[SDV_WEBSPHERE_APPSERVER_PRIMARY_IP]   alias=${ROOT}
    SSHLibrary.login    ${netact}[SDV_DESKTOP_ADMIN_USER]    ${netact}[SDV_DESKTOP_ADMIN_PASSWORD]

Switch Connection To Root
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${ROOT}

Switch Connection To Default
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${DEFAULT}
