# !/bin/bash

#Check current session
./fcmd 127.0.0.1:40001 gm |grep "'" > result.txt

if [ -s result.txt ]; then
  echo ""******Need delete existed data sessions"******"
  num=`cat result.txt |grep "'"|wc -l`
  echo Existed data sessions num is $num

  for((i=1;i<="$num";i++));
  do
    echo $i
    oldsession=`awk 'NR=='$i'{print}' result.txt|sed "s/'//g"`
    echo $oldsession
    
    #Delete session
    ./fcmd 127.0.0.1:40001 dm $oldsession
  done

  #Check whether deletion is finished
  CheckRet=$(./fcmd 127.0.0.1:40001 gm |grep "'")
  echo $CheckRet
  if [ -z "$CheckRet" ]; then
     echo "******Data Session deletion succesffly.*******"
  else
     echo "******Data Session deletion failed.*******"
  fi
  
fi

#Create new session
case $1 in
   A001)
      echo "*******Start create A001 new session******"
      Ret=$(./fcmd 127.0.0.1:40001 cm n=TA_A001_S p=AutoProvider d=DataCollector\@$2 m=[f5c:@zmq_5gfilter.txt][su:GIVAXI-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   A002)
      echo "*******Start create A002 new session******"
      Ret=$(./fcmd 127.0.0.1:40001 cm n=TA_A002_S p=AutoProvider d=DataCollector\@$2 m=[f5c:@5gfilter.txt][su:GIVAXI-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   A004)
      echo ""******Start create A004 new Data session"******"
      Ret=$(./fcmd 127.0.0.1:40001 cm n=TA_A004_S  p=AutoProvider d=DataCollector\@$2 \
m=[f5s:@syscom_filter.txt][sh:CPRT00,CPNRT00,CPNB00,CPCL00][gnb:gNB5G][f:0000] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   A005)
      echo "*******Start create A005 new session******"
      Ret=$(./fcmd 127.0.0.1:40001 cm n=TA_A005_S p=AutoProvider d=DataCollector\@$2 m=[f5c:@null_5gfilter.txt][su:GIVAXI-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   C006)
      echo ""******Start create C006 new session"******"
      Ret=$(./fcmd 127.0.0.1:40001 cm n=TA_C006_S  p=AutoProvider d=DataCollector\@$2 \
m=[f5s:@syscom_filter.txt][sh:CPRT00,CPNRT00,CPNB00,CPCL00][gnb:gNB5G][f:0000] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   *)
      echo "Ignorant"
      ;;
 esac

if [ ! -z "$Ret" ]; then
  echo "******Data Session created successfully.*******"
 else
  echo "******Data Session creation failed.******"
fi

