from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


@load_moler_configuration_from_tl()
def openssl_pkcs12_export(certs, private_key, output_name, password, timeout=30):
    test_pc = DeviceFactory.get_device(name='TEST_PC')
    command = "openssl pkcs12 -export -out {} -in {} -inkey {} -password 'pass:{}'".format(output_name, certs,
                                                                                           private_key, password)
    openssl_pkcs12_export_cmd = test_pc.get_cmd(cmd_name='run_script',
                                                cmd_params={'script_command': command})
    openssl_pkcs12_export_cmd(timeout=timeout)
