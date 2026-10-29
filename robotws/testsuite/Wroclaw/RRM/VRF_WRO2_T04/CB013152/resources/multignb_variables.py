from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


def apply_testlines_variables(testline):
    testline_ips = [test_pc.default_ssh_connection_details.addr for test_pc in testline.test_pcs[1:]]
    BuiltIn().set_suite_variable('@{REMOTE_HOSTS}', *testline_ips)

    for idx, ip in enumerate(testline_ips, start=1):
        BuiltIn().set_suite_variable('${REMOTE_HOST_' + str(idx) + '_IP}', ip)


@keyword
def get_remote_host_ip():
    testline_ips = [test_pc.default_ssh_connection_details.addr for test_pc in testline.test_pcs[1:]]
    if testline_ips:
        remote_host_ip = testline_ips[0]
        BuiltIn().log('remote_host : {}'.format(remote_host_ip))
        return remote_host_ip
    else:
        BuiltIn().log_warning('Remote host is not present')
        return None


testline = BuiltIn().get_variable_value('${tl}')
apply_testlines_variables(testline)
