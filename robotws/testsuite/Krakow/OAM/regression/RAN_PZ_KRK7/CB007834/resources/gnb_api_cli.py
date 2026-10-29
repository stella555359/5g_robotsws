"""
gNB methods for recommisioning and parameter/status management

:author: Bartłomiej Bieńko (bartlomiej.bienko@nokia.com)
:copyright: Bartłomiej Bieńko (bartlomiej.bienko@nokia.com)
:contact: i_5g_pz_mmw_krk_7sg_test@internal.nsn.com
"""
from functools import wraps

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

from taf.sbts.oam.coam.admin import admin


def admin_connect(admin_method):
    @wraps(admin_method)
    def wrapper(self, *args, **kwargs):
        try:
            self.connect()
            result = admin_method(self, *args, **kwargs)
            return result
        finally:
            self.disconnect()
    return wrapper


class GnbApiCli:
    """
    GnbApiCLI class is an interface to communicate with ASiR.
    """

    def __init__(self, ip=None, username=None, password=None, mrbts_id=None):
        self.tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)
        self.ip = ip if ip else self.tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]
        self.username = username if username else self.tl.gnbs[0].cu.oam_http_connection_details.username
        self.password = password if password else self.tl.gnbs[0].cu.oam_http_connection_details.password
        self.mrbts_id = mrbts_id if mrbts_id else self.tl.gnbs[0].instance_id
        self.admin = admin()
        self._already_connected = False

    def connect(self):
        if self._already_connected:
            logger.debug("The connection (via admin) has already been established; nothing to do")
            return

        logger.debug("Establishing connection (via admin) to {}, credentials are {} with password {}"
                     .format(self.ip, self.username, self.password))
        self.admin.connect_to(bts_host=self.ip, username=self.username, password=self.password)
        logger.debug("Connection (via admin) with {} established properly!")
        self._already_connected = True

    def disconnect(self):
        if not self._already_connected:
            logger.debug("The connection (via admin) has not been established yet; nothing to do")
            return
        logger.debug("Disconnecting (via admin) with {}".format(self.ip))
        self.admin.teardown_admin()
        logger.debug("Connection with {} (via admin) has been successfully closed!".format(self.ip))

    def teardown_all_admin_aliases(self):
        self.admin.teardown_all_aliases_for_admin()

    @admin_connect
    def parameter_recommissioning(self,
                                  dist_name,
                                  parameter,
                                  operation,
                                  value,
                                  skip_parameter_relation_errors=False,
                                  should_activate=True,
                                  timeout=300,
                                  connection=None):
        logger.debug("Performing parameter recommissioning: dist_name={} | parameter={} | operation={} | value={}".
                     format(dist_name, parameter, operation, value))
        recommissioning_status = self.admin.perform_parameter_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            value=value,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate,
            timeout=timeout,
            connection=connection)
        logger.debug("Recommissioning has been performed; recommissioning status: {}".format(recommissioning_status))

    @admin_connect
    def object_recommissioning(self,
                               dist_name,
                               parameter,
                               operation,
                               skip_parameter_relation_errors=False,
                               should_activate=True,
                               timeout=300,
                               connection=None,):
        logger.debug("Performing object recommissioning: dist_name={} | parameter={} | operation={} ".
                     format(dist_name, parameter, operation))
        recommissioning_status = self.admin.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate,
            timeout=timeout,
            connection=connection)
        logger.debug("recommissioning has been performed; recommissioning status: {}".format(recommissioning_status))

    @admin_connect
    def get_current_scf_file(self, local_dir_path, file_name):
        return self.admin.get_current_scf_file(local_dir_path, file_name)

    @admin_connect
    def validate_scf_online(self, scf_file):
        return self.admin.validate_scf_online(scf_file)

    @admin_connect
    def get_cell_num(self, cell_type='nr'):
        info = self.admin.get_cells_info(cell_type=cell_type)
        nr_cell = [cell['globalCellId'] for cell in info]
        if nr_cell:
            return nr_cell
        raise Exception('Not found cell num in {}'.format(info))

    def set_x2c_interface_signalling(self, interval, skip_parameter_relation_errors=True, should_activate=True):
        valid_value = ['disabled', '5min', '15min', '30min', '60min', '360min']
        if interval in valid_value:
            parameters = [
                {
                    "parameterName": "miNrX2CC",
                    "operation": "update",
                    "value": "{}".format(interval),
                }
            ]
            self.object_recommissioning(
                dist_name='MRBTS-{0}/NRBTS-{0}/NRPMRNL-1'.format(self.mrbts_id),
                parameter=parameters,
                operation="update",
                skip_parameter_relation_errors=skip_parameter_relation_errors,
                should_activate=should_activate)

    @admin_connect
    def rollback_software(self, timeout):
        self.admin.rollback_software(timeout=timeout)

    @admin_connect
    def get_cells_info(self):
        return self.admin.get_cells_info(cell_type='nr')

    @admin_connect
    def get_managed_objects(self, class_name, timeout=10):
        return self.admin.get_managed_objects(class_name=class_name, timeout=timeout)

    @admin_connect
    def block_cells(self):
        self.admin.block_all_cells(rat='NR')
        self.admin.block_all_cells(rat='LTE')

    @admin_connect
    def unblock_cells(self):
        self.admin.unblock_all_cells(rat='NR')
        self.admin.unblock_all_cells(rat='LTE')

    @admin_connect
    def get_counters_info(self, dist_name, timeout):
        return self.admin.get_counters_info(dist_name=dist_name, timeout=timeout)

    @admin_connect
    def disable_ethernet_port_secutity(self):
        self.admin.disable_ethernet_port_security()
