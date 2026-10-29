*** Settings ***
Documentation
...   Resource files for regression testing of feature CB010215
...   author: Marek Bodziony
...   contact: marek.bodziony@nokia.com

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME      gnbscf
Library     testsuite.Krakow.SISO.resources.netact_operations.NetActOperations    WITH NAME    netact
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   CB010215_deltas.py
Variables   PDL_validation_errors.py

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    User Account has Default Password
${uDTX_false_and_TC_true_validation_error}                  *${PDL_validation_error_when_uDTX_false_and_TC_true}*
${uDTX_true_and_TC_true_with_CRG_validation_error_Rel5}     *${PDL_validation_error_when_CRG_enabled}*

*** Keywords ***
Change param '${param_name}' to ${param_value} for Rel${n}
    ${cell_id}    Evaluate     ${n}-4
    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/LNBTS-${tl.gnbs[0].global_bts_id}/LNCEL-${cell_id}
    ...     parameter=${param_name}    value=${param_value}
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Activate uDTX with Traffic Concentration on ${RU_rel}
    gnbscf.perform_bts_delta_commissioning      delta=${activate_uDTX_with_TC_delta_${RU_rel}}   bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Activate uDTX without Traffic Concentration on ${RU_rel}
    gnbscf.perform_bts_delta_commissioning      delta=${activate_uDTX_without_TC_delta_${RU_rel}}   bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Deactivate uDTX on ${RU_rel}
    gnbscf.perform_bts_delta_commissioning      delta=${deactivate_uDTX_${RU_rel}}   bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Activate Traffic Concentration on ${RU_rel}
    gnbscf.perform_bts_delta_commissioning      delta=${activate_TC_Rel5}   bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Deactivate uDTX while Traffic Concentration enabled and expect validation error on ${RU_rel}
    Run Keyword And Expect Error
    ...         ${uDTX_false_and_TC_true_validation_error}
    ...         Deactivate uDTX on ${RU_rel}

Activate Traffic Concentration while uDTX enabled and CRG configured and expect validation error on ${RU_rel}
    Run Keyword And Expect Error
    ...         ${uDTX_true_and_TC_true_with_CRG_validation_error_Rel5}
    ...         Activate Traffic Concentration on ${RU_rel}

Verify if 'actMicroDtx' is set to false in NetAct for ${RU_rel}
    sleep   10
    netact.verify_parameters_values_via_netact     ${actMicroDtx_false_${RU_rel}}
    [Teardown]  netact.teardown

Verify if 'allowTrafficConcentration' is set to false in NetAct for ${RU_rel}
    sleep   10
    netact.verify_parameters_values_via_netact     ${allowTrafficConcentration_false_${RU_rel}}
    [Teardown]  netact.teardown

Enable Cell Resource Groups for Rel5
    gnbscf.perform_bts_delta_commissioning      delta=${enable_CRG_Rel5}   bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}

Disable Cell Resource Groups for Rel5
    gnbscf.perform_bts_delta_commissioning      delta=${disable_CRG_Rel5}   bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}
