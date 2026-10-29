import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_gbr_demand_allocation(file_name1, file_name2, cellid):
    dummy1 = AutoDict()
    dummy2 = AutoDict()
    dummy3 = AutoDict()
    dummy4 = AutoDict()

    print("Reading from 1st file ", file_name1)
    with open(file_name1) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulMetricIndData':
                try:
                    dummy1[line['physCellId']].append(int(float(line['metricIndData.gbrPrbDemand'])))
                except Exception:
                    dummy1[line['physCellId']] = [int(float(line['metricIndData.gbrPrbDemand']))]
            if 'type' in header and line['type'] == 'ulPsCellGbrLoadIndData':
                try:
                    dummy3[line['physCellId']].append(int(float(line['gbrPrbLoad'])))
                except Exception:
                    dummy3[line['physCellId']] = [int(float(line['gbrPrbLoad']))]

    print("Reading from 2nd file ", file_name2)
    with open(file_name2) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulMetricIndData':
                try:
                    dummy2[line['physCellId']].append(int(float(line['metricIndData.gbrPrbDemand'])))
                except Exception:
                    dummy2[line['physCellId']] = [int(float(line['metricIndData.gbrPrbDemand']))]
            if 'type' in header and line['type'] == 'ulPsCellGbrLoadIndData':
                try:
                    dummy4[line['physCellId']].append(int(float(line['gbrPrbLoad'])))
                except Exception:
                    dummy4[line['physCellId']] = [int(float(line['gbrPrbLoad']))]

    gbr_demand_list1 = list(set(dummy1.get(cellid)))
    gbr_demand_list2 = list(set(dummy2.get(cellid)))

    gbr_demand_final_list1 = set(gbr_demand_list1)
    print('gbr_demand_final_list1 values', list(gbr_demand_final_list1))
    gbr_demand_final_list1_count = len(gbr_demand_final_list1)
    print('gbr_demand_final_list1 count', gbr_demand_final_list1_count)

    gbr_demand_final_list2 = set(gbr_demand_list2)
    print('gbr_demand_final_list2 values', list(gbr_demand_final_list2))
    gbr_demand_final_list2_count = len(gbr_demand_final_list2)
    print('gbr_demand_final_list2 len', gbr_demand_final_list2_count)

    flag = 1
    count = 0
    list_count = gbr_demand_final_list1_count * 20/100
    if gbr_demand_final_list1_count == gbr_demand_final_list2_count:
        for value in gbr_demand_final_list1:
            if value in gbr_demand_final_list2:
                print('value present', value)
            else:
                flag = 0
                count = count + 1
    else:
        flag = 0

    if flag == 1:
        print('Testcase pass, gbr demand values are same before and after run of ngbr call')
    else:
        percent_value = (gbr_demand_final_list2_count * 30) / 100
        if count > percent_value:
            print('Testcase fail, gbr demand values are not same before and after run of ngbr call')
        else:
            flag = 1
            print('Testcase pass, gbr demand values are same before and after run of ngbr call')

    gbr_demand_list1 = list(set(dummy3.get(cellid)))
    gbr_demand_list2 = list(set(dummy4.get(cellid)))

    gbr_demand_final_list1 = set(gbr_demand_list1)
    print('gbr_demand_final_list1 values', list(gbr_demand_final_list1))
    gbr_demand_final_list1_count = len(gbr_demand_final_list1)
    print('gbr_demand_final_list1 count', gbr_demand_final_list1_count)

    gbr_demand_final_list2 = set(gbr_demand_list2)
    print('gbr_demand_final_list2 values', list(gbr_demand_final_list2))
    gbr_demand_final_list2_count = len(gbr_demand_final_list2)
    print('gbr_demand_final_list2 len', gbr_demand_final_list2_count)

    flag = 1
    count = 0
    if gbr_demand_final_list1_count == gbr_demand_final_list2_count:
        for value in gbr_demand_final_list1:
            if value in gbr_demand_final_list2:
                print('value present', value)
            else:
                flag = 0
                count = count + 1
    else:
        flag = 0

    if flag == 1:
        print('Testcase pass, gbr allocation values are same before and after run of ngbr call')
    else:
        percent_value = (gbr_demand_final_list2_count * 20) / 100
        if count > percent_value:
            print('Testcase fail, gbr demand values are not same before and after run of ngbr call')
        else:
            flag = 1
            print('Testcase pass, gbr allocation values are same before and after run of ngbr call')

    return flag
