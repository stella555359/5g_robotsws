*** Settings ***
Documentation    Commercial mobile phone adb common keywords
...   author: Shi Ming
...   contact: ming.shi@nokia-sbell.com

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh    WITH NAME    csn
Library    Telnet

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/qualcomm_common_keywords.robot
Resource    ./check_android_ue_l3_call_process.robot

*** Variables ***
${ue_code}   *%23*%232846579159%23*%23*

*** Keywords ***
Get product brand
    [Documentation]    Get UE brand.
    ...  :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell getprop ro.product.brand
    ...    connection=cygwin
    sleep    5s
#    ${brand}=    csn.Read Output    connection=cygwin
    ${brand}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ${brand}=    Strip String    ${brand}
    Should not be empty    ${brand}    msg=Fail to get brand info from ue ${serial_number}, please check your ue status
    Set Suite Variable    ${brand}    ${brand}
    [Teardown]    csn.disconnect      connection=cygwin

Get all pointer variable
    [Documentation]    Get all pointer variable.
    ...  :param  ui_version: The ui version from UE, for samsung the default is ui version [S10UI1.1], also support S10UI2.1
    [Arguments]    ${ui_version}=default
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='default'
    ...    Get all Samsung pointer variable
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S10UI2.1'
    ...    Get all Samsung pointer variable with S10UI2.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S20UI2.1'
    ...    Get all Samsung pointer variable with S20UI2.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S20UI2.5'
    ...    Get all Samsung pointer variable with S20UI2.5
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S21UI3.1'
    ...    Get all Samsung pointer variable with S21UI3.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S22UI4.1'
    ...    Get all Samsung pointer variable with S22UI4.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S24UI5.1'
    ...    Get all Samsung pointer variable with S24UI5.1
    run keyword if    '${brand}'=='HUAWEI'
    ...    Get all Huawei pointer variable
    run keyword if    '${brand}'=='HUAWEI' and '${ui_version}'=='M40PUI1.1'
    ...    Get all Huawei pointer variable with M40PUI1.1
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='default'
    ...    Get all Xiaomi pointer variable
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='Mi12UI13.0.12'
    ...    Get all Xiaomi pointer variable with Mi12UI13.0.12
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='Mi12UI13.0.28'
    ...    Get all Xiaomi pointer variable with Mi12UI13.0.28
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='Mi12UI13.0.41'
    ...    Get all Xiaomi pointer variable with Mi12UI13.0.41
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='Mi11UI13'
    ...    Get all Xiaomi pointer variable with Mi11UI13
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='Mi11UI12'
    ...    Get all Xiaomi pointer variable with Mi11UI12
    run keyword if    '${brand}'=='HONOR' and '${ui_version}'=='default'
    ...    Get all HONOR pointer variable
    run keyword if    '${brand}'=='HONOR' and '${ui_version}'=='S30UI3.1.1'
    ...    Get all HONOR pointer variable with S30UI3.1.1
    run keyword if    '${brand}'=='lge'
    ...    Get all LG pointer variable
    run keyword if    '${brand}'=='OnePlus'
    ...    Get all Oneplus pointer variable
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S21UI4.0'
    ...    Get all Samsung pointer variable with S21UI4.0
    run keyword if    '${brand}'=='Redmi'
    ...    Get all Redmi pointer variable

Get all Samsung pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    535 1755
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S10UI2.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    721 2345
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    1133 417
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S20UI2.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    550 1850
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S20UI2.5
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    550 1850
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 380
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S21UI3.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    938 344
    Set Suite Variable    ${close_task}    550 1850
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 380
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S21UI4.0
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    941 412
    Set Suite Variable    ${close_task}    535 1865
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 380
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S22UI4.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    950 380
    Set Suite Variable    ${close_task}    535 1865
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 350
    Set Suite Variable    ${iperf_space}    800 550

Get all Samsung pointer variable with S24UI5.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    550 1850
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 380
    Set Suite Variable    ${iperf_space}    800 550

Get all Huawei pointer variable
    Set Suite Variable    ${home}    82
    Set Suite Variable    ${airplane}    960 290
    Set Suite Variable    ${close_task}    580 2140
    Set Suite Variable    ${Home_button}    82
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 308
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    960 850

