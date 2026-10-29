*** Settings ***
Documentation    use gnb_logs to capture logs, include tti ,bip.
...              Author: Lin Stella
...              Squard: HZ SG6

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot

*** Keywords ***
Clone Gnblogs Tool
    [Arguments]    ${gnb_logs_dir}=/home/ute    ${gnb_log_version}=HEAD
    ${status}    Run Keyword And Return Status    File Should Exist    ${gnb_logs_dir}/gnb_logs/gnb_logs.exe
    run keyword if    ${status}    Run Process    mv ${gnb_logs_dir}/gnb_logs ${gnb_logs_dir}/gnb_logs_bak   shell=True
    Run Process    mkdir ${gnb_logs_dir}/gnb_logs_tool    shell=True
    Log To Console    start clone gnb_logs tool
    Run Process    git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool.git ${gnb_logs_dir}/gnb_logs_tool
    ...    shell=True
    ...    stdout=${gnb_logs_dir}/gnblogs_install_result.txt
    run keyword if    '${gnb_log_version}'!='HEAD'    Run Process    cd ${gnb_logs_dir}/gnb_logs_tool/;git checkout ${gnb_log_version}
    ...    shell=True
    Run Process    unzip ${gnb_logs_dir}/gnb_logs_tool/gnb_logs.zip -d ${gnb_logs_dir}
    ...    shell=True
    Run Process    chmod 774 ${gnb_logs_dir}/gnb_logs/gnb_logs
    ...    shell=True
    Run    sudo sed -i 's/Tti_raw_logs_only.*=.*yes/Tti_raw_logs_only = no/' ${gnb_logs_dir}/gnb_logs/config.ini
    Log To Console    gnb_logs tool install finish
    [Teardown]    run keyword and ignore error    Recover Gnblogs Tool on VM

Recover Gnblogs Tool on VM
    [Arguments]    ${gnb_logs_dir}=/home/ute
    ${status}    Run Keyword And Return Status    File Should Exist    ${gnb_logs_dir}/gnb_logs/gnb_logs.exe
    run keyword if    ${status}    Run Process    sudo rm -rf ${gnb_logs_dir}/gnb_logs_bak   shell=True
    ...               ELSE
    ...               Run Process    sudo mv ${gnb_logs_dir}/gnb_logs_bak ${gnb_logs_dir}/gnb_logs
    Run Process    sudo rm -rf ${gnb_logs_dir}/gnb_logs_tool   shell=True