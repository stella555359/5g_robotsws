*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002056-BGAN/Resources/Prepare_IWK_TestLine.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Library           taf.pdu    WITH NAME    pdu
Library         SSHLibrary


*** Variables ***
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${dist_name}      MRBTS-${mrbtsId}/EQM-1/APEQM-1/RMOD-1
#${WEBUI_URL}        https://${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ru_user}      ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.username}
${ru_password}     ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.password}
${connection}    GNB

${tmp_log_dir}    /home/ute/log
${testline}  7_5_UTE5G402T919
${alarm_filter}   Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
${scf_name}      TL2066.xml
*** Keywords ***
Case Setup
    Log To Console    \n *** Case Setup
    Conect to DU COAM
    Check If BTS Is OnAir
    ${mrbtsId}    Set variable    ${tl.gnbs[0].instance_id}
    ${nrbtsId}    Set variable    ${tl.gnbs[0].global_bts_id}
    admin_cli.get_current_scf_file    local_dir_path=${tmp_log_dir}    file_name=${scf_name}    connection=${connection}
    ${commission_file}    set variable    ${tmp_log_dir}/${scf_name}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}


Case Teardown
    Log To Console    \n *** Case Teardown
    Conect to DU COAM
    run keyword and ignore error    COAM Reset RMOD
    ...      dist_name=${dist_name}     connection=${connection}
    admin_cli.teardown    connection=${connection}

Disconnect from cOAM
    [Arguments]  ${connection}
    csn.disconnect  ${connection}

Configure ${parameter} to ${value}
    Log To Console    \n****Configure ${parameter} to ${value}   console=yes
    Conect to DU COAM
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-10576/EQM-1/APEQM-1/RMOD-1
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


Set RU Voltage to ${value}
    Log To Console    \n****Configure RU Voltage to ${value}V
    csn.Connect to   ${DU_OAM_IP}    ${bts_username}    ${bts_password}    alias=${connection}
    ${FRIps}    csn.execute   cat /rom/config/FRIps.txt    connection=${connection}
	${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${RU_IP}=     Get from list       ${splitFRIps}     2
    ${containers}=    csn.Execute    lxc-ls     connection=${connection}
    ${fhnet_container}=    get regexp matches     ${containers}     \0x[12]018
    SSHLibrary.Open Connection    ${DU_OAM_IP}    timeout=10    alias=${connection}
    ${output}    SSHLibrary.Login    ${bts_username}    ${bts_password}
    sleep    2
    ${output}    SSHLibrary.Write    rm -rf /user/toor4nsn/.ssh/known_hosts
    sleep    2
    ${output}    SSHLibrary.Write    lxc-attach -n ${fhnet_container[0]}
    SSHLibrary.Read Until    >
    sleep    2
    ${out}    SSHLibrary.Write    ssh ${ru_user}@${RU_IP}
    sleep   2
#    SSHLibrary.Write    yes
#    sleep    2
    ${continue}=                        Run keyword and return status
    ...                                 SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
    Run keyword if   ${continue}        SSHLibrary.Write                    text=yes
    ...              ELSE               SSHLibrary.Write                    text=wrong_password
    Sleep            time_=20s          reason=Waiting for password prompt...
#    SSHLibrary.Read Until               expected=password:
#    SSHLibrary.Write                    text=${password}
    SSHLibrary.Read Until               ${ru_user}@${RU_IP}'s password:
    SSHLibrary.Write                    text=${ru_password}
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=\
    sleep  2
    ${out}    SSHLibrary.Write    rad -mw 0x110032 ${value}000
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection


Check fault report
    Log To Console    \n****Check fault report    console=yes
    [Arguments]    ${fault_ID}    ${alarm_filter}
    Conect to DU COAM
    ${alarm info}    coam.get_alarms   timeout=60    connection=${connection}    detailed_output=False
    ${alarm_status}=		Set Variable	${FALSE}
    FOR    ${alarm}  IN      @{alarm info}
        Log Dictionary		${alarm}
        ${alarm_status}=	Set Variable If		'${alarm['faultId']}'=='${fault_ID}' and '${alarm['alarmId']}'=='${alarm_filter}'    ${TRUE}    ${FALSE}
        Exit For Loop If	${alarm_status}==${TRUE}
     END
    Run Keyword If	${alarm_status}==${FALSE}	Log To Console	Fault ${fault_ID} not proper raised
	Should Be True	${alarm_status}==${TRUE}

Check fault clear
    Log To Console    \n****Check fault clear   console=yes
    [Arguments]    ${fault_ID}    ${alarm_filter}
    Conect to DU COAM
    @{alarm info}    coam.get_alarms   timeout=60    connection=${connection}    detailed_output=False
    ${alarm_status}=		Set Variable	${FALSE}
    FOR    ${alarm}  IN      @{alarm info}
        Log Dictionary		${alarm}
        ${alarm_status}=	Set Variable If		'${alarm['faultId']}'=='${fault_ID}' and '${alarm['alarmId']}'=='${alarm_filter}'    ${TRUE}    ${FALSE}
        Exit For Loop If	${alarm_status}==${TRUE}
     END
    Run Keyword If	${alarm_status}==${TRUE}	Log To Console	Fault ${fault_ID} not proper canceled
	Should Be True	${alarm_status}==${FALSE}

Conect to DU COAM
    [Arguments]    ${connection}=${connection}
    coam.connect to   bts_host=${DU_OAM_IP}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${connection}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir



