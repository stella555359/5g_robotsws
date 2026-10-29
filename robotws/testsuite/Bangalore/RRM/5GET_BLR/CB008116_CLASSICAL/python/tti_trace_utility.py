import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


class TtiTrace:

    def __init__(self, file_name, crnti, direction, bearer_id_list, trace_duration=3):
        self.file_name = file_name
        self.crnti = crnti
        self.bearer_id_list = bearer_id_list
        self.trace_duration = float(trace_duration)
        self.direction = direction

    def calculate_tput_dl(self):
        dummy_dl = AutoDict()
        for b_id in self.bearer_id_list:
            b_id_tm = str(b_id).strip()
            b_id = 'scheduledBytesPerBearer[' + b_id_tm + ']'
            with open(self.file_name) as csv_file:
                csv_reader = csv.DictReader(csv_file)
                header = csv_reader.fieldnames
                for line in csv_reader:
                    if 'type' in header and line['type'] == 'dlFdSchedData' and line['rnti'] == str(self.crnti):
                        try:
                            dummy_dl[line['rnti']][b_id_tm] += (float(line[b_id]) * 8) / self.trace_duration
                        except TypeError:
                            dummy_dl[line['rnti']][b_id_tm] = (float(line[b_id]) * 8) / self.trace_duration
        return dummy_dl

    def calculate_tput_ul(self):
        dummy_ul = AutoDict()
        for b_id in self.bearer_id_list:
            b_id_tm = str(b_id).strip()
            with open(self.file_name) as csv_file:
                csv_reader = csv.DictReader(csv_file)
                header = csv_reader.fieldnames
                for line in csv_reader:
                    for l_id in range(0, 8):
                        if ('type' in header and 'rcvdBearers[' + str(l_id) + '].lcId' in header and
                                line['type'] == 'ulPduDemuxData' and line['rnti'] == str(self.crnti)
                                and line['rcvdBearers[' + str(l_id) + '].lcId'] == str(float(b_id_tm))):
                            try:
                                dummy_ul[line['rnti']][b_id_tm] += (float(
                                    line['rcvdBearers[' + str(l_id) + '].rcvdBytes']) * 8) / self.trace_duration
                            except TypeError:
                                dummy_ul[line['rnti']][b_id_tm] = (float(
                                    line['rcvdBearers[' + str(l_id) + '].rcvdBytes']) * 8) / self.trace_duration
        return dummy_ul


def get_tp_frm_tti(crnti_list, ue_to_bearer, direction, filename, tti_dur=3):
    ue_tp_tti = {}
    tp = []
    for ue_id in ue_to_bearer:
        crnti = crnti_list[int(ue_id) - 1]
        bearer_list = ue_to_bearer[ue_id]
        print(crnti, bearer_list)
        if direction == 'ul':
            tp = TtiTrace(filename, crnti, direction, bearer_list, tti_dur).calculate_tput_ul()

        elif direction == 'dl':
            tp = TtiTrace(filename, crnti, direction, bearer_list, tti_dur).calculate_tput_dl()

        ue_tp_tti[ue_id] = tp[crnti]
    print(ue_tp_tti)
    return ue_tp_tti


def verify_tp_from_tti(ue_to_bearer, tp, qos_profile_speed, qos_profile_unit, vonr_codec_rate, tri_time=0,
                       total_dur=0):
    flag = 1
    print("Dead code", tri_time, total_dur)
    for ue_id in ue_to_bearer:
        if len(ue_to_bearer[ue_id]) != len(tp[ue_id].keys()):
            print("Bearer ID and TP data is missmatch")
            return 0
        length = len(qos_profile_speed[ue_id])
        for profile_idx in range(length):
            if qos_profile_unit[ue_id][profile_idx] == "mbps":
                factor = 1048576
            else:
                factor = 1024

            if ('amr' in qos_profile_speed[ue_id][profile_idx] or 'g7' in qos_profile_speed[ue_id][profile_idx]
                    or 'custom' in qos_profile_speed[ue_id][profile_idx]):
                spd = float(vonr_codec_rate[qos_profile_speed[ue_id][profile_idx]])
                # updated_spd = float(vonr_codec_rate[updated_qos_profile_speed[ue_id][profile_idx]])
            else:
                spd = float(qos_profile_speed[ue_id][profile_idx])
            expected_tp = spd * factor

            bearer_id = ue_to_bearer[ue_id][profile_idx]
            tp_per_bearer = tp[ue_id][bearer_id.strip()]

            deviation = max(tp_per_bearer, expected_tp) - min(tp_per_bearer, expected_tp)
            deviation = 100 * (deviation / expected_tp)

            if expected_tp > tp_per_bearer:
                if deviation > 10:
                    print("Failure leg Deviation is more 1% or more")
                    print("Actual TP:{0} Expected TP:{1} Deviate:%{2} for UE ID:{3} Bearer ID{4}".
                          format(tp_per_bearer, expected_tp, deviation, ue_id, bearer_id))
                    flag = 0
            else:
                print("?????How much delta deviation is not known code changes needed further")
                print("Actual TP:{0} Expected TP:{1} Deviate:%{2} for UE ID:{3} Bearer ID{4}".
                      format(tp_per_bearer, expected_tp, deviation, ue_id, bearer_id))
    if flag == 1:
        return 'Pass'
    else:
        return 'Failure'
