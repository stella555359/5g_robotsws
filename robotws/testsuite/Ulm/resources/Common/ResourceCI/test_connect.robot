*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in connect.robot for classical deployments.
...   Many KWs from connect.robot are implicitely tested by other suites!


Library     taf.sbts.oam.coam.admin     WITH NAME   admin
Library     taf.transport.ssh           WITH NAME   ssh

Resource    ../gnb.robot
Resource    ../connect.robot
Resource    ../testline.robot


*** Test Cases ***
Test Multiple Setup OAM Http session
    [TAGS]              CONNECT
    FOR     ${_}     IN RANGE    12
        connect.Setup OAM HTTP Session  node_type=gnb   node_id=0
    END

Test Get Connection Parameters
    [TAGS]              CONNECT
    ${ssh_alias}    connect.Connect To Node Common Unit
    ${inst_dict}    connect.Get Ssh Connection Parameters       ${ssh_alias}
    ssh.Disconnect  ${ssh_alias}
    ${keys}         Get Dictionary Keys     ${inst_dict}
    FOR     ${key}  IN  @{keys}
        Log To Console  ${\n}Alias ${ssh_alias} parameter ${key}: ${inst_dict}[${key}]
    END
    [Teardown]      ssh.Reset Cache

Test Check SSH Alias Exist
    [TAGS]              CONNECT
    ${status}       Check SSH Alias Exist   dummy_alias
    Should Not Be True  ${status}
    ${ssh_alias}    connect.Connect To Node Common Unit
    ${status}       Check SSH Alias Exist   ${ssh_alias}
    Should Be True  ${status}
    ${ssh_alias}    connect.Connect To Node Common Unit
    ssh.Disconnect  ${ssh_alias}
    [Teardown]      ssh.Reset Cache

Test Connect to gNB Capacity Unit
    [TAGS]              CONNECT
    ${comu_type}    testline.Get Common Unit Type
    ${capa_type}    testline.Get Capacity Unit Type

    IF          '${comu_type}'=='ASOE'
        @{mcu_list}     Create List
    ELSE IF     '${capa_type}'=='ABIN'
        @{mcu_list}     Create List   0   1
    ELSE IF     '${capa_type}'=='ABIP'
        @{mcu_list}     Create List   0   1
    ELSE
        @{mcu_list}     Create List   0   1   2
    END

    FOR     ${slave}    IN  @{mcu_list}
            ${alias}        Connect To GNB Capacity Unit        slave=${slave}
            ${inst_dict}    connect.Get Ssh Connection Parameters   ${alias}
            Log To Console  ${inst_dict}
            ssh.Disconnect  ${alias}
    END
    [Teardown]      ssh.Reset Cache

Test Disconnect all available ssh connections
    [TAGS]              CONNECT
    Disconnect All Available SSH Connections


