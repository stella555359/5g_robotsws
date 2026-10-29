from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.qxdm.utils.support_functions import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.qxdm.utils.logs_exceptions import NoLogsToProcess


class UELogAnalyzer:
    class _TLog:
        def __init__(self, name, timestamp, tput_stats):
            self.tput_stats = tput_stats
            self.timestamp = timestamp
            self.name = name

    def __init__(self):
        self.dl_5g = self.ul_5g = self.dl_lte = self.ul_lte = []
        # re from qxdm timestamps
        self.time_re = r'[0-9]{4} *[a-zA-z]{3} *[0-9]+ *[0-9]{2}:[0-9]{2}:[0-9]{2}'
        self.parsed_logs = []

    def parse_tput_logs(self, path='/home/ute/robotws/ue_logs.txt'):
        files_to_parse = split_file(path)
        self.parsed_logs = []
        for file in files_to_parse:
            with open(file, 'r') as f:
                name = file.replace(".txt", "")
                line = f.readline()
                i = 0
                while line:
                    raw_date = re.findall(self.time_re, line)[0]
                    date = parse_date(raw_date)
                    raw_tput = f.readline()
                    tput_stat = parse_tput(raw_tput)
                    log = self._TLog(name, date, tput_stat)
                    self.parsed_logs.append(log)
                    line = f.readline()
                    line = f.readline()

    def get_value(self, log_name, value_name, option, ca_id=0):
        to_calculate = []
        for log in self.parsed_logs:
            if log_name == log.name and value_name in log.tput_stats.keys():
                if log.tput_stats[value_name]:
                    to_calculate.append(int(log.tput_stats[value_name]))
        if not to_calculate:
            raise NoLogsToProcess(log_name, value_name)
        if option == 'avg':
            return sum(to_calculate) / len(to_calculate)
        if option == 'max':
            return max(to_calculate)
        if option == 'raw':
            return to_calculate

    def get_sorted_tput(self, log_name):
        res = []
        for log in self.parsed_logs:
            if log_name == log.name:
                res.append(log)
        if not res:
            raise NoLogsToProcess(log_name)
        return sorted(res, key=lambda d: d.timestamp)

    def get_all_sorted_logs(self):
        return sorted(self.parsed_logs, key=lambda d: d.timestamp)

    def generate_tput_chart(self):
        lte_dl = self.get_sorted_tput("lte_dl")

        lte_ul = self.get_sorted_tput("lte_ul")

        nr_dl = self.get_sorted_tput("5g_dl")

        nr_ul = self.get_sorted_tput("5g_ul")

        timestamps = [x.timestamp for x in nr_dl]
        if lte_dl or lte_ul:
            fig = make_subplots(rows=1, cols=2, subplot_titles=["NR", "LTE"])
            # NR part
            tput_to_add = [float(x.tput_stats["AvgPHY"]) / 1000 for x in nr_dl]
            fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="NR Downlink"), row=1, col=1)
            tput_to_add = [float(x.tput_stats["AvgPHY"]) / 1000 for x in nr_ul if x.tput_stats["AvgPHY"]]
            fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="NR Uplink"), row=1, col=1)
            fig.update_xaxes(title_text="Time")
            fig.update_yaxes(title_text="Mbps")
            # LTE part
            tput_to_add = [float(x.tput_stats["AvgPHY"]) / 1000 for x in lte_dl if x.tput_stats["CA_ID"] == '0']
            fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="LTE Downlink CA 0"), row=1, col=2)
            tput_to_add = [float(x.tput_stats["AvgPHY"]) / 1000 for x in lte_ul if x.tput_stats["AvgPHY"]]
            fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="LTE Uplink"), row=1, col=2)
            tput_to_add = [float(x.tput_stats["AvgPHY"]) / 1000 for x in lte_dl if x.tput_stats["CA_ID"] == '1']
            fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="LTE Downlink CA 1"), row=1, col=2)
            fig.update_xaxes(title_text="Time")
            fig.update_yaxes(title_text="Mbps")
            # Summary part
            dl_lte_ca_0 = [x for x in lte_dl if x.tput_stats["CA_ID"] == "0"]
            dl_lte_ca_1 = [x for x in lte_dl if x.tput_stats["CA_ID"] == "1"]
            sum_lte_dl = [(float(x.tput_stats["AvgPHY"]) + float(y.tput_stats["AvgPHY"])) for x, y
                          in zip(dl_lte_ca_0, dl_lte_ca_1)]
            sum_dl = [(float(x.tput_stats["AvgPHY"]) + y) / 1000 for x, y
                      in zip(nr_dl, sum_lte_dl)]
            fig2 = make_subplots(rows=1, cols=1, subplot_titles=["NR + LTE"])
            fig2.update_xaxes(title_text="Time")
            fig2.update_yaxes(title_text="Mbps")
            fig2.add_trace(go.Scatter(x=timestamps, y=sum_dl, name="NR+LTE Downlink"), row=1, col=1)
            sum_ul = [(float(x.tput_stats["AvgPHY"]) + float(y.tput_stats["AvgPHY"])) / 1000 for x, y
                      in zip(nr_ul, lte_ul)]
            fig2.add_trace(go.Scatter(x=timestamps, y=sum_ul, name="NR+LTE Uplink"), row=1, col=1)
            with open("chart_hard_test.html", "w") as f:
                f.write(fig.to_html(full_html=False))
                f.write(fig2.to_html(full_html=False))
