#-----------------------------------------------------------------------
#
# File: vm_cbam_resources.robot
#
# Set of keywords related to CBAM management.
#
# These robotframework keywords uses python functions from
# 1) taf.cloud.cbam library (referenced with cbam word) and
# 2) vm_cbam_resources.py local file (referenced with cbam_utils word).
#
#-----------------------------------------------------------------------


*** Settings ***
Documentation    This is common keywords for CB6773 related cases
...              Please do not modify the file without notification to author
...              Author: zhao nana
...              Contact: nana.zhao@nokia-sbell.com
...              Squard: MMW2
#Suite Setup       Cbam_Common_Setup
#Suite Teardown    Cbam_Common_Teardown

Library           Collections
Library           OperatingSystem
Library           BuiltIn
Library           String

Library           taf.cloud.cbam    WITH NAME    cbam
Library           taf.transport.ssh             WITH NAME    csn
Library           taf.gnb.oam.commissioning  WITH NAME  commissioning
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library    ${CURDIR}/vm_cbam_resources.py       WITH NAME    cbam_utils

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    ${CURDIR}/CB006773_variable.robot



*** Variables ***

*** Keywords ***

Cbam_Common_Setup
    [Documentation]    Author: zhao nana
    ...                This keyword is to prepare test case for cbam

    Download and extract addons
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    cbam.post_catalog_info    path=${flavor_package_path}
    cbam.post_catalog_info    path=${net_package_path}
    cbam.post_catalog_info    path=${redundant_package_path}

Cbam_Common_Teardown
    [Documentation]    Author: zhao nana
    ...                This keyword is to restore env  for cbam TA

    Delete addons
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    run keyword and ignore error    cbam.delete_catalog_info    vnfd_id=${flavor_vnfd_id}
    run keyword and ignore error    cbam.delete_catalog_info    vnfd_id=${net_vnfd_id}
    run keyword and ignore error    cbam.delete_catalog_info    vnfd_id=${vnf_vnfd_id}
    
Download and extract addons
    [Documentation]    Author: zhao nana
    ...                This keyword is to download addons
    
    Run    cd ${download_path}; wget ${package_link}/${version}/Addons-${version}.txz; mkdir Addons;
    Run    cd ${download_path}; tar Jxvf Addons-${version}.txz -C Addons/; cd Addons; tar xzvf CBAM.tgz; 

Download qcow2
    [Documentation]    Author: zhao nana
    ...                This keyword is to download qcow2

    csn.execute     command=cd ${qcow2_path}; wget ${package_link}/${version}/AirFrameVirtualized-${version}.qcow2    connection=OSP

Delete qcow2
    [Documentation]    Author: zhao nana
    ...                This keyword is to delete qcow2

    csn.execute     command=cd ${qcow2_path}; rm -rf AirFrameVirtualized-${version}.qcow2    connection=OSP   

Delete addons
    [Documentation]    Author: zhao nana
    ...                This keyword is to delete addons

    Run    cd ${download_path}; rm -rf *;

prepare image for cbam
    [Documentation]    Author: zhao nana
    ...                This keyword is to create image on cloud

    Connect to cloud controller
    Download qcow2
    delete image from the glance
    Create new image into the glance
    Delete qcow2

Connect to cloud controller
    [Documentation]    Author: zhao nana
    ...                This keyword is login openstack with ssh
    [Arguments]    ${alias}=OSP
    csn.Connect to
    ...     hostname=${cloud_ip}
    ...     username=${cloud_username}
    ...     password=${cloud_passwd}
    ...     alias=${alias}

Check image does not exsit
    [Documentation]    Author: zhao nana
    ...                This keyword is to check whether image exist

    [Arguments]    ${image}     ${source_file_path}=~/openrc
    ${image_check}      csn.execute     command=. ${source_file_path}; openstack image list | grep ${image}
    ...                 connection=OSP
    Should not Contain    ${image_check}    ${image}

Check image is ready
    [Documentation]    Author: zhao nana
    ...                This keyword is to checks if image is ative and not in saving state

    [Arguments]     ${image}    ${source_file_path}=~/openrc
    ${is_active}=    csn.execute    command=. ${source_file_path}; openstack image list | grep ${image}
    ...             connection=OSP
    Should Contain    ${is_active}    active        ignore_case=True

Create new image into the glance
    [Documentation]    Author: zhao nana
    ...                This keyword is to create image

    [Arguments]     ${source_file_path}=~/openrc
    ${create_image_params}=    set variable    --disk-format=qcow2 --container-format=bare
    ${create_image_cmd}=    set variable
    ...    openstack image create --file ~/${package_name} ${create_image_params} ${image_name}
    ${result}    csn.execute     command=. ${source_file_path}; ${create_image_cmd}     connection=OSP
    Should Not Contain    ${result}    Errno
    wait until keyword succeeds  5min   1min
    ...           Check image is ready    source_file_path=${source_file_path}     image=${image_name}
    

delete image from the glance
    [Documentation]    Author: zhao nana
    ...                This keyword is to delete image

    [Arguments]     ${source_file_path}=~/openrc
    run keyword and ignore error    csn.execute     command=. ${source_file_path}; openstack image delete ${image_name}
    ...                               connection=OSP
    wait until keyword succeeds  2min   30s
    ...             Check image does not exsit
    ...                   image=${image_name}
    ...                   source_file_path=${source_file_path}

