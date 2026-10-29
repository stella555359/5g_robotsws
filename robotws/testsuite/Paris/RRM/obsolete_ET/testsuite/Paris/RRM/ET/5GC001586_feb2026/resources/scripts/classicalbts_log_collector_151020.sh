#!/usr/bin/env bash
#trap "" 6

# from https://confluence.int.net.nokia.com/display/~botang/%5BTool%5D+Collect+ASIK+and+ABIL+logs

readonly input_params="$@"
#readonly input_params_num="$#"
readonly script_path="$(readlink -f "$0")"
readonly script_dir="${script_path%/*}"
readonly date_time="$(date +%Y%m%d-%H%M%S)"
log_dir="log-${date_time}"
log_dir_set=0
dir_name_tmp="/ffs/run/logs/log_collector_${date_time}_tmp"
arg_help_flag=0
arg_compress_flag=0
dir_name=""
dir_name_full_path="$script_dir"
dir_name_exists=1

host_name=$(hostname)
host_type=${host_name:0:3}
host_id=${host_name##*-}
known_fsp_list=()
known_fct_list=()

#echo "host_type is ${host_type}"
#echo "host_id is ${host_id}"


print_help() {
cat <<EOF
#################################################################################################################
# Usage:                                                                                                        #
# Step 1. Upload classicalbts_log_collector.sh to a folder which is shared both for Master XEON and Slave XEON, #
#         e.g. /ffs/run/logs/, /rom, and /ffs/run/config/toor4nsn                                               #
# Step 2. SSH login Master Xeon. Change path to directory of classicalbts_log_collector.sh                      #
# Step 3. execute "chmod 755 classicalbts_log_collector.sh"                                                     #
# Step 4. run "./classicalbts_log_collector.sh -o [dir_name]" to collect logs.                                  #
#         [dir_name] could be a path under /ffs/run/logs or /tmp.                                               #
#         Command can be like following:                                                                        #
#             ./classicalbts_log_collector.sh -o ./                                                             #
#             ./classicalbts_log_collector.sh -o /tmp                                                           #
#             ./classicalbts_log_collector.sh -o /ffs/run/logs                                                  #
#         Besides, with '-z' option, logs will be made into txz package, e.g.                                   #
#             ./classicalbts_log_collector.sh -z -o ./                                                          #
#             ./classicalbts_log_collector.sh -o ./ -z                                                          #
# Step 5. find logs under [dirname]                                                                             #
#                                                                                                               #
# Notes:                                                                                                        #
# 1. Do NOT Collect Logs During GNB Upgrading!!!                                                                #
# 2. Do Remember To Delete Useless Log Files From FileSystem To Save Storage.                                   #
# 3. Do NOT select /ffs/run/config/ folder as output folder                                                     #
# 4. classicalbts_log_collector.sh should in UNIX EOL.                                                          #
#    EOL format could be changed with Notepad++, Edit->EOL Conversion->Unix(LF), then store.                    #
#                                                                                                               #
# Your ideas and comments are appreciated.                                                                      #
# https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=665759442                                   #
# Contact: bo.tang@nokia-sbell.com                                                                              #
#################################################################################################################
EOF
}

fetch_common_logs() {
    file_list=$(find /tmp/ -name "*startup*.log" -o -name "*startup*.log.xz" -o -name "*startup*.zip" -o -name "AppDef*.txt" -o -name "pmGeneration.log" -o -name "EmQueue.log*")
    for file in ${file_list[@]}; do
        cp -f --parents $file $1
    done
    journalctl -b > $1/journal.log
#	echo -e "file_list:\n$file_list"
}

fetch_on_xeon_master() {
    local output_dir=$1/$(hostname)
    mkdir -p $output_dir
    ls /ffs/run/TargetBD*.xml > $output_dir/release.txt
    cp -f --parents /tftpboot/slot*/devA/ystart.log $output_dir
    cp -f --parents /tftpboot/slot*/devA/zstart.log $output_dir
    cp -f --parents /tftpboot/slot*/devB/ystart.log $output_dir
    cp -f --parents /tftpboot/slot*/devB/zstart.log $output_dir
    cp -f --parents /tftpboot/slot*/devC/bootlog.msg $output_dir
    cp -f --parents /ffs/run/config/node_0xe000/config/* $output_dir
    cp -f --parents /ffs/run/swconfig.txt $output_dir
    cp -f --parents /ffs/run/cp_runtime.ini $output_dir
    cp -f --parents /ffs/run/logs/*_aasyslog $output_dir -r
    cp -f --parents /ffs/run/logs/system/sysRuntime $output_dir -r
    cp -f --parents /ffs/run/uri $output_dir -r
    cp -f --parents /ffs/run/config/*.xml $output_dir
    cp -f --parents /tmp/CounterAvailIndTrace*.* $output_dir
    cp -f --parents /tmp/LomMessageTrace*.* $output_dir
    cp -f --parents /tmp/VirtualNodeConfig*.xml $output_dir
    #cp -f --parents /var/tmp/aasysinfo $output_dir -r
    #cp -f --parents /var/tmp/node_0xe*/aasysinfo $output_dir -r
    cp -f --parents /ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf $output_dir
    cp -f --parents /rom/simmode/* $output_dir -r
    cp -f --parents /ffs/run/config/envdata/* $output_dir -r
    cp -f --parents /tmp/startup_l3* $output_dir
#    cp -f --parents /tmp/*startup* $output_dir
    cp -f --parents /rom/TargetBD*.xml* $output_dir
    cp -f --parents /var/log/* $output_dir -r

    journalctl -au airphone-dci-link-network-config.service > $1/journal_airphone-dci-link-network-config.log

    if [ -n "ls -A /ffs/run/swpool/OAM/admin-cli*zip" ] ; then
       if [ ! -e "/tmp/admin-cli/admin-cli.sh" ]; then unzip /ffs/run/swpool/OAM/admin-cli*zip -d /tmp/admin-cli; fi
       /bin/bash /tmp/admin-cli/admin-cli.sh --bts-username=Nemuadmin --bts-password=nemuuser --bts-host=192.168.255.129 --bts-port=443 --format='human' --data='{"requestId":1,"parameters":{"name":"generateScf"}}' --output-file $output_dir/SCF.xml
       echo ">> Done fetch scf file to ${output_dir}"
    fi

    fetch_common_logs $output_dir
    echo ">> Done fetch_on_xeon_master to ${output_dir}"
}

fetch_on_xeon_slave() {
    local output_dir=$1/$(hostname)
    mkdir -p $output_dir
    #cp -f --parents /var/tmp/aasysinfo $output_dir -r
    #cp -f --parents /var/tmp/node_0xe*/aasysinfo $output_dir -r

    fetch_common_logs $output_dir

#	echo -e "file_list:\n$file_list"
    echo ">> Done fetch_on_xeon_slave to ${output_dir}"
}

fetch_on_asp() {
    local output_dir=$1/$(hostname)
    mkdir -p $output_dir

    fetch_common_logs $output_dir
    if [ ${host_id:1:1} = 'c' ]; then		#FSP C
        cp -f --parents /tmp/*startup*.tgz $output_dir
        lococtl -tar /tmp/request
        cp -f --parents /tmp/request.tgz $output_dir
    fi

    echo ">> Done fetch_on_asp to ${output_dir}"
}

log_fetcher() {
    local output_dir=$1
    output_dir=${output_dir/#'/ffs/fs1'/'/ffs/run'}
    output_dir=${output_dir/#'/ffs/fs2'/'/ffs/run'}
    if [ ! -d $output_dir ]; then
        mkdir $output_dir -p
    fi

    #echo ">> log_fetcher/collecting logs to $output_dir from $(hostname)"
    if [ ${host_type} = 'fct' ] && [ ${host_id:1:1} = 'a' ]; then
        fetch_on_xeon_master $output_dir 2> /dev/null

        collecting_command=${script_path/#'/ffs/fs1'/'/ffs/run'}
        collecting_command=${collecting_command/#'/ffs/fs2'/'/ffs/run'}
        collecting_command="${collecting_command} -o $output_dir"

        for target_board in ${known_fct_list[@]}; do
            echo "--------------------------"
            echo ">> Start to collect logs from FCT board ${target_board} "
            ssh -o StrictHostKeyChecking=no -t -p 22 toor4nsn@${target_board} "${collecting_command}" 2> /dev/null
        done

        for target_board in ${known_fsp_list[@]}; do
            echo "--------------------------"
            echo ">> Start to collect logs from FSP board ${target_board} "
            ssh -o StrictHostKeyChecking=no -t -p 22 toor4nsn@${target_board} "${collecting_command}" 2> /dev/null
        done

    elif [ ${host_type} = 'fct' ] && [ ${host_id:1:1} = 'b' ]; then
        fetch_on_xeon_slave $output_dir 2> /dev/null
    elif [ ${host_type} = 'asp' ]; then
        fetch_on_asp $output_dir 2> /dev/null
    fi
}

get_dir_name_from_arguments() {
    dir_name=$1
	#echo "get_dir_name_from_arguments/ dir_name is ${dir_name}"
    if [ -z "$dir_name" ]; then						#there is no output directory after '-o' option, set script_dir as default
        dir_name_full_path="$dir_name_full_path/$log_dir"
        dir_name_exists=0
    elif [ ${dir_name:0:1} = "/" ]; then			#absolute directory path
        dir_name_full_path="$dir_name/$log_dir"
    else
        dir_name_full_path="$dir_name_full_path/$dir_name/$log_dir"
    fi
	dir_name_full_path=$(readlink -m ${dir_name_full_path})
	#echo "get_dir_name_from_arguments/ dir_name_full_path is ${dir_name_full_path}"
}

parse_arguments() {
    while [ -n "$1" ]; do
        arg=$1
        case $arg in
        --help)
            arg_help_flag=1        #if input arguments contain "--help", then only print HELP information and no longer parse other arguments
            break
        ;;
        -z)
            arg_compress_flag=1        #if input arguments contain "-z", then in compress mode.
        ;;
        -o)        #if input arguments contain "-o", then parse the next argument for output directory
            get_dir_name_from_arguments $2
            if [ $dir_name_exists = 1 ]; then
                shift
            fi
            log_dir_set=1
        ;;
        *)
            echo ">> Input argument '$1' could NOT be recognized. Please refer to '--help' option for usage."
            arg_help_flag=1    #if input argument is not supported, then only print HELP information.
            break
        ;;
        esac
        shift
    done

    #if input arguments contain "--help" or input unsupported argument, then only print HELP information.
    if [ $arg_help_flag = 1 ]; then
        return
    fi

    return
}

if [ ${host_type} = 'fct' ] && [ ${host_id:1:1} = 'a' ]; then

    if [ -n "$1" ]; then
        parse_arguments ${input_params};
        if [ $log_dir_set = 0 ]; then
            echo ">> No output dir set with '-o' option. Please refer to '--help' option for usage."
            arg_help_flag=1
        fi
    else
        echo ">> No input argument. Please refer to '--help' option for usage."
        arg_help_flag=1
    fi

    if [ $arg_help_flag = 1 ]; then
        print_help;
        exit 0;
    fi

#    echo ">> dir_name_full_path is $dir_name_full_path"
	if [ ${dir_name_full_path:0:16} = "/ffs/fs1/config/" ] || [ ${dir_name_full_path:0:16} = "/ffs/fs2/config/" ]; then
		echo ">> Log output dir is ${dir_name_full_path}"
		echo ">> Do NOT select /ffs/run/config/ folder as output folder. Please refer to '--help' option for usage."
		exit 0;
	fi

    known_fsp_list=$(arp -a | grep -e "etha" |grep -e "fsp" | grep -v incomplete | cut -d '(' -f2 |cut -d ')' -f1 | sort)
    known_fct_list=$(arp -a | grep -e "etha" |grep -e "fct" | grep -v incomplete | cut -d '(' -f2 |cut -d ')' -f1 | sort)
	echo -e ">> Active FSPs are:\n${known_fsp_list[@]}"
	echo -e ">> Active FCTs are:\n${known_fct_list[@]}"

	mkdir -p $dir_name_full_path
#    echo ">> Target directory $dir_name_full_path on $(hostname) is created to save logs"
    mkdir -p $dir_name_tmp
    echo ">> Temporary directory $dir_name_tmp on $(hostname) is created to save logs"
    log_fetcher $dir_name_tmp
#    rm $dir_name_full_path/* -rf
    mv $dir_name_tmp/* $dir_name_full_path -f  2> /dev/null
    rm $dir_name_tmp -rf
    echo "--------------------------"
    echo ">> Temporary directory $dir_name_tmp on $(hostname) is deleted"
    if [ $arg_compress_flag = "1" ]; then
        pushd ${dir_name_full_path} > /dev/null
            tarball_name="${dir_name_full_path##*/}.tar"
            tarball_name_full="${dir_name_full_path##*/}.txz"
            tar -cf ${tarball_name} * --remove-files
		    xz -zT0 -0 ${tarball_name}
		    mv "${tarball_name}.xz" ${tarball_name_full}
        popd > /dev/null
        echo ">> Logs are compressed to $dir_name_full_path/${tarball_name_full}"
    fi
    echo ">> Log Stored To $dir_name_full_path"
    echo ">> Log Collecting Finished!!!"
    echo ">> Do Remember To Delete Useless Log Files From FileSystem To Save Storage!!!"

elif [ ${host_type} = 'fct' ] && [ ${host_id:1:1} = 'b' ]; then
    if [ $1 = "-o" ] && [ -n "$2" ]; then
        log_fetcher $2
    fi
elif [ ${host_type} = 'asp' ]; then
    if [ $1 = "-o" ] && [ -n "$2" ]; then
        log_fetcher $2
    fi
else
    echo ">> Sorry. Log collecting on $(hostname) is not supported."
fi

exit 0;
