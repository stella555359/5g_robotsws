"""
This module provides a GUI application for managing deployments and terminations of Cloud BTS from Mantaray.

Classes:
    LabInfo: Handles Mantaray lab information retrieval.
    DeploymentManager: Manages deployment and termination scripts.
    GUI: Provides the graphical user interface for the application.

Usage:
    Acitvate test_repo venv in terminal by executing command "source /home/ute/test_repo/bin/activate" or alias "robot".
    Start the GUI application by executing "python <path to this module>".
"""

import os
import yaml
import json
import tkinter as tk
from tkinter import messagebox, ttk
from taf.nms.netact import netact
from taf.transport.ssh import ssh


class LabInfo:
    """
    Handles Mantaray lab information retrieval.

    Attributes:
        lab_number (str): Mantaray lab number.
        labs_yaml (str): The path to the YAML file containing lab information.
        lab_ip (str): The IP address of the lab.
        user (str): The username for the lab.
        password (str): The password for the lab.
        tampere_lab (bool): Indicates if the lab is a Tampere lab.
    """

    def __init__(self, lab_number):
        self.lab_number = lab_number
        self.labs_yaml = '/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cloud_common_resources/mantaray/' \
                         'mantaray_labs.yaml'
        self.lab_ip, self.user, self.password, self.tampere_lab = self.get_lab_data()

    def get_lab_data(self):
        """
        Retrieves lab data from the YAML file.

        Returns:
            tuple: A tuple containing the lab IP address, username, and password.
        """
        with open(self.labs_yaml, 'r') as file:
            labs_data = yaml.safe_load(file)
            ip = labs_data[f'SRNCLAB{self.lab_number}']
            usr = labs_data['NMS_USERNAME']
            pswd = labs_data['NMS_PASSWORD']
            tampere = any(int(self.lab_number) == lab for lab in labs_data['TAMPERE_LABS'])
            return ip, usr, pswd, tampere

    def list_builds(self):
        """
        Retrieves list of available builds from given Mantaray lab.

        Returns:
            list: A list of available builds.
        """
        nms = netact()
        nms.add_node(service_name="cmwas", hostname=self.lab_ip, username=self.user, password=self.password)
        available_builds = nms.get_list_of_imported_builds(mo_type="CNF")
        nms.delete_node(service_name="cmwas")
        return available_builds

    def get_ccr_info(self):
        """
        Retrieves CCR information and available space from given Mantaray lab.

        Returns:
            tuple: A tuple containing a list of public CCR names and available space on given Mantaray lab.
        """
        ssh_client = ssh()
        ssh_client.connect_to(hostname=self.lab_ip, username=self.user, password=self.password)
        domain = "srntre" if self.tampere_lab else "srnblr"
        ccr_cmd = (f"curl -X 'GET' 'https://srnclab{self.lab_number}lcm.{domain}.nsn-rdnet.net:8443/api/v2.0/projects?"
                   f"public=true&' -H 'accept: application/json' -k")
        avail_space_cmd = "df -h --output=avail /var/opt/nokia/oss/global/swm/swm_arch/ | tail -n +2"
        ccr_info = ssh_client.execute(ccr_cmd)
        avail_space = ssh_client.execute(avail_space_cmd)
        ssh_client.disconnect()
        json_list = json.loads(ccr_info)
        ccr_names = [item['name'] for item in json_list if 'library' not in item['name']]
        return ccr_names, avail_space


