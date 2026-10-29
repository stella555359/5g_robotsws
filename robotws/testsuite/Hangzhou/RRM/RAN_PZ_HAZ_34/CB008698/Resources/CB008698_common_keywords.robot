*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008698
Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008698/Resources/CB008698_keywords.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Variables   ../Resources/CB008698_variables.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot

*** Variables ***
${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${tl_scf_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_0000}    25R2_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R1_ENB_0000}    25R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R3_ENB_0000}    24R3_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_0000}    24R2_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R4_ENB_0000}    Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R3_ENB_0000}    Configuration_scf_GNB1_CB008698.xml

${tl_scf2_SBTS25R3_ENB_9999}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_9999}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R1_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R3_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS23R4_ENB_0000}    Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS23R3_ENB_0000}    Configuration_scf_GNB2_CB008698.xml

#${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
#${tl_scf_file_name1}    Configuration_scf_GNB1_CB008698.xml
#${tl_scf_file_name2}    Configuration_scf_GNB2_CB008698.xml
${gnb_path}    /tmp/
${connection}    gnb
${epc_log_path}    /tmp/
${tshark_path}      /usr/bin/tshark
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}

@{5Gcell1_ANT}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
@{5Gcell2_ANT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
@{5Gcell3_ANT}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}

@{PA_value}    ${35}    ${50}    ${30}    ${0}     ${63}     ${48}  #int list
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_api_port}             ${tl.attenuator[0].port}
${TOPYOUNG_max_value}           ${120}
${vendor}                    ${tl.attenuator[0].vendor}

${att_api_ports}    ${tl.attenuator[0].port}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_9}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_10}               ${tl.attenuator[0].attenuator_ports[2]}
${atten_ip}                  ${tl.attenuator[0].ip_addr}
${SN}                       ${tl.ues[0].serial_number}
${ue_types}                  ${tl.ues[0].capabilities[0]}

${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
@{enb_dist_name2}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-0
@{enb_para}    administrativeState
@{enb_value}    unlocked    locked
@{enb_x2link_0}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
@{enb_x2link_1}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml
#@{gnb_list}    ${0}    ${1}
@{gnb_list}    ${0}
@{branch}    SBTS23R3_ENB_0000    SBTS23R4_ENB_0000    SBTS24R1_ENB_0000


*** Keywords ***
###attenuator###
Set TOPYOUNG Attenuation Value
    [Arguments]    ${ports}    ${cell}    ${value}    ${ip_addr}=${tl.attenuator[0].ip_addr}    ${port}=${tl.attenuator[0].port}
    atten.setup_attenuator    ip_addr=${ip_addr}    port=${port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${TOPYOUNG_max_value}    vendor=${vendor}
    atten.set_attenuation     port=${${cell}_ANT1}    value=${value}
    atten.set_attenuation     port=${${cell}_ANT2}    value=${value}


###BTS keyword###
Setup for Env cell on-air for 2 gnb
    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name1}    golden_scf_name_gnb2=${tl_scf_file_name2}

Setup for Env cell on-air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the gNB cells onair status
    should be equal    '${cell_status}'    'True'

Lock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.lock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM    timeout=60
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Unlock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.unlock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM    timeout=60
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get_cell_id_multi_cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${cell_list}=    coam.get_cell_list    connection=GNB_OAM
#    FOR     ${cell}    IN    @{cell_list['cells']['nr']}
#        @{cell_ids}=    set variable    ${cell['physicalCellId']}
#    END
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get BTS parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    ${distname_id}=${1}
    Log    ${distname_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=GNB_OAM
#    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${0}]['distName']}
    ...    pattern=${Abbreviation}    connection=GNB_OAM
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    ${distname_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=GNB_OAM
    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${MO_ID}]['distName']}
    ...    pattern=${Abbreviation}    connection=GNB_OAM
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

check Redirect status
    [Arguments]    ${gnb_index}=${0}    ${distname_id}=${1}
    ${actRedirect_status}=    get BTS parameter value    class_name=NRBTS    Abbreviation=actRedirect    gnb_index=${gnb_index}
    ...    distname_id=${distname_id}
    Set Test Variable    ${actRedirect_status}    ${actRedirect_status}

get nrCellIdentity value
    [Arguments]    ${gnb_index}=${0}    ${distname_id}=${0}
    ${nrCellIdentity_value}=    get parameter value    class_name=NRCELL    Abbreviation=nrCellIdentity
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}
    Set Test Variable    ${nrCellIdentity_value}    ${nrCellIdentity_value}

get required value of parameter
    [Arguments]    ${Abbreviation}    ${class_name}=NRCELL    ${gnb_index}=${0}    ${distname_id}=${0}
    ${parameter_value}=    get parameter value    class_name=${class_name}    Abbreviation=${Abbreviation}
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}
    [Return]    ${parameter_value}

###enb parameter
Modify parameter on enb
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify the enblte parameter    dist_name=${dist_name}    parameter=${parameter}    value=${value}

#set enb cell
#    [Arguments]    ${dist_name}=@{enb_dist_name}[0]    ${dist_name1}=@{enb_dist_name2}[0]    ${parameter}=@{enb_para}[0]    ${value}=@{enb_value}[0]
#    Run keyword if    '${enb_instance}'=='${911}'   Modify parameter on enb    dist_name=${dist_name1}    parameter=${parameter}    value=${value}
#    ...    ELSE    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]   ${dist_name1}=${enb_dist_name2}[0]
    Log    ${dist_name1}
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb MME IP
    [Arguments]    ${dist_name}=${enb_dist_name}[1]    ${parameter}=${enb_para}[1]    ${value}=${enb_value}[2]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

Lock x2link on ENB side for SA
    [Arguments]     ${dist_name_0}=${enb_x2link_0}[0]     ${dist_name_1}=${enb_x2link_1}[0]
    ...             ${parameter}=${enb_para}[0]    ${value}=${enb_value}[1]
    Modify parameter on enb    dist_name=${dist_name_0}    parameter=${parameter}    value=${value}
    Modify parameter on enb    dist_name=${dist_name_1}    parameter=${parameter}    value=${value}

