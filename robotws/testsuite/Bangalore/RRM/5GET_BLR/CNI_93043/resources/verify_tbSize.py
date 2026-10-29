import csv


def validate_tbSize(file_name, uernti, fddflag=True, flag=False):
    print(file_name)
    rnti = []
    num_5qi1Prb = []
    bitmap = []
    tb_size = []
    total_BufferedBytes = []

    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if ('type' in header and line['type'] == 'dlFdSchedData') \
                    and ('numOf5qi1Prb' in header and line['numOf5qi1Prb'] != '0.0') \
                    and ('rat0Bitmap' in header and line['rat0Bitmap'] == '1.0'):
                if int(line['rnti']) == 65535:
                    continue
                try:
                    num_5qi1Prb.append(int(float(line['numOf5qi1Prb'])))
                    bitmap.append(int(float(line['rat0Bitmap'])))
                    tb_size.append(int(float(line['tbSize'])))
                    total_BufferedBytes.append(int(float(line['rrmtotalDrbBufferedBytes'])))
                except Exception:
                    pass
    print(tb_size)
    print(total_BufferedBytes)
    status = True
    length = len(total_BufferedBytes)
    for i in range(length - 1):
        if not total_BufferedBytes[i] * 8 <= tb_size[i]:
            print(total_BufferedBytes[i], tb_size[i])
            status = False
    return status
