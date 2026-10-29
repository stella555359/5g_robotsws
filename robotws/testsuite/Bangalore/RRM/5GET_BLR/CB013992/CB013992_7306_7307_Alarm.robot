*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Test Set Name: CB013992
...             Testing Split: Alarm 7306,7307 & 7311
...             Requirement ID  : 5G_RAN_USR_RRM_27531, 5G_RAN_USR_RRM_27534, 5G_RAN_USR_RRM_27535

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Library		      OperatingSystem
Resource         ./CB013992_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with CB013992_intergNB.json
...                 AND     sleep    10
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    60
...                 AND     OperatingSystem.Run    sudo ip -6 addr add fc00:8a00:a000:117c::a44:7e7b/122 dev eth3
...                 AND     sleep    6
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.101/24 dev eth3
...                 AND     sleep    6
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
...                 AND     sleep    60
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt      sos
...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Variables ***

${wts_cfg_file}    ${CURDIR}/config/wts/config.cfg
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${EXPECTED_IP}    fc00:8a00:a000:117c::a44:7e7b
${EXPECTED_gNBID_PLMN}      Xn-C (MCC,MNC,GnbId): (311,489,4);
${EXPECTED_gNBID_PLMN2}      Xn-C (MCC,MNC,GnbId): (311,489,4)

*** Test Cases ***
[1]CB013992-A_EC3_TC2_SCTP_association_failure_detected_on_Xn-C_interface_fault_7306
    [Documentation]   This test case checks alarms 7306, 7307, and 7311 and verifies the alarm destination IP and supplementary information

    FOR    ${i}    IN RANGE    1    5
    Drop Xn Link    4
    ${alarm_output}    Check If Alarm Appeared    7306
    List Should Contain Value    ${alarm_output}    ${EXPECTED_IP}
    List Should Contain Value    ${alarm_output}    ${EXPECTED_gNBID_PLMN}
    Sleep    15s
    CB013992_resource.Establish Xn Link To gNB${4}
    END

    FOR    ${i}    IN RANGE    1    5
    Perform SCF Delta Commissioning with AdminitrativeState.json
    ${output}=     Run    ssh -q toor4nsn@192.168.255.129 ip6tables -A INPUT -p sctp --dport 38422 -j DROP
    Perform SCF Delta Commissioning with AdminitrativeState_Unlock.json
    sleep   300
    ${alarm_output1}    Check If Alarm Appeared      7307
    list Should Contain value      ${alarm_output1}   ${EXPECTED_IP}
    list should contain value    ${alarm_output1}      ${EXPECTED_gNBID_PLMN}
    sleep   2
    ${output}=     Run    ssh -q toor4nsn@192.168.255.129 ip6tables -D INPUT -p sctp --dport 38422 -j DROP
    sleep   2
    CB013992_resource.Establish Xn Link To gNB${4}
    END

    FOR    ${i}    IN RANGE    1    5
    Perform SCF Delta Commissioning with AdminitrativeState.json
    sleep   2
    ${output}=     Run    ssh -q toor4nsn@192.168.255.129 ip -6 route add fc00:8a00:a000:117c::a44:7e7b via fc00:8a00:a000:117c::a44:7e7c
    sleep   2
    Perform SCF Delta Commissioning with AdminitrativeState_Unlock.json
    sleep   30
    Check If Alarm Appeared      7311
    list Should Contain value      ${alarm_output}   ${EXPECTED_IP}
    list should contain value    ${alarm_output}      ${EXPECTED_gNBID_PLMN2}
    sleep   2
    ${output}=     Run    ssh -q toor4nsn@192.168.255.129 ip -6 route del fc00:8a00:a000:117c::a44:7e7b via fc00:8a00:a000:117c::a44:7e7c
    END
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
