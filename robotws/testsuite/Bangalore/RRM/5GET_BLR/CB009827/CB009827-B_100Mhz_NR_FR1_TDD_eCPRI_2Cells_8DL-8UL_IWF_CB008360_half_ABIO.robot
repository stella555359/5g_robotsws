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
...    USCB009827_USCB009827-B#1_2Cells_8DL-8UL_Activation_of_load_based_subcell_pooling_
...    interworking_with_CB007113_CB008360
...    Requirement ID  : 5G_RAN_USR_RRM_17842;CB_FIM_32204
...    This TC aims at validating the IWF CB007113 and CB008360 successful cell setup of 2 *NR FR1 TDD eCPRI 8DL8UL cells in half ABIO
...    Pre-requisite features CB007113 and CB008360 are enabled.



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB009827_Keywords.robot
Resource        ../CB008285/CB008285_Resource.robot
Resource         ../resources/robot/configuration_id.robot




Suite Setup    Run keywords   Log to console   "Suite setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND    Sleep    2min
...                 AND   Perform SCF Delta Commissioning with Update_BSR_config.json
...                 AND    Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
#...                 AND    Sleep    2min
#...                 AND    Get and Update BSR SW
#...                        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/srjacob
#...                        CB009827     BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip   /home/ute/BSR
...                 AND    add routes
...                 AND    Add GNB RadParam for CB009827-A
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
${BSR_SW_FILE}             BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip
${TLConfig.isUTE}   True
${tl.core}      ${None}
*** Keywords ***

Custom Suite Teardown
  ...                 Run Keywords    Revert GNB RadParam
  ...                 AND     Revert AP RadParam
  ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
  ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}



*** Test Cases ***
[1][1.0] CB009827_USCB009827-B#1_2Cells_8DL-8UL_Activation_of_load_based_subcell_pooling_interworking_with_CB007113_CB008360
    log to console   Suite setup successful ...
    sleep   30s
    Set SRS Beam Position for muMIMO
    Link SCOUT SCF to Configuration ID for Reporting
    Attach Multiple SA UEs and perform data transfer
    sleep  20s
    Attach Multiple NSA UEs and perform data transfer
    sleep  10s
    Run Keyword and Ignore Error    Verify Counters CB008360
    Run Keyword and Ignore Error  Start Log    ttitrace    sherpa   cell_id=51

