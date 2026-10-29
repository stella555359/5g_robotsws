*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS24R2    CONFIGURED

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Update bsr package
...                 AND     Perform SCF Delta Commissioning with delta_fallback_activation_TMO.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs
...                 AND     Load CFG and verify cell status    ${wts_cfg_file}	${start_cell}	${end_cell}
#...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs
...                 AND     Stop Log   snapshot     #sosreport
...                 AND     Clean edaemon and egate

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

Documentation
...             author:                 neravati.dheeraj_nehru@nokia.com
...             maintainer:             neravati.dheeraj_nehru@nokia.com
...
...             INTRODUCTION:      RJIO BEP 03815247_AB3
...             TEST SET NAME:     03815247_AB31_AB32.robot
...             TESTING SPLIT:     See RJIO BEP 03815247 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        RJIO BEP 03815247 CFAM


Resource         ./BEPRJIO_resource_v1.robot



*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_AB51_TMO.cfg
&{WTS}             Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${start_cell}       1
${end_cell}         6
${start_ue_id}      1
${end_ue_id}        4
${TEST_NAME}        test_case_AB31_AB32


*** Test Cases ***
[1]03815247_AB51_Successful_VoNR_call_when_UE_not_signalling_VoNR_capabilities_NRBTS.actAssumeVoNRCapability_isEnabled


    set test variable      ${LOG_PATH}

#    NSA X2AP Link Should be UP  1   2
    ${crnti1}    ${gw1}   Generalised MultiUE Register should be Successful VoNR Suported   1   1    pdu_id=1     nw_id=1
    ...    vonr_supp=1  isEpsFb=False

    ${crnti2}    ${gw2}   Generalised MultiUE Register should be Successful VoNR Suported   2   2    pdu_id=1     nw_id=1
    ...    vonr_supp=2  isEpsFb=False    start_gw=${gw1}

    ${crnti3}    ${gw3}   Generalised MultiUE Register should be Successful VoNR Suported   3   3    pdu_id=1     nw_id=1
    ...    vonr_supp=3    isEpsFb=False     start_gw=${gw2}

    ${crnti4}    ${gw4}   Generalised MultiUE Register should be Successful VoNR Suported   71   71    pdu_id=1     nw_id=1
    ...    vonr_supp=1  isEpsFb=False     start_gw=71

    ${crnti5}    ${gw5}   Generalised MultiUE Register should be Successful VoNR Suported   72   72    pdu_id=1     nw_id=1
    ...    vonr_supp=2  isEpsFb=False    start_gw=${gw4}

    ${crnti6}    ${gw6}   Generalised MultiUE Register should be Successful VoNR Suported   73   73    pdu_id=1     nw_id=1
    ...    vonr_supp=3    isEpsFb=False     start_gw=${gw5}


    OperatingSystem.Run    mkdir ${LOG_PATH}/egate_log
    OperatingSystem.Run    cp ${WTS_DIR}/*.log.* ${LOG_PATH}/egate_log


*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    admin.setup admin    bts_host=192.168.255.129
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    admin.teardown admin