Get all Huawei pointer variable with M40PUI1.1
    Set Suite Variable    ${home}    82
    Set Suite Variable    ${airplane}    1008 385
    Set Suite Variable    ${close_task}    580 2140
    Set Suite Variable    ${Home_button}    82
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 308
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    960 850

Get all Xiaomi pointer variable
    Set Suite Variable    ${home}    26
    Set Suite Variable    ${airplane}    920 1250
    Set Suite Variable    ${close_task}    535 2165
    Set Suite Variable    ${Home_button}    26
    Set Suite Variable    ${swipe}    500 800 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all Xiaomi pointer variable with Mi12UI13.0.12
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    300 1650
    Set Suite Variable    ${close_task}    535 2080
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    620 2180
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all Xiaomi pointer variable with Mi12UI13.0.28
    Set Suite Variable    ${Home}    3
    Set Suite Variable    ${airplane}    932 1633
    Set Suite Variable    ${close_task}   717 2920
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    347 2514 715 400
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all Xiaomi pointer variable with Mi11UI13
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1300 2200
    Set Suite Variable    ${close_task}    535 2080
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    620 2180
    Set Suite Variable    ${iperf_button}    1000 400
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all Xiaomi pointer variable with Mi11UI12
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1300 2000
    Set Suite Variable    ${close_task}    535 2080
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    620 2180
    Set Suite Variable    ${iperf_button}    1000 400
    Set Suite Variable    ${iperf_space}    250 700
    Set Suite Variable    ${5G}    900 960

Get all Xiaomi pointer variable with Mi12UI13.0.41
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    300 1250
    Set Suite Variable    ${close_task}    535 2080
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    620 2180
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all HONOR pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    920 350
    Set Suite Variable    ${close_task}    535 2165
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all HONOR pointer variable with S30UI3.1.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    630 227
    Set Suite Variable    ${close_task}    358 1420
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all LG pointer variable
    Set Suite Variable    ${home}    KEYCODE_HOME
    Set Suite Variable    ${airplane}    1300 1730
    Set Suite Variable    ${close_task}    700 2450
    Set Suite Variable    ${Home_button}    KEYCODE_HOME
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1200 360
    Set Suite Variable    ${iperf_space}    800 650

Get all Oneplus pointer variable
    Set Suite Variable    ${home}    KEYCODE_HOME
    Set Suite Variable    ${airplane}    950 1283
    Set Suite Variable    ${close_task}    540 2063
    Set Suite Variable    ${Home_button}    KEYCODE_HOME
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1200 360
    Set Suite Variable    ${iperf_space}    800 650

Get all Redmi pointer variable
    Set Suite Variable    ${home}    KEYCODE_HOME
    Set Suite Variable    ${airplane}    920 1650
    Set Suite Variable    ${close_task}    535 2165
    Set Suite Variable    ${Home_button}    KEYCODE_HOME
    Set Suite Variable    ${swipe}    500 800 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Preparation and execution for Commercial UE Attach
    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
    ...    attached to confirm whether the button was clicked once or twice
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${UE_IP_net}=127.0.0    ${UE_type}=${brand}    ${ue_index}=${0}    ${retry}=${3}   ${cap_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}      ${timeout}=60
    Get Commercial UE IP    ue_index=${ue_index}    cap_index=${cap_index}
    log to console    \n before attach ip of ue_${ue_index}:${UE_IP}
    ${passed}=    Run Keyword And Return Status    Should Contain    ${UE_IP}    ${UE_IP_net}
    FOR   ${index}    IN RANGE    ${retry}
        run keyword if    '${passed}'=='${True}'
    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
    ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.    AND
    ...    Andriod UE adb enable data services    ue_index=${ue_index}    AND
    ...    sleep    ${timeout}    AND
    ...    Get Commercial UE IP    ue_index=${ue_index}    cap_index=${cap_index}    AND
    ...    Compare UE IP if is assigned on for loop    AND
    ...    Exit For Loop If    '${compare}'=='${True}'
    ...    ELSE
    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
    ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.    AND
    ...    sleep    ${timeout}    AND
    ...    Get Commercial UE IP    ue_index=${ue_index}    cap_index=${cap_index}    AND
    ...    Compare UE IP if is assigned on for loop    AND
    ...    Exit For Loop If    '${compare}'=='${True}'
    END
    log to console    \n after attach ip of ue_${ue_index}:${UE_IP}

