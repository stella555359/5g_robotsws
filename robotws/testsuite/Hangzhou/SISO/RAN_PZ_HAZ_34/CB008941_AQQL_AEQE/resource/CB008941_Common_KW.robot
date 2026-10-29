*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    ../../CB008238_A/resource/CB008238_Common_KW.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library    ../lib/CB008941.py
Library     taf.rfrl.bts.commissioning


*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
@{cell_id_list}    ${1}
@{group1}    ${0}    ${1}    ${2}    ${3}
@{group2}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}

*** Keywords ***
L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_new.txt
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    log to console    check endpointCapacitySharingGroup have 0-11
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    #Should Be Equal    ${group_list}    ${group2}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${1}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    #Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${3}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${8}
    #Should Be Equal    ${status}    ${True}
    log to console    L3 call
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100    4G_check=True
    [Teardown]  run keywords  run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}    AND
    ...    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_old.txt

Modify Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Upload Swconfig File    swconfig_path=${swconfig_path}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait until keyword succeeds    5 min    10 sec   Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Upload Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    ${swconfig_file_name}    Fetch from right    ${swconfig_path}    /
    log to console    upload swconfig file
    csn.Upload File    local_path=${swconfig_path}    remote_path=/ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    rename uploaded new swconfig file
    csn.execute    mv /ffs/run/${swconfig_file_name} /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    crasign...
    csn.execute    crasign /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    craverify...
    csn.execute    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7    connection=${asik_alias}
    sleep    1s
    log to console    reboot testline...
    Perform BTS Site Reset
    sleep    120s

