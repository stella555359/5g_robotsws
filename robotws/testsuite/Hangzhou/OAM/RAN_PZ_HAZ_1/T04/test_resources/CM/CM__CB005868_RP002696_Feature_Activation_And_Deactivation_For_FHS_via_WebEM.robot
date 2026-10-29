*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${NEED_RECOVER}    ${False}

*** Keywords ***
CM__CB005868_RP002696_Feature_Activation_And_Deactivation_For_FHS_via_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:Automated__CM__Feature_activation_and_deactivation_for_FHS_via_WebEM_CB005868_RP002696.robot
    ...     Verify after feature(actSecurityForFHS=true) activation, need manual reset FHS(MDCD),
    ...     and log on MDCD check IPsec tunnel establishment. During deactivation, MDCD will reset autonomously, IPsec tunnel not establishment.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.07.2023 - Commit to robotws
    ...  - 23.09.2024 - Change from WEBUI case to API case due to CB012236 Nokia rebranding in WebEM and CuDo
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Active Feature RP002696 For FHS And Check Result
    Step 2: Reset Relative MO And Check Action
    Step 3: Deactive Feature RP002696 For FHS And Check Result

CaseSetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}

CaseTearDown
    Log    Case Special Teardown    console=${True}
    Run Keyword If    ${NEED_RECOVER}    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

