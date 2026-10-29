#!/bin/bash -x

name={name}

for i in "$@"; do
  case $i in
    -n=*)
      name="${i#*=}"
      shift # past argument=value
      ;;
    -i=*)
      interfaces_in="${i#*=}"
      shift # past argument=value
      ;;
    -x=*)
      iphyxml="${i#*=}"
      shift # past argument=value
      ;;
    -*|--*)
      echo "-i=<interfaces> interfaces on which the container will be mapped (separated with ',')"
      echo "-n=<name>      name or number of the docker to launch (multi docker)"
      echo "-x=<phy.xml path>      path to the iphy.xml file (optional, if not present, default file will be used)"
      exit 1
      ;;
    *)
      image=$i
      shift
      ;;
  esac
done

if [ X$image = X ]; then
    image=airphone-docker-local.artifactory-espoo1.int.net.nokia.com/rp1sim:v1.0.0
fi

if [ -z $interfaces_in ]; then
    echo "Command line usage : start.sh -i=<interface[,interface]> [-x=<iphy.xml>] image"
fi

IFS=\, read -a interfaces <<<"$interfaces_in"
net="docker${interfaces[0]}"

for interface in ${interfaces[@]}; do
    sudo docker network create --opt com.docker.network.bridge.name=docker$interface docker$interface
done

if [ -n "$iphyxml" ]; then
    v="--volume=$iphyxml:/rom/simmode/iphy.xml"
fi

cid=`sudo docker run \
--rm \
--detach \
--privileged \
--volume=/home/ute/rusim:/etc/rusim $v \
--network=$net \
--name=$name \
$image`

for interface in ${interfaces[@]}; do
    sudo docker network connect docker$interface $name
    sudo ip link set dev $interface master docker$interface
done

sudo docker exec -it $name /bin/bash
sudo docker kill $name

for interface in ${interfaces[@]}; do
    sudo docker network rm docker$interface
done
