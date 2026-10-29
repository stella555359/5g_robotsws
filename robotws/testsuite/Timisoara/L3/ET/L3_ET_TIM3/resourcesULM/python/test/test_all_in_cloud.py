from testsuite.Ulm.resources.Common.python import all_in_cloud

try:
    import unittest2 as unittest
except ImportError:
    import unittest  # type: ignore

try:
    import unittest.mock as mock
except ImportError:
    import mock  # type: ignore


KUBECTL_GET_PM_OUTPUT = """
NAME                                                             READY   STATUS    RESTARTS   AGE
ute-7-5-ute5gaic012-cpcl-0                                       3/3     Running   0          113m
ute-7-5-ute5gaic012-cpif-0                                       7/7     Running   0          113m
ute-7-5-ute5gaic012-cpnb-0                                       3/3     Running   0          113m
ute-7-5-ute5gaic012-cpnrt-0                                      3/3     Running   0          113m
ute-7-5-ute5gaic012-cpue-0                                       2/2     Running   0          113m
ute-7-5-ute5gaic012-healing-controller-5f67787b85-bpjw9          1/1     Running   0          3h53m
ute-7-5-ute5gaic012-kubeapisymptomdataprovider-ddfdb9967-kzttd   1/1     Running   0          113m
ute-7-5-ute5gaic012-logservice-6f68746947-pgkbq                  2/2     Running   0          3h53m
ute-7-5-ute5gaic012-lwsd-0                                       1/1     Running   0          113m
ute-7-5-ute5gaic012-oamasm-0                                     6/6     Running   0          113m
ute-7-5-ute5gaic012-oamcm-0                                      3/3     Running   0          113m
ute-7-5-ute5gaic012-oamconfig-0                                  7/7     Running   0          113m
ute-7-5-ute5gaic012-oamext-0                                     26/26   Running   0          113m
ute-7-5-ute5gaic012-oamfm-0                                      3/3     Running   0          113m
ute-7-5-ute5gaic012-oampm-0                                      2/2     Running   0          113m
ute-7-5-ute5gaic012-pm-0                                         2/2     Running   0          113m
ute-7-5-ute5gaic012-rcpfm-0                                      1/1     Running   0          113m
ute-7-5-ute5gaic012-rcpsdl-0                                     2/2     Running   0          113m
ute-7-5-ute5gaic012-rcpsdl-1                                     2/2     Running   0          113m
ute-7-5-ute5gaic012-rcpsdl-2                                     2/2     Running   0          113m
ute-7-5-ute5gaic012-rcpum-6b99f44bf7-qbzff                       1/1     Running   0          113m
ute-7-5-ute5gaic012-securestorage-0                              4/4     Running   0          113m
ute-7-5-ute5gaic012-trsconfig-6659dc84c4-bmzms                   1/1     Running   0          113m
ute-7-5-ute5gaic012-twamp-0                                      4/4     Running   0          113m
ute-7-5-ute5gaic012-upue-0                                       6/6     Running   0          113m
"""

KUBECTL_GET_PMCORE_OUTPUT = """
ctr-7-5-ute5gaic012-pmcore ctr-7-5-ute5gaic012-pm-rest-server
"""


def get_robot_variable(name):
    return {'${tl}': create_testline_configuration(),
            '${OUTPUT DIR}': '/fake/output/dir'}.get(name)


def create_testline_configuration():

    du1 = mock.MagicMock(name='du1')
    du1.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr = 'vdu_host'
    du1.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username = 'vdu_user'
    du1.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password = 'vdu_pass'

    gnb1 = mock.MagicMock(name='gnb1')
    gnb1.dus = [du1]
    gnb1.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr = 'cu_host'
    gnb1.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username = 'cu_user'
    gnb1.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username = 'cu_pass'

    tl = mock.MagicMock(name="tl")
    tl.gnbs = [gnb1]
    return tl


def connect_mock(hostname, username, password):
    def execute_vdu(command):
        if command.startswith('kubectl get pod -n'):
            return KUBECTL_GET_PM_OUTPUT
        if command.startswith('kubectl get pods -n'):
            return KUBECTL_GET_PMCORE_OUTPUT

    def execute_cu(command):
        if command.startswith('kubectl get pod -n'):
            return KUBECTL_GET_PM_OUTPUT
        if command.startswith('kubectl get pods -n'):
            return KUBECTL_GET_PMCORE_OUTPUT

    connection = mock.MagicMock()
    connection.execute = {'vdu_host': execute_vdu,
                          'cu_host': execute_cu}[hostname]

    return connection


class TestAllInCloud(unittest.TestCase):
    def setUp(self):
        ssh_patcher = mock.patch('testsuite.Ulm.resources.Common.python.all_in_cloud.connect', connect_mock)
        self.ssh_mock = ssh_patcher.start()
        # self.ssh_mock.return_value.execute = ssh_execute
        self.ssh_mock = connect_mock
        self.addCleanup(ssh_patcher.stop)

        robot_builtin_patcher = mock.patch('testsuite.Ulm.resources.Common.python.all_in_cloud.BuiltIn')
        robot_builtin_mock = robot_builtin_patcher.start()
        robot_builtin_mock.BuiltIn.return_value.get_variable_value = get_robot_variable
        self.addCleanup(robot_builtin_patcher.stop)

    def test_get_pm_pod_and_container_on_vdu(self):
        pods = all_in_cloud.get_pm_pod_and_container_on_vdu(0)
        self.assertEqual(pods, ('ute-7-5-ute5gaic012-pm-0', 'ctr-7-5-ute5gaic012-pmcore'))

        pods = all_in_cloud.get_pm_pod_and_container_on_cu(0)
        self.assertEqual(pods, ('ute-7-5-ute5gaic012-pm-0', 'ctr-7-5-ute5gaic012-pmcore'))


if __name__ == '__main__':
    unittest.main()