class DeploymentManager:
    """
    Manages deployment and termination scripts.

    Attributes:
        lab_info (LabInfo): An instance of LabInfo containing lab information.
    """

    def __init__(self, lab_info):
        self.lab_info = lab_info

    def check_available_sw(self):
        """
        Checks available software and CCR information on given Mantaray lab.

        Returns:
            tuple: A tuple containing available software, CCR names, and available space.
        """
        try:
            available_sw = self.lab_info.list_builds()
            available_ccrs, available_space = self.lab_info.get_ccr_info()
            return available_sw, available_ccrs, available_space.strip() + "B"
        except Exception as e:
            raise RuntimeError(f"Failed to check available software: {str(e)}")

    @staticmethod
    def deployment_script(bts_init, nms_lab, ccr, vdu_sw_version, vcu_sw_version, nokia_sync_version,
                          rannic_sw_version, koredump_sw_version, koredump_vdu_selected, koredump_vcu_selected):
        """
        Generates and executes the deployment script.

        Args:
            bts_init (str): The Cloud BTS init file.
            nms_lab (str): The NMS lab identifier.
            ccr (str): The CCR name.
            vdu_sw_version (str): The vDU software version.
            vcu_sw_version (str): The vCU software version.
            koredump_sw_version (str): The Koredump Operator version.
            nokia_sync_version (str): The Nokia Sync Operator version.
            rannic_sw_version (str): The Ran Nic SW Controller version.
            koredump_vdu_selected (bool): Whether the vDU toggle is selected.
            koredump_vcu_selected (bool): Whether the vCU toggle is selected.
        Raises:
            ValueError: If required parameters are not provided.
        """
        if not nms_lab or not bts_init or not ccr:
            raise ValueError("Cloud BTS, NMS Lab and CCR must be filled out")

        test_cases = []
        if vcu_sw_version or (koredump_sw_version and koredump_vcu_selected):
            test_cases.append("Integrate vCU Server")
        if koredump_sw_version and koredump_vcu_selected:
            test_cases.append("Koredump Operator Deployment vCU")
        if vcu_sw_version:
            test_cases.append("vCU Deployment")

        if vdu_sw_version or nokia_sync_version or rannic_sw_version or (koredump_sw_version and koredump_vdu_selected):
            test_cases.append("Integrate vDU Server")
        if koredump_sw_version and koredump_vdu_selected:
            test_cases.append("Koredump Operator Deployment vDU")
        if rannic_sw_version:
            test_cases.append("Rannic Deployment")
        if nokia_sync_version:
            test_cases.append("Nokia Sync Operator Deployment")
        if vdu_sw_version:
            test_cases.append("vDU Deployment")
        if koredump_sw_version and not (koredump_vcu_selected or koredump_vdu_selected):
            raise ValueError("Please select where to deploy Koredump Operator (vDU and/or vCU)")
        if (koredump_vcu_selected or koredump_vdu_selected) and not koredump_sw_version:
            raise ValueError("Koredump Operator version must be provided if selected for deployment")
        if not test_cases:
            raise ValueError("Please fill out SW versions for your deployment")

        test_cases_str = " ".join(f"-t '{tc}'" for tc in test_cases)

        command = (
            f"robot --variablefile /home/ute/testline_configuration/{bts_init} "
            f"--variable NMS_LAB:{nms_lab} "
            f"--variable CCR_NAME:{ccr} "
            f"--variable VDU_SW_VERSION:{vdu_sw_version} "
            f"--variable VCU_SW_VERSION:{vcu_sw_version} "
            f"--variable KOREDUMP_VERSION:{koredump_sw_version} "
            f"--variable NOKIA_SYNC_VERSION:{nokia_sync_version} "
            f"--variable RANNIC_SW_VERSION:{rannic_sw_version} "
            "-T -L TRACE -d /home/ute/Mantaray_deployment "
            f"{test_cases_str} "
            "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/CloudRAN/Mantaray_deployment.robot"
        )
        os.system(command)

    @staticmethod
    def upgrade_script(bts_init, nms_lab, vdu_sw_version, vcu_sw_version, nokia_sync_version,
                       rannic_sw_version, koredump_sw_version, koredump_vdu_selected, koredump_vcu_selected):
        """
        Generates and executes the upgrade script.

        Args:
            bts_init (str): The Cloud BTS init file.
            nms_lab (str): The NMS lab identifier.
            vdu_sw_version (str): The vDU software version.
            vcu_sw_version (str): The vCU software version.
            nokia_sync_version (str): The Nokia Sync Operator version.
            rannic_sw_version (str): The Ran Nic SW Controller version.
            koredump_sw_version (str): The Koredump Operator version.
            koredump_vdu_selected (bool): Whether the vDU toggle is selected.
            koredump_vcu_selected (bool): Whether the vCU toggle is selected.
        Raises:
            ValueError: If required parameters are not provided.
        """
        if not nms_lab or not bts_init:
            raise ValueError("Cloud BTS and NMS Lab must be filled out")

        test_cases = []

        if koredump_sw_version and koredump_vcu_selected:
            test_cases.append("Upgrade Koredump Operator vCU")
        if koredump_sw_version and koredump_vdu_selected:
            test_cases.append("Upgrade Koredump Operator vDU")
        if vcu_sw_version:
            test_cases.append("Upgrade vCU")
        if rannic_sw_version:
            test_cases.append("Upgrade Rannic")
        if nokia_sync_version:
            test_cases.append("Upgrade Nokia Sync Operator")
        if vdu_sw_version:
            test_cases.append("Upgrade vDU")
        if koredump_sw_version and not (koredump_vcu_selected or koredump_vdu_selected):
            raise ValueError("Please select where to upgrade Koredump Operator (vDU and/or vCU)")
        if (koredump_vcu_selected or koredump_vdu_selected) and not koredump_sw_version:
            raise ValueError("Koredump Operator version must be provided if selected for upgrade")
        if not test_cases:
            raise ValueError("Please fill out SW versions for upgrade operation")

        test_cases_str = " ".join(f"-t '{tc}'" for tc in test_cases)

        command = (
            f"robot --variablefile /home/ute/testline_configuration/{bts_init} "
            f"--variable NMS_LAB:{nms_lab} "
            f"--variable VDU_SW_VERSION:{vdu_sw_version} "
            f"--variable VCU_SW_VERSION:{vcu_sw_version} "
            f"--variable NOKIA_SYNC_VERSION:{nokia_sync_version} "
            f"--variable RANNIC_SW_VERSION:{rannic_sw_version} "
            f"--variable KOREDUMP_VERSION:{koredump_sw_version} "
            "-T -L TRACE -d /home/ute/Mantaray_deployment "
            f"{test_cases_str} "
            "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/CloudRAN/Mantaray_upgrade.robot"
        )
        os.system(command)

    @staticmethod
    def termination_script(bts_init, nms_lab, terminate_vcu, terminate_vdu, terminate_rannic, terminate_sync,
                           terminate_koredump, vdu_koredump_selected, vcu_koredump_selected, deintegrate_vcu,
                           deintegrate_vdu):
        """
        Generates and executes the termination script.

        Args:
            bts_init (str): The Cloud BTS init file.
            nms_lab (str): The NMS lab identifier.
            terminate_vcu (bool): Whether to terminate vCU.
            terminate_vdu (bool): Whether to terminate vDU.
            terminate_rannic (bool): Whether to terminate Ran Nic SW Controller.
            terminate_sync (bool): Whether to terminate Nokia Sync Operator.
            terminate_koredump (bool): Whether to terminate Koredump Operator.
            vdu_koredump_selected (bool): Whether the vDU koredump toggle is selected.
            vcu_koredump_selected (bool): Whether the vCU koredump toggle is selected.
            deintegrate_vcu (bool): Whether to deintegrate vCU.
            deintegrate_vdu (bool): Whether to deintegrate vDU.
        Raises:
            ValueError: If required parameters are not provided.
        """
        if not nms_lab or not bts_init:
            raise ValueError("Cloud BTS and NMS Lab must be filled out")
        test_cases = []
        if terminate_koredump and vcu_koredump_selected:
            test_cases.append("vCU Koredump Operator Termination")
        if terminate_vcu:
            test_cases.append("vCU Termination")
            test_cases.append("Deintegrate vCU Server")
        if terminate_vdu:
            test_cases.append("vDU Termination")
        if terminate_koredump and vdu_koredump_selected:
            test_cases.append("vDU Koredump Operator Termination")
        if terminate_rannic:
            test_cases.append("Rannic Termination")
        if terminate_sync:
            test_cases.append("Nokia Sync Operator Termination")
        if terminate_vdu and terminate_rannic and terminate_sync:
            test_cases.append("Deintegrate vDU Server")
        if deintegrate_vcu and not terminate_vcu:
            test_cases.append("Deintegrate vCU Server")
        if deintegrate_vdu and "Deintegrate vDU Server" not in test_cases:
            test_cases.append("Deintegrate vDU Server")
        if terminate_koredump and not (vcu_koredump_selected or vdu_koredump_selected):
            raise ValueError("Please select where to terminate Koredump Operator (vDU and/or vCU)")
        if not test_cases:
            raise ValueError("Please select at least one component to terminate")

        test_cases_str = " ".join(f"-t '{tc}'" for tc in test_cases)

        command = (
            f"robot --variablefile /home/ute/testline_configuration/{bts_init} "
            f"--variable NMS_LAB:{nms_lab} "
            "-T -L TRACE -d /home/ute/Mantaray_deployment "
            f"{test_cases_str} "
            "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/CloudRAN/Mantaray_termination.robot"
        )
        os.system(command)


