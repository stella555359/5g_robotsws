*** Settings ***
Resource    ../gnb.robot
Resource    ../connect.robot
Resource    ../testline.robot
Library     taf.sbts.oam.coam.admin     WITH NAME   admin
Library     taf.transport.ssh           WITH NAME   ssh



*** Test Cases ***
Test Multiple Setup OAM Http session
    [TAGS]              CONNECT
    FOR     ${iter}     IN RANGE    12
        ${oam_alias}    connect.Setup OAM Http session  node_type=gnb   node_id=0
    END

Test Get Connection Parameters
    [TAGS]              CONNECT
    ${ssh_alias}    connect.Connect to Node Common Unit
    ${inst_dict}    connect.Get Ssh Connection Parameters       ${ssh_alias}
    ssh.disconnect  ${ssh_alias}
    ${keys}         Get Dictionary Keys     ${inst_dict}
    FOR     ${key}  IN  @{keys}
        Log To Console  ${\n}Alias ${ssh_alias} parameter ${key}: ${inst_dict}[${key}]
    END
    [Teardown]      ssh.Reset Cache

Test Check SSH Alias Exist
    [TAGS]              CONNECT
    ${status}       Check SSH Alias Exist   dummy_alias
    Should Not Be True  ${status}
    ${ssh_alias}    connect.Connect to Node Common Unit
    ${status}       Check SSH Alias Exist   ${ssh_alias}
    Should Be True  ${status}
    ${ssh_alias}    connect.Connect to Node Common Unit
    ssh.disconnect  ${ssh_alias}
    [Teardown]      ssh.Reset Cache

Test Connect to gNB Capacity Unit
    [TAGS]              CONNECT
    ${comu_type}    testline.Get Common Unit Type
    Pass Execution If       '${comu_type}'=='ASOE'  This test isn't applicable for ASOE TL!
    FOR     ${slave}    IN  a   b   loner
            ${alias}        Connect to gNB Capacity Unit        slave=${slave}
            ${inst_dict}    connect.Get Ssh Connection Parameters   ${alias}
            ssh.disconnect  ${alias}
    END
    [Teardown]      ssh.Reset Cache



