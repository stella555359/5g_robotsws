*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/admin/admin.robot

*** Keywords ***
Kill The VPP Process
    Connect to BTS
    ${VPP_STRING}=      ssh.execute    command=ps -ef | grep vpp | grep -v grep    connection=cOAM_toor4nsn
    ${VPP_ID}=          Get Substring    ${VPP_STRING}    9    14
    ssh.send command    command=kill -9 ${VPP_ID}    connection=cOAM_toor4nsn
    FOR    ${i}    IN RANGE    300
         ${PING}=    Run    ping -c 2 192.168.255.129
         ${Exit}=    Run Keyword And Return Status    Should Contain    ${PING}    100% packet loss
         Exit For Loop If    ${Exit}==True
    END
    [Teardown]    Run Keywords    Wait until keyword succeeds  30 min  60sec  Check if BTS status is Configured or OnAir
    ...           AND             Disconnect from BTS

Pause The VPP Process
    Connect to BTS
    ${VPP_STRING}=      ssh.execute    command=ps -ef | grep vpp | grep -v grep    connection=cOAM_toor4nsn
    ${VPP_ID}=          Get Substring    ${VPP_STRING}    9    14
    ssh.send command    command=kill -19 ${VPP_ID}    connection=cOAM_toor4nsn
    Run Keyword         ssh.execute    command=journalctl -f | grep -v gpsd | grep vpp_main    connection=cOAM_toor4nsn
    [Teardown]    Run Keywords    Wait until keyword succeeds  30 min  60sec  Check if BTS status is Configured or OnAir
    ...           AND             Disconnect from BTS
