*** Settings ***
Documentation    Common variables for 1596 feature on tl054

*** Variables ***
${RU_TYPE}                       ${tl.gnbs[0].dus[0].rus[0].radio_type}
${SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
${ENB_SCF_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
${SWCONFIG_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
${LMP_INTERNAL_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${TEST_REPEAT_TIMES}             1
${RECOVERY_TIMEOUT}              10 min
#@{CELL_LIST_GNB_ATTACH}          1    2                       #GNB cell list which can do attach
@{GNB_PS_CELL_INDEX_LIST}        1    2
${PRACHCONFIGRATIONINDEX_DEFAULT}    38
${TIMEOUT_MODIFY_PARA}               6 min                    #timeout for COAM update several parameters via rest api
${VERIFY_DURATION}                  ${60}                     #duration_time_for_once in Verify tput from GNB within duration and record data to csv

${ENB_INDEX}                     0        #ENB configuration cofigured in testline_configuration __init__.py,
                                          #if there are more than one enb configured, and only one enb status need to check by your testcases
                                          #this parameter is needed

# alias
${ASIK_ALIAS}                    ASIK Master
${ENB_ALIAS}                     enblte
${GNB_COAM_ALIAS}                GNB_OAM
${ABIL_MASTER_ALIAS}             ABIL Master
@{RUS_ALIAS}                     RU_1    RU_2
# UL/DL throughput
${UL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}        1400
${DL_PORT}          ${tl.ues[0].iperf_details.port}
${DL_LENGTH}        1400
${UL_THROUGHPUT}    50M
${DL_THROUGHPUT}    100M
${UL_EXPECT}        1
${DL_EXPECT}        1
@{RU_1}        1