Unlock x2link on ENB side
    [Arguments]     ${dist_name_0}=${enb_x2link_0}[0]     ${dist_name_1}=${enb_x2link_1}[0]
    ...             ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name_0}    parameter=${parameter}    value=${value}
    Modify parameter on enb    dist_name=${dist_name_1}    parameter=${parameter}    value=${value}


###UE keywordWords###
Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${0}
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}

Step2: UE setup VoNR call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: UE setup EMC call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    Make EMC call on UE    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: QCM UE setup EMC call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    QCM Make EMC call on UE    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step3: UE hang up VoNR call
    [Arguments]    ${ue_index}=${0}
    hang up VoNR call    ue_index=${ue_index}

Step3: UE hang up EMC call
    [Arguments]    ${ue_index}=${0}
    hang up EMC call    ue_index=${ue_index}

Step3: QCM UE hang up EMC call
    [Arguments]    ${ue_index}=${0}
    QCM hang up EMC call    ue_index=${ue_index}

Step4: Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Common UE parameter setup
    [Arguments]  ${ue_index}=${0}
#    set suite variable    ${ue_type}    ${tl.ues[${ue_index}].capabilities[1]}
    set suite variable    ${serial_number}    ${tl.ues[${ue_index}].serial_number}
#    Setup Variable for attenuator
#    Setup Variable for cellID

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21/S23 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   10s
    #####Samsung S23 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin${ue_index}
    sleep    2s
    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make EMC call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21/S23 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    #####Samsung S23 WA to click time cancel
    sleep    10s
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cpc_${ue_index}
    sleep    2s
    csn.disconnect      connection=cpc_${ue_index}

QCM Make EMC call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make EMC call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 66    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

QCM hang up EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 2067    connection=cpc_${ue_index}
    sleep      5s
    csn.disconnect      connection=cpc_${ue_index}

hang up EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    ####open 911 call manu
    csn.send_command    command=adb -s ${serial_number} shell input tap 250 55    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21/S23 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

Setup UE data status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=${status}

choice required APN on UE
    [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log    ${serial_number}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    set apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}

#make airplane mode to enable
#    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    log to console    enable airplane mode UE${ue_index}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
#    run keyword if    '${passed}'=='${False}'
#        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
#        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#        ...    close_task=${close_task}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   60s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

UE attach with new method
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${distname_id}=${0}
    Log    ${serial_number}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#    ...    close_task=${close_task}
    Wait Until Keyword Succeeds    3x    10s    make sure airplane mode disable    ue_index=${ue_index}
    UE attach verify with adb command    ue_index=${ue_index}    gnb_index=${gnb_index}    distname_id=${distname_id}

UE attach verify with adb command
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${gnb_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${distname_id}=${0}
    ${cell_id}=    get_attached_nr_cell_id_on_ue
    ...    host=${hostname}    username=${username}    password=${password}    sn=${serial_number}
    get nrCellIdentity value    gnb_index=${gnb_index}    distname_id=${distname_id}
    ${reslut}=    Run Keyword And Return Status    Should Be Equal As Strings    ${nrCellIdentity_value}    ${cell_id}
    Run Keyword If    '${reslut}'=='${True}'    Log to console    INFO:5G UE setup successfully.
    ...    ELSE IF    '${reslut}'=='${False}'    Fail    5G UE setup not successfully.

change UE 5G mode
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${system_and_udpate}=634 1984
    ...    ${swipe_indevelop}=500 2050 500 1800    ${develop_option}=500 1590    ${mode_tap}=500 2050    ${mode_selection}=SA
    ...    ${SA_tap}=500 1816    ${NSA_tap}=500 1667    ${USB_connection_mode_cancel}=584 2143
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    2s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep    2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep    2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep    2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    sleep    4s
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${system_and_udpate}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${develop_option}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep mCurrentFocus    connection=cygwin
    sleep   2s
    ${current_window} =    csn.read output    connection=cygwin
    Should Contain    ${current_window}    DevelopmentSettingsActivity
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe_indevelop}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${mode_tap}    connection=cygwin
    sleep    2s
    run keyword if    '${mode_selection}'=='SA'
    ...    csn.send_command    command=adb -s ${serial_number} shell input tap ${SA_tap}    connection=cygwin
    ...    ELSE IF    '${mode_selection}'=='NSA'
    ...    csn.send_command    command=adb -s ${serial_number} shell input tap ${NSA_tap}    connection=cygwin
    sleep    10s
    Check UE device exist    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap ${USB_connection_mode_cancel}    connection=cygwin
    sleep    2s
    csn.send_command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry | grep mServiceState    connection=cygwin
    ${nsaState}=    csn.read output    connection=cygwin
    ${regexp_result}=    find_string    string=${nsaState}    pattern=nsaState=\\d
    run keyword if    '${mode_selection}'=='SA'
    ...    Should Be Equal    ${regexp_result}[1]    nsaState=0
    ...    ELSE IF    '${mode_selection}'=='NSA'
    ...    Should Not Be Equal    ${regexp_result}[1]    nsaState=0
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Wait Until Keyword Succeeds    3x    30s    make sure airplane mode enable    ue_index=${ue_index}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#    ...    close_task=${close_task}
#    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
#    Should Be Equal    ${passed}    ${True}
    [Teardown]    Run Keyword and Ignore Error   csn.disconnect      connection=cygwin

make sure airplane mode enable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log    ${serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${False}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Should Be Equal    ${passed}    ${True}

make sure airplane mode disable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log    ${serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Should Be Equal    ${passed}    ${False}

check hanging resource for per UE on gnb
    [Arguments]    ${gnb_ips}    ${UE_Type_Index}=${2}
    ${ue_num}    get length    ${tl.ues}
#    set suite variable    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[${UE_Type_Index}]}    ue_index=${ue_index}
        make airplane mode to enable    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        Should Be Equal    ${passed}    ${True}
    END
    Check hanging resource for gnb    gnb_ips=${gnb_ips}

###check wireshark log###
Check EPSFB message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check EPSFB mesage on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}    pcap_parser=test6
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}    pcap_parser=test6
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression     filter_expression=${Code0_13_c6}    pcap_parser=test6
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}

