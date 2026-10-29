*** Settings ***
Force Tags    PY36
Documentation    This is common keywords for CB6773 related cases
...              Please do not modify the file without notification to author
...              Author: zhao nana
...              Contact: nana.zhao@nokia-sbell.com
...              Squard: MMW2

Suite Setup       Cbam_Common_Setup
Suite Teardown    Cbam_Common_Teardown

Resource          ${CURDIR}/resource/vm_cbam_resources.robot

*** Variables ***


*** Test Cases ***
[1]5GC001575_JG_A001_VCP Creation-Instantiation of shared Compute Resources VNF flavors
    [Documentation]    create and instantiate flavor on cbam
    [Tags]    CRT_21B    CRT_TRUNK
    [Setup]
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}

    ${vnf_id}=    set variable    5gbts_flavor
    ${vnfd_id}    Select VNF flavor package    release=${release}    vim_type=${VIM_TYPE}
    set suite variable  ${flavor_vnfd_id}   ${vnfd_id}
    
    ${result}    cbam.create_vnf    vnfd_id=${flavor_vnfd_id}    name=${FLAVOR_NAME}    description=${FLAVOR_DESCRIPTION}
    sleep    2s
    cbam.modify_vnf    vnf_instance_name=${FLAVOR_NAME}    path_to_parameter_file=${flaovr_modify_config_file}
    
    wait until keyword succeeds  5 min  30 sec    check operation result    instance_name=${FLAVOR_NAME}
    
    ${op_dict}=    cbam.instantiate_vnf
                   ...    vnf_instance_name=${FLAVOR_NAME}
                   ...    path_to_parameter_file=${flavor_instantiate_config_file}
                   ...    password=${vim_password}
                   ...    flavour_id=${vnf_id}
    
    wait until keyword succeeds  5 min  30 sec    check operation result    instance_name=${FLAVOR_NAME}
    [Teardown]

[1]5GC001575_JG_A002_VCP Termination-Removal of shared Compute Resources VNF flavors
    [Documentation]    terminate and delete flavor on cbam
    [Tags]    CRT_21B    CRT_TRUNK
    [Setup]
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    cbam.terminate_vnf
    ...    vnf_instance_name=${FLAVOR_NAME}
    ...    termination_type=${graceful_terminate_type}
    ...    graceful_termination_timeout=20
	
    Wait until VNF reaches expected state
    ...    vnf_name=${FLAVOR_NAME}
    ...    expected_state=NOT_INSTANTIATED
    ...    timeout=300s
    ...    interval=10s
    
    sleep    10s
    
    cbam.delete_vnf    vnf_instance_name=${FLAVOR_NAME}
    [Teardown]

[1]5GC001575_JG_A003_VCP Creation-Instantiation of VNF External Networks
    [Documentation]    create and instantiate net on cbam
    [Tags]    CRT_21B    CRT_TRUNK
    [Setup]
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    ${vnf_id}=    set variable    5gbts_nets
    ${vnfd_id}    Select VNF extnet package    release=${release}    vim_type=${VIM_TYPE}
    set suite variable  ${net_vnfd_id}   ${vnfd_id}
    ${result}    cbam.create_vnf    vnfd_id=${net_vnfd_id}    name=${NETWORK_NAME}    description=${NET_DESCRIPTION}
    cbam.modify_vnf    vnf_instance_name=${NETWORK_NAME}    path_to_parameter_file=${net_modify_config_file}
    wait until keyword succeeds  5 min  30 sec    check operation result    instance_name=${NETWORK_NAME}
    ${op_dict}=    cbam.instantiate_vnf
                   ...    vnf_instance_name=${NETWORK_NAME}
                   ...    path_to_parameter_file=${net_instantiate_config_file}
                   ...    password=${vim_password}
                   ...    flavour_id=${vnf_id}
    wait until keyword succeeds  5 min  30 sec    check operation result    instance_name=${NETWORK_NAME}
    [Teardown]

[1]5GC001575_JG_A004_VCP Termination-Removal of VNF External Networks
    [Documentation]    terminate and delete net on cbam
    [Tags]    CRT_21B    CRT_TRUNK
    [Setup]
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    cbam.terminate_vnf    vnf_instance_name=${NETWORK_NAME}    termination_type=FORCEFUL
    Wait until VNF reaches expected state
    ...    vnf_name=${NETWORK_NAME}
    ...    expected_state=NOT_INSTANTIATED
    ...    timeout=300s
    ...    interval=10s
    
    sleep    5s
    cbam.delete_vnf    vnf_instance_name=${NETWORK_NAME}    
    [Teardown]

[1]5GC001575_JG_A005_VCP HA Creation-Instantiation of gnb-CU VNF
    [Documentation]    create and instantiate vnf on cbam
    [Tags]    CRT_21B    CRT_TRUNK
    [Setup]
    prepare image for cbam
    cbam_utils.customize_vnf_config_files_of_type_instantiate
                ...    srcdir=${CURDIR}/resource/configutions/vnf
                ...    dstdir=${CURDIR}/resource/configutions/new
                ...    version=${version}
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    ${vnf_id}=    set variable    5gbts_vnf
    ${vnfd_id}    Select VNF gnb_cu_ha package    release=${release}    vim_type=${VIM_TYPE}
    set suite variable  ${vnf_vnfd_id}   ${vnfd_id}

    ${result}    cbam.create_vnf    vnfd_id=${vnf_vnfd_id}    name=${VNF_NAME}    description=${VNF_DESCRIPTION}
    sleep    5s

    cbam.modify_vnf    vnf_instance_name=${VNF_NAME}    path_to_parameter_file=${vnf_modify_config_file}
    wait until keyword succeeds  20 min  30 sec    check operation result    instance_name=${VNF_NAME}
    
    ${op_dict}=    cbam.instantiate_vnf
                   ...    vnf_instance_name=${VNF_NAME}
                   ...    path_to_parameter_file=${CURDIR}/resource/configutions/new/5G_instantiate_vnf_gui.json
                   ...    password=${vim_password}
                   ...    flavour_id=${vnf_id}
    
    wait until keyword succeeds  20 min  30 sec    check operation result    instance_name=${VNF_NAME}
    
    load cu scf and check onair
    [Teardown]
    
[1]5GC001575_JG_A006_VCP HA Termination-Removal of gnb-CU VNF with the mode Forceful
    [Documentation]    terminate and delete vnf on cbam
    [Tags]    CRT_21B    CRT_TRUNK
    [Setup]
    cbam.connect    ip=${cbam_addr}    client_id=${client_id}    client_secret=${client_secret}    version=${CBAM_VERSION}
    cbam.terminate_vnf    vnf_instance_name=${VNF_NAME}    termination_type=${terminate_type}
    Wait until VNF reaches expected state
    ...    vnf_name=${VNF_NAME}
    ...    expected_state=NOT_INSTANTIATED
    ...    timeout=300s
    ...    interval=10s
    
    sleep    10s
    
    cbam.delete_vnf    vnf_instance_name=${VNF_NAME}
    cbam.delete_catalog_info    vnfd_id=${vnf_vnfd_id}
    [Teardown]
*** Keywords ***




*** Keywords ***