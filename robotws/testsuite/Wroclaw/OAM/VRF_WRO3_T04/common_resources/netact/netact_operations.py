import taf.gnb.oam.ne3s.ws as netact
import taf.config.scf as scf


def activate_pm_counters_reporting(dist_name, path_to_scf, reporting_interval, na_instance):
    current_scf = scf.scf()
    current_scf.load_scf(path_to_scf)
    attributes = dict(current_scf.scf_operations._get_node(dist_name)._tree.attrib)
    return na_instance.activate_pm_reporting(class_name=attributes['class'], dist_name=dist_name,
                                             version_name=attributes['version'],
                                             reporting_interval=reporting_interval)


def configure_cmp_server_using_netact(na_instance, dist_name, psk, ref_number, server_type, timeout=400):
    return na_instance.configure_cmp_server(dist_name=dist_name, psk=psk, ref_number=ref_number,
                                            server_type=server_type, timeout=timeout)


def connect_using_netact(ip_address, debug, debug_log_path, netact_server_address=None,
                         netact_server_port=10000, **kwargs):
    na_instance = netact.ws()
    na_instance.configure_connection(ip_address, debug=debug, debug_log_path=debug_log_path,
                                     netact_server_address=netact_server_address,
                                     netact_server_port=netact_server_port, **kwargs)
    if 'alias' in kwargs:
        na_instance.connect(kwargs['alias'])
    else:
        na_instance.connect()
    return na_instance


def fetch_latest_pm_report(pm_file_path, na_instance):
    return na_instance.fetch_latest_pm_report(pm_file_path=pm_file_path)


def get_active_faults_using_netact(na_instance):
    return na_instance.get_active_faults(timeout=600)


def get_audit_trail_logs(na_instance, adaptation_version, path):
    return na_instance.get_audit_trail_logs(destination_path=path, adaptation_version=adaptation_version,
                                            timeout=1200)


def get_scf_from_netact(na_instance, path_to_scf):
    return na_instance.get_current_plan(path_to_scf)


def initialize_certificate(na_instance, server_type, dist_name, timeout):
    return na_instance.initialize_certificate(server_type=server_type, dist_name=dist_name, timeout=timeout)


def install_certificate_using_netact(na_instance, cert_dist_name, path_to_cert, timeout):
    return na_instance.install_certificate(cert_dist_name=cert_dist_name, path_to_cert=path_to_cert,
                                           timeout=timeout)


def delete_certificate_using_netact(na_instance, cert_dist_name, cert_fingerprint, timeout):
    return na_instance.delete_certificate(cert_dist_name=cert_dist_name, cert_fingerprint=cert_fingerprint,
                                          timeout=timeout)


def update_cmp_key_using_netact(na_instance, server_type, dist_name, timeout):
    return na_instance.update_certificate(dist_name=dist_name, server_type=server_type, timeout=timeout)


def set_local_account_from_netact(mrbts_id, username, password, username_type, na_instance, timeout=400):
    return na_instance.set_local_account(adaptation_version=mrbts_id, user_type=username_type, username=username,
                                         password=password, timeout=timeout)


def set_parameter_using_netact(dist_name, param_changes, path_to_scf, na_instance):
    current_scf = scf.scf()
    current_scf.load_scf(path_to_scf)
    attributes = dict(current_scf.scf_operations._get_node(dist_name)._tree.attrib)
    return na_instance.set_managed_object_parameter(class_name=attributes['class'], dist_name=dist_name,
                                                    version_name=attributes['version'], param_changes=param_changes)


def teardown_all_connections(na_instance):
    return na_instance.teardown_all()


def unregister_and_teardown(na_instance):
    unregister_connection(na_instance)
    teardown_all_connections(na_instance)


def unregister_connection(na_instance):
    return na_instance.unregister()


def upload_scf_using_netact(path_to_scf, na_instance):
    return na_instance.set_parameter_by_scf(path_to_scf)
