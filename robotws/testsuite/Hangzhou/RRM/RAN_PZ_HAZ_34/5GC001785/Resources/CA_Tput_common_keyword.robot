*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB007835
Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot



*** Variables ***
${tl_scf_file_name1}    Configuration_scf_GNB1_CB007835.xml
${duration_time}    600
${att_api_port}         ${tl.attenuator[0].port}
${max_attenuation_value}     ${127}
${vendor}               ${tl.attenuator[0].vendor}


*** Keywords ***
#####BTS keywords#####
Setup for Env cell on-air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the gNB cells onair status
    should be equal    '${cell_status}'    'True'

Lock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.lock_cell
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Unlock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.unlock_cell
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

#COAM Get nrcellid with lcrid
#    [Arguments]   ${lcrid}    ${gnb_index}=${0}
#    Connect to gnb coam via ssl
#    ${cellgrp_index_list}    Get All Cell Group Id
#    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
#    FOR    ${index}    IN    @{cellgrp_index_list}
#       ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
#       ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
#       exit for loop if    '${nrCellId}'!='None'
#    END
#    [Return]    ${nrCellId}
#    [Teardown]    COAM Teardown gnb connections

#Get nrcellid in all cellgroup with lcrid
#    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
#    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
#    FOR    ${cell}    IN    @{cell_list}
#       ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
#       ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
#       ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
#       ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
#    END
#    [Return]    ${nrCellIdentity}



#####UE keywords#####
Common UE parameter setup
    [Arguments]  ${ue_index}=${0}
#    set suite variable    ${ue_type}    ${tl.ues[${ue_index}].capabilities[1]}
    set suite variable    ${serial_number}    ${tl.ues[${ue_index}].serial_number}

Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}

Start UL DL data transfer
    Power UE Start DL traffic    dl_throughput=1500M    duration=${duration_time}
    Power UE Start UL traffic    ul_throughput=100M    duration=${duration_time}

Step7: UE detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}



#####Attenuation keywords######
adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}    ${att_port_2}     ${att_port_3}    ${att_port_4}     ${atten_ip}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    5s

