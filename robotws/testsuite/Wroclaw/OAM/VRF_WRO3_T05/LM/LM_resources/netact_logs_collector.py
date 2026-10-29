import os
from lib_WOM import get_netacts_by_name_with_release
import sys
from netact_logs_collector_imp import NetActLogsCollector
if sys.version_info[0] < 3:
    import Tkinter as tk
    from ttk import Combobox
else:
    import tkinter as tk
    from tkinter.ttk import Combobox


def raise_text_field(method):
    def wrapper(self, node_name):
        result = method(self, node_name)
        self.text_rt.delete('1.0', tk.END)
        self.text_rt.insert(1.0, result)
    return wrapper


class NetActLogsCollectorGUI(object):
    def __init__(self, netact_dict):
        self.netAct = netact_dict
        self.gui = tk.Tk()
        self.text_rt = tk.Text(self.gui, height=22, width=95)
        self.netAct_holder = Combobox(self.gui, value=list(self.netAct.keys()),)
        self.netAct_holder.set(list(self.netAct.keys())[0])
        self.implementation = NetActLogsCollector(self.netAct)
        self.current_path = os.path.dirname(os.path.abspath(__file__))

    def setup_gui(self):
        self.gui.resizable(width=False, height=False)
        self.gui.geometry('800x500')
        self.gui.title('NA_logs_collector')
        tk.Button(
            self.gui, text="Collect NetAct info", command=lambda: self.collect_env_info(self.netAct_holder.get()),
            relief=tk.RAISED).grid(row=0, column=0)
        tk.Button(
            self.gui, text="Collect NetAct logs", command=lambda: self.collect_env_logs(self.netAct_holder.get()),
            relief=tk.RAISED).grid(row=0, column=1)
        tk.Button(
            self.gui, text="Collect NetAct status", command=lambda: self.collect_env_status(self.netAct_holder.get()),
            relief=tk.RAISED).grid(row=0, column=2)
        tk.Button(
            self.gui, text="Collect DNS records", command=lambda: self.collect_dns_records(self.netAct_holder.get()),
            relief=tk.RAISED).grid(row=0, column=3)
        tk.Button(
            self.gui, text="Collect BTSMED logs", command=lambda: self.collect_btsmed_logs(self.netAct_holder.get()),
            relief=tk.RAISED).grid(row=1, column=0)
        tk.Label(
            self.gui, text="Choose your favourite NetAct: ").grid(row=1, column=0, columnspan=4, sticky=tk.S)
        scroll = tk.Scrollbar(self.gui)
        scroll.grid(row=3, column=4, sticky="ns")
        self.text_rt.grid(row=3, column=0, columnspan=4)
        scroll.config(command=self.text_rt.yview)
        self.netAct_holder.grid(row=2, column=0, columnspan=4, sticky=tk.N)
        for i in range(8):
            self.gui.rowconfigure(i, weight=1)
        for i in range(4):
            self.gui.columnconfigure(i, weight=1)

    def start_collector(self):
        self.setup_gui()
        self.gui.mainloop()

    @raise_text_field
    def collect_env_logs(self, node_name):
        self.implementation.collect_env_logs(self.netAct_holder.get())
        result = "AS, NE3S and Common Mediation logs have been collected.\n" \
                 "You can find them in was_logs and ommon_and_ne3s_logs catalogs under " + node_name + "_logs folder."
        return result

    @raise_text_field
    def collect_btsmed_logs(self, node_name):
        self.implementation.collect_btsmed_logs(self.netAct_holder.get())
        result = "BTSMED logs have been collected.\n" \
                 "You can find them in " + node_name + "_btsmed_log.zip file."
        return result

    @raise_text_field
    def collect_env_info(self, node_name):
        result = self.implementation.collect_env_info(self.netAct_holder.get())
        with open(self.current_path + "/" + str(node_name) + "_env_info.txt", "w") as f:
            f.write("".join(result))
        return result

    @raise_text_field
    def collect_env_status(self, node_name):
        result = self.implementation.collect_env_status(self.netAct_holder.get())
        with open(self.current_path + "/" + str(node_name) + "_env_status.txt", "w") as f:
            f.write("".join(result))
        return result

    @raise_text_field
    def collect_dns_records(self, node_name):
        result = self.implementation.collect_dns_records(self.netAct_holder.get())
        with open(self.current_path + "/" + str(node_name) + "_dns_records.txt", "w") as f:
            f.write(result)
        return result


if __name__ == "__main__":
    netAct_dict = get_netacts_by_name_with_release()
    collector = NetActLogsCollectorGUI(netAct_dict)
    collector.start_collector()
