*** Settings ***
Force Tags    PY36
Documentation     author: Xing Jing && Yayun zhang
...                 contact: jing.1.xing@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB006112

Resource     ./../CB006112/Resources/CB006112_common_keywords.robot
#Variables    Resources/variables.py
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006112/Resources/variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup        Run Keywords    robot_common_operations.Common Suite Setup
                   ...    AND    Setup for SA Env cell on-air

Suite Teardown         Run Keywords    robot_common_operations.Common Suite Teardown
...                    AND    Save snapshot Teardown for COAM


*** Variables ***
${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
#${SCF_file_name}    gNB1_6112_B_08.xml
${SCF_file_name}    gNB1_Golden_SCF.xml
${interface}    any
${B_8_gNB1_nglogname1}    gNB2_6112_B08_1.pcap
${B_8_gNB1_nglogname2}    gNB2_6112_B08_2.pcap
${B_8_gNB1_nglogname3}    gNB2_6112_B08_3.pcap
${B_8_gNB1_nglogname4}    gNB2_6112_B08_4.pcap
${gnb_filter}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#${gnb_filter1}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 7 and
#              ...    nr-rrc.drx_InactivityTimer == 8 and nr-rrc.drx_LongCycleStartOffset == 3
#@{value1}    7    8    3
#${gnb_filter2}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 5
#             ...    and nr-rrc.drx_InactivityTimer == 6 and nr-rrc.drx_LongCycleStartOffset == 3
#@{value2}    5    6    3
#${gnb_filter3}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 4
#             ...    and nr-rrc.drx_InactivityTimer == 5 and nr-rrc.drx_LongCycleStartOffset == 3
#@{value3}    4    5    3
#${gnb_filter4}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 6
#             ...    and nr-rrc.drx_InactivityTimer == 7 and nr-rrc.drx_LongCycleStartOffset == 3
#@{value4}    6    7    3
${gnb_filter1}      f1ap.procedureCode == 7 and
              ...    nr-rrc.drx_InactivityTimer == 14 and nr-rrc.drx_LongCycleStartOffset == 9
@{value1}    14    9
${gnb_filter2}      f1ap.procedureCode == 7
             ...    and nr-rrc.drx_InactivityTimer == 4 and nr-rrc.drx_LongCycleStartOffset == 3
@{value2}    4    3
${gnb_filter3}      f1ap.procedureCode == 7
             ...    and nr-rrc.drx_InactivityTimer == 4 and nr-rrc.drx_LongCycleStartOffset == 3
@{value3}    4    3
${gnb_filter4}      f1ap.procedureCode == 7
             ...    and nr-rrc.drx_InactivityTimer == 14 and nr-rrc.drx_LongCycleStartOffset == 9
@{value4}    14    9
${serial_number}    ${tl.ues[0].serial_number}

${5GRU_ANT1}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb1 cell 1
${5GRU_ANT2}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb1 cell 1
${5GRU_ANT3}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #gnb1 cell 2
${5GRU_ANT4}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}    #gnb1 cell 2
${5GRU_ANT5}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}    #gnb1 cell 3
${5GRU_ANT6}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}    #gnb1 cell 3
${4GRU_ANT7}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}    #enb
${4GRU_ANT8}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}    #enb
${5GRU_ANT9}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell 1
${5GRU_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell 1
${5GRU_ANT11}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}    #gnb2 cell 2
${5GRU_ANT12}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}    #gnb2 cell 2
##PA
@{PA_value}    ${25}    ${50}    ${30}    ${0}    ${120}    #int list
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_api_port}             ${tl.attenuator[0].port}
@{att_connection_port}      ${5GRU_ANT1}    ${5GRU_ANT2}    ${5GRU_ANT3}    ${5GRU_ANT4}    ${5GRU_ANT5}    ${5GRU_ANT6}
...         ${4GRU_ANT7}    ${4GRU_ANT8}    ${5GRU_ANT9}    ${5GRU_ANT10}    ${5GRU_ANT11}     ${5GRU_ANT12}
${HBTE_max_value}           ${127}
${vendor}                    ${tl.attenuator[0].vendor}

## filter command for coverting PDML
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap\"  -T pdml

${dxdata2_apn}    95 943
${dxdata2_apn_348}    150 943

@{enb_id}    241    383    358
${enb_instance}     ${tl.enbs[0].instance_id}

${model}                     ${tl.attenuator[0].model}

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type}                  ${tl.ues[0].capabilities[0]}

