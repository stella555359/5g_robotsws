from taf.config.scf.scf_operations import SCFOperations
import re


scf_opr = SCFOperations()


def modify_data(file_path=None, to_modify=None):
    if to_modify is None:
        return
    if file_path is None:
        raise Exception("imporper inputs - file_path :{}, params to modify:{}".format(file_path, to_modify))
    try:
        scf_opr.load_scf(file_path)
        mod = []
        print(to_modify)
        for mo, entry in to_modify.items():
            if '|' in mo:
                mo_ref = mo.split('|')
                mod.append('modify:'+mo_ref[0]+'='+str(entry)+'|'+mo_ref[1])
            else:
                mod.append('modify:'+mo+'='+str(entry))
        print("in here")
        print(mod)
        scf_opr.perform_scf_modification(mod)
        scf_opr.save_scf(file_path)
    except Exception as e:
        print("Skipped Modify due to error - {}".format(e))


def delete_data(file_path=None, to_delete=None):
    if to_delete is None:
        return
    if file_path is None:
        raise Exception("imporper inputs - file_path :{}, params to delete:{}".format(file_path, to_delete))
    try:
        scf_opr.load_scf(file_path)
        delete = []
        for mo, entry in to_delete.items():
            if entry == '':
                delete.append('delete:'+mo)

            elif isinstance(entry, list):
                for data in entry:
                    if '{}|' in data:
                        delete.append('delete:'+mo+':'+data)
        print(delete)
        scf_opr.perform_scf_modification(delete)
        scf_opr.save_scf(file_path)
    except Exception as e:
        print("Skipped delete due to error - {}".format(e))


def add_data(file_path=None, to_add=None):
    if to_add is None:
        return
    if file_path is None or to_add is None:
        raise Exception("imporper inputs - file_path :{}, params to add:{}".format(file_path, to_add))
    try:
        add = []
        scf_opr.load_scf(file_path)
        for mo, entry in to_add.items():
            # print(mo, entry)
            mo_data = mo.split(':')
            print("mod_data is {}".format(mo_data[-1]))
            if mo_data[-1] == 'l' and entry is not None:
                mo = ":".join(mo_data[:-1])
                add.append('add:'+mo+':'+str(entry))
            elif mo_data[-1] == 'l' and entry is None:
                add.append('add:'+":".join(mo_data[:-1]))
            elif mo_data[-1] == 'd':
                add.append('add:'+":".join(mo_data[:-1])+':'+entry)
            elif mo_data[-1] == '':
                add.append('add:'+mo+':'+str(entry))
            elif isinstance(entry, dict):
                if 'class' in entry:
                    # com.nokia.srbts.nrbts:NRREL, MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1, NRBTSCL22R4_2213_100, create
                    add.append('add:['+entry['class']+', '+mo+', '+entry['version'] + ', create]')
            elif entry == '':
                add.append('add:'+mo)
            else:
                add.append('add:'+mo+'='+str(entry))
        scf_opr.perform_scf_modification(add)
        scf_opr.save_scf(file_path)
    except Exception as e:
        print("Skipped due to error - {}".format(e))