Preparation and execution for andriod UE Attach
    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
    ...    attached to confirm whether the button was clicked once or twice
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${UE_type}=${brand}    ${ue_index}=${0}    ${retry}=${2}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}    ${interval}=5    ${timeout}=30
    FOR   ${index}    IN RANGE    ${retry+1}
        run keyword if    ${index}==${retry}    Andriod UE adb reboot    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
        run keyword if    '${passed}'=='${True}'
        ...    Run Keywords
        ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.
        ...    ELSE
        ...    Run Keywords
        ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.
        Andriod UE adb enable data services    ue_index=${ue_index}
        sleep    ${interval}
        run keyword and ignore error    Wait Until Keyword Succeeds    ${timeout}    ${interval}
        ...    Verify UE IP already Assigned    ue_index=${ue_index}
        Exit For Loop If    '${compare}'=='${True}'
    END
    should be true    ${compare}    msg=UE attach failed with no IP success assigned!!!

Verify UE IP already Assigned
    [Arguments]    ${ue_index}=${0}
    Get Commercial UE IP    ue_index=${ue_index}
    ${result}    Compare UE IP if is assigned on for loop
    Should be True    ${result}

Check airplane mode status on
    [Arguments]    ${ue_index}=${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} shell settings get global airplane_mode_on    connection=cygwin
    sleep    3s
    ${airplane_status} =    csn.Read Output    connection=cygwin
    @{airmode_status}    split string    ${airplane_status}    \r\n
    ${status}    set variable if    '${airmode_status[0]}'=='0'    ${False}    ${True}
    [Return]    ${status}
    [Teardown]   csn.Disconnect   connection=cygwin

Andriod UE adb reboot
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ADB reboot ue    ue_index=${ue_index}   serial_number=${serial_number}
    Log to console    wait for adb startup
    BuiltIn.sleep    30s
    Check UE device exist    ue_index=${ue_index}

Andriod UE adb enable data services
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} shell svc data enable    connection=cygwin
    sleep    3s
    [Teardown]   csn.Disconnect   connection=cygwin

Compare UE IP if is assigned on for loop
    [Arguments]    ${UE_IP_net}=127.0.0
    ${compare}=    Run Keyword And Return Status    Should Not Contain     ${UE_IP}    ${UE_IP_net}
    Set Suite Variable    ${compare}    ${compare}
    [Return]    ${compare}

Commercial UE detach
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
    Get Commercial UE IP    ue_index=${ue_index}
    ${passed}=    Run Keyword And Return Status    Should Contain    ${UE_IP}    ${UE_IP_net}
    run keyword if    '${passed}'=='${True}'
    ...    Log    INFO:${UE_type} UE status is on detach.
    ...    ELSE    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
    ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log    INFO:${UE_type} UE detach successfully.

Andriod UE detach
    [Documentation]    UE detach. Determine if UE is on detach, if no, will click airplane swtich once, if yes,
    ...     will report info and do nothing
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  hostname: control PC address
    ...    :param  home: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${UE_type}=${brand}    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}    ${retry}=${2}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    FOR    ${index}    IN RANGE    ${retry+1}
        Exit For Loop If    '${passed}'=='${True}'
        run keyword if    '${passed}'=='${False}'
        ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    END
    should be true    ${passed}    msg=UE detach failed with ${retry+1} times retry!!!
    Log to console    INFO:${UE_type} UE detach successfully.

Commercial UE click AIRPLANE once
    [Documentation]    click AIRPLANE switch once
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   8s
    #####Click the task button#####
    run keyword if    '${brand}'=='Xiaomi'   Run Keyword and Ignore Error
    ...   csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

Commercial UE click AIRPLANE twice
    [Documentation]    click AIRPLANE switch twice
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    sleep   4s
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    #####Tap the airplane mode switch to disable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   4s
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
    sleep   50s
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   4s
    run keyword if    '${brand}'=='Xiaomi'   Run Keyword and Ignore Error
    ...   csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

