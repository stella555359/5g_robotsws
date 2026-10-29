from robot.libraries.BuiltIn import BuiltIn


class HTMLReport:
    counters = {}
    logger = BuiltIn().get_library_instance("LOG")

    def __init__(self, report_name):
        self.report_name = report_name

    def __call__(self, func):
        def inner_func(*args, **kwargs):
            logs = BuiltIn().get_library_instance("COLLECTLOGS")
            loop = self.logger.loop + 1

            if loop not in logs.html_report:
                logs.html_report[loop] = {}
                HTMLReport.counters = {}
            if self.report_name in HTMLReport.counters:
                HTMLReport.counters[self.report_name] += 1
            else:
                HTMLReport.counters[self.report_name] = 1
            report_name = "{} {}".format(self.report_name, str(HTMLReport.counters[self.report_name]))
            result = func(*args, **kwargs)
            if not result:
                result = False
            # text_res = "pass" if result else "fail"
            self.logger.debug("{} - {}".format(report_name, result))
            logs.html_report[loop][report_name] = result
            return result
        return inner_func
