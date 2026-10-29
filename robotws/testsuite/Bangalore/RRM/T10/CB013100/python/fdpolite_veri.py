from taf.sbts.oam.coam.admin import admin
import os
import subprocess
import pkgutil
import importlib
import json
import time
import csv
all_events = {}
xxxx = ''


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def is_matplotlib_installed():
    print('mta_isn-->', bool(pkgutil.find_loader('matplotlib')))
    return bool(pkgutil.find_loader('matplotlib'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def install_and_import_matplotlib():
    print("matplot library installation")
    if not is_matplotlib_installed():
        install_package('matplotlib')
    return importlib.import_module('matplotlib')


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def verify_fdpolite(filename, tmo=1, tdd=1):
    install_and_import_pandas()
    import pandas as pd
    all_events = pd.read_csv(filename, low_memory=False)
    dlFdSchedData = all_events[all_events["type"] == "dlFdSchedData"]
    dlFdPolite = all_events[all_events["type"] == "dlFdPolite"]
    if len(dlFdPolite) == 0:
        print("There is no event for FD Polite")
        return "FAIL"
    if tdd == 1:
        tmo_condition = (
            (dlFdPolite['sfn'] %
             8 == 1) & (
                (dlFdPolite['slot'] == 0) | (
                    dlFdPolite['slot'] == 1) | (
                    dlFdPolite['slot'] == 16) | (
                    dlFdPolite['slot'] == 17)))
    else:
        tmo_condition = ((dlFdPolite['sfn'] % 8 == 4) & (
            (dlFdPolite['slot'] == 1) | (dlFdPolite['slot'] == 2)))
    fdpolite_on_trs_slot = dlFdPolite[tmo_condition]
    if len(fdpolite_on_trs_slot) != 0:
        print(
            "FD Polite is applied on TRS slot cross chk the config is slot"
            "0,1,,16,17 TRS slot ?? and if config is ok raise pr/precheck")
        return 'FAIL'

    fd_p_flt = dlFdSchedData.merge(
        dlFdPolite, on=[
            'sfn', 'slot', 'rnti'], how='inner')
    print(fd_p_flt)
    fd_p_flt['prb_diff'] = fd_p_flt["numOfPrbBeforePolite_y"] - \
        fd_p_flt["numOfPrb_x"]
    fd_p_flt['mcs_diff'] = fd_p_flt["mcsBeforePolite_y"] - \
        fd_p_flt["rrmDlUsedMcs_x"]
    fd_p_flt['tbs_diff'] = fd_p_flt["tbSizeBeforePolite_y"] - \
        fd_p_flt["tbSize_x"]

    if fd_p_flt['prb_diff'].lt(0).all():
        print("All values are above  0")
    else:
        print("PRB diff ")
        return 'FAIL'
    if fd_p_flt['mcs_diff'].gt(0).all():
        print("all MCSs are downgraded")
    else:
        print("ERROR at MCS")
        return 'FAIL'
    if fd_p_flt['tbs_diff'].lt(1).all():
        print("all TBs are incresed")
    else:
        print("Error in TB size")
        return 'FAIL'

    if (~fd_p_flt['muStatus_x'].str.contains(
            'MUPAIR', case=False, na=False)).all():
        return "PASS"
    else:
        print("Error in MUMIMO leg")
        return "FAIL"

    # print("===>",len(dlFdSchedData),len(dlFdPolite))

# x=verify_fdpolite("output_dl_formated.csv")


def get_total_cmp(pm_report, expected_value, cell_id=None):
    value = 0
    counter = 0
    sd_level = {}
    avg = 0
    req_moc = ""
    for record in pm_report:
        for time in record.keys():
            for counter in record[time].keys():
                for moc in record[time][counter].keys():
                    if cell_id is not None and moc.endswith(cell_id):
                        req_moc = moc
                        value += int(float(record[time][counter][moc]))
                        if moc in sd_level.keys():
                            avg = avg + 1
                            sd_level[moc] = sd_level[moc] + \
                                int(int(float(record[time][counter][moc])))
                        else:
                            sd_level[moc] = 0
    print(sd_level)
    print("at average of", avg)
    if expected_value == value:
        sd_level[req_moc] = int(sd_level[req_moc] / avg)
        return 'PASS' + "'#'" + str(sd_level)
    elif expected_value == -1:
        if value < 1:
            return 'Fail'"'#'" + str(sd_level)
        else:
            sd_level[req_moc] = int(sd_level[req_moc] / avg)
            return 'PASS' + "'#'" + str(sd_level)
    else:
        print(
            "counter-->",
            counter,
            "expected value-->",
            expected_value,
            "Actual Value",
            value)
        return 'FAIL' + "'#'" + str(sd_level)


def update_gscn(file, cellid, gscn):
    cell_str = "<phy_cell_id>" + str(cellid) + "<"
    fp = open(file, 'r')

    fp1 = open("n_iphy.xml", "w")
    for line in fp:
        if cell_str in line:
            fp1.write(line)
            strng = "              <GSCN>" + str(gscn) + "</GSCN>\n"
            fp1.write(strng)
            next(fp)
        else:
            fp1.write(line)

    fp.close()
    fp1.close()
    cmd = "mv  n_iphy.xml  " + file
    os.system(cmd)
    time.sleep(5)


def init_rnti_bwp(ues, rnti_bwp):
    for rnti in rnti_bwp:
        ues[rnti] = 0


def check_rntis(rntis):
    for rnti in rntis.keys():
        if rntis[rnti] != 1:
            return 1
    return 0


def validate_bwps(
        file_name,
        event,
        small_bwp_id,
        second_bwp_id,
        large_bwp_id,
        small_bwp_num_prb,
        second_bwp_num_prb,
        large_bwp_num_prb,
        large_bwp_ues=[],
        small_bwp_ues=[],
        second_bwp_ues=[],
        lower_blanked=0,
        upper_blanked=0):
    attrs = ['sfn', 'slot', 'rnti', 'numOfPrb', 'startPrb', 'cellBwpId']
    recs = read_tti_csv(file_name, event, *attrs)
    indx = -1
    large_rnti_bwp = {}
    second_rnti_bwp = {}
    small_rnti_bwp = {}
    init_rnti_bwp(large_bwp_ues, large_rnti_bwp)
    init_rnti_bwp(small_bwp_ues, small_rnti_bwp)
    init_rnti_bwp(second_bwp_ues, second_rnti_bwp)
    if lower_blanked != 0:
        small_bwp_num_prb = small_bwp_num_prb + lower_blanked
        second_bwp_num_prb = second_bwp_num_prb + lower_blanked
    for rnti in recs[2]:
        indx += 1
        unblnk_prb = large_bwp_num_prb - upper_blanked
        if int((float(recs[4][indx])) < lower_blanked) or (
                (int(float(recs[3][indx])) + int(float(recs[4][indx]))) > (unblnk_prb)):
            print("Error overlapping with balnked prb region")
            return 'Fail'

        if rnti in large_bwp_ues:
            if int(float((recs[5][indx]))) != large_bwp_id:
                print("Large BWP")
                return 'Fail'
            if (int(float(recs[3][indx])) +
                    int(float(recs[4][indx]))) > large_bwp_num_prb:
                print("Large BWP prb")
                return 'Fail'
            large_rnti_bwp[rnti] = 1

        elif rnti in small_bwp_ues:
            if int(float(recs[5][indx])) != small_bwp_id:
                print("small BWP")
                return 'Fail'
            if (int(float(recs[3][indx])) +
                    int(float(recs[4][indx]))) > small_bwp_num_prb:
                print("small BWP prb")
                return 'Fail'
            small_rnti_bwp[rnti] = 1
        elif rnti in second_bwp_ues:
            if int(float(recs[5][indx])) != second_bwp_id:
                print("second BWP ")
                return 'Fail'
            if (int(float(recs[3][indx])) +
                    int(float(recs[4][indx]))) > second_bwp_num_prb:
                print("second BWP prb", second_bwp_num_prb,
                      (int(float(recs[3][indx])) + int(float(recs[4][indx]))))
                return 'Fail'
            second_rnti_bwp[rnti] = 1
        else:
            print("Unknown RNTI ", rnti)
            return 'Fail'

    if len(large_bwp_ues):
        ret = check_rntis(large_rnti_bwp)
        if ret == 1:
            print("All UEs are not sch for large BWP")
            return 'Fail'
    if len(small_bwp_ues):
        ret = check_rntis(small_rnti_bwp)
        if ret == 1:
            print("All UEs are not sch for small BWP")
            return 'Fail'
    if len(second_bwp_ues):
        ret = check_rntis(second_rnti_bwp)
        if ret == 1:
            print("All UEs are not sch for second BWP")
            return 'Fail'
    print("All validation is successful")
    return 'pass'


def get_sfn_sequence(filename, event):
    sfn_list = []
    with open(filename) as fp:
        f_csv = csv.DictReader(fp)
        for k in f_csv:
            if k['type'] == event:
                sfn_list.append(int(float(k['sfn'])))
    return sfn_list


def populate_allevents(filename, all_events):
    def_val = []
    for i in range(1024):
        def_val.append(None)
    with open(filename) as fp:
        f_csv = csv.DictReader(fp)
        for k in f_csv:
            # need deep copy so that same list will not be refered
            all_events[k['type']] = def_val[:]
            # print(len(all_events[k['type']]))


def read_tti_csv(file_name, inp_event, *attr):
    global all_events
    populate_allevents(file_name, all_events)

    with open(file_name) as fp:
        frame_tracker = frame_track()
        f_csv = csv.DictReader(fp)

        for event in f_csv:
            node = event_info(event)
            # print(event)
            if all_events[event['type']][int(float(event['sfn']))] is None:
                master_node = master(node)
                all_events[event['type']][int(
                    float(event['sfn']))] = master_node
            else:
                master_node = master(node)
                ev_obj = all_events[event['type']][int(float(event['sfn']))]
                # if node.event['type'] == 'dlFdSchedData':
                #    print("Here",event['sfn'],event['rnti'])
                if ev_obj.node_creat_req == 0:
                    if ev_obj.next_node is None:
                        ev_obj.node.update_node(node)
                    else:
                        ev_tmp = ev_obj.next_node
                        while ev_tmp.next_node:
                            ev_tmp = ev_tmp.next_node
                        ev_tmp.node.update_node(node)
                else:

                    ev_obj.is_up_require(master_node)
                    ev_obj.node_creat_req = 0

            frame_tracker.update_sfn_nxt_node(node, all_events)
    sfn_seq = get_sfn_sequence(file_name, inp_event)
    sfn_rep = {}
    for sfn in sfn_seq:
        sfn_rep[sfn] = sfn_seq.count(sfn)
    return fetch_records(inp_event, *attr)


def fetch_records(event, *attr):
    global all_events
    records = []
    for i in range(len(attr)):
        records.append([])

    for eve in all_events[event]:
        if eve is not None:
            rec = eve.fetch_records(*attr)
            for i in range(len(attr)):
                records[i] = records[i] + rec[i]
    return records


class frame_track:
    def __init__(self):
        self.pre_sfn = None
        self.current_sfn = None

    def update_sfn_nxt_node(self, node, all_events):
        if self.pre_sfn is None:
            self.pre_sfn = int(float(node.event['sfn']))
            self.current_sfn = int(float(node.event['sfn']))
        else:
            self.current_sfn = int(float(node.event['sfn']))
            if self.pre_sfn != self.current_sfn:
                for event in all_events.keys():
                    update_node = all_events[event][self.pre_sfn]
                    if update_node is not None:
                        update_node.node_creat_req = 1

                self.pre_sfn = self.current_sfn


class event_info:
    def __init__(self, event):
        self.event = event
        self.head_node = None
        self.tail_node = None

    def update_node(self, node):
        if self.tail_node is None:
            self.tail_node = node
            self.head_node = self
            # if node.event['type'] == 'dlFdSchedData':
            # print("Adding",node.event['sfn'],node.event['rnti'])
            # self.disp()

        else:
            tmp = self.tail_node
            while tmp.tail_node:
                tmp = tmp.tail_node
            tmp.tail_node = node

            # if node.event['type'] == 'dlFdSchedData':
            #     print("2nd Adding",node.event['sfn'],node.event['rnti'])
            #     self.disp()

    def disp(self):
        print("Currently nodes")
        tmp = self
        while tmp:
            print("from disp", tmp.event['rnti'])
            tmp = tmp.tail_node


class master:

    def __init__(self, node):
        self.frame_period = 0  # on which 0-1023
        self.node = node
        self.event_name = node.event['type']
        self.node_creat_req = 0  # to mark the frame
        self.next_node = None  # points to next master node

    def is_up_require(self, master_node):

        if self.node_creat_req:
            # self.node_creat_req = 0
            if self.next_node is None:
                self.next_node = master_node
                return master_node
            else:
                tmp_master = self.next_node
                while tmp_master.next_node:
                    tmp_master = tmp_master.next_node

                tmp_master.next_node = master_node
                return master_node
        else:
            if self.next_node is None:
                return self
            else:
                tmp_master = self.next_node
                while tmp_master.next_node:
                    tmp_master = tmp_master.next_node
                return tmp_master

    def fetch_records(self, *event_attrs):
        records = []
        indx = 0
        for i in range(len(event_attrs)):
            records.append([])

        if len(event_attrs):
            for attribute in event_attrs:
                tmp = self.node
                while tmp:
                    records[indx].append(tmp.event[attribute])
                    tmp = tmp.tail_node
                tmp = self.next_node
                while tmp:
                    # if tmp.next_node:
                    tmp_node = tmp.node
                    while tmp_node:
                        records[indx].append(tmp_node.event[attribute])
                        tmp_node = tmp_node.tail_node
                    tmp = tmp.next_node
                indx = indx + 1
        else:
            print("Error No record input to fetch")

        return records
