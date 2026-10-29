*** Settings ***
Documentation     Test case for SyVe_CM_Verify_State_Management_For_Different_Modules_LTE3296
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules
  [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19881
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Verify the correct provisioning of different modules states from admin and NetAct
    ...    The main steps performed for the test are:
    ...    -   Step 1: Check Initial BTS State
    ...    -   Step 2: Check Initial Alarms Status from WebEM
    ...    -   Step 3: Check Initial Alarms Status from Netact
    ...    -   Step 4: Upload Configuration Status
    ...    -   Step 5: Check Status Parameters For SMOD RMOD BBMOD CABLINK From Admin
    ...    -   Step 6: Check Status Parameters For SMOD RMOD BBMOD CABLINK From NetAct
    ...    -   Step 7: Lock Radio Modules And Check RMOD Status From Admin
    ...    -   Step 8: Check Locked RMOD Status From NetAct
    ...    -   Step 9: Unlock Radio Modules And Check RMOD State From Admin
    ...    -   Step 10: Check Unlocked RMOD Status From NetAct
    ...    -   Step 11: Check Final Alarms Status from WebEM
    ...    -   Step 12: Check Final Alarms Status from Netact
    ...    -   Step 13: Check Final BTS State
    ...    -   Step 14: Check Final Number and State of Cells and RMs
    ...    Pass criteria: Checked status are correct for all the RMOD,SMOD,BBMOD,CABLINK modules from admin and NetAct.
    ...                   Check status are correct for RMOD before and after module lock from admin and NetAct
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19881 -
    ...    SyVe_CM_Verify_State_Management_For_Different_Modules_LTE3296
    ...    - 13.01.2021 - update according to requirement change.
    ...    - 03.03.2021 - change infomodel check to admin check
    ...    - 04.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 20.01.2022 - Modified by Kang Lixin  - https://jira3.ext.net.nokia.com/browse/TAT-22476 -
    ...    Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    Add logic to ignore checking BBMOD if not exist
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-19881_SyVe_CM_Verify_State_Management_For_Different_Modules_LTE3296.png
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    TC Preparation
    Step 1: Check Initial BTS State
    Step 2: Check Initial Alarms Status from WebEM
    Step 3: Check Initial Alarms Status from Netact
    Step 4: Upload Configuration Status
    Step 5: Check Status Parameters For SMOD RMOD BBMOD From Admin
    Step 6: Check Status Parameters For SMOD RMOD BBMOD CABLINK From NetAct
    Step 7: Lock Radio Modules And Check RMOD Status From Admin
    Step 8: Check Locked RMOD Status From NetAct
    Step 9: UnLock Radio Modules And Check RMOD State From Admin
    Step 10: Check Unlocked RMOD Status From NetAct
    Step 11: Check Final Alarms Status from WebEM
    Step 12: Check Final Alarms Status from Netact
    Step 13: Check Final BTS State
    Step 14: Check Final Number and State of Cells and RMs

TC Preparation
    Log   TC Preparation started     console=True
    Set Test Variable    ${RMOD_path}    //RMOD_R-*
    Set Test Variable    ${SMOD_path}    //CABINET_R-*/SMOD_R-*
    Set Test Variable    ${BBMOD_path}    //CABINET_R-*/BBMOD_R-*
    Set Test Variable    ${CABLINK_path}    //CABLINK_R-*
    Get Runtime Objects ID For SMOD RMOD BBMOD CABLINK Modules
    Generate Runtime Objects DistName For SMOD RMOD BBMOD CABLINK Modules
    ${smod_bbmod_cablink_dn}    Create List
    Append To List    ${smod_dn}    @{bbmod_dn}
    ${smod_bbmod_cablink_dn}    Set Variable    ${smod_dn}
    Append To List    ${smod_bbmod_cablink_dn}    @{cablink_dn}
    Set Test Variable    ${smod_bbmod_cablink_dn}

Step ${index}: Check Status Parameters For SMOD RMOD BBMOD From Admin
    Log    Step ${index}: Check Status Parameters For SMOD RMOD BBMOD From Admin    console=True
    coam.Assert Every    RMOD    ${RMOD_expected_state}
    Run Keyword If    ${bbmod_id}     coam.Assert Every    BBMOD    ${BBMOD_expected_state}
    coam.Assert Every    SMOD    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}

