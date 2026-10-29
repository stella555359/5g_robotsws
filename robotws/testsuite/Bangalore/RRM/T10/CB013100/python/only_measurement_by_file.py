import xml.etree.ElementTree as ET
import csv
from taf.sbts.oam.coam.admin import admin
import os
import tinny_parser
import subprocess
import pkgutil
import importlib
import json
import time


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def is_matplotlib_installed():
    print('mta_isn-->', bool(pkgutil.find_loader('matplotlib')))
    return bool(pkgutil.find_loader('matplotlib'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def install_and_import_matplotlib():
    print("matplot library installation")
    if not is_matplotlib_installed():
        install_package('matplotlib')
    return importlib.import_module('matplotlib')


def download_measurements(path="/home/ute/Downloads/", file='nori.zip'):
    tp = path + file
    api = admin()
    connection = api.connect_to()
    connection.collect_pm_files(tp)
    tp = file.replace('.zip', '')
    tp = path + tp
    zf = path + file
    cmd = 'unzip -d ' + tp + ' ' + zf
    print(cmd)
    os.system(cmd)
    uz = path + file.replace('.zip', '')
    cmd = ' cd ' + uz + '/PERFMON_FILES;' + 'gunzip *'
    print(cmd)
    os.system(cmd)


def traverse(root, cntr_data, stk):
    for child in root:
        if child.tag == 'DN':
            dn = child.text
            if len(stk):
                stk[0] = dn
            else:
                stk.append(dn)
        elif 'measurementType' in child.attrib.keys():
            update_cntr_data(stk[0], child, cntr_data)
        else:
            pass
        traverse(child, cntr_data, stk)


def update_cntr_data(dn, child, cntr_data):
    counters = {}
    data = {}
    if dn not in cntr_data.keys():
        cntr_data[dn] = []
    for cntr in child:
        counters[cntr.tag] = cntr.text
    data[child.attrib['measurementType']] = counters
    cntr_data[dn].append(data)


def read_write_cntr_csv(cntr_data, st_time, file):
    file_csv = file.replace('xml', 'csv')
    header = ['Date_time', 'DN', 'Mtype']
    cntr_list = []
    for dn in cntr_data:
        for cnt in cntr_data[dn]:
            for ag_cnt in cnt:
                for counter in cnt[ag_cnt]:
                    cntr_list.append(counter)
    cntr_list = set(cntr_list)
    header.extend(cntr_list)

    with open(file_csv, 'w', newline='') as csvfile:
        wr = csv.DictWriter(csvfile, fieldnames=header)
        wr.writeheader()
        row = {'Date_time': st_time}
        for dn in cntr_data:
            row['DN'] = dn
            for mea_data in cntr_data[dn]:
                w_row = {}
                for mt in mea_data:
                    row['Mtype'] = mt
                    w_row.update(row)
                    w_row.update(mea_data[mt])
                    wr.writerow(w_row)


def read_xml(file):
    stk = []
    cntr_data = {}
    tree = ET.parse(file)
    root = tree.getroot()
    traverse(root, cntr_data, stk)
    st_time = root[0].attrib['startTime']
    read_write_cntr_csv(cntr_data, st_time, file)


def read_file_list(
        path='/home/ute/Downloads/nori/PERFMON_FILES',
        kpi_txt_file=None,
        kpi=None,
        cell=None):
    install_and_import_pandas()
    install_and_import_matplotlib()
    import pandas as pd
    import matplotlib.pyplot as plt
    pd.set_option('display.max_columns', None)
    for curr_dir, subdir, filenames in os.walk(path):
        # print(filenames)
        for file in filenames:
            if file.endswith('xml'):
                read_xml(curr_dir + '/' + file)
        break
    for curr_dir, subdir, filenames in os.walk(path):
        break
    final = []
    for f in filenames:
        if f.endswith('csv'):
            print("Checking file", f)
            df = pd.read_csv(curr_dir + '/' + f, low_memory=False)
            kpi_data = analyze_kpi_formula(df, kpi_txt_file)
            if kpi_data is not None:
                dn_req = fetch_dn(kpi_data, kpi, cell)
                if dn_req is not None:
                    req_kpi = kpi_data[kpi][0][dn_req][['Date_time', kpi]]
                    final.append(req_kpi)
                # print(final)
    if len(final) != 0:
        final = pd.concat(final)
        final = final.sort_values(by='Date_time')
        print(final)
        return final


def fetch_dn(kpi_data, kpi, cell):
    dn_list = kpi_data[kpi][0].keys()
    for dn in dn_list:
        if cell in dn:
            return dn


def analyze_kpi_formula(df, kpi_txt_file):
    # global gx, gy
    # gy = df
    kpi_counters = tinny_parser.get_kpi_attrs(kpi_txt_file)
    # print(kpi_counters.keys())
    req_dn = []
    kpi_data = {}
    not_present = 0
    for kpi in kpi_counters:
        kpi_data[kpi] = []
        cntrs = kpi_counters[kpi]
        # print('kpi -->',kpi,'cntrs',cntrs)
        for cntr in cntrs:
            tmp_req = ['DN']
            tmp_req.append(cntr)
            if cntr in df.columns:
                not_present = 0
                tmp = df[tmp_req].dropna()['DN'].unique()
                tmp = list(tmp)
                # print('Adding to req dn',tmp)
                if tmp not in req_dn:
                    req_dn.append(tmp)
            else:
                # print("Missing",cntr)
                not_present = 1

        if not_present == 0:
            dn_based_df = get_kpi_based_on_dn(df, req_dn, cntrs)
            # print('dn_based_df',dn_based_df)
            kpi_data[kpi].append(genrate_kpi(dn_based_df, kpi, kpi_txt_file))
            return kpi_data
        # else:
        #   pass
            # print("All Counter is not present or any of missed for KPI ??",kpi)

    # print(req_dn)


# gfin = ''


def get_kpi_based_on_dn(df, req_dn, kpi_counters, specific=None):
    # global gfin
    req = ['Date_time', 'DN']
    req = req + kpi_counters
    # print('Needed is -->',req)
    dn_based_df = {}

    mtype_based_df = {}
    for dns in req_dn:
        for dn in dns:
            # print('checking for',req)
            # Do not do blind drop
            mtypes = check_mtype_common(df, kpi_counters)
            if len(mtypes.keys()) == 1:
                dn_based_df[dn] = df.loc[df['DN'] == dn][req].dropna()
            else:

                flag = 0
                for mtype in mtypes.keys():
                    # print('check  -->',mtype,'bef--->',mtype_based_df)
                    if flag == 0:

                        mtype_based_df[dn] = df.loc[df['DN']
                                                    == dn][mtypes[mtype]].dropna()
                        flag = 1
                    else:
                        # print("Annd  ",mtype_based_df[dn])

                        # gfin = [mtype_based_df[dn], df.loc[df['DN'] == dn][mtypes[mtype]].dropna()]
                        alter_df = df.loc[df['DN'] ==
                                          dn][mtypes[mtype]].dropna()
                        # alter_df=alter_df.drop(['Date_time','DN'],axis=1)
                        # print('you arre merging',alter_df)
                        mtype_based_df[dn] = mtype_based_df[dn].merge(
                            alter_df, on='Date_time')
                        mtype_based_df[dn] = mtype_based_df[dn].rename(
                            columns={'DN_x': 'DN'})
                        mtype_based_df[dn] = mtype_based_df[dn].drop(
                            'DN_y', axis=1)

                    # print('After--->',mtype_based_df)

                final = mtype_based_df
                dn_based_df = mtype_based_df
                # gfin = final
                # print("merged",final)

            # print('diff fail here --->',dn,dn_based_df[dn])
            # gfin = dn_based_df

    return dn_based_df


def check_mtype_common(df, kpi_counters):
    need_cols = ['Mtype'] + kpi_counters
    req_df = df[need_cols]
    mtype_entry = {}

    for cntr in kpi_counters:
        Mtype = req_df[['Mtype', cntr]].dropna()['Mtype'].unique()
        Mtype = list(Mtype)
        for m in Mtype:
            if m not in mtype_entry.keys():
                mtype_entry[m] = ['Date_time', 'DN']
        mtype_entry[m].append(cntr)
    # print('number of Mtype',mtype_entry)
    return mtype_entry
    # mtype_entry = req_df['Mtype'].unique()
    # print('number of Mtype',mtype_entry)


def genrate_kpi(dn_based_df, inp_kpi, req_kpi_file):
    fp = open(req_kpi_file)
    kpis = fp.readlines()
    fp.close()
    # date_time and kpi as key
    req_kpis = {}
    initi_req_kpis(req_kpis, dn_based_df, req_kpi_file)
    req_flds = ['Date_time', 'DN']
    for kpi in kpis:
        if inp_kpi in kpi.split('=')[0]:
            for dn in dn_based_df:
                # print('checking for kpi',kpi.split('=')[0],dn)
                # print('evaluate',kpi)
                dn_based_df[dn] = dn_based_df[dn].eval(kpi, engine='python')
                # print('success')
                req_flds.append(inp_kpi)
                # req_kpis[dn][inp_kpi]=dn_based_df[dn][req_flds]
    return dn_based_df


def initi_req_kpis(req_kpis, dn_based_df, req_kpi_file):
    fp = open(req_kpi_file)
    kpis = fp.readlines()
    fp.close()
    for kpi in kpis:
        for dn in dn_based_df:
            req_kpis[dn] = {}


def plot_kpis():
    pass


def cmp_kpis(bef, aft, kpi_txt_file, kpi, cell):
    bef_rep = read_file_list(bef, kpi_txt_file, kpi, cell)
    aft_rep = read_file_list(aft, kpi_txt_file, kpi, cell)
    bef_kpi = bef_rep[kpi].tolist()
    aft_kpi = aft_rep[kpi].tolist()
    print('Consider the last two readings only')
    last_reading = aft_kpi[-1]

    for kpi_val in bef_kpi:
        if kpi_val > last_reading:
            print(kpi_val, '<-->', last_reading)
            return 'fail'
    # print('al is')
    return 'pass'

# read_file_list(r'C:\Users\kumarnay\Downloads\crt_iphy\nok' ,r'C:\Users\kumarnay\
# Downloads\crt_iphy\nok\req_kpi.txt','NR_5114b' , 'NRCELL-1')


def update_delta_upload(
        file,
        day,
        hour,
        minute,
        dur,
        moc_to_update='MRBTS-1/NRBTS-1/NRPGRP-3'):

    with open(file) as fp:
        data = json.load(fp)
        print(len(data[0]['parameters']))
        for para in data:
            if moc_to_update in para['distName']:
                for p in para['parameters']:
                    if 'lbpsPeriodList' in p['parameterName']:
                        for we_day in p['value']:
                            if day in we_day['lbpsDayOfWeek']:
                                we_day.update(
                                    {'lbpsDuration': dur, 'lbpsStartTimeHour': hour, 'lbpsStartTimeMinute': minute})

    print("-->", file)
    with open(file, 'w') as fp:
        json.dump(data, fp)
        print(data)

    time.sleep(30)
    upload_delta(file)
    time.sleep(40)


def upload_delta(file):
    api = admin()
    connection = api.connect_to()
    connection.perform_delta_recommissioning(delta_file=file)

# update_delta_upload('/home/ute/robotws/testsuite/Bangalore/RRM/T10/CB013100/config
# /SBTS26R1/energysaving_cellswitchoff.json','Mon','10','20','60')
