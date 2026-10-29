import csv


def validate_mimo(file_name, uernti, fddflag=True, flag=False):
    print(file_name)
    rnti = []
    num_5qi1Prb = []
    bitmap = []
    mu_status = []
    tb_size = []
    total_BufferedBytes = []

    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if ('type' in header and line['type'] == 'dlFdSchedData') \
                    and ('muStatus' in header and line['muStatus'] != 'MUPAIR') \
                    and ('rat0Bitmap' in header and line['rat0Bitmap'] == '1.0'):
                if int(line['rnti']) == 65535:
                    continue
                try:
                    mu_status.append((line['muStatus']))
                    bitmap.append(int(float(line['rat0Bitmap'])))
                    num_5qi1Prb.append(int(float(line['numOf5qi1Prb'])))
                    tb_size.append(int(float(line['tbSize'])))
                    total_BufferedBytes.append(int(float(line['rrmtotalDrbBufferedBytes'])))
                except Exception:
                    pass
    print(bitmap)
    print(mu_status)
    print(tb_size)
    print(total_BufferedBytes)
    status = True
    length = len(total_BufferedBytes)
    for i in range(length - 1):
        if not total_BufferedBytes[i] * 8 <= tb_size[i]:
            print(total_BufferedBytes[i], tb_size[i])
            status = False
    return status
