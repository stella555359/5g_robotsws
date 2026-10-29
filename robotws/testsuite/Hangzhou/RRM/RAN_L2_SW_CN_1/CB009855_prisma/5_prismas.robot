*** Settings ***
Documentation    ...
#Documentation    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CB009855_prisma
#...    pybot -L trace -d ./testlogs/ 5_prismas.robot
#...    update gnb cmd:
#...    /home/ute/test_repo/bin/robot -L trace -v gnb_v:SBTS00_ENB -d /home/ute/logs/
#...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/update_gnb.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#*** Variables ***
#${log_path}    ${OUTPUT_DIR}
#${update_gnb}    robot -L trace -v gnb_v:SBTS00_ENB -d ${log_path}/log_update_gnb ${CURDIR}/../CUDU_L2/tools/update_gnb.robot
#${case1}    robot -V ${CURDIR}/init_98/ -L trace -d ${log_path}/log_98 ${CURDIR}/prisma_TA_98.robot
#${case2}    robot -V ${CURDIR}/init_99/ -L trace -d ${log_path}/log_99 ${CURDIR}/prisma_TA_99.robot
#${case3}    robot -V ${CURDIR}/init_100/ -L trace -d ${log_path}/log_100 ${CURDIR}/prisma_TA_100.robot
#${case4}    robot -V ${CURDIR}/init_101/ -L trace -d ${log_path}/log_101 ${CURDIR}/prisma_TA_101.robot
#${case5}    robot -V ${CURDIR}/init_102/ -L trace -d ${log_path}/log_102 ${CURDIR}/prisma_TA_102.robot
#*** Test Cases ***
#Test Case For 5 Prismas
#    Run    ${update_gnb}
#    Run    ${case1}
#    Run    ${case2}
#    Run    ${case3}
#    Run    ${case4}
#    Run    ${case5}
#*** Keywords ***
