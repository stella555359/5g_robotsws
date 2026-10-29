*** Settings ***
Documentation     Keywords relating to the execution of the CIT cases for 5GC000636 Feature.
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/log.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/airphone.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Resource          ../../../Resources/robot/tshark.robot

*** Keywords ***
Verify CRNTI is Present In APL3 Logs
    [Documentation]    This keyword verifies if the CRNTI(Cell Radio Network Temporary Indentifier) is assigned
    ...                to the UE after SgNBAddition is Complete.
    ${rc}=    Run and return rc
    ...       sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'grep -i "crnti" /tmp/APL3.log'
    Should be Equal as Integers     ${rc}      0    msg=CRNTI value is not present in APL3 logs

Check SSBPosInBurst Medium Bitmap Is Present
    [Arguments]    ${filter}    ${msg_names}
    ${pcap_file}    log_store.get_gnb_pcap
    Msg Should Be Present in PCAP    ${pcap_file}    ${filter}    ${msg_names}

Check MaxMIMO Layers IE Is Present
    [Arguments]    ${filter}    ${msg_names}
    ${pcap_file}    log_store.get_gnb_pcap
    Msg Should Be Present in PCAP    ${pcap_file}    ${filter}    ${msg_names}

Perform UE Attach
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}

Perform SgNBAdiition
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}
    ...    target_cells=${CELL_ID}    bearer=${BEARER_ID}

Store Egate Logs
    ${test_log_path}    log_store.get_test_log_folder
    Set Test Variable    ${test_log_path}
    Collect EGATE Logs