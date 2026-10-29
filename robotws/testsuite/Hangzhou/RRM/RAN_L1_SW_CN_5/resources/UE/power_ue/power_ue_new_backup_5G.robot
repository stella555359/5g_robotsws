*** Settings ***
Documentation     UE common keyword for normal L3 call, support to control Multi UE also.
...               Please do not modify the file without notification to author
...               Author: Civen Chen
...               Contact: civen.chen@nokia-sbell.com
Resource          ./UEs/huawei.robot
Resource          ./UEs/qct_dx50.robot
Resource          ./UEs/samsung.robot
Resource          ./UEs/huawei_sigspark.robot
Resource          ./UEs/lg_v50.robot
Resource          ./UEs/mtk.robot
Resource          ./UEs/inseego.robot
Resource          ./UEs/xiaomi.robot
Resource          ./UEs/askey_sigspark.robot
Resource          ./UEs/askey.robot
Resource          ./UEs/oneplus.robot
Resource          ./UEs/nokia_cpe.robot
Resource          ./Power_ue_supports/power_ue_log.robot
Resource          ./Power_ue_supports/power_ue_throughput.robot

*** Keywords ***
UE require and attach
    [Arguments]    ${UE_type}
    #########################################################################
    ##qualcomm ue special code###############################################
    #########################################################################
    log    INFO:require_ue    console=true
    power_ue.Prepare UE    ue_type=${UE_type}
    sleep    2s
    log    INFO:attach ue    console=true
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_type}
    sleep    2s
    power_ue.Verify attach    ue_type=${UE_type}    5Grach_ed=${5Grach_ed}    4G_check=False

UE start data transfer for UL and DL
    [Arguments]    ${UE_type}    ${DL_Send_Tput}    ${UL_Send_Tput}    ${Duration}
    log    INFO: Start data transmission UL    console=true
    power_ue.Start traffic    ue_type=${UE_type}    direction=ul    throughput=${UL_Send_Tput}    duration=${Duration}
    log    INFO: Start data transmission DL    console=true
    power_ue.Start traffic    ue_type=${UE_type}    direction=dl    throughput=${DL_Send_Tput}    duration=${Duration}
    sleep    10s

Verify average throughput of UL and DL
    [Arguments]    ${UE_type}    ${DL_Target_Tput}    ${UL_Target_Tput}    ${Cell_Id}
    sleep    5s
    log    INFO:verify average throughput with deviation DL    console=true
    Run Keyword And Ignore Error    power_ue.Check throughput    ue_type=${UE_type}    direction=ul
    ...    throughput=${UL_Target_Tput}    cellid=${Cell_Id}
    log    INFO:verify average throughput with deviation UL    console=true
    Run Keyword And Ignore Error    power_ue.Check throughput    ue_type=${UE_type}    direction=dl
    ...    throughput=${DL_Target_Tput}    cellid=${Cell_Id}

UE stop data transfer and detach
    [Arguments]    ${UE_type}
    log    INFO:stop data transfer_DL_UL    console=true
    power_ue.Stop traffic    ue_type=${UE_type}    direction=ul
    power_ue.Stop traffic    ue_type=${UE_type}    direction=dl
    log    INFO:detach ue    console=true
    power_ue.UE Detach    ue_type=${UE_type}

UE L3 Call
    [Arguments]    ${DL_Send_Tput}    ${UL_Send_Tput}    ${DL_Target_Tput}    ${UL_Target_Tput}    ${UE_type}    ${Cell_Id}
    ...    ${Duration}=9999
    UE require and attach    ${UE_type}
    UE start data transfer for UL and DL    ${UE_type}    ${DL_Send_Tput}    ${UL_Send_Tput}    ${Duration}
    Verify average throughput of UL and DL    ${UE_type}    ${DL_Target_Tput}    ${UL_Target_Tput}    ${Cell_Id}
    UE stop data transfer and detach    ${UE_type}
    #########################################################################
    #######################run ue detach when case failed####################
    #########################################################################

Ue detach when case failed
    ${ue_status}    run keyword and return status    should contain    ${TEST TAGS}    QUALCOMM_UE
    run keyword if    ${ue_status}==True    Qualcomm ue stop data transfer and detach    ${UE_alias}    ${DL_DT_Name}    ${UL_DT_Name}
    ...    ELSE    UE detach    UE1
