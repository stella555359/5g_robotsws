import re
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.HR.resources.asik_commands import AsikConnection


class NgLinkManager:
    def __init__(self, amf_ip='10.27.28.136'):
        self.amf = amf_ip
        self.asik = AsikConnection()

    def block_ng_link(self):
        with self.asik as connection:
            connection.execute_command_on_asik(
                'nft insert rule ip route POSTROUTING ip daddr {{ {} }} counter drop'.format(self.amf))

    def unblock_ng_link(self):
        with self.asik as connection:
            output = connection.execute_command_on_asik('nft list table route -a | grep {}'.format(self.amf))
            handle_id = int(re.search(r"handle\s(\d+)", output).group(1))
            connection.execute_command_on_asik('nft delete rule ip route POSTROUTING handle {}'.format(handle_id))
