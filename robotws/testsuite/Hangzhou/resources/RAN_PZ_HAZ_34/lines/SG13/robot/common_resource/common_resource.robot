*** Settings ***
Library     ../../python/tak_iperf/
Library     ../../python/tak_files/
Library     ../../python/tak_xml/
Library     ../../python/tak_common/
Library     ../../python/tak_mcs/
Library     ../../python/tak_gnb/
Library     ../../python/tak_pa/
Library     ../../python/tak_cpe/
Library     ../../python/tak_airphone/
Resource    common_setup_teardown.robot
Resource    common_airphone.robot
Resource    common_gnb.robot
Resource    common_host_server.robot
Resource    common_logs_operate.robot
Resource    common_logs_analysis.robot
Resource    common_common.robot
Resource    common_qualcomm.robot
Resource    common_prisma.robot
Resource    common_upgrade.robot
Resource    common_aic_setup_teardown.robot
Resource    common_aic_gnb.robot
Resource    common_aic_airphone.robot
Resource    common_aic_logs_operate.robot

