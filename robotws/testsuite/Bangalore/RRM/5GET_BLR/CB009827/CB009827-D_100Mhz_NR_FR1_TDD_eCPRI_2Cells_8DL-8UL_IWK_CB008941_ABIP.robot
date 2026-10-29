*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LOOO    SBTS00        CONFIGURED    5G_RAN_TDD    RAN_5G    CRT
...            VARIANT_SANSA_FS_ECPRI_CMWV_TDD     PY39

Documentation    :copyright: Nokia
...              :authors: Sruthi
...              :contact: Sruthi.jacob@nokia.com
...              Feature Overview:
...   This feature introduces the UL subcell deactivation mechanism for the cases where RF units do not support UL PRB
...   muting as per CB008941 allowing respective deployment.
...   The stream-PRB receiving resources on UL fronthaul are limited and they become the bottleneck resources to support
...   higher amount cell configuration. In order to resolve this issue, the subcell deactivation mechanism is introduced
...   in this feature to ensure the unmuted stream-PRBs in all activated UL subcells shall not be larger than the L1 UL
...   fronthaul capacity on L1 pool level.
...             TC Overview:
...    USCB009827-D#1: interworking with CB008941
...    Requirement ID  : CB_FIM_32207;CB_FIM_32208;5G_RAN_USR_RRM_17660
...    This user scenario is to validate below aspects
...   a)One of the cells support UL PRB muting.
...   b)The activation of CB009827 ,where BBRM deactivates some UL subcells inside a L1 Pool (via Load-Based algorithm )
...     according to a fair share of the cells' current UL load(GBR and non-GBR)and UL FH stream-PRB resources in single
...     L1 pool are pooled.
...   c)Interworking with CB008941


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB009827_Keywords.robot
Resource        ../CB008285/CB008285_Resource.robot

Suite Setup    Run keywords   Log to console   "Suite setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND    Sleep    2min
...                 AND   Perform SCF Delta Commissioning with Update_BSR_config.json
...                 AND    Sleep    2min
...                 AND    Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
#...                 AND    Get and Update BSR SW
#...                        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/srjacob
#...                        CB009827     BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip   /home/ute/BSR
...                 AND    add routes
...                 AND    Add GNB RadParam for CB009827-D
...                 AND    Sleep    2min
...                 AND    Add AP RadParam for CB009827-A
...                 AND    Sleep    2min
...                 AND    Setup_Env.Reboot GNB System Module From Console And Check Airscale Is Ready
#...                 AND    Start Default Logging Gnb ASIL_ABIO
...                 AND     CB009827_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}
#...                 AND    Setup X2 Link


#Suite Teardown    Custom Suite Teardown
*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/CB009827-A.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${filepath}            "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/srjacob/CB009827/"
${en_ue_id}             ${13}
${SCFC}=                 ${CURDIR}/config/TC_D/SCF_CB009827-D_8DL8UL_IWK_CB008941_ABIP.xml
${AP_XML}=               ${CURDIR}/config/TC_D/IPHY_CB009827-D.xml
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
[1][1.0] CB009827_USCB009827-D#1_2_2Cells_8DL-8UL_Activation_of_subcell_deactivation_algorithm_for_UL_when_only_one_of_the_cells_support_ULPRB_muting
    Setup X2 Link
    Run Keyword and Ignore Error     Link SCOUT SCF to Configuration ID for Reporting
    log to console   Suite setup successful ...
    sleep   30s
    Set SRS Beam Position for muMIMO
    Attach Multiple SA UEs and perform data transfer
    sleep  10s
    Run Keyword and Ignore Error   Verify PM Counters for Cell50 [NRCELL-1]
    Run Keyword and Ignore Error   Verify PM Counters for Cell51 [NRCELL-2]
#    Run Keyword and Ignore Error  Start Log    ttitrace    sherpa
	Sleep    10s
#
#    ${logs_path1}   Run Keyword and Ignore Error   Stop Log    sherpa    ttitrace    test_scenario=UlData_load_at_Cell50
#	Run Keyword and Ignore Error  Decode Sherpa pcap    UlData_load_at_Cell50

    sleep   60s
    #Decrease load in Cell50
    Decrease SA Users data traffic    ue_id=1     trf_id=1
    Decrease SA Users data traffic    ue_id=2     trf_id=3
    #Increase load in Cell51
    Attach Multiple NSA UEs and perform data transfer
    sleep  10s
    Run Keyword and Ignore Error    Verify PM Counters for Cell51 [NRCELL-2]
#    Run Keyword and Ignore Error  Start Log    ttitrace    sherpa   cell_id=51
	Sleep    10s
#    ${logs_path2}    Run Keyword and Ignore Error  Stop Log    sherpa     ttitrace    test_scenario=UlData_load_at_Cell51
#	Run Keyword and Ignore Error  Decode Sherpa pcap    UlData_load_at_Cell51

#
