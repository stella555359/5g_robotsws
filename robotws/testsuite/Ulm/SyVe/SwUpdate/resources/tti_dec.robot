*** Settings ***
Documentation    Keyword files for tti decoder installation/ modifications

Library    taf.transport.ssh                WITH NAME   ssh

Resource   ../../../resources/Common/connect.robot

*** Keywords ***
Install TTI Dec
    [Documentation]   Install tti dec for a particular SW version
    [Arguments]    ${version}    ${gnb_id}=0

    ${gnb_testpc}=    connect.Connect to test pc proxy for node    node_id=${gnb_id}
    Run Keyword and Ignore Error    ssh.execute    sudo rm -rf /opt/tti-dec    connection=${gnb_testpc}
    ${output}=
    ...    ssh.execute    sudo dpkg -i /mnt/etfiles/images/sbts/${version}/${version}_tti-dec.deb
    ...    connection=${gnb_testpc}    timeout=3600
    ${ttidec_failed}=    Run Keyword And Return Status    Should Not Contain    ${output}    No such file
    IF    ${ttidec_failed}     Log to Console    Installed tti-decoder files for build version ${version}!
    ...    ELSE     Log to Console    Error installing tti-decoder files for build version ${version}!
