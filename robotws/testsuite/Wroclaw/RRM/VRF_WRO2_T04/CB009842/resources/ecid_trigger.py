import argparse
from taf.transport.ssh import ssh
from robot.api import logger

client_ssh = ssh()


def perform_database_modification(ssh_client, container_name, command):
    db_user = 'root'
    db_pass = 'nls72@NSN'
    cmd = f'kubectl exec -i {container_name} -c nls-database -- mysql -u{db_user} -p{db_pass} -Dnls72 -e "{command}"'
    return ssh_client.execute(cmd)


def set_measurement_quantities(quantity, characteristics='OnDemand'):
    print('Setting NRPPA.MeasurementQuantities to :', quantity)

    hname = "10.27.227.254"   # LMF NALA
    uname = 'root'
    upass = 'nls72NSN'
    cmd0 = "kubectl get pods | grep nls-database"
    cmd3 = f"update OMCconfigParameter set LastValue=CurrValue,CurrValue='{quantity}',DisplayValue='{quantity}'," \
           f"updateFlag=1 " \
           f"Where paraName='NRPPA.MeasurementQuantities' and hostName='ALL_HOST' and processType='NRPPA';\n"
    cmd4 = "update OMCconfigSync set UPDATEFLAG=UPDATEFLAG+1, hostName='ALL_HOST',processType='NRPPA'," \
           "syncflag=0 Where hostname <> 'BMS_PARA';\n"
    cmd5 = "commit;\n"
    cmd6 = f"update OMCconfigParameter set LastValue=CurrValue,CurrValue='{characteristics}'," \
           f"DisplayValue='{characteristics}'," \
           f"updateFlag=1 " \
           f"Where paraName='NRPPA.ReportCharacteristics' and hostName='ALL_HOST' and processType='NRPPA';\n"

    client_ssh.connect_to(hname, uname, upass)
    output = client_ssh.execute(cmd0, timeout=40)
    print(output)
    db_name = output.split(' ')[0]
    print(db_name)

    output = perform_database_modification(client_ssh, db_name, cmd3)
    print(output)
    output = perform_database_modification(client_ssh, db_name, cmd4)
    print(output)
    output = perform_database_modification(client_ssh, db_name, cmd6)
    print(output)
    output = perform_database_modification(client_ssh, db_name, cmd5)
    print(output)
    client_ssh.disconnect()


def set_imsi(imsi):
    print('Triggering imsi :', imsi)

    hname = "10.27.227.254"
    uname = "root"
    upass = "nls72NSN"

    cmd2 = "curl -v http://10.27.227.254:9210 -d@/root/ks_test/" + imsi + ".xml\n"

    client_ssh.connect_to(hname, uname, upass)
    output = client_ssh.execute(cmd2, timeout=40)
    print('Response for imsi trigger :', output)
    client_ssh.disconnect()


def ecid_trigger(imsi, meas_quantities, report_characteristics='OnDemand'):
    logger.info("\n Sending E-CID with measurementQuantities: {}\n".format(meas_quantities), also_console=True)
    set_imsi(imsi)
    set_measurement_quantities(meas_quantities, report_characteristics)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='python trigger.py -i <imsi> -m <measurementQuantities>')
    parser.add_argument('-i', '--imsi', help='Imsi', type=str, required=True)
    parser.add_argument('-m', '--measurement-quantities', help='Measurement quantities', type=str, required=True)
    parser.add_argument('-c', '--report-characteristics', help='Report Characteristics', type=str, required=True)

    args = parser.parse_args()
    print(args)
    ecid_trigger(args.imsi, args.measurement_quantities, args.report_characteristics)
