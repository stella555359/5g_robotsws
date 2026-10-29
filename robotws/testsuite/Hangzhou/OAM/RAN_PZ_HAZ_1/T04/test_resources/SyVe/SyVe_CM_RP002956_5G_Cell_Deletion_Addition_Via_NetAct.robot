*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21064
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision NR cell delete and add from NetAct based on prepare a delete NRCEL-1 plan
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Import the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check final BTS state
    ...    - Check NRCELL be deleted
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check NRCELL be added
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add NRCEL provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-21064
    ...    - SyVe_CM_Verify_5G_Cell_Deletion_Addition_Via_NetAct_RP002956_5G
    ...    - 11.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking. Also add logic to check action in Step 6&9
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    change the value of gloable variable ${plan_path} from .csv to .xml
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 15.12.2022 - Modified by YuaGao
    ...    - Update case add sCCNumber value check for BOAM_ET_5GC001196-E-a_5GC000769-A-a
    ...    - 19.09.2023 - Modified by Kang Lixin - Refactor case to generate plan instead of import plan
    ...    - 14.12.2023 - Modified by Kang Lixin - Remove sCCNumber value check for CB010672
    ...    - 27.06.2025 - Modified by Kang Lixin - Optimize to use common kw Create Plan To Delete NRCELL Via NetAct
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    image:: http://tatools.emea.nsn-net.net/static/hran_doc/
    ...    testsuite/SYVE/TAT-21064_SyVe_CM_Verify_5G_Cell_Deletion_Addition_Via_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Provision plan to delete NRCELL
    Step 6: Check final BTS state
    Step 7: Check NRCELL be deleted
    Step 8: Provision the backup plan
    Step 9: Check final alarms status from WebEM
    Step 10: Check final alarms status from Netact
    Step 11: Check final BTS state
    Step 12: Check NRCELL be added
    Step 13: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${dic_bts_infor}    coam.Get Bts Info
    ${MRBTS_ID}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${NRCELL_list}    ${cell_list['cells']['nr']}
    ${NRBTS_RT_cell_num_initial}    Evaluate    len(${NRCELL_list})
    Set Test Variable    ${NRBTS_RT_cell_num_initial}
    ${selected_cell}    Evaluate    random.choice(${NRCELL_list})    modules=random, sys
    Set Test Variable    ${selected_nrcell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_nrcell_R}    ${selected_cell['id']['internal']}
    ${ALL_NRCELL_list}    Create List
    ${ALL_NRCELL_ID_list}    Create List
    FOR    ${item}    IN    @{NRCELL_list}
        ${nrcell_R}    Set Variable    ${item['id']['internal']}
        Append To List    ${ALL_NRCELL_list}    ${nrcell_R}
    END
    ${selected_nrcell_id}    Fetch From Right    ${selected_nrcell_DN}    -
    Set Test Variable    ${selected_nrcell_id}
    ${Initial_NRCELL_list_R}    Copy List    ${ALL_NRCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_NRCELL_list}    ${selected_nrcell_R}
    Set Test Variable    ${Other_NRCELL_list}    ${ALL_NRCELL_list}
    Set Test Variable    ${Initial_NRCELL_list_R}
    ${list_nrDU_infor}    Pop From Dictionary    ${dic_bts_infor}    nrDU
    Should Be Equal As Integers    ${list_nrDU_infor.__len__()}    ${1}
    ...    It must be one and only one NRDU for this test case.
    Set Test Variable    ${NRDU_NAME}    ${list_nrDU_infor[0]['id']['configuration']}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Provision plan to delete NRCELL
    Log    Step ${index}: Provision plan to delete NRCELL    console=True
    ${name}    Create Plan To Delete NRCELL Via NetAct    ${selected_nrcell_DN}
    Set Test Variable    ${name}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name}_backup -DN ${MRBTS_DN} -createBackupPlan false
    ${cmd2}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check NRCELL be deleted
    Log    Step ${index}: Check NRCELL be deleted    console=True
    ${after_deleted_nrcells}    coam.Get Ids For All    NRCEL
    Set Test Variable    ${after_deleted_nrcells}
    ${deleted_nrcells}    Copy List    ${Initial_NRCELL_list_R}
    Set Test Variable    ${deleted_nrcells}
    Remove Values From List    ${deleted_nrcells}    @{after_deleted_nrcells}
    Sort List    ${deleted_nrcells}
    ${after_deleted_nrcells_count}    Evaluate    len(${after_deleted_nrcells})
    Should Be Equal As Integers    ${NRBTS_RT_cell_num_initial}    ${after_deleted_nrcells_count+1}

Step ${index}: Check NRCELL be added
    Log    Step ${index}: Check NRCELL be added    console=True
    ${after_added_nrcells}    coam.Get Ids For All    NRCEL
    ${added_nrcells}    Copy List    ${after_added_nrcells}
    Remove Values From List    ${added_nrcells}    @{after_deleted_nrcells}
    Sort List    ${added_nrcells}
    Lists Should Be Equal    ${deleted_nrcells}    ${added_nrcells}
    ${after_added_nrcells_count}    Evaluate    len(${after_added_nrcells})
    Should Be Equal As Integers    ${NRBTS_RT_cell_num_initial}    ${after_added_nrcells_count}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check Other Cells Onair
    FOR    ${item}    IN    @{Other_NRCELL_list}
        coam.Assert    NRCEL    ${item}    ${cells_NR_expected_state}    timeout=45s
    END
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every
    ...    GNCEL    ${cells_GSM_expected_state}    timeout=45s
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every
    ...    WNCEL    ${cells_WCDMA_expected_state}    timeout=45s
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every
    ...    LNCEL    ${cells_LTE_expected_state}    timeout=45s
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${final_nrcells}    coam.Get Ids For All    NRCEL
    ${final_nrcells_count}    Evaluate    len(${final_nrcells})
    Run Keyword If    ${NRBTS_RT_cell_num_initial}!=${0} and ${NRBTS_RT_cell_num_initial}!=${final_nrcells_count}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
