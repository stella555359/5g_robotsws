*** Settings ***
Documentation           author: Sky Mei
...                     contact: sky.mei@nokia-sbell.com
...                     squad group: SG_01
...                     feature : 5GC00XXXX

#Library                 taf.collectors.core   WITH NAME   core
#Library                 taf.collectors.btslog  WITH NAME   btslog
#Library                 taf.hw.rf_attenuator    WITH NAME    PA_
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource                ../../5GC000496_C/Resources/L3Call.robot
#Variables               ${CFGFILE_PATH}/5GC000496/Delta.py

*** Variables ***
#TL info
${UPDATE_FILE_PATH}     /opt/ute/tmp/
#${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${DELTA_PATH}           ${CFGFILE_PATH}/5GC002197/Delta.py
#${TestLineSCF1CELL}    ${CFGFILE_PATH}/TestLineSCF1Cell_Both.xml
${MRBTS_ID}             ${tl.gnbs[0].instance_id}
${NRBTS_ID}             ${tl.gnbs[0].global_bts_id}

${ASIK_LMP_IP}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

#TL207_gNB1
${WEBUI_IP}             ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}            https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

#TL20702_gNB2
${WEBUI_IP1}            ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME1}      ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD1}      ${tl.gnbs[1].cu.oam_http_connection_details.password}
${WEBUI_URL1}           https://${tl.gnbs[1].cu.oam_http_connection_details.addr}

#TL207_eNB
${ENB_WEBUI_IP}         ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}         https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${RU_TYPE}              ${tl.gnbs[0].dus[0].rus[0].radio_type}
${AEQA_IP}              ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}    # 192.168.254.34
${UTE_IP}               ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}         ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}         ${tl.core.default_ssh_connection_details.password}

#${PB_PORT}              4001
${PB_ASIK_IP}           ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}         ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}           ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${5GC_IP}               ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}         ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}         ${tl.core.default_ssh_connection_details.password}

## Attenuator parameter ##
${PA_INFO}              ${tl.attenuator}

####GNB1####
${5GRU1_ANT1}           ${1}
${5GRU1_ANT2}           ${2}
${5GRU2_ANT1}           ${3}
${5GRU2_ANT2}           ${4}
${5GRU3_ANT1}           ${5}
${5GRU3_ANT2}           ${6}
####GNB2####
${5GGNB2_RU1_ANT1}      ${7}
${5GGNB2_RU1_ANT2}      ${8}

##################define these variable for convenient#########################
${ALIAS_ASIK}            asik                                                ##
${ALIAS_ASIK_SLAVE}      asik_slave                                          ##
${ALIAS_ABIL}            abil                                                ##
${ALIAS_ABIL_SLAVE}      abil_slave                                          ##
${ALIAS_LONER}           loner                                               ##
${ALIAS_UTE}             ute                                                 ##
${ALIAS_ENBCTLPC}        ENB_PC                                              ##
${ALIAS_SHP}             SHP                                                 ##
${ALIAS_E500}            E500                                                ##
${ALIAS_PRISMA}          Prisma                                              ##
${ALIAS_AMF}             AMF                                                 ##
########################END of alias Define####################################
${IMSI1}                 ${tl.ues[0].imsi}
${IMSI2}                 ${tl.ues[1].imsi}
${UE_TYPE}               huawei_sigspark
${OAM_TYPE}              COAM

*** Keywords ***
