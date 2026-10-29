#!/usr/bin/python
# !/opt/ute/python/bin

import os
import subprocess
import string
from Tkinter import *

window = Tk()
oru_branch = StringVar()
oru_load = StringVar()
gnb_load = StringVar()
# gnb_branch = StringVar()
wts_load = StringVar()
command = StringVar()
test_type = StringVar()
# path = string
max_cont = "1"
cont = StringVar()
chk_commissioning = BooleanVar(False)
chk_downloading = BooleanVar(False)
chk_wts = BooleanVar(False)
chk_last_build = BooleanVar(False)
chk_last_wts = BooleanVar(False)


def open_window():
    global path
    os.system(
        "terminator -e 'bash -c \"cd " + path +
        "\necho \033[31mPASTE THE COPIED LINES BELOW AND PRESS RETURN\033[m; exec bash\"'")


def run_test():
    generate_cmd.grid_remove()
    command_label.grid(column=1, row=10)
    command_value.grid(column=2, row=10)
    command_value.insert(INSERT, command.get())


#    open_term.grid(column=2, row=30)


def run_page2():
    global path

    if int(cont.get()) > int(max_cont):
        cont.set(max_cont)

    text = "TEST_TYPE = " + test_type.get()
    print(text)
    text = "DOCKER_BRANCH = " + oru_branch_value.get()
    print(text)
    text = "DOCKER_TAG = " + oru_sw_value.get()
    print(text)
    text = "DOCKER_NB = " + cont.get()
    print(text)
    text = "GNB_DOWNLOADING_REQ = " + str(chk_downloading.get())
    print(text)
    text = "WTS_DOWNLOADING_REQ = " + str(chk_wts.get())
    print(text)
    text = "GNB_COMMISSIONING_REQ = " + str(chk_commissioning.get())
    print(text)
    text = "GNB_SW_TO_DOWNLOAD = " + gnb_load.get()
    print(text)
    text = "WTS_SW_TO_DOWNLOAD = " + wts_load.get()
    print(text)
    text = "cd " + path + "\nsource /home/ute/test_repo/bin/activate\n"
    text = text + "robot -L TRACE -d results -b debug.log -V config/Lannion/" + testLine + "/"
    text = text + " --variable TEST_TYPE:" + test_type.get()
    text = text + " --variable DOCKER_BRANCH:" + oru_branch.get()
    text = text + " --variable DOCKER_TAG:" + oru_load.get()
    text = text + " --variable DOCKER_NB:" + cont.get()
    text = text + " --variable GNB_COMMISSIONING_REQ:" + str(chk_commissioning.get())
    if chk_downloading.get():
        text = text + " --variable GNB_DOWNLOADING_REQ:" + str(chk_downloading.get())
        if not chk_last_build.get():
            text = text + " --variable GNB_SW_TO_DOWNLOAD:" + gnb_load.get()
    if chk_wts.get():
        text = text + " --variable WTS_DOWNLOADING_REQ:" + str(chk_wts.get())
        if not chk_last_wts.get():
            text = text + " --variable WTS_SW_TO_DOWNLOAD:" + wts_load.get()
    text = text + " " + path + "testsuite/Lannion/Airphone/ORUsim/test.robot"
    command.set(text)
    valid2.grid_remove()
    generate_cmd.grid(column=1, row=10)


def run_page1():
    wts_downloading.grid_remove()
    gnb_downloading.grid_remove()
    gnb_commissioning.grid_remove()
    valid1.grid_remove()
    row = 5
    if chk_downloading.get():
        gnb_sw_label.grid(column=1, row=row)
        gnb_sw_value.grid(column=2, row=row)
        gnb_branch_check.grid(column=1, row=row+1)
#        gnb_branch_value.grid(column=2, row=row+1)
        chk_commissioning.set(True)
        row = row+2
    if chk_wts.get():
        wts_sw_label.grid(column=1, row=row)
        wts_sw_value.grid(column=2, row=row)
        wts_check.grid(column=1, row=row+1)
        row = row+1
    valid2.grid(column=2, row=row+1)


