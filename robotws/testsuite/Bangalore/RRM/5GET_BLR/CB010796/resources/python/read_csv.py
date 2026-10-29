import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_nonUeSpecificPriority(file_name):
    dummy = AutoDict()
    count = 0
    rf_cooling = []
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'dlSlotBlankingInfo' and
                                     (line['nonUeSpecificPriorityInSlot'] == 'CSIRS' or
                                      line['nonUeSpecificPriorityInSlot'] == 'SSB')):
                try:
                    rf_cooling.append(line['slotMutedForRfCooling'])
                except Exception:
                    pass
        status = "True"
        count = len(rf_cooling)
        print("Array count", count)
        for i in range(count-1):
            if int(float(rf_cooling[i])) == 0:
                print("Condition is matching")
            else:
                print("Condition Failed", rf_cooling[i])
                status = "False"

    return status


def check_targetMutingRatio(file_name, tmr):
    dummy = AutoDict()
    count = 0
    achvd_muting_ratio = []
    muting_outcome = []
    tgt_muting_ratio = []
    rf_cooling = []
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'dlSlotBlankingInfo' and
                                     line['nonUeSpecificPriorityInSlot'] == 'LASTUNUSED'):
                try:
                    achvd_muting_ratio.append(line['achievedMutingRatio'])
                    muting_outcome.append(line['slotMutingOutcome'])
                    tgt_muting_ratio.append(line['targetMutingRatio'])
                    rf_cooling.append(line['slotMutedForRfCooling'])
                except Exception:
                    pass

        num = 0
        count = len(rf_cooling)
        print("Array count", count)
        for i in range(count-1):
            if int(float(rf_cooling[i])) == 1 and int(float(tgt_muting_ratio[i])) == int(tmr):
                print("Slot Muted     : ", rf_cooling[i], achvd_muting_ratio[i], muting_outcome[i], tgt_muting_ratio[i])
                num = num+1
            else:
                print("Slot Not Muted : ", rf_cooling[i], achvd_muting_ratio[i], muting_outcome[i], tgt_muting_ratio[i])

    print("Total Slot muted for RF Colling : ", num)
    return 'True' if num >= 1 else 'False'
