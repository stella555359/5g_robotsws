# from collections import namedtuple
import subprocess
import pkgutil
import importlib
import csv
import os
import time
all_events = {}
xxxx = ''


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def is_tkinter_installed():
    return bool(pkgutil.find_loader('tkinter'))


def install_and_import_tkinter():
    print("tkinter library installation")
    if not is_tkinter_installed():
        install_package('tkinter')
    return importlib.import_module('tkinter')


def merge_multiple_csv(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_' + dire + '_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_' + dire + '_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(
                pd.read_csv(
                    os.path.join(
                        filepath,
                        file),
                    low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)


def get_total_cmp(pm_report, expected_value):
    value = 0
    counter = 0
    for record in pm_report:
        for time in record.keys():
            for counter in record[time].keys():
                for moc in record[time][counter].keys():
                    value += int(record[time][counter][moc])
    if expected_value == value:
        return 'PASS'
    elif expected_value == -1:
        if value < 1:
            return 'Fail'
        else:
            return 'PASS'
    else:
        print(
            "counter-->",
            counter,
            "expected value-->",
            expected_value,
            "Actual Value",
            value)
        return 'FAIL'


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


def fetch_records_based_on_start_frame(event, sfn_seq, sfn_rep, *attr):
    global all_events
    records = []
    for i in range(len(attr)):
        records.append([])

    for sfn in sfn_seq:

        eve = all_events[event][sfn]
        if eve is not None:
            rec = eve.fetch_records(*attr)
            for i in range(len(attr)):
                records[i] = records[i] + rec[i]
    return records


def count_records():
    record_cnt = 0
    for event in all_events:
        event_list = all_events[event]
        for node in event_list:
            tmp_node = node
            while tmp_node:
                if tmp_node is not None:
                    record_cnt = record_cnt + 1
                    # print(tmp_node.node.event['sfn'],'-->',node.node.event['rnti'])
                    tmp = tmp_node.node.tail_node
                    while tmp:
                        # print("chain",tmp_node.node.event['sfn'],'--',tmp_node.node.event['rnti'])
                        record_cnt = record_cnt + 1
                        tmp = tmp.tail_node
                tmp_node = tmp_node.next_node

    print(record_cnt)


def verify_sliv(file_name, event, *attr):
    rec = read_tti_csv(file_name, event, *attr)
    count_records()
    # rec=read_tti_csv("output_ul_formated.csv",'ulFdSchedData','SLIV')
    for i in rec[0]:

        if int(float(i)) != 27 and int(float(i)) != 41:
            return 'Failure'
    print("All SLIVs are either 27 or 41")
    return 'Pass'


def check_random(rat0bit):
    bitmap = []
    rat0bit = int(float(rat0bit))
    for i in range(64):
        bitmap.append(rat0bit >> i & 1)
    bit_1_count = bitmap.count(1)
    is_conti = 1
    first_1_bit = bitmap.index(1)
    count_1 = 0
    prev_indx_1 = 0
    if bit_1_count > 1:
        for i in range(first_1_bit, 64):
            if count_1 == bit_1_count:
                break
            if i == first_1_bit:
                prev_indx_1 = i
                nxt_indx_1 = i

            if bitmap[i] == 1:
                count_1 += 1
                nxt_indx_1 = i
                if nxt_indx_1 - prev_indx_1 > 1:
                    is_conti = 0
                    break
                prev_indx_1 = nxt_indx_1
    print("is_contigiuous", is_conti)


def verify_randomprb(file_name, event, *attr):
    global xxxx
    rec = read_tti_csv(file_name, event, *attr)
    count_records()
    xxxx = rec


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


def check_rgbs_set(rat0bitmap, chbw_prb):
    print("Finding rbgs for", rat0bitmap, '==>', chbw_prb)
    rbg_size = 0
    if chbw_prb >= 145:
        rbg_size = 16
    elif chbw_prb >= 73:
        rbg_size = 8
    elif chbw_prb >= 37:
        rbg_size = 4
    else:
        rbg_size = 2
    num_rbgs = int(chbw_prb / rbg_size)
    if chbw_prb % rbg_size != 0:
        num_rbgs += 1
    rbg_ids = []
    cnt = 0
    bit = pow(2, (num_rbgs - 1))
    for i in range(0, num_rbgs):
        if bit & rat0bitmap:
            rbg_ids.append(cnt)
        cnt += 1
        rat0bitmap <<= 1
    print("Allocated rbgs from rgb bitmap", rbg_ids)
    return rbg_ids


def genrate_random(
        sfn,
        slot,
        pci,
        num_rbgs,
        is_partial=1,
        prime=997,
        tslsperframe=20):
    island_order = []
    last_whole_rbg = num_rbgs
    if is_partial == 1:
        last_whole_rbg = num_rbgs - 1
    for i in range(0, last_whole_rbg):
        xsfn = (sfn * tslsperframe) + slot
        island_order.append(
            (((xsfn + pci + 1 + i) * prime) %
             last_whole_rbg) + 1)
    if is_partial == 1:
        island_order.append(num_rbgs)
    print(island_order)
    return island_order


def get_len(alloc):
    cnt = 0
    for i in alloc:
        cnt += len(i)
    return cnt


def chk_remove_alloc(
        rgb_idx,
        tmp_small_bwp_rgb_rand_seq,
        small_bwp_rgb_rand_seq,
        rbg_alloc,
        rat0=None,
        bwpsize=273):
    flag = 0
    last_added = 0
    cnt = 0
    print("Availabel is", tmp_small_bwp_rgb_rand_seq)
    for alloc in rbg_alloc:
        if rgb_idx in alloc:
            flag = 1
            break
    remv_entry = 0
    if flag == 0:
        if rat0 is not None:
            partial_rgbs = check_rgbs_set(rat0, bwpsize)
            print("This scenario is belong to partial allocation",
                  tmp_small_bwp_rgb_rand_seq, small_bwp_rgb_rand_seq)
            last_rand = small_bwp_rgb_rand_seq[-1]
            last_rgb_indx = small_bwp_rgb_rand_seq.index(last_rand)
            for alloc in rbg_alloc:
                if last_rgb_indx in alloc:
                    flag = 1
                break
            if flag == 1:
                alloc.remove(last_rgb_indx)
                cnt = cnt + 1
        else:
            print("Error in partial leg")
            # check the partial area
    if flag == 1:
        for i in range(len(alloc)):
            if last_added == 0:
                last_added = 1
                if len(tmp_small_bwp_rgb_rand_seq) < len(alloc):
                    print("Last rand added is",
                          small_bwp_rgb_rand_seq[-1],
                          "alloc remain",
                          i,
                          'tot alloc',
                          alloc)
                    tmp_small_bwp_rgb_rand_seq.append(
                        small_bwp_rgb_rand_seq[-1])

            rand = min(tmp_small_bwp_rgb_rand_seq)
            tmp_small_bwp_rgb_rand_seq.remove(rand)
            rbg_idx = small_bwp_rgb_rand_seq.index(rand)
            if rbg_idx not in alloc:
                print("Error", alloc, 'script derived ==>rbgidx', rbg_idx,
                      'rand==>', rand, "rand seq", small_bwp_rgb_rand_seq)
                return 'Fail'
            else:
                cnt += 1
        if cnt == len(alloc):
            rbg_alloc.remove(alloc)
            return 'Pass'
        else:
            print("Faiulre leg", cnt, "alloc", alloc)
            return 'Fail'
    else:
        print("RGB Index not found", rgb_idx, "allocation is", rbg_alloc)
        return 'Fail'


def clean_up_inv(seqnce):
    lnth = len(seqnce)
    cnt = 0
    for i in range(lnth):
        if seqnce[i] == 255:
            cnt = cnt + 1
    for i in range(cnt):
        seqnce.remove(255)


def verify_rat0bitmap(
        numprb_small_bwp,
        numprb_second_bwp,
        numprb_large_bwp,
        sfn,
        slot,
        cellid,
        totalrbg_isalands,
        rat0bitmap_small_bwp=[],
        rat0bitmap_second_bwp=[],
        rat0bitmap_large_bwp=[],
        smallbwp=245,
        secondbwp=0,
        largbwp=273,
        rbgsize=16):
    is_cleanup_small = 0
    is_cleanup_second = 0
    is_cleanup_large = 0
    rand_rbg_seq = genrate_random(sfn, slot, cellid, totalrbg_isalands)
    str_slot = str(slot)
    occured_events = all_events.keys()
    if 'dlPagingOrSibSchedData' in occured_events:
        print("sib is scheduled on this SFN", sfn)
        if all_events['dlPagingOrSibSchedData'][sfn] is not None:
            slot_info = all_events['dlPagingOrSibSchedData'][sfn].fetch_records(
                'slot', 'startPrb', 'numOfPrb')
            for slots in slot_info[0]:
                if str_slot in slots:
                    print(
                        "sib is scheduled on solt{0}  of SFN:{1}".format(
                            slot, sfn))
                    start_prb = int(float(slot_info[1][0]))
                    num_prb = int(float(slot_info[2][0]))
                    num_rbgs_ssb = int(num_prb / rbgsize)
                    if num_prb % rbgsize:
                        num_rbgs_ssb = num_rbgs_ssb + 1
                    initial_rbg_pos = int(start_prb / rbgsize)
                    num_rbgs_not_use = int(num_prb / rbgsize)
                    if start_prb % rbgsize:
                        num_rbgs_not_use = num_rbgs_not_use + 1
                    endpoint = initial_rbg_pos + num_rbgs_not_use
                    for i in range(initial_rbg_pos, endpoint):
                        print("Setting RBGX as 255", i)
                        rand_rbg_seq[i] = 255
                    is_cleanup_small = 1
                    is_cleanup_second = 1
                    is_cleanup_large = 1
                    break
            print(
                "After considering dlPagingOrSibSchedData rand seq",
                rand_rbg_seq)
    small_bwp_rand_last_indx = 0
    second_bwp_rand_last_indx = 0
    is_smallbwp_partial_used = 0
    tmp_small_bwp_rgb_rand_seq = []
    small_bwp_rgb_rand_seq = []
    if len(rat0bitmap_small_bwp) != 0:
        rbg_alloc = []
        for i in rat0bitmap_small_bwp:
            rbg_alloc.append(check_rgbs_set(i, smallbwp))
        total_alloc = get_len(rbg_alloc)
        print("rgb allocation list", rbg_alloc, "total rbgs", total_alloc)

        is_partial = 0
        if smallbwp % rbgsize == 0:
            small_bwp_rand_last_indx = int(smallbwp / rbgsize)
        else:
            small_bwp_rand_last_indx = int(smallbwp / rbgsize) + 1
            is_partial = 1
        small_bwp_partial_rbg_utlz = []
        small_bwp_rgb_rand_seq = rand_rbg_seq[:small_bwp_rand_last_indx]
        if is_partial == 1:
            tmp_small_bwp_rgb_rand_seq = small_bwp_rgb_rand_seq[:-1]
        else:
            tmp_small_bwp_rgb_rand_seq = small_bwp_rgb_rand_seq[:]
        remain = len(tmp_small_bwp_rgb_rand_seq) - total_alloc
        partial_prb_cnt_smallbwp = []
        while total_alloc != 0:
            min_rand = min(tmp_small_bwp_rgb_rand_seq)
            if min_rand == 255:
                tmp_small_bwp_rgb_rand_seq.remove(min_rand)
                continue
            print(tmp_small_bwp_rgb_rand_seq, '==>', min_rand)
            rgb_idx = small_bwp_rgb_rand_seq.index(min_rand)
            chk_remove_alloc(
                rgb_idx,
                tmp_small_bwp_rgb_rand_seq,
                small_bwp_rgb_rand_seq,
                rbg_alloc)
            total_alloc = get_len(rbg_alloc)
            print("Pending allocation", total_alloc)
            if (len(tmp_small_bwp_rgb_rand_seq) ==
                    0) and is_smallbwp_partial_used == 0:
                prbs_used_from_small_bwp = 0
                partial_prb_cnt = 0
                info = all_events['dlFdSchedData'][sfn].fetch_records(
                    'slot', 'startPrb', 'numOfPrb', 'cellBwpId')
                print("small bwp id is chosen as", 2)
                tti_bwp_id_indx = 0
                for slots in info[0]:
                    if str_slot == slots:
                        if int(float(info[-1][tti_bwp_id_indx])) == 2:
                            print(
                                "info[2][tti_bwp_id_indx]",
                                prbs_used_from_small_bwp,
                                info[2][tti_bwp_id_indx])
                            prbs_used_from_small_bwp = prbs_used_from_small_bwp + \
                                int(float(info[2][tti_bwp_id_indx]))
                    tti_bwp_id_indx = tti_bwp_id_indx + 1

                used = prbs_used_from_small_bwp - \
                    (int((smallbwp / rbgsize)) * rbgsize)
                if used > 0:
                    partial_prb_cnt_smallbwp.append(used)
                    is_smallbwp_partial_used = 1
    print("Small BWP partial is used then how many PRBs is from the rbg",
          partial_prb_cnt_smallbwp,
          (int((smallbwp / rbgsize)) * rbgsize),
          prbs_used_from_small_bwp)
    print("Small BWP partial area needs to be used here code will be added use the flga is_smallbwp_partial_used")
    print("AFter", tmp_small_bwp_rgb_rand_seq)
    if remain == len(tmp_small_bwp_rgb_rand_seq):
        print("All RBGs are allocated for small BWP")
    else:
        print("need to use the partial area as well")
    tmp_second_bwp_rgb_rand_seq = []
    if len(rat0bitmap_second_bwp) != 0:
        is_partial = 0
        if secondbwp % rbgsize == 0:
            second_bwp_rand_last_indx = int(secondbwp / rbgsize)
        else:
            second_bwp_rand_last_indx = int(secondbwp / rbgsize) + 1
            is_partial = 1
    if len(rat0bitmap_large_bwp) != 0:
        print("Verifying large BWP allocation", rat0bitmap_large_bwp)
        is_partial = 0
        large_bwp_partial_used = 0
        large_bwp_exclusive_rand = ''
        if largbwp % rbgsize == 0:
            large_bwp_rand_last_indx = int(largbwp / rbgsize)
        else:
            large_bwp_rand_last_indx = int(largbwp / rbgsize) + 1
            is_partial = 1
            if len(rat0bitmap_second_bwp) != 0:
                large_bwp_exclusive_rand = rand_rbg_seq[second_bwp_rand_last_indx:]
            elif len(rat0bitmap_small_bwp) != 0:
                large_bwp_exclusive_rand = rand_rbg_seq[small_bwp_rand_last_indx:]
            else:
                large_bwp_exclusive_rand = rand_rbg_seq[:]

        print("large_bwp_exclusive_rand --act", large_bwp_exclusive_rand)
        rbg_alloc = []
        l_index = 0
        partail_alloction_indx = 0
        is_large_indx_need = 0
        partail_rat0 = None
        for i in rat0bitmap_large_bwp:
            if numprb_large_bwp[l_index] % rbgsize:
                partial_rbg = numprb_large_bwp[l_index] % rbgsize
                if (largbwp % rbgsize) == partial_rbg:
                    print("Consider the partial RBG part i.e last index")
                    is_large_indx_need = 1
                    partail_rat0 = i

            l_index = l_index + 1
            rbg_alloc.append(check_rgbs_set(i, largbwp))

        total_alloc = get_len(rbg_alloc)
        print("For Large BWP gnb allocated rgb  allocation list ",
              rbg_alloc, "total rgbs", total_alloc)
        if is_partial == 1:
            tmp_large_bwp_exclusive_rand_seq = large_bwp_exclusive_rand[:-1]
        else:
            tmp_large_bwp_exclusive_rand_seq = large_bwp_exclusive_rand[:]
        is_other_region_considered = 0
        while total_alloc != 0:
            if is_other_region_considered == 0:
                is_other_region_considered = 1
                for i in tmp_small_bwp_rgb_rand_seq:
                    tmp_large_bwp_exclusive_rand_seq.append(i)
                for i in tmp_second_bwp_rgb_rand_seq:
                    tmp_large_bwp_exclusive_rand_seq.append(i)
                if is_smallbwp_partial_used == 0:
                    if len(small_bwp_rgb_rand_seq):
                        print(
                            "Dbg",
                            get_len(rbg_alloc),
                            large_bwp_rand_last_indx,
                            small_bwp_rand_last_indx)
                        is_smallbwp_partial_used = 1
                        tmp_large_bwp_exclusive_rand_seq.append(
                            small_bwp_rgb_rand_seq[-1])
            if is_cleanup_large:
                is_cleanup_large = 0
                clean_up_inv(tmp_large_bwp_exclusive_rand_seq)

            min_rand = min(tmp_large_bwp_exclusive_rand_seq)
            rgb_idx = rand_rbg_seq.index(min_rand)
            print(
                "script calculated rgb idx",
                rgb_idx,
                'for rand no',
                min_rand)
            print("large BWP exclusive==>", tmp_large_bwp_exclusive_rand_seq)
            chk_remove_alloc(
                rgb_idx,
                tmp_large_bwp_exclusive_rand_seq,
                rand_rbg_seq,
                rbg_alloc,
                partail_rat0,
                largbwp)
            total_alloc = get_len(rbg_alloc)
            print("Total RBG allocation for large BWP", total_alloc)
            if len(tmp_large_bwp_exclusive_rand_seq) == 0:
                print(
                    "Large BWP exclusive area is used empty and rgb alloc need to add the last rbg",
                    rbg_alloc)
                if len(rbg_alloc):
                    tmp_large_bwp_exclusive_rand_seq.append(rand_rbg_seq[-1])
        if len(tmp_large_bwp_exclusive_rand_seq) == 0 and len(
                tmp_second_bwp_rgb_rand_seq) == 0 and len(tmp_small_bwp_rgb_rand_seq) == 0:
            print("All RBGs are allocated as per the random order")
            return 'Pass'
        else:
            print("Wrong check used")
            return 'Fail'


def validat_random_rbg_alloc(
        file_name,
        event,
        small_bwp_prb,
        second_bwp_prb,
        large_bwp_prb,
        smallbwp_id=255,
        second_bwp_id=255,
        large_bwp_id=255):
    attrs = [
        'sfn',
        'slot',
        'physCellId',
        'rnti',
        'numOfPrb',
        'startPrb',
        'cellBwpId',
        'rat0Bitmap']
    recs = read_tti_csv(file_name, event, *attrs)
    if large_bwp_prb >= 145:
        rbg_size = 16
    elif large_bwp_prb >= 73:
        rbg_size = 8
    elif large_bwp_prb >= 37:
        rbg_size = 4
    else:
        rbg_size = 2
    totalrbg_isalands = int(large_bwp_prb / rbg_size)
    if large_bwp_prb % rbg_size != 0:
        totalrbg_isalands += 1
    rat0bitmap_small_bwp = []
    rat0bitmap_second_bwp = []
    rat0bitmap_large_bwp = []
    numprb_small_bwp = []
    numprb_second_bwp = []
    numprb_large_bwp = []
    pre_sfn = int(float(recs[0][0]))
    pre_slot = int(float(recs[1][0]))
    cellid = int(float(recs[2][0]))
    if smallbwp_id == int(float(recs[6][0])):
        rat0bitmap_small_bwp.append(int(float(recs[-1][0])))
        numprb_small_bwp.append(int(float(recs[4][0])))
    elif second_bwp_id == int(float(recs[6][0])):
        rat0bitmap_second_bwp.append(int(float(recs[-1][0])))
        numprb_second_bwp.append(int(float(recs[4][0])))
    elif large_bwp_id == int(float(recs[6][0])):
        rat0bitmap_large_bwp.append(int(float(recs[-1][0])))
        numprb_large_bwp.append(int(float(recs[4][0])))
    else:
        print("Invalid information is input or sth wrong")
        return 'Fail'

    for index in range(1, len(recs[0])):
        sfn = int(float(recs[0][index]))
        slot = int(float(recs[1][index]))
        if pre_sfn != sfn or pre_slot != slot:
            print("verifying for rat0bitmap on", pre_sfn, pre_slot)
            verify_rat0bitmap(
                numprb_small_bwp,
                numprb_second_bwp,
                numprb_large_bwp,
                pre_sfn,
                pre_slot,
                cellid,
                totalrbg_isalands,
                rat0bitmap_small_bwp=rat0bitmap_small_bwp,
                rat0bitmap_second_bwp=rat0bitmap_second_bwp,
                rat0bitmap_large_bwp=rat0bitmap_large_bwp,
                smallbwp=small_bwp_prb,
                secondbwp=second_bwp_prb,
                largbwp=large_bwp_prb,
                rbgsize=rbg_size)
            rat0bitmap_small_bwp = []
            rat0bitmap_second_bwp = []
            rat0bitmap_large_bwp = []
            numprb_small_bwp = []
            numprb_second_bwp = []
            numprb_large_bwp = []
            if smallbwp_id == int(float(recs[6][index])):
                rat0bitmap_small_bwp.append(int(float(recs[-1][index])))
                numprb_small_bwp.append(int(float(recs[4][index])))
            elif second_bwp_id == int(float(recs[6][index])):
                rat0bitmap_second_bwp.append(int(float(recs[-1][index])))
                numprb_second_bwp.append(int(float(recs[4][index])))
            elif large_bwp_id == int(float(recs[6][index])):
                rat0bitmap_large_bwp.append(int(float(recs[-1][index])))
                numprb_large_bwp.append(int(float(recs[4][index])))
            else:
                print("Invalid information is input or sth wrong")
                return 'Fail'
        else:
            if smallbwp_id == int(float(recs[6][index])):
                rat0bitmap_small_bwp.append(int(float((recs[-1][index]))))
                numprb_small_bwp.append(int(float(recs[4][index])))
            elif second_bwp_id == int(float(recs[6][index])):
                rat0bitmap_second_bwp.append(int(float(recs[-1][index])))
                numprb_second_bwp.append(int(float(recs[4][index])))
            elif large_bwp_id == int(float(recs[6][index])):
                rat0bitmap_large_bwp.append(int(float(recs[-1][index])))
                numprb_large_bwp.append(int(float(recs[4][index])))
            else:
                print("Invalid information is input or sth wrong")
                return 'Fail'
        pre_sfn = sfn
        pre_slot = slot


def verify_dtx(file, rnti_list):
    attrs = ['rnti', 'ueList']
    recs = read_tti_csv(file, 'dlDtxOptimData', *attrs)
    rnti_tmp = rnti_list[:]
    for rntis in recs[1]:
        for rnti in rnti_list:
            if rnti in rnti_tmp:
                rnti_tmp.remove(rnti)
                if len(rnti_tmp) == 0:
                    print("All ues are in DTX")
                    return 'Pass'

    print("List of ues not in DTX", rnti_tmp)
    return 'Fail'


def merge_multiple_csv_8954(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_' + dire + '_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_' + dire + '_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(
                pd.read_csv(
                    os.path.join(
                        filepath,
                        file),
                    low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)
