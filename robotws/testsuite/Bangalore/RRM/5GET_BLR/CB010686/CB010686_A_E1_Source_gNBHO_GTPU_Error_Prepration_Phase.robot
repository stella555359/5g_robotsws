*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Test Set Name: CB010686 Source GNB detected GTP error during inter-gNB mobility Preparation phase 
...             Testing Split: A#E1
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             Requirement ID  : 5G_RAN_USR_RRM_26509
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Library		      OperatingSystem


Resource         ./CB010686_resource.robot


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with A_B5.json
...                 AND     sleep    60
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     sleep    60
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     sleep    60
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1


Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
...                 AND     Run Keyword and Ignore Error    Get Snapshot


*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_a_b_5.cfg
${WTS_DIR}          /opt/iphy/latest
${start_ue_id}        1
${end_ue_id}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nw_id}    1
${ue_id}    1

*** Test Cases ***
[1.0] CB010686 Source GNB detected GTP error during inter-gNB mobility Preparation phase
     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${start_ue_id}    ${1}
     sleep   5s
     MultiUE Trigger UL Traffic for SA    ${start_ue_id}  ${1}  Traffic_rate=mbps     ul_rate=70   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${start_ue_id}  ${1}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
     sleep   5s
     Trigger Xn HO and HO Prepration Timeout 	${start_ue_id}      3
	 Inject PDU Error   ${1}    ${1}    1
     sleep   1s
     UE state should be active   ${1}    ${1}
     MultiUE Deregister should be Successful   ${1}    ${1}
     ${scen1}     Stop Log      btslog     cprt
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

