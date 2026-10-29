*** Settings ***
Documentation
...     author:                Madhukara M V
...     email:                 madhukara.n_v@nokia.com
...     Feature:               CB011172_CB007145
...     INTRODUCTION:     This user scenario verifies that simultaneous support of RP1 and ORAN Radio in single ODU.
...     TEST STEPS:        Bring up 2 cells on
...                        Cell 1 on RINLINE2-1 card
...                        Cell 4 on RINLINE2-2 card ( as at this moment bringup of RP1 and ORU on single RANNIC is not supported)
...                        Attch UE 1 to cell 1 and attach UE 2 to cell 2 ( both are TDD cells)
...                        Verify the peak tput on the both the UES on both the cells.
...
...      CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      REFERENCES:       CB011172

Library             ute_wtssim
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../../../resources/robot/AIC_Common_Keywords.robot
#../resources/robot/AIC_Common_Keywords.robot
Resource            ../../../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/common_resources/robot/coam.robot
#Resource            ../../../RRM/5GET_BLR/CB007145/resources/common/CB007145_Resource.robot
Resource            ../resources/ORAN_Keywords.robot
Resource            ../../../resources/robot/WTS_Runner_Keywords.robot
#Resource         ../../../resources/robot/configuration_id.robot
Library      ta5g_commissioning

Suite Setup         Run keywords     Test Suite Setup
...                 AND     Get and Install RFMplugin vdu  ${RFplugin_file}
#...                 AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Load netconf credentials
...                 AND             load iphyfile    ${INSTALL_OFGESA}
...                 AND             Sleep    30s
...                 AND             AIC Software Build Info
...                 AND             Fetch Taf Library used in TL
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${vdu_file_path}
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${vcu_file_path}
...                 AND           sleep    200s
#...                 AND              Prepare AIC TL with vcu and vdu full config files   ${vcu_file_path}    ${vdu_file_path}
#...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
#...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A  4892
#...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
#...                 AND           AP Reboot Wait For Connection    ${120}
...                 AND           Verify RMODs Online Status   ${600}
...                 AND           sleep   100s    reason=f1 link should up
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    10s

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/B_TC2/5G_install_radio_FDD.sh
${RFplugin_file}       O-RU_NK_475701A-102_0025
${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/B_TC2/iphy-new.xml
${iphy_file_path}  ${CURDIR}/config/SBTS25R2/iphy-new.xml
${wts_cfg_file}    ${CURDIR}/config/B_TC2/basic_FDD_ORAN.cfg
${vcu_file_path}   ${CURDIR}/config/B_TC2/vcu_scf_fdd.xml
${vdu_file_path}   ${CURDIR}/config/B_TC2/vdu_scf_fdd.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${2}

*** Test Cases ***
CB011172-CR-B_TC2_ORU_Management_Simultaneous_support_of_NETCONF_OR_Yang_and_SOAP_OR_RP1_fronthaul_M-Plane_interfaces_by_single_O-DU
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_st_ue_id}    pdu_id=1    nw_id=1
    MultiUE Register should be Successful      ${sa_en_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_st_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_st_ue_id}    mbps  150  pdu_id=1  trf_id=2    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_st_ue_id}    mbps  100  pdu_id=1  trf_id=1    qfi_id=1
    sleep   60s
    MultiUE Trigger DL Traffic for SA     ${sa_en_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_en_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=2    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_en_ue_id}    ${sa_en_ue_id}    mbps  100  pdu_id=1  trf_id=1    qfi_id=1
    sleep   60s
    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=247   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=21    pdu_id=1   qfi_id=1
#    Link SCOUT SCF to Configuration ID for Reporting
    [teardown]  MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}

