*** Settings ***
Documentation    Common variables for 1113 feature

*** Variables ***
${CONFIGURATION}      null

${gNb_CuType}       NSA
${SCF_DEFAULT_FILE_PATH}        /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_step2.xml
${SWCONFIG_DEFAULT_FILE_PATH}   /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
${ENB_SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
${LMP_INTERNAL_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

# alias
${ASIK_ALIAS}                    ASIK Master
${ENB_ALIAS}                     enblte
${GNB_COAM_ALIAS}                GNB_OAM
${ABIL_MASTER_ALIAS}             ABIL Master
@{RUS_ALIAS}                     RU_1

${if_pdl_check}                 ${False}                  #this is for online modify nidd parameters

${TEST_REPEAT_TIMES}             1
${RECOVERY_TIMEOUT}              10 min
@{GNB_PS_CELL_INDEX_LIST}        1                        #GNB cell list which can do attach
${TIMEOUT_MODIFY_PARA}               6 min                    #timeout for COAM update several parameters via rest api
${VERIFY_DURATION}                  ${60}
${VERIFY_DURATION_peak}             ${300}
${ENB_INDEX}                     0        #ENB configuration cofigured in testline_configuration __init__.py,
                                          #if there are more than one enb configured, and only one enb status need to check by your testcases
                                          #this parameter is needed

# UL/DL throughput
${UL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}        1400
${DL_PORT}          ${tl.ues[0].iperf_details.port}
${DL_LENGTH}        1400
${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    1500M
${UL_EXPECT_BEAMSET_6}        58
${DL_EXPECT_BEAMSET_6}        1251
${UL_EXPECT_BEAMSET_2}        54
${DL_EXPECT_BEAMSET_2}        1355
${EXP_TPUT_PERCENTAGE}    0.95
