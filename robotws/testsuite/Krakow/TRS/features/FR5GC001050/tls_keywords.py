from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
mplane_address = tl.gnbs[0].dus[0].f1_m_ip_addr.v4.split('/')[0]


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def _nmap_scan(bts_id=0, du_id=0):
    vm = DeviceFactory.get_device("GNB{}_DU{}".format(bts_id, du_id), initial_state="UNIX_LOCAL")
    nmap_cmd = vm.get_cmd(cmd_name="nmap", cmd_params={"options": "--script ssl-enum-ciphers", "ip": mplane_address})
    return nmap_cmd()


def check_cipher_suites(tls_version, cipher_suites, bts_id=0, du_id=0):
    """
    Check if all cipher suites are in nmap output and tls version is as expected.

    :param tls_version: tls version, e.g. TLSv1.2
    :param cipher_suites:  list of expected cipher suites
    :param bts_id: ID of BTS
    :param du_id: ID of DU
    :return: output of openssl s_client command
    """
    nmap_output = _nmap_scan(bts_id=0, du_id=0)
    nmap_tls_versions = nmap_output['CRYPTO_PROTOCOLS']
    MolerTest.info("TLS versions:", dump=nmap_tls_versions)
    if tls_version not in nmap_tls_versions:
        MolerTest.error("Expected tls version ({}) not in nmap output ({})".format(tls_version, nmap_tls_versions),
                        raise_exception=True)
    nmap_cipher_suites = nmap_output['CIPHERS']
    MolerTest.info("Expected cipher suites:", dump=cipher_suites)
    MolerTest.info("Nmap cipher suites:", dump=nmap_cipher_suites)
    suites_diff = list(set(nmap_cipher_suites).symmetric_difference(set(cipher_suites)))
    if suites_diff:
        error_dict = {"Expected Cipher Suites": cipher_suites, "Cipher Suites in Nmap output": nmap_cipher_suites,
                      "Diff": suites_diff}
        MolerTest.error("Incorrect cipher suites:", dump=error_dict, raise_exception=True)
