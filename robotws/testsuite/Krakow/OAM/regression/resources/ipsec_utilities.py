from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


@load_moler_configuration_from_tl()
def start_ipsec_on_ute(timeout=10):
    test_pc = DeviceFactory.get_device(name='TEST_PC')
    ip_a_cmd = test_pc.get_cmd(cmd_name='ip_addr', cmd_params={'options': 'add 10.10.10.250/24 dev eth1'})
    sudo_ip_a_cmd = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': ip_a_cmd})
    sudo_ip_a_cmd(timeout=timeout)
    ipsec_cmd = test_pc.get_cmd(cmd_name='ipsec', cmd_params={'options': 'start'})
    sudo_ipsec_cmd = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': ipsec_cmd})
    sudo_ipsec_cmd(timeout=timeout)


@load_moler_configuration_from_tl()
def configure_ipsec_on_ute(ca_cert_path, cert_path, key_path, ipsec_conf_path, ipsec_secrets_path, timeout=10):
    test_pc = DeviceFactory.get_device(name='TEST_PC')
    cp_ca_cert = test_pc.get_cmd(cmd_name='cp', cmd_params={'src': ca_cert_path, 'dst': '/etc/ipsec.d/cacerts/'})
    sudo_cp_ca_cert = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cp_ca_cert})
    sudo_cp_ca_cert(timeout=timeout)
    cp_cert = test_pc.get_cmd(cmd_name='cp', cmd_params={'src': cert_path, 'dst': '/etc/ipsec.d/certs/'})
    sudo_cp_cert = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cp_cert})
    sudo_cp_cert(timeout=timeout)
    cp_key = test_pc.get_cmd(cmd_name='cp', cmd_params={'src': key_path, 'dst': '/etc/ipsec.d/private/'})
    sudo_cp_key = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cp_key})
    sudo_cp_key(timeout=timeout)
    cp_ipsec_conf = test_pc.get_cmd(cmd_name='cp', cmd_params={'src': ipsec_conf_path, 'dst': '/etc/'})
    sudo_cp_ipsec_conf = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cp_ipsec_conf})
    sudo_cp_ipsec_conf(timeout=timeout)
    cp_ipsec_secrets = test_pc.get_cmd(cmd_name='cp', cmd_params={'src': ipsec_secrets_path, 'dst': '/etc/'})
    sudo_cp_ipsec_secrets = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cp_ipsec_secrets})
    sudo_cp_ipsec_secrets(timeout=timeout)
    ipsec_cmd = test_pc.get_cmd(cmd_name='ipsec', cmd_params={'options': 'reload'})
    sudo_ipsec_cmd = test_pc.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': ipsec_cmd})
    sudo_ipsec_cmd(timeout=timeout)
