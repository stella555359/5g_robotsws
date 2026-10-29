import PySimpleGUI as sg
import robot
import json
import subprocess
import sys
import Scripts
import jsoneditor
from robot.api import logger
# from robot.api import listeners

settings = None
sg.set_options(font=('Helvetica', 14))


def import_ini(pathToFile):
    sys.path.insert(1, pathToFile)
    import __init__ as tlconf
    return tlconf.tl


def program_setup():
    global tl
    global settings
    robot.run("Scripts.robot",
              variablefile=settings["ini_folder"] + "/",
              test='Get TTI trace Decoder',
              outputdir=settings["out_folder"] + "/")
    try:
        tl = import_ini(settings["ini_folder"] + "/")
    except ModuleNotFoundError:
        sg.popup("__init__.py not found. Please verify folder")
        open_settings_window()


def load_settings():
    global settings
    try:
        with open("config.json", "r") as config_file:
            settings = json.load(config_file)
        print("Current Settings:")
        for key, value in settings.items():
            print(key, ":", value)
    except FileNotFoundError:
        sg.popup("Please define settings before first use")
        settings = {
            "ini_folder": "",
            "out_folder": "",
            "syslog_folder": "/tmp/btslog2",
            "syslog_filename": "Syslog.log",
            "tti_duration": "2",
            "tti_folder": "/tmp",
            "tti_filename": "TTI",
            # "s1x2_folder": "/tmp",
            "s1x2_filename": "s1x2_trace_%D_%H.pcap",
            # "bip_folder": "/tmp",
            "bip_filename": "bip_trace_%D_%H.pcap"
        }
        open_settings_window()
    return settings


def update_settings(new_settings):
    global settings
    with open("config.json", "w") as config_file:
        json.dump(new_settings, config_file, indent=4)
    settings = load_settings()


def open_settings_window():
    global settings
    layout_general_settings = [
        [
            sg.Text("TL Configuration files location"),
            sg.In(size=(25, 1), enable_events=True, default_text=settings["ini_folder"], key="-FOLDER_INI-"),
            sg.FolderBrowse()],
        [
            sg.Text("Output Files Folder            "),
            sg.In(size=(25, 1), enable_events=True, default_text=settings["out_folder"], key="-FOLDER_OUT-"),
            sg.FolderBrowse()],
        [
            sg.Text("Syslog Output Folder           "),
            sg.In(size=(25, 1), enable_events=True, default_text=settings["syslog_folder"], key="-FOLDER_SysLog-"),
            sg.FolderBrowse()],
        [
            sg.Text("Syslog File Name               "),
            sg.In(size=(25, 1), enable_events=True, default_text=settings["syslog_filename"], key="-NAME_SysLog-"),
            sg.FolderBrowse()],
        # [
        #     sg.Text("S1X2 Output Folder             "),
        #     sg.In(size=(25, 1), enable_events=True, default_text=settings["s1x2_folder"], key="-FOLDER_s1x2-"),
        #     sg.FolderBrowse()],
        [
            sg.Text("S1X2 File Name                 "),
            sg.In(size=(25, 1), enable_events=True, default_text=settings["s1x2_filename"], key="-NAME_s1x2-"),
            sg.FolderBrowse()],
        # [
        #     sg.Text("L1L2 Output Folder             "),
        #     sg.In(size=(25, 1), enable_events=True, default_text=settings["bip_folder"], key="-FOLDER_bip-"),
        #     sg.FolderBrowse()],
        [
            sg.Text("L1L2 File Name                 "),
            sg.In(size=(25, 1), enable_events=True, default_text=settings["bip_filename"], key="-NAME_bip-"),
            sg.FolderBrowse()]

    ]
    layout_TTI_settings = [
        [
            sg.Text("TTI capturing duration (s)"),
            sg.In(size=(25, 1), enable_events=True, default_text='2', key="-TTI_duration-")],
        [
            sg.Text("TTI Output Folder            "),
            sg.In(size=(25, 1), enable_events=True, default_text='/tmp', key="-FOLDER_TTI-"),
            sg.FolderBrowse()],
        [
            sg.Text("TTI Trace File Name               "),
            sg.In(size=(25, 1), enable_events=True, default_text='TTI_trace', key="-NAME_TTI-"),
            sg.FolderBrowse()]
        ]
    setting_tg = [[sg.TabGroup([
        [sg.Tab("General", layout_general_settings),
         sg.Tab("TTI", layout_TTI_settings)]]),
        ],
        [sg.Submit(), sg.Cancel()]]
    window_settings = sg.Window("Settings", setting_tg, modal=True)
    choice_settings = None
    while True:
        event_settings, values_settings = window_settings.read()
        if event_settings == "Cancel" or event_settings == sg.WIN_CLOSED:
            break
        elif event_settings == "Submit":
            new_settings = {
                "ini_folder": values_settings["-FOLDER_INI-"],
                "out_folder": values_settings["-FOLDER_OUT-"],
                "syslog_folder": values_settings["-FOLDER_SysLog-"],
                "syslog_filename": values_settings["-NAME_SysLog-"],
                # "s1x2_folder": values_settings["-FOLDER_s1x2-"],
                "s1x2_filename": values_settings["-NAME_s1x2-"],
                # "bip_folder": values_settings["-FOLDER_bip-"],
                "bip_filename": values_settings["-NAME_bip-"],
                "tti_duration": values_settings["-TTI_duration-"],
                "tti_folder": values_settings["-FOLDER_TTI-"],
                "tti_filename": values_settings["-NAME_TTI-"]
            }
            update_settings(new_settings)
            break
    window_settings.close()


