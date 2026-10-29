*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_VRF    SBTS00    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Dariusz Maciocha
...             :contact: dariusz.maciocha@nokia.com

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/feature_keywords.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/multignb_variables.py
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_egate
Library        ta5g_testline_management
Library        testsuite/Wroclaw/RRM/resources/scout_report.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008490/resources/CB008490_keywords.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library        testsuite/Wroclaw/RRM/resources/syslog_checker.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008490/resources/test_variables.py

Test Setup       Run Keywords    Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND       Find Scfc And Fix And Send Full Commissioning
...              scfc_filename=${SCFC_SN}
...              remote_host=${REMOTE_HOST_1_IP}
...    AND       Find Scfc And Fix And Send Full Commissioning
...              scfc_filename=${SCFC_MN}
...    AND       Enable Tshark Verification    logs_path=${OUTPUT_DIR}/${TEST_NAME}/${TSHARK_SUBDIR}
...    AND       Reach Onair Without Confirmation    lua_cfg=${EGATE}    remote_hosts=${REMOTE_HOSTS}    align_tac_values=${false}
Test Teardown    Teardown

*** Variables ***
${SCFC_MN}=                  scfc_MN_n78A_n257M_AEQE_8CC.xml
${SCFC_SN}=                  scfc_SN_n78A_n257M_AWEUB_8CC.xml
${IPHY}=                     ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${EGATE}=                      ${CURDIR}/config/cfg_n78A_n257M_8CC_9UEs.cfg

*** Test Cases ***
CB008490-QCL_B101_B6_NR-DC_SCG_CA_SCell_Lock
    Attach Ue    ue_id=8
    Establish PDU Session    ue_id=8    pdu_id=1    gw_id=1    pass_regexp=measIdToAddModList    timeout=60
    Send A4 Measurement
    ${delta} =    Catenate    [{"distName":"MRBTS-3/NRBTS-3/NRCELL-4","operation":"update","parameters":[{"parameterName":"administrativeState",
    ...    "value":"Locked","operation":"update"}]},{"distName":"MRBTS-3/NRBTS-3/NRCELL-5","operation":"update","parameters":
    ...    [{"parameterName":"administrativeState","value":"Locked","operation":"update"}]}]
    Send Delta Commissioning    ${delta}    ${REMOTE_HOST_1_IP}
    Verify Partial Reset

*** Keywords ***
Verify Partial Reset
    Verify Tcpdump Log    ${UeWith8CCConfirmation}
    Verify Tcpdump Log    ${ResetRequest}    timeout=120
    Verify Tcpdump Log    ${NgReset}
    Verify Tcpdump Log    ${NgRanConfigurationWithCellsDeleted}    relation_symbol= >=

Teardown
    Add Scout Scf Id To Test Data
    Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Run Keyword If Test Passed    Find Suspicious Logs
