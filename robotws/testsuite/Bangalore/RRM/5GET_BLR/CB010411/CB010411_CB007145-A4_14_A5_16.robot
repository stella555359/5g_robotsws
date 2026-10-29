*** Settings ***
Documentation
...     author:                Prerana
...     email:                 Prerana.N_S@nokia.com
...     Feature:               CB010411_CB007145
...     INTRODUCTION:     This user scenario describes NSA/SA call Success,UL and DL Data Success of FDD 40 Mhz BW
...     TEST SET NAME:    [1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes NSA SgNBAddition Success,UL and DL Data Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...                        [1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes SA UE Attach Success,UL and DLData Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...      TESTING SPLIT:    See CB007145 testplan
...      CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      REFERENCES:       CB007145 CFAM
...      Requirement ID:   5G_RAN_USR_RRM_15610,5G_RAN_USR_RRM_15632

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/common_resources/robot/coam.robot
Resource            ../CB007145/resources/common/CB007145_Resource.robot

Suite Setup         Run keywords     Test Suite Setup
...                 AND              AIC Software Build Info
...                 AND              Fetch Taf Library used in TL
...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A  4892
...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
...                 AND           AP Reboot Wait For Connection    ${120}
...                 AND           Verify RMODs Online Status   ${300}
...                 AND           sleep   1200s    reason=f1 link should up
...                 AND           sleep    120s
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    60s

*** Variables ***
${RMOD_name}       AHFII
${iphy_file_path}  ${CURDIR}/config/SBTS25R!/iphy_CB007145A414A516.xml
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_CB007145A414A516.cfg
${vcu_file_path}   ${CURDIR}/config/SBTS25R1/scfc_cu_CB007145A414A516.xml
${vdu_file_path}   ${CURDIR}/config/SBTS25R1/scfc_du_CB007145A414A516.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${5}

*** Test Cases ***
[1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1

    sleep   180s

    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=10   pdu_id=1   qfi_id=1

    MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}
