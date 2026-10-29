*** Settings ***
Documentation
...    copyright: Nokia

*** Variables ***
${FEATURE_ACTIVATION_DURATION}    420s
${FULL_COMMISSIONING}=            ${FALSE}
${RESET_TL}=                      ${FALSE}
${SCFC}=                          full_scfc_2cells.xml

*** Keywords ***
Wait For Feature Activation
    sleep    ${FEATURE_ACTIVATION_DURATION}    Value based on RAN_5G_CP_12352238, RAN_5G_USR_15686, delta configuration

Check If Cell Enabled And In NotEnergySaving State
    Check Admin Object Parameter Value    moc=NRCELL_R    parameter_name=energySavingState    value=notEnergySaving
    Check Admin Object Parameter Value    moc=NRCELL_R    parameter_name=operationalState    value=enabled

Set Current Date And Wait For EnergySaving State Change
    [Arguments]    ${scfc_filename}    ${parameter_name}    ${value}    ${moc}
    Set Current Date In Delta And Return Lbps Start Time
    ...   scfc_filename=${scfc_filename}
    Find Scfc and Send Delta Commissioning    scfc_filename=${scfc_filename}
    Wait For Parameter Value Change    parameter_name=${parameter_name}    value=${value}    moc=${moc}

Stop CMAS Broadcast
    Execute Egate Command    cmd=cbs_broadcast_stop amf=1

Reset Testline And Wait For Rmods And Collect Logs
    Reset Testline
    Wait For Testline Icmp Echo Replies And Ssh Services
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/reset_testline
    Check Radios Availability
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/reset_testline
