*** Settings ***
Documentation
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../common_resources/certificates/certificates.robot
Resource    ../../../common_resources/vm/vm_operations.robot

Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin

*** Variables ***
${ping_pass}=             0% packet loss
${ping_loss}=             100% packet loss
${IPv4_Test_PC}=          10.42.22.118
${Test_PC_username}=      trs
${Test_PC_password}=      YT_xk39b
${IPv4}=                  10.42.54.13

*** Keywords ***
Connect to ADMIN Read-Write
    [Arguments]    ${number}    ${username}    ${password}
    FOR    ${nr}    IN RANGE    ${number}
        Connect to ADMIN    username=${username}
        ...                 password=${password}
        ...                 timeout=${180}
        ...                 alias=readwrite${nr}
    END

Connect to ADMIN Read-Only
    [Arguments]    ${number}    ${username}    ${password}
    FOR    ${nr}    IN RANGE    ${number}
        Connect to ADMIN    username=${username}
        ...                 password=${password}
        ...                 timeout=${180}
        ...                 alias=read${nr}
    END

Disconnect from ADMIN Read-Write
    [Arguments]    ${number}
    FOR    ${nr}    IN RANGE    ${number}
        Run Keyword And Continue On Failure      Disconnect from ADMIN    readwrite${nr}
    END

Disconnect from ADMIN Read-Only
    [Arguments]    ${number}
    FOR    ${nr}    IN RANGE    ${number}
        Run Keyword And Continue On Failure      Disconnect from ADMIN    read${nr}
    END

MantaRay Teardown with Restriction
    [Arguments]   ${LAB_NMS}
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    param_name=btsEMMaxSimulSession
	...	       param_value=10    LAB_NAME=${LAB_NMS}
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	       param_value=0    LAB_NAME=${LAB_NMS}
    Deintegrate BTS from MantaRay     ${LAB_NMS}

Send Ping From Test PC
    [Arguments]     ${expected_status}=${NONE}
    ${ping_status}=  Set Variable If    "${expected_status}"=="pass"    ${ping_pass}    ${ping_loss}
    SSHLibrary.Open Connection    ${IPv4_Test_PC}
    SSHLibrary.Login      ${Test_PC_username}  ${Test_PC_password}
    SSHLibrary.Write      ping -c 5 ${IPv4} -I enp0s20f0u1
    Sleep      30         reason=Wait until terminal execute the command
    ${ping}=   SSHLibrary.Read
    Should Contain        ${ping}  ${ping_status}
    SSHLibrary.Close Connection
