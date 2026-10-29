NEO2219 = dict(
    API_CLIENT_ID="NOM_NEO2219_OPEN_CLIENT",
    API_USERNAME="neonetics",
    API_PASSWORD="Nokia_150",
    API_GW="https://neo2219.dyn.nesc.nokia.net",
    BASE_DOMAIN="https://neo2219.dyn.nesc.nokia.net",
    VIP="100.74.44.166",
)

NEO8256 = dict(
    API_CLIENT_ID="NOM_NEO8256_OPEN_CLIENT",
    API_USERNAME="neonetics",
    API_PASSWORD="Nokia123_",
    API_GW="https://neo8256.dyn.nesc.nokia.net",
    BASE_DOMAIN="https://neo8256.dyn.nesc.nokia.net",
    VIP="100.74.44.110",
)

nom = {"NOM_NEO2219": NEO2219, "NOM_NEO8256": NEO8256}


def get_variables(ip_address):
    if ip_address:
        for nom_key in nom:
            if nom[nom_key]["VIP"] == ip_address:
                return {"DICT__NOM": nom[nom_key]}
