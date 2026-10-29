import csv
import sys


def get_phase_and_att_from_csv(*args):
    att_list = []
    phase_list = []
    for arg in args:
        with open(arg, newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            i = 0
            for row in reader:
                row.pop(0)
                if i != 0 and "Phase" not in row:
                    att_list.append([item.split('|', 1)[0] for item in row if item != ''])
                    phase_list.append([item.split('|', 1)[1] for item in row if item != ''])
                i += 1
    return att_list, phase_list


def get_att_output_channel(*args):
    att_list, phase_list = get_phase_and_att_from_csv(*args)
    for i in range(len(att_list)):
        for j in range(len(att_list[i])):
            att_list[i][j] = float(att_list[i][j])
    return att_list


def get_phase_output_channel(*args):
    att_list, phase_list = get_phase_and_att_from_csv(*args)
    for i in range(len(phase_list)):
        for j in range(len(phase_list[i])):
            phase_list[i][j] = float(phase_list[i][j])
    return phase_list
