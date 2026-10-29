*** Settings ***
Force Tags      CLOUD_5G_I_[LO][LO]_AP_[LOO]  CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Vishwas H N
...              :contact: vishwas.h_n@nokia.com
...
...             INTRODUCTION:     This user scenario describes starting handling in gNB-CU a UE with 5QI1 RRC Release Delay
...             Timer running performs an inter-gNB handover over Ng interface.
...             TEST SET NAME:    CB009429
...             TESTING SPLIT:    CB009429
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009429 CFAM


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../5G_CRT/resources/common_Resource.robot
Resource         ../5G_CRT/resources/common_keywords.robot
Resource          ./resources/CB009429_B_B2_keywords.robot
Library          ta5g_cell_operations
Library          taf.sw.syslog
Resource        ../../../resources/robot/configuration_id.robot
Library         ./resources/get_host_addr.py


*** Variables ***
${scfc_gnb1}     ${CURDIR}/config/scf/BTS1_Delta.json
${scfc_gnb2}     ${CURDIR}/config/scf/BTS2_Delta.json
${cfg}      ${CURDIR}/config/wts/basic_setup.cfg
${ue_id}=    3
${regexp}=   *UE3: Inter-eNB handover from EXT_ENB-2.3 to EXT_ENB-3.7 performed*
${timeout}=	30


*** Test Cases ***
USCB009429-B#B2 Handling RRC Release Delay timer during inter-gNB NGAP Handover


    [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    Start WTS Using WTS_Runner       ${cfg}
    ...        AND    wtsrunner.enb_x2_link_up    enb=1    target=3
    ...        AND    wtsrunner.enb_x2_link_up    enb=1    target=2
    ...        AND    sleep   10s
    ...        AND    Perform Delta changes for intergNB_NGHO
    ...        AND    Get gNB2 IP address


  Start Tshark on eth3
    Start VONR call on UE-3
    Verify 5QI-1 addition
    Stop Tshark on eth3
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act.log  alias=feat_act
    Delete Normal VONR QoSflow
    sleep    5s
    Verify fiveQI1RrcRelDelayTimer started
    sleep    2s
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    sleep    2s
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act1.log  alias=feat_act  host_ip=${hostid2}
    ...     virtualenv_dir=/home/ute/.pyenv/versions/test_repo/
    sleep    5s
    Perform Inter-gNb HO to gnb-2 cell-7 via NG Interface
    sleep    5s
    Verify fiveQI1RrcRelDelayTimer started post Ho
    Start Tshark on eth3 after New VONR call
    Add QoSflow for VONR call
    sleep    5s
    Verify 5QI-1 addition after New VONR call
    Stop Tshark on eth3 after New VONR call
    Verify fiveQI1RrcRelDelayTimer stop
    sleep    2s
    Delete New VONR QoSflow call
    sleep    2s
    Verify fiveQI1RrcRelDelayTimer started after new VONR call
    sleep    80s
    Verify fiveQI1RrcRelDelayTimer stop post Ho
    taf.sw.syslog.Collect Syslog Results  destination=${OUTPUTDIR}${/}feat_act1.log    unzip=True  alias=feat_act
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Detach UE-3
     ...    AND   Kill WTS processes Using WTS_Runner
     ...    AND   Link SCOUT SCF to Configuration ID for Reporting
     ...    AND   taf.sw.syslog.teardown_all_aliases_for_syslog
     ...    AND   Stop Log    snapshot    sosreport









