*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Ming Shi, Civen Chen
...              Contact: ming.shi@nokia-sbell.com, civen.chen@nokia-sbell.com
...              Already verified equipment: Huawei Meta20x.

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
#Resource    ../../aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot

*** Variables ***

*** Keywords ***
################################## STEP2: UE ATTACH ##################################
new_power_UE.UE Attach
    [Arguments]    ${ue_index}    ${retry}=${2}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    ...  :param  retry: retry times for ue attach.
    New Preparation and execution for andriod UE Attach    ue_index=${ue_index}    retry=${retry}
    Log    click Airplane mode switch to disable its function so that make UE attach

New Preparation and execution for andriod UE Attach
    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
    ...    attached to confirm whether the button was clicked once or twice
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${UE_IP_net}=127.0.0    ${UE_type}=${brand}    ${ue_index}=${0}    ${retry}=${2}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}
    FOR   ${index}    IN RANGE    ${retry+1}
        run keyword if    ${index}==${retry}    Commercial_mobile_phone_adb_common_keywords.Andriod UE adb reboot    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
        ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.    AND
        ...    Andriod UE adb enable data services    ue_index=${ue_index}    AND
        ...    sleep  60s    AND
        ...    New Get Commercial UE IP    ue_index=${ue_index}    AND
        ...    Compare UE IP if is assigned on for loop    AND
        ...    Exit For Loop If    '${compare}'=='${True}'
        ...    ELSE
        ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
        ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.    AND
        ...    Andriod UE adb enable data services    ue_index=${ue_index}    AND
        ...    sleep  30s    AND
        ...    New Get Commercial UE IP    ue_index=${ue_index}    AND
        ...    Compare UE IP if is assigned on for loop    AND
        ...    Exit For Loop If    '${compare}'=='${True}'
    END
    should be true    ${compare}    msg=UE attach failed with no IP success assigned!!!


New Get Commercial UE IP
    [Arguments]    ${ue_index}=${0}   ${cap_index}=${0}    ${capabilities}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    run keyword if    '${capabilities}'=='HUAWEI_MATE30PRO' or '${capabilities}'=='xiaomi' or '${capabilities}'=='samsungS21'
    ...    New Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep inet | grep -v ims00 | cut -d '/' -f 1 |tail -n -2 |head -1 |awk '{print $2}'
    ...    ELSE IF    '${capabilities}'=='samsung'
    ...    New Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep "scope global" | cut -d '/' -f 1 |head -n 1|awk '{print $2}'
    ...    ELSE    New Get Commercial UE IP with first UE    ue_index=${ue_index}

New Get Commercial UE IP with first UE
    [Documentation]    get UE IP
    ...    :param  command: common which to get UE IP
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...   ${command}=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |tail -n -1 |head -1 |awk '{print $2}'
    sleep   5s
    csn.send_command    command=${command}
    ...    connection=cygwin
    ${UE_IP}=    csn.Read Output    connection=cygwin
    ${UE_IP}=    Strip String    ${UE_IP}
    log to console    \n attached ip of ue_${ue_index}:${UE_IP}
#    Should Not Contain      ${UE_IP}      192.168
    Set Suite Variable    ${UE_IP}    ${UE_IP}
    [Teardown]    csn.disconnect      connection=cygwin


New Commercial UE detach
    [Documentation]    UE detach. Determine if UE is on detach, if no, will click airplane swtich once, if yes,
    ...     will report info and do nothing
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  hostname: control PC address
    ...    :param  home: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${UE_IP_net}=127.0.0    ${UE_type}=${brand}    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}
    New Get Commercial UE IP    ue_index=${ue_index}
    ${passed}=    Run Keyword And Return Status    Should Contain    ${UE_IP}    ${UE_IP_net}
    run keyword if    '${passed}'=='${True}'
    ...    Log    INFO:${UE_type} UE status is on detach.
    ...    ELSE    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
    ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log    INFO:${UE_type} UE detach successfully.
