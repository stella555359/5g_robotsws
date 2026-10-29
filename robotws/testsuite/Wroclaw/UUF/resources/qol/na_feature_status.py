path = '/home/ute/netact_console.txt'
tc = ''
netAct = {}

with open(path) as file_in:
    lines = []
    for line in file_in:
        lines.append(line)


def if_exist(key, dictionary):
    """
    Check if key exist in dictionary
    key: str
    dictionary: dict
    :return bool
    """
    if (dictionary[key]):
        print('%-13s:%s' % (key, dictionary[key]))
        return True
    else:
        return False


for line in lines:
    if "Test Case" in line:
        tc = line.split()[2]
        netAct[tc] = {'Test case': tc}
        netAct[tc]['TC status'] = 'ongoing'
        netAct[tc]['INFO:'] = False
        netAct[tc]['Source build'] = False
        netAct[tc]['Provision'] = False
        netAct[tc]['CM Provision'] = False
        netAct[tc]['Rollback'] = False
        netAct[tc]['Fallback'] = False
    if tc:
        if "IS ALREADY IMPORTED" in line:
            netAct[tc]['Source build'] = line.split()[1]
    if "SWM Provision" in line:
        netAct[tc]['Provision'] = line.split()[4].replace('.', '')
    # if "Link to logs" in line:
    #     netAct[tc]['Link to logs'] = line.split()[4]
    if "CM PROVISION" in line:
        netAct[tc]['CM Provision'] = line.split()[3].replace('.', '')
    if "SWM Rollback" in line:
        netAct[tc]['Rollback'] = line.split()[4].replace('.', '')
    if "Setting up admin on alias: cancel_fallback" in line:
        netAct[tc]['Fallback'] = 'PASSED'
    if "| PASS |" in line:
        netAct[tc]['TC status'] = 'PASSED'
    if "| FAIL |" in line:
        netAct[tc]['TC status'] = 'FAILED'
    if "The last error was:" in line:
        netAct[tc]['INFO:'] = line

for index in netAct:
    print('=' * 45)
    if_exist('Test case', netAct[index])
    if_exist('Source build', netAct[index])
    if_exist('Provision', netAct[index])
    if_exist('CM Provision', netAct[index])
    if_exist('Rollback', netAct[index])
    if_exist('Fallback', netAct[index])
    if_exist('INFO:', netAct[index])
    if_exist('TC status', netAct[index])
    print('=' * 45)
