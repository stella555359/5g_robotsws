from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.tti_parser_base import TTIParser


class TTI_8305(TTIParser):
    def feature_conditions(self, single_log) -> bool:
        return (single_log['dlFdSchedData']['body']['muStatus'] == "MUPAIR" and
                single_log['dlFdSchedData']['body']['numOfLayers'] == "RANK2" and
                single_log['dlFdSchedData']['body']['numOfPrb'] > 260)
