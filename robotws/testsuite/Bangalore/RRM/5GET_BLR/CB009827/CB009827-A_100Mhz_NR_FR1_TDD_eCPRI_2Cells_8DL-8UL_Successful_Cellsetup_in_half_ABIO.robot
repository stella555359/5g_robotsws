*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD   SBTS00        CONFIGURED    5G_RAN    RAN_5G    CRT
...             CONFIGS_Bangalore/RRM/ET/CB009827/CB009827-D_2_8DL8UL_IWK_CB008941_Half_ABIO_Config.yml  PY39
Documentation    :copyright: Nokia
...              :authors: Sruthi/Nagesh
...              :contact: Sruthi.jacob@nokia.com/nagesh.k_v@nokia.com
...              Feature Overview:
...   This feature introduces the UL subcell deactivation mechanism for the cases where RF units do not support UL PRB
...   muting as per CB008941 allowing respective deployment.
...   The stream-PRB receiving resources on UL fronthaul are limited and they become the bottleneck resources to support
...   higher amount cell configuration. In order to resolve this issue, the subcell deactivation mechanism is introduced
...   in this feature to ensure the unmuted stream-PRBs in all activated UL subcells shall not be larger than the L1 UL
...   fronthaul capacity on L1 pool level.
...             TC Overview:
...    USCB009827-A#1: BB cell set type CB009827-A - 2 cells 8DL-8UL streams in half ABIO
...    Requirement ID  : SRAN_SFS_SISO.3050
...    This TC aims at validating successful cell setup of 2 *NR FR1 TDD eCPRI 8DL8UL cells in half ABIO
...    Pre-requisite features CB007113 and CB008360 are enabled.



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB009827_Keywords.robot
Resource         ../CB008285/CB008285_Resource.robot




Suite Setup    Run keywords   Log to console   "Suite setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND    Sleep    2min
...                 AND   Perform SCF Delta Commissioning with Update_BSR_config.json
...                 AND    Sleep    2min
...                 AND    Get and Update BSR SW
...                        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/srjacob
...                        CB009827     BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip   /home/ute/BSR
...                 AND    add routes
...                 AND    Add GNB RadParam for CB009827-D
...                 AND    Sleep    2min
...                 AND    Add AP RadParam for CB009827-A
...                 AND    Sleep    2min
...                 AND    Setup_Env.Reboot GNB System Module From Console And Check Airscale Is Ready
...                 AND    Start Default Logging Gnb ASIL_ABIO
...                 AND     CB009827_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    Setup X2 Link


Suite Teardown    Custom Suite Teardown
*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/CB009827-A.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${filepath}            "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/srjacob/CB009827/"
${en_ue_id}             ${13}
${SCFC}=                 ${CURDIR}/config/TC_B/SCF_CB009827-A_2_8DL8UL_Half_ABIO.xml
${AP_XML}=               ${CURDIR}/config/TC_B/IPHY_CB009827-A.xml
*** Keywords ***

Custom Suite Teardown
  ...                 Run Keywords    Revert GNB RadParam
  ...                 AND     Revert AP RadParam
  ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
  ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}



*** Test Cases ***
[1]CB009827_USCB009827-A#1_1_NR_FR1_TDD_eCPRI_2Cells_8DL-8UL_Successful_Cellsetup_in_half_ABIO
    log to console   Suite setup successful ...
    sleep   30s
    Set SRS Beam Position for muMIMO
#Checking if two cells are configured in single Loki
    Attach Multiple SA UEs and perform data transfer
    sleep  10s

    Attach Multiple NSA UEs and perform data transfer