load cu scf and check onair
    [Documentation]    Author: zhao nana
    ...                This keyword is to commission cu and check cell onair

    ${stream}    String.Split String From Right      ${version}  separator=.  max_split=1
    CU Full Commission    path_of_commission_file=${CURDIR}/../../../../../../commissionings/HGZ/${testline}/SCF_${stream[0]}_CU.xml
    Wait_all_Cells_onair_cloud_Coam

Check_Cell_Status_with_CellId_on_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to verify cell status
    [Arguments]    ${operational_state}=Disabled
    ...            ${administrative_state}=Locked
    ...            ${cell}=1
    Run Keyword And Ignore Error  selenium_coam.close_start_up_view_window  timeout=${5}
    ${output}=    selenium_coam.get_cell_info    cell_idx=${cell}
    Log Many      ${output}
    should be equal      ${output['Status']['Operational state']}    ${operational_state}
    should be equal      ${output['Status']['Administrative state']}    ${administrative_state}

Verify_Cell_Status_Is_On_Air_Or_Not
    [Documentation]    Author: zhao nana
    ...                This keyword is to verify cell status
    [Arguments]    ${cell}=1    ${operational_state}=Disabled    ${administrative_state}=Locked
    Wait Until Keyword Succeeds    20min    5s    Check_Cell_Status_with_CellId_on_cloud_coam
    ...    operational_state=${operational_state}
    ...    administrative_state=${administrative_state}
    ...    cell=${cell}

Wait_all_Cells_onair_cloud_Coam
    [Documentation]    Author: zhao nana
    ...   This keyword is to check all cells online

    Du login page via webUI
    Run Keyword And Ignore Error  selenium_coam.close_start_up_view_window  timeout=${5}
    ${total_cell_number}    selenium_coam.get_number_of_cells
    FOR    ${cell_id}    IN RANGE    ${total_cell_number}
        Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Enabled    administrative_state=Unlocked    cell=${cell_id+1}
    END
    [Teardown]    Run Keyword And Ignore Error    DU COAM selenium logout


check operation result
    [Documentation]    Author: zhao nana
    ...                This keyword is to check operation(eg modify/instantiate vnf operation) complete
    [Arguments]    ${instance_name}=${VNF_NAME}
    ${po_list}    cbam.get_all_operation_execution_info    vnf_instance_name=${instance_name}
    log    ${po_list}
    ${operationId}=    Get from dictionary    ${po_list[0]}    id
    ${result}    cbam.get_operation_execution_info    operation_id=${operationId}
    ${operationState}=    Get from dictionary    ${result}    operationState
    should be true    '${operationState}'=='COMPLETED'

Select VNF flavor package
    [Documentation]    Author: zhao nana
    ...                This keyword is to select flavor package and return vnfd_id

    [Arguments]
    ...    ${vim_type}=NCIR # or OSP
    ...    ${release}=5G21B

    ${vnfd_list}=    cbam.get_catalog_info

    ${vnfd_id}=    cbam_utils.get_vnfd_id
    ...    vnfd_list=${vnfd_list}
    ...    vnf_type=flavor
    ...    vim_type=${vim_type}
    ...    release=${release}
    [return]    ${vnfd_id}

Select VNF extnet package
    [Documentation]    Author: zhao nana
    ...                This keyword is to select extnet package and return vnfd_id
    
    [Arguments]
    ...    ${release}=5G21B
    ...    ${vim_type}=NCIR # or OSP

    ${vnfd_list}=    cbam.get_catalog_info
    ${vnfd_id}=    cbam_utils.get_vnfd_id    
    ...    vnfd_list=${vnfd_list}
    ...    vnf_type=extnet
    ...    vim_type=${vim_type}
    ...    release=${release}
    [return]    ${vnfd_id}

Select VNF gnb_cu_ha package
    [Documentation]    Author: zhao nana
    ...                This keyword is to select gnb_cu_ha package and return vnfd_id
    
    [Arguments]
    ...    ${release}
    ...    ${vim_type}=NCIR # or OSP

    ${vnfd_list}=    cbam.get_catalog_info
    
    ${vnfd_id}=    cbam_utils.get_vnfd_id
    ...    vnfd_list=${vnfd_list}
    ...    vnf_type=gnb_cu_ha    
    ...    vim_type=${vim_type}    
    ...    release=${release}
    [return]    ${vnfd_id}

Check VNF state
    [Documentation]    Author: zhao nana
    ...                This keyword is to check vnf state

    [Arguments]
    ...    ${vnf_name}
    ...    ${expected_state}
    ${vnf_list}       cbam.query_all_vnfs
    
    ${vnf_id}         cbam_utils.get_vnf_id    ${vnf_list}    ${vnf_name}
    
    ${vnf_info}       cbam.query_one_vnf    ${vnf_id}
    
    ${current_state}    cbam_utils.get_operation_vnf_state    ${vnf_info}
    Should Be Equal    ${current_state}    ${expected_state}

Wait until VNF reaches expected state
    [Documentation]    Author: zhao nana
    ...                Wait until the VNF unit in CBAM reaches expected state.
    ...                Possible states are NOT_INSTANTIATED, INSTANTIATED

    [Arguments]
    ...    ${vnf_name}
    ...    ${expected_state}=INSTANTIATED
    ...    ${timeout}=120s
    ...    ${interval}=20s

    ${status}=    run keyword and return status
    ...           wait until keyword succeeds    ${timeout}    ${interval}
    ...           Check VNF state    ${vnf_name}    ${expected_state}
    [return]    ${status}
