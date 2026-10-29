*** Settings ***
Force Tags    CIT    GQC_PLAN:DESIGNER:egodlews    RAN_5G    SBTS00    NoResUsage
       ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    CB007949_keywords.robot
Resource    ../keywords/logging.robot

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}

Test Setup    With Retry Context    3
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

Suite Teardown    Run Keyword And Ignore Error    Deregister UE    ${ue_id}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/egate_custom_config.cfg
${iphy_xml}=                ${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
${scfc}=                    scfc_7949_A_B1a.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1

*** Test Cases ***
CB007949_A_B1a_Successful_Blind_SCell_Addition_With_Beamforming_Disabled
    Register UE With PDU Session Setup    ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Verify Successful 3CC TTT SCell Addition
    Verify PUCCH Resource For 3CC TTT
    Deregister Ue    ue_id=${ue_id}
