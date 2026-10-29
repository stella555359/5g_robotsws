*** Settings ***
Resource          ./Resources/testline_keywords.robot

Test template       This Case Template

Documentation    Suite description
...   author: Wang Yixiang
...   contact: yixiang.x.wang@nokia-sbell.com
...   squad group: MMW_SG1
...   check testline status, if not onair, commission and wait onair
...   todo:

Force Tags    5G_RRM
...   PY27
Suite Setup     Testline check suite setup
Suite Teardown    log    Suite Teardown

*** Variables ***
${scfpath}    /home/ute/Projects/mmw1_config

*** Test Cases ***     ${nr_default_scf_file}                                ${enb_default_scf_file}
#7_5_CLOUD402T245       ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL245_8cc.xml    ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL245_ENB.xml
#7_5_UTE402T256         ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL256_8cc.xml    ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL256_ENB.xml
#7_5_UTE402T401         ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL401_4cc.xml    ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL401_ENB.xml
#7_5_UTE402T246         ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL246.xml        ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL246_ENB.xml
#7_5_UTE5G402T253       ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL253.xml        ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL253_ENB.xml
#7_5_UTE5G402T254       ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL1170.xml       ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL254_ENB.xml
#7_5_UTE5G402T255       ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL255.xml        ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL255_ENB.xml
#7_5_UTE5G402T049       ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL10152.xml      ${scfpath}/${TEST NAME}/scf/SCF_MMW1_TL49_ENB.xml

*** Keywords ***
This Case Template
    [Documentation]    Author: Wang Yixiang
    ...    case description
    [Arguments]    ${nr_default_scf_file}   ${enb_default_scf_file}
    Get testline info    tl_name=${TEST NAME}   exec_path=${EXECDIR}
    ${auto_running}   Check if robot process running
    Pass Execution If    ${auto_running}    ${TEST NAME} auto-robot is running, skip onair check.
    Create connection and directory
    ${onair_flag}    run keyword and return status    Verify all cells should be onair
    Print if cell onair and auto-robot running info    onair_flag=${onair_flag}    auto_running=${auto_running}
    Comission LTE and NR if cell not onair and auto-robot is not running    onair_flag=${onair_flag}    auto_running=${auto_running}
    ...    nr_default_scf_file=${nr_default_scf_file}   enb_default_scf_file=${enb_default_scf_file}
    [Teardown]   run keyword and ignore error    Case teardown for testline    auto_running=${auto_running}

Print if cell onair and auto-robot running info
    [Arguments]    ${onair_flag}   ${auto_running}
    run keyword if    ${onair_flag}==${False}     log to console    ${TEST NAME} cell not onair    ELSE
    ...    log to console    ${TEST NAME} cell is onair
    run keyword if    ${auto_running}==${False}    log to console    ${TEST NAME} auto-robot is not running   ELSE
    ...    log to console    ${TEST NAME} auto-robot is running

Comission LTE and NR if cell not onair and auto-robot is not running
    [Arguments]    ${onair_flag}   ${auto_running}
    ...    ${nr_default_scf_file}   ${enb_default_scf_file}
    run keyword if    ${onair_flag}==${False} and ${auto_running}==${False}
    ...    Run keywords    log to console    Cell not onair and auto-robot is not running, will commission with default scf   AND
    ...    Commission of LTE and NR
    ...    nr_default_scf_file=${nr_default_scf_file}
    ...    enb_default_scf_file=${enb_default_scf_file}
