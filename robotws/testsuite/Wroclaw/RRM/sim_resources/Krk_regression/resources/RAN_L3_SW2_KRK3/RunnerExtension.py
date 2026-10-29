from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.String import String
from taf.wts.runner import runner


class RunnerExtension(runner):
    def get_average_data_rate(self, ue_id, dir, pdu=1, mode="SA"):
        if mode == "SA":
            self.qfi_stats(ue=ue_id, pdu=pdu, qfi="1", dir=dir)
        else:
            self.bearer_stats(id=2, ue=ue_id, dir=dir)
        cmd_result = self.read_wtsemu_output_until_re(expected="Last data rate", timeout="10")
        logger.debug(" \n {}".format(cmd_result))
        average_rate = String().get_regexp_matches(cmd_result, "Average data rate\\s+(\\d+)", 1)
        return int(average_rate[0])

    def verify_average_data_rate_is_above_expected_margin(self, ue_id, dir, expected_rate_mbps, margin, pdu=1,
                                                          mode="SA"):
        avg_rate = self.get_average_data_rate(ue_id, dir, pdu, mode)
        expected_rate = float(expected_rate_mbps) * (10 ** 6)
        logger.debug("UE-{} dir {} expected {} rate {}".format(ue_id, dir, float(expected_rate), float(avg_rate)))
        BuiltIn().should_be_true(float(avg_rate) >= float(expected_rate) * float(margin))
