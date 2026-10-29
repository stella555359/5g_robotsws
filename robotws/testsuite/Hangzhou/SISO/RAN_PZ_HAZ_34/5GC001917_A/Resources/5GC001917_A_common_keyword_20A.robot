*** Settings ***
Documentation
...   author: qionghua zhang
...   contact: qionghua.zhang@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC000738

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    Telnet
Library    taf.transport.ssh    WITH NAME    csn
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
Resource    taf/rfrl/common_resources/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library    taf.sbts.oam.coam.admin   WITH NAME    coam

*** Variables ***
${AT_script_path}    C:/Tools/AT
${ue_plmn_default}    at+cops=1,2,24409,7
${enb_b1_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${enb_b1_para}    actDynTrigLteNrDualConnectivity
${dl_port}    ${tl.ues[0].ssh_connection_details.port}
${ul_port}    ${tl.ues[0].iperf_details.port}
${dl_time}    20
${dl_throughput}    10M
${dl_length}    1024B
${ul_time}    10
${ul_throughput}     1M
${ul_length}    1024B
${ul_expect}    0
${dl_expect}    0
${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
${tl_scf_filename}    TL33_738_SCF.xml
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enbx2_para}    administrativeState
${lnrel_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${lnrel_para}    defaultLnRelGnbCellId


*** Keywords ***
Prepare with COMA gNB classical BTS cell onair
    [Arguments]    ${lnrel_value}=0    ${ru_reset}=no
#    Power reset For All RU    ru_reset=${RU_reset}
    Perform full commission for COAM classical gnb
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check COAM gnb classical start normally
    sleep    5s
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    sleep    20s
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist}    parameter=${lnrel_para}
    ...    value=${lnrel_value}
    sleep    60s
    Check the COAM gnb cell status onair

Power reset For All RU
    [Arguments]    ${ru_reset}=no
    Run Keyword If   '${ru_reset}'!='yes'  return from keyword   ${ru_reset}
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
    FOR  ${index}    IN RANGE    ${ru_num}
       ${index}    Evaluate    ${index}+${1}
       ${status}    Run Keyword And Return Status     Perform RU Power Off    ru_index=${index}
       run keyword if  not ${status}    Log    Power Off RU_${index}  failed.
       sleep   3s
       ${status}    Run Keyword And Return Status     Perform RU Power On    ru_index=${index}
       run keyword if  not ${status}    Log    Power On RU_${index}  failed.
    END
    [Return]    ${ru_reset}

Perform full commission for COAM classical gnb
    [Arguments]    ${scf}=${tl_scf_dir_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

Check COAM gnb classical start normally
    Check Airscale HW module status
    ${res} =    Feature 1514 Enabled
    run keyword if    ${res}==${False}    wait until keyword succeeds    15min   30s
    ...    Check the COAM gnb RU status ready

Check the COAM gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the COAM gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Get bts counter
    [Arguments]    ${counter_id}    ${full_path}
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values   ${res}
    [return]    ${values}

Login coam webui
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}

Check the bts counter ${counter_id} from ${counter_path} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ...                 full_path=${counter_path}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}
