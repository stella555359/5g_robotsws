*** Settings ***
Documentation
...    Author: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Maintainer: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_OPERABILITY_PM_GMS
...    References: doors
...    Feature Description: CB012803

Library        String
Library        Telnet
Library        BuiltIn
Library        OperatingSystem
Library        Process

Library      ta5g_testline_management
#Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta_pcmd
Library      taf.transport.ssh   WITH NAME   csn
Library      simulator_keywords.py




Resource    ../../../ET/BOAM_VERIF_ET2/resources/pretest_posttest.robot
Resource    ../../../ET/BOAM_VERIF_ET2/resources/system.robot
Resource    ../../../ET/BOAM_VERIF_ET2/resources/AirPhone/resources/ute/ute_wts_runner.robot
#Resource    ../../../../L3/ET/L3_ET_TIM3/resources/5G_SW_WRO_Keywords.robot
Resource    ../../../ET/BOAM_VERIF_ET2/resources/admin_infomodel.robot



*** Variables ***
${swconfig_path}=       /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/resources/swconfig.txt
${remote_path}=         /ffs/run/swconfig.txt
${gnb_ip}=              192.168.255.129
${gnb_username}=        toor4nsn
${gnb_pass}=            oZPS0POrRieRtu
${env_path}=            /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/resources/environment.json
${meas_path}=           /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/resources/measurements.json
${pmstat_path}=         /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/resources/PMStatvcu.json
${env_remote_path}=     /ffs/run/environment.json
${meas_remote_path}=    /ffs/run/measurements.json
${pmstat_remote_path}=    /tmp/PMStatvcu.json


*** Keywords ***
Add PM flags to swconfig
    #add PM flags to swconfig.txt
    log to console    ** Add PM flags to swconfig.txt **
    csn.Connect To    hostname=${gnb_ip}    username=${gnb_username}    password=${gnb_pass}
    csn.upload_file    local_path=${swconfig_path}    remote_path=${remote_path}
    csn.execute    command=cd /ffs/run/ && crasign swconfig.txt && reboot
    Sleep   120
    log to console    ** Finished adding the flags **
    log to console    ** Waiting for BTS to be Configured **
    Wait Until Keyword Succeeds   600    10    ADMIN INFOMODEL Check If BTS Is Configured

Reach_OnAir_AEQE_GMC
    #enter egate
    log to console    ** Copy the wts.cfg file to /home/ute **
    ${source_cfg}=         Set Variable    ${CURDIR}/wts.cfg
    ${destination_cfg}=     Set Variable   /home/ute/wts.cfg
    Run Keyword And Continue On Failure    OperatingSystem.File Should Exist    ${source_cfg}
    Copy File         ${source_cfg}     ${destination_cfg}
    BuiltIn.Sleep     120
    log to console    ** Run EGATE commands to reach OnAir **
    Make Simulator Executable
    Run Hardcoded IP Commands Then Start EGATE
    Wait Until Keyword Succeeds   600    10    ADMIN INFOMODEL Check If BTS Is OnAir
#Reach OnAir AEQE

Start counter simulator
    log to console    **Start counter simulator**
    csn.Connect To    hostname=${gnb_ip}    username=${gnb_username}    password=${gnb_pass}
    csn.upload_file    local_path=${meas_path}    remote_path=${meas_remote_path}
    csn.upload_file    local_path=${env_path}    remote_path=${env_remote_path}
    csn.upload_file    local_path=${pmstat_path}    remote_path=${pmstat_remote_path}
    Start PMStat Detached Over SSH NonBlocking    host=192.168.255.129    username=toor4nsn