result = os.popen("hostname\n")
s = result.readline()
result.close()
testLine = s.strip()
testLine = string.replace(testLine, '-', '_', 2)

tmp = subprocess.check_output(['sudo find /home -type d -name ORUsim|grep robotws/testsuite/Lannion/Airphone/ORUsim'],
                              shell=True)
tmp = tmp.strip()
tmp = tmp.split('testsuite/', 1)
path = str(tmp[0])
print(path)

window.title("orusim test on " + testLine)

test_type_label = Label(window, text="Enter the configuration type to be tested   ", justify=LEFT, font=12)
test_type_menu = OptionMenu(window, test_type, "rusim", "orusim")
test_type.set("orusim")
oru_branch_label = Label(window, text="Enter the docker repository to be tested  ", justify=LEFT, font=12)
oru_branch_value = Entry(window, bd=4, justify=CENTER, textvariable=oru_branch)
oru_branch.set("orusim")
oru_sw_label = Label(window, text="Enter the orusim image tag to be tested   ", justify=LEFT, font=12)
oru_sw_value = Entry(window, bd=4, justify=CENTER, textvariable=oru_load)
oru_load.set("v2.0.11")
oru_cont_nb_label = Label(window, text="Nb of containers to be tested ("+max_cont+" max)", justify=LEFT, font=12)
oru_cont_nb_value = Entry(window, bd=4, justify=CENTER, textvariable=cont)
cont.set("1")
gnb_downloading = Checkbutton(window, text='gNB downloading requested', font=12, var=chk_downloading)
gnb_commissioning = Checkbutton(window, text='gNB commissioning requested', font=12, var=chk_commissioning)
wts_downloading = Checkbutton(window, text='esimmode_WTS downloading requested', font=12, var=chk_wts)

# gnb_branch_value = Entry(window, bd=4, justify=CENTER, width=35, textvariable=gnb_branch)
# gnb_branch.set("SBTS00")
gnb_branch_check = Checkbutton(window, text='OR Apply latest gNB load from Trunk', font=12, var=chk_last_build)

gnb_sw_label = Label(window, text="Enter the gNB load to be downloaded       ", justify=LEFT, font=12)
gnb_sw_value = Entry(window, bd=4, justify=CENTER, width=35, textvariable=gnb_load)
gnb_load.set("SBTS00_ENB_9999_220420_000009")

wts_check = Checkbutton(window, text='OR Apply latest esimmmode_WTS', font=12, var=chk_last_wts)

wts_sw_label = Label(window, text="Enter the esimmode_WTS load to be downloaded ", justify=LEFT, font=12)
wts_sw_value = Entry(window, bd=4, justify=CENTER, width=35, textvariable=wts_load)
wts_load.set("4.0.20393")

command_label = Label(window, text="copy (ctrl c) the lines beside in a new terminal ", justify=LEFT, bg="#FF9900",
                      font=12)
command_value = Text(window, bd=4, width=50, height=12)

valid1 = Button(window, text="VALIDATE CHOICE")
valid1.configure(command=run_page1, bg="#39DEEF")
valid2 = Button(window, text="VALIDATE CHOICE")
valid2.configure(command=run_page2, bg="#39DEEF")
generate_cmd = Button(window, text="GENERATE COMMANDS")
generate_cmd.configure(command=run_test, bg="#39DEEF")
open_term = Button(window, text="OPEN NEW TERMINAL")
open_term.configure(command=open_window, bg="#39DEEF")

test_type_label.grid(column=1, row=1)
test_type_menu.grid(column=2, row=1)
oru_branch_label.grid(column=1, row=2)
oru_branch_value.grid(column=2, row=2)
oru_sw_label.grid(column=1, row=3)
oru_sw_value.grid(column=2, row=3)
oru_cont_nb_label.grid(column=1, row=4)
oru_cont_nb_value.grid(column=2, row=4)
wts_downloading.grid(column=1, row=5)
gnb_downloading.grid(column=1, row=6)
gnb_commissioning.grid(column=1, row=7)
valid1.grid(column=2, row=8)

window.mainloop()
