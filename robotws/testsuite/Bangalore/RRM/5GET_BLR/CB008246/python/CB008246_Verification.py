import json
import os
import csv
import time


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def find_by_key(data, target):
    if isinstance(data, dict):
        for k, v in data.items():
            if k == target:
                yield v
            else:
                for child_val in find_by_key(v, target):
                    yield child_val
    elif isinstance(data, list):
        for item in data:
            for item_val in find_by_key(item, target):
                yield item_val


def ConvertPcapToJson(PcapFile, filters):
    path, File = os.path.split(PcapFile)
    JsonFile = File.split('.')[0] + '_' + filters + '.json'
    NewJsonPath = os.path.join(path, JsonFile)
    cmd = 'tshark -2 -R ' + filters + ' -r ' + PcapFile + \
        ' -T json --no-duplicate-keys > ' + NewJsonPath
    print('cmd', cmd)
    os.system(cmd)
    time.sleep(5)
    return NewJsonPath


def ReadJsonFile(JsonFile):
    jsonData = ''
    with open(JsonFile) as fd:
        jsonData = json.loads(fd.read())
    return jsonData


def create_csv_file(filePath, event, data, *header):
    dummy = []
    mul = len(data[1][0])
    custom_data = []
    for i in range(len(data[1]) * mul):
        dummy.append(event)
    data.insert(0, dummy)
    for i in range(len(header) + 1):
        custom_data.append([])
    mmm = custom_data
    for pkt in data[1:]:
        indx = 1
        for attr in pkt:
            for attr_val in attr:
                custom_data[indx].append(attr_val)
            indx = indx + 1
        for attr in pkt:
            for i in range(len(attr)):
                custom_data[0].append(event)
            break
    idx = 0
    newData = {}
    for item in header:
        newData[item] = custom_data[idx]
        idx += 1
    CsvFile = filePath.replace('json', 'csv')
    with open(CsvFile, "w", newline='') as outfile:
        writerfile = csv.writer(outfile)
        writerfile.writerow(newData.keys())
        writerfile.writerows(zip(*newData.values()))
    time.sleep(5)
    return CsvFile


def get_values(json_file, event, *args):
    value = []
    z = ReadJsonFile(json_file)
    for i in range(len(z)):
        value.append([])
        for attr in args[1:]:
            x = list(find_by_key(z[i], attr))
            value[i].append(x)
        for item in value[i][:4]:
            if len(item) < len(value[i][3]):
                for j in range(len(item), len(value[i][3])):
                    item.append(item[0])
    create_csv_file(json_file, event, value, *args)
    return value
