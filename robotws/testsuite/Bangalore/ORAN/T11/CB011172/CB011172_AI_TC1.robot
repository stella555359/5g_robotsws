*** Settings ***
Documentation
...     author:                Lavanya
...     email:                 Lavanya.T_V@nokia.com
...     Feature:               CB011172_CB007145
...     INTRODUCTION:     This user scenario describes NSA/SA call Success,UL and DL Data Success of FDD 40 Mhz BW
...     TEST SET NAME:    [1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes NSA SgNBAddition Success,UL and DL Data Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...                        [1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes SA UE Attach Success,UL and DLData Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...      TESTING SPLIT:    See CB007145 testplan
...      CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      REFERENCES:       CB011172/CB007145 CFAM
...      Requirement ID:   5G_RAN_USR_RRM_15610,5G_RAN_USR_RRM_15632


Library             ute_wtssim
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../../../resources/robot/AIC_Common_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource            ../../../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/common_resources/robot/coam.robot
Resource            ../resources/ORAN_Keywords.robot
Resource            ../../../resources/robot/WTS_Runner_Keywords.robot
Resource            testsuite/Bangalore/ORAN/T08/CB008048/resources/CB008048_keywords.robot
Library      ta5g_commissioning
Library      ta5g_pm_counters
Library     ta5g_admin_operations

Suite Setup         Run keywords     Enable Cloud
...                 AND     Test Suite Setup
#Get and Update RFMplugin   ${RFplugin_file}
#...                 AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Load netconf credentials
...                 AND             load iphyfile     ${INSTALL_OFGESA}
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
...                 AND           Verify RMODs Online Status   ${300}
...                 AND           sleep   100s    reason=f1 link should up
...                 AND           sleep    10s
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    10s


*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/AI_TC1/5G_install_radio_FDD.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_FJRU-N75N3N1-G_0020.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/AI_TC1/iphy-new.xml
${iphy_file_path}  ${CURDIR}/config/SBTS25R2/iphy-new.xml
${wts_cfg_file}    ${CURDIR}/config/AI_TC1/basic_FDD_ORAN.cfg
${vcu_file_path}   ${CURDIR}/config/AI_TC1/vcu_scf_fdd.xml
${vdu_file_path}   ${CURDIR}/config/AI_TC1/vdu_scf_fdd.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${2}

*** Test Cases ***
CB011172-CR-AI_TC1_5GC002558_Slim_carrier
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  75  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  40  pdu_id=1  trf_id=1    qfi_id=1
    sleep   60s
    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=75   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=40   pdu_id=1   qfi_id=1
#    Link SCOUT SCF to Configuration ID for Reporting
    [teardown]  MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}

