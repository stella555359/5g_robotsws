*** Settings ***
Documentation    Test variables and keyword resource file for turandot
Library    OperatingSystem

Library    python/perf_log_collection.py

*** Keywords ***
Queue Robot Logs To turandot
    perf_log_collection.Queue Logs To Turandot    ${WORKSPACE}/robot_results/robot_print.txt    compress=false
    ...                                                                                         subfolder=${RL_PATH.jenkins_debug}
    perf_log_collection.Queue Logs To Turandot    ${WORKSPACE}/robot_results/debug.log    compress=true    subfolder=${RL_PATH.jenkins_debug}
    perf_log_collection.Queue Logs To Turandot    ${WORKSPACE}/robot_results/output.xml    compress=true    subfolder=${RL_PATH.jenkins_debug}
    perf_log_collection.Queue Logs To Turandot    ${WORKSPACE}/properties.txt    compress=false    subfolder=${RL_PATH.jenkins_debug}
