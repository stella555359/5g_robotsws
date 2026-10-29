*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
       ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :authors: Joanna Kutrowska-Girzycka
...             :contact: joanna.kutrowska-girzycka@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     CB007949_keywords.robot
Resource     ../keywords/logging.robot
Resource     ../keywords/messaging.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_enb
Library      ta5g_delta
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ../resources/messaging.py
Variables    CB007949_messaging_filters.py
Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}

Test Setup    Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

Suite Teardown    Run Keyword And Ignore Error    Deregister UE    ${ue_id}

*** Variables ***
${LOGGING_POLICY}=     BASIC_POLICY
${cfg}=                ${CURDIR}/config/egate_custom_config.cfg
${iphy_xml}=           ${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
${scfc}=               scfc_7949_E.xml
${ue_id}=              1
${gw_id}=              1
${pcell_id}=           3
${gnb_id}=             2
${a1_meas_id}=         1
${a1_rsrp}=            110
${a2_meas_id}=         3
${a2_rsrp}=            30
${scell_id}=           2
${pucchResourceID}=    9

*** Test Cases ***
CB007949_E_B1_Apply_pCSI_Bundling_To_A_TDD_FR1_3CC_DL_CA_UE_pCSI_Bundling_Is_Applied_In_PCell_And_In_Both_Scells
    Attach UE And Verify Establishing PDU Session   ue_id=${ue_id}    cell_id=${pcell_id}
    ${starting_prb}=    Get StartingPRB Of PucchResourceId From RRCReconguration    pucchResourceID=${pucchResourceID}
    Verify A1 Configuration
    Verify PSCI Bundling After RRC Setup
    Send A1 Measurement And Verify A2 Configuration On 2 Scells
    Verify Successful 3CC TTT SCell Addition With PCSI Bundling
    Verify PCSI Bundling After SCell Addition   ${starting_prb}
    Send A2 Measurement And Verify SCell2 Release
    ...    a2_meas_id=${a2_meas_id}
    ...    a2_rsrp=${a2_rsrp}
    ...    scell_id=${scell_id}
    Verify PCSI Bundling After SCell2 Release

*** Keywords ***

Get StartingPRB Of PucchResourceId From RRCReconguration
   [Arguments]    ${pucchResourceID}
    ${index_of_pucchResourceID}=    Get Index Of Value From List    flow_alias=Established_PDU_UE${ue_id}
    ...  message_alias=RRCReconfiguration    parameter_name=pucch-ResourceId    value_of_parameter=${pucchResourceID}
    ${starting_prb}=    Get Value From Message By Index    flow_alias=Established_PDU_UE${ue_id}    message_alias=RRCReconfiguration
    ...  parameter_name=startingPRB    index_of_value=${index_of_pucchResourceID}
    [Return]    ${starting_prb}


