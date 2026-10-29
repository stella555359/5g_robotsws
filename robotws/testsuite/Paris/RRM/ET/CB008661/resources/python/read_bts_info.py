import sys


def read_bts_info(bts_info):
    # print(bts_info)
    print('type of bts_info variable = %s' % type(bts_info))
    # print(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: keys btsInfo')
    btsInfoSummary = ':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: GNB_BTS_INFO keys'
    for i in bts_info:
        # print("key bts Info = %s" % (i))
        btsInfoSummary += '\n'
        btsInfoSummary += 'key value = ' + i
    # print(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: systemModules info')
    btsInfoSummary += '\n'
    btsInfoSummary += ':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: systemModules info'
    system_modules = bts_info['systemModules']
    for systemModules_info in system_modules:
        for key in systemModules_info:
            if key in ['productName', 'productCode', 'positionInSubrack', 'serialNumber']:
                # print("%s = %s" % (key, systemModules_info[key]))
                btsInfoSummary += '\n'
                btsInfoSummary += key + ' = ' + systemModules_info[key]
    # print(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: basebandModules info')
    btsInfoSummary += '\n'
    btsInfoSummary += ':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: basebandModules info'
    basebandModules = bts_info['basebandModules']
    for basebandModules_info in basebandModules:
        for key in basebandModules_info:
            if key in ['productName', 'productCode', 'fullCapacityInUse', 'serialNumber']:
                # print("%s = %s" % (key, basebandModules_info[key]))
                btsInfoSummary += '\n'
                btsInfoSummary += key + ' = ' + basebandModules_info[key]
    return btsInfoSummary


if __name__ == '__main__':
    read_bts_info(sys.argv[1])
