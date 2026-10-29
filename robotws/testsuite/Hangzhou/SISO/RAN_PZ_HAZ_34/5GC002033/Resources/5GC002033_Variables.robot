*** Variables ***
@{GNB_PS_CELL_INDEX_LIST}        1    2   3    4
${TEST_REPEAT_TIMES}             1
${VERIFY_DURATION}      ${60}
${EXP_TPUT_PERCENTAGE}     0.95


${RU_TYPE}                          ${tl.gnbs[0].dus[0].rus[0].radio_type}
${SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
${ENB_SCF_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
${SWCONFIG_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
${LMP_INTERNAL_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${TEST_REPEAT_TIMES}             1
${RECOVERY_TIMEOUT}              10 min
@{GNB_PS_CELL_INDEX_LIST}        1    2   3   4
@{CELL_INDEX_DELET}              1    2
${TIMEOUT_MODIFY_PARA}               360 s                   #timeout for COAM update several parameters via rest api
${VERIFY_DURATION}                  ${60}                     #duration_time_for_once in Verify tput from GNB within duration and record data to csv

${ENB_INDEX}                     0        #ENB configuration cofigured in testline_configuration __init__.py,
                                          #if there are more than one enb configured, and only one enb status need to check by your testcases
                                          #this parameter is needed

# alias
${ASIK_ALIAS}                    ASIK Master
${ENB_ALIAS}                     enblte
${GNB_COAM_ALIAS}                GNB_OAM
${ABIL_MASTER_ALIAS}             ABIL Master
@{RU_1}                 1
# UL/DL throughput
${UL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}        1400
${DL_PORT}          ${tl.ues[0].iperf_details.port}
${DL_LENGTH}        1400
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    600M
${UL_EXPECT}        1
${DL_EXPECT}        1
${UL_EXPECT_PEAK}    10
${DL_EXPECT_PEAK}    200