class GUI:
    """
    Provides the graphical user interface for the application.

    Attributes:
        main_window (tk.Tk): The main window of the application.
    """

    def __init__(self, main_window):
        self.main_window = main_window
        self.main_window.title("Manta Deployer")
        self.setup_ui()

    def setup_ui(self):
        """
        Sets up the user interface elements.
        """
        window_width = 630
        window_height = 280
        screen_width = self.main_window.winfo_screenwidth()
        screen_height = self.main_window.winfo_screenheight()
        position_top = int(screen_height / 2 - window_height / 2)
        position_right = int(screen_width / 2 - window_width / 2)
        self.main_window.geometry(f'{window_width}x{window_height}+{position_right}+{position_top}')

        style = ttk.Style()
        style.map("TCheckbutton", indicatorcolor=[('selected', 'black'), ('!selected', 'white')])

        self.mode_combobox = ttk.Combobox(self.main_window, width=15, values=["Deploy", "Upgrade", "Terminate"],
                                          state="readonly", justify="center")
        self.mode_combobox.grid(row=0, column=1)
        self.mode_combobox.bind("<<ComboboxSelected>>", self.switch_mode)
        self.mode_combobox.set("Deploy")
        tk.Label(self.main_window, text="Mode:").grid(row=0, column=0)

        self.bts_init_entry = tk.Entry(self.main_window)
        self.bts_init_entry.grid(row=1, column=1)
        self.bts_init_entry.bind("<FocusIn>", self.show_bts_init_suggestions)
        self.bts_init_entry.bind("<KeyRelease>", self.update_bts_init_suggestions)
        self.bts_init_suggestions = tk.Listbox(self.main_window, width=30)
        self.bts_init_suggestions.grid(row=2, column=1, pady=10)
        self.bts_init_suggestions.bind("<<ListboxSelect>>", self.select_bts_init)
        self.bts_init_suggestions.grid_remove()

        self.nms_lab_entry = tk.Entry(self.main_window)
        self.available_ccrs = ttk.Combobox(self.main_window, width=30)
        self.vdu_sw_version_entry = ttk.Combobox(self.main_window, width=30)
        self.vcu_sw_version_entry = ttk.Combobox(self.main_window, width=30)
        self.koredump_sw_version_entry = ttk.Combobox(self.main_window, width=30)
        self.koredump_vdu_check = ttk.Checkbutton(
            self.main_window, text="vDU", style="TCheckbutton"
        )
        self.koredump_vcu_check = ttk.Checkbutton(
            self.main_window, text="vCU", style="TCheckbutton"
        )
        self.nokia_sync_version_entry = ttk.Combobox(self.main_window, width=30)
        self.rannic_sw_version_entry = ttk.Combobox(self.main_window, width=30)
        self.terminate_vcu_check = ttk.Checkbutton(self.main_window, text="Terminate vCU", style="TCheckbutton")
        self.terminate_vdu_check = ttk.Checkbutton(self.main_window, text="Terminate vDU", style="TCheckbutton")
        self.terminate_koredump_check = ttk.Checkbutton(
            self.main_window, text="Terminate Koredump on:", style="TCheckbutton"
        )
        self.terminate_rannic_check = ttk.Checkbutton(
            self.main_window, text="Terminate Ran Nic SW Controller", style="TCheckbutton"
        )
        self.terminate_sync_check = ttk.Checkbutton(
            self.main_window, text="Terminate Nokia Sync Operator", style="TCheckbutton"
        )
        self.ocp_deintegration_check = ttk.Checkbutton(
            self.main_window, text="Advanced", style="TCheckbutton", command=self.toggle_ocp_deintegration
        )
        self.deintegrate_vcu_check = ttk.Checkbutton(self.main_window, text="deint. vCU OCP", style="TCheckbutton")
        self.deintegrate_vdu_check = ttk.Checkbutton(self.main_window, text="deint. vDU OCP", style="TCheckbutton")
        self.terminate_koredump_vdu_check = ttk.Checkbutton(self.main_window, text="vDU", style="TCheckbutton")
        self.terminate_koredump_vcu_check = ttk.Checkbutton(self.main_window, text="vCU", style="TCheckbutton")
        self.check_sw_button = tk.Button(self.main_window, text="Check available SW", command=self.check_available_sw)
        self.deploy_button = tk.Button(self.main_window, text="Deploy", width=15, command=self.deployment)
        self.terminate_button = tk.Button(self.main_window, text="Terminate", command=self.termination)
        self.upgrade_button = tk.Button(self.main_window, text="Upgrade", width=15, command=self.upgrade)

        self.show_deploy_fields()

    def toggle_ocp_deintegration(self):
        """
        Toggles the visibility of OCP deintegration checkboxes.
        """
        if self.ocp_deintegration_check.instate(['selected']):
            self.deintegrate_vcu_check.grid(row=5, column=3, pady=3, sticky='w')
            self.deintegrate_vdu_check.grid(row=6, column=3, pady=3, sticky='w')
        else:
            self.deintegrate_vcu_check.grid_remove()
            self.deintegrate_vdu_check.grid_remove()

    def switch_mode(self, event):
        """
        Switches between deploy and terminate modes.

        Args:
            event (tk.Event): The event that triggered this method.
        """
        selected_mode = self.mode_combobox.get()
        if selected_mode == "Deploy":
            self.show_deploy_fields()
        elif selected_mode == "Upgrade":
            self.show_upgrade_fields()
        elif selected_mode == "Terminate":
            self.show_terminate_fields()

    def show_deploy_fields(self):
        """
        Displays the fields for deployment mode.
        """
        for widget in self.main_window.winfo_children():
            widget.grid_remove()
        self.mode_combobox.grid(row=1, column=2, pady=1, padx=40, sticky='w')
        tk.Label(self.main_window, text="Mode:").grid(row=0, column=2, padx=80, sticky='w')
        tk.Label(self.main_window, text="Cloud BTS:").grid(row=1, column=0, padx=10, sticky='e')
        self.bts_init_entry.grid(row=1, column=1)
        tk.Label(self.main_window, text="NMS Lab:").grid(row=3, column=0, padx=10, sticky='e')
        self.nms_lab_entry.grid(row=3, column=1)
        tk.Label(self.main_window, text="CCR:").grid(row=4, column=0, padx=10, sticky='e')
        self.available_ccrs.grid(row=4, column=1, pady=1)
        tk.Label(self.main_window, text="vCU SW Version:").grid(row=5, column=0, padx=10, sticky='e')
        self.vcu_sw_version_entry.grid(row=5, column=1, pady=1)
        tk.Label(self.main_window, text="vDU SW Version:").grid(row=6, column=0, padx=10, sticky='e')
        self.vdu_sw_version_entry.grid(row=6, column=1, pady=1)
        tk.Label(self.main_window, text="Koredump Version:").grid(row=7, column=0, padx=10, sticky='e')
        self.koredump_sw_version_entry.grid(row=7, column=1, pady=1)
        tk.Label(self.main_window, text="deploy on:").grid(row=7, column=2, padx=7, sticky='w')
        self.koredump_vdu_check.grid(row=7, column=2, pady=3, padx=85, sticky='w')
        self.koredump_vcu_check.grid(row=7, column=2, pady=3, padx=135, sticky='w')
        tk.Label(self.main_window, text="Nokia Sync Version:").grid(row=8, column=0, padx=10, sticky='e')
        self.nokia_sync_version_entry.grid(row=8, column=1, pady=1)
        tk.Label(self.main_window, text="Ran Nic Version:").grid(row=9, column=0, padx=10, sticky='e')
        self.rannic_sw_version_entry.grid(row=9, column=1, pady=1)
        self.check_sw_button.grid(row=3, column=2, pady=1, padx=30, sticky='w')
        self.deploy_button.grid(row=10, column=1, pady=10, padx=10)

    def show_upgrade_fields(self):
        """
        Displays the fields for upgrade mode.
        """
        for widget in self.main_window.winfo_children():
            widget.grid_remove()
        self.mode_combobox.grid(row=1, column=2, pady=1, padx=20, sticky='w')
        tk.Label(self.main_window, text="Mode:").grid(row=0, column=2, padx=60, sticky='w')
        tk.Label(self.main_window, text="Cloud BTS:").grid(row=1, column=0, padx=10, sticky='e')
        self.bts_init_entry.grid(row=1, column=1)
        tk.Label(self.main_window, text="NMS Lab:").grid(row=3, column=0, padx=10, sticky='e')
        self.nms_lab_entry.grid(row=3, column=1)
        tk.Label(self.main_window, text="New vCU SW:").grid(row=5, column=0, padx=10, sticky='e')
        self.vcu_sw_version_entry.grid(row=5, column=1, pady=1)
        tk.Label(self.main_window, text="New vDU SW:").grid(row=6, column=0, padx=10, sticky='e')
        self.vdu_sw_version_entry.grid(row=6, column=1, pady=1)
        tk.Label(self.main_window, text="New Koredump Version:").grid(row=7, column=0, padx=10, sticky='e')
        self.koredump_sw_version_entry.grid(row=7, column=1, pady=1)
        tk.Label(self.main_window, text="upgrade on:").grid(row=7, column=2, padx=3, sticky='w')
        self.koredump_vdu_check.grid(row=7, column=2, pady=3, padx=85, sticky='w')
        self.koredump_vcu_check.grid(row=7, column=2, pady=3, padx=135, sticky='w')
        tk.Label(self.main_window, text="Nokia Sync Version:").grid(row=8, column=0, padx=10, sticky='e')
        self.nokia_sync_version_entry.grid(row=8, column=1, pady=1)
        tk.Label(self.main_window, text="Ran Nic Version:").grid(row=9, column=0, padx=10, sticky='e')
        self.rannic_sw_version_entry.grid(row=9, column=1, pady=1)
        self.check_sw_button.grid(row=3, column=2, pady=1, padx=10)
        self.upgrade_button.grid(row=10, column=1, pady=10, padx=10)

    def show_terminate_fields(self):
        """
        Displays the fields for termination mode.
        """
        for widget in self.main_window.winfo_children():
            widget.grid_remove()
        self.mode_combobox.grid(row=1, column=2, padx=5)
        tk.Label(self.main_window, text="Mode:").grid(row=0, column=2, sticky='w')
        tk.Label(self.main_window, text="Cloud BTS:").grid(row=1, column=0, padx=10, sticky='e')
        self.bts_init_entry.grid(row=1, column=1, pady=3)
        self.bts_init_suggestions.grid(row=2, column=1, pady=10)
        self.bts_init_suggestions.grid_remove()
        tk.Label(self.main_window, text="NMS Lab:").grid(row=3, column=0, padx=10, sticky='e')
        self.nms_lab_entry.grid(row=3, column=1, pady=3)
        self.terminate_vcu_check.grid(row=4, column=1, pady=3, sticky='w')
        self.terminate_vdu_check.grid(row=5, column=1, pady=3, sticky='w')
        self.terminate_koredump_check.grid(row=6, column=1, pady=3, sticky='w')
        self.terminate_koredump_vdu_check.grid(row=6, column=2, pady=3, padx=0, sticky='w')
        self.terminate_koredump_vcu_check.grid(row=6, column=2, pady=3, padx=50, sticky='w')
        self.terminate_sync_check.grid(row=7, column=1, pady=3, sticky='w')
        self.terminate_rannic_check.grid(row=8, column=1, pady=3, sticky='w')
        self.ocp_deintegration_check.grid(row=4, column=3, pady=3, sticky='w')
        self.terminate_button.grid(row=10, column=1, pady=3)

    def show_bts_init_suggestions(self, event):
        """
        Displays suggestions for BTS init files.
        """
        self.bts_init_suggestions.grid()

    def update_bts_init_suggestions(self, event):
        """
        Updates the suggestions for BTS init files based on user input.
        """
        typed_text = self.bts_init_entry.get()
        suggestions = self.get_bts_init_suggestions(typed_text)
        self.bts_init_suggestions.delete(0, tk.END)
        for suggestion in suggestions:
            self.bts_init_suggestions.insert(tk.END, suggestion)

    def get_bts_init_suggestions(self, typed_text):
        """
        Retrieves suggestions for BTS init files based on user input.

        Args:
            typed_text (str): The text typed by the user in the BTS initialization entry field.

        Returns:
            list: A list of matching BTS initialization file names.
        """
        base_path = '/home/ute/testline_configuration/'
        try:
            all_dirs = os.listdir(base_path)
            matching_dirs = [d for d in all_dirs if typed_text.lower() in d.lower()]
            return matching_dirs
        except FileNotFoundError:
            return []

    def select_bts_init(self, event):
        """
        Handles the selection of a BTS init file from the suggestions list.
        """
        try:
            selected_index = self.bts_init_suggestions.curselection()
            if selected_index:
                selected_bts_init = self.bts_init_suggestions.get(selected_index)
                self.bts_init_entry.delete(0, tk.END)
                self.bts_init_entry.insert(0, selected_bts_init)
                self.bts_init_suggestions.grid_remove()
        except tk.TclError:
            pass

    def check_available_sw(self):
        """
        Checks and displays available software and CCR information for the selected Mantaray lab.
        """
        nms_lab = self.nms_lab_entry.get()
        if not nms_lab:
            messagebox.showerror("Error", "NMS Lab must be filled out")
            return
        try:
            lab_info = LabInfo(lab_number=nms_lab)
            deployment_manager = DeploymentManager(lab_info)
            available_sw, available_ccrs_list, available_space = deployment_manager.check_available_sw()
            self.update_dropdowns(available_sw)
            self.available_ccrs['values'] = available_ccrs_list
            messagebox.showinfo("Success", "Available SW retrieved.\n\n"
                                           f"Free space on lab:\n{' ' * 10}{available_space}")
            if available_ccrs_list:
                self.available_ccrs.set(available_ccrs_list[0])
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def update_dropdowns(self, avail_sw):
        """
        Updates the dropdown menus with available software versions.

        Args:
            avail_sw (list): A list of available software versions.
        """
        vdu_sw = [sw for sw in avail_sw if sw.startswith("vDUCNF")]
        vcu_sw = [sw for sw in avail_sw if sw.startswith("vCUCNF")]
        koredump_sw = [sw for sw in avail_sw if sw.startswith("koredump-operator")]
        nokia_sync_sw = [sw for sw in avail_sw if sw.startswith("nokia-sync-operator")]
        rannic_sw = [sw for sw in avail_sw if sw.startswith("ran-nic-sw-controller")]

        self.vdu_sw_version_entry['values'] = vdu_sw
        self.vcu_sw_version_entry['values'] = vcu_sw
        self.koredump_sw_version_entry['values'] = koredump_sw
        self.nokia_sync_version_entry['values'] = nokia_sync_sw
        self.rannic_sw_version_entry['values'] = rannic_sw

    def deployment(self):
        """
        Initiates the deployment process based on user input.
        """
        bts_init = self.bts_init_entry.get()
        nms_lab = self.nms_lab_entry.get()
        ccr = self.available_ccrs.get()
        vdu_sw_version = self.vdu_sw_version_entry.get()
        vcu_sw_version = self.vcu_sw_version_entry.get()
        koredump_version = self.koredump_sw_version_entry.get()
        nokia_sync_version = self.nokia_sync_version_entry.get()
        rannic_sw_version = self.rannic_sw_version_entry.get()
        koredump_vdu_selected = self.koredump_vdu_check.instate(['selected'])
        koredump_vcu_selected = self.koredump_vcu_check.instate(['selected'])

        if vdu_sw_version and not vdu_sw_version.endswith("-amd64"):
            vdu_sw_version += "-amd64"
        if vcu_sw_version and not vcu_sw_version.endswith("-amd64"):
            vcu_sw_version += "-amd64"
        if koredump_version and not koredump_version.endswith("-amd64"):
            koredump_version += "-amd64"
        if nokia_sync_version and not nokia_sync_version.endswith("-amd64"):
            nokia_sync_version += "-amd64"
        if rannic_sw_version and not rannic_sw_version.endswith("-amd64"):
            rannic_sw_version += "-amd64"

        if not bts_init or not nms_lab:
            messagebox.showerror("Error", "Cloud BTS and NMS Lab must be filled out")
            return
        try:
            lab_info = LabInfo(lab_number=nms_lab)
            deployment_manager = DeploymentManager(lab_info)
            deployment_manager.deployment_script(bts_init, nms_lab, ccr, vdu_sw_version, vcu_sw_version,
                                                 nokia_sync_version, rannic_sw_version, koredump_version,
                                                 koredump_vdu_selected, koredump_vcu_selected)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def upgrade(self):
        """
        Initiates the upgrade process based on user input.
        """
        bts_init = self.bts_init_entry.get()
        nms_lab = self.nms_lab_entry.get()
        vdu_sw_version = self.vdu_sw_version_entry.get()
        vcu_sw_version = self.vcu_sw_version_entry.get()
        koredump_version = self.koredump_sw_version_entry.get()
        nokia_sync_version = self.nokia_sync_version_entry.get()
        rannic_sw_version = self.rannic_sw_version_entry.get()
        koredump_vdu_selected = self.koredump_vdu_check.instate(['selected'])
        koredump_vcu_selected = self.koredump_vcu_check.instate(['selected'])

        if vdu_sw_version and not vdu_sw_version.endswith("-amd64"):
            vdu_sw_version += "-amd64"
        if vcu_sw_version and not vcu_sw_version.endswith("-amd64"):
            vcu_sw_version += "-amd64"
        if koredump_version and not koredump_version.endswith("-amd64"):
            koredump_version += "-amd64"
        if nokia_sync_version and not nokia_sync_version.endswith("-amd64"):
            nokia_sync_version += "-amd64"
        if rannic_sw_version and not rannic_sw_version.endswith("-amd64"):
            rannic_sw_version += "-amd64"

        if not bts_init or not nms_lab:
            messagebox.showerror("Error", "Cloud BTS and NMS Lab must be filled out")
            return
        try:
            lab_info = LabInfo(lab_number=nms_lab)
            upgrade_manager = DeploymentManager(lab_info)
            upgrade_manager.upgrade_script(bts_init, nms_lab, vdu_sw_version, vcu_sw_version,
                                           nokia_sync_version, rannic_sw_version, koredump_version,
                                           koredump_vdu_selected, koredump_vcu_selected)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def termination(self):
        """
        Initiates the termination process based on user input.
        """
        bts_init = self.bts_init_entry.get()
        nms_lab = self.nms_lab_entry.get()
        terminate_vcu = self.terminate_vcu_check.instate(['selected'])
        terminate_vdu = self.terminate_vdu_check.instate(['selected'])
        terminate_koredump = self.terminate_koredump_check.instate(['selected'])
        vdu_koredump_selected = self.terminate_koredump_vdu_check.instate(['selected'])
        vcu_koredump_selected = self.terminate_koredump_vcu_check.instate(['selected'])
        terminate_rannic = self.terminate_rannic_check.instate(['selected'])
        terminate_sync = self.terminate_sync_check.instate(['selected'])
        deintegrate_vcu = self.deintegrate_vcu_check.instate(['selected'])
        deintegrate_vdu = self.deintegrate_vdu_check.instate(['selected'])

        if not bts_init or not nms_lab:
            messagebox.showerror("Error", "Cloud BTS and NMS Lab must be filled out")
            return
        try:
            lab_info = LabInfo(lab_number=nms_lab)
            deployment_manager = DeploymentManager(lab_info)
            deployment_manager.termination_script(bts_init, nms_lab, terminate_vcu, terminate_vdu, terminate_rannic,
                                                  terminate_sync, terminate_koredump, vdu_koredump_selected,
                                                  vcu_koredump_selected, deintegrate_vcu, deintegrate_vdu)
        except Exception as e:
            messagebox.showerror("Error", str(e))


if __name__ == "__main__":
    main_window = tk.Tk()
    gui = GUI(main_window)
    main_window.mainloop()
