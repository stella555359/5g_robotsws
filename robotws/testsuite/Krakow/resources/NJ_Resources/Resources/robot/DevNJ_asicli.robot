*** Settings ***
Documentation
...    Robot keywords for ASI CLI.

Library    String
Library    Collections
Library    OperatingSystem
Library    taf.transport.ssh   WITH NAME    ssh
Library    ../python/wft.py    WITH NAME    wft

*** Variables ***
${loadserver_addr}        10.66.11.28
${loadserver_username}    scpadm
${loadserver_password}    M%ACTfVV&U!k3qqL#1r4
${loadserver_alias}       nj_loadserver
${cli_installation_flag}    ${True}

@{branches_required_asicli}    5G  SBTS00  SBTS21B  SBTS22R1  SBTS22R2  SBTS22R3

*** Keywords ***
Install ASI CLI
    [Arguments]    ${build_name}
    [Documentation]     install asi cli package
    ...                 build_name (str) – build name. e.g.: 5G20A_9.1800.933
#    ${branch}=    Get Branch From Build Name    ${build_name}
#    Log To Console    branch is ${branch}
#    ${required}=      Run Keyword And Return Status    List Should Contain Value
#    ...    ${branches_required_asicli}    ${branch}
#    Return From Keyword If    '${required}' != 'True'

    Log To Console    install asicli
    ${asicli_version}=    Get ASI CLI Version From WFT    ${build_name}
    Run Keyword If    '${asicli_version}' == 'None'   Fail    Failed to get the aiscil version from the WFT

    Download ASI CLI From Load Server    ${asicli_version}
    Prepare ASI CLI Env

Install ASI CLI For UTE Cloud
    ${result}=        Run Keyword And Return Status    Variable Should Exist    ${ENB_BUILD}
    Return From Keyword If    ${result}==False or ${cli_installation_flag} == ${False}
    Log To Console  Install ${ENB_BUILD} CLI
    Install ASI CLI    ${ENB_BUILD}
    Set Global Variable  ${cli_installation_flag}  ${False}

Get Branch From Build Name
    [Arguments]    ${build_name}
    [Documentation]     replace the branch part of build name with ASIR
    ...                 build_name (str) – build name. e.g.: 5G20A_9.1800.933
    ...                 return branch. e.g.: 5G20A
    @{build}=    Split String    ${build_name}    separator=_
    [Return]    @{build}[0]

Get ASI CLI Version From WFT
    [Arguments]    ${build_name}
    [Documentation]     get asi cli version fro wft
    ...                 build_name (str) – build name. e.g.: 5G20A_9.1800.933
    ${asicli_version}=  wft.get_asicli_version    ${build_name}
    Log To Console    asicli version is ${asicli_version}
    [Return]    ${asicli_version}

Download ASI CLI From Load Server
    [Arguments]    ${asicli_version}
    ...            ${local_asicli_file}=/tmp/asi-cli.tgz
    [Documentation]     download asicli version from NJ load server
    ...                 asicli_version (str) – asicli version. e.g.: ASIRCLI_9.1.4
    ssh.connect to    hostname=${loadserver_addr}  username=${loadserver_username}  password=${loadserver_password}  alias=${loadserver_alias}
    ssh.download file    remote_path=/home/scpadm/SPACE/COMMON/Loads/ASIR/ASI_CLI/${asicli_version}/asi-cli.tgz  local_path=${local_asicli_file}
    ...   connection=${loadserver_alias}
    OperatingSystem.File Should Exist    ${local_asicli_file}    msg=Fail to download asi cli file from load server

Prepare ASI CLI Env
    [Arguments]    ${local_asicli_file}=/tmp/asi-cli.tgz
    ...            ${dest_asicli_dir}=/opt/asir
    [Documentation]     prepare asi cli on local VM for gnb
    ${asimgr}=    Set Variable    /opt/Nokia/Managers/BTS\\ Site/ASiR\\ Manager/tools
    Log To Console  sudo rm -rf ${asimgr}
    Run    sudo rm -rf ${asimgr}
    Log To Console  sudo mkdir -p ${asimgr}
    Run    sudo mkdir -p ${asimgr}
    Log To Console  sudo tar zxf ${local_asicli_file} -C ${asimgr}
    Run    sudo tar zxf ${local_asicli_file} -C ${asimgr}
    Log To Console  sudo rm -rf ${asimgr}/CLI && sudo cp -rf ${asimgr}/scripts ${asimgr}/CLI
    Run    sudo rm -rf ${asimgr}/CLI && sudo cp -rf ${asimgr}/scripts ${asimgr}/CLI
    Log To Console  sudo rm -rf ${dest_asicli_dir} && sudo ln -s ${asimgr}/scripts ${dest_asicli_dir}
    Run    sudo rm -rf ${dest_asicli_dir} && sudo ln -s ${asimgr}/scripts ${dest_asicli_dir}
    Log To Console  sudo chown -R ute.ute ${asimgr}
    Run    sudo chown -R ute.ute ${asimgr}
    Log To Console  sudo chown -R ute.ute ${dest_asicli_dir}
    Run    sudo chown -R ute.ute ${dest_asicli_dir}

Prepare ASI CLI Env For Enb
    [Arguments]    ${local_asicli_file}=/tmp/asi-cli.tgz
    ...            ${dest_asicli_dir}=/opt/enb/asir
    [Documentation]     prepare asi cli on local VM for enb
    Run    sudo rm -rf ${dest_asicli_dir}
    Run    sudo mkdir -p ${dest_asicli_dir}
    Run    sudo tar zxf ${local_asicli_file} -C ${dest_asicli_dir}
    Run    sudo chown -R ute.ute ${dest_asicli_dir}
