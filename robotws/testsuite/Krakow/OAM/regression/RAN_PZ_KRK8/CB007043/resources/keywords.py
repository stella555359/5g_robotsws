import logging
from parameters import *
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.commissioning import GenericCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def check_preconditions():
    BuiltIn().log_to_console(f"\n ***  Checking parameters  ***")
    verify_slcelldrconf_moc_not_exists()
    class_name = "com.nokia.srbts.mnl:TRBLCADM"
    parameter_checklist = preconditions_parameters
    gnb_operations = GnbDuOperations()
    check_for_mandatory_parameters(class_name)
    for param_name in preconditions_parameters:
        gnb_operations.get_param_value(param_name, bts_id=0, du_id=0)
        BuiltIn().log_to_console(f"{param_name} | checked")
    verify_parameters_value_is_false()
    verify_if_parameters_are_in_moc(class_name, parameter_checklist)


def check_postconditions():
    class_name = 'com.nokia.srbts.mnl:SLCELLDRCONF'
    parameter_checklist = postconditions_parameters
    gnb_operations = GnbDuOperations()
    BuiltIn().log_to_console(f"\n ***  Checking parameters  ***")
    check_for_mandatory_parameters(class_name)
    verify_parameters_value_is_false()
    for param_name in postconditions_parameters:
        gnb_operations.get_param_value(param_name, bts_id=0, du_id=0)
        BuiltIn().log_to_console(f"{param_name} | checked")
    verify_if_parameters_are_in_moc(class_name, parameter_checklist)
    check_if_migration_succeeds()


def verify_parameters_value_is_false():
    false_params_value = []
    gnb_operations = GnbDuOperations()
    gnb_operation = GenericCommissioning()
    for param_name in false_parameters:
        param_value = gnb_operations.get_param_value(param_name, bts_id=0, du_id=0)
        false_params_value.append(param_value)
        BuiltIn().log_to_console(f"{param_name} | checked")
    if all(values == "false" for values in false_params_value):
        false_check = []
        class_name = "com.nokia.srbts.mnl:FEATCADM"
        result = gnb_operation.get_all_params_under_class_name(class_name, bts_id=0, du_id=0)
        false_check.append(result)
        param_dict = false_check[0][0]['params']
        param_names = []
        for params in param_dict:
            param_names.append(params)
        if all(params in param_names for params in false_parameters):
            BuiltIn().log_to_console(f"All mandatory values are set to false.")
            print("All mandatory values are set to false.")
        else:
            raise ExecutionFailed(
                message=f"Parameters do not match in FEATCADM. Please check your config",
                continue_on_failure=False
            )
    else:
        raise ExecutionFailed(
            message=f"At least one parameter value is not to false. Please check your config.",
            continue_on_failure=False
        )


def check_for_mandatory_parameters(class_name):
    mandatory_list = []
    gnb_operations = GnbDuOperations()
    gnb_operation = GenericCommissioning()
    for param_name in mandatory_parameters:
        any_value = gnb_operations.get_param_value(param_name, bts_id=0, du_id=0)
        mandatory_list.append(any_value)
        BuiltIn().log_to_console(f"{param_name} | checked")
    if any(item for item in mandatory_list):
        mandatory_check = []
        result = gnb_operation.get_all_params_under_class_name(class_name, bts_id=0, du_id=0)
        mandatory_check.append(result)
        param_dict = mandatory_check[0][0]['params']
        param_names = []
        for params in param_dict:
            param_names.append(params)
        if any(params in param_names for params in mandatory_parameters):
            return
        else:
            raise ExecutionFailed(
                message=f"At least one mandatory parameter has to be configured. Please check your config",
                continue_on_failure=False
            )
    else:
        raise ExecutionFailed(
            message=f"There must be at least one mandatory parameter configured..",
            continue_on_failure=False
        )


def check_if_migration_succeeds():
    migration_check = []
    class_name = "com.nokia.srbts.mnl:TRBLCADM"
    gnb_operation = GenericCommissioning()
    result = gnb_operation.get_all_params_under_class_name(class_name, bts_id=0, du_id=0)
    migration_check.append(result)
    param_dict = migration_check[0][0]['params']
    param_names = []
    for params in param_dict:
        param_names.append(params)
    if any(params in param_names for params in preconditions_parameters):
        raise ExecutionFailed(
            message=f"Migration Failed!",
            continue_on_failure=False
        )
    else:
        BuiltIn().log_to_console(f"\n* Migration successful *")
        print("* Migration successful *")


def verify_slcelldrconf_moc_not_exists():
    moc_check = []
    class_name = 'com.nokia.srbts.mnl:SLCELLDRCONF'
    gnb_operation = GenericCommissioning()
    check_result = gnb_operation.get_all_params_under_class_name(class_name, bts_id=0, du_id=0)
    moc_check.append(check_result)
    if any(param for param in moc_check):
        logging.warning("MIGRATION FAILED!")
        raise ExecutionFailed(
            message=f"SLCELLDRCONF MOC should not exist in current configuration!",
            continue_on_failure=False
        )
    else:
        BuiltIn().log_to_console(f"\n* MOC verified *")
        print("* MOC verified *")


def verify_if_parameters_are_in_moc(class_name, parameter_checklist):
    moc_check = []
    gnb_operation = GenericCommissioning()
    result = gnb_operation.get_all_params_under_class_name(class_name, bts_id=0, du_id=0)
    moc_check.append(result)
    param_dict = moc_check[0][0]['params']
    param_names = []
    for params in param_dict:
        param_names.append(params)
    if all(params in param_names for params in parameter_checklist):
        BuiltIn().log_to_console(class_name + "MOC verified.")
        print(class_name + " MOC verified.")
    else:
        raise ExecutionFailed(
            message=f"Parameters do not exist in TRBLCADM MOC - please check your config. Migration Failed",
            continue_on_failure=False
        )
