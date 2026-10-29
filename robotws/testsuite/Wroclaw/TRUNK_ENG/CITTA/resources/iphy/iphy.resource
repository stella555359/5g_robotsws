*** Settings ***
Documentation    Manipulating IPHY configuration.

Library    taf.transport.ssh    WITH NAME    ssh
Library    ./iphy_xml.py


*** Keywords ***
Apply Iphy Configuration
    [Arguments]    ${file}
    [Documentation]    Upload provided conifguration ``file`` into IPHY, then set it as active.
    ...
    ...    Note: site reset is required for changes to take effect.
    iphy_xml.Update    ${file}
    ${iphy_connection}=    ssh.Connect To    hostname=192.168.200.129    username=toor4nsn    password=oZPS0POrRieRtu
    ssh.Upload File    ${file}    /rom/simmode/custom_iphy.xml    connection=${iphy_connection}
    ${link_configuration}=    Set Variable    ln -sf /rom/simmode/custom_iphy.xml /rom/simmode/iphy.xml
    ssh.execute     ${link_configuration}    connection=${iphy_connection}
    [Teardown]    ssh.Disconnect    connection=${iphy_connection}
