*** Settings ***
Documentation    This is about common variables used for 8985 feature.

Variables   commissionings/HGZ/${testline_name}/__init__.py

*** Variables ***
${testline_name}    7_5_UTE5G402T2120    # dummy variable, just for pipeline
${DURATION_OF_TRAFFIC}        1600
# common check threshold
${DURATION_OF_TPUT_CHECK}     60s
${PERCENT_TARGET_AVG}         0.85
${PERCENT_TARGET_MIN}         0.5

${MRBTS_ID}                                         ${tl.gnbs[0].instance_id}
${NRBTS_ID}                                         ${tl.gnbs[0].global_bts_id}
${DN_MRBTS}                                         MRBTS-${MRBTS_ID}
${DN_NRBTS}                                         ${DN_MRBTS}/NRBTS-${NRBTS_ID}
