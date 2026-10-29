"""
:copyright: Nokia Networks
:author: Konrad Kocik
:contact: konrad.kocik@nokia.com
:maintainer: konrad.kocik@nokia.com
:contact: konrad.kocik@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.ul.objectmodelchecker.datamodel.scf.model import SCFFactory


class MySCFParameter(object):
    def __init__(self, app_version, dist_name, param_abbr, list_param, value):
        self.app_version = self._get_app_version(app_version)
        self.version = app_version
        self.dist_name = dist_name
        self.param_abbr = param_abbr
        self.list_param = list_param
        self.value = value

    def _get_app_version(self, app_version):
        for v in range(len(app_version)):
            if app_version[v] == '5':
                return str(app_version[v:])


class TestLineTopology(object):
    """ Represents topology of currently used test line """
    CLASSICAL = 'CLASSICAL'
    CLOUD = 'CLOUD'


def get_test_line_topology(cloud_topology):
    """
    Extracts test line topology from given cloud (manager) topology.
    :param cloud_topology: taken from test line's configuration file,
                           i.e. value 'CLOUD_5G_CLASSICAL_ASIKA101L_ABILA102B1_AEQA_BRANCH' stored in
                           variable ${tl.tl_cloud_topology}
    :type cloud_topology: str
    :return: extracted test line topology, one of the values form TestLineTopology enum
    :rtype: str
    """
    if 'CLASSICAL' in cloud_topology:
        return TestLineTopology.CLASSICAL
    else:
        return TestLineTopology.CLOUD


def check_whether_GPS_exists(tl_topology):
    """
    Check whether Test Line contain GPS

    :param tl_topology: type of test line topology, i.e. 'cOAM'
    :type  tl_topology: str
    :return: True if GPS exist, False otherwise
    :rtype Boolean
    """
    get_scf_file(local_dir_path='/tmp', file_name='scf_gps.xml', tl_topology=str(tl_topology))

    scf_params = load_value_from_scf(path='/tmp/scf_gps.xml')
    for scf_param in scf_params:
        if scf_param.param_abbr == 'syncInputType':
            if scf_param.value == '1pps/ToD from external GNSS receiver':
                return True
    return False


def get_scf_file(local_dir_path, file_name, tl_topology):
    """
    Get scf file from BTS via API

    :param local_dir_path: Path where will be save file
    :param local_dir_path: Str
    :param file_name: Name of scf, this name have to contain extension ".xml" ex. "scf.xml"
    :param file_name: Str
    :param tl_topology: Type of test line topology
    :type tl_topology: Str
    :return: Scf file
    :rtype file XML
    """
    tl_topology = str(tl_topology)
    if tl_topology == 'CLOUD':
        pass
    if tl_topology == 'CLASSICAL':
        _get_scf_file_admin(local_dir_path, file_name)


def _get_scf_file_admin(local_dir_path, file_name, log_dir='/tmp'):
    alias = '_ad_get_scf'
    ad = admin()
    bts_host, username, password = get_details_to_login_from_init('http')

    ad.connect_to(bts_host=bts_host, username=username, password=password, bts_port=3600,
                  reconnect_with_default_on_failure=True, name=alias, admin_api_log_dir=log_dir)
    try:
        ad.get_current_scf_file(local_dir_path=local_dir_path, file_name=file_name, connection=alias)
    finally:
        ad.teardown(connection=alias)


def load_value_from_scf(path):
    """
    Get all parameters from scf
    :param path: Path to SCF.xml
    :type path: (str)
    :return: Return list of objects
    :rtype (list of obj)
    """
    scf_params = list()
    scf_model = SCFFactory(path).get_scf_model()
    for scf_managed_object in scf_model.managed_objects:
        for param in scf_managed_object.parameters:
            if hasattr(param, 'parameters'):
                for param_l in param.parameters:
                    scf_params.append(MySCFParameter(
                        app_version=scf_managed_object.version,
                        dist_name=scf_managed_object.dist_name,
                        param_abbr=param_l.name,
                        list_param=True,
                        value=param_l.value
                    ))
            else:
                scf_params.append(MySCFParameter(
                    app_version=scf_managed_object.version,
                    dist_name=scf_managed_object.dist_name,
                    param_abbr=param.name,
                    list_param=False,
                    value=param.value
                ))
    return scf_params


def get_details_to_login_from_init(service):
    """
    Get details to login from given service.
    :param service: str e.g. 'http' or 'ssh'
    :return: tuple of str (address, username, password) e.g. ('192.168.255.129', 'toor4nsn', 'oZPS0POrRieRtu')
    :raises AttributeError when there is no service requested by user
    """
    if service == 'http':
        details_to_login = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_http_connection_details}")
    elif service == 'ssh':
        details_to_login = BuiltIn().get_variable_value("${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}")
    else:
        raise AttributeError("There is no service: {}. Only supported: 'oam' and 'ssh'".format(service))
    return details_to_login.addr, details_to_login.username, details_to_login.password
