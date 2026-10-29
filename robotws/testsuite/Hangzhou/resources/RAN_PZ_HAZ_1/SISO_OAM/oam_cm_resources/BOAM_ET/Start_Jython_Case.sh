#/bin/bash
case_name=$1
robot_file=$2
cd /home/ute/ValidationToolKit_21.12/NE3S_VTK/webservice/
LIB="/home/ute/ValidationToolKit_21.12/NE3S_VTK/lib"
CLASSPATH=''
for jar in ${LIB}/*.*; do
        CLASSPATH="$CLASSPATH:$jar"
done
set CLASSPATH
export CLASSPATH

/opt/ute/jython/bin/robot -L TRACE -d /home/ute/logs/ -t "${case_name}" ${robot_file}