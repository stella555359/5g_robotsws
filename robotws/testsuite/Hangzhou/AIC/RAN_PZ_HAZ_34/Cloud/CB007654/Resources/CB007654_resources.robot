*** Settings ***
Library           Collections
Library           json
Library           OperatingSystem
Library           Process
Library           String
Library           taf.config.scf                        WITH NAME    scf
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.selenium.gnb.oam.coam.cu          WITH NAME    scu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.nms.nom                           WITH NAME    nom_rest
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/utils.py
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/global_variables.py
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_fm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_fm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/variables.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_pre_post_condition.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_setup_teardown.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_trs_conn.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vran_others.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/nom_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_testline_configuration.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_state.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_pm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_testline_configuration.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_state.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_pm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_cloud_deployment.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/nom_testline_configuration.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_log.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_log_other.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/kw_to_be_optimized.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources_new.robot

*** Keywords ***
#Case Setup
#    vDU Verify All Cells Status Should Be Onair
#    VDU Rest Login
#    ${scf_path}  Get A Directory  scf
#    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
#    set test variable    ${scf_file_with_fullpath}
#    scf.Load_Scf  file_path=${scf_file_with_fullpath}
#    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
#    set test variable    ${VDU_CONF}
#    [Teardown]  VDU Rest Logout

Set miNrCellAvailability Value at vDU
    [Arguments]    ${set_value}
    Log To Console   set miNrCellAvailability to ${set_value}
    ${distname}    Set Variable   MRBTS-${testline_id}/NRBTS-${testline_id}/NRPMRNL-1
    @{para_list}    Create list    miNrCellAvailability
    @{value_list}    Create list    ${set_value}
    ${output}=    Run Keyword And Return Status    vDU Modify Parameters Online After Checking    para_list=${para_list}
    ...    value_list=${value_list}    mo=${distname}

Set actAperCsi Value at vDU
    [Arguments]    ${set_value}
    Log To Console   set actAperCsi to ${set_value}
    ${distname}    Set Variable   MRBTS-${testline_id}/NRBTS-${testline_id}/NRCELL-1
    @{para_list}    Create list    actAperCsi
    @{value_list}    Create list    ${set_value}
    ${output}=    Run Keyword And Return Status    vDU Modify Parameters Online After Checking    para_list=${para_list}
    ...    value_list=${value_list}    mo=${distname}

Trigger NRCELL object locking by parameter at vDU
    Log To Console   Trigger NRCELL object locking by parameter actAperCsi
    ${distname}    Set Variable   MRBTS-${testline_id}/NRBTS-${testline_id}/NRCELL-1
    ${actAperCsi_value}    Get VDU Parameter Value Online    mo_dn=${distname}    para_name=actAperCsi
    Run Keyword If  '${actAperCsi_value}'=='false'    Set actAperCsi Value at vDU   set_value=true
    ...    ELSE    Set actAperCsi Value at vDU    set_value=false
    sleep    10s
    wait until keyword succeeds     10min    60s     vDU Verify All Cells Status Should Be Onair

Check M55601 PM counter value at vDU
    [Documentation]    *****************
    ...    check PM counter when cell is not on air and miNrCellAvailability=5min
    ...    M55601C00001=300  0<M55601C00002<300  0<M55601C01001<300  0<M55601C01003<300
    ...    M55601C01002=1    M55601C01004=1
    ...    *****************
    [Arguments]    ${counter_id}
    Log To Console   check ${counter_id} value
    ${dist_name}    Set Variable    MRBTS-${testline_id}/NRBTS-${testline_id}/NRCELL-1
    ${counter_value}    vDU Get PM Counter Latest Values    counter_id=${counter_id}   dimension_dist_name=${dist_name}
    Run Keyword If    '${counter_id}'=='M55601C00001'    Should Be True     ${counter_value}==300
    ...    ELSE IF   '${counter_id}'=='M55601C01002' or '${counter_id}'=='M55601C01004'   Should Be True   ${counter_value}==1
    ...    ELSE    Should Be True    0<${counter_value}<=300
    Log To Console    ${counter_id} counter is ${counter_value}

