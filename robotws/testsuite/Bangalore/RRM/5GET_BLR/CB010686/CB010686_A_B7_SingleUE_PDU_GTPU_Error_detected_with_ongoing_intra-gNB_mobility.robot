*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : navin.kumar_ray@nokia.com
...             maintainer   : navin.kumar_ray@nokia.com
...             Test Set Name: CB010686 PDU Session detected GTP Error at source gNB with ongoing inter-gNB mobility
...             Testing Split: A#B5
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             Requirement ID  : 5G_RAN_USR_RRM_26508
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Library		      OperatingSystem


Resource         ./CB010686_resource.robot


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with A_B7.json
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
#update the path of the cfg file & also change the cfg file name

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_b7.cfg
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
[1]CB010686-A-B5 PDU Session detected GTP Error at source gNB with ongoing inter-gNB mobility.

     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${1}    ${1}

     sleep   5s

     MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=70   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
     sleep   5s

     Intra_gnb_Handover    1
	 sleep   5s

     ${status}       Run keyword and Return Status   Inject PDU Error   ${1}    ${1}    1
#     Should Contain            ${status}                FAIL
     Should Be Equal As Strings          ${status}                True
     sleep   5s
     UE state should be active   ${1}    ${1}
     MultiUE Deregister should be Successful   ${1}    ${1}
     ${scen1}     Stop Log      btslog     cprt
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Intra_gnb_Handover
    [Arguments]   ${ue_id}
    ${cmd}   set variable   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=51 nrsrp_nr=30 nrsrq_nr=20
    ute_wtssim.Execute Egate Command    ${cmd}
    sleep   3s

