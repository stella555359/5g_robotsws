*** Settings ***
Documentation    Common variables for 1200 feature

*** Variables ***
${UPUE_NODE_ID}    0x1011

${LAYER0_UL_PORT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${LAYER1_UL_PORT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${LAYER0_DL_PORT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${LAYER1_DL_PORT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${INITIAL_LAYER0_UL_ATTEN}    44
${INITIAL_LAYER1_UL_ATTEN}    44
${INITIAL_LAYER0_DL_ATTEN}    32
${INITIAL_LAYER1_DL_ATTEN}    32
${INIT_TRY_TRIGGER_LAY0_UL_ATTEN}    50
${INIT_TRY_TRIGGER_LAY1_UL_ATTEN}    50
@{RL_RESUME_REC_VALUE_LIST}   40    43

${E500_HLS_IP}    192.168.10.70
${E500_SCRIPTS_BASE}        ${CURDIR}/../TestData/E500_script_60m_aahf
${E500_SCRIPTS_MULTI_UE}    ${CURDIR}/../TestData/E500_script_60m_aahf_mul_ue
