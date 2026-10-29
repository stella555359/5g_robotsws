import time

from ta5g_iphy import ta5g_iphy
from ta5g_admin_operations import ta5g_admin_operations
from ta5g_admin_operations import ta_admin_common_operations
from ta5g_enb import ta5g_enb
from robot.api import logger


def deploy_redundant_cnf_layout():
    logger.console("Starting deploy of redundant CPLANE instances in vCU")
    with ta5g_admin_operations().connect_to_vcu_aic() as vcu_connection:
        vcu_version = vcu_connection.get_active_software_version()
    sw_version = vcu_version.split("_")[-1]
    namespace = ta5g_enb().get_namespace_for_vcu()
    hostname = namespace.replace("-", "_").upper()
    host = ta5g_enb().get_ip_vcu_master()
    sw_dir = "{local_hostname}/vCUCNF00_{sw_version}/0".format(local_hostname=hostname, sw_version=sw_version)
    with ta_admin_common_operations.create_shell_session_vcu(host) as connection:
        connection.send_shell_command("helm uninstall vcucnf -n {} --debug"
                                      .format(namespace))

        connection.send_shell_command("sed -i 's/cnfLayout: basic/cnfLayout: redundant/g' \
                                      /var/home/core/{}/HelmChart/aic-vcu-cnf/tl.yaml"
                                      .format(sw_dir))
        connection.send_shell_command("sed -i 's/cnfLayout: \"basic\"/cnfLayout: \"redundant\"/g' \
                                      /var/home/core/{}/HelmChart/aic-vcu-cnf/values-override.yaml"
                                      .format(sw_dir))
        connection.send_shell_command("sed -i 's/rangeEnd: 172.16.2.101/rangeEnd: 172.16.2.102/g' \
                                      /var/home/core/{}/HelmChart/aic-vcu-cnf/vcu-cnf-common.yaml"
                                      .format(sw_dir))
        connection.send_shell_command("sed -i 's/rangeEnd: 10.0.1.210/rangeEnd: 10.0.1.211/g' \
                                      /var/home/core/{}/HelmChart/aic-vcu-cnf/vcu-cnf-common.yaml"
                                      .format(sw_dir))
        connection.send_shell_command("sed -i 's/rangeEnd: 10.0.11.210/rangeEnd: 10.0.11.211/g' \
                                      /var/home/core/{}/HelmChart/aic-vcu-cnf/vcu-cnf-common.yaml"
                                      .format(sw_dir))
        connection.send_shell_command("sed -i 's/rangeEnd: 10.0.12.210/rangeEnd: 10.0.12.211/g' \
                                      /var/home/core/{}/HelmChart/aic-vcu-cnf/vcu-cnf-common.yaml"
                                      .format(sw_dir))

        shin_install, shout_install, sherr_install = connection.send_shell_command(
                                      "cd /var/home/core/{sw_dir}/HelmChart/cnf/aic-vcu-cnf/ && \
                                      helm install vcucnf . -f values-override.yaml -f tl.yaml \
                                      -f vcu-cnf-common.yaml -n {namespace} --timeout 25m --debug"
                                      .format(sw_dir=sw_dir, namespace=namespace))

        shin, shout, sherr = connection.send_shell_command("helm list -n {} ".format(namespace))
        for element in shout:
            if 'vcucnf' in element and 'deployed' in element:
                break
        else:
            raise Exception('vcucnf not created with errors: {}'.format(shout_install))


def get_scfc_file_du_aic(path, filename_prefix='initial_commissioning'):
    number_of_vdu = ta5g_admin_operations().get_number_of_vdu()
    for vdus in range(number_of_vdu):
        filename = filename_prefix+'_vdu_{0}.xml'.format(vdus)
        host = ta5g_iphy().get_vdu_master_ip(vdu=vdus)
        with ta5g_admin_operations().connect_to_vdu_aic(host=host) as vdu_connection:
            vdu_connection.get_current_plan_file(path, filename)
