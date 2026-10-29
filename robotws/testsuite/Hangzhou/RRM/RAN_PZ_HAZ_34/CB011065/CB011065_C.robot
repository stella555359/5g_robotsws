*** Settings ***
Documentation
...   author: Yin Ran
...   contact: ran.yin@nokia.com
...   Description: This is CB011065-SR-C in TMO configuration

Resource           ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/common_resource.robot
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       120 minutes

*** Variables ***
#Reduce global paramter as possilbe and automatically got from gNB or __init__

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7529}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB011065-SR_C_Case01_NSA Intra MeNB HO without PsCell change Preparation attempt
    [Documentation]
    ...    author: Yin Ran
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to verify CB011065-SR-C normal scenario.
    [Setup]
    ...    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_C_TMO
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Log To Console      ${\n}============= Prepare counter collection =============${\n}
    Counter collection CB011065_C
    Log To Console      ${\n}============= Enable Endc =============${\n}
    Config Allow Endc For Enb Cell
    Log To Console      ${\n}============= Prepare Intra-MeNB handovers =============${\n}
    NSA UE Attach and Traffic Setup    UE_ID=51
    NSA UE Attach and Traffic Setup    UE_ID=52
    Log To Console      ${\n}============= Perform Intra-MeNB HO without PsCell=======${\n}
    Intra-MeNB HO without PsCell change    UE_ID=51    Cell_ID=2
    Intra-MeNB HO without PsCell change    UE_ID=52    Cell_ID=2
    Log To Console      ${\n}============= Perform Intra-MeNB HO with takeback=======${\n}
    Intra-MeNB HO with takeback    UE_ID=51    Cell_ID=1
    Intra-MeNB HO with takeback    UE_ID=52    Cell_ID=1
    Log To Console      ${\n}============= Wait for -C counter update =============${\n}
    sleep    5 min
    Log To Console      ${\n}============= Check counter for -C =============${\n}
    Counter check
    DETTACH UE    UE_ID=51
    DETTACH UE    UE_ID=52

*** Keywords ***
Counter collection CB011065_C
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00009;
    ...    Counter rule: sum(M55128C00009)==2;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00010;
    ...    Counter rule: sum(M55128C00010)==2;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00002;
    ...    Counter rule: sum(M55128C00002)==2;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00003;
    ...    Counter rule: sum(M55128C00003)==2;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00004;
    ...    Counter rule: sum(M55128C00004)==2;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter check
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Config Allow Endc For Enb Cell
    Airphone.Airphone Execute Egate Command
#    ...    cmd=enb_cell_param enb=1 id=1 allow_endc=on
    ...    cmd=enb_cell_param enb=1 id=2 allow_endc=on

NSA UE Attach and Traffic Setup
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Attach UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_attach id=${UE_ID}
    ...    pass_regexp=UE IS ACTIVE
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue=${UE_ID} id=2 dir=dl mbps=5 trf_id=1
    ...    pass_regexp=Started Downlink Internal traffic
    sleep    3s

Intra-MeNB HO with takeback
    [Arguments]    ${UE_ID}    ${Cell_ID}
    Log To Console      ${\n}============= Intra-MeNB HO with takeback for UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_ho id=${UE_ID} ho_mode=INTRA_LTE enb=1 cell=${Cell_ID} rsrp=15:97
    ...    pass_regexp=SgNBReleaseRequest sent
    sleep    5s

Intra-MeNB HO without PsCell change
    [Arguments]    ${UE_ID}    ${Cell_ID}
    Log To Console      ${\n}============= Intra-MeNB HO without PsCell change for UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_ho id=${UE_ID} ho_mode=INTRA_LTE enb=1 cell=${Cell_ID} rsrp=15:97
    ...    pass_regexp=SgNB Modification is successful
    sleep    5s


DETTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Detach UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_detach id\=${UE_ID}
    ...    pass_regexp=detached
    sleep    2s