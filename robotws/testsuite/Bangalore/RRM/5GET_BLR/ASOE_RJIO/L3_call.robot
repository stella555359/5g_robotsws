*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  AUTHOR          :
...  MAINTAINER      :
...  INTRODUCTION    :
...  TEST SET NAME   :
...  TESTING SPLIT   :
...  CONTACTS        :
...  REFERENCES      :
...  REQUIREMENT ID  :

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../CB009215/resources/CB009215_keyword.robot
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout
Library          ute_wtssim
Library          OperatingSystem

Suite Setup         Run keywords    Suite setup from scratch
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_min=100
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.sack_timeout=20
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_min=400
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_initial=400
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_max=800
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.wmem_max=40971520
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.wmem_default=40971520
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.rmem_max=40971520
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.rmem_default=40971520
...                 AND     Update bsr package
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    6

Suite Teardown     Run Keyword and ignore error    Get Sos Report
*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1

*** Test Cases ***
[1]L3_call
    Set test variable      ${LOG_PATH}
    wts_sim_keywords.MultiUE Register should be Successful    1   1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA   start_ue_id=1    end_ue_id=1    Traffic_rate=mbps   dl_rate=10
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA   start_ue_id=1    end_ue_id=1    Traffic_rate=mbps   ul_rate=10
    sleep  10s
    FOR    ${iter}    IN RANGE    1    30
        wts_sim_keywords.Validate DL Traffic For SA   1      dl_rate=10     pdu_id=1      qfi_id=1
        wts_sim_keywords.Validate UL Traffic For SA   1      ul_rate=10     pdu_id=1      qfi_id=1
        sleep   60s
    END
    wts_sim_keywords.UE Deregister should be Successful   ue_id=1
    [Teardown]      Link SCOUT SCF to Configuration ID for Reporting



*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin
