import taf.gnb.oam.ne3s.ws as netact
import taf.config.scf as scf


def connect_using_netact(ip_address, netact_server_address=None, netact_server_port=10000, **kwargs):
    na_instance = netact.ws()
    na_instance.configure_connection(ip_address, netact_server_address=netact_server_address,
                                     netact_server_port=netact_server_port, **kwargs)
    if 'alias' in kwargs:
        na_instance.connect(kwargs['alias'])
    else:
        na_instance.connect()
    return na_instance


def set_parameter_using_netact(dist_name, param_changes, path_to_scf, na_instance):
    current_scf = scf.scf()
    current_scf.load_scf(path_to_scf)
    attributes = dict(current_scf.scf_operations._get_node(dist_name)._tree.attrib)
    na_instance.set_managed_object_parameter(class_name=attributes['class'], dist_name=dist_name,
                                             version_name=attributes['version'], param_changes=param_changes)


def unregister_connection(na_instance):
    na_instance.unregister()


def teardown_all_connections(na_instance):
    na_instance.teardown_all()


def unregister_and_teardown(na_instance):
    unregister_connection(na_instance)
    teardown_all_connections(na_instance)


def fetch_latest_pm_report(pm_file_path, na_instance):
    na_instance.fetch_latest_pm_report(pm_file_path=pm_file_path)


def activate_pm_counters_reporting(dist_name, path_to_scf, collection_interval, reporting_interval, na_instance):
    current_scf = scf.scf()
    current_scf.load_scf(path_to_scf)
    attributes = dict(current_scf.scf_operations._get_node(dist_name)._tree.attrib)
    na_instance.activate_pm_reporting(class_name=attributes['class'], dist_name=dist_name,
                                      version_name=attributes['version'], collection_interval=collection_interval,
                                      reporting_interval=reporting_interval)
