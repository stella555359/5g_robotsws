import time
from taf.sw.nadcm.interface import nadcm
from taf.hw.fhgw.cli.interface import cli
from taf.internal.robot_typecasts.typecasts import time_to_seconds


class nadcm_event_logs:

    def __init__(self):
        self.inadcm = nadcm()
        self.cli = cli()

    def get_bmc_node_id_and_ip_via_neat(self, connection=None):
        # Get BMC node id and ip address via neat.
        inventory_info = self.inadcm.get_inventory_nodes(connection=connection)
        node_id2ip_dic = {}
        for node_item in inventory_info:
            if node_item["dynamicstate"]["powerstatus"].lower() in ["on", "off"] and node_item["product_name"]:
                node_id2ip_dic[node_item['id']] = node_item['obm_ip']
        return node_id2ip_dic

    def reset_bmc_to_generate_event_logs_for_them_one_by_one(self, node_id2ip_dic, connection=None):
        # Loop all the BMC. Reset BMC one by one.
        task_dic = {}
        for node_id in node_id2ip_dic.keys():
            task_id = self.inadcm.reset_node_bmc(node_id, connection=connection)
            task_status = self.inadcm.get_upgrade_state(task_id, connection=connection)
            assert task_status['state'] == 'PROGRESS' and 'Resetting the BMC' in task_status['steps'], \
                "Send BMC reset command to %s failed!" % node_id2ip_dic[node_id]
            task_dic[task_id] = node_id2ip_dic[node_id]
        return task_dic

    def wait_until_all_the_bmc_reset_tasks_finished(self, task_dic, connection=None):
        # Loop all the BMC reset task. Wait each one finished.
        reset_failed = {}
        for task_id, ip_addr in task_dic.items():
            try:
                self.wait_until_task_finished(task_id, connection=connection)
            except Exception as e:
                reset_failed[ip_addr] = str(e)
        if reset_failed:
            raise RuntimeError("BMC reset failed: %s" % reset_failed)

    def wait_until_task_finished(self, task_id, timeout="10 min", connection=None):
        # Wait a task finished.
        timeout_s = time_to_seconds(timeout)
        max_time = time.time() + timeout_s

        while True:
            if time.time() >= max_time:
                raise RuntimeError("Task status still is %s in %s." % (task_status["state"], timeout))
            task_status = self.inadcm.get_upgrade_state(task_id, connection=connection)
            if task_status["state"] == "PROGRESS":
                time.sleep(5)
            elif task_status["state"] == "SUCCESS":
                break
            else:
                raise AssertionError("The task status is abnormal: %s" % task_status["state"])

    def check_bmc_reset_event_log_is_asserted(self, node_id2ip_dic, connection=None):
        # Get event logs of each BMC, check that BMC reset event is asserted.
        logs_not_found = []
        for key in node_id2ip_dic.keys():
            node_logs = self.inadcm.get_events_for_node(node_id2ip_dic[key], connection=connection)
            for log_item in node_logs["events"]:
                if log_item["description"] == "Management Controller Offline (BMC cold reset) - Asserted":
                    break
            else:
                logs_not_found.append(node_id2ip_dic[key])

        if logs_not_found:
            raise RuntimeError("BMC reset log can not be found in %s" % logs_not_found)

    def generate_login_failed_log_on_server_one_by_one(self, node_id2ip_dic, connection=None):
        # Loop all the severs. Login with wrong password one by one.'
        node_event_dic = {}
        for node_id, ip_addr in node_id2ip_dic.items():
            try:
                self.cli.connect_to(ip_addr, "admin", "wrong_password")
                raise RuntimeError("Login with wrong user or password should be failed!")
            except Exception as e:
                if "Authentication failed" in str(e):
                    node_event_dic[node_id] = ip_addr
                    print("Succeed to generate 'Login failed' log on %s: %s" % (ip_addr, str(e)))
                else:
                    print("Faied to generate 'Login failed' log on %s: %s" % (ip_addr, str(e)))
        return node_event_dic

    def check_login_faied_event_log_is_asserted(self, node_id2ip_dic, connection=None):
        # Get event logs of each sever, check that login failed event is asserted.
        logs_not_found = []
        for node_id, ip_addr in node_id2ip_dic.items():
            node_logs = self.inadcm.get_active_events_for_node(ip_addr, connection=connection)
            for log_item in node_logs["events"]:
                if "Login failed" in log_item["description"]:
                    break
            else:
                logs_not_found.append(ip_addr)

        if logs_not_found:
            raise RuntimeError("Login failed log can not be found in %s" % logs_not_found)
