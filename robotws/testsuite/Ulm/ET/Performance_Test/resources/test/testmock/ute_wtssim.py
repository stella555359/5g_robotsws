
import re


class UteWtsSimMock():
    """until we set up unit test, this will do
    """

    def __init__(self):
        self.cmd_count = 0
        self.registered_ue_ids = []
        self.cmds = {
            "ue_summary": UteWtsSimMock.generate_ue_summary()
        }

    def execute_egate_command_and_wait_for_data(self, *_, **kwargs):
        self.cmd_count = self.cmd_count + 1
        return self._intercept_returns(kwargs['cmd'])

    def execute_egate_command(self, *_, **kwargs):
        self.cmd_count = self.cmd_count + 1
        return self._intercept_returns(kwargs['cmd'])

    def _intercept_returns(self, cmd):
        if "ue_summary" in cmd:
            return cmd + self.cmds["ue_summary"]
        if "ue_pdu_session_modify" in cmd:
            return cmd + " PDU SESSION RESOURCE MODIFY RESPONSE"
        if "ue_register" in cmd:
            ueid = re.search(r".*id=([0-9]+).*", cmd).group(1)
            self.registered_ue_ids.append(ueid)
            return cmd + " REGISTRATION COMPLETE"
        if "ue_deregister" in cmd:
            ueid = re.search(r".*id=([0-9]+).*", cmd).group(1)
            self.registered_ue_ids.remove(ueid)
            print(f"remove: {ueid}")
            return cmd + " tba"
        return cmd

    @classmethod
    def generate_ue_summary(cls, active=400, cells=None):
        if cells is None:
            cells = [(1, 100), (3, 300)]
        cell_str = ""
        for cell, count in cells:
            cell_str = f"{cell_str}   Cell-{cell}   {count}    -\n"
        return f"""
        UEs Summary
        =====================================================
        Parameter                Simulated  External  Total
        -----------------------------------------------------
        Configured               2700       0         2700
        -----------------------------------------------------
        Active                   {active}        0         {active}
        ENB-2                 {active}        0         {active}
        {cell_str}
        -----------------------------------------------------
        Active (Time Aligned)    -9999        -
        ENB-2                    -9999        -
            Cell-1               -9999        -
            Cell-3               -9999        -
        -----------------------------------------------------
        Active (Time Unaligned)  0          -
        =====================================================
        Idle                     2          0         2
        ENB-2                  2          0         2
            Cell-3             2          -
        =====================================================
        """
