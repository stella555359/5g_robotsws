import csv


def read_csv(file_path):
    csv_raw_list = []
    with open(file_path, 'r') as file_object:
        content = csv.reader(file_object)
        for con in content:
            csv_raw_list.append(con)
    return csv_raw_list


def write_csv(file_path, content_list):
    with open(file_path, 'w') as file_object:
        csv_w = csv.writer(file_object)
        for con in content_list:
            csv_w.writerow(con)


def handle_value(raw_list, col_name, new_title):
    if col_name in raw_list[0]:
        index = raw_list[0].index(col_name)
    else:
        raise Exception("not find %s" % col_name)
    raw_list[0].append(new_title)
    for i in range(1, len(raw_list)):
        try:
            source = raw_list[i][index]
        except Exception as err:
            continue
        try:
            b = bin(int(source[:2], 16))[2:]
            c = b.zfill(8)
            target = int(c[1:5], 2)
        except Exception as err:
            target = ''
            pass
        raw_list[i].append(target)
    return raw_list


def calc_csv_ucibits_as_cqi(source_path, target_path, source_title, target_title):
    csv_raw_list = read_csv(source_path)
    content = handle_value(csv_raw_list, source_title, target_title)
    write_csv(target_path, content)


if __name__ == "__main__":
    calc_csv_ucibits_as_cqi('csv_TC026_cucionly.csv',
                            'new.csv', 'uci.pucch.ucibits', 'uciBits.qci')
    # calc_csv_ucibits_as_cqi('csv06234.csv', 'new.csv', 'uciBits', 'uciBits.qci')