Step ${index}: Check Status Parameters For SMOD RMOD BBMOD CABLINK From NetAct
    Log    Step ${index}: Check Status Parameters For SMOD RMOD BBMOD CABLINK From NetAct    console=True
    ${status_dic}    Create Dictionary
    ${empty_status_dic}    Create Dictionary
    Set To Dictionary     ${status_dic}    operationalState=enabled
    Set To Dictionary     ${empty_status_dic}    availabilityStatus=failed
    FOR    ${dn}    IN    @{smod_bbmod_cablink_dn}
        NetAct Check Actual Configuration Parameters   dist_name=${dn}    ui_values=true    &{status_dic}
        ${status}    ${out_result}     Run Keyword And Ignore Error    Check Actual Configuration Parameters
        ...    dist_name=${dn}    &{empty_status_dic}
        Should Be Equal   '${status}'    'FAIL'
        Should Contain    ${out_result}    No element matching
    END
    Set To Dictionary     ${status_dic}    administrativeState=${_Com_Unlocked_}
    Set To Dictionary     ${status_dic}    usageState=${_Active_}
    FOR    ${dn}    IN    @{rmod_dn}
        NetAct Check Actual Configuration Parameters   dist_name=${dn}    ui_values=true    &{status_dic}
        ${status}    ${out_result}     Run Keyword And Ignore Error     Check Actual Configuration Parameters
        ...    dist_name=${dn}    &{empty_status_dic}
        Should Be Equal   '${status}'    'FAIL'
        Should Contain    ${out_result}    No element matching
    END

Step ${index}: Lock Radio Modules And Check RMOD Status From Admin
    Log    Step ${index}: Lock Radio Modules And Check RMOD Status From Admin    console=True
    FOR    ${RMOD_path}    IN     @{rmod_id}
        coam.Lock    ${RMOD_path}    300s
    END
    Wait until Keyword Succeeds    3x    15s    coam.Assert Every    RMOD
    ...    operationalState=${_Enabled_}, usageState=${_Idle_}, administrativeState=${_Com_Locked_}
    Wait Until Keyword Succeeds  15x  30s  coam.Assert Alarm Inactive  faultId=48

Step ${index}: Check Locked RMOD Status From NetAct
    Log    Step ${index}: Check Locked RMOD Status From NetAct    console=True
    ${status_dic}    Create Dictionary
    ${empty_status_dic}    Create Dictionary
    Set To Dictionary     ${status_dic}    operationalState=enabled
    Set To Dictionary     ${status_dic}    administrativeState=${_Com_Locked_}
    Set To Dictionary     ${status_dic}    usageState=${_Idle_}
    Set To Dictionary     ${empty_status_dic}    availabilityStatus=failed
    FOR    ${dn}    IN    @{rmod_dn}
        Log    ${dn}
        NetAct Check Actual Configuration Parameters   dist_name=${dn}    ui_values=true    &{status_dic}
        ${status}    ${out_result}     Run Keyword And Ignore Error     Check Actual Configuration Parameters
        ...    dist_name=${dn}   &{empty_status_dic}
        Should Be Equal   '${status}'    'FAIL'
        Should Contain    ${out_result}    No element matching
    END

Step ${index}: Unlock Radio Modules And Check RMOD State From Admin
    Log    Step ${index}: Unlock Radio Modules And Check RMOD State From Admin    console=True
    FOR    ${RMOD_path}    IN     @{rmod_id}
        coam.Unlock    ${RMOD_path}     300s
    END
    Wait until Keyword Succeeds    3x    15s
    ...    coam.Assert Every    RMOD       operationalState=${_Enabled_}, usageState=${_Active_}, administrativeState=${_Com_Unlocked_}

