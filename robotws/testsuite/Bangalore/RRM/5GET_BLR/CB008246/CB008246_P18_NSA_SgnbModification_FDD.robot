*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CONFIGS_Bangalore/Bangalore/RRM/ET/CB008246/CB008246_P18_NSA_SgnbModification_FDD.yml
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...             maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...
...             INTRODUCTION:      CB008246 P18 NSA FDD add HR DRB
...             TEST SET NAME:     CB008246-P High reliability DRB release and add High reliability DRB
...             TESTING SPLIT:     See CB008246-P testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-P CFAM
...				Objective: SgNB addition with one or more non-GBR High Reliability DRBs
...				Procedure: Bearer 2 and Bearer 3 is added

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Change IPHY File Value AP ABIO      AHFII       5394
...                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file}       349000   431760
#...                 AND     Perform SCF Delta Commissioning with Delta_CB008246_P18_NSA_SgnbModification_FDD.json
#...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Stop Log    btslog      snapshot     sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB008246_P18_NSA_SgnbModification_FDD_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB008246_P18_NSA_SgnbModification_FDD_iphy.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg_P18_NSA_SgnbModification_FDD.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${st_ue_id}      1
${en_ue_id}      1
${nsa_st_ue_id}    11
${nsa_en_ue_id}    11
*** Test Cases ***
[1][1.0] TC18_P_NSA_FDD_HR_DRB_activated_during_SgNB_Modification
    log to console   UE attach trigerring now...
    X2AP Link Should be UP
    start log   cprt
	${crnti}=      MultiUE Attach for NSA     11    11    1
    Sgnb Modification to add bearer id 3    11
    Start traffic for NSA UE    11    2
    sleep       30s
    Start traffic for NSA UE    11    3
    sleep       30s
    ${path}    Stop log    cprt
    Validate that the NSA traffic is normal     11
    Verify CB008246 Parameters     ${path}[cprt]    nr-rrc.pdsch_Config     nr-rrc.mcs_Table
    MultiUE Detach for NSA   11   11

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Start traffic for NSA UE
    [Arguments]    ${UE_id}    ${bear_id}
    MultiUE DL Traffic Start for NSA     ${UE_id}      ${UE_id}      mbps    10     id=${bear_id}   trf_id=1
    MultiUE UL Traffic Start for NSA     ${UE_id}      ${UE_id}      mbps    10     id=${bear_id}    trf_id=1
    sleep       4s

Sgnb Modification to add bearer id 3
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
    [Documentation]    This keyword is used to add different QCI other than the one added as a default.
    wtsrunner.bearer_add    ue=${UE_ID}  id=3  filter=0  precedence=0
    sleep       5s
    wtsrunner.enb_ue_dc_modify   ue=${UE_ID}  bearer_to_add=3  by=enb  cause=RN_CauseRadioNetwork_unspecified
    ...                          type=split_scg

Validate that the NSA traffic is normal
    [Arguments]    ${UE_id}
    log to console   NSA traffic validation ongoing...
    Run keyword and Ignore Error    MultiUE Validate DL Traffic For NSA     11     11    2    10
    Run keyword and Ignore Error    MultiUE Validate UL Traffic For NSA     11     11    2    10
    Run keyword and Ignore Error    MultiUE Validate DL Traffic For NSA     11     11    3    10
    Run keyword and Ignore Error    MultiUE Validate UL Traffic For NSA     11     11    3    10

