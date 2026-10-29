import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def verify_highest_rank(file_name, rnti, max_expected_rank):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlFdSchedData':
                try:
                    dummy[line['rnti']].append((line['numOfLayers']))
                except Exception:
                    dummy[line['rnti']] = [(line['numOfLayers'])]
    Check = True
    rank = list(set(dummy.get(rnti)))
    if len(rank) != 1:
        print("Allocated with multiple ranks")
        Check = False
    elif rank[0] != max_expected_rank:
        print("rnti:", rnti, max_expected_rank, "is not matching with rank", rank[0])
        Check = False
    elif rank[0] == max_expected_rank:
        print("rnti:", rnti, max_expected_rank, "is matching with rank", rank[0])
    return Check
