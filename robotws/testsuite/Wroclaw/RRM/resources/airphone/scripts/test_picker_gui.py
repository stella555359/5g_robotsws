"""
Documentation    :copyright: Nokia
...              :authors: Bartosz Grzegorczyk, Kamila Gniewek
...              :contact: bartosz.grzegorczyk@nokia.com, kamila.gniewek@nokia.com
"""

import os
import signal
import sys
import threading
import tkinter as tk
from tkinter import ttk
from tkinter import *
from datetime import datetime
import socket
import time
from robot.api import TestData
import webbrowser
import subprocess


class TestPathsManager:
    """
    This class goes through 5G_SW_WRO directory to find paths for all test cases
    """
    def __init__(self):
        self.sw_wro_file_path = '/home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/'
        self.paths_to_tests_list = []
        self.paths_to_cit_list = []
        self.paths_to_crt_list = []
        self.paths_to_report_tests_list = []

    def get_tests_paths(self):
        """
        This method search for all files in 5G_SW_WRO directory and divides it to three categories:
        paths_to_tests_list, paths_to_cit_list, paths_to_crt_list
        """
        self._get_list_of_tests('/home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/')
        for each_test_path in self.paths_to_tests_list:
            if self._check_if_cit_or_crt_test(each_test_path, " CIT"):
                self.paths_to_cit_list.append(each_test_path)
            if self._check_if_cit_or_crt_test(each_test_path, " CRT"):
                self.paths_to_crt_list.append(each_test_path)
        self.paths_to_tests_list = [full_test_path.replace(self.sw_wro_file_path, '')
                                    for full_test_path in self.paths_to_tests_list]
        self.paths_to_cit_list = [full_test_path.replace(self.sw_wro_file_path, '')
                                  for full_test_path in self.paths_to_cit_list]
        self.paths_to_crt_list = [full_test_path.replace(self.sw_wro_file_path, '')
                                  for full_test_path in self.paths_to_crt_list]

    def _get_files_from_directory(self, sw_wro_tests_paths):
        """
        This method search for all files in 5G_SW_WRO directory and return theirs paths
         :param sw_wro_tests_paths: path to sw wro tests
        """
        paths_to_files_list = []
        all_files_in_sw_wro_path = os.listdir(sw_wro_tests_paths)
        for each_file in all_files_in_sw_wro_path:
            each_file_path = os.path.join(sw_wro_tests_paths, each_file)
            if os.path.isdir(each_file_path):
                paths_to_files_list = paths_to_files_list + self._get_files_from_directory(each_file_path)
            else:
                paths_to_files_list.append(each_file_path)
        return paths_to_files_list

    def _get_list_of_tests(self, path):
        """
        This method takes all files in 5G_SW_WRO directory and applies only paths to tests
        to self.paths_to_tests_list
        """
        paths_to_files_list = self._get_files_from_directory(path)
        for each_file_path in paths_to_files_list:
            if each_file_path.endswith(".robot"):
                if not ("eyword" in each_file_path or
                        "ariable" in each_file_path or
                        "script" in each_file_path or
                        "instances" in each_file_path):
                    self.paths_to_tests_list.append(each_file_path)
        self.paths_to_tests_list.sort()

    @staticmethod
    def _check_if_cit_or_crt_test(test_path, cit_or_crt):
        """
        This method checks if given test file is CRT OR CIT
         :param test_path: individual path to test file
         :param cit_or_crt: indicate whether to check for cit or crt, e.g CIT
         :return: boolean depended on finding CIT or CRT
        """
        with open(test_path) as test_file:
            all_test_file_lines = test_file.readlines()
        for each_line in all_test_file_lines:
            if cit_or_crt in each_line:
                return True
        return False