Check Commercial attach successfully
    [Documentation]    verify attach on NSA env
    ...    :param  5Gstatus: expectation of UE attach status
    ...    :param  abil: abil number
    ...    :param  gnb_index: gnb number
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=1    ${ue_index}=${0}
    ${5Grach_ed}    Verify 5GRACH success times on gnb side    abil=${abil}    gnb_index=${gnb_index}
    Preparation and execution for Commercial UE Attach    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    ${5Grach_ing}    Verify 5GRACH success times on gnb side    abil=${abil}    gnb_index=${gnb_index}
    run keyword if     '${5Gstatus}'=='PASS'    should be true    ${5Grach_ing}>${5Grach_ed}
    run keyword if     '${5Gstatus}'=='PASS'    Log to console    INFO:5G UE setup successfully.
    run keyword if     '${5Gstatus}'=='FAIL'    should be true    ${5Grach_ing}==${5Grach_ed}
    run keyword if     '${5Gstatus}'=='FAIL'    Log to console    INFO:5G UE setup unsuccessfully.
    sleep    3s

Check Commercial attach successfully for SA
    [Documentation]    verify attach on SA env
    ...    :param  5Gstatus: expectation of UE attach status
    ...    :param  abil: abil number
    ...    :param  gnb_index: gnb number
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=1    ${ue_index}=${0}
    ${5Grach_ed}    Verify 5GRACH success times on gnb side    abil=${abil}    gnb_index=${gnb_index}
    Preparation and execution for Commercial UE Attach    ue_index=${ue_index}
    sleep    30s
    ${5Grach_ing}    Verify 5GRACH success times on gnb side    abil=${abil}    gnb_index=${gnb_index}
    run keyword if     '${5Gstatus}'=='PASS'    should be true    ${5Grach_ing}>${5Grach_ed}
    run keyword if     '${5Gstatus}'=='PASS'    Log to console    INFO:5G UE setup successfully.
    run keyword if     '${5Gstatus}'=='FAIL'    should be true    ${5Grach_ing}==${5Grach_ed}
    run keyword if     '${5Gstatus}'=='FAIL'    Log to console    INFO:5G UE setup unsuccessfully.
    sleep    3s

Get Commercial UE IP
    [Arguments]    ${ue_index}=${0}   ${cap_index}=${0}    ${capabilities}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${ip_filter}=${None}
    Connect to control pc via cygwin    ue_index=${ue_index}
    run keyword if    ${ip_filter} is not None
    ...    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep ${ip_filter} | grep -v ims00 | cut -d '/' -f 1 | head -1 |awk '{print $2}'
    ...    ELSE IF    '${capabilities}'=='HUAWEI_MATE30PRO' or '${capabilities}'=='xiaomi' or '${capabilities}'=='samsungS21'
    ...    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep inet | grep -v ims00 | cut -d '/' -f 1 |tail -n -2 |head -1 |awk '{print $2}'
    ...    ELSE IF    '${capabilities}'=='samsung'
    ...    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep 'scope global' | cut -d '/' -f 1 |head -n 1|awk '{print $2}'
    ...    ELSE    Get Commercial UE IP with first UE    ue_index=${ue_index}

Get Commercial UE IP with first UE
    [Documentation]    get UE IP
    ...    :param  command: common which to get UE IP
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...   ${command}=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |tail -n -1 |head -1 |awk '{print $2}'
    sleep   5s
    csn.send_command    command=${command}
    ...    connection=cygwin
    ${UE_IP}    csn.Read Output    connection=cygwin
    ${UE_IP}    Strip String    ${UE_IP}
    ${UE_IP}    set variable if      '${UE_IP}'==''    127.0.0.1    ${UE_IP}
    Should Not Start With      ${UE_IP}      192.168
    Set Suite Variable    ${UE_IP}    ${UE_IP}
    [Teardown]    csn.disconnect      connection=cygwin

Start DL traffic and check the TP on EPC
    [Documentation]    stat DL traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    ...    :param  protocal: Traffic protocal type. E.G udp/tcp
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    ...            ${process_num}=${1}    ${seg_size}=1180    ${window}=2M   ${cap_index}=${0}    ${ip_filter}=${None}
    run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       cap_index=${cap_index}
    ...                                                       ip_filter=${ip_filter}
    ...    ELSE    Start DL TCP traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}

