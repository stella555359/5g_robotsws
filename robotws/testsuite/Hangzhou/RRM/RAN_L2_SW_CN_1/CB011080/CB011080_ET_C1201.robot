*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11    CB012528    owner_qiaren
Resource          resources/CB011080_resource.robot

Documentation
...     CB011080_C1201_interwork_multi-bwp

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                Full_SCF_CB011080_multiBWP.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080_multi_bwp.xml
${WTS_CFG}                  basic_CB011080_multi_bwp.lua
${SWCONFIG_PARAM_GNB}       0x890071=1;

${UE_1}                     3

${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2

${6CC_NUM}                  6
@{6CC_DL_TPUT}         500    80    180    160    120    450
@{2CC_UL_TPUT}         85    45
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55



*** Test Cases ***
CB011080_ET_C1201_Verify_6CC_IWK_With_3Dedicated_BWPs_Pcell_Larger
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true

    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
    Start SA UE Big DL Traffic Internal    ${UE_1}    2300
    Start SA UE Big UL Traffic Internal    ${UE_1}    175
    Sleep    3s    reason=wait 30s for traffic statble
    Wait Until Keyword Succeeds    30s    2s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
    Wait Until Keyword Succeeds    30s    2s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT}    ${6CC_NUM}
    Capture And Check TTitrace Logs    1



