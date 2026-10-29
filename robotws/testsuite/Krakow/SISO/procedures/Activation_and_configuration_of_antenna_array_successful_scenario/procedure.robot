*** Settings ***

Library     taf/rfrl/procedures/resources/python/beamset_configurator.py
Resource    taf/rfrl/bts/robot/gnb.robot
Variables    ./variables.py

*** Keywords ***
Activation and configuration of antenna array successful scenario
    [Arguments]  ${beamset}=all
    ${beam_sets}  Run Keyword If  '${beamset}'=='all'  Get Possible BeamSets Configuration
    ...     ELSE  Create List  ${beamset}

    Verify nrarfcn on gNB
    FOR  ${beam_set}  IN  @{beam_sets}
         Verify Configuration Parameters For Cell Group    param_dict=${cell_group_params_to_check}
         Verify Configuration Parameters For Cell     param_dict=${cell_params_to_check}
         Set new beamSet value via GUI for all cells    basicBeamSet=${beam_set}
         Wait Until Keyword Succeeds     900 sec     5 sec   Verify gNB is onAir
    END
