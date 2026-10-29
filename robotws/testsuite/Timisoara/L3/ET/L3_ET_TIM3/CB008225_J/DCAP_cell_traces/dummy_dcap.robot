*** Settings ***
Force Tags     NoResUsage
Resource    dummy_dcap_Keywords_And_Variables.robot
Library     taf.sw.dcap.rd    WITH NAME    rd

#Suite Setup    log to console  SS
#Suite Teardown    log to console  ST
#Test Setup    log to console  TS
#Test Teardown    log to console  TT

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
Dummy_DCAP_test
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Get Vm IP and Replace
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=cell_traces_configuration.json
#    ...        AND             Set VM IP in SCF
#    ...        AND             Get 5G Tracing Profiles
    ...        AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start # to be deleted after dcap is prepared from UTE
#    ...        AND             Get 5G Tracing Profiles
    ...        AND             Start Dcap

    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Deregister Ue    ue_id=1


    [Teardown]    Run Keywords    Stop And Revert Dcap
    ...           AND             Deregister Ue Without Confirmation    ue_id=1
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=cell_traces_configuration.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Get 5G Tracing Profiles
    [Arguments]    ${timeout}=30
    ${5g_profiles}=    rd.get_5g_profiles    timeout=${timeout}
    Log To Console    ${5g_profiles}
    [Return]   ${5g_profiles}


Set VM IP in SCF
    ${VM_IP}=  set variable  ${tl.test_pc.default_ssh_connection_details.addr}
    Perform Parameter Commissioning  parameter=tceIpAddress  value=${VM_IP}  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1

Get Vm IP and Replace
    ${VM_IP}=  set variable  ${tl.test_pc.default_ssh_connection_details.addr}
#    Run  pwd
    Run  sed -i 's/vm_tceIpAddress/${VM_IP}/' ${CURDIR}/config/SBTS23R3/cell_traces_configuration.json
