*** Settings ***
Documentation
...   feature keywords for CB013553

Library        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB013553/resources/keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/attenuators.py
Library        taf.hw.rf_attenuator    WITH NAME    att
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py     WITH NAME     ds
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py    WITH NAME     ah

*** Variables ***
@{cell_40}=   ${21}    ${22}   ${23}    ${24}
@{cell_50}=   ${13}    ${14}   ${15}    ${16}
@{cell_81}=   ${5}     ${6}    ${7}     ${8}
@{step_1_values}    30dB    30dB    30dB    30dB
@{step_2_values}     0dB     0dB     0dB     0dB
@{step_3_values}    40dB    40dB    40dB    40dB
@{step_4_values}    90dB    90dB    90dB    90dB
@{step_5_values}    15dB    15dB    15dB    15dB
${BTS_ID}                  ${tl.gnbs[0].instance_id}
${MAIN_SCF_PATH}           MRBTS-${bts_id}/NRBTS-${bts_id}

*** Keywords ***
verify uplinkTxSwitching for Pcell and Scell
    [Arguments]    ${pcap_file}
    verify_uplinkTxSwitching_for_pcell_in_rrc_messages    ${pcap_file}


verify uplinkTxSwitching for FDD Pcell and TDD Scell
    [Arguments]    ${pcap_file}
    verify_uplinkTxSwitching_for_FDD_pcell_in_rrc_messages    ${pcap_file}
    verify_uplinkTxSwitching_for_TDD_scell_in_rrc_messages    ${pcap_file}


verify uplinkTxSwitching for FDD Stepwise Scell
    [Arguments]    ${pcap_file}
    verify_uplinkTxSwitching_for_FDD_stepwise_scell_in_rrc_messages    ${pcap_file}


Prepare preconditions for F+T case
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_50}    values=${step_1_values}
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_4_values}


Prepare attenuation for A1 measurements for TDD scell
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_2_values}
    BuiltIn.Sleep    5
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_50}    values=${step_2_values}


Prepare attenuation for A2 measurements for TDD scell
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_50}    values=${step_1_values}
    BuiltIn.Sleep    5
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_3_values}


Prepare preconditions for T+F case
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_2_values}


Attenuate all
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_50}    values=${step_4_values}
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_4_values}

prepare HO
    [Documentation]   A2 meas on pcell 81 and a3 to target 50
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_5_values}
    BuiltIn.Sleep    3
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_50}    values=${step_2_values}


Adjust attenuation value for single port
    [Arguments]      ${atteunator}   ${att_port}   ${value}
    att.Setup Attenuator      ${atteunator}
    att.set_attenuation     port=${att_port}    value=${value}
    ${value_port}    att.read_attenuation    port=${att_port}
    should be equal    ${value_port}db    ${value}
    [Teardown]    att.disconnect


Adjust attenuation values for multiple ports
    [Arguments]      ${atteunator}   ${att_ports}   ${values}
    att.Setup Attenuator      ${atteunator}
    att.set_ports_attenuation     ports=${att_ports}    values=${values}    confirm=True
    ${value_port}    att.read_ports_attenuation    ports=${att_ports}
    [Teardown]    att.disconnect


Perform delta precondition for subfeature D
    [Documentation]
    ...    Perform delta precondition for subfeature D

    [Arguments]
    ...    ${nrcell_scell_1}=40
    ...    ${nrcell_scell_2}=50
    ...    ${nrcell_scell_3}=60
    ...    ${nrcell_pcell}=81
    ...    ${dlSCellConfigLevelNum}=3
    ...    ${nrarfcnDl}=128840
    ...    ${nrarfcnUl}=138040
    ...    ${gscnOrSsPbchArfcn}=1609
    ...    ${maxNumOfSCellAlloc}=0
    ...    ${sCellOperationalMode}=dlOnly
    ...    ${sCellExcludelistTimerFr1}=60
    ...    ${actBufferBasedSCellAddition}=oneShot_stepWise_Dl_Fr1


    Log To Console    __Activate precondition for CB013553-D
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_1}/NRCELL_FDD-1     nrarfcnDl                  value=${nrarfcnDl}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_1}/NRCELL_FDD-1     nrarfcnUl                  value=${nrarfcnUl}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_1}                  gscnOrSsPbchArfcn          value=${gscnOrSsPbchArfcn}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_1}                  maxNumOfSCellAlloc         value=${maxNumOfSCellAlloc}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_1}                  dlSCellConfigLevelNum      value=${dlSCellConfigLevelNum}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_2}                  dlSCellConfigLevelNum      value=${dlSCellConfigLevelNum}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_3}                  dlSCellConfigLevelNum      value=${dlSCellConfigLevelNum}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}                                  sCellExcludelistTimerFr1        value=${sCellExcludelistTimerFr1}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}                                  actBufferBasedSCellAddition     value=${actBufferBasedSCellAddition}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_pcell}/NRREL-${nrcell_scell_2}      sCellOperationalMode
    ...    value=${sCellOperationalMode}
    Log To Console    __Wait for delta precondition CB013553-D activation successfully perform
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Log To Console    __delta Done, setup attenuator for Pcell with A1 measurements
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_2_values}


Perform delta for SCellAllocation
    [Arguments]
    ...    ${nrcell_scell_1}=40
    ...    ${maxNumOfSCellAlloc}=100

    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${nrcell_scell_1}    maxNumOfSCellAlloc    value=${maxNumOfSCellAlloc}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
