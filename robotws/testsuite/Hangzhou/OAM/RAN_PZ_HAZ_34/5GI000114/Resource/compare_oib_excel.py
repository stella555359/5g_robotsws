'''
Created on Mar 19, 2019

@author: l26chen
'''

import xlrd
import xlwt
import datetime
from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.runtime.client_request import ClientRequest
# comment out for incompatible to Office365-REST-Python-Client==2.2.1,
# please double check when these code is needed in future.
# from office365.runtime.utilities.request_options import RequestOptions
from office365.sharepoint.client_context import ClientContext


def download_excel_from_sharepoint(path, url1, url2, url3, url4):
    setting = {
        'url': r'' + url1,
        'id': 'a98fcdcc-21ae-40fb-85b3-0d1c11a5b933',
        'secret': 'gFE5wkIQKxAtwQ1WUKveZQjwYkC+mKHoBpuTmhrM3hw='}
    api = r'' + (url2 + url3 + url4)
    context_auth = AuthenticationContext(url=setting['url'])
    if context_auth.acquire_token_for_app(client_id=setting['id'], client_secret=setting['secret']):
        ctx = ClientContext(setting['url'], context_auth)
        request = ClientRequest(ctx)
        format_str = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/json'
        # comment out for incompatible to Office365-REST-Python-Client==2.2.1
        # options = RequestOptions("{0}/{1}".format(setting['url'], api))
        # options.set_header('Accept', 'text/html,application/xhtml+xml,application/xml,application/json')
        # options.set_header('Content-Type', format_str)
        # data = ctx.execute_request_direct(options)
        # print (data.status_code)
        # if data.status_code == 200:
        #     with open(r'' + path, 'wb') as f:
        #         f.write(data.content)
        #     print ('done')
        #     return 'Pass'
        # else:
        #     print ('error')
        #     print (data.status_code)
        #     raise RuntimeError('download file error from sharepoint')
    else:
        print(context_auth.get_last_error())
        raise RuntimeError('user or password is wrong, please check')


def compare_oib(na_fn, na_sn, na_cn, na_maplist, ni_fn, ni_sn, ni_cn, ni_maplist, case_sen_flag=True):
    timestamp = ''
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    filename = 'Netact_oib_compare_result.xls_' + timestamp + '.xls'
    filename = r'' + filename
    wb = xlwt.Workbook()
    sheet = wb.add_sheet('result')
    na_table = xlrd.open_workbook(r'' + na_fn).sheet_by_name(na_sn)
    ni_table = xlrd.open_workbook(r'' + ni_fn).sheet_by_name(ni_sn)
    na_srow, na_cindex, na_list = get_valid_col_list(na_table, r'' + na_cn, na_maplist)
    ni_srow, ni_cindex, ni_list = get_valid_col_list(ni_table, r'' + ni_cn, ni_maplist)
    netact_clist = na_table.col_values(na_cindex)
    ni_clist = ni_table.col_values(ni_cindex)
    if not case_sen_flag:
        netact_clist = [str(item).lower() for item in netact_clist]
        ni_clist = [str(item).lower() for item in ni_clist]
    diff_flag, save_flag, row = 0, 0, 0
    write_excel_row(sheet, row, ['NetAct Part'])
    row = row + 1
    write_excel_row(sheet, row, [na_cn] + na_maplist)
    for i in range(na_srow + 1, len(netact_clist)):
        diff_flag = 0
        diff_list = [netact_clist[i]]
        if netact_clist[i] in ni_clist:
            ni_row = ni_clist.index(netact_clist[i])
            for j in range(len(na_list)):
                if not case_sen_flag:
                    na_table.cell(i, na_list[j]).value = str(na_table.cell(i, na_list[j]).value).lower()
                    ni_table.cell(ni_row, ni_list[j]).value = str(ni_table.cell(ni_row, ni_list[j]).value).lower()
                if na_table.cell(i, na_list[j]).value != ni_table.cell(ni_row, ni_list[j]).value:
                    diff_flag, save_flag = 1, 1
                    diff_list.append(na_table.cell(i, na_list[j]).value)
                else:
                    diff_list.append('')
            if diff_flag:
                row = row + 1
                write_excel_row(sheet, row, diff_list)
        else:
            save_flag = 1
            row = row + 1
            write_excel_row(sheet, row, na_table.row_values(i))
    row = row + 3
    write_excel_row(sheet, row, ['NIDD Part'])
    for i in range(ni_srow + 1, len(ni_clist)):
        if ni_clist[i] in netact_clist:
            continue
        else:
            save_flag = 1
            row = row + 1
            write_excel_row(sheet, row, ni_table.row_values(i))
    if save_flag:
        wb.save(filename)
        raise RuntimeError('Excel compare failed, please see result in netact_oib_compare_result.xls')
    else:
        return 'Pass'


def get_valid_col_list(table, cname, map_list):
    row = table.nrows
    start_row = 0
    col_index = 0
    for r in range(row):
        if cname in table.row_values(r):
            start_row = r
            col_index = table.row_values(r).index(cname)
            map_list = [table.row_values(r).index(item) for item in map_list]
            break
    return start_row, col_index, map_list


def write_excel_row(sheet, row, data):
    for i in range(len(data)):
        sheet.write(row, i, data[i])
