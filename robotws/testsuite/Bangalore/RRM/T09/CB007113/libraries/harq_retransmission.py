import csv


def validate_maxHarqTxNum(file_name, cellid, maxharqnum=10):
    flag = False
    rnti = []
    maxHarqTxNum = []
    txnum = []
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'maxHarqTxNum' in header and line['physCellId'] == str(cellid) \
                    and line['type'] == 'ulFdSchedData':
                try:
                    maxHarqTxNum.append(int(float(line['maxHarqTxNum'])))
                    txnum.append(int(float(line['txNumber'])))
                except Exception as e:
                    print(e)
    maxHarqTxNum = list(set(maxHarqTxNum))
    txnum = list(set(txnum))
    if maxharqnum in maxHarqTxNum:
        for tx in txnum:
            if tx > 1:
                print("Retransmission is working")
                flag = True
    return flag


def validate_maxHarqTxNum_rnti(file_name, cellid, rnti_=None, payloadsize=1000):
    flag = False
    rnti_dict = {}
    rnti = []
    for ue in rnti_:
        tbsize = []
        with open(file_name) as csv_file:
            csv_reader = csv.DictReader(csv_file)
            header = csv_reader.fieldnames
            for line in csv_reader:
                if 'maxHarqTxNum' in header and line['physCellId'] == str(cellid) \
                        and line['type'] == 'ulFdSchedData' and line['rnti'] == str(ue):
                    try:
                        tbsize.append(int(float(line['tbSize'])))
                    except Exception as e:
                        print(e)
        rnti_dict[ue] = list(set(tbsize))
        tbsize.clear()
    for ue in rnti_:
        for payload in rnti_dict[ue]:
            if payload < payloadsize:
                flag = True
            else:
                continue
    return flag