Check counters by object_locking at vDU
    vDU Rest Login
    log to console     check M55601C01001 & M55601C01002 by object_locking counters at DU side
#    OAM Precondition Cell Should Be Onair
    ${mi_value}    Get VDU Parameter Value Online    mo_dn=MRBTS-${testline_id}/NRBTS-${testline_id}/NRPMRNL-1    para_name=miNrCellAvailability
    run keyword if  '${mi_value}'!='5min'    Set miNrCellAvailability Value at vDU   set_value=5min
    sleep    5s
    Trigger NRCELL object locking by parameter at vDU
    log to console     wait 270s to get latest PM for CB007654-D_003
    sleep    270s
    Check M55601 PM counter value at vDU    M55601C01001
    Check M55601 PM counter value at vDU    M55601C01002
    [Teardown]   Run Keyword And Ignore Error    vDU Rest Logout

Check counters by object_locking at vCU
    CU Rest Login
    log to console     check M55601C01001 & M55601C01002 by object_locking counters at CU side
    CU Login
    ${mi_value}    CU Get Online Parameter Value    MRBTS-${testline_id}/NRBTS-${testline_id}/NRPMRNL-1    miNrCellAvailability
    run keyword if  '${mi_value}'!='5min'    Set miNrCellAvailability Value at vCU   set_value=5min
    sleep    5s
    Trigger NRCELL object locking by parameter at vCU
    log to console     wait 270s to get latest PM for CB007654-D_003
    sleep    270s
    Check M55601 PM counter value at vCU    M55601C01001
    Check M55601 PM counter value at vCU    M55601C01002
    [Teardown]   Run Keyword And Ignore Error    CU Rest Logout

Check M55601 PM counter value at vCU
    [Documentation]    *****************
    ...    check PM counter when cell is not on air and miNrCellAvailability=5min
    ...    M55601C00001=300, M55601C00002<300, M55601C01001-4>0
    ...    *****************
    [Arguments]    ${counter_id}
    Log To Console   check ${counter_id} value
    ${dist_name}    Set Variable    MRBTS-${testline_id}/NRBTS-${testline_id}/NRCELL-1
    ${counter_value}    Get CU Counter   ${counter_id}   55601   dimension_dist_name=${dist_name}
    run keyword if    '${counter_id}'=='M55601C00001'    Should Be True     ${counter_value}==300
    ...    ELSE IF   '${counter_id}'=='M55601C01002' or '${counter_id}'=='M55601C01004'   Should Be True   ${counter_value}==1
    ...    ELSE    Should Be True    0<${counter_value}<=300
    Log To Console    ${counter_id} counter is ${counter_value}

Trigger NRCELL object locking by parameter at vCU
    Log To Console   Trigger NRCELL object locking by parameter actAperCsi
    ${distname}    Set Variable   MRBTS-${testline_id}/NRBTS-${testline_id}/NRCELL-1
    ${actAperCsi_value}    CU Get Online Parameter Value    ${distname}    parameter_path=actAperCsi
    run keyword if  '${actAperCsi_value}'=='false'    Set actAperCsi Value at vCU    set_value=true
    ...    ELSE    Set actAperCsi Value at vCU    set_value=false
    sleep    10s
    wait until keyword succeeds     1min    10s     CU Verify All Cells Status Are Onair

Set miNrCellAvailability Value at vCU
    [Arguments]    ${set_value}
    Log To Console   set miNrCellAvailability to ${set_value}
    ${distname}    Set Variable   MRBTS-${testline_id}/NRBTS-${testline_id}/NRPMRNL-1
    &{para_dict}    Create Dictionary    operation_type=replace   parameter_path=/miNrCellAvailability    value=${set_value}
    @{para_list}    Create List  ${para_dict}
    CU Login
    ${output}=    Run Keyword And Return Status    CU Online Change Single Mo Parameters via rest    para_list=${para_list}
    ...    mo_dn=${distname}
    CU Logout