Check EMC fallback message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check EMC fallback message on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}   alias=test6
    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}    pcap_parser=test6
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}    pcap_parser=test6
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression     filter_expression=${Code0_13_c6}    pcap_parser=test6
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}

Get RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialUEMessage, Registration request, Registration request
    ${Registration_request}=     Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 15
    ${Registration_request_packets}=    cap.filter_packets_by_expression    filter_expression=${Registration_request}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${Registration_request_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]

Get HO-RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####gnb1 PathSwitchRequest
    ${PathSwitch_request}=     Catenate    ngap.procedureCode == 25 and ngap.NGAP_PDU == 0
    ${PathSwitch_request_packets}=    cap.filter_packets_by_expression    filter_expression=${PathSwitch_request}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${PathSwitch_request_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]

Get NGHO-RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####gnb1 HandoverRequestAckknowledge
    ${HandoverRequestAckknowledge}=     Catenate    ngap.procedureCode == 13 and ngap.NGAP_PDU == 1
    ${HandoverRequestAckknowledge_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverRequestAckknowledge}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${HandoverRequestAckknowledge_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]

Get SgNB_UE_X2AP_ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${SgNBAdditionRequestAcknowledge}=     Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
    ${SgNBAdditionRequestAcknowledge_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBAdditionRequestAcknowledge}
    ${SgNB_UE_X2AP_ID}=     cap.get_field_value_by_xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//x2ap.SgNB_UE_X2AP_ID
    [Return]    ${SgNB_UE_X2AP_ID}[0]

