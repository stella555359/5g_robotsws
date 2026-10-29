import json
import os


def update_and_gen(fl1, integrity, cipher):
    cmd = (
        "ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|"
        "grep TargetBD_SBTS.*xml$|awk '{ print $9 }'|cut -d _ -f 2 >bte_rel"
    )
    os.system(cmd)
    sw_ver = ''
    rel_fp = open("bte_rel", "r")
    for line in rel_fp:
        sw_ver = line.strip()
    rel_fp.close()
    os.remove("bte_rel")
    fpath = fl1.rsplit('/', 2)[0]
    fpath = fpath+'/'+sw_ver+'/'+'delta_gen.json'
    with open(fl1, "r") as org_fp:
        data = json.load(org_fp)
    for para in data:
        for c_para in para['parameters']:
            if c_para['parameterName'] == "cipherPrefL":
                c_para['value'][0]['nea0'] = cipher['nea0']
                c_para['value'][0]['nea1_128'] = cipher['nea1_128']
                c_para['value'][0]['nea2_128'] = cipher['nea2_128']
                c_para['value'][0]['nea3_128'] = cipher['nea3_128']
            elif c_para['parameterName'] == "integrityProtPrefL":
                c_para['value'][0]['nia0'] = integrity['nia0']
                c_para['value'][0]['nia1_128'] = integrity['nia1_128']
                c_para['value'][0]['nia2_128'] = integrity['nia2_128']
                c_para['value'][0]['nia3_128'] = integrity['nia3_128']
    with open(fpath, "w") as newf:
        json.dump(data, newf, indent=4)
    with open(fpath, "r") as newf:
        data = json.load(newf)
    for para in data:
        for c_para in para['parameters']:
            if c_para['parameterName'] == "cipherPrefL":

                print(c_para['value'][0]['nea0'])
                print(c_para['value'][0]['nea1_128'])
                print(c_para['value'][0]['nea2_128'])
                print(c_para['value'][0]['nea3_128'])
            elif c_para['parameterName'] == "integrityProtPrefL":
                print(c_para['value'][0]['nia0'])
                print(c_para['value'][0]['nia1_128'])
                print(c_para['value'][0]['nia2_128'])
                print(c_para['value'][0]['nia3_128'])


def update_cfg(cfg_file, profile):
    flag = 0
    fpath = cfg_file.rsplit('/', 1)[0]
    new_cfg_file = fpath + '/' + 'basic_setup_gen.cfg'
    os.system("rm -rf basic_setup_gen.cfg")
    fp1 = open(cfg_file, "r")
    fp2 = open(new_cfg_file, "w")
    for line in fp1:
        if "set_ue simulated id" in line:
            for key in profile:
                flag = 0
                x = "set_ue simulated id=" + str(key)+" "
                if line.find(x) != -1:
                    tmp = line.split()
                    for pat in tmp:
                        if "nia" in pat:
                            nia = "nia="+profile[key]
                            s_pat = pat.strip()
                            mc_line = line.replace(s_pat, nia)
                            print("ins", mc_line)
                            fp2.write(mc_line)
                            flag = 1
                            break
                if flag == 1:
                    break
            if flag == 0:
                print(line)
                fp2.write(line)

        else:
            fp2.write(line)
    fp1.close()
    fp2.close()


def update_cfg1(cfg_file, profile):
    flag = 0
    fpath = cfg_file.rsplit('/', 1)[0]
    new_cfg_file = fpath + '/' + 'basic_setup_gen.cfg'
    os.system("rm -rf basic_setup_gen.cfg")
    fp1 = open(cfg_file, "r")
    fp2 = open(new_cfg_file, "w")
    for line in fp1:
        if "set_ue simulated id" in line:
            for key in profile:
                flag = 0
                x = "set_ue simulated id=" + str(key)+" "
                if line.find(x) != -1:
                    tmp = line.split()
                    for pat in tmp:
                        if "nia" in pat:
                            nia = "nia="+profile[key]
                            s_pat = pat.strip()
                            mc_line = line.replace(s_pat, nia)
                            print("ins", mc_line)
                            fp2.write(mc_line)
                            flag = 1
                            break
                if flag == 1:
                    break
            if flag == 0:
                print(line)
                fp2.write(line)

        else:
            fp2.write(line)
    fp1.close()
    fp2.close()


# prof={1:'aes',2:'zuc'}
# update_cfg("/home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008116/config/wts/basic_setup_2CC_tdd_ref.cfg",prof)
# fl1="/home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008116/config/SBTS22R4/basic_delta.json"
# ciph={
#             "nea0":"1",
#             "nea1_128":"0",
#             "nea2_128":"0",
#             "nea3_128":"0"
# }
#
# intgr={
#       "nia0":"1",
#       "nia1_128":"0",
#       "nia2_128":"0",
#       "nia3_128":"0"
#     }
#
# update_and_gen(fl1,intgr,ciph)
