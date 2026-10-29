import json


def read_json(file):
    dist_obj = {}
    with open(file) as json_file:
        data = json.load(json_file)
        print(data)
        for item in data:
            # print(item['distName'])
            tmp = {}
            dist_obj[item['distName']] = {}
            # print(item['operation'])
            # print(item['parameters'])
            for para in item['parameters']:
                if para['operation'] != 'delete':
                    tmp[para['parameterName']] = para['value']

            dist_obj[item['distName']] = tmp
            # break
    return data, dist_obj


def get_value(moc, key):
    lst = []
    items = moc[key]
    for item in items:
        print("---->", item)
        tmp_dict = {}
        tmp_dict[item] = items[item]
        lst.append(tmp_dict)
        print(lst)
    return lst


def chk_value(val, operation):
    nw_val = {}
    delim = '/'
    istdd = 1
    for p_key in val:
        if isinstance(val[p_key], list) and isinstance(val[p_key][0], dict):

            n_key = delim + p_key + delim + str(0) + delim
            print(n_key)
            if operation == 'create':
                nw_val[delim + p_key] = ''
            for x in val[p_key]:
                for c_key in x:
                    tmp_key = n_key
                    tmp_key += c_key
                    print(tmp_key, "==>", x[c_key])
                    nw_val[tmp_key] = x[c_key]
                    if x[c_key] == "semiStatic":
                        istdd = 0
            print(nw_val)
            return nw_val, istdd
        else:
            print(isinstance(val[p_key], list), isinstance(val[p_key], list))
            if operation == 'create':
                nw_val[delim + p_key] = ''
            if isinstance(val[p_key], list):

                for p_key in val:
                    nw_val[delim+p_key+delim + '0'] = val[p_key][0]
                    return nw_val, istdd
            else:
                return val, istdd


def make_paras_cu(file):
    lst = []
    dl = '/'
    x, y = read_json(file)

    dist_obj = {}
    for item in x:
        tmp = {}
        distName = item['distName']
        operation = item['operation']
        paras = y[distName]
        t_tmp = {}

        dist_obj[distName] = []
        # print(distName,'===>',operation,'====>',paras)
        for key in paras:
            tmp['operation_type'] = operation
            t_tmp['parameter_path'] = dl + key
            # print(isinstance(paras[key],list),"-->",paras[key])
            if isinstance(paras[key], list) and \
                    isinstance(paras[key][0], dict):
                if operation == 'create':
                    tmp['parameter_path'] = dl + key
                    tmp['operation_type'] = operation
                    dist_obj[distName].append(tmp)
                    tmp = {}
                for c_item in paras[key]:
                    for c_key in c_item:
                        tmp['operation_type'] = operation
                        # print(c_key,"===",c_item)
                        tmp['parameter_path'] = \
                            t_tmp['parameter_path'] + dl + '0' + dl + c_key
                        # print(tmp['parameter_path'])
                        tmp['value'] = c_item[c_key]
                        # lst.append(tmp)
                        dist_obj[distName].append(tmp)
                        tmp = {}
            elif isinstance(paras[key], list):
                if operation == 'create':
                    tmp['parameter_path'] = dl + key
                    tmp['operation_type'] = operation
                    dist_obj[distName].append(tmp)
                    tmp = {}
                    for item in paras[key]:
                        tmp['operation_type'] = operation
                        tmp['parameter_path'] = dl + key + dl + '0'
                        tmp['value'] = item
                        dist_obj[distName].append(tmp)
                        tmp = {}

            else:
                tmp['parameter_path'] = t_tmp['parameter_path']
                tmp['value'] = paras[key]
                # lst.append(tmp)
                dist_obj[distName].append(tmp)
                tmp = {}
    return dist_obj
