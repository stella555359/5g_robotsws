*** Settings ***
Documentation    Define variables used in feature


*** Variables ***
${NSA_SA}                SA
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${testline_name}    7_5_UTE5G402T053
${IS_LOG_REQUIRED}    ${True}

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

# This is used for testing on current CA TLs like: 254/49/255
#${SCF_TEMPLATE_6137_TEST}    /home/ute/Projects/mmw1_config/${testline_name}/scf/backup/SCF_6137A_4CC_CA.xml

${SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml

# RIM-RS is opened on RMOD-9 AEHC, so need to ignore the alarm 7525,7527,7532, 7535
${ALLOWED_FAULTS_IDS}    7525,7527,7532,7535,1999