Start DL TCP traffic and check the TP on EPC with first UE
    [Documentation]    stat DL TCP traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${process_num}=${16}    ${seg_size}=4880    ${window}=2M
    Get Commercial UE IP    ue_index=${ue_index}
	sleep    5s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=pwd    connection=cygwin
	${tmp_output} =    csn.Read Output    connection=cygwin
	log to console    This is ${tmp_output}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${DL_port} -i 1 &
    ...    connection=cygwin
    sleep    3s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
	csn.send_command    command=pwd    connection=EPCAPP
	${tmp_output} =    csn.Read Output    connection=EPCAPP
	log to console    This is ${tmp_output}
    csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep    5s
    #csn.send_command
    #...    command=iperf3 -c ${UE_IP} -p ${DL_port} -t ${time} -P ${process_num} -w ${window} -M ${seg_size} >/dev/null 2>/dev/null &
    #...    connection=EPCAPP
    FOR    ${i}    IN RANGE    10
	    log to console    This is loop${i}
        csn.send_command
       ...   command=iperf3 -c ${UE_IP} -p ${DL_port} -t ${time} -P ${process_num} -w ${window} -M ${seg_size} >/dev/null 2>/dev/null &
       ...   connection=EPCAPP
	   sleep    3s
       csn.send_command    command=ps -ef |grep iperf3 |grep ${DL_port} |grep -v grep |awk '{print $2}'
       ...   connection=EPCAPP
	    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
	    #${testType}    Evaluate    type(${pid})
        #log to console    testtype is ${testType}
	    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
	    #${pid}=    Run keyword and continue on failure    Convert To String    ${pid}
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END
	log to console    .....UE_${ue_index} tcp dl iperf start....
    #[Teardown]    csn.disconnect      connection=EPCAPP}



Start DL traffic and check the TP on EPC with first UE
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    ...            ${process_num}=${1}   ${cap_index}=${0}    ${ip_filter}=${None}
    Get Commercial UE IP    ue_index=${ue_index}    cap_index=${cap_index}    ip_filter=${ip_filter}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Stop DL traffic and check the TP on EPC
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${protocol}=udp    #${time}=10
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    run keyword if    '${protocol}'!='udp'    Stop traffic via iperf command on UE    port=${DL_port}    ue_index=${ue_index}
    [Teardown]    csn.disconnect      connection=EPCAPP

Connect to EPC APP
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=EPCAPP

Start UL traffic and check the TP on Commercial
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}
    ...    ${iperf_type}=via_app    ${protocol}=udp    ${data_amount}=data_amount    ${buffer_size}=1024B    ${process_num}=${16}
    run keyword if    '${iperf_type}'=='via_app'    Start UL UDP traffic via iperf app     time=${time}    traffic=${traffic}
    ...    iperf_port=${iperf_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    ELSE    Start UL traffic via iperf command    time=${time}    traffic=${traffic}    process_num=${process_num}
    ...    UL_port=${iperf_port}    ue_index=${ue_index}    protocol=${protocol}     data_amount=${data_amount}    buffer_size=${buffer_size}

Start UL UDP traffic via iperf app
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}
    ...            ${retry}=${3}    ${buffer_size}=1400B
#    Connect to control pc via cygwin    ue_index=${ue_index}
    FOR   ${index}    IN RANGE    ${retry}
        ${iperf_status}    run keyword and return status    Start UL traffic and check the TP on Commercial with first UE
    ...    time=${time}    traffic=${traffic}    UL_port=${iperf_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
        exit for loop if   ${iperf_status}
    END
    should be true   ${iperf_status}   msg=Failed to start UL traffic after ${retry} retries.


Start UL traffic via iperf command
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}
    ...    ${protocol}=udp      ${data_amount}=data_amount    ${buffer_size}=1024B    ${process_num}=${16}
    run keyword if    '${protocol}'=='udp'    Start UL UDP traffic via iperf command     time=${time}    traffic=${traffic}
    ...    UL_port=${UL_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    ELSE    Start UL TCP traffic via iperf command    time=${time}    process_num=${process_num}
    ...    UL_port=${UL_port}    ue_index=${ue_index}     data_amount=${data_amount}


Start UL TCP traffic via iperf command
    [Arguments]
    ...    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}
    ...    ${time}=10
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${data_amount}=1M    ${process_num}=${16}
    log to console    Start UL TCP traffic
    Get Commercial UE IP    ue_index=${ue_index}
	sleep    2s
    Connect to control pc via cygwin    ue_index=${ue_index}
	csn.send_command    command=pwd    connection=cygwin
	${tmp_output} =    csn.Read Output    connection=cygwin
	log to console    This is ${tmp_output}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${UL_port} -i 1 &
    ...    connection=cygwin
    sleep    1s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   1s
	csn.send_command    command=pwd    connection=EPCAPP
	${tmp_output} =    csn.Read Output    connection=EPCAPP
	log to console    This is ${tmp_output}
    csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}' |xargs kill -9 &   connection=EPCAPP
    sleep    5s
    #csn.send_command
    #...    command=iperf3 -c ${UE_IP} -p ${UL_port} -t ${time} -R -w ${data_amount} -M 1280 -P ${process_num} >/dev/null 2>/dev/null &
    #...    connection=EPCAPP
	FOR    ${i}    IN RANGE    10
	    log to console    This is loop${i}
        csn.send_command
       ...   command=iperf3 -c ${UE_IP} -p ${UL_port} -t ${time} -R -w ${data_amount} -M 1280 -P ${process_num} >/dev/null 2>/dev/null &
       ...   connection=EPCAPP
	   sleep    2s
       csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}'
       ...   connection=EPCAPP
	    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
	    #${testType}    Evaluate    type(${pid})
        #log to console    testtype is ${testType}
	    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
	    #${pid}=    Run keyword and continue on failure    Convert To String    ${pid}
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END
    log to console    .....UE_${ue_index} tcp ul iperf start....
    #[Teardown]    csn.disconnect      connection=EPCAPP


