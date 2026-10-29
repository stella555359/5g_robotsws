*** Settings ***
Documentation
...    Author: Izabela Muntean (izabela.muntean@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: RAN_BOAM_VERIF_SG04
...    References: doors
...    Feature Description:CNI-83747


Library        SSHLibrary
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn



Resource    ../../resources/admin.robot
Resource   ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${SYSTEM_ENB_TRANSPORT_IP}=    192.168.255.129
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${BTS_metadata}=                BTS1_*_metadata.txt

*** Keywords ***

3_Trigger_6929_SSD_Wearout
    Check not uncommissioned state for BTS
    ADMIN Reset Site
    Sleep  60s
    BuiltIn.Wait Until Keyword Succeeds  600  30  Check not uncommissioned state for BTS
    SYSTEM Open SSH Connection To Enb
#     ${content}=  SYSTEM Execute Command On gNB
#    ...    command=ddal -s ddal_ssd_get_health
#    ${status}   Run Keyword And Return Status  should contain   ${content}    is_ssd_healthy=1
    SSHLibrary.Write  EST_A=0x09
    SSHLibrary.Write  EST_B=0x09
    SSHLibrary.Write  echo "$EST_A $EST_B" > /tmp/fake_life_time
    SSHLibrary.Write  mount -o bind /tmp/fake_life_time /sys/block/mmcblk0/device/life_time
    SSHLibrary.Write  ddal -s ddal_ssd_get_health
    SSHLibrary.Read Until   is_ssd_healthy=0
    SSHLibrary.Close Connection
    Sleep  60s
    wait until keyword succeeds  600  5  Check if fault is in active raw alarm  6929   EFaultId_SsdWearoutAl

Check if fault is in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should contain  ${RawAlamrsActive}  (${fault_id})
    Should contain  ${RawAlamrsActive}  ${EFaultId}

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Close SSH Connection
    [Arguments]    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Close Connection

SYSTEM Open SSH Connection To Enb
    SYSTEM Open SSH Connection    host=${SYSTEM_ENB_TRANSPORT_IP}
    ...                           port=22
    ...                           username=${SYSTEM_ENB_SSH_USERNAME}
    ...                           password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                           alias=ssh_enb
