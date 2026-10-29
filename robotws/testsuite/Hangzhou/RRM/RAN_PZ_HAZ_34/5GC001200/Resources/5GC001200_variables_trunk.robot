*** Settings ***
Documentation    Common variables for 1200 feature

*** Variables ***
${UPUE_NODE_ID}      0x223D

${LAYER0_UL_PORT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${LAYER1_UL_PORT}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${LAYER0_DL_PORT}    ${None}
${LAYER1_DL_PORT}    ${None}
${INITIAL_LAYER0_UL_ATTEN}    10
${INITIAL_LAYER1_UL_ATTEN}    10
${INITIAL_LAYER0_DL_ATTEN}    ${None}
${INITIAL_LAYER1_DL_ATTEN}    ${None}
${INIT_TRY_TRIGGER_LAY0_UL_ATTEN}    20
${INIT_TRY_TRIGGER_LAY1_UL_ATTEN}    20
@{RL_RESUME_REC_VALUE_LIST}   10    0

${E500_HLS_IP}    192.168.10.71
${E500_SCRIPTS_BASE}    ${CURDIR}/../TestData/E500_script_TL250
${E500_SCRIPTS_MULTI_UE}    ${CURDIR}/../TestData/E500_script_TL250_multi_ue
