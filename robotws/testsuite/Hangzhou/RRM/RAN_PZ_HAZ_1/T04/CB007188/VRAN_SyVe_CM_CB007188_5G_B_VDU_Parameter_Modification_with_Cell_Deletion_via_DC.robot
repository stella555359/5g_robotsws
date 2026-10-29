*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource        ../../Resources/Cloud/AIC_Common_Resource.robot
Resource         ../Resources/PZ2/vdu_log_containerlog.robot
Resource         ../Resources/PZ2/vdu_oam_cm.robot
Resource         ../Resources/PZ2/aic_common_resources_new.robot
Resource         ../Resources/PZ2/kw_to_be_optimized.robot
Resource         ../Resources/PZ2/vdu_sec_authorization.robot
Resource         ../Resources/PZ2/vdu_cloud_deployment.robot
Resource         ../Resources/PZ2/vdu_trs_conn.robot
Library          ../Resources/PZ2/py_tool/utils.py

*** Variables ***
${NEED_RECONNECT_RU}             ${False}
${VDU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT_ROOT}     \\[root@\\S+:\\S+\\][\\r\\n]+#\\s
${VDU_OE_SERVER_PROMPT}          \\[core@\\S+\\s\\S+\\]\\$\\s
${VDU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$

*** Keywords ***
VRAN_SyVe_CM_CB007188_5G_B_VDU_Parameter_Modification_with_Cell_Deletion_via_DC
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.10.2024, lixin.kang@nokia-sbell.com, draft,
    ...    New case,based to transfer from PZ2 case:
    ...   [1][1.0] CB007188_5G_B_VDU_Parameter_Modification_with_Cell_deletion_via_NOM_DC
    Log To Console    ${TEST_NAME} start.
    Step 1: Random Delete One NRCELL From NetAct
    Step 2: Check Cell Number And Status
    Step 3: Make Sure vDU Restart Once

Step ${index}: Random Delete One NRCELL From NetAct
    Log To Console  Step ${index}: Get NRCELLGRP And NRCELL Parameters on vDU
    ${nrcell_list}    Get Cell ID List
    ${cellid}    Evaluate    random.choice(${nrcell_list})    modules=random
    ${selected_nrcell_dn}    Set Variable    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${cellid}
    ${HANDLE}    Begin K8s Log
    Set Test Variable    ${HANDLE}
    ${back_scf}    vDU Backup SCF From Test Line
    ${name}     Create Plan To Delete NRCELL Via NetAct    ${selected_nrcell_dn}    ${back_scf}
	Set Test Variable    ${name}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=activate

Step ${index}: Check Cell Number And Status
    Log To Console  Step ${index}: Check Cell Number And Status
    Wait Until Keyword Succeeds    15m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    ${cell_number_current}    Get VDU Cell Number From SCF
    Should Be True   ${cell_number_current}==${CELL_NUMBER_FORMER}-1

Step ${index}: Make Sure vDU Restart Once
    Log To Console  Step ${index}: Make Sure vDU Restart Once
    ${local_auto_healing_log}    End K8s Log      handle=${HANDLE}      pod_abbr=healing-controller    container=healing-controller
    ${VNF_restart_number}=  OperatingSystem.Run  cat ${local_auto_healing_log} | egrep -i "start VNF restart" | wc -l
    should be true   ${VNF_restart_number}==1

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    # This CB007188 transfered case must run on DC env. But CRT env MRBTS11083/11084 has FHGW, plan to change to DC at FB26xx
    #FhmSiso Should Be Expected   fhmsiso=direct-connect
    ${cell_number_former}    Get VDU Cell Number From SCF
    Set Test Variable    ${cell_number_former}
    ${START_TIME}    Get time    exclude_millis=yes
    Set Test Variable    ${START_TIME}

Case Postcondition
    Log To Console    Case Postcondition
    NetAct Provision Plan    plan_name=${name}_backup   dist_names=PLMN-PLMN/MRBTS-${vDU_id}   backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
	Wait Until Keyword Succeeds    15m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