def edit_init():
    global settings
    try:
        # Open the file in Vim
        subprocess.run(["vim", settings["ini_folder"]+"/"+"__init__.py"])
    except FileNotFoundError:
        print("Vim is not installed on your system, or the 'vim' command is not in your PATH.")
    except Exception as e:
        print(f"An error occurred: {e}")


def check_setup(setup_flags):
    global settings

    var1 = "syslog:" + settings["syslog_filename"]
    var2 = "syslog_folder:" + settings["syslog_folder"]
    var3 = "out_folder:" + settings["out_folder"]
    var4 = "Setup_flags_json:" + json.dumps(setup_flags)
    cellsOnAir = Scripts.check_cells_on_air(tl)
    print('Cells On Air :', cellsOnAir)
    # json_result = settings["syslog_folder"] + "/check_cell_setup.json"
    # with open(json_result, "r") as content:
    #     setup_params = json.load(content)
    # jsoneditor.editjson(setup_params)
    if cellsOnAir:
        ch = sg.popup_yes_no("Cells are On Air. They must be restarted.\nDo you want to launch a Reset?", title="YesNo")
        if ch == "Yes":
            Scripts.reset_site(tl)
        else:
            return
    robot.run("Scripts.robot",
              variablefile=settings["ini_folder"] + "/",
              variable=[var1, var2, var3, var4],
              loglevel="TRACE",
              test='Check BBPool Assignment',
              outputdir=settings["out_folder"] + "/")
    json_result = settings["syslog_folder"] + "/check_cell_setup.json"
    with open(json_result, "r") as content:
        setup_params = json.load(content)
        jsoneditor.editjson(setup_params)

    # layout = [
    #     [sg.Text("Cell Setup", size=(20, 1))],
    #     [sg.Multiline(json.dumps(setup_params, indent=4), size=(60, 20), reroute_cprint=True,
    #                   key="-OUTPUT-", autoscroll=True)],
    #     [sg.Button("Exit")]
    # ]
    #
    # # Create the window
    # window = sg.Window("Cell Setup Parameters Check", layout)
    # sg.cprint(setup_params)

    # Event loop
    # while True:
    #     event, values = window.read()
    #     sg.cprint(event, values)
    #     if event in (sg.WINDOW_CLOSED, "Exit"):
    #         break
    #
    # # Close the window
    # window.close()