*** Test Cases ***
[1]CB006112-B_08_Successful_INTRA_gNB_HO_setup FDD _of_VoNR_call_with_enable_different_VoNR_DRX_profile
    [Documentation]    This user scenario describes the gNB behavior for the successful setup of Voice
    ...    over NR call with FDD&TDD when VoNR specific DRX profile is enabled.
    [Tags]    CRT_22R1    CRT_TRUNK   CRT_22R2    CB0061112-A    CRT_22R3    CRT_22R4    CRT_23R1
    [Setup]
    robot_common_operations.Common Case Setup
    Online modify parmeters    parameters_to_update=${PARAM_CB006112_B_08_WA}
# gnb1 cell2 to 0db,cell1 120db,cell3 120db
    Set default PA value for gnb1 MultiRat cases    value_1=${PA_value}[3]    value_2=${PA_value}[4]
    ...    value_3=${PA_value}[4]    value_4=${PA_value}[4]
    Set default PA value for gnb2 MultiRat case    value_1=${PA_value}[4]  ## gnb cell2 and cell3 120db
    Check UE device exist
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Prepare env with UE    ue_index=${0}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'   Run Keywords
    ...    set apn dxdata2
    ...    AND    make WA with Samsung S21
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'
    ...    choice required APN on QCOM UE    usedapn=${X75_dxdata2_location}    ue_type=${ue_type}   ue_index=${0}
#    ...    Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2}
    Run Keyword If    '${ue_type}' == 'qct_dx50'    Prepare env with UE    ue_index=${0}
##gnb1 cell2
    Start Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname1}    interface=${interface}
    UE attach successfully    ue_index=${0}
    Stop Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname1}
    sleep   3s
# gnb1 cell2  VONR
    Start Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname2}    interface=${interface}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    Make a VoNR call(+6688)    ue_index=${0}
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
    sleep    30s
    check voice call status    ue_index=${0}    status=${2}
    run keyword and ignore error    Capture and download TTITrace log
    Stop Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname2}
# gnb1 cell2 HO cell1
    Start Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname3}    interface=${interface}
    sleep    30s
# trigger HO from gnb1cell2 to cell1 for B_08,gnb1 cell2 to 30db, cell1 0db,cell3 120db
    Set default PA value for gnb1 MultiRat cases    value_1=${PA_value}[2]    value_2=${PA_value}[3]
    ...    value_3=${PA_value}[4]    value_4=${PA_value}[4]
    sleep    30s
    run keyword and ignore error    Capture and download TTITrace log
    Stop Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname3}
    sleep   3s
# End  Call
    check voice call status    ue_index=${0}    status=${2}
    Start Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname4}    interface=${interface}
    End a call on UE    ue_index=${0}    serial_number=${serial_number}
    sleep    30s
    check voice call status    ue_index=${0}    status=${0}
    Stop Capture Wireshark Logs on gNB    nglogname=${B_8_gNB1_nglogname4}

    Check IE wireshark log for CDRX config    logname=${B_8_gNB1_nglogname1}    message_filter=${gnb_filter1}
    ...    value1=${value1}[0]    value2=${value1}[1]
    Run Keyword And Ignore Error    Check IE wireshark log for CDRX config    logname=${B_8_gNB1_nglogname2}    message_filter=${gnb_filter2}
    ...    value1=${value2}[0]    value2=${value2}[1]
    Check IE wireshark log for CDRX config    logname=${B_8_gNB1_nglogname3}    message_filter=${gnb_filter3}
    ...    value1=${value3}[0]    value2=${value3}[1]
    Check IE wireshark log for CDRX config    logname=${B_8_gNB1_nglogname4}    message_filter=${gnb_filter4}
    ...    value1=${value4}[0]    value2=${value4}[1]
    [Teardown]    Run Keywords
    ...           Online modify parmeters    parameters_to_update=${PARAM_CB006112_B_08_recover_WA}
    ...           AND    robot_common_operations.Common Case Teardown
    ...           AND    run keyword and ignore error    Test recover
    ...           AND    run keyword and ignore error    CI_interface.Common Case Teardown

*** Keywords ***
Switch QCOM APN to muti DRB
    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch APN to muti DRB
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}

Android UE SwitchApn
    [Documentation]
    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
    ...    str ui_version: mobile ui version.
    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
    android_mobile.setup
    ...               ui_version=${ui_version}    host=${host}    username=${username}
    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

Make a VoNR call(+6688) on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[0]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

Prepare env with UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=S21UI3.1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}

