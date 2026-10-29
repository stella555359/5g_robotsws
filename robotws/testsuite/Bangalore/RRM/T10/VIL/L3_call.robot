*** Settings ***
Force Tags        CLOUD_5G_I_MP_AP_LOOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
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
Resource         ../../5GET_BLR/resources/robot/common_log_collection.robot
Resource         ../../5GET_BLR/resources/robot/wts_sim_keywords.robot
Resource         ../../5GET_BLR/CB009215/resources/CB009215_keyword.robot
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout
Library          OperatingSystem

#Suite Setup         Run keywords    Prepare TL with all config files
#...                 AND         Suite setup from scratch
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_min=100
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.sack_timeout=20
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_min=400
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_initial=400
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.sctp.rto_max=800
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.wmem_max=40971520
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.wmem_default=40971520
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.rmem_max=40971520
#...                 AND     OperatingSystem.Run   command=sudo sysctl -w net.core.rmem_default=40971520
Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Update bsr package
...                 AND     Configure eth3 IP
...                 AND     Start wts application and load CFG		${wts_cfg_file}

#Suite Teardown     Run Keyword and ignore error    Get Sos Report
*** Variables ***
${AP_XML}=      ${CURDIR}/config/iphy.xml
${SCFC}=        ${CURDIR}/config/scfc.xml
${wts_cfg_file}         /opt/iphy/latest/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${start_cell}    1
${end_cell}      3
${enb_id}        2
${eNB_ID_x2}		 1
${eNB_target}    2
${NSA_UE_ID}     11
${Target_Cells}    1
${Traffic_rate}   Mbps
${dl_rate}       100
${ul_rate}       20
${Bearer_ID}     2

*** Test Cases ***
[1]L3_call
    Set test variable      ${LOG_PATH}
    NSA X2AP Link Should be UP      ${eNB_ID_x2}		${eNB_target}
    sleep  5s
    Wait Until Keyword Succeeds     180s    5s	Verify_sib_mib_for_Cell		${start_cell}	${end_cell}		${enb_id}
    wts_sim_keywords.MultiUE Register should be Successful    1   3
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA   start_ue_id=1    end_ue_id=3    Traffic_rate=mbps   dl_rate=10
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA   start_ue_id=1    end_ue_id=3    Traffic_rate=mbps   ul_rate=10
    sleep  10s
    FOR    ${iter}    IN RANGE    1    3
        wts_sim_keywords.Validate DL Traffic For SA   1      dl_rate=10     pdu_id=1      qfi_id=1
        wts_sim_keywords.Validate UL Traffic For SA   1      ul_rate=10     pdu_id=1      qfi_id=1
        sleep   60s
    END
    wts_sim_keywords.UE Deregister should be Successful   ue_id=1
    FOR    ${ue_num}    IN RANGE    11    13
        NSA LTE Attach should be Successful    ${ue_num}
        NSA UE Attach should be Successful     ${ue_num}    ${Target_Cells}
        ${Target_Cells} =  Evaluate  ${Target_Cells} + 1
        sleep  5s
    END
    FOR    ${ue_num}    IN RANGE    11    13
        wts_sim_keywords.Trigger DL Traffic for NSA    ${ue_num}        ${Traffic_rate}     ${dl_rate}       ${Bearer_ID}    ${TRF_ID}
        wts_sim_keywords.Trigger UL Traffic for NSA    ${ue_num}        ${Traffic_rate}     ${ul_rate}       ${Bearer_ID}    ${TRF_ID}
        sleep   6s
    END
    FOR    ${ue_num}    IN RANGE    11    13
    wts_sim_keywords.NSA UE Detach should be Successful   ${ue_num}
    END
    [Teardown]      Link SCOUT SCF to Configuration ID for Reporting



*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQF_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQF_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    coam.teardown admin
