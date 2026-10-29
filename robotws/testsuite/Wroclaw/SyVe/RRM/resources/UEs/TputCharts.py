from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


class TputCharts:
    common_size_factor = 2
    x_size, y_size = 3 * common_size_factor, 2 * common_size_factor

    def __init__(self):
        self.all_tputs = None
        self.name = None
        self.title = "Tput characteristics"

    def draw_tput_change_chart(self, tputs_dict, chart_name, title=None):
        try:
            import matplotlib.pyplot as plt
        except ImportError:
            Logger.info("Installing matplotlib...")
            Os.execute_command("pip install matplotlib")
            import matplotlib.pyplot as plt

        if title is not None:
            self.title = title
        self.all_tputs = tputs_dict
        self.name = chart_name
        fig = plt.figure(figsize=(TputCharts.x_size, TputCharts.y_size))
        chart = fig.add_subplot(1, 1, 1)
        plt.grid()
        for index, tputs in enumerate(self.all_tputs.values()):
            color = "r" if index < len(self.all_tputs.values()) / 2 else "b"
            chart.plot(range(1, len(tputs) + 1), tputs, color)
        self._set_labels_and_chart_annotations(chart)
        return self._get_file_chart_path(plt)

    def _set_labels_and_chart_annotations(self, chart):
        x_ann_start = 0
        for title, tputs in self.all_tputs.items():
            chart.annotate(title, xy=(x_ann_start, tputs[0]))
        labels = {'title': self.title,
                  'xlabel': 'Read tput sample [nr]', 'ylabel': 'Tput [mbps]'}
        chart.set(**labels)

    def _get_file_chart_path(self, plt_):
        picture_path = Os.join_path_elements(Env().test_log_dir, f"{self.name}_Tputs.png")
        plt_.savefig(picture_path)
        plt_.close()
        return picture_path
