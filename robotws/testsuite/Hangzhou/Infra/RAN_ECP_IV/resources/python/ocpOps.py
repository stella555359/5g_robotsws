import os
import time
import yaml
import json
from robot.utils import timestr_to_secs
from sshi import sshi


class ocpOps:
    def __init__(self):
        self.issh = sshi()

    def connect_to_ssh(self, host, username, password, keyfile=''):
        self.issh.connect_to(host, username, password, keyfile=keyfile)

    def get_ocp_release(self):
        return self.issh.execute("oc get nokiaclusters \
                                  | grep -v NAME |awk '{print $1}' \
                                  | xargs -i kubectl get nokiaclusters {} -o yaml \
                                  | grep 'nokiaRelease:'")

    def ocp_release_should_be(self, release):
        ocp_release = self.get_ocp_release()
        if release not in ocp_release:
            raise AssertionError("ocp release mismatch:[%s][%s]." % (release, ocp_release))

    def nodes_status_should_be_ready(self, node=None):
        if not node:
            res = self.issh.execute("kubectl get nodes | grep -v STATUS |awk '{print $1, $2}'")
        else:
            res = self.issh.execute("kubectl get nodes %s| grep -v STATUS |awk '{print $1, $2}'" % (node))
        lines = res.splitlines()
        for line in lines:
            if not line or 'kubectl' in line or 'core' in line or 'root' in line:
                continue
            if 'Ready' in line:
                continue
            raise AssertionError("node status abnormal:[%s] [%s]." % (node, line))

    def pods_status_should_be_ok(self, namespace=None):
        if not namespace:
            kube_cmd = "kubectl get pod -A \
                        -o jsonpath=\"{range .items[*]} {.metadata.name} {.status.phase} {'\\n'} {end}\""
        else:
            kube_cmd = "kubectl get pod -n %s \
                        -o jsonpath=\"{range .items[*]} {.metadata.name} {.status.phase} {'\\n'} {end}\"" % (namespace)
        res = self.issh.execute(kube_cmd)
        lines = res.splitlines()
        for line in lines:
            if not line or 'kubectl' in line or 'core' in line or 'root' in line or 'installer' in line:
                continue
            if 'Running' in line or 'Succeeded' in line or 'Completed' in line:
                continue
            raise AssertionError("pod status abnormal:[%s] [%s]." % (namespace, line))

    def operators_available_should_be_true(self, operator=None):
        if not operator:
            res = self.issh.execute("oc get co | grep -v AVAILABLE |awk '{print $1, $3}'")
        else:
            res = self.issh.execute("oc get co %s| grep -v AVAILABLE |awk '{print $1, $3}'" % (operator))
        lines = res.splitlines()
        for line in lines:
            if not line or 'kubectl' in line or 'core' in line or 'root' in line:
                continue
            if 'True' in line:
                continue
            raise AssertionError("operator status abnormal:[%s] [%s]." % (operator, line))

    def cephcluster_health_should_be_ok(self):
        res = self.issh.execute('kubectl get cephcluster -n openshift-storage \
                                 -o jsonpath="{.items[0].status.ceph.health}"')
        if 'HEALTH_OK' not in res:
            raise AssertionError("cephcluster health not ok:[%s]." % (res))

    def get_rannic_cards_info(self):
        rannic_cards = []
        res = self.issh.execute("lspci | grep Cav", check_result=False)
        lines = res.splitlines()
        for line in lines:
            if not line or 'lspci' in line or 'core' in line or 'root' in line:
                continue
            if 'Cav' in line:
                rannic_cards.append(line)
        return rannic_cards

    def rannic_driver_service_should_be_active(self):
        self.issh.execute("sudo systemctl status loki-driver-load.service > rannic_driver.log")
        self.issh.execute("cat rannic_driver.log | grep active")
        self.issh.execute("rm rannic_driver.log")


if __name__ == '__main__':
    # connect
    ocpOps = ocpOps()
    ocpOps.connect_to_ssh('10.16.118.118', 'core', 'system123')   # testline5
    # ocpOps.connect_to_ssh('10.20.102.26', 'core', 'system123')  # iv029
    ocpOps.get_ocp_release()
    ocpOps.nodes_status_should_be_ready()
    ocpOps.pods_status_should_be_ok()
    ocpOps.operators_available_should_be_true()
    rannic_cards = ocpOps.get_rannic_cards_info()
    if rannic_cards:
        ocpOps.rannic_driver_service_should_be_active()
    ocpOps.cephcluster_health_should_be_ok()
