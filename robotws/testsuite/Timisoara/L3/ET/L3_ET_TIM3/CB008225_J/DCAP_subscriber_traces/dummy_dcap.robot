*** Settings ***

Documentation
...    author:
...     pybot -V /home/ute/testline_configuration/${HOSTNAME//-/_} -L TRACE -b debug.log -d
...     results/ testsuite/Timisoara/L3/ET/L3_ET_TIM3/CB008225/DCAP_subscriber_traces/dummy_dcap.robot
## change IP ->VMIP in config/223R3/delta_7732_subscriber_trace_with_cell_trace.json
## SBA dcap logs are here : /home/ute/robotws/results/20230327/1310/5g/controlPlane/*.5gm

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
    ...        AND             Get Vm IP and Replace  ${delta_scf}
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_subscriber_trace_with_cell_trace.json
    ...        AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start # to be deleted after dcap is prepared from UTE
    ...        AND             Start Dcap

    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Start Subscriber Trace
    Deregister Ue    ue_id=1


    [Teardown]    Run Keywords    Stop Subscriber Trace    ue_id=1
    ...           AND             Stop And Revert Dcap
    ...           AND             Deregister Ue Without Confirmation    ue_id=1
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_subscriber_trace_with_cell_trace.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Get Vm IP and Replace
    [Arguments]       ${delta_scf}
    ${VM_IP}=  set variable  ${tl.test_pc.default_ssh_connection_details.addr}
#    Run  pwd
    Run  sed -i 's/vm_tceIpAddress/${VM_IP}/' ${CURDIR}/config/SBTS23R3/${delta_scf}