Check SA preempted success message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preempted ue part##################################################
    ####UE CONTEXT RELEASE REQUEST(NGAP)
    ${UCRR_filter}=     Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE REQUEST
    ${UCRR_packets}=    cap.filter_packets_by_expression    filter_expression=${UCRR_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${UCRR_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Run Keyword If    '${actRedirect_status}' == 'True'    Should Be Equal    ${ngap_radioNetwork}[0]    41
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Should Be Equal    ${ngap_radioNetwork}[0]    46

    ####UE CONTEXT RELEASE COMMAND(NGAP)
    ${UCRC_filter} =    Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE COMMAND
    ${UCRC_packets}=    filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Run Keyword If    '${actRedirect_status}' == 'True'    Should Be Equal    ${ngap_radioNetwork}[0]    41
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Should Be Equal    ${ngap_radioNetwork}[0]    46

    ####BEARER CONTEXT RELEASE COMMAND(E1AP)
    ${BCRC_filter} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 11
    Log To Console    check BEARER CONTEXT RELEASE COMMAND
    ${BCRC_packets}=    filter_packets_by_expression    filter_expression=${BCRC_filter}
    ${e1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${BCRC_packets}
    ...    xpath=.//e1ap.radioNetwork
    Run Keyword If    '${actRedirect_status}' == 'True'    Should Be Equal    ${e1ap_radioNetwork}[0]    27
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Should Be Equal    ${e1ap_radioNetwork}[0]    27

    ####check UCRC when actRedirect is true, check rrcrelease when actRedirect is false
    Run Keyword If    '${actRedirect_status}' == 'True'    check UCRC when actRedirect is true
    ...    ELSE IF    '${actRedirect_status}' == 'False'    check rrcrelease when actRedirect is false

    ####UE CONTEXT RELEASE COMPLETE(NGAP)
    ${UCRC_filter}=     Catenate
    ...    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE COMPLETE
    ${UCRC_packets}=    cap.filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${ngap_RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    Should Be Equal    ${ngap_RAN_UE_NGAP_ID}[0]    ${SA_preempted_ue_id}

check UCRC when actRedirect is true
    ####UE CONTEXT RELEASE COMMAND(check on RRC Release)
    ${UCRC_filter} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and f1ap.radioNetwork == 16
    Log To Console    check F1AP UE CONTEXT RELEASE COMMAND
    ${UCRC_packets}=    filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${f1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...    xpath=.//f1ap.radioNetwork
    Should Be Equal    ${f1ap_radioNetwork}[0]    16

check rrcrelease when actRedirect is false
    ####RRCRelease(F1AP/NR RRC)
    ${RRCRelease_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and f1ap.radioNetwork == 16
    Log To Console    check RRCRelease
    ${RRCRelease_packets}=    filter_packets_by_expression    filter_expression=${RRCRelease_filter}
#    ${f1ap_UEContextReleaseCommand_element} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
#    ...    xpath=.//f1ap.UEContextReleaseCommand_element
#    Should Be Equal    ${f1ap_UEContextReleaseCommand_element}    1
    ${f1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
    ...    xpath=.//f1ap.radioNetwork
    ${nr-rrc_waitTime} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
    ...    xpath=.//nr-rrc.waitTime
    Run Keyword If    '${f1ap_radioNetwork}[0]' == '${16}'    Should Be Equal    '${nr-rrc_waitTime}[0]'    '${timerRejectWait_value}'
    ${nr_rrc_deprioritisationType} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
    ...    xpath=.//nr-rrc.deprioritisationType
    Should Be Equal    ${nr_rrc_deprioritisationType}[0]    0
    ${nr_rrc_deprioritisationTimer} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
    ...    xpath=.//nr-rrc.deprioritisationTimer
    Should Be Equal    ${nr_rrc_deprioritisationTimer}[0]    0


Check preemption success message
    [Arguments]    ${logname}    ${check_priorityLevelARP}=${1}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preemption ue part##################################################
    ####INITIAL CONTEXT SETUP REQUEST
    ${ICSR_filter}=     Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check INITIAL CONTEXT SETUP REQUEST
    ${ICSR_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_filter}
    ${ngap_priorityLevelARP}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_packets}
    ...                                                xpath=.//ngap.priorityLevelARP
    Should Contain    ${ngap_priorityLevelARP}    ${check_priorityLevelARP}

    ####BEARER CONTEXT SETUP REQUEST
    ${BCSR_filter} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 8 and e1ap.priorityLevel == ${check_priorityLevelARP}
    Log To Console    check BEARER CONTEXT SETUP REQUEST
    ${BCSR_packets}=    filter_packets_by_expression    filter_expression=${BCSR_filter}
    ${e1ap_priorityLevel} =    get_field_value_by_xpath    pdml_list=${BCSR_packets}
    ...    xpath=.//e1ap.priorityLevel
    Should Contain    ${e1ap_priorityLevel}    ${check_priorityLevelARP}

    ####BEARER CONTEXT SETUP RESPONSE
    ${BCSRS_filter} =    Catenate
    ...    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 8 and e1ap.GNB_CU_CP_UE_E1AP_ID == ${preemption_ue_id}
    Log To Console    check BEARER CONTEXT SETUP RESPONSE
    ${BCSRS_packets}=    filter_packets_by_expression    filter_expression=${BCSRS_filter}
    ${e1ap_GNB_CU_CP_UE_E1AP_ID} =    get_field_value_by_xpath    pdml_list=${BCSRS_packets}
    ...    xpath=.//e1ap.GNB_CU_CP_UE_E1AP_ID
    Should Be Equal    ${e1ap_GNB_CU_CP_UE_E1AP_ID}[0]    ${preemption_ue_id}

    ####UE CONTEXT SETUP REQUEST
    ${UCSR_filter} =    Catenate
    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 5 and f1ap.GNB_CU_UE_F1AP_ID == ${preemption_ue_id}
    Log To Console    check UE CONTEXT SETUP REQUEST
    ${UCSR_packets}=    filter_packets_by_expression    filter_expression=${UCSR_filter}
    ${f1ap_GNB_CU_UE_F1AP_ID} =    get_field_value_by_xpath    pdml_list=${UCSR_packets}
    ...    xpath=.//f1ap.GNB_CU_UE_F1AP_ID
    Should Be Equal    ${f1ap_GNB_CU_UE_F1AP_ID}[0]    ${preemption_ue_id}

    ####UE CONTEXT SETUP RESPONSE
    ${UCSRS_filter} =    Catenate
    ...    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 5 and f1ap.GNB_CU_UE_F1AP_ID == ${preemption_ue_id}
    Log To Console    check UE CONTEXT SETUP RESPONSE
    ${UCSRS_packets}=    filter_packets_by_expression    filter_expression=${UCSRS_filter}
    ${f1ap_GNB_CU_UE_F1AP_ID} =    get_field_value_by_xpath    pdml_list=${UCSRS_packets}
    ...    xpath=.//f1ap.GNB_CU_UE_F1AP_ID
    Should Be Equal    ${f1ap_GNB_CU_UE_F1AP_ID}[0]    ${preemption_ue_id}

    ####INITIAL CONTEXT SETUP RESPONSE
    ${ICSRS_filter}=     Catenate
    ...    ngap.NGAP_PDU == 1 and ngap.procedureCode == 14 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check INITIAL CONTEXT SETUP RESPONSE
    ${ICSRS_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSRS_filter}
    ${ngap_RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${ICSRS_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    Should Be Equal    ${ngap_RAN_UE_NGAP_ID}[0]    ${preemption_ue_id}

Check preemption DRB with Reestablishment
    [Arguments]    ${logname}    ${length_qosflow}=6    ${length_pduid}=2
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####INITIAL CONTEXT SETUP RESPONSE
    ${ICSRS_filter}=     Catenate
    ...    ngap.NGAP_PDU == 1 and ngap.procedureCode == 14 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check INITIAL CONTEXT SETUP RESPONSE
    ${ICSRS_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSRS_filter}
    ${ngap_qosFlowIdentifier}=     cap.get_field_value_by_xpath    pdml_list=${ICSRS_packets}
    ...                                                xpath=.//ngap.qosFlowIdentifier
    ${ngap_pDUSessionID}=     cap.get_field_value_by_xpath    pdml_list=${ICSRS_packets}
    ...                                                xpath=.//ngap.pDUSessionID
    Length Should Be    ${ngap_qosFlowIdentifier}    ${length_qosflow}
    Length Should Be    ${ngap_pDUSessionID}    ${length_pduid}
    List Should Not Contain Duplicates    ${ngap_pDUSessionID}

Check preemption not execute message
    [Arguments]    ${logname}    ${length_qosflow}=7
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialContextSetupResponse
    ${ICSRS_filter}=     Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 14
    Log To Console    check INITIAL CONTEXT SETUP RESPONSE
    ${ICSRS_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSRS_filter}
    ${ngap_qosFlowIdentifier}=     cap.get_field_value_by_xpath    pdml_list=${ICSRS_packets}
    ...                                                xpath=.//ngap.qosFlowIdentifier
    Length Should Be    ${ngap_qosFlowIdentifier}    ${length_qosflow}

    ${UCRR_filter}=     Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE REQUEST
    ${UCRR_packets}=    cap.filter_packets_by_expression    filter_expression=${UCRR_filter}
    ${ngap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${UCRR_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Empty    ${ngap_procedureCode}

    ${UCRC_filter} =    Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE COMMAND
    ${UCRC_packets}=    filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${ngap_procedureCode} =    get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Empty    ${ngap_procedureCode}

    ${BCRC_filter} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 11
    Log To Console    check BEARER CONTEXT RELEASE COMMAND
    ${BCRC_packets}=    filter_packets_by_expression    filter_expression=${BCRC_filter}
    ${e1ap_procedureCode} =    get_field_value_by_xpath    pdml_list=${BCRC_packets}
    ...    xpath=.//e1ap.procedureCode
    Should Be Empty    ${e1ap_procedureCode}

    ${UCRC_filter} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and f1ap.radioNetwork == 16
    Log To Console    check F1AP UE CONTEXT RELEASE COMMAND
    ${UCRC_packets}=    filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${f1ap_procedureCode} =    get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...    xpath=.//f1ap.procedureCode
    Should Be Empty    ${f1ap_procedureCode}

    ${RRCRelease_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and f1ap.radioNetwork == 16
    Log To Console    check RRCRelease
    ${RRCRelease_packets}=    filter_packets_by_expression    filter_expression=${RRCRelease_filter}
    ${f1ap_procedureCode} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
    ...    xpath=.//f1ap.procedureCode
    Should Be Empty    ${f1ap_procedureCode}

    ${UCRC_filter}=     Catenate
    ...    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE COMPLETE
    ${UCRC_packets}=    cap.filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${ngap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Empty    ${ngap_procedureCode}

Get drb id with attach
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${BCSR_filter}=    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 8
    Log To Console    BearerContextSetupRequest
    ${BCSR_packets}=    cap.filter_packets_by_expression    filter_expression=${BCSR_filter}
    ${e1ap_dRB_ID_1}=     cap.get_field_value_by_xpath    pdml_list=${BCSR_packets}
    ...                                                xpath=.//e1ap.dRB_ID
    ${BCMR_filter}=    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    BearerContextModificationRequest
    ${BCMR_packets}=    cap.filter_packets_by_expression    filter_expression=${BCMR_filter}
    ${e1ap_dRB_ID_2}=     cap.get_field_value_by_xpath    pdml_list=${BCMR_packets}
    ...                                                xpath=.//e1ap.dRB_ID
    ${id_list}=    Combine Lists    ${e1ap_dRB_ID_1}    ${e1ap_dRB_ID_2}
    ${drb_id_list}=    Remove Duplicates    ${id_list}
    [Return]    ${drb_id_list}

Get fiveqi id with attach
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ICSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log To Console    InitialContextSetupRequest
    ${ICSR_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_filter}
    ${ngap_fiveQI_1}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_packets}
    ...                                                xpath=.//ngap.fiveQI
    ${PSRSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 29
    Log To Console    PDUSessionResourceSetupRequest
    ${PSRSR_packets}=    cap.filter_packets_by_expression    filter_expression=${PSRSR_filter}
    ${ngap_fiveQI_2}=     cap.get_field_value_by_xpath    pdml_list=${PSRSR_packets}
    ...                                                xpath=.//ngap.fiveQI
    ${id_list}=    Combine Lists    ${ngap_fiveQI_1}    ${ngap_fiveQI_2}
    ${fiveqi_id_list}=    Remove Duplicates    ${id_list}
    [Return]    ${fiveqi_id_list}

Get priorityLevelARP id with attach
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ICSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log To Console    InitialContextSetupRequest
    ${ICSR_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_filter}
    ${ngap_priorityLevelARP_1}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_packets}
    ...                                                xpath=.//ngap.priorityLevelARP
    ${PSRSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 29
    Log To Console    PDUSessionResourceSetupRequest
    ${PSRSR_packets}=    cap.filter_packets_by_expression    filter_expression=${PSRSR_filter}
    ${ngap_priorityLevelARP_2}=     cap.get_field_value_by_xpath    pdml_list=${PSRSR_packets}
    ...                                                xpath=.//ngap.priorityLevelARP
    ${id_list}=    Combine Lists    ${ngap_priorityLevelARP_1}    ${ngap_priorityLevelARP_2}
    ${priorityLevelARP_id_list}=    Remove Duplicates    ${id_list}
    [Return]    ${priorityLevelARP_id_list}

Check Partial admission during intra-gNB HO
    [Arguments]    ${logname}
    ${nrCellId1}=    get required value of parameter    Abbreviation=physCellId    distname_id=${1}
    ${nrCellId2}=    get required value of parameter    Abbreviation=physCellId    distname_id=${2}
    ${maxNumOfNonGBRBearersSA}=    get required value of parameter    Abbreviation=maxNumOfNonGBRBearersSA    distname_id=${1}
    ${nrCellId1}=    Convert To String    ${nrCellId1}
    ${nrCellId2}=    Convert To String    ${nrCellId2}
    ${release_number}=    Evaluate    ${length_drb}-${maxNumOfNonGBRBearersSA}
    ${result}=    get_released_5qi_drb_qosflow
    ...    required_mapping_list=${drb_id_list}    arppriority=${priorityLevelARP_id_list}    number=${release_number}

    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####Measurement report
    ${MR_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    Measurement report
    ${MR_packets}=    cap.filter_packets_by_expression    filter_expression=${MR_filter}
    ${nr_rrc_physCellId}=     cap.get_field_value_by_xpath    pdml_list=${MR_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    Should Contain    ${nr_rrc_physCellId}    ${nrCellId1}
    Should Contain    ${nr_rrc_physCellId}    ${nrCellId2}

    ####Bearer Context Modification Request
    ${BCMR_filter}=    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9 and e1ap.id == 26
    Log To Console    Bearer Context Modification Request
    ${BCMR_packets}=    cap.filter_packets_by_expression    filter_expression=${BCMR_filter}
    ${e1ap_dRB_ID}=     cap.get_field_value_by_xpath    pdml_list=${BCMR_packets}
    ...                                                xpath=.//e1ap.dRB_ID
    Length Should Be    ${e1ap_dRB_ID}    3
    Should Be Equal    ${result}[0]    ${e1ap_dRB_ID}

    ####Bearer Context Modification Response
    ${BCMRes_filter}=    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    Bearer Context Modification Response
    ${BCMRes_packets}=    cap.filter_packets_by_expression    filter_expression=${BCMRes_filter}
    ${e1ap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${BCMRes_packets}
    ...                                                xpath=.//e1ap.procedureCode
#    ${e1ap_dRB_ID}=     cap.get_field_value_by_xpath    pdml_list=${BCMRes_packets}
#    ...                                                xpath=.//e1ap.dRB_ID
    Should Be Equal    ${e1ap_procedureCode}[0]    9

    ####UE Context Modification Request
    ${UCMR_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    UE Context Modification Request
    ${UCMR_packets}=    cap.filter_packets_by_expression    filter_expression=${UCMR_filter}
    ${f1ap_dRBID}=     cap.get_field_value_by_xpath    pdml_list=${UCMR_packets}
    ...                                                xpath=.//f1ap.DRBs_ToBeReleased_List//f1ap.dRBID
    Length Should Be    ${f1ap_dRBID}    2
    Sort List    ${f1ap_dRBID}
    Sort List    ${result}[2]
    Should Be Equal    ${result}[2]    ${f1ap_dRBID}

    ####UE Context Modification Response
    ${UCMRes_filter}=    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    UE Context Modification Response
    ${UCMRes_packets}=    cap.filter_packets_by_expression    filter_expression=${UCMRes_filter}
    ${f1ap_dRBID}=     cap.get_field_value_by_xpath    pdml_list=${UCMRes_packets}
    ...                                                xpath=.//f1ap.dRBID
    Length Should Be    ${f1ap_dRBID}    3
    Should Be Equal    ${result}[0]    ${f1ap_dRBID}

    ####RRC reconfiguration
    ${RR_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    RRC reconfiguration
    ${RR_packets}=    cap.filter_packets_by_expression    filter_expression=${RR_filter}
    ${nr_rrc_DRB_Identity}=     cap.get_field_value_by_xpath    pdml_list=${RR_packets}
    ...                                                xpath=.//nr-rrc.DRB_Identity
    Length Should Be    ${nr_rrc_DRB_Identity}    2

    ####RRC reconfiguration complete
    ${RRC_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    RRC reconfiguration complete
    ${RRC_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_filter}
    ${nr_rrc_c1}=     cap.get_field_value_by_xpath    pdml_list=${RRC_packets}
    ...                                                xpath=.//nr-rrc.c1
    Should Be Equal    ${nr_rrc_c1}[1]    1

    ####PDU Session Resource Notify message
    ${PSRN_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 30
    Log To Console    PDU Session Resource Notify message
    ${PSRN_packets}=    cap.filter_packets_by_expression    filter_expression=${PSRN_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${PSRN_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Length Should Be    ${ngap_radioNetwork}    2
    ${new_ngap_radioNetwork}=    Remove Duplicates    ${ngap_radioNetwork}
    Length Should Be    ${new_ngap_radioNetwork}    1
    Should Be Equal    ${new_ngap_radioNetwork}[0]    22


Check NG_HO preemption success message
    [Arguments]    ${logname}    ${check_priorityLevelARP}=${1}
    Log    ${logname}
    Log    ${check_priorityLevelARP}
    ##########################################preemption ue part##################################################
    ####HandoverRequest(NGAP)
    ${HandoverRequest_filter}=     Catenate
    ...    ngap.procedureCode == 13 and ngap.NGAP_PDU == 0
    Log To Console    check HandoverRequest
    ${HandoverRequest_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverRequest_filter}
    ${ngap_NGAP_PDU}=     cap.get_field_value_by_xpath    pdml_list=${HandoverRequest_filter_packets}
    ...                                                xpath=.//ngap.NGAP_PDU
    Should Be Equal    ${ngap_NGAP_PDU[0]}    0
    ####HandoverRequestAcknowledge(NGAP)
    ${HandoverRequestAcknowledge_filter}=     Catenate
    ...     ngap.procedureCode == 13 and ngap.NGAP_PDU == 1 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check HandoverRequest
    ${HandoverRequestAcknowledge_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverRequestAcknowledge_filter}
    ${ngap_NGAP_PDU}=     cap.get_field_value_by_xpath    pdml_list=${HandoverRequestAcknowledge_filter_packets}
    ...                                                xpath=.//ngap.NGAP_PDU
    Should Be Equal    ${ngap_NGAP_PDU[0]}    1
    ####DownlinkRANStatusTransfer(NGAP)
    ${DownlinkRANStatusTransfer_filter}=     Catenate
    ...    ngap.procedureCode == 7 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check HandoverRequest
    ${DownlinkRANStatusTransfer_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${DownlinkRANStatusTransfer_filter}
    ${ngap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${DownlinkRANStatusTransfer_filter_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Equal    ${ngap_procedureCode[0]}    7
    ####HandoverNotify(NGAP)
    ${HandoverNotify_filter}=     Catenate
    ...    ngap.procedureCode == 11 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check HandoverRequest
    ${HandoverNotify_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverNotify_filter}
    ${ngap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${HandoverNotify_filter_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Equal    ${ngap_procedureCode[0]}    11

Check XN_HO preemption success message
    [Arguments]    ${logname}    ${check_priorityLevelARP}=${1}
    Log    ${check_priorityLevelARP}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preemption ue part##################################################
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}
    ${HO_req}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_packets}
    ...                               xpath=.//xnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr} and xnap.NG_RANnodeUEXnAPID == ${preemption_ue_id}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_ACK_packets}
    ...                               xpath=.//xnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest(NGAP)
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr} and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}
    ${PathS_req}=     cap.get_field_value_by_xpath    pdml_list=${PathS_req_packets}
    ...                               xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge(NGAP)
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr} and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}
    ${PathS_ACK}=     cap.get_field_value_by_xpath    pdml_list=${PathS_ACK_packets}
    ...                               xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease(XNAP)
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6 and xnap.NG_RANnodeUEXnAPID == ${preemption_ue_id}
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}
    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                               xpath=.//xnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6

Check HO preemption success message
    [Arguments]    ${logname}    ${check_priorityLevelARP}=${1}
    Log    ${check_priorityLevelARP}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preemption ue part##################################################
    ####UEContextReleaseRequest(NGAP)
    ${UEContextReleaseRequest_filter}=     Catenate
    ...    ngap.procedureCode == 42 and ngap.radioNetwork == 46 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check UEContextReleaseRequest
    ${UEContextReleaseRequest_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseRequest_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${UEContextReleaseRequest_filter_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Should Be Equal    ${ngap_radioNetwork[0]}    46
    ####UEContextReleaseCommand(NGAP)
    ${UEContextReleaseCommand_filter}=     Catenate
    ...    ngap.procedureCode == 41 and ngap.radioNetwork == 46 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check UEContextReleaseCommand
    ${UEContextReleaseRequest_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseCommand_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${UEContextReleaseRequest_filter_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Should Be Equal    ${ngap_radioNetwork[0]}    46
    ####UEContextReleaseComplete(NGAP)
    ${UEContextReleaseComplete_filter}=     Catenate
    ...    ngap.procedureCode == 41 and ngap.NGAP_PDU == 1 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check UEContextReleaseCommand
    ${UEContextReleaseRequest_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseComplete_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${UEContextReleaseRequest_filter_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Should Contain    ${ngap_radioNetwork[0]}    41

Check NSA preempted success message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preempted ue part##################################################
    ####SgNBReleaseRequired
    ${SgNBReleaseRequired}=     Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
    Log To Console    check SgNBReleaseRequired
    ${SgNBReleaseRequired_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBReleaseRequired}
    ${x2ap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${SgNBReleaseRequired_packets}
    ...                                                xpath=.//x2ap.radioNetwork
    Should Be Equal    ${x2ap_radioNetwork}[0]    36

    ####SgNBReleaseConfirm
    ${SgNBReleaseConfirm}=     Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 32
    Log To Console    check SgNBReleaseConfirm
    ${SgNBReleaseConfirm_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBReleaseConfirm}
    ${x2ap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${SgNBReleaseConfirm_packets}
    ...                                                xpath=.//x2ap.procedureCode
    Should Be Equal    ${x2ap_procedureCode}[0]    32

    ####UEContextRelease
    ${UEContextRelease}=     Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
    Log To Console    check UEContextRelease
    ${UEContextRelease_packets}=    cap.filter_packets_by_expression    filter_expression=${UEContextRelease}
    ${x2ap_SgNB_UE_X2AP_ID}=     cap.get_field_value_by_xpath    pdml_list=${UEContextRelease_packets}
    ...                                                xpath=.//x2ap.SgNB_UE_X2AP_ID
    Should Be Equal    ${x2ap_SgNB_UE_X2AP_ID}[0]    ${NSA_preempted_ue_id}

    ####SgNBAdditionRequest
    ${SgNBAdditionRequest}=     Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
    Log To Console    check SgNBAdditionRequest
    ${SgNBAdditionRequest_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBAdditionRequest}
    ${x2ap_procedureCode}=     cap.get_field_value_by_xpath    pdml_list=${SgNBAdditionRequest_packets}
    ...                                                xpath=.//x2ap.procedureCode
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${x2ap_procedureCode}

    ####SgNBAdditionRequestReject
    ${SgNBAdditionRequestReject}=     Catenate    x2ap.X2AP_PDU == 2 and x2ap.procedureCode == 27
    Log To Console    check SgNBAdditionRequestReject
    ${SgNBAdditionRequestReject_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBAdditionRequestReject}
    ${x2ap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${SgNBAdditionRequestReject_packets}
    ...                                                xpath=.//x2ap.radioNetwork
    Run Keyword If    ${status}==True    Log    message SgNBAdditionRequest is not exist
    ...    ELSE IF    ${status}==False    Should Be Equal    ${x2ap_radioNetwork}[0]    12

Check intergNB_NGAP HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
#    ####PDUSessionResourceModifyRequest
#    Log To Console     PDUSessionResourceModifyRequest
#    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
#    ${5QI_1_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_1_filter}    pcap_parser=test6
#    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    Should Be Equal    ${ngap_fiveQI[0]}    1
    ####HandoverRequired(NGAP)
    Log To Console    HandoverRequired
    ${HO_req_filter}=     Catenate    ngap.procedureCode == 12 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    12
    ####HandoverCommand(NGAP)
    Log To Console    HandoverCommand
    ${HandoverCommand_filter}=     Catenate    ngap.procedureCode == 12 and ip.dst == ${asik2_addr}
    ${HandoverCommand_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverCommand_filter}    pcap_parser=test6
    ${HO_Com}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_Com[0]}    12
    ###UEContextRelease
#    Log To Console    UEContextRelease
#    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
#    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
#    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
#    Should Be Equal    ${UE_rel[0]}    6
    ###UEContextReleaseCommand(NGAP)
    Log To Console    UEContextReleaseCommand
    ${UE_rel_filter}=     Catenate    ngap.procedureCode == 41 and ngap.radioNetwork == 2
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    2
    ###UEContextReleaseComplete(NGAP)
    Log To Console    UEContextReleaseComplete
    ${UE_rel_filter}=     Catenate    ngap.procedureCode == 41 and ngap.NGAP_PDU == 1
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//ngap.NGAP_PDU    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    1
    ####RRC ReConfiguration(eventA3)
    ####RRC ReConfiguration(eventA3)
    ####UEContextReleaseCommand
    ####UEContextReleaseComplete

Check intergNB_NGAP HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest(NGAP)
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    ngap.procedureCode == 13 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    13
    ####HandoverRequestAckonwledge(NGAP)
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    ngap.procedureCode == 13 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    13
    ###PathSwitchRequest
#    Log To Console    PathSwitchRequest
#    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
#    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
#    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
#    Should Be Equal    ${PathS_req[0]}    25
    ###PathSwitchRequestAckonwledge
#    Log To Console    PathSwitchRequestAckonwledge
#    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
#    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
#    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
#    Should Be Equal    ${PathS_ACK[0]}    25
    ###UEContextRelease
#    Log To Console    UEContextRelease
#    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
#    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
#    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
#    Should Be Equal    ${UE_rel[0]}    6
#    ####UEContextSetupRequest,RRC ReConfiguration(eventA3)
#    Log To Console    RRC ReConfiguration
#    ${RRC_Rec_filter}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.eventId == 2
#    ${RRC_Rec_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Rec_filter}    pcap_parser=test6
#    ${RRC_Rec}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
#    should contain    ${RRC_Rec}    2
    ###RRC ReConfiguration Complete
#    Log To Console    RRC ReConfiguration Complete
#    ${RRC_ReCom_filter}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.criticalExtensions == 0
#    ${RRC_ReCom_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_ReCom_filter}    pcap_parser=test6
#    ${RRC_ReCom}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
#    Should Be Equal    ${RRC_ReCom}    0
    ####HandoverNotify(NGAP)
    Log To Console    HandoverNotify
    ${UE_HandoverNotify_filter}=     Catenate     ngap.procedureCode == 11 and ngap.NGAP_PDU == 0
    ${UE_HandoverNotify_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_HandoverNotify_filter}    pcap_parser=test6
    ${UE_HandoverNotify}=     cap.Get Field Value By Xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_HandoverNotify[0]}    11
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check L3 Call intergNB HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     xnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1
    ####RRC ReConfiguration(eventA3)
    ####RRC ReConfiguration(eventA3)

Check L3 Call intergNB HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
#    ####UEContextSetupRequest,RRC ReConfiguration(eventA3)
#    Log To Console    RRC ReConfiguration
#    ${RRC_Rec_filter}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.eventId == 2
#    ${RRC_Rec_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Rec_filter}    pcap_parser=test6
#    ${RRC_Rec}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
#    should contain    ${RRC_Rec}    2
#    ####RRC ReConfiguration Complete
#    Log To Console    RRC ReConfiguration Complete
#    ${RRC_ReCom_filter}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.criticalExtensions == 0
#    ${RRC_ReCom_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_ReCom_filter}    pcap_parser=test6
#    ${RRC_ReCom}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
#    Should Be Equal    ${RRC_ReCom[0]}    0
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check intergNB HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
#    ####PDUSessionResourceModifyRequest
#    Log To Console     PDUSessionResourceModifyRequest
#    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
#    ${5QI_1_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_1_filter}    pcap_parser=test6
#    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    Should Be Equal    ${ngap_fiveQI[0]}   1
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     xnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1
    ####RRC ReConfiguration(eventA3)
    ####RRC ReConfiguration(eventA3)

Check intergNB HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
#    ####UEContextSetupRequest,RRC ReConfiguration(eventA3)
#    Log To Console    RRC ReConfiguration
#    ${RRC_Rec_filter}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.eventId == 2
#    ${RRC_Rec_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Rec_filter}    pcap_parser=test6
#    ${RRC_Rec}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
#    should contain    ${RRC_Rec}    2
#    ####RRC ReConfiguration Complete
#    Log To Console    RRC ReConfiguration Complete
#    ${RRC_ReCom_filter}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.criticalExtensions == 0
#    ${RRC_ReCom_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_ReCom_filter}    pcap_parser=test6
#    ${RRC_ReCom}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
#    Should Be Equal    ${RRC_ReCom}    0
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check intragNB interFre HO process on gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####UEContextModificationRequest,RRC Reconfiguration
    Log To Console    RRC Reconfiguration
    ${RRC_Reconfiguration_filter}=     Catenate    f1ap.procedureCode == 7 and f1ap.F1AP_PDU == 0 and nr-rrc.criticalExtensions == 0
    ${RRC_Re_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}    pcap_parser=test6
    ${RRC_Re}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
    should contain    ${RRC_Re}    0
    Log To Console    RRC Reconfiguration Completed
    ${RRC_Reconfiguration_filter}=     Catenate
    ...    f1ap.procedureCode == 13 and nr-rrc.criticalExtensions == 0 and f1ap.F1AP_PDU == 0
    ${RRC_Re_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}    pcap_parser=test6
    ${RRC_ReC}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
    should contain    ${RRC_ReC}    0

Check VONR Normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

Check the Two VONR Normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
#    Should Be Equal    ${ngap_nas[0]}    0
    should contain x times    ${ngap_nas}    0    2

Check wireshark log for ECC release
    [Arguments]    ${logname}
    Check wireshark log for ECC    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
    ...    xpath_filter=ngap.nas    expect_value=0
    Check wireshark log for ECC    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28
    ...    xpath_filter=ngap.PDUSessionResourceReleaseResponse_element
    ...    expect_value=PDUSessionResourceReleaseResponse
    ...    attribute_name=showname

Check wireshark log for ECC
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_with_Y}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression
    ...    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_value}=     cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}    pcap_parser=test6
    should be equal    ${filtered_value[0]}    ${expect_value}

Check VoNR release success message
    [Arguments]    ${logname}
    Analysis wireshark log for VoNR success release    logname=${logname}

Analysis wireshark log for VoNR success release
     [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_nas} =    get_field_value_by_xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_id} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${ngap_id[0]}    0



###PM counter
Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb counter greater expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}>=${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb counter contain expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should contain any    ${counter_value}    ${1}    ${2}
    [Teardown]    COAM Teardown gnb connections

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

get dict kpi from pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}

check required KPI via pm file
    [Arguments]    ${KPI_name_list}    ${check_field}    ${dict_kpi_get}
    ...    ${equal_specfied}=${0}    ${larger_specfied}=${0}    ${less_specfied}=${0.011}    ${greater_than_or_equal_specfied}=${0}
    FOR    ${KPI_name}    IN    @{KPI_name_list}
        Run Keyword IF    '${check_field}' == 'equal_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] == ${equal_specfied}
        ...    ELSE IF    '${check_field}' == 'larger_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] > ${larger_specfied}
        ...    ELSE IF    '${check_field}' == 'less_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] < ${less_specfied}
        ...    ELSE IF    '${check_field}' == 'greater_than_or_equal_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] >= ${greater_than_or_equal_specfied}
    END

check cell1 counter KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell1_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${0}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell1_one}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${1}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell1_two}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${2}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell1_three}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${3}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell1_five}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${5}

check cell2 counter KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell2_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${0}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell2_two}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${2}
    check required KPI via pm file    KPI_name_list=${CB008698_F_006_kpi_names_value_cell2_three}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${3}
