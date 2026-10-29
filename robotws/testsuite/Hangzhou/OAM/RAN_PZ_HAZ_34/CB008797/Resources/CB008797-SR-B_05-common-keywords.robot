*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.config.scf    WITH NAME    cscf
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

*** Variables ***
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_file_path}            ${output_dir}

*** Keywords ***
Get Version
    [Arguments]     ${conn}=cOAM_admin
    Log To Console    Get Version
    Connect to gnb coam via ssl    connection=${conn}    bts_host=${DU_IP}
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=   coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

get cells info
    [Arguments]    ${conn}=cOAM_admin    ${cell_type}=nr
    Connect to gnb coam via ssl    connection=${conn}    bts_host=${DU_IP}
    ${cell_info}    coam.Get Cells Info    cell_type=${cell_type}    connection=${conn}
    Disconnect from DU
    [Return]    ${cell_info}

Adjust Enb
    [Arguments]    ${index}=9  ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-1
    ...    ${parameter}=defaultLnRelGnbCellId
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}

UE attach by Spark
    Log To Console    Prepare UE
    power_ue.Prepare UE    ue_type=askey_sigspark
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=askey_sigspark
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=askey_sigspark    5Grach_ed=${5Grach_ed_0}
    power_ue.UE Detach    ue_type=askey_sigspark











