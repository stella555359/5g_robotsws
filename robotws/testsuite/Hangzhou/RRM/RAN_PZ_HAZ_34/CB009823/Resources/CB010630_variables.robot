*** Settings ***
Documentation    This is about common variables used for CB010630 feature.

*** Variables ***
${testline_name}    7_5_UTE5G402T420
${NSA_SA}          SA
${MRBTS_ID_GNB0}        ${tl.gnbs[0].instance_id}
${connection_GNB_victim}    ${OAM_ALIAS_GNB0}
${connection_GNB_aggressor}    ${OAM_ALIAS_GNB1}
${gnb_index_victim}    0
${gnb_index_aggressor}    1
