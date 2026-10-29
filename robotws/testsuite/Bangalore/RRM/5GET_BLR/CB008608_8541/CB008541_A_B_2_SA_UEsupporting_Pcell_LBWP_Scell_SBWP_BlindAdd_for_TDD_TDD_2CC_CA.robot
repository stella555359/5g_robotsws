*** Setting ***
#Force Tags      CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS
#...   PY27
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     vDUCNF_0.300   vDUCNF_0.30022R4    CONFIGURED
Documentation
...     author:         Shekhar.Vijay_Barewar@nokia.com/prasun.chakravorty@nokia.com
...     maintainer:     Shekhar Barewar/Prasun Chakravorty
...     INTRODUCTION:   CB008608_CB008541 CRT Automation
...     Feature:        CB008608/8541


Resource            CB008608_8541_resource.robot
Resource            resources/AIC_8541_TCrelated_keywords.robot



Suite Setup             Run keywords   BuiltIn.Run Keyword And Ignore Error   Test Suite Setup
...                     AND     BuiltIn.Run Keyword And Ignore Error   AIC Software Build Info
...                     AND     BuiltIn.Run Keyword And Ignore Error   Fetch Taf Library used in TL
#...                     AND    Trigger Delta Plan For CU  ${delta_cu}
#...                     AND    Update and Activate Delta Plan Parameter   delta   ${delta_vdu}
...                     AND    BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND    Verify RMODs Online Status   ${800}
...                     AND    BuiltIn.Run Keyword And Ignore Error   Clear WTS     ${WTS_DIR}
...                     AND    BuiltIn.Run Keyword And Ignore Error   Add WTS Ipaddr At VM
...                     AND    log to console   loading cfg.................
...                     AND    Start WTS Using WTS_Runner     ${wts_cfg_file}
...                     AND    sleep   120s

#Suite Teardown          Run keywords        Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_8608_8541_TC01.cfg
${delta_vdu}        ${CURDIR}/config/SBTS23R1/Delta_Configuration_TC01_A_B_2_vdu.json
${delta_cu}         ${CURDIR}/config/SBTS23R1/Delta_Configuration_TC01_A_B_2_vcu.json
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}         1
${QFI_ID}        1
${TRF_ID}        1
${TRF_ID2}       2
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${VDU_SCF_PATH}     ${CURDIR}/config/working_8379_vdu.xml
${VCU SCF PATH}     ${CURDIR}/config/working_8379_vcu.xml
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${UE_ID}   1


*** Test Cases ***
[1] CB008541_A#B.2_SA_UEsupporting_Pcell_LBWP_Scell_SBWP_BlindAdd_for_TDD_TDD_2CC_CA
    log to console   ue attach triggering now....
    UE Register should be Successful And Fetch RNTI   1
    Sleep  5s
    Check Blind SCell Addition and Small BWP in SCell   31624
    Start Big DL Data Transfer And Check SCell Activation for the Blind Scell Added with 2CC
    BuiltIn.Run Keyword And Ignore Error   Verify DL Tput For 2CC
