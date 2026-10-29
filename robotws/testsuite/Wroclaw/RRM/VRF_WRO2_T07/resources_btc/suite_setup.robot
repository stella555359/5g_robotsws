*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library     Process
Library     String
Library     ute_fsmaccess
Library     taf.sbts.oam.coam.admin
Library     ${CURDIR}${/}suite_setup.py
Library     ute_wtssim
Library     ta5g_commissioning

Resource    ${CURDIR}${/}suite_config_step.robot

*** Variables ***

${CONFIG_PATH}      ${CURDIR}${/}config
${RESOURCES_PATH}   ${CONFIG_PATH}${/}resources

*** Keywords ***

ePC Shutdown Step
    Config Step '${CONFIG_PATH}${/}teardown_epc.sh' 'Shutdown ePC SIM' '0'

Network Setup Step
    Config Step '${CONFIG_PATH}${/}setup_network.sh' '\nSetup network interfaces' '0'

Port Availability Setup Step
    Kill Process Which Occupies Port

Wireshark Setup Step
    Config Step '${CONFIG_PATH}${/}setup_wireshark.sh' '\nSetup Wireshark' '0'
    ${wireshark_version}=  Get Wireshark Version
    Download Wireshark Plugins  ${wireshark_version}

Wireshark 5G Setup Step
    Config Step Start 'Setup Wireshark'
    ${wireshark_version}=  Get Wireshark Version
    Download Wireshark Plugins  ${wireshark_version}
    Configure Wireshark
    Config Step Stop '0'

Tox Setup Step
    Config Step '${CONFIG_PATH}${/}setup_tox.sh' 'Setup Tox' '0'

Detect Wireshark Plugins
    Config Step Start 'Detect Wireshark plugin'
    ${wireshark_version}=  Get Wireshark Version
    Detect Plugin    ${wireshark_version}
    Config Step Stop '0'

Branch Detection Step
    Config Step Start 'Detect branch'
    Setup eNB FSM Access
    ${sw_version}=  Get eNB SW Version
    ${enb_type}=  Execute Command On Enb  cat /var/dt/module-identity/unit-id
    ${enb_type}=  Remove String  ${enb_type}  \x00
    ${simulator}=  Check Simulator
    Log To Console  SW version: ${sw_version}
    Log To Console  eNB type: ${enb_type}
    Teardown eNB FSM Access
    ${branch}=  Get Branch Name    ${sw_version}
    Log To Console  FTTools repo branch: ${branch}
    ${technology}=  Get Technology From Bts
    Log To Console  BTS used technology: ${technology}
    Config Step Stop '0'
    [Return]    ${branch}  ${enb_type}  ${simulator}  ${technology}

Environment Detection Step
    ${env_type}=  Get Env Type
    Log To Console  Env type is: ${env_type}
    [Return]    ${env_type}

FTTools Setup Step '${branch}'
    Config Step '${CONFIG_PATH}${/}setup_fttools.sh ${branch}' 'Setup FTTools' '0'

iPHY Setup Step '${branch}' '${enb_type}'
    Config Step '${CONFIG_PATH}${/}setup_iphy.sh ${branch}${/}${enb_type}' 'Setup iPHY' '5m'

Fix Vlan Id And Perform Commissioning
    [Arguments]    ${scf_file}
    ${FIXED_VLAN_ID_SCF}=    ta5g_commissioning.Fix Vlan Id In Scfc
    ...                      input_filepath=${scf_file}
    Perform Commissioning    bts_id=1    scf_file=${FIXED_VLAN_ID_SCF}   skip_parameter_relation_errors=True
    ...                      timeout=500

Admin Setup Step '${branch}' '${enb_type}' '${simulator}' '${technology}'
    Config Step Start 'Setup Admin'
    Setup Admin    bts_port=443    use_ssl=True
    ${INPUT_SCFC_PATH}=    Set Variable
    ...   ${RESOURCES_PATH}${/}${branch}${/}${enb_type}${/}${simulator}${/}${technology}${/}full_commissioning.xml
    ${OUTPUT_SCFC_PATH}=   Set Variable
    ...   ${RESOURCES_PATH}${/}${branch}${/}${enb_type}${/}${simulator}${/}${technology}${/}updated_commissioning.xml
    Migrate Scf  ${INPUT_SCFC_PATH}  ${OUTPUT_SCFC_PATH}
    Run Keyword If  '${simulator}' != '5G_AP'    Perform Commissioning    bts_id=1
    ...    scf_file=${OUTPUT_SCFC_PATH}   skip_parameter_relation_errors=True    timeout=500
	Teardown Admin
	Config Step Stop '2m'

vRAN Admin Setup Step '${branch}' '${enb_type}' '${simulator}' '${technology}'
    Config Step Start 'Setup Admin'
    ${INPUT_SCF_PATH_VDU}=    Set Variable
    ...  ${RESOURCES_PATH}${/}${branch}${/}${enb_type}${/}${simulator}${/}${technology}${/}vDU${/}full_commissioning.xml
    ${INPUT_SCF_PATH_VCU}=    Set Variable
    ...  ${RESOURCES_PATH}${/}${branch}${/}${enb_type}${/}${simulator}${/}${technology}${/}vCU${/}full_commissioning.xml
    ${CURRENT_SCF_PLAN_FILE}=    Get Vdu Current Plan File
    ...    vdu_path=${RESOURCES_PATH}${/}${branch}${/}${enb_type}${/}${simulator}${/}${technology}${/}vDU
    Change Serial Number And Product Code From Default Scf
    ...    vdu_default_scf_path=${CURRENT_SCF_PLAN_FILE}
    ...    vdu_new_plan=${INPUT_SCF_PATH_VDU}    target_distname=MRBTS-1/EQM-1/APEQM-1/RNICMOD-1
    ta5g_commissioning.Perform Commissioning Vcu Aic      path_to_plan_file=${INPUT_SCF_PATH_VCU}
    ta5g_commissioning.Send Full Commissioning Vdu Aic    input_filepath=${INPUT_SCF_PATH_VDU}    vdu=1

iPHY Reset Step
    Config Step '${CONFIG_PATH}${/}reset_iphy.sh' 'Reset iPHY' '5m'

ePC iPHY Setup Step
    Config Step '${CONFIG_PATH}${/}setup_epc_iphy.sh' 'Setup ePC SIM with iPHY' '1m'

ePC CUS Setup Step '${enb_type}' ${technology}
    Config Step '${CONFIG_PATH}${/}setup_epc_cus.sh '${enb_type}' ${technology}' 'Setup ePC SIM with CUS' '1m'

EMS Sim Setup Step
    Log to console  Setup EMS Sim...
    Start Process  ${CONFIG_PATH}${/}setup_emssim.sh
    Log to console  [DONE]

WTS Setup Step
    Check Wts 5g
    Config Step '${CONFIG_PATH}${/}setup_wts.sh' 'Setup WTS' '0'
    Run Process    bash    /opt/iphy/WTS_CURRENT/startWTS.sh    stdout=log.txt    stderr=err.log
    ...            shell=True    timeout=60
    Change WTS Config File

LTE Env Setup '${branch}' '${enb_type}' '${simulator}' ${technology}
    Wireshark Setup Step
    Run Keyword If  '${simulator}' == 'iPHY'    iPHY Setup '${branch}' '${enb_type}'
    ...   ELSE   CUS Setup '${branch}' ${enb_type} ${technology}
    Check Syslog Flags And Enable If Needed

iPHY Setup '${branch}' '${enb_type}'
    ePC Shutdown Step
    iPHY Setup Step '${branch}' '${enb_type}'
    Admin Setup Step '${branch}' '${enb_type}' 'iPHY'
    ePC iPHY Setup Step
    iPHY Reset Step

CUS Setup '${branch}' ${enb_type} '${technology}'
    Admin Setup Step '${branch}' '${enb_type}' 'CUS' '${technology}'
    ePC CUS Setup Step '${enb_type}' ${technology}

5G Env Setup
    Wireshark 5G Setup Step
    WTS Setup Step

vDU Env Setup
    ${sw_version}=  Get Sw Version Vdu
    Log To Console  ${sw_version}
    ${branch}=  get Vran Branch Name  '${sw_version}'
    FTTools Setup Step '${branch}'
    Log To Console  FTTools repo branch: ${branch}
    Wireshark 5G Setup Step
    WTS Setup Step

SBTS Suite Setup
    ${branch}  ${enb_type}  ${simulator}  ${technology}=    Branch Detection Step
    ${env_type}=    Environment Detection Step
    FTTools Setup Step '${branch}'
    Run Keyword If  '${env_type}' == 'LTE'    LTE Env Setup '${branch}' '${enb_type}' '${simulator}' '${technology}'
    Run Keyword If  '${env_type}' == '5G'    5G Env Setup

Common Suite Setup
    Port Availability Setup Step
    Network Setup Step
    Tox Setup Step
    Detect Wireshark Plugins
    ${vran}  ${vran_out_msg}=  VRAN Connection Check
    Log To Console  vRAN env=${vran}
    Log To Console  ${vran_out_msg}
    Run Keyword If  '${vran}' == 'True'    vDU Env Setup
    ...  ELSE    SBTS Suite Setup

Suite Setup
    Common Suite Setup
