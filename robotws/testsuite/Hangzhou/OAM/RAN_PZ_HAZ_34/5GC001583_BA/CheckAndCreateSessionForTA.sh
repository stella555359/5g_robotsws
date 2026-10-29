# !/bin/bash

#Delete monitoring session
deletesession() {
  echo $1
  ./fcmd $1 gm |grep "'" > result.txt

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
	  echo "./fcmd $1 dm $oldsession"
      ./fcmd $1 dm $oldsession
    done

    #Check whether deletion is finished
    CheckRet=$(./fcmd $1 gm |grep "'")
    if [ -z "$CheckRet" ]; then
       echo "******Data Session deletion succesffly.*******"
    else
       echo "******Session $CheckRet deletion failed.*******"
    fi
  fi
}

#Delete Provider controller if exists
deleteprovider(){
  provider=$(./fcmd $1 gp |grep "'")
  if [ -z "$provider" ]; then
      echo "******No Provider Controller*******"
  else
      oldprovider=$(echo $provider |sed 's/ //g' |sed "s/^'//g" |sed "s/'$//g")
      ./fcmd $1 dp $oldprovider >> session.log
  fi

  #Check whether deletion is finished
  CheckRet=$(./fcmd $1 gp |grep "'")
  if [ -z "$CheckRet" ]; then
     echo "******Provider Controller deletion succesffly.*******"
  else
     echo "******Provider $CheckRet deletion failed.*******"
  fi
}

#Delete Data Collector if exists
deletecollector(){
  collector=$(./fcmd $1 gd |grep "'")
  if [ -z "$collector" ]; then
      echo "******No Data Collector*******"
  else
      oldcollector=$(echo $collector |sed 's/ //g' |cut -d'(' -f1 |sed "s/^'//g" |sed "s/'$//g")
      ./fcmd $1 dd $oldcollector >> session.log
  fi

  #Check whether deletion is finished
  CheckRet=$(./fcmd $1 gd |grep "'")
  if [ -z "$CheckRet" ]; then
     echo "******Data Collector deletion succesffly.*******"
  else
     echo "******Collector $CheckRet deletion failed.*******"
  fi
}

#Create new session
case $1 in
   A001)
      echo $5
      deletesession $5
      deletecollector $5
      deleteprovider $5
      echo ""******Start create A001 new Provider Controller"******"
      Ret_cs=$(./fcmd $5 cp gNB_provider $3|grep "success")
      if [ ! -z "$Ret_cs" ]; then
        echo "******gNB_provider created successfully.*******"
        echo "./fcmd $5 cp gNB_provider $3"
      else
        echo "******gNB_provider creation failed.******"
        echo "Resons:$Ret_cs"
      fi

      echo ""******Start create A001 new Data Collector"******"
      Ret_cs=$(./fcmd $5 cd gNB_datacollector $4|grep "success")
      if [ ! -z "$Ret_cs" ]; then
        echo "******gNB_datacollector created successfully.*******"
        echo "./fcmd $5 cd gNB_datacollector $4"
      else
        echo "******gNB_datacollector creation failed.******"
        echo "Resons:$Ret_cs"
      fi

      echo ""******Start create A001 new Data session"******"
      echo "./fcmd $5 cm n=BananaSession p=gNB_provider d=gNB_datacollector@$2 \
m=[f5c:@ext/config/TraceFilter.txt][su:GIVAXI-0][gnb:gNB5G] m=[f5s:@ext/config/TraceFilter.txt][sh:CPRT-0,CPNRT-0,CPNB-0,CPCL-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1] pl=[n:emilforwarder][c:@ext/config/_emilforwarder.conf][s:1]"
      Ret=$(./fcmd $5 cm n=BananaSession p=gNB_provider d=gNB_datacollector@$2 \
m=[f5c:@ext/config/TraceFilter.txt][su:GIVAXI-0][gnb:gNB5G] m=[f5s:@ext/config/TraceFilter.txt][sh:CPRT-0,CPNRT-0,CPNB-0,CPCL-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1] pl=[n:emilforwarder][c:@ext/config/_emilforwarder.conf][s:1]|grep "success")
      #echo "===$?"
      ;;
   A002)
      echo "*******Start create A001 new session******"
      echo "./fcmd $5 cm n=TA_A001_S p=gNB_1 d=gNB_datacollector\@$2 m=[f5c:@5gfilter.txt][su:GIVAXI-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]"
      Ret=$(./fcmd $5 cm n=TA_A001_S p=gNB_1 d=gNB_datacollector\@$2 m=[f5c:@5gfilter.txt][su:GIVAXI-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   A003)
      echo "*******Start create A005 new session******"
      Ret=$(./fcmd $5 cm n=TA_A005_S p=gNB_1 d=DataCollector\@$2 m=[f5c:@5gfilter.txt][su:GIVAXI-0][gnb:gNB5G] \
pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   C006)
      echo ""******Start create C006 new session"******"
      Ret=$(./fcmd $5 cm n=TA_C006_S  p=gNB_1 d=DataCollector\@$2 \
m=[f5s:@TraceFilter.txt][sh:CPRT-0,CPNRT-0,CPNB-0,CPCL-0][gnb:gNB5G] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]|grep "success")
      ;;
   *)
      echo "Ignorant"
      ;;
 esac


if [ ! -z "$Ret" ]; then
  echo "******Data Session created successfully.*******"
 else
  echo "******Data Session creation failed.******"
  echo $Ret
fi


