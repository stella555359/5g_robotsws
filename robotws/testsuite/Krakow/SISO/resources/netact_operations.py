import logging
import time
from datetime import datetime
from functools import wraps
from taf.nms.netact.interface import netact
from taf.rfrl.utilities.tl_config import get_netact_web_credentials, get_netact_ssh_credentials, get_bts_instance_id
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations


def setup_netact_if_necessary(netact_fun):
    @wraps(netact_fun)
    def wrapper(self, *args, **kwargs):
        NetActOperations().setup()
        result = netact_fun(self, *args, **kwargs)
        return result

    return wrapper


class NetActOperations(object):
    ROBOT_LIBRARY_SCOPE = 'TEST'
    __instance = None
    __initialized = None
    __plan_name = 'Testing plan {}'.format(datetime.now().strftime("%d-%m-%Y, %H:%M:%S"))

    def __new__(cls, *args, **kwargs):
        if NetActOperations.__instance is None:
            NetActOperations.__instance = super(NetActOperations, cls).__new__(cls)

        return NetActOperations.__instance

    def __init__(self):
        if self.__initialized:
            return
        self.netact = netact()
        self.plan = None
        self._already_setup = False
        self.__initialized = True

    def setup(self):
        """
        Configure NetAct credentials and create draft configuration plan
        """
        if self._already_setup:
            return
        web_credentials = get_netact_web_credentials()
        ssh_credentials = get_netact_ssh_credentials()
        self.netact.add_web_url(web_url=web_credentials['addr'], username=web_credentials['username'],
                                password=web_credentials['password'])
        self.netact.add_node(service_name='cmwas', hostname=ssh_credentials['addr'],
                             username=ssh_credentials['username'], password=ssh_credentials['password'])
        self.plan = self.netact.create_plan_configuration(name=self.__plan_name)
        self._already_setup = True

    def teardown(self):
        """
        Delete draft plan if created
        """
        if self.plan is not None:
            self.netact.delete_plan_configuration(plan=self.plan)
            self.plan = None

    @setup_netact_if_necessary
    def get_mo_from_configuration(self, mo_distname, config_type):
        """
        Get managed object content from configuration
        :param mo_distname: managed object distname from NetAct configuration
        :param config_type: actual or plan
        :return: ManagedObject object or None if given distname is not in configuration
        """
        if config_type == 'actual':
            configuration = self.netact.get_actual_configuration()
        elif config_type == 'plan':
            configuration = self.netact.get_plan_configuration(name=self.__plan_name)
        else:
            raise TypeError("'{}' is not a correct configuration type".format(config_type))

        try:
            managed_object = self.netact.get_managed_object(configuration=configuration, mo_id=mo_distname)
            return managed_object
        except Exception:
            return None

    @setup_netact_if_necessary
    def set_parameters_values_via_netact(self, parameters_dict, activate_plan=True):
        """
        Set given values to parameters in draft configuration plan, provision and validate plan.
        :param parameters_dict: dict with managed_objects as keys and dicts with pairs param_name-param_value as values
                e.g.
                {
                    'PLMN-PLMN/MRBTS-{}/EQM-1/APEQM-1/RMOD-{}': {
                        'administrativeState': '0'
                    }
                }
        :param activate_plan: if set to True activation is performed after validation, default False
        :return: None
        """
        for mo_distname, param_dict in parameters_dict.items():
            managed_object = self.get_mo_from_configuration(mo_distname, config_type='plan')
            if managed_object is None:
                managed_object = self.get_mo_from_configuration(mo_distname, config_type='actual')
                self.netact.create_managed_object(plan=self.plan, meta_class=managed_object.meta_class,
                                                  meta_version=managed_object.meta_version, mo_id=mo_distname,
                                                  **param_dict)
            else:
                self.netact.edit_managed_object(managed_object=managed_object, **param_dict)

        self.netact.provision_plan(plan_name=self.__plan_name, provisioning_operation='preactivate')
        self.netact.validate_plan(plan_name=self.__plan_name)
        if activate_plan:
            self.netact.provision_plan(plan_name=self.__plan_name, provisioning_operation='activate')

    @setup_netact_if_necessary
    def get_parameters_values_via_netact(self, parameters_dict):
        """
        Get values of given parameters from actual configuration
        :param parameters_dict: dict with managed_objects as keys and lists of parameters' names as values e.g.
                {
                    'PLMN-PLMN/MRBTS-{}/EQM-1/APEQM-1/RMOD-{}': ['administrativeState', '', ''],
                }
        :return: dict with managed_objects as keys and dicts with pairs param_name-param_value as values e.g.
                {
                    'PLMN-PLMN/MRBTS-{}/EQM-1/APEQM-1/RMOD-{}': {
                        'administrativeState': '0'
                    },
                }
        """
        param_values_dict = dict.fromkeys(parameters_dict.keys(), dict())
        actual_conf = self.netact.get_actual_configuration()
        for mo_distname, param_list in parameters_dict.items():
            managed_object = self.netact.get_managed_object(configuration=actual_conf, mo_id=mo_distname)
            for param_name in param_list:
                param_value = managed_object.parameters[param_name]
                param_values_dict[mo_distname].update({param_name: param_value})
        logging.info(param_values_dict)
        return param_values_dict

    @setup_netact_if_necessary
    def verify_parameters_values_via_netact(self, expected_parameters_dict):
        """
        Check if parameters in actual configuration have given values
        :param expected_parameters_dict: dict with managed_objects as keys and dicts with pairs param_name-param_value
                as values e.g.
                {
                    'PLMN-PLMN/MRBTS-{}/EQM-1/APEQM-1/RMOD-{}': {
                        'administrativeState': '0'
                    }
                }
        :raises: ValueError if any parameter has incorrect value
        """
        get_params_dict = {}
        for mo_distname, params_dict in expected_parameters_dict.items():
            get_params_dict[mo_distname] = params_dict.keys()

        actual_params_values = self.get_parameters_values_via_netact(get_params_dict)

        for mo_distname, exp_values in expected_parameters_dict.items():
            act_values = actual_params_values[mo_distname]
            for exp_param, exp_value in exp_values.items():
                act_value = act_values[exp_param]
                if exp_value == act_value:
                    logging.info("Expected value of {} matches actual value end is equal to {}".format(exp_param,
                                                                                                       act_value))
                else:
                    error_msg = "Expected value of {} doesn't match actual value: {} != {}".format(exp_param,
                                                                                                   exp_value,
                                                                                                   act_value)
                    raise ValueError(error_msg)

    @setup_netact_if_necessary
    def perform_rmod_operation_via_netact(self, operation, rmod_id=1, activate_plan=True):
        """
        Set necessary parameters in plan to perform given operation, provision, validate and activate.
        :param operation: available operations: lock, unlock
        :param rmod_id: RMOD id from configuration
        :param activate_plan: if set to False activation is not performed after validation, default True
        :return: None
        """
        operation_mapping = {
            'lock': '0',
            'unlock': '2'
        }
        mrbts_id = get_bts_instance_id()
        rmod_dist_name = 'PLMN-PLMN/MRBTS-{}/EQM-1/APEQM-1/RMOD-{}'.format(mrbts_id, rmod_id)
        params_dict = {
            rmod_dist_name: {
                'administrativeState': operation_mapping[operation]
            }
        }
        self.set_parameters_values_via_netact(params_dict, activate_plan)
        self.verify_parameters_values_via_netact(params_dict)

    @setup_netact_if_necessary
    def perform_cell_operation_via_netact(self, operation, cells_ids=None, rmod_id=None, gnb_id=0, activate_plan=True):
        """
        Set necessary parameters in plan to perform given operation, provision, validate and activate.
        :param operation: available operations: lock, unlock
        :param cells_ids: list of cells' global ids to perform operation on
        :param rmod_id: RMOD id from configuration - if given operation is performed on all cells assigned
                        to this rmod; if cells_ids param is also given it works as a filter for rmod cells
        :param gnb_id: gNB id - related to Test Line configuration, default 0
        :param activate_plan: if set to False activation is not performed after validation, default True
        :raises ValueError: raised if both cells_ids and rmod_id are None
        :return: None
        """
        # operation name: parameter value for NetAct
        operation_mapping = {
            'lock': '0',
            'unlock': '2'
        }
        gnb_cell = GnbCellOperations()
        if rmod_id is not None:
            target_cells_ids = gnb_cell.get_all_cells_id(ru_id=rmod_id)
            if cells_ids is not None:
                target_cells_ids = [cell_id for cell_id in cells_ids if cell_id in target_cells_ids]
        elif cells_ids is not None:
            target_cells_ids = cells_ids
        else:
            raise ValueError("Cells to {} not specified!".format(operation))

        distname = gnb_cell.adjust_dist_name('PLMN-PLMN/MRBTS-{}/NRBTS-{}', bts_id=gnb_id)
        params_dict = dict()
        for cell_id in target_cells_ids:
            cell_dist_name = '{}/NRCELL-{}'.format(distname, cell_id)
            params_dict[cell_dist_name] = {
                    'administrativeState': operation_mapping[operation]
            }
        self.set_parameters_values_via_netact(params_dict, activate_plan)
        time.sleep(10)
        self.verify_parameters_values_via_netact(params_dict)
