*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Piotr Wisniewski
...             :contact:piotr.wisniewski@nokia.com

Resource       taf/ul/ettf/main.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       taf/ul/ettf/main.robot
Resource       ${CURDIR}/../resources/feature_keywords.robot

Library        taf.ul.ettf.setups
Library        taf.ul.ettf.retry_context
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_egate
Library        ute_wtssim
Library        ute_fsmaccess
Library        ta5g_testline_management
Library        ../resources/multignb_variables.py

Variables      ../../resources/custom_policy.py
Variables      ../resources/feature_variables.py


Suite Setup    Run Keywords
...                Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}    remote_host=${REMOTE_HOST_1_IP}

Test Setup         Run Keywords
...                Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${EGATE}    remote_hosts=${REMOTE_HOSTS}

*** Variables ***
${LOGGING_POLICY}=      SYSLOG_POLICY
${SCFC_GNB_MN}=         /A_B2/scf_MN_A_B2_n28A_BO_BOO_AP_LOO.xml
${SCFC_GNB_SN}=         /A_B2/scf_SN_A_B2_n78A_n257A_BO_BOO_AP_LOO.xml
${IPHY}=                ${CURDIR}/config/CB008490_A/iphy_MN_n28A_SN_n78A_n257A.xml
${EGATE}=               ${CURDIR}/config/CB008490_A/cfg_MN_n28A_SN_n78A_n257A.cfg
@{swconfig_8717_rdFlag}=    0x890057=0
@{REMOTE_HOSTS}=        None

*** Test Cases ***
CB008490_A_B2_Broadcast_Of_NR-DC-SN_Cell_Information_On_Xn_Interface_basic_Scenario_With_MN_Initiated_Xn_Link_Establishment
    Send Delta Commissioning with NRADJGNB set to unlocked
    Verify XNAP Messages For A_B2 Scenario
    Verify Link Status On Secondary Node

*** Keywords ***

Send Delta Commissioning with NRADJGNB set to unlocked
    Find Scfc and Send Delta Commissioning   scfc_filename=/A_B2/Delta_CB008490_A_B2.json

Prepare Flow Check For B2 Scenario
    feature_keywords.Create GNB alias
    Expect XNAP Message Flow For B2 Scenario

Expect XNAP Message Flow For B2 Scenario
    Expect message flow
    ...    gNB:XNAP_XNAPSetupRequest as XNAPSetupRequestWithSAandNRDCSNCell
    ...    gNB:XNAP_XNAPSetupResponse as XNAPSetupResponseWithListOfServedCell

Verify XNAP Messages For A_B2 Scenario
      Verify Tcpdump Log      ${XNAP_SETUP_REQUEST}
      Verify Tcpdump Log      ${XNAP_SETUP_RESPONSE}

Verify Link Status On Secondary Node
    Setup Admin    remote_host=${REMOTE_HOST_1_IP}    name="SN"

    ${PATH_XNLINK}=   Set Variable         /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-2/XNLINK_R-1
    ${PATH_NRADJGNB}=   Set Variable       /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/NRBTS_A-2/NRADJGNB_A-1
    ${status_XNLINK}=   Set Variable       "{'xnLinkStatus': 'available'}"
    ${status_NRADJGNB}=   Set Variable     "{'gNodeBIdCtrl': 'gnbControlled'}"

    ${Returned_XnLink_Pattern}=    Get Parameters      connection="SN"   dist_name=${PATH_XNLINK}    pattern=xnLinkStatus
    Log To Console    ${Returned_XnLink_Pattern}
    Should Be True    "${Returned_XnLink_Pattern}" == ${status_XNLINK}

    ${Returned_xnLinkRef_from_adj}=    Get Parameters      connection="SN"   dist_name=${PATH_NRADJGNB}    pattern=gNodeBIdCtrl
    Log To Console    ${Returned_xnLinkRef_from_adj}
    Should Be True    "${Returned_xnLinkRef_from_adj}" == ${status_NRADJGNB}

    Teardown Admin    connection="SN"