Get Parameters From FHS Via SSH
    ${param_dic}    Create Dictionary
    ${FHS_params}    coam.get_managed_objects    FHS_L
    ${ip}    Set Variable    ${FHS_params[0]["parameters"]["ipAddress"]}
    ${index}    Establish SSH to SBTS    host_ip=${MPLANE_IP}    alias=monkey
    #if FHS connect to master, no need connect to fct-4a
    ${output}    Execute CMD Via SSH connection    ssh toor4nsn@fct-4a    assword\|yes/no
    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    assword
    ${output}    Execute CMD Via SSH connection    oZPS0POrRieRtu    root\@fct-4a
    #${is_pass}    ${output}    Run Keyword And Ignore Error    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt | grep "MDCD\\|MDEA"    MD
    #${output}    Run Keyword If    '${is_pass}'=='FAIL'    Change To Right CABINET
    #...    ELSE    Set Variable    ${output}
    #${ip}    Should Match Regexp    ${output}    \\d+\\.\\d+\\.\\d+\\.\\d+
    ${output}    Execute CMD Via SSH connection    lxc-ls --active    0x\\d018
    ${id_FHNET}    Should Match Regexp    ${output}    0x\\d018
    ${cmd_to_FHNET}    Set Variable    lxc-attach -n ${id_FHNET}
    Execute CMD Via SSH connection    ${cmd_to_FHNET}    root\@FHNET
    ${output}    Execute CMD Via SSH connection    rm /user/toor4nsn/.ssh/known_hosts    root\@FHNET
    ${output}    Execute CMD Via SSH connection    ssh serviceuser@${ip}    password\|yes/no    console_delay=1s
    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    password
    ${output}    Execute CMD Via SSH connection    Pl(FzaYj5~c5;q    serviceuser\@fhs
    ${output}    Execute CMD Via SSH connection    su toor4nsn    Password
    ${output}    Execute CMD Via SSH connection    oZPS0POrRieRtu    \#
    #Change from SBTS23R2_ENB_9999_230104_000010, command ipsec replaced by swanctl -l and output replaced by ESTABLISHED
    ${output}    Execute CMD Via SSH connection    echo ++++++;swanctl -l;echo --------    \--------
    Comment    ${output}    Execute CMD Via SSH connection    echo ++++++;ipsec statusall;echo ++++++    \#
    ${output}    Set Variable    ${output.split('++++++')[1].strip()}
    Set To Dictionary    ${param_dic}    ipsec    ${output}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${param_dic}

Get Case Relative Runtime MO
    ${fhs_MO}    ute_admin_infomodel.query_infomodel    get object //EQM_R-*//FHS_R-*
    ${link}    ute_admin_infomodel.query_infomodel    get object //EQM_R-*//CABLINK_R-* is [firstEndpointDN="${fhs_MO['dist_name']}"]
    ${RMOD_MO}    ute_admin_infomodel.query_infomodel    get object ${link['secondEndpointDN']}
    ${All_RMOD_MO}    ute_admin_infomodel.query_infomodel    get list //EQM_R-*//RMOD_R-*
    ${All_g_cells}    Infomodel Get Objects Parameter    //GNCEL_R-*    dist_name    ${True}
    ${All_l_cells}    Infomodel Get Objects Parameter    //LNCEL_R-*    dist_name    ${True}
    ${All_w_cells}    Infomodel Get Objects Parameter    //WNCEL_R-*    dist_name    ${True}
    ${All_nr_cells}    Infomodel Get Objects Parameter    //NRCELL_R-*    dist_name    ${True}
    ${ALL_CELL_DN}    Combine Lists    ${All_g_cells}    ${All_l_cells}    ${All_w_cells}    ${All_nr_cells}
    ${RELATE_CELLS}    Create List
    FOR    ${cell_id}    IN    @{RMOD_MO['activeGsmCellsList']}
        ${tmp_mo}    ute_admin_infomodel.query_infomodel    get object //GNCEL_CONF_M-${cell_id}/GNCEL_R-1
        Append To List    ${RELATE_CELLS}    ${tmp_mo['dist_name']}
        Remove Values From List    ${ALL_CELL_DN}    ${tmp_mo['dist_name']}
    END
    FOR    ${cell_id}    IN    @{RMOD_MO['activeLteCellsList']}
        ${tmp_mo}    ute_admin_infomodel.query_infomodel    get object //LNCEL_R-${cell_id}
        Append To List    ${RELATE_CELLS}    ${tmp_mo['dist_name']}
        Remove Values From List    ${ALL_CELL_DN}    ${tmp_mo['dist_name']}
    END
    FOR    ${cell_id}    IN    @{RMOD_MO['activeNrCellsList']}
        ${tmp_mo}    ute_admin_infomodel.query_infomodel    get object //NRCELL_R-${cell_id}
        Append To List    ${RELATE_CELLS}    ${tmp_mo['dist_name']}
        Remove Values From List    ${ALL_CELL_DN}    ${tmp_mo['dist_name']}
    END
    FOR    ${cell_id}    IN    @{RMOD_MO['activeWcdmaCellsList']}
        ${tmp_mo}    ute_admin_infomodel.query_infomodel    get object //WRCEL_R-${cell_id}
        Append To List    ${RELATE_CELLS}    ${tmp_mo['dist_name']}
        Remove Values From List    ${ALL_CELL_DN}    ${tmp_mo['dist_name']}
    END
    ${IRRESPECTIVE_RMOD_DN}    Create List
    FOR    ${MO}    IN    @{All_RMOD_MO}
        Append To List    ${IRRESPECTIVE_RMOD_DN}    ${MO['dist_name']}
    END
    Remove Values From List    ${IRRESPECTIVE_RMOD_DN}    ${RMOD_MO['dist_name']}
    Set Test Variable    ${IRRESPECTIVE_RMOD_DN}
    Set Test Variable    ${RMOD_MO_DN}    ${RMOD_MO['dist_name']}
    Set Test Variable    ${FHS_MO_DN}    ${fhs_MO['dist_name']}
    Set Test Variable    ${RELATE_CELLS}
    Set Test Variable    ${IRRESPECTIVE_CELL_DN}    ${ALL_CELL_DN}
    Log List    ${IRRESPECTIVE_CELL_DN}
    Log List    ${RELATE_CELLS}
    Log List    ${IRRESPECTIVE_RMOD_DN}

Check MO Actions In IMs File
    [Arguments]    ${ims_file}
    Log    ${ims_file}
    FOR    ${RMOD}    IN    @{IRRESPECTIVE_RMOD_DN}
        Add expected ims2 event    change ${RMOD} [operationalState: regex"[Ee]nabled" -> *]
        Run keyword and expect error    *    Validate ims2
    END
    FOR    ${CELL}    IN    @{IRRESPECTIVE_CELL_DN}
        Add expected ims2 event    change ${CELL} [operationalState: regex"[Ee]nabled" -> *]
        Run keyword and expect error    *    Validate ims2
    END

Step ${index}: Active Feature RP002696 For FHS And Check Result
    LOG    Step ${index}: Active Feature RP002696 For FHS And Check Result    console=${True}
    Get Case Relative Runtime MO
    Save IMS and Restart IMS model    ims_before_step_${index}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actSecurityForFHS    operation=update    value=true
    coam.reset_unit    dist_name=${FHS_MO_DN}  timeout=600
    ute_admin_infomodel.wait_for_infomodel_event    change ${FHS_MO_DN} [operationalState: * -> regex"[Dd]isabled"]    300
    ute_admin_infomodel.wait_for_infomodel_event    change ${FHS_MO_DN} [operationalState: * -> regex"[Ee]nabled"]    600
#    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_IND-* [targetDN="${FHS_MO_DN}"]
#    ${object}    ute_admin_infomodel.query_infomodel    get object //RESET_IND-* is [targetDN="${FHS_MO_DN}"]
#    ute_admin_infomodel.wait_for_infomodel_event    remove ${object['dist_name']}/RESULT-1 [status=Succeeded]    600
    Wait Until Keyword Succeeds    20 mins    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    ${dic_p}    Get Parameters From FHS Via SSH
    #Change from SBTS23R2_ENB_9999_230104_000010, command ipsec replaced by swanctl -l and output replaced by ESTABLISHED
    Should Contain    ${dic_p["ipsec"]}    ESTABLISHED
    Comment    Should Contain    ${dic_p["ipsec"]}    Security Associations
    Save IMS and Restart IMS model    ims_after_step_${index}
    Check MO Actions In IMs File    ${BTS Files}/IM/ims_after_step_${index}.ims2

Step ${index}: Deactive Feature RP002696 For FHS And Check Result
    LOG    Step ${index}: Deactive Feature RP002696 For FHS And Check Result    console=${True}
    Get Case Relative Runtime MO
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actSecurityForFHS    operation=update    value=false
    ute_admin_infomodel.wait_for_infomodel_event    change ${FHS_MO_DN} [operationalState: * -> regex"[Dd]isabled"]    300
    ute_admin_infomodel.wait_for_infomodel_event    change ${FHS_MO_DN} [operationalState: * -> regex"[Ee]nabled"]    600
    Wait Until Keyword Succeeds    20 mins    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Set Test Variable    ${NEED_RECOVER}    ${False}
    ${dic_p}    Get Parameters From FHS Via SSH
    #Change from SBTS23R2_ENB_9999_230104_000010, command ipsec replaced by swanctl -l and output replaced by ESTABLISHED
    Should Not Contain    ${dic_p["ipsec"]}    ESTABLISHED
    Comment    Should Be Equal As Strings    ${dic_p["ipsec"].strip()}    ${EMPTY}
    Save IMS and Restart IMS model    ims_after_step_${index}
    Check MO Actions In IMs File    ${BTS Files}/IM/ims_after_step_${index}.ims2

Step ${index}: Reset Relative MO And Check Action
    LOG    Step ${index}: Reset Relative MO And Check Action    console=${True}
    Get Case Relative Runtime MO
    Save IMS and Restart IMS model    ims_before_step_${index}
    coam.reset_unit    dist_name=${RMOD_MO_DN}  timeout=600
    ute_admin_infomodel.wait_for_infomodel_event    change ${RMOD_MO_DN} [operationalState: * -> regex"[Dd]isabled"]    300
    ute_admin_infomodel.wait_for_infomodel_event    change ${RMOD_MO_DN} [operationalState: * -> regex"[Ee]nabled"]    600
#    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_IND-* [targetDN="${RMOD_MO_DN}"]
#    ${object}    ute_admin_infomodel.query_infomodel    get object //RESET_IND-* is [targetDN="${RMOD_MO_DN}"]
#    ute_admin_infomodel.wait_for_infomodel_event    remove ${object['dist_name']}/RESULT-1 [status=Succeeded]    600
    Wait Until Keyword Succeeds    20 mins    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Save IMS and Restart IMS model    ims_after_step_${index}
    Check MO Actions In IMs File    ${BTS Files}/IM/ims_after_step_${index}.ims2
    ${count}    Get Length    ${RELATE_CELLS}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${select_cell}    Set Variable    ${RELATE_CELLS[${index}]}
    coam.block_cell    ${select_cell}
    coam.assert     LNCEL    ${select_cell}    ${cells_LTE_blocked_state}    timeout=60s
    coam.unblock_cell    ${select_cell}
    coam.assert     LNCEL    ${select_cell}    ${cells_LTE_expected_states}    timeout=60s

Change To Right CABINET
    ${output}    Execute CMD Via SSH connection    ssh toor4nsn@fct-4a    assword\|yes/no
    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    assword
    ${output}    Execute CMD Via SSH connection    oZPS0POrRieRtu    root\@fct-4a
    ${output}    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt | grep "MDCD\\|MDEA"    MD
    [Return]    ${output}