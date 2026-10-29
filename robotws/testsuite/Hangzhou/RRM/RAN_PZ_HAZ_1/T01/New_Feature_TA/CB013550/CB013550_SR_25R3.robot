*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${wts_folder}  /opt/wts

*** Test Cases ***
Case_Precondition
    Case Precondition for sbts

[1]CB013550-D-SR-Counter for Number of NSA ERABs Released due to Normal causes initiated by MeNB for CB006898
    [Tags]    QC_203270       QCD_MN_RAN      QCP_RAN_VRF
#    Airphone Operation    edaemon_egate_setup     gnb tag=1
    Setup X2 Link
    UE Deregister From gNB      ue_id=11
    Start Collect Mutli Counters For Normal Release
    Trigger Normal-release
    Stop Collect Mutli Counter
#    Get Emil Decoded Data In Json
    UE Detach From gNB

[1]CB013550-D-SR-Non Profile Based Control Plane counter
    [Tags]    QC_203269       QCD_MN_RAN      QCP_RAN_VRF
#    Airphone Operation    edaemon_egate_setup     gnb tag=1
    Setup X2 Link
    UE Deregister From gNB      ue_id=11
    Start Collect Mutli Counters For Abnormal Release
    Trigger abnormal-release
    Stop Collect Mutli Counter
#    Get Emil Decoded Data In Json
    UE Detach From gNB

*** Keywords ***
Case Precondition for sbts
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition

Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=1
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
#    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
#    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

Create wts folder if not exists
     Run Keyword If    not os.path.exists("${wts_folder}")   Run  cd /opt;sudo mkdir wts
     ${wts_folder}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
     ${wts_folder_list}    Split String    ${wts_folder}    /
     ${wts_up_folder}    Generate wts path
     Run  cd ${wts_up_folder};tar -czvf latest.tar ${wts_folder_list[-1]}/
     ${exist_latest}   Run   cd ${wts_up_folder};ls latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"    Run  cd ${wts_up_folder};sudo cp latest.tar /opt/wts
     Run keyword if  "${exist_latest}"=="latest.tar"    Run  cd ${wts_up_folder};sudo rm latest.tar
     Run  cd /opt/iphy;rm -f latest
     ${exist_latest}   Run   cd /opt/wts;ls latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"   Run  cd /opt/wts;sudo tar -xzvf latest.tar
     Run keyword if  "${exist_latest}"=="latest.tar"   Run  cd /opt/wts;sudo rm latest.tar
     Run  cd /opt/wts;sudo mv ${wts_folder_list[-1]}/ latest/
     Run  cd /opt/iphy;ln -s /opt/wts/latest latest

Generate wts path
    ${wts_folder}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    ${wts_folder_list}    Split String    ${wts_folder}    /
    ${wts_folder}    Set Variable    /opt/iphy/${wts_folder_list[-2]}
    [Return]    ${wts_folder}

Setup X2 Link
    Airphone Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    sleep   600s

UE Deregister From gNB
    [Arguments]    ${ue_id}=11
    Airphone Execute Egate Command    cmd=ue_attach id=${ue_id}
    sleep   5s
    Airphone Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    sleep   10s

Start Collect Mutli Counters For Normal Release
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55162C00002;
    ...         Counter rule:avg(M55162C00002)==1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55112C06002;
    ...         Counter rule:avg(M55112C06002)==1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55180C00005;
    ...         Counter rule:avg(M55180C00005)==1;
    append to list  ${rule_list}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Start Collect Mutli Counters For Abnormal Release
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55162C00003;
    ...         Counter rule:avg(M55162C00003)==1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55180C00002;
    ...         Counter rule:avg(M55180C00002)==1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55112C06003;
    ...         Counter rule:avg(M55112C06003)==1;
    append to list  ${rule_list}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Stop Collect Mutli Counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

Trigger Normal-release
    Airphone Execute Egate Command    cmd=enb_ue_dc_release ue=11 by=enb cause=RN_normal_release

Trigger abnormal-release
    Airphone Execute Egate Command    cmd=enb_ue_dc_release ue=11 by=enb cause=RN_CauseRadioNetwork_unspecified

UE Detach From gNB
    Airphone Execute Egate Command    cmd=ue_detach id=11
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