Start UL UDP traffic via iperf command
    [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${ue_index}=${0}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${window_size}=2M
    sleep   2s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
    ...    -t ${time} -P 1 -i 1 -f m -b ${traffic} -l ${buffer_size} -T 64 -w ${window_size} &
    csn.send_command    command=${cmd}
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    log to console    .....UE_${ue_index} udp ul iperf start....
    [Teardown]    csn.disconnect      connection=cygwin

Stop traffic via iperf command on UE
    [Arguments]    ${port}=${tl.appserver.iperf_details.port}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc via cygwin    ue_index=${ue_index}    hostname=${hostname}    username=${username}    password=${password}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ${pid}    strip_string    ${pid}
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin


Start UL traffic and check the TP on Commercial with first UE
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}
    ...    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${ue_index}=${0}
    ...    ${time}=10
    ...    ${traffic}=10.00M    ${iperf_button}=${iperf_button}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Run Keyword And Ignore Error     csn.disconnect    connection=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   3s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf    connection=cygwin
    sleep   3s
    csn.send_command
    ...    command=adb -s ${serial_number} shell am start -n com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity
    ...    connection=cygwin
    sleep    2s
    #####tap the spare space of magic iperf to focus on input line#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${iperf_space}    connection=cygwin
    sleep   2s
    FOR	${i}	IN RANGE	10
        Retry send command in cygwin    command=adb -s ${serial_number} shell input keyevent 67
        sleep    0.5
    END
    ${ul_cmd}    set variable
    ...  iperf\%s-c\%s${EPC_IP}\%s-u\%s-p\%s${UL_port}\%s-t\%s${time}\%s-i\%s1\%s-P\%s1\%s-f\%sm\%s-b\%s${traffic}\%s-l\%s${buffer_size}\%s-T\%s64\%s
    Retry send command in cygwin    command=adb -s ${serial_number} shell input text ${ul_cmd}
    sleep   3s
    Retry send command in cygwin    command=adb -s ${serial_number} shell input tap ${iperf_button}
    sleep   3s
    Retry send command in cygwin    command=adb -s ${serial_number} shell ps -ef | grep -w iperf| grep -v grep|awk '{print $2}'
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${iperf_pid}    evaluate    ${output.strip()}
    should be true    ${iperf_pid} > ${0}

Retry send command in cygwin
    [Arguments]  ${command}
    ${keyinput_status}    Run keyword and return status    csn.send_command    command=${command}    connection=cygwin
    Run keyword if     '${keyinput_status}' == '${False}'    run keywords
    ...   csn.force reconnect    connection=cygwin          AND
    ...   csn.send_command    command=${command}    connection=cygwin

