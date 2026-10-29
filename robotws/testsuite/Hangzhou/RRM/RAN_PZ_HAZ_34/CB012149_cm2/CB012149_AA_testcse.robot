*** Settings ***
Resource    Resources/CB012149_common_keyword.robot
Variables    Resources/CB012149_variable.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${TRUE}

*** Variables ***
${tl_scf_dir_path}     ${CURDIR}/../../../../../commissionings/HGZ/


*** Test Cases ***
[1]CB012149_SR_AA_01_Successful operation of the CB012149 feature activation_with_CA
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    CB012149 UE prepare UE
    ${cpif_log}    Qcom UE Attach and Get CP-IF log    
    Check ulTxSwitch Related Info during Attach Procedure    cpif_log=${cpif_log}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    CB012149 COAM update ulTxSwitchingSupportList    ulTxSwitchingSupportList=${CB012149_disable_ulTxSwitching}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    ${cpif_log}    Qcom UE Attach and Get CP-IF log   
    Check ulTxSwitch Related Info during Attach Procedure    cpif_log=${cpif_log}    feature_enable=${False}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log    ul_target_tdd=175
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    ...                                                       layer_true=${uldata_puschreceivereq_layer1_filter}
    ...                                                       layer_false=${uldata_puschreceivereq_layer2_filter}
    CB012149 COAM update ulTxSwitchingSupportList    ulTxSwitchingSupportList=${CB012149_enable_ulTxSwitching}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log    ul_target_tdd=175
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    ...                                                       layer_true=${uldata_puschreceivereq_layer1_filter}
    ...                                                       layer_false=${uldata_puschreceivereq_layer2_filter}
    ${cpif_log}    Qcom UE Attach and Get CP-IF log    
    Check ulTxSwitch Related Info during Attach Procedure    cpif_log=${cpif_log}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}
