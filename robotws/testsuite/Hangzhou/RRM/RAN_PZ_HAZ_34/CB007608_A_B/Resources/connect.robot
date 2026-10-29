*** Settings ***
Documentation     Keywords for connection handling
Library    taf.sbts.oam.coam.admin            WITH NAME    admin
Library    taf.gnb.oam.coam.cu                WITH NAME    coam_cu
Library    taf.transport.ssh    WITH NAME    ssh
Resource    ./testline.robot

*** Keywords ***

Connect to TestPC
    [Documentation]   :Author: Soenke Kullberg
    ...     Setup ssh connection to Test PC and returns connection handle/alias
    ...     **Note:** KW sould be called without arguments
    ...     :param alias: (optional) alias used for ssh connection
    ...     :return alias: for ssh connection to Testpc
    ...     **Example:**
    ...     | ${tpc_alias}=  connect.Connect to TestPC
    ...     | ssh.execute  command=ls  connection=${tpc_alias}
    [Arguments]    ${alias}=ssh-test-pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}

Connect to UE PC
    [Documentation]   :Author: Jing Liang
    ...     Setup ssh connection to UE control PC
    ...     :param ue_id: (optional) ue id
    ...     :param alias: (optional) alias used for ssh connection
    ...     :return: alias for ssh connection to Testpc
    [Arguments]    ${ue_id}=${0}    ${alias}=ssh-ue-pc-${ue_id}
    ssh.Connect to    hostname=${tl.ues[${ue_id}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_id}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_id}].ssh_connection_details.password}
    ...    alias=${alias}
    [Return]    ${alias}