Stop UL traffic and check the TP on EPC
    [Arguments]    ${UL_port}=${tl.appserver.iperf_details.port}    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${iperf_type}=via_app    ${protocol}=udp
    run keyword if    '${iperf_type}'!='via_app'    Stop traffic via iperf command on UE    port=${UL_port}    ue_index=${ue_index}
    run keyword if    '${iperf_type}'!='via_app' and '${protocol}'!='udp'    Stop TCP traffic on EPC    ue_index=${ue_index}    port=${UL_port}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am force-stop com.nextdoordeveloper.miperf.miperf    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

Stop TCP traffic on EPC
    [Arguments]    ${ue_index}=${0}    ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${hostname}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    ...    hostname=${hostname}    username=${username}    password=${password}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    [Teardown]    csn.disconnect      connection=EPCAPP


Connect to control pc via cygwin
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    FOR   ${index}    IN RANGE    3
          ${connection_status}    Run keyword and return status    csn.connect to    hostname=${hostname}
    ...    username=${username}    password=${password}    alias=${alias}    look_for_keys=${False}
          Exit For Loop If    '${connection_status}'=='${True}'
          sleep    15s
    END
    Run keyword if    '${connection_status}'=='${False}'     Log
    ...      CPC connection failed: ${hostname} / ${username} / ${password} /     WARN
    Should be true    ${connection_status}

Commercial UE click 5G once
    [Documentation]    click 5G switch once
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  5G: 5G switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${5G}=${5G}    ${close_task}=${close_task}   ${ue_index}=${0}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am start -n com.android.phone/.MobileNetworkSettings    connection=cygwin
    sleep   2s
    #####Tap the 5G mode switch to enable 5G mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${5G}    connection=cygwin
    sleep   5s
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep   2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin

Kill vysor process
    [Documentation]    Author: Ren Biyao
    ...    Magic iperf is applied for sending and receiving data. Since magic iperf can only work without any interruption
    ...    when working on front window, it is required to close the pop-up advertising window of vysor in advance.
    ...    Otherwise, vysor will inevitably show up on front window every 15 min and end the data transmission process in magic iperf.
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    3x    5sec    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command   command=taskkill /f /im Vysor.exe    connection=cygwin
    sleep    1s
    csn.send_command   command=tasklist | grep Vysor.exe    connection=cygwin
    sleep    1s
    ${vysor_status}    csn.read_output    connection=cygwin
    csn.send_command   command=adb -s ${serial_number} shell " ps -ef | grep vysor | grep -v grep | grep 'shell' | awk '{print $2}'| xargs kill -9"
    ...    connection=cygwin
    Sleep    1s
    ${check_process}    csn.Execute    ps -ef | grep vysor | grep -v grep | grep 'shell'    connection=cygwin
    Should be empty    ${check_process}
    [Teardown]    csn.disconnect      connection=cygwin

Set data center Mode for Huawei
    [Documentation]   set the data center Mode for Huawei
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced   ue_index=${ue_index}
    Connect ADB devices  alias=cpc_${ue_index}    serial_number=${serial_number}
    log     INFO:UE devices detected    console=true
    csn.send_command    command=adb -s ${serial_number} shell service call phone 1 s16 ${ue_code}    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell service call phone 1 s16 ${ue_code}    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 550 900    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 550 1800   connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2000 500 100 100    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 550 1900    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 550 1200    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 880 1330    connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cpc_${ue_index}
    sleep   120s
    csn.disconnect      connection=cpc_${ue_index}

Close Airmode confirm window for lg_v50
    [Documentation]   LG MP will ask to confirm open airmode action
    [Arguments]   ${old_output}    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.send_command   command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow   connection=${connection}
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.count('StatusBar')}>0   csn.send_command
    ...   command=adb -s ${serial_number} shell input tap 1000 2760    connection=${connection}
    Return From Keyword If   ${output.count('StatusBar')}>0
    ${old_window}   Should Match Regexp   ${old_output}    \\=Window\\{[0-9a-fA-F]{1,7}\\s
    ${window}   Should Match Regexp   ${output}   \\=Window\\{[0-9a-fA-F]{1,7}\\s
    run keyword if  not $old_window==$window   csn.send_command
    ...   command=adb -s ${serial_number} shell input tap 1000 2760    connection=${connection}

Awake UE if Sleepy
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep   2s
    Run Keyword If   ${output.lower().count('isstatusbarkeyguard=true')}>0 or ${output.lower().count('mshowinglockscreen=true')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 82   connection=${connection}
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${EMPTY}    connection=${connection}