Set actAperCsi Value at vCU
    [Arguments]    ${set_value}
    Log To Console   set actAperCsi to ${set_value}
    ${distname}    Set Variable   MRBTS-${testline_id}/NRBTS-${testline_id}/NRCELL-1
    &{para_dict}    Create Dictionary    operation_type=replace   parameter_path=/actAperCsi    value=${set_value}
    @{para_list}    Create List  ${para_dict}
    CU Login
    ${output}=    Run Keyword And Return Status    CU Online Change Single Mo Parameters via rest    para_list=${para_list}
    ...    mo_dn=${distname}
    CU Logout

#   ...............   following keywords are for CB007654-D_006   ..............
Check counters by locking cell at vCU
    [Documentation]    *****************
    ...    check PM counter when cell is locked at vCU side and miNrCellAvailability=5min
    ...    M55601C00001=300, M55601C00002=0, M55601C01001-4>0
    ...    *****************
    log to console     check M55601C01003 & M55601C01004 by locking cell at CU side
    vDU Verify All Cells Status Should Be Onair
    vDU Rest Login
    ${mi_value}    Get VDU Parameter Value Online    mo_dn=MRBTS-${testline_id}/NRBTS-${testline_id}/NRPMRNL-1    para_name=miNrCellAvailability
    run keyword if  '${mi_value}'!='5min'    Set miNrCellAvailability Value at vDU   set_value=5min
    sleep    5s
    Trigger NRCELL lock unlock at vCU
    log to console     wait 180s to get latest PM for CB007654-D_006
    sleep    180s
    Check M55601 PM counter value at vDU    M55601C01003
    Check M55601 PM counter value at vDU    M55601C01004
    [Teardown]   Run Keyword And Ignore Error    vDU Rest Logout

Trigger NRCELL lock unlock at vCU
    Log To Console   Trigger NRCELL lock unlock at vCU
    ${cells_list}    CU Get Cells ID list
    set test variable    ${cells_list}
    CU Lock Specified Cell    ${cells_list[0]}
    sleep    1min
    CU Unock Specified Cell    ${cells_list[0]}
    wait until keyword succeeds     1min    10s     CU Verify All Cells Status Are Onair

Check counters by locking cell at vDU
    [Documentation]    *****************
    ...    check PM counter when cell is locked at vCU side and miNrCellAvailability=5min
    ...    M55601C00001=300, M55601C00002=0, M55601C01001-4>0
    ...    *****************
    log to console     check M55601C01003 & M55601C01004 by locking cell at CU side
    vDU Verify All Cells Status Should Be Onair
    vDU Rest Login
    ${mi_value}    Get VDU Parameter Value Online    mo_dn=MRBTS-${testline_id}/NRBTS-${testline_id}/NRPMRNL-1    para_name=miNrCellAvailability
    run keyword if  '${mi_value}'!='5min'    Set miNrCellAvailability Value at vDU   set_value=5min
    sleep    5s
    Trigger NRCELL lock unlock at vDU
    log to console     wait 270s to get latest PM for CB007654-D_006
    sleep    270s
    Check M55601 PM counter value at vCU    M55601C01003
    Check M55601 PM counter value at vCU    M55601C01004
    [Teardown]   Run Keyword And Ignore Error    vDU Rest Logout

Trigger NRCELL lock unlock at vDU
    Log To Console   Trigger NRCELL block unblock at vDU
    VDU Block Specify One Cell By REST
    sleep    1min
    VDU Unblock Specify One Cell By REST
    wait until keyword succeeds     1min    10s     vDU Verify All Cells Status Should Be Onair