Step ${index}: Check Unlocked RMOD Status From NetAct
    Log To Console    Step ${index}: Check Unlocked RMOD Status From NetAct
    ${status_dic}    Create Dictionary
    ${empty_status_dic}    Create Dictionary
    Set To Dictionary     ${status_dic}    operationalState=enabled
    Set To Dictionary     ${status_dic}    administrativeState=${_Com_Unlocked_}
    Set To Dictionary     ${status_dic}    usageState=${_Active_}
    Set To Dictionary     ${empty_status_dic}    availabilityStatus=failed
    FOR    ${dn}    IN    @{rmod_dn}
        Log    ${dn}
        NetAct Check Actual Configuration Parameters   dist_name=${dn}    ui_values=true    &{status_dic}
        ${status}    ${out_result}     Run Keyword And Ignore Error     Check Actual Configuration Parameters
        ...    dist_name=${dn}    &{empty_status_dic}
        Should Be Equal   '${status}'    'FAIL'
        Should Contain    ${out_result}    No element matching
    END

Step ${index}: Check ${when} BTS State
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} Alarms Status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} Alarms Status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload Configuration Status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Check Final Number and State of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Get Runtime Objects ID For SMOD RMOD BBMOD CABLINK Modules
    [Documentation]    Get all the object ids for SMOD_R,RMOD_R,BBMOD_R,CABLINK_R
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ${smod_id}=    coam.Get Ids For All    SMOD
    ${rmod_id}=    coam.Get Ids For All    RMOD
    ${bbmod_id}=    coam.Get Ids For All    BBMOD
    ${cablink_id}=    coam.Get Ids For All    CABLINK
    Set Test Variable    ${smod_id}
    Set Test Variable    ${rmod_id}
    Set Test Variable    ${bbmod_id}
    Set Test Variable    ${cablink_id}

Generate Runtime Objects DistName For SMOD RMOD BBMOD CABLINK Modules
    [Documentation]    Generate all the object distname for SMOD_R,RMOD_R,BBMOD_R,CABLINK_R
    ...    e.g. PLMN/PLMN/MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ${smod_dn}    Create List
    ${rmod_dn}    Create List
    ${bbmod_dn}    Create List
    ${cablink_dn}    Create List
    ${split_str}    Set Variable    /EQM_R
    FOR    ${id}    IN     @{smod_id}
        ${smod}    Fetch From Right    ${id}    ${split_str}
        Append To List    ${smod_dn}    ${MRBTS_DN}${split_str}${smod}
    END
    FOR    ${id}    IN     @{rmod_id}
        ${rmod}    Fetch From Right    ${id}    ${split_str}
        Append To List    ${rmod_dn}    ${MRBTS_DN}${split_str}${rmod}
    END
    FOR    ${id}    IN     @{bbmod_id}
        ${bbmod}    Fetch From Right    ${id}    ${split_str}
        Append To List    ${bbmod_dn}    ${MRBTS_DN}${split_str}${bbmod}
    END
    FOR    ${id}    IN     @{cablink_id}
        ${cablink}    Fetch From Right    ${id}    ${split_str}
        Append To List    ${cablink_dn}    ${MRBTS_DN}${split_str}${cablink}
    END
    Set Test Variable    ${smod_dn}
    Set Test Variable    ${rmod_dn}
    Set Test Variable    ${bbmod_dn}
    Set Test Variable    ${cablink_dn}

Particular Teardown
    FOR    ${RMOD_path}    IN     @{rmod_id}
        ${status}    ${output_result}    Run Keyword And Ignore Error    coam.Assert    RMOD    ${RMOD_path}    administrativeState=${_Com_Locked_}
        Run Keyword If    '${status}'=='PASS'    coam.Unlock    ${RMOD_path}     120s
    END
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown