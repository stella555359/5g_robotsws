*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6


Resource    ../keywords/tshark_verifying.robot
Library     ../resources/common_functions.py
Library     ../CB008490/resources/common_keywords.py
Library     ta5g_iphy
Library     ta5g_commissioning
Library     taf.ul.ettf.setups

*** Keywords ***
Prepare Test Setup For One Real Gnb And Enable Tshark Verification
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc}=SCFC    ${cfg}=cfg
    ${iphy}=    Create Config File Path Variable Name     filetype=${iphy}    name=${tc_id}
    ${scfc}=    Create Config File Path Variable Name     filetype=${scfc}    name=${tc_id}
    ${cfg}=     Create Config File Path Variable Name     filetype=${cfg}     name=${tc_id}

    ${iphy_filename}=    Get Variable Value    ${iphy}
    ${scfc_filename}=    Get Variable Value    ${scfc}
    ${cfg_filename}=     Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc_filename}
    ...    AND         Reset Wts
    ...    AND         Wait 300s To Reset Wts
    ...    AND         Enable Tshark Verification
    ...    AND         With Simulator Configuration    config=${cfg_filename}    timeout=300
    ...    AND         Enforce protocol    nr-rrc

Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc_MN}=SCFC_MN    ${scfc_SN}=SCFC_SN    ${cfg}=cfg
    ${iphy}=       Create Config File Path Variable Name     filetype=${iphy}       name=${tc_id}
    ${scfc_MN}=    Create Config File Path Variable Name     filetype=${scfc_MN}    name=${tc_id}
    ${scfc_SN}=    Create Config File Path Variable Name     filetype=${scfc_SN}    name=${tc_id}
    ${cfg}=        Create Config File Path Variable Name     filetype=${cfg}        name=${tc_id}

    ${iphy_filename}=       Get Variable Value    ${iphy}
    ${scfc_MN_filename}=    Get Variable Value    ${scfc_MN}
    ${scfc_SN_filename}=    Get Variable Value    ${scfc_SN}
    ${cfg_filename}=        Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${scfc_SN_filename}
    ...                remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${scfc_MN_filename}
    ...    AND         Enable Tshark Verification
    ...    AND         With Simulator Configuration    config=${cfg_filename}   timeout=300    remote_hosts=${REMOTE_HOSTS}
    ...    AND         Enforce protocol    nr-rrc

Wait ${x:\d+}s To Reset Wts
    Sleep    ${x}s