Test recover
    run keyword and ignore error    End a call on UE    serial_number=${tl.ues[0].serial_number}
    run keyword and ignore error    TL UE detach
    Set default PA value for gnb1 MultiRat cases    value_1=${PA_value}[3]    value_2=${PA_value}[4]
    ...    value_3=${PA_value}[4]    value_4=${PA_value}[4]
    Set default PA value for gnb2 MultiRat case    value_1=${PA_value}[4]

Set default PA value for cases
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value for HBTE
    ...    value_1=${PA_value}[3]     value_2=${PA_value}[3]
    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Adjust the attenuation value for HBTE
    ...    value_1=${PA_value}[3]     value_2=${PA_value}[3]

Change the PA value to trigger HO for B_08
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value for HBTE
    ...    value_1=${PA_value}[2]     value_2=${PA_value}[2]
    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Adjust the attenuation value for HBTE
    ...    value_1=${PA_value}[2]     value_2=${PA_value}[2]

Capture and download TTITrace log
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_9999'    Capture TTITrace and download to test pc ASIB
    ...    gnb_index=${1}    hw_slot=${1}
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Capture TTITrace and download to test pc ASIB
    ...    gnb_index=${1}    hw_slot=${5}

Adjust the attenuation value for HBTE
    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
    should be equal    ${value_port2}    ${value_1}

Set default PA value for gnb1 MultiRat cases
    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}    ${value_3}=${value_3}    ${value_4}=${value_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                gnb1 cell2 to 0db,  cell1 120db,cell3 120db
    ...                value_1:cell2 P3P4 value_2:cell1 P1P2 value_3:cell3 P5P6 value_4:enb P7P8
     Adjust the attenuation value for gnb1 Multi HBTE
     ...    value_1=${value_1}     value_2=${value_2}    value_3=${value_3}    value_4=${value_4}

Adjust the attenuation value for gnb1 Multi HBTE
    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}    ${value_3}=${value_3}    ${value_4}=${value_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    ...                value_1:cell2 P3P4 value_2:cell1 P1P2 value_3:cell3 P5P6 value_4:enb P7P8
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${5GRU_ANT1}    value=${value_2}
    att.set_attenuation     port=${5GRU_ANT2}    value=${value_2}
    att.set_attenuation     port=${5GRU_ANT3}    value=${value_1}
    att.set_attenuation     port=${5GRU_ANT4}    value=${value_1}
    att.set_attenuation     port=${5GRU_ANT5}    value=${value_3}
    att.set_attenuation     port=${5GRU_ANT6}    value=${value_3}
    att.set_attenuation     port=${4GRU_ANT7}    value=${value_4}
    att.set_attenuation     port=${4GRU_ANT8}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${5GRU_ANT1}
    should be equal    ${value_port1}    ${value_2}
    ${value_port2}    att.read_attenuation    port=${5GRU_ANT2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${5GRU_ANT3}
    should be equal    ${value_port3}    ${value_1}
    ${value_port4}    att.read_attenuation    port=${5GRU_ANT4}
    should be equal    ${value_port4}    ${value_1}
    ${value_port5}    att.read_attenuation    port=${5GRU_ANT5}
    should be equal    ${value_port5}    ${value_3}
    ${value_port6}    att.read_attenuation    port=${5GRU_ANT6}
    should be equal    ${value_port6}    ${value_3}
    ${value_port7}    att.read_attenuation    port=${4GRU_ANT7}
    should be equal    ${value_port7}    ${value_4}
    ${value_port8}    att.read_attenuation    port=${4GRU_ANT8}
    should be equal    ${value_port8}    ${value_4}


Set default PA value for gnb2 MultiRat case
    [Arguments]      ${value_1}=${value_1}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                 gnb2 cell2 and cell3 120db
     Adjust the attenuation value for gnb2 Multi HBTE    value_1=${value_1}

Adjust the attenuation value for gnb2 Multi HBTE
    [Arguments]      ${value_1}=${value_1}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${5GRU_ANT9}      value=${value_1}
    att.set_attenuation     port=${5GRU_ANT10}     value=${value_1}
    att.set_attenuation     port=${5GRU_ANT11}     value=${value_1}
    att.set_attenuation     port=${5GRU_ANT12}     value=${value_1}
    ${value_port9}    att.read_attenuation     port=${5GRU_ANT9}
    should be equal    ${value_port9}    ${value_1}
    ${value_port10}    att.read_attenuation    port=${5GRU_ANT10}
    should be equal    ${value_port10}    ${value_1}
    ${value_port11}    att.read_attenuation    port=${5GRU_ANT11}
    should be equal    ${value_port11}    ${value_1}
    ${value_port12}    att.read_attenuation    port=${5GRU_ANT12}
    should be equal    ${value_port12}    ${value_1}
