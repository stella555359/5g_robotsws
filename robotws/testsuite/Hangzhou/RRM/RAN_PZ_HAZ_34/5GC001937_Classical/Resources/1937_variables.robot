*** Settings ***
Documentation    Common variables for 1937 feature

*** Variables ***
${PROGRAM}                                    ${None}
${BTS_ID}                                     ${tl.gnbs[0].instance_id}
${TIMEOUT_CLUSTER}    10 min
${TIMEOUT_REST_API_RESTART}    600
${GOLDEN_FULL_SCF_8CC_4UL}   /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}.xml

#traffic variables
${UL_PORT}        ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}      1400B
${TRAFFIC_TIME}   3600
${DL_PORT}        ${tl.ues[0].iperf_details.port}
${DL_LENGTH}      1400B

@{PCELL_INDEX}    1    2
${ENB_IP}         ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

# default arg
${testline_name}      null
${CONFIGURATION}      null
${TEST STATUS}        FAIL

# x cc configuration tput variables: dl 475M per cell at least, ul 100M per cell at least
${DURATION}                         900

# ul
${ACT_UL_TPUT_256_UDP}                       500M
${UL_EXPECT_TPUT_256_UDP}                    200
${ACT_UL_TPUT}                       250M
${UL_EXPECT_TPUT}                    200
# 2cc dl
${2CC_ACT_DL_TPUT}                  1200M
${2CC_2DL_2UL_DL_EXPECT}            980
# 3cc dl
${3CC_ACT_DL_TPUT}                  1600M
${3CC_3DL_2UL_DL_EXPECT}            1460
# 4cc dl
${4CC_ACT_DL_TPUT}                  2000M
${4CC_4DL_2UL_DL_EXPECT}            2000
# 8cc dl
${8CC_ACT_DL_TPUT}                  4400M
${8CC_ACT_DL_2_THREAD_TPUT}         2300M
${8CC_8DL_2UL_DL_EXPECT}            3850
# 6cc dl
${6CC_ACT_DL_TPUT}                  3300M
${6CC_6DL_2UL_DL_EXPECT}            2850
# 7cc dl
${7CC_ACT_DL_TPUT}                  3850M
${7CC_7DL_2UL_DL_EXPECT}            2993
# deviation percentage
${TCP_UL_DEVIATION}                 1.0
${TCP_DL_DEVIATION}                 1.0
${UDP_UL_DEVIATION}                 1.0
${UDP_DL_DEVIATION}                 1.0
# tput cases retry time
${RETRY_TIME_UDP}                       1
${RETRY_TIME_TCP}                       1