class TestPickerGraphicUserInterface(TestPathsManager):
    """
    This class generates Graphic User Interface where tests to run can be picked
    and generates the .txt file on the Desktop which contains paths with tests to run
    """

    def __init__(self):
        """
        Constructor, Initialization of tkinter objects
        """
        super().__init__()
        self.window = None
        self.main_frame = None
        self.all_tests_tab = None
        self.cit_tab = None
        self.crt_tab = None
        self.checkbutton_variable = None
        self.checkbutton_variable_rotta = None
        self.test_listbox = None
        self.tests_paths_selected_list = []
        self.tests_reports_paths_selected_list = []
        self.tests_logs_paths_selected_list = []
        self.rotta_path_var = None
        self.report_path_var = None
        self.results_array = []
        self.running_script_state_flag = False
        self.server_socket = None
        self.actual_path = "/home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/"
        self.logs_path = "/home/ute/logs/"
        self.write_file = "/tmp/testrunner_tmp_file"
        self.current_tab = "Tests"
        self.entry_color = "#ffffff"
        self.listbox_color = "#029ea3"
        self.label_color = "#1590bd"
        self.script_color = "#ffa500"
        self.question_color = "#808080"
        self.window_color = "#c0c0c0"
        self.background_color = "#b2b3c0"

    def create_graphic_user_interface(self):
        """
        This method creates graphic user interface
        """
        self.get_tests_paths()
        self.create_window_and_frame()
        self.create_label("Choose test scenarios you want to run:", 35)
        self.create_listbox()
        self.create_tests_tabs()
        self.fill_tabs_wth_test_paths()
        self.create_grep_entry()
        self.create_tests_button()
        self.create_results_button()
        self.create_reports_button()
        self.create_admin_button()
        self.create_setup_pycharm_button()
        self.create_check_radios_button()
        self.create_full_commis_button()
        self.create_reset_testline_button()
        self.create_delta_button()
        self.create_report_test_check_button()
        self.create_import_to_rotta_button()
        self.create_run_tests_button()
        self.window.mainloop()

    def get_new_tests_paths(self, event):
        """
        This method search for all files in 5G_SW_WRO directory and divides it to three categories:
        paths_to_tests_list, paths_to_cit_list, paths_to_crt_list
        """
        self.all_tests_tab.delete(0, tk.END)
        self.cit_tab.delete(0, tk.END)
        self.crt_tab.delete(0, tk.END)
        self.paths_to_tests_list = []
        self.actual_path = "/home/ute/robotws/testsuite/"+self.tests_path.get()
        self._get_list_of_tests(self.actual_path)
        for each_test_path in self.paths_to_tests_list:
            if self._check_if_cit_or_crt_test(each_test_path, " CIT"):
                self.paths_to_cit_list.append(each_test_path)
            if self._check_if_cit_or_crt_test(each_test_path, " CRT"):
                self.paths_to_crt_list.append(each_test_path)
        self.paths_to_tests_list = [full_test_path.replace(self.actual_path, '')
                                    for full_test_path in self.paths_to_tests_list]
        self.paths_to_cit_list = [full_test_path.replace(self.actual_path, '')
                                  for full_test_path in self.paths_to_cit_list]
        self.paths_to_crt_list = [full_test_path.replace(self.actual_path, '')
                                  for full_test_path in self.paths_to_crt_list]
        self.fill_tabs_wth_test_paths()

    def exit(self):
        """
        This method defines program exit - it closes socket if it is open and destroys window.
        """
        if self.server_socket is not None and isinstance(self.server_socket, socket.socket):
            self.server_socket.close()
        self.close_bash()
        pid = os.getpid()
        os.kill(pid, signal.SIGKILL)
        self.window.destroy()
        sys.exit(0)

    def create_window_and_frame(self):
        """
        This method creates window and main frame
        """
        self.window = tk.Tk()
        window_width, window_height = 950, 550

        screen_width = self.window.winfo_screenwidth()
        screen_height = self.window.winfo_screenheight()

        position_top = int(screen_height / 2 - window_height / 2)
        position_right = int(screen_width / 2 - window_width / 2)

        self.window.geometry(f'{window_width}x{window_height}+{position_right}+{position_top}')
        self.window.title("ET Test Runner")
        self.window.resizable(width=False, height=False)
        self.window.protocol('WM_DELETE_WINDOW', self.exit)
        self.window.option_add("*Font", ["Helvetica", 10])
        self.main_frame = tk.Label(self.window, bg=self.background_color)
        self.main_frame.place(relwidth=1, relheight=1)

    def create_grep_entry(self):
        """
        This method defines creation of label and entry for greping tests.
        """
        self.create_label("Find test:", 9, 560, 79)
        self.grep_entry = Entry(master=self.main_frame, width=35, bg=self.entry_color)
        self.grep_entry.place(x=620, y=78)
        self.grep_entry.bind('<Return>', self.find_tests_from_text)

    def fill_tabs_wth_test_paths(self):
        """
        This method fills three tabs for all tests, CIT and CRT with corresponding test paths
        """
        for each_test in self.paths_to_tests_list:
            self.all_tests_tab.insert(tk.END, each_test)
        for each_cit_test in self.paths_to_cit_list:
            self.cit_tab.insert(tk.END, each_cit_test)
        for each_crt_test in self.paths_to_crt_list:
            self.crt_tab.insert(tk.END, each_crt_test)

    def find_tests_from_text(self, event):
        """
        This method defines finding tests from text entered in grep entry.
        """
        self.test_grep = self.grep_entry.get()
        grep_list = [element for element in self.paths_to_tests_list if self.test_grep in element]
        grep_tests_list = []

        # This if adds already selected tests to list
        if len(self.all_tests_tab.curselection()) != 0:
            self._get_selected_paths(self.all_tests_tab)
            grep_tests_list += self.tests_paths_selected_list
        grep_tests_list += grep_list

        self.all_tests_tab.delete(0, tk.END)
        for each_test in grep_tests_list:
            self.all_tests_tab.insert(tk.END, each_test)
            if each_test in self.tests_paths_selected_list:
                index = self.all_tests_tab.get(0, tk.END).index(each_test)
                self.all_tests_tab.selection_set(index)

        self.tests_paths_selected_list = []

    def create_label(self, text, width=30, x=80, y=40):
        """
        This method creates labels with text information
        """
        self.label_element = tk.Label(master=self.main_frame, text=text, font=["Helvetica", 10, "bold"],
                                      width=width, height=1, borderwidth=1, bd=1, relief="groove", bg=self.label_color,
                                      highlightthickness=0, anchor="w").place(x=x, y=y)

    def create_listbox(self):
        """
        This method creates listbox with multiple selection mode
        """
        self.test_listbox = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                       selectmode="multiple")
        self.test_listbox.pack(pady=100, padx=75)

    def create_tests_tabs(self):
        """
        This method creates three listbox for all tests, CIT and CRT
        """
        self.tests_notebook = ttk.Notebook(self.test_listbox)
        self.all_tests_tab = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                        selectmode="multiple", exportselection=False)
        self.cit_tab = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                  selectmode="multiple", exportselection=False)
        self.crt_tab = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                  selectmode="multiple", exportselection=False)
        self.all_tests_tab.bind('<FocusOut>', lambda e: "break")
        self.tests_notebook.add(self.all_tests_tab, text='All tests')
        self.tests_notebook.add(self.cit_tab, text='CIT')
        self.tests_notebook.add(self.crt_tab, text='CRT')
        self.tests_notebook.bind("<<NotebookTabChanged>>", self.on_tab_change)
        self.tests_notebook.pack(expand=1, fill="both")
        self.create_label("Path: /home/ute/robotws/testsuite/", 34, 80, 79)
        self.tests_path = Entry(master=self.main_frame, width=26, bg=self.entry_color)
        self.tests_path.place(x=295, y=78)
        self.tests_path.insert(tk.END, "Wroclaw/RRM/5G_SW_WRO/")
        self.tests_path.bind('<Return>', self.get_new_tests_paths)

    def create_results_tabs(self, text):
        """
        This method create results notebook with listbox
        """
        self.result_notebook = ttk.Notebook(self.test_listbox)
        self.results_listbox = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                          selectmode="multiple")
        self.result_notebook.add(self.results_listbox, text=text)
        self.result_notebook.pack(expand=1, fill="both")

    def create_logs_tabs(self, text):
        """
        This method creates three tabs for all tests, CIT and CRT
        """
        self.logs_notebook = ttk.Notebook(self.test_listbox)
        self.reports_listbox = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                          selectmode="multiple")
        self.logs_listbox = tk.Listbox(master=self.main_frame, bg=self.listbox_color, width=600, height=300,
                                       selectmode="multiple")
        self.logs_notebook.add(self.reports_listbox, text="Tests to report")
        self.logs_notebook.add(self.logs_listbox, text="Logs")
        self.logs_notebook.bind("<<NotebookTabChanged>>", self.on_listbox_select)
        self.logs_notebook.pack(expand=1, fill="both")

    def on_tab_change(self, event):
        """
        This method clears selection in all three tabs
        """
        self.all_tests_tab.selection_clear(0, tk.END)
        self.cit_tab.selection_clear(0, tk.END)
        self.crt_tab.selection_clear(0, tk.END)

    def on_listbox_select(self, event):
        """
        This method clears selection on listbox reselect for reports tab
        """
        selected_tab = self.logs_notebook.index(self.logs_notebook.select())
        try:
            if selected_tab == 0:
                self.reports_listbox.selection_clear(0, tk.END)
                self.logs_listbox.selection_clear(0, tk.END)
                self.open_file_button.destroy()
                self.create_report_tests_button()
            elif selected_tab == 1:
                self.reports_listbox.selection_clear(0, tk.END)
                self.logs_listbox.selection_clear(0, tk.END)
                self.report_tests_button.destroy()
                self.create_open_file_button()
        except AttributeError:
            pass

    def fill_tabs_wth_test_paths(self):
        """
        This method fills three tabs for all tests, CIT and CRT with corresponding test paths
        """
        for each_test in self.paths_to_tests_list:
            self.all_tests_tab.insert(tk.END, each_test)
        for each_cit_test in self.paths_to_cit_list:
            self.cit_tab.insert(tk.END, each_cit_test)
        for each_crt_test in self.paths_to_crt_list:
            self.crt_tab.insert(tk.END, each_crt_test)

    def create_report_test_check_button(self):
        """
        This method creates report test check button which allows to mark whether to report tests or not
        """
        self.checkbutton_variable = tk.IntVar()
        self.report_tests_checkbutton = tk.Checkbutton(master=self.main_frame, text="Do you want to report tests?",
                                                       bg=self.question_color, variable=self.checkbutton_variable,
                                                       onvalue=1, offvalue=0)
        self.report_tests_checkbutton.place(x=75, y=480)

    def create_import_to_rotta_button(self):
        """
        This method creates rotta check button which allows to mark whether to send reports to rotta or not
        """
        self.checkbutton_variable_rotta = tk.IntVar()
        self.rotta_checkbutton = tk.Checkbutton(master=self.main_frame, text="Do you want to update to rotta folder?",
                                                bg=self.question_color, variable=self.checkbutton_variable_rotta,
                                                onvalue=1, offvalue=0)
        self.rotta_checkbutton.place(x=75, y=500)
        self.create_label("Your rotta folder: /home/ute/rotta/", 32, 75, 521)
        self.rotta_path = Entry(master=self.main_frame, width=35, bg=self.entry_color)
        self.rotta_path.place(x=285, y=520)
        self.rotta_path.insert(tk.END, "5G_3/wroclaw/ET_L3/")

    def create_run_tests_button(self):
        """
        This method creates run tests button which allow to run selected tests
        """
        if self.running_script_state_flag is False:
            self.run_tests_button = tk.Button(master=self.main_frame, height=2, text="Start test runs",
                                              bg=self.script_color, font=["Helvetica", 10, "bold"],
                                              command=self._generate_file_with_selected_tests)
        else:
            self.run_tests_button = tk.Button(master=self.main_frame, height=2, text="Start test runs",
                                              bg=self.script_color, font=["Helvetica", 10, "bold"],
                                              command=self._generate_file_with_selected_tests, state=tk.DISABLED)
        self.run_tests_button.place(x=750, y=485)

    def create_report_tests_button(self):
        """
        This method creates report tests button which allow to report selected tests
        """
        if self.running_script_state_flag is False:
            self.report_tests_button = tk.Button(master=self.main_frame, height=2, text="Report tests",
                                                 bg=self.script_color, font=["Helvetica", 10, "bold"],
                                                 command=self.report_tests)
        else:
            self.report_tests_button = tk.Button(master=self.main_frame, height=2, text="Report tests",
                                                 bg=self.script_color, font=["Helvetica", 10, "bold"],
                                                 command=self.report_tests, state=tk.DISABLED)
        self.report_tests_button.place(x=750, y=485)

    def create_open_file_button(self):
        """
        This method creates open file button which allow to open selected files
        """
        self.open_file_button = tk.Button(master=self.main_frame, height=2, text="Open file", bg=self.script_color,
                                          font=["Helvetica", 10, "bold"], command=self.open_file)
        self.open_file_button.place(x=650, y=485)

    def open_file(self):
        """
        This method defines which files are selected and how selected files should be open
        """
        if len(self.logs_listbox.curselection()) != 0:
            self._check_selected_tests_logs_paths()
            for each_test_path in self.tests_logs_paths_selected_list:
                test_to_open = self.report_path_var + each_test_path
                if test_to_open.endswith(".html"):
                    try:
                        webbrowser.open(test_to_open)
                    except Exception as e:
                        print(f"Problem with opening file: {test_to_open}, exception: {e}")
                elif test_to_open.endswith(".txt") or test_to_open.endswith(".log"):
                    try:
                        subprocess.run(["xdg-open", test_to_open], check=True)
                    except Exception as e:
                        print(f"Problem with opening file: {test_to_open}, exception: {e}")

    def create_tests_button(self):
        """
        This method creates tests button which allow to switch tab to "Tests"
        """
        self.switch_to_tests_button = tk.Button(master=self.main_frame, text="Tests", bg=self.script_color,
                                                font=["Helvetica", 10, "bold"], command=self.show_tests)
        self.switch_to_tests_button.config(width=5, height=1)
        self.switch_to_tests_button.place(x=13, y=100)

    def create_results_button(self):
        """
        This method creates results button which allow to switch tab to "Results"
        """
        self.switch_to_results_button = tk.Button(master=self.main_frame, text="Results", bg=self.script_color,
                                                  font=["Helvetica", 10, "bold"], command=self.show_results)
        self.switch_to_results_button.config(width=5, height=1)
        self.switch_to_results_button.place(x=13, y=130)

    def create_reports_button(self):
        """
        This method creates reports button which allow to switch tab to "Reports"
        """
        self.switch_to_reports_button = tk.Button(master=self.main_frame, text="Reports", bg=self.script_color,
                                                  font=["Helvetica", 10, "bold"], command=self.show_reports)
        self.switch_to_reports_button.config(width=5, height=1)
        self.switch_to_reports_button.place(x=13, y=160)

    def destroy_all(self):
        """
        This method defines destroy of all children objects to main_frame widget
        """
        for widget in self.main_frame.winfo_children():
            widget.destroy()

    def create_admin_button(self):
        """
        This method creates "Admin" button which allow to start open admin script
        """
        if self.running_script_state_flag is False:
            self.open_admin_button = tk.Button(master=self.main_frame, text="Admin", bg=self.script_color,
                                               command=self.admin, font=["Helvetica", 10, "bold"])
        else:
            self.open_admin_button = tk.Button(master=self.main_frame, text="Admin", bg=self.script_color,
                                               command=self.admin, font=["Helvetica", 10, "bold"], state=tk.DISABLED)
        self.open_admin_button.config(width=13, height=1)
        self.open_admin_button.place(x=75, y=450)

    def create_setup_pycharm_button(self):
        """
        This method creates "Setup pycharm" button which allow to start setup pycharm script
        """
        if self.running_script_state_flag is False:
            self.setup_pycharm_button = tk.Button(master=self.main_frame, text="Setup pycharm", bg=self.script_color,
                                                  command=self.setup_pycharm, font=["Helvetica", 10, "bold"])
        else:
            self.setup_pycharm_button = tk.Button(master=self.main_frame, text="Setup pycharm", bg=self.script_color,
                                                  command=self.setup_pycharm, font=["Helvetica", 10, "bold"],
                                                  state=tk.DISABLED)
        self.setup_pycharm_button.config(width=13, height=1)
        self.setup_pycharm_button.place(x=190, y=450)

    def create_check_radios_button(self):
        """
        This method creates "Check radios" button which allow to start check radios script
        """
        if self.running_script_state_flag is False:
            self.check_radios_button = tk.Button(master=self.main_frame, text="Check radios", bg=self.script_color,
                                                 command=self.check_radios, font=["Helvetica", 10, "bold"])
        else:
            self.check_radios_button = tk.Button(master=self.main_frame, text="Check radios", bg=self.script_color,
                                                 command=self.check_radios, font=["Helvetica", 10, "bold"],
                                                 state=tk.DISABLED)
        self.check_radios_button.config(width=13, height=1)
        self.check_radios_button.place(x=420, y=450)

    def create_full_commis_button(self):
        """
        This method creates "Clear SCF" button which allow to start full commissioning script
        """
        if self.running_script_state_flag is False:
            self.full_commis_button = tk.Button(master=self.main_frame, text="Clear SCF", bg=self.script_color,
                                                command=self.full_commis, font=["Helvetica", 10, "bold"])
        else:
            self.full_commis_button = tk.Button(master=self.main_frame, text="Clear SCF", bg=self.script_color,
                                                command=self.full_commis, font=["Helvetica", 10, "bold"],
                                                state=tk.DISABLED)
        self.full_commis_button.config(width=13, height=1)
        self.full_commis_button.place(x=305, y=450)

    def create_reset_testline_button(self):
        """
        This method creates "Reset testline" button which allow to start reset testline script
        """
        if self.running_script_state_flag is False:
            self.reset_testline_button = tk.Button(master=self.main_frame, text="Reset testline", bg=self.script_color,
                                                   command=self.reset_testline, font=["Helvetica", 10, "bold"])
        else:
            self.reset_testline_button = tk.Button(master=self.main_frame, text="Reset testline", bg=self.script_color,
                                                   command=self.reset_testline, font=["Helvetica", 10, "bold"],
                                                   state=tk.DISABLED)
        self.reset_testline_button.config(width=13, height=1)
        self.reset_testline_button.place(x=650, y=450)

    def create_delta_button(self):
        """
        This method creates "Load delta" button which allow to start delta loading script
        """

        if self.running_script_state_flag is False:
            self.load_delta_button = tk.Button(master=self.main_frame, text="Load delta", bg=self.script_color,
                                               command=self.load_delta, font=["Helvetica", 10, "bold"])
        else:
            self.load_delta_button = tk.Button(master=self.main_frame, text="Load delta", bg=self.script_color,
                                               command=self.load_delta, font=["Helvetica", 10, "bold"],
                                               state=tk.DISABLED)
        self.load_delta_button.config(width=13, height=1)
        self.load_delta_button.place(x=535, y=450)

    def show_tests(self):
        """
        This method creates all "Tests" tab objects
        """
        self.current_tab = "Tests"
        self.destroy_all()
        self.create_tests_button()
        self.create_results_button()
        self.create_reports_button()
        self.create_label("Choose test scenarios you want to run:", 35)
        self.create_listbox()
        self.create_tests_tabs()
        self.fill_tabs_wth_test_paths()
        self.create_grep_entry()
        self.create_admin_button()
        self.create_setup_pycharm_button()
        self.create_check_radios_button()
        self.create_full_commis_button()
        self.create_reset_testline_button()
        self.create_delta_button()
        self.create_report_test_check_button()
        self.create_import_to_rotta_button()
        self.create_run_tests_button()

    def get_tests_reports_paths(self, event):
        """
        This method gets paths to test output.xmls and to test logs and insert it into tabs.
        """
        self.reports_listbox.delete(0, tk.END)
        self.logs_listbox.delete(0, tk.END)
        self.paths_to_report_tests_list = []
        self.paths_to_open_tests_list = []
        self.report_path_var = self.report_path.get()
        self._get_list_of_tests_to_report(self.report_path_var)
        self.paths_to_report_tests_list = [full_test_path.replace(self.report_path_var, '')
                                           for full_test_path in self.paths_to_report_tests_list]
        self.paths_to_open_tests_list = [full_test_path.replace(self.report_path_var, '')
                                         for full_test_path in self.paths_to_open_tests_list]
        self.fill_tabs_wth_test_paths_to_report()

    def _get_list_of_tests_to_report(self, path):
        """
        This method gets paths to test output.xmls and to test logs
        """
        if path == self.logs_path and len(path) == len(self.logs_path) \
                or path == self.logs_path and len(path) == len(self.logs_path)-1:
            paths_to_files_list = self.files_generator(path, 3)
        else:
            paths_to_files_list = self.files_generator(path, 1)
        for each_file_path in paths_to_files_list:
            if each_file_path.endswith("output.xml"):
                self.paths_to_report_tests_list.append(each_file_path)
            if each_file_path.endswith(".html") or each_file_path.endswith(".txt") or each_file_path.endswith(".log"):
                self.paths_to_open_tests_list.append(each_file_path)
        self.paths_to_report_tests_list.sort()
        self.paths_to_open_tests_list.sort()

    def files_generator(self, folder_path, max_depth=3):
        """
        This method defines depth of finding paths - for default path depth is 3, for other paths depth is lower.
        """
        for foldername, subfolders, filenames in os.walk(folder_path):
            current_depth = foldername[len(folder_path):].count(os.sep)
            if current_depth > max_depth:
                continue
            for filename in filenames:
                yield os.path.join(foldername, filename)
            if current_depth == max_depth:
                subfolders.clear()

    def _get_files_from_directory(self, path):
        """
        This method search for all files in 5G_SW_WRO directory and return theirs paths
         :param path: path to sw wro tests
        """
        paths_to_files_list = []
        all_files_in_path = os.listdir(path)
        for each_file in all_files_in_path:
            each_file_path = os.path.join(path, each_file)
            if os.path.isdir(each_file_path):
                paths_to_files_list = paths_to_files_list + self._get_files_from_directory(each_file_path)
            else:
                paths_to_files_list.append(each_file_path)
        return paths_to_files_list

    def fill_tabs_wth_test_paths_to_report(self):
        """
        This method fills two tabs for tests reports and test logs with corresponding test paths
        """
        for each_test in self.paths_to_report_tests_list:
            self.reports_listbox.insert(tk.END, each_test)
        for each_test in self.paths_to_open_tests_list:
            self.logs_listbox.insert(tk.END, each_test)

    def show_results(self):
        """
        This method creates all "Results" tab objects
        """
        self.current_tab = "Results"
        self.destroy_all()
        self.create_tests_button()
        self.create_results_button()
        self.create_reports_button()
        self.create_label("State of test:", 11)
        self.create_listbox()
        self.create_results_tabs("Results")
        self.load_results_into_tab()

    def log_into_results(self, log_data):
        """
        This method add log into results array
        """
        self.results_array.append(log_data)

    def load_results_into_tab(self):
        """
        This method add results into results listbox
        """
        for result in self.results_array:
            self.results_listbox.insert(tk.END, result)

    def show_reports(self):
        """
        This method creates all "Reports" tab objects
        """
        self.current_tab = "Reports"
        self.destroy_all()
        self.create_tests_button()
        self.create_results_button()
        self.create_reports_button()
        self.create_label("Report tests:", 11)
        self.create_listbox()
        self.create_logs_tabs("placeholder")
        self.create_label("Your log folder:", 14, 75, 451)

        self.report_path = Entry(master=self.main_frame, width=35, bg=self.entry_color)
        self.report_path.place(x=175, y=450)
        self.report_path.insert(tk.END, self.logs_path)
        self.report_path.bind('<Return>', self.get_tests_reports_paths)
        self.get_tests_reports_paths("placeholder")
        self.create_report_tests_button()

    def report_tests(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about tests to report.
        It results in triggering bash script.
        """
        if len(self.reports_listbox.curselection()) != 0:
            self._check_selected_tests_report_paths()
            report_list = []
            for each_test_path in self.tests_reports_paths_selected_list:
                bash_path = self.report_path_var+each_test_path
                report_list.append(bash_path)
            report_list = ' '.join(report_list)
            with open(self.write_file, "w") as file:
                file.write("Report "+str(report_list))
            self.generate_results_display()

    def setup_pycharm(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about setup pycharm.
        It results in triggering bash script.
        """
        with open(self.write_file, "w") as file:
            file.write("Setup_pycharm")
        self.generate_results_display()

    def admin(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about admin open.
        It results in triggering bash script.
        """
        with open(self.write_file, "w") as file:
            file.write("Open_admin")
        self.generate_results_display()

    def full_commis(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about full commissioning.
        It results in triggering bash script.
        """
        with open(self.write_file, "w") as file:
            file.write("Clear_scf")
        self.generate_results_display()

    def check_radios(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about checking radios.
        It results in triggering bash script.
        """
        with open(self.write_file, "w") as file:
            file.write("Check_radios")
        self.generate_results_display()

    def reset_testline(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about testline reset.
        It results in triggering bash script.
        """
        with open(self.write_file, "w") as file:
            file.write("Reset_testline")
        self.generate_results_display()

    def close_bash(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about closing bash script.
        It results in closing bash script.
        """
        with open(self.write_file, "w") as file:
            file.write("End_bash")
        self.generate_results_display()

    def load_delta(self):
        """
        This method extracts information from selected tests array and look for information about delta path.
        This method writes to "/tmp/testrunner_tmp_file" information about loading delta.
        It results in triggering bash script.
        """
        self._check_selected_tests_paths()
        selected_test = self.tests_paths_selected_list
        if len(self.tests_paths_selected_list) == 1:
            delta_test_path = selected_test[0]
            index_last_slash = delta_test_path.rfind('/')

            if index_last_slash != -1:
                result = delta_test_path[:index_last_slash]
            else:
                print("Delta error")

            delta_name = self.check_delta_name(self.sw_wro_file_path+delta_test_path)

            delta_path = self.sw_wro_file_path+result+"/config/default/"+delta_name
            with open(self.write_file, "w") as file:
                file.write("Delta "+delta_path)
            self.generate_results_display()

    def check_delta_name(self, filepath):
        """
        This method extracts information from file and returns information about delta path.
        """
        suite = TestData(source=filepath)
        data_list = suite.setting_table.suite_setup._data_as_list()
        data_list_to_lower = [value.lower() for value in data_list]
        search_value = "find scfc and send delta commissioning"
        index = data_list_to_lower.index(search_value)
        found_value = data_list_to_lower[index+1]
        parts = found_value.split("=")
        found_part = parts[1].strip()
        return found_part

    def _generate_file_with_selected_tests(self):
        """
        This method writes to "/tmp/testrunner_tmp_file" information about starting tests.
        It results in triggering bash script.
        """
        if len(self.all_tests_tab.curselection()) != 0 or len(self.cit_tab.curselection()) != 0 or len(
                self.crt_tab.curselection()) != 0:
            self._check_selected_tests_paths()
            self._save_file_with_tests_to_run()
            with open(self.write_file, "w") as file:
                file.write("Start_test")
            self.generate_results_display()
            self.tests_paths_selected_list = []

    def generate_results_display(self):
        """
        This method show "Results" tab and starts socket connection
        """
        self.running_script_state_flag = True
        self.show_results()
        threading.Thread(target=self.connect_with_socket).start()

    def connect_with_socket(self):
        """
        This method defines socket connection behavior between bash and application. It inserts received data to
        "Results" tab and end stream in case of receiving "End_of_stream"
        """
        time.sleep(2)
        HOST = 'localhost'
        PORT = 12333
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((HOST, PORT))
        self.server_socket.listen()
        try:
            while True:
                client_socket, client_adress = self.server_socket.accept()

                while True:
                    data = client_socket.recv(1024).decode('utf-8')
                    if not data:
                        break
                    if data[:-1].lower() == 'End_of_stream':
                        break
                    else:
                        self.log_into_results(data[:-1])
                        if self.current_tab == "Results":
                            self.results_listbox.insert(tk.END, data[:-1])
                        break
                client_socket.close()
                if data[:-1].lower() == 'end_of_stream':
                    self.running_script_state_flag = False
                    break
        except KeyboardInterrupt:
            self.server_socket.close()
            print("Socket stopped by user")
        finally:
            self.running_script_state_flag = False
            self.reload_current_tab()
            self.server_socket.close()

    def reload_current_tab(self):
        """
        This method checks which tab is active and triggers tab reloading.
        """
        if self.current_tab == "Tests":
            self.show_tests()
        elif self.current_tab == "Results":
            self.show_results()
        elif self.current_tab == "Reports":
            self.show_reports()
        else:
            print("Application reload error!")

    def _save_file_with_tests_to_run(self):
        """
        This method creates .txt file on Desktop with paths to test cases to execute,
        which were marked in graphic user interface
        """
        generated_file_name = f"Tests_to_run_{datetime.now().strftime('%Y_%m_%d_%H_%M_%S')}.txt"
        with open("/home/ute/Desktop/" + generated_file_name, "a") as generated_file:
            for each_test_path in self.tests_paths_selected_list:
                generated_file.write(f"{self.actual_path}{each_test_path} \n")
            if len(self.cit_tab.curselection()) != 0:
                generated_file.write("CIT\n")
            if len(self.crt_tab.curselection()) != 0:
                generated_file.write("CRT\n")
            generated_file.write(f"{self._is_report_checked()} \n")
            generated_file.write(f"{self._is_rotta_upload_checked()} \n")

    def _is_report_checked(self):
        """
        This method returns True if report check button is marked and False otherwise
        """
        return True if self.checkbutton_variable.get() else False

    def _is_rotta_upload_checked(self):
        """
        This method returns Upload and path if rotta check button is marked and NoUpload otherwise
        """
        return "Upload_/home/ute/rotta/"+self.rotta_path.get() if self.checkbutton_variable_rotta.get() else "NoUpload"

    def _check_selected_tests_paths(self):
        """
        This method gets selected tests paths for current tab and appends them to self.tests_paths_selected_list
        """
        self.tests_paths_selected_list = []
        if len(self.all_tests_tab.curselection()) != 0:
            self._get_selected_paths(self.all_tests_tab)
        elif len(self.cit_tab.curselection()) != 0:
            self._get_selected_paths(self.cit_tab)
        elif len(self.crt_tab.curselection()) != 0:
            self._get_selected_paths(self.crt_tab)

    def _check_selected_tests_report_paths(self):
        """
        This method gets selected tests paths for current tab and appends them to self.tests_reports_paths_selected_list
        """
        self.tests_reports_paths_selected_list = []
        if len(self.results_listbox.curselection()) != 0:
            self._get_selected_report_paths(self.results_listbox)

    def _check_selected_tests_logs_paths(self):
        """
        This method gets selected tests paths for current tab and appends them to self.tests_logs_paths_selected_list
        """
        self.tests_logs_paths_selected_list = []
        if len(self.logs_listbox.curselection()) != 0:
            self._get_selected_logs_paths(self.logs_listbox)

    def _get_selected_paths(self, tkinter_listbox):
        """
        This method gets selected tests paths for given tab and appends them to self.tests_paths_selected_list
         :param tkinter_listbox: eg. self.all_tests_tab, self.cit_tab, self.crt_tab
        """
        for each_selected_path in tkinter_listbox.curselection():
            self.tests_paths_selected_list.append(tkinter_listbox.get(each_selected_path))

    def _get_selected_report_paths(self, tkinter_listbox):
        """
        This method gets selected tests reports paths for given tab and appends them to
        self.tests_reports_paths_selected_list
         :param tkinter_listbox: eg. self.all_tests_tab, self.cit_tab, self.crt_tab
        """
        for each_selected_path in tkinter_listbox.curselection():
            self.tests_reports_paths_selected_list.append(tkinter_listbox.get(each_selected_path))

    def _get_selected_logs_paths(self, tkinter_listbox):
        """
        This method gets selected tests logs paths for given tab and appends them to self.tests_logs_paths_selected_list
         :param tkinter_listbox: eg. self.all_tests_tab, self.cit_tab, self.crt_tab
        """
        for each_selected_path in tkinter_listbox.curselection():
            self.tests_logs_paths_selected_list.append(tkinter_listbox.get(each_selected_path))


if __name__ == '__main__':
    TestPickerGraphicUserInterface().create_graphic_user_interface()
