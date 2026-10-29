from collections import namedtuple
import csv

all_events = {}
xxxx = ''


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
    # for i in rec[4]:
    # print("RNTI",i)
    # check_random(i)


# verify_randomprb("x.csv", "xyz", "sfn", "slot", "rnti", "rat0Bitmap")
#

# count_records()
file = 'output_dl_formated.csv'
event = 'dlLaSwitchBetweenHrAndBr'
chk_attrs = [
    'laMode',
    'event',
    'pdcchMetric.nbSamples',
    'pdcchMetric.nbSamplesThreshold',
    'pdcchMetric.ratio',
    'pdschMetric.nbSamples',
    'pdschMetric.nbSamplesThreshold',
    'sfn',
    'slot',
    'cqiAlSelection',
    'aggregationLevel',
    'pdschMetric.ratio']


def verify_pdcch_outage(
        file,
        event,
        refer_event,
        nidd_pdcch,
        nidd_pdsch,
        *attrs):
    values = read_tti_csv(file, event, *attrs)
    # nidd:tti_trace
    # cqiDciCssAl[x]HR  => x is agregation level

    aggr_mapping = {1: 8, 2: 4, 4: 2, 8: 1}
    curr_refer_info = ""
    # refer_value=read_tti_csv(file,refer_event,*attrs)
    for indx in range(len(values[4])):
        # dlLaSwitchBetweenHrAndBr from this event pdcchmetric ratio is
        # compared with nidd recover %
        if int(float(values[4][indx])) >= int(nidd_pdcch) or int(
                float(values[-1][indx])) >= int(nidd_pdsch):
            if 'BASICRELIABILITY' == values[0][indx] and 'HIGHRELIABILITY' == values[0][indx - 1]:

                print("HR to BR switch success",
                      values[0][indx - 1], 'switch to', values[0][indx])
                print("SFN:{0} SLOT:{1}".format(
                    values[-5][indx], values[-4][indx]))

                curr_refer_info = all_events[refer_event][int(
                    float(values[-5][indx]))].fetch_records(*attrs)
                if len(curr_refer_info[-4]) == 1:
                    fn = int(float(values[-5][indx]) - 1)
                    while True:
                        if all_events[refer_event][fn] is not None:
                            curr_refer_info = all_events[refer_event][fn].fetch_records(
                                *attrs)
                            break
                        fn = fn - 1
                    if 'HIGHRELIABILITY' in curr_refer_info[0]:
                        # print("event ",refer_event,"-->",file,"-->",fn)
                        print("HR to BR switch success in dlfdsch event aggre lvl")
                        print("Aggregation level before HR to BR switch",
                              curr_refer_info[-2])
                        hr_br_sfn_info = all_events[refer_event][int(
                            float(values[-5][indx]))].fetch_records(*attrs)
                        print("Aggregation level during HR to BR switch",
                              hr_br_sfn_info[-2])
                        return 'pass'
                elif 'BASICRELIABILITY' in curr_refer_info[0] and 'HIGHRELIABILITY' in curr_refer_info[0]:
                    print("HR to BR switch success in dlfdsch event")
                    return 'pass'
    print("HR to BR switch failed")
    return 'fail', curr_refer_info


def verify_pdcch_recovery(file, event, nidd_pdcch, nidd_pdsch, *attrs):
    values = read_tti_csv(file, event, *attrs)
    for indx in range(len(values[4])):
        if int(float(values[4][indx])) >= int(nidd_pdcch) and int(
                float(values[-1][indx])) >= int(nidd_pdsch):
            if 'BASICRELIABILITY' == values[0][indx -
                                               1] and 'HIGHRELIABILITY' == values[0][indx]:
                print("BR to HR switch success",
                      values[0][indx - 1], 'switch to', values[0][indx])
                return 'pass'
    print("BR to HR switch failed")
    return 'fail'


# x=verify_pdcch_outage(file,event,'dlFdSchedData',20,2,*attrs)
# file='output_dl_formated_blerdeact.csv'
# y=verify_pdcch_recovery(file,event,20,*attrs)


file = 'output_ul_formated.csv'
event = 'ulLaSwitchBetweenHrAndBr'
chk_attrs = [
    'laMode',
    'event',
    'pdcchMetric.nbSamples',
    'pdcchMetric.nbSamplesThreshold',
    'pdcchMetric.ratio',
    'puschMetric.nbSamples',
    'puschMetric.nbSamplesThreshold',
    'sfn',
    'slot',
    'cqiAlSelection',
    'aggregationLevel',
    'puschMetric.ratio']


def verify_pdcch_outage_ul(
        file,
        event,
        refer_event,
        nidd_pdcch,
        nidd_pusch,
        *attrs):
    values = read_tti_csv(file, event, *attrs)
    # nidd:tti_trace
    # cqiDciCssAl[x]HR  => x is agregation level

    aggr_mapping = {1: 8, 2: 4, 4: 2, 8: 1}
    curr_refer_info = ""
    # refer_value=read_tti_csv(file,refer_event,*attrs)
    for indx in range(len(values[4])):
        # dlLaSwitchBetweenHrAndBr from this event pdcchmetric ratio is
        # compared with nidd recover %
        if int(float(values[4][indx])) >= int(nidd_pdcch) or int(
                float(values[-1][indx])) >= int(nidd_pusch):
            if 'BASICRELIABILITY' == values[0][indx] and 'HIGHRELIABILITY' == values[0][indx - 1]:

                print("HR to BR switch success",
                      values[0][indx - 1], 'switch to', values[0][indx])
                print("SFN:{0} SLOT:{1}".format(
                    values[-5][indx], values[-4][indx]))

                curr_refer_info = all_events[refer_event][int(
                    float(values[-5][indx]))].fetch_records(*attrs)
                if len(curr_refer_info[-4]) == 1:
                    fn = int(float(values[-5][indx]) - 1)
                    while True:
                        if all_events[refer_event][fn] is not None:
                            curr_refer_info = all_events[refer_event][fn].fetch_records(
                                *attrs)
                            break
                        fn = fn - 1
                    if 'HIGHRELIABILITY' in curr_refer_info[0]:
                        # print("event ",refer_event,"-->",file,"-->",fn)
                        print("HR to BR switch success in ulfdsch event aggre lvl")
                        print("Aggregation level before HR to BR switch",
                              curr_refer_info[-2])
                        hr_br_sfn_info = all_events[refer_event][int(
                            float(values[-5][indx]))].fetch_records(*attrs)
                        print("Aggregation level during HR to BR switch",
                              hr_br_sfn_info[-2])
                        return 'pass'
                elif 'BASICRELIABILITY' in curr_refer_info[0] and 'HIGHRELIABILITY' in curr_refer_info[0]:
                    print("HR to BR switch success in ulfdsch event")
                    return 'pass'
    print("HR to BR switch failed")
    return 'fail', curr_refer_info


def verify_pdcch_recovery_ul(file, event, nidd_pdcch, nidd_pusch, *attrs):
    values = read_tti_csv(file, event, *attrs)
    for indx in range(len(values[4])):
        if int(float(values[4][indx])) >= int(nidd_pdcch) and int(
                float(values[-1][indx])) >= int(nidd_pusch):
            if 'BASICRELIABILITY' == values[0][indx -
                                               1] and 'HIGHRELIABILITY' == values[0][indx]:
                print("BR to HR switch success",
                      values[0][indx - 1], 'switch to', values[0][indx])
                return 'pass'
    print("BR to HR switch failed")
    return 'fail'
