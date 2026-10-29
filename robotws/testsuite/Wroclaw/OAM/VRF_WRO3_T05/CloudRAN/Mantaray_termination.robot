*** Settings ***
Documentation    Test for Cloud BTS termination from Mantaray.
...              Terminates CNF objects and deintegrates CLOUD objects in given NMS lab based on
...              variables ${MRBTS_CU} and ${MRBTS} from init.py
...              To terminate, fill out needed variable: ${NMS_LAB}
...              Location of init.py for terminating BTS must be passed in as argument when running this test.
...              Example command to run the script:
...              "robot --variablefile /home/ute/testline_configuration/11_16_MRBTS8699 -T -L TRACE -b debug.log
...              -d /home/ute/Mantaray_deployment
...              /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/CloudRAN/Mantaray_termination.robot"
...              Author:    damian.kotula@nokia.com

Resource    ../../cloud_common_resources/mantaray/mantaray.robot


*** Variables ***
#Fill out variable:
${NMS_LAB}         ____  #example: 1028

#Do not change. Declare used lab in ${NMS_LAB} variable.
${NMS_LAB_IP}    ${SRNCLAB${NMS_LAB}}

*** Test Cases ***
vCU Termination
    Terminate vCU

vCU Koredump Operator Termination
    Terminate Koredump Operator vCU

Deintegrate vCU Server
    Deintegrate Cloud Server from NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vCU

vDU Termination
    ${result} =    Run Keyword And Return Status    Terminate vDU
    IF    not ${result}    Fatal Error
    ...    msg=vDU termination failed, cancelling rest of cases to not mix up termination order.

Rannic Termination
    Terminate Ran Nic SW Operator

Nokia Sync Operator Termination
    Terminate Nokia Sync Operator

vDU Koredump Operator Termination
    Terminate Koredump Operator vDU

Deintegrate vDU Server
    Deintegrate Cloud Server from NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vDU

*** Keywords ***
Terminate vCU
    ${installed_sw} =    Get Installed SW Version    hw_type=vCU
    ${is_build_on_nms_lab} =    _Check If SW is present on NMS lab    ${installed_sw}-amd64    ${NMS_LAB_IP}
    IF    '${installed_sw}' != 'None' and ${is_build_on_nms_lab}
        Log   Terminating vCU from Mantaray    console=${True}
        Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vCU
    ELSE IF    not ${is_build_on_nms_lab} or '${installed_sw}' == 'None'
        Log    SW not found on NMS lab or vCU not reachable, removing charts from OCP    console=${True}
        ${ssh_conn} =    Connect To Admin via SSH    hw_type=vCU
        mantaray.Remove Existing Charts    hw_type=vcu    chart_name=all    conn=${ssh_conn}
        Disconnect from ADMIN via SSH    ${ssh_conn}    hw_type=vCU
        Log    Removing objects from Mantaray    console=${True}
        Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vCU
    END

Terminate vDU
    ${installed_sw} =    Get Installed SW Version    hw_type=vDU
    ${is_build_on_nms_lab} =    _Check If SW is present on NMS lab    ${installed_sw}-amd64    ${NMS_LAB_IP}
    IF    '${installed_sw}' != 'None' and ${is_build_on_nms_lab}
        Log   Terminating vDU from Mantaray    console=${True}
        Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vDU
    ELSE IF    not ${is_build_on_nms_lab} or '${installed_sw}' == 'None'
        Log    SW not found on NMS lab or vDU not reachable, removing charts from OCP    console=${True}
        ${ssh_conn} =    Connect To Admin via SSH    hw_type=vDU
        mantaray.Remove Existing Charts    hw_type=vdu    chart_name=all    conn=${ssh_conn}
        Disconnect from ADMIN via SSH    ${ssh_conn}    hw_type=vDU
        Log    Removing objects from Mantaray    console=${True}
        Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vDU
    END

Terminate Nokia Sync Operator
    ${nokia_sync_sw} =    Run Keyword And Ignore Error     Get Nokia Sync Version    vDU
    ${version_avail} =    Run Keyword And Return Status    Should Not Contain    ${nokia_sync_sw}    FAIL
    IF    ${version_avail}
        ${nokia_sync_sw} =    Replace String    ${nokia_sync_sw}[1]    operator-    operator_
        _Prepare SW on NMS lab    sw_version=${nokia_sync_sw}-amd64    nms_lab_ip=${NMS_LAB_IP}
        ...                       nop_type=nokia-sync-operator
    END
    Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    nop_type=nokia-sync-operator

Terminate Ran Nic SW Operator
    ${rannic_sw} =        Run Keyword And Ignore Error     Get Rannic Version    vDU
    ${version_avail} =    Run Keyword And Return Status    Should Not Contain    ${rannic_sw}    FAIL
    IF    ${version_avail}
        ${rannic_sw} =    Replace String     ${rannic_sw}[1]    controller-    controller_
        _Prepare SW on NMS lab    sw_version=${rannic_sw}-amd64    nms_lab_ip=${NMS_LAB_IP}
        ...                       nop_type=ran-nic-sw-controller
    END
    Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    nop_type=ran-nic-sw-controller

Terminate Koredump Operator vDU
    ${koredump_sw} =       Run Keyword And Ignore Error     Get Koredump Version   hw_type=vDU
    ${version_avail} =     Run Keyword And Return Status    Should Not Contain    ${koredump_sw}    FAIL
    IF    ${version_avail}
        ${koredump_sw} =    Replace String   ${koredump_sw}[1]    operator-    operator_
        _Prepare SW on NMS lab    sw_version=${koredump_sw}-amd64    nms_lab_ip=${NMS_LAB_IP}
        ...                       nop_type=koredump-operator-vdu
    END
    Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    nop_type=koredump-operator-vdu


Terminate Koredump Operator vCU
    ${koredump_sw}=       Run Keyword And Ignore Error     Get Koredump Version   hw_type=vCU
    ${version_avail}=     Run Keyword And Return Status    Should Not Contain    ${koredump_sw}    FAIL
    IF    ${version_avail}
        ${koredump_sw}=    Replace String    ${koredump_sw}[1]    operator-    operator_
        _Prepare SW on NMS lab    sw_version=${koredump_sw}-amd64    nms_lab_ip=${NMS_LAB_IP}
        ...                       nop_type=koredump-operator-vcu
    END
    Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    nop_type=koredump-operator-vcu


Get Installed SW Version
    [Arguments]    ${hw_type}=None
    TRY
        ${installed_sw} =    Get Software Version    hw_type=${hw_type}
        RETURN    ${installed_sw[0]}
    EXCEPT
        RETURN   None
    END
