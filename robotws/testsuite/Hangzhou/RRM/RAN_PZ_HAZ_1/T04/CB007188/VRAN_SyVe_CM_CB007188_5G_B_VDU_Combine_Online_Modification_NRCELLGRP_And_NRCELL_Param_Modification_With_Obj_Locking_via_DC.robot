*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource        ../../Resources/Cloud/AIC_Common_Resource.robot



*** Keywords ***
VRAN_SyVe_CM_CB007188_5G_B_VDU_Combine_Online_Modification_NRCELLGRP_And_NRCELL_Param_Modification_With_Obj_Locking_via_DC
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    15.10.2024, lixin.kang@nokia-sbell.com, draft,
    ...    New case,based to transfer from PZ2 case:
    ...   [1][1.0] CB007188_5G_B_VDU_Combine_Online_Modification_NRCELLGRP_Parameter_And_NRCELL_Parameter_Modification_With_Objeck_Locking_via_NOM_DC
    Log To Console    ${TEST_NAME} start.
    Step 1: Get NRCELLGRP And NRCELL Parameters on vDU
    Step 2: Combine Online Modify NRCELLGRP And NRCELL Parameters In Netact
    Step 3: Check Online Parameter On NetAct

Step ${index}: Get NRCELLGRP And NRCELL Parameters on vDU
    Log To Console  Step ${index}: Get NRCELLGRP And NRCELL Parameters on vDU
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=bacup_plan.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}  plan_name=backup_plan   operation_type=actual
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/bacup_plan.csv
    ${nrcell_list}    L_XML.Get Elements    ${xml_content}    .//managedObject[@class="NRCELL"]
    ${random}    Evaluate    random.randint(0,${nrcell_list.__len__()-1})    modules=random, sys
    ${targetObj}    L_XML.Get Element Attribute    ${nrcell_list[${random}]}    distName
    Set Test Variable   ${CELL_ID}    ${targetObj}
    ${nrcellgrp_list}    L_XML.Get Elements    ${xml_content}    .//managedObject[@class="NRCELLGRP"]
    ${random}    Evaluate    random.randint(0,${nrcellgrp_list.__len__()-1})    modules=random, sys
    ${targetObj}    L_XML.Get Element Attribute    ${nrcellgrp_list[${random}]}    distName
    Set Test Variable   ${CELLGROUP_ID}    ${targetObj}
	${PMAX_BEFORE}    L_XML.Get Element Text    ${xml_content}    .//managedObject[@distName="${CELL_ID}"]/p[@name="pMax"]
	${PMAX_CHANGED}     Evaluate	${PMAX_BEFORE}+1
	${PMAX_CHANGED}    Convert To String    ${PMAX_CHANGED}
    ${MAXNUM_BEFORE}    L_XML.Get Element Text    ${xml_content}    .//managedObject[@distName="${CELLGROUP_ID}"]/p[@name="maxNumOfRrcCGRPSA"]
    ${MAXNUM_CHANGED}    Evaluate	  ${MAXNUM_BEFORE}+20
    ${MAXNUM_CHANGED}    Convert To String    ${MAXNUM_CHANGED}
    Set Test Variable    ${PMAX_BEFORE}
    Set Test Variable    ${PMAX_CHANGED}
    Set Test Variable    ${MAXNUM_BEFORE}
    Set Test Variable    ${MAXNUM_CHANGED}

Step ${index}: Combine Online Modify NRCELLGRP And NRCELL Parameters In Netact
    Log To Console     Step ${index}: Combine Online Modify NRCELLGRP And NRCELL Parameters In Netact
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${name}    MRBTS-${vDU_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${name}    Automation SyVe for MRBTS-${vDU_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${cell_dn}    Fetch From Right    ${CELL_ID}    PLMN-PLMN/
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${cell_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${CELL_ID}   pMax=${PMAX_CHANGED}
    ${cellgrp_dn}    Fetch From Right    ${CELLGROUP_ID}    PLMN-PLMN/
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${cellgrp_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${CELLGROUP_ID}   maxNumOfRrcCGRPSA=${MAXNUM_CHANGED}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check Online Parameter On NetAct
    Log To Console    ${index}
    Wait Until Keyword Succeeds    1m    10s
    ...    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}     dist_name=${CELL_ID}
    ...    pMax=${PMAX_CHANGED}
    Wait Until Keyword Succeeds    1m    10s
    ...    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}    dist_name=${CELLGROUP_ID}
    ...    maxNumOfRrcCGRPSA=${MAXNUM_CHANGED}
    Wait Until Keyword Succeeds    3m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

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

Case Postcondition
    Log To Console    Case Postcondition
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
