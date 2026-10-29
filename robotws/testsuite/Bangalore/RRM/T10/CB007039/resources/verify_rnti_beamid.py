import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def verify_rnti_beamid(file_name, rnti, beam_id):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        # print(header)
        for line in csv_reader:
            print(line)
            if 'type' in header and line['type'] == 'dlBeamData':
                try:
                    dummy[line['rnti']].append(int(float(line['currentBestBeamId'])))
                except Exception:
                    dummy[line['rnti']] = [int(float(line['currentBestBeamId']))]
    Check = True
    for key in rnti:
        print(key)
        beam = list(set(dummy.get(key)))
        if len(beam) != 1:
            Check = False
        if beam[0] != beam_id:
            Check = False
            print("Beam_ID is not matching")
        else:
            print("Bmid_ID is matching")
    return Check
