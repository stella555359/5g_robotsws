from taf.sbts.oam.coam.admin import admin
coam = admin()


def GetRusUnderAbil(abil_index, conn):
    bts_info = coam.get_bts_info(connection=conn)
    cables = bts_info['cables']
    bbmod_name = 'BBMOD-'+str(abil_index)
    rmods = []
    for i in range(len(cables)):
        bbmod = cables[i]['firstEndPointId']['configuration'].split("/")[-2]
        rmod = cables[i]['secondEndPointId']['configuration'].split("/")[-2]
        if bbmod == bbmod_name and rmod not in rmods:
            rmods.append(rmod)
    for i in range(len(rmods)):
        rmods[i] = rmods[i].replace("RMOD-", "")
    return rmods


def AddListitemToList(listfrom, listto):
    for item in listfrom:
        listto.append(item)
    return listto
