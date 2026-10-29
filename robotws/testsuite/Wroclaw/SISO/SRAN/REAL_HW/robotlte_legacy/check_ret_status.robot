*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Keywords ***
Step 1: Check alarms
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  Step 1: Check alarms  console=${TRUE}
    Verify alarms       alias=${alias}

Step 2: Check RET status
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  Step 2: Check RET status  console=${TRUE}
    ${scf_ret_count}    Get number of RET from scf
    ${runtime_ret_list}   admin_im.Query Infomodel   query=get list //ALD_R-*/RETU_R-*     timeout=120    alias=${alias}
    ${runtime_ret_count}  Get length  ${runtime_ret_list}
    Run keyword if  ${scf_ret_count}!=${runtime_ret_count}  Fail  Number of detected RETs is not equal to number of RETs from scf
    Check all RET status  ${runtime_ret_list}

Step 3: Check alarms
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  Step 3: Check alarms  console=${TRUE}
    Verify alarms       alias=${alias}

Get number of RET from scf
    [Arguments]  ${scf_path}=${cfg.scf_file_path}
    ${ret_distName_list}  Create List
    ${ret_list}  Evaluate Xpath  ${scf_path}  .//managedObject[@class="com.nokia.srbts.eqm:RETU"]
    FOR  ${ret}  IN  @{ret_list}
        Append to list  ${ret_distName_list}  ${ret.attrib["distName"]}
    END
    ${ret_count}  Get length  ${ret_distName_list}
    [Return]  ${ret_count}

Check all RET status
    [Arguments]  ${ret_list}
    ${sw_before_CNI_61110}  Run keyword and return status  Should match regexp  ${cfg.release}  SBTS20[A-C]|SBTS21R[1-4]|SBTS22R[1-2]
    FOR  ${ret}  IN  @{ret_list}
        ${administrativeState}  Set variable if  ${sw_before_CNI_61110}  ${ret.stateInfo.administrativeState}  ${ret.administrativeState}
        Should match regexp  ${administrativeState}  (?i)Unlocked
        ${operationalState}  Set variable if  ${sw_before_CNI_61110}  ${ret.stateInfo.operationalState}  ${ret.operationalState}
        Should match regexp  ${operationalState}  (?i)enabled
        ${usageState}  Set variable if  ${sw_before_CNI_61110}  ${ret.stateInfo.usageState}  ${ret.usageState}
        Should match regexp  ${usageState}  (?i)Idle
        ${availabilityStatus}  Set variable if  ${sw_before_CNI_61110}  ${ret.stateInfo.availabilityStatus}  ${ret.availabilityStatus}
        Run keyword if  ${sw_before_CNI_61110}  Should match regexp  ${availabilityStatus}  (?i)Online
        ...  ELSE  Should match regexp  '${availabilityStatus}'  None
    END
