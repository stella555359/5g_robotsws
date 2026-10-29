*** Settings ***
Documentation    This is for two gnb connections in case of gnbs inter handover
...              Please do not modify the file without notification to author
...              Author: Chen Jun
...              Squard: HZ SG6
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot


*** Keywords ***
Connect To Source Coam
    [Arguments]    ${connection}=GNB_OAM0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=0

Connect To Target Coam
    [Arguments]    ${connection}=GNB_OAM1
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=1

Connect To Source Common Unit Master
    [Arguments]    ${connection}=ASIK Master0
    Connect to Common Unit Master    alias=${connection}    gnb_index=${0}

Connect To Target Common Unit Master
    [Arguments]    ${connection}=ASIK Master1
    Connect to Common Unit Master    alias=${connection}    gnb_index=${1}

Connect To Source Common Unit Slave
    [Arguments]    ${connection}=ASIK Slave0    ${proxy}=ASIK Master0
    Connect to Common Unit Slave    alias=${connection}    asik_alias=${proxy}    gnb_index=${0}

Connect To Target Common Unit Slave
    [Arguments]    ${connection}=ASIK Slave1    ${proxy}=ASIK Master1
    Connect to Common Unit Slave    alias=${connection}    asik_alias=${proxy}    gnb_index=${1}

Connect To Source Capacity Unit Master
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master0    ${asik_alias}=ASIK Master0
    Connect To Capacity Unit Master    du_index=${du_index}    hw_slot=${hw_slot}    alias=${alias}    asik_alias=${asik_alias}

Connect To Target Capacity Unit Master
    [Arguments]    ${alias}=ABIL Master1    ${hw_slot}=${1}    ${asik_alias}=ASIK Master1
    Connect To Capacity Unit Master    alias=${alias}    hw_slot=${hw_slot}    asik_alias=${asik_alias}    gnb_index=${1}

Connect To Source Capacity Unit Slave
    [Arguments]    ${alias}=ABIL Slave0    ${hw_slot}=${1}    ${asik_alias}=ASIK Master0
    Connect to Capacity Unit Slave    alias=${alias}    hw_slot=${hw_slot}    asik_alias=${asik_alias}

Connect To Target Capacity Unit Slave
    [Arguments]    ${alias}=ABIL Slave1    ${hw_slot}=${1}    ${asik_alias}=ASIK Master1
    Connect to Capacity Unit Slave    alias=${alias}    hw_slot=${hw_slot}    asik_alias=${asik_alias}    gnb_index=${1}

Connect To Source Capacity Unit Loner
    [Arguments]     ${hw_slot}=${1}    ${alias}=ABIL Loner0    ${asik_alias}=ASIK Master0
    Connect To Capacity Unit Loner    hw_slot=${hw_slot}    alias=${alias}    asik_alias=${asik_alias}

Connect To Target Capacity Unit Loner
    [Arguments]    ${hw_slot}=${1}    ${alias}=ABIL Loner1    ${asik_alias}=ASIK Master1
    Connect to Capacity Unit Loner    hw_slot=${hw_slot}    alias=${alias}    asik_alias=${asik_alias}    gnb_index=${1}

Source COAM Login Page Via WebUI
    coam_selenium.COAM Navigate to login page via webUI    gnb_index=${0}

Target COAM Login Page Via WebUI
    coam_selenium.COAM Navigate to login page via webUI    gnb_index=${1}

Connections For Source And Target Alias
    Connect To Source Coam
    Connect To Target Coam
    Connect To Source Common Unit Master
    Connect To Target Common Unit Master
    Connect To Source Common Unit Slave
    Connect To Target Common Unit Slave
    Connect To Source Capacity Unit Master
    Connect To Target Capacity Unit Master
    Connect To Source Capacity Unit Slave
    Connect To Target Capacity Unit Slave
    Connect To Source Capacity Unit Loner
    Connect To Target Capacity Unit Loner

Disconnect For Source And Target Alias
    Run Keyword And Ignore Error    ssh.disconnect    connection=ABIL Loner0
    Run Keyword And Ignore Error    ssh.disconnect    connection=ABIL Loner1
    Run Keyword And Ignore Error    ssh.disconnect    connection=ABIL Slave0
    Run Keyword And Ignore Error    ssh.disconnect    connection=ABIL Slave1
    Run Keyword And Ignore Error    ssh.disconnect    connection=ABIL Master0
    Run Keyword And Ignore Error    ssh.disconnect    connection=ABIL Master1
    Run Keyword And Ignore Error    ssh.disconnect    connection=ASIK Slave0
    Run Keyword And Ignore Error    ssh.disconnect    connection=ASIK Slave1
    Run Keyword And Ignore Error    ssh.disconnect    connection=ASIK Master0
    Run Keyword And Ignore Error    ssh.disconnect    connection=ASIK Master1
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM1

