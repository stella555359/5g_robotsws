#!/bin/bash -x

for i in "$@"; do
  case $i in
    -n=*)
      N="${i#*=}"
      shift # past argument=value
      ;;
    -i=*)
      interface="${i#*=}"
      shift # past argument=value
      ;;
    -*|--*)
      echo "-i=<interface> interface on which the container will be mapped"
      echo "-N=<name>      name or number of the docker to launch (multi docker)"
      exit 1
      ;;
    *)
      image=$i
      shift
      ;;
  esac
done

sudo docker kill orusim$N

if [ X$image = X ]; then
    image=http://artifactory-espoo1.int.net.nokia.com/artifactory/webapp/#/artifacts/browse/simple/General/airphone-docker-local/orusim/v2.0.8
    image=airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v1.21.10
    image=airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v1.22.2-1-ga0308b2
    image=airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v1.22.2
    image=airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v1.22.0
    image=airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-UE_APP-ORUSIM-0.42
fi

if [ -n "$N" ]; then
    docker network create --opt com.docker.network.bridge.name=docker$N docker$N
    net=docker$N
else
    net=bridge
fi

cid=`sudo docker run \
--rm \
--detach \
--privileged \
--volume=/home/ute/orusimBT5:/etc/orusimBT5 \
--volume=/home/ute/orusimBT5/Scripts/supervisord.conf:/etc/supervisor/supervisord.conf \
--network=$net \
--name=orusim$N \
$image`

if [ -n "$interface" ]; then
    sudo ip link set dev $interface master docker${N:-0}
fi

#instanceid=$(sudo docker ps | grep orusim3 | awk '{print $1}')
instanceid=$(sudo docker ps -aqf "name=orusim3")
sudo docker cp /home/ute/orusimBT5/Scripts/fjt_4T4R_FDD_n1.xml $instanceid:/opt/dev/xml/snapshots/
sudo docker cp /home/ute/orusimBT5/Scripts/orusim-config.xml $instanceid:/tmp/orusim-config.xml
sudo docker exec -it orusim$N /bin/bash


#sudo docker kill orusim$N
