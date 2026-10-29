!/bin/bash

#just replace 24R2 with latest Trunk Build after branch off
#date=`date`
#execution_date="${date// /_}"
#build=`grep "Active SW version" trace.txt | tail -1 | cut -b 23- | tr -d '"' | tr -d ',' | sed -e 's/24R2/00/g' `;



#export http_proxy="http://10.158.100.6:8080"
#export https_proxy="http://10.158.100.6:8080"
#export ftp_proxy="http://10.158.100.6:8080"


robot -L trace -b trace.txt -v  bts_id:1 CB007351_verification_of_RSA_certificate_installation_automatically.robot


sleep 20

#/opt/ute/python3/bin/ute_reporting_portal send -p UTE -l label -l Local -ro output.xml -ca TRSSIV -tl TRSIV-TL0001 --sw_version $build -qc update.qc -v
python3  ~/log_upload_client.py "ute_reporting_portal send -l label -p UTE -ro output.xml -ca E2ET_BTSTRSPZ -tl 1_2_UTE4GT0101ASIM03 --sw_version SBTS00_ENB_9999_250719_000017 -qc CB007351_verification_of_RSA_certificate_installation_automatically.qc"

#sleep  50

#robot -L trace -b trace.txt -v  bts_id:1 CB007351_Verification_of_automatic_configured_Valid_RSA_certificates_are_taken_after_SW_roll-back.robot

#sleep 20

##/opt/ute/python3/bin/ute_reporting_portal send -p UTE -l label -l Local -ro output.xml -ca TRSSIV -tl TRSIV-TL0001 --sw_version $build -qc update.qc -v

#sleep  50

#robot -L trace -b trace.txt -v  bts_id:1 CB007351_verification_of_ECDSA_certificate_installation_automatically.robot

#sleep 20



#cd /home/ute/fw_user_path/testcases/Alarms_EDA_Aditya/

#sh batch_adi.sh