def main():
    global settings
    button_size = (8, 3)
    settings = load_settings()
    program_setup()
    menu_bar = sg.Menu([['File', ['Settings', 'Exit']],
                        ['About', ['Source Code', 'Edit __init__.py']]])
    button_reset = sg.Button('Reset gNB', size=button_size, tooltip='Launch a gNB reboot', key="-RESET-")
    button_snapshot = sg.Button('Get Snapshot', size=button_size, tooltip='Collects gNB Snapshot', key="-SNAP-")
    button_scf = sg.Button('Get SCF', size=button_size, tooltip='Collects gNB SCF', key="-SCF-")
    button_checkCellSetup = sg.Button('Check Cell Setup', tooltip='Features Activation is checked at Cell Setup. '
                                      'gNB Reset must be launched before using this button',
                                      size=button_size, key="-SETUP-")
    button_startTTItrace = sg.Button('Launch And Process TTI Trace', tooltip='Launch and analyzes TTI trace with the '
                                     'duration stablished in the Settings', size=button_size, key="-TTI_launch-")
    button_startSysLogtrace = sg.Button('Start Syslog', tooltip='Launch Syslog trace', size=button_size,
                                        key="-SysLog_launch-")
    button_startS1X2trace = sg.Button('Start S1X2', tooltip='Launch S1X2 trace', size=button_size,
                                      key="-S1X2_launch-")
    button_startBiptrace = sg.Button('Start L1L2 Bip', tooltip='Launch L1L2 trace', size=button_size,
                                     key="-L1L2_launch-")
    button_checkPRB = sg.Button('Check PRB Assignment', tooltip='Launch a TTI trace of 2s and checks '
                                'the PRB assignment is correct', size=button_size, key="-Check_PRB-")
    checkbox_TTI = [[sg.Checkbox("Launch TTI                          ", key="-cb_TTI_Launch-", default=True)],
                    [sg.Checkbox("Convert to csv", key="-cb_TTI_convert-", default=True)],
                    # [sg.Checkbox("Check DL PRB Assignment                    ", key="-cb_PRB_dl-")],
                    # [sg.Checkbox("Check UL PRB Assignment                    ", key="-cb_PRB_ul-")],
                    [sg.Checkbox("DL Charts                                      ", key="-cb_DL-")],
                    [sg.Checkbox("UL Charts                                      ", key="-cb_UL-")]]
    checkbox_Setup = [[sg.Checkbox("Cells per l1Subpool", key="-cb_l1SpCells-", default=True)],
                      [sg.Checkbox("bbPoolInfos (AddressDistributionReq)", key="-cb_bbPoolInfos-", default=True)],
                      [sg.Checkbox("numMinPrbAlloc per Cell", key="-cb_numMinPrbAlloc-", default=True)],
                      [sg.Checkbox("cellcsirs", key="-cb_cellcsirs-")],
                      [sg.Checkbox("trscsirs", key="-cb_trscsirs-")],
                      [sg.Checkbox("uecsirs", key="-cb_uecsirs-")]]
    mainLayout = [
        [
            [menu_bar],
            [sg.Frame('gNB', layout=[[button_reset, button_snapshot, button_scf]])],
            [sg.Frame('Traces', layout=[[button_startSysLogtrace, button_startBiptrace, button_startS1X2trace]])],
            [sg.Frame('Check Cell Setup', layout=[[sg.Column(checkbox_Setup), button_checkCellSetup]])],
            [sg.Frame('TTI', layout=[[sg.Column(checkbox_TTI), button_startTTItrace]])]
        ]
    ]

    window_main = sg.Window(title="SyVe Testing Tools", layout=mainLayout)
    while True:
        event, values = window_main.read()
        # End program if user closes window or
        # presses the OK button
        print(event, values)
        if event in (None, 'Exit'):
            break
        elif event == '-RESET-':
            Scripts.reset_site(tl)
        elif event == '-SNAP-':
            var1 = "snap_folder:" + settings["out_folder"]
            robot.run("Scripts.robot",
                      variablefile=settings["ini_folder"]+"/",
                      variable=[var1],
                      test='Collect Snapshot',
                      outputdir=settings["out_folder"]+"/")
        elif event == '-SCF-':
            var1 = "scf_folder:" + settings["out_folder"]
            robot.run("Scripts.robot",
                      variablefile=settings["ini_folder"] + "/",
                      variable=[var1],
                      test='Collect SCF',
                      outputdir=settings["out_folder"] + "/")
        elif event == '-SysLog_launch-':
            var1 = "syslog:" + settings["syslog_filename"]
            var2 = "syslog_folder:" + settings["syslog_folder"]
            var3 = "out_folder:" + settings["out_folder"]
            robotresult = robot.run("Scripts.robot",
                                    variablefile=settings["ini_folder"] + "/",
                                    variable=[var1, var2],
                                    test='Start Syslog',
                                    outputdir=settings["out_folder"] + "/")
            if robotresult == 0:
                ch = sg.popup_ok("BTSLog is running, press to stop", title="Stop")
                robotresult = robot.run("Scripts.robot",
                                        variablefile=settings["ini_folder"] + "/",
                                        variable=[var1, var2, var3],
                                        test='Stop Syslog',
                                        outputdir=settings["out_folder"] + "/")
                if robotresult == 0:
                    sg.popup_ok("Trace " + settings["out_folder"] + "/" + settings["syslog_filename"] +
                                " created successfully", title="Stop")
            else:
                ch = sg.popup_ok("BTSLog failed to start. Please check the configuration of BTSLog on your VM")

        elif event == '-S1X2_launch-':
            var1 = "s1x2:" + settings["s1x2_filename"]
            var2 = "/tmp"
            var3 = "out_folder:" + settings["out_folder"]
            robotresult = robot.run("Scripts.robot",
                                    variablefile=settings["ini_folder"] + "/",
                                    variable=[var1, var2],
                                    test='Start S1X2',
                                    loglevel="TRACE",
                                    outputdir=settings["out_folder"] + "/")
            if robotresult == 0:
                ch = sg.popup_ok("S1X2 is running, press to stop", title="Stop")
                robotresult = robot.run("Scripts.robot",
                                        variablefile=settings["ini_folder"] + "/",
                                        variable=[var1, var2, var3],
                                        test='Stop s1X2',
                                        loglevel="TRACE",
                                        outputdir=settings["out_folder"] + "/")
                if robotresult == 0:
                    sg.popup_ok("Trace " + settings["out_folder"] + "/" + settings["s1x2_filename"] +
                                " created successfully", title="Stop")
            else:
                ch = sg.popup_ok("s1x2 failed to start")
        elif event == '-L1L2_launch-':
            Scripts.start_bip_trace(tl, settings["out_folder"] + "/" + settings["bip_filename"])

        elif event == '-TTI_launch-':
            tti_flags = {"launch": values["-cb_TTI_Launch-"], "convert": values["-cb_TTI_convert-"],
                         # "prb_dl": values["-cb_PRB_dl-"], "prb_ul": values["-cb_PRB_ul-"],
                         "DL": values["-cb_DL-"], "UL": values["-cb_UL-"]}
            var1 = "tti_folder:" + settings["tti_folder"]
            var2 = "tti_filename:" + settings["tti_filename"]
            var3 = "tti_duration:" + settings["tti_duration"]
            var4 = "tti_flags_json:" + json.dumps(tti_flags)
            var5 = "syslog_folder:" + settings["syslog_folder"]
            var6 = "out_folder:" + settings["out_folder"]
            if values["-cb_TTI_Launch-"]:
                print('Starting trace {}/{} for a duration of {}s'.format(
                    settings["tti_folder"], settings["tti_filename"], settings["tti_duration"]))
            robot.run("Scripts.robot",
                      variablefile=settings["ini_folder"] + "/",
                      variable=[var1, var2, var3, var4, var5, var6],
                      loglevel="TRACE",
                      test='Launch and convert TTI',
                      outputdir=settings["out_folder"] + "/")
        elif event == '-SETUP-':
            setup_flags = {"l1SpCells": values["-cb_l1SpCells-"], "bbPoolInfos": values["-cb_bbPoolInfos-"],
                           "numMinPrbAlloc": values["-cb_numMinPrbAlloc-"], "cellcsirs": values["-cb_cellcsirs-"],
                           "trscsirs": values["-cb_trscsirs-"], "uecsirs": values["-cb_uecsirs-"]}
            check_setup(setup_flags)
        elif event == 'Settings':
            open_settings_window()
            settings = load_settings()
        elif event == 'Edit __init__.py':
            edit_init()
    window_main.close()


if __name__ == "__main__":
    main()
