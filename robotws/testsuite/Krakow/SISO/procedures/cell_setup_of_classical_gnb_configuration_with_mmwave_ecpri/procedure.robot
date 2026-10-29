*** Settings ***

Library     taf/rfrl/procedures/resources/python/beamset_configurator.py
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   taf/rfrl/procedures/SISO/variables/siso_procedures_variables.py

*** Keywords ***
Cell setup of Classical gNB
    [Arguments]  ${beam_sets}=${None}
    ${beam_sets}  Run Keyword If  ${beam_sets} == ${None}  Get Possible BeamSets Configuration
    ...     ELSE    Set Variable	${beam_sets}

    Verify nrarfcn on gNB
    Verify basic beam set on gNB    beam_set=${beam_sets}
    Verify Configuration Parameters For Cell Group    param_dict=${cell_group_params_to_check}
    Verify Configuration Parameters For Cell     param_dict=${cell_params_to_check}
    Verify gNB is onAir
