from robot.api.logger import info
from taf.transport.ssh import ssh


def verify_hw_status(hw_node, alias, ccs_daemon_node_id):
    """
        check HW status

        :param string hw_node: board node number    0x12 or 0x10
        :param string alias: alias
        :param string ccs_daemon_node_id: CCS Daemon node id
        :return: bool True or False

        - Example::

              check_hw_status    0x12
    """
    csn = ssh()
    info("Start to check board status: \n")
    sys_result = csn.execute(
        "export PYTHONPATH=/opt/hwmt/python &&"
        " python3 /opt/hwmt/python/hwapi/AdetS.py -s -n {}|grep {}".format(
            ccs_daemon_node_id, hw_node), alias)
    if 'ready[0]' in sys_result:
        info("board in right status")
        return True
    else:
        info("Status is not ready", also_console=True)
        return False
