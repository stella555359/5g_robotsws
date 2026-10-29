*** Settings ***
Documentation
...   regression common keywords

Resource     ../../resources/preconditions.robot
Resource     ../../resources/btslog_collecting.robot
Resource     ../resources/attach_verification.robot
Resource     ../../resources/pm_counters/pm_counters.robot
Resource     taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot
Library      ../../VRF_WRO2_T07/resources/testline_preparation.py
Library      ./python_functions.py
Library      ../../resources/pm_counters.py
Library      testsuite/Wroclaw/RRM/resources/csv4all_helpers.py
Library      DateTime


*** Variables ***
# taf.rfrl.uuf4all - 2.0.70
${VM_USERNAME}   ute
${VM_PASSWORD}   ute


*** Keywords ***
Set Sector for Testing
    [Arguments]    ${sector}=SECTOR_1  ${att_id}=1
    Set Attenuation  0dB  ${ATTENUATOR['${sector}']['ports']}  confirm=${TRUE}  attenuator_id=${att_id}
    ${sector_to_attenuate}   Set Variable If   '${sector}' == 'SECTOR_1'   SECTOR_2  SECTOR_1
    Set Attenuation  90dB  ${ATTENUATOR['${sector_to_attenuate}']['ports']}  confirm=${TRUE}  attenuator_id=${att_id}
    Set Suite Variable   ${sector_no}   ${sector[-1]}


Start and Initialize Attenuator
    Initialise Attenuator
    Set Attenuation  0dB  confirm=${TRUE}


Collect and Verify Syslog
    Collect Syslog
    Run Keyword If Test Passed    Find Suspicious Prints In Passed Test
    Run    zip -j ${OUTPUT DIR}/${TESTNAME}/syslog ${OUTPUT DIR}/${TESTNAME}/syslog.log
    Run    rm ${OUTPUT DIR}/${TESTNAME}/syslog.log


# ********************* to remove *********************

Prepare Testline Configuration
    [Arguments]    ${scf_tag}=SCF_DEFAULT    ${custom_swconfig_flags}=${None}
    ${scf_path}=    Prepare Testline To OnAir State    scf_tag=${scf_tag}    custom_swconfig_flags=${custom_swconfig_flags}
    Set Global Variables
    Check SCF File Validation   ${scf_path}


Check OnAir BTS Status
    [Documentation]   Check if all cells are in OnAir state. If failed, BTS is reseting and check cells' status again.
    ${passed}   Run Keyword And Return Status   webUI_operations.Wait For All Cells On Air State
    Run Keyword If    not ${passed}    webUI_operations.Wait For All Cells On Air State


Check SCF File Validation
    [Arguments]   ${scf}
    ${validation_result}   Run Keyword And Ignore Error   SCF Validation   scf_file=${scf}
    Run Keyword If   '@{validation_result}[0]' == 'PASS'
    ...      Log To Console   SCF is validated succesfully
    ...   ELSE
    ...      Log To Console   \n Find validation errors below: \n @{validation result}[1]


Set X2 Interface Name For NSA Technology
    ${cell_deployment_type}   webUI_operations.Get Parameter Value From Scf   parameter_abbreviation=cellDepType
    Run Keyword If   '${cell_deployment_type}' == 'NSA'   _Get X2 Name


_Get X2 Name
    Run Keyword If   '${smod_name}' == 'ASIK'
    ...               Set Global Variable   ${x2_interface}   fp0.${tl.gnbs[0].cu.x2c.vlan_id}
    Run Keyword If   '${smod_name}' == 'ASIB'
    ...               Set Global Variable   ${x2_interface}   br1.${tl.gnbs[0].cu.x2c.vlan_id}


Set UTE Library For UE If Needed
    Run Keyword If   ${tl.ues}
    ...   _Set UE Library


_Set UE Library
    Run Keyword If   '${tl.ues[0].__class__.__name__}' == 'Android'
    ...   Set Library Search Order  taf.ue
    ...   ELSE
    ...   Set Library Search Order  ute_ue
