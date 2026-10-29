from robot.api import logger

from ta_messaging.message_verifiers import message_verifier


@message_verifier
def plmn_list_not_contains_24410_24412(msg):
    plmn_list = msg.get_value_by_unique_key('plmn-IdentityList')
    print(plmn_list)
    count = 0
    for plmn in plmn_list:
        mcc = ''.join(str(x) for x in plmn['plmn-Identity']['mcc'])
        mnc = ''.join(str(x) for x in plmn['plmn-Identity']['mnc'])
        if mcc == '244' and (mnc == '10' or mnc == '12'):
            count += 1
    return count == 0


@message_verifier
def plmn_list_contains_24410_24412(msg):
    plmn_list = msg.get_value_by_unique_key('plmn-IdentityList')
    print(plmn_list)
    count = 0
    for plmn in plmn_list:
        mcc = ''.join(str(x) for x in plmn['plmn-Identity']['mcc'])
        mnc = ''.join(str(x) for x in plmn['plmn-Identity']['mnc'])
        if mcc == '244' and (mnc == '10' or mnc == '12'):
            count += 1
    return count == 2
