#!/bin/bash

################ WTS TESTLINE INFO COLLECTION SCRIPT ################
#
SILENT_MODE="OFF"
FILENAME="testline_info.log"

if [ -n "$1" ]; then
	if [ "$1" == "-help" ] || [ "$1" == "-h" ]; then
		echo "Usage:"
		echo "./get_testline_info.sh [PARAMS]"
		echo "PARAMS:"
		echo "   <filename>	- specify filename of generated log file"
		echo "   -s 		- don't print results in terminal"
		exit
	elif [ "$1" == "-silent" ] || [ "$1" == "-s" ]; then
		SILENT_MODE="ON"
	else
		FILENAME="$1"
	fi
fi

if [ -n "$2" ]; then
	if [ "$2" == "-silent" ] || [ "$2" == "-s" ]; then
		SILENT_MODE="ON"
	else
		FILENAME="$2"
	fi
fi


##### Below are the current minimum recommended specifications. #####
REC_KERNEL=3.18.27
REC_GLIBC=2.12.2
REC_BINUTILS=2.26
##### Distribution Name and Version #####
# Debian
REC_DISTRIBUTION_NAME[0]='Debian'
REC_DISTRIBUTION_VERSION[0]=7
# CentOS
REC_DISTRIBUTION_NAME[1]='CentOS'
REC_DISTRIBUTION_VERSION[1]=6.7
# RHEL
REC_DISTRIBUTION_NAME[2]='RHEL'
REC_DISTRIBUTION_VERSION[2]=6.7

##### Number of Cores #####
REC_NUM_CORES=4

##### CPU Cache #####
REC_CPU_CACHE=12288 #12MB

##### CPU Types and required flags #####
# Core 2
REC_CPU_TYPE_CORE2='Core 2'
REC_CPU_TYPE_CORE2_FLAGS=("mmx" "sse" "sse2" "sse3" "ssse3")
# Sandy Bridge
REC_CPU_TYPE_SANDY='Sandy Bridge'
REC_CPU_TYPE_SANDY_FLAGS=("sse4_1" "sse4_2" "popcnt" "avx" "aes" "pclmul") #unique flags in sandy bridge

##### RAM #####
REC_RAM_SIZE=12288 #12GB

##### sysctl #####
REC_SYSCTL_VARIABLE[0]="net.core.rmem_default"
REC_SYSCTL_VARIABLE_VALUE[0]="1048576"

REC_SYSCTL_VARIABLE[1]="net.core.rmem_max"
REC_SYSCTL_VARIABLE_VALUE[1]="26214400"

REC_SYSCTL_VARIABLE[2]="net.core.wmem_default"
REC_SYSCTL_VARIABLE_VALUE[2]="1048576"

REC_SYSCTL_VARIABLE[3]="net.core.wmem_max"
REC_SYSCTL_VARIABLE_VALUE[3]="26214400"

REC_SYSCTL_VARIABLE[4]="net.ipv4.tcp_mem"
REC_SYSCTL_VARIABLE_VALUE[4]="2033920  8388608 12582912"

REC_SYSCTL_VARIABLE[5]="net.ipv4.tcp_rmem"
REC_SYSCTL_VARIABLE_VALUE[5]="10240   87380   12582912"

REC_SYSCTL_VARIABLE[6]="net.ipv4.tcp_wmem"
REC_SYSCTL_VARIABLE_VALUE[6]="10240   87380   12582912"

REC_SYSCTL_VARIABLE[7]="net.ipv4.udp_mem"
REC_SYSCTL_VARIABLE_VALUE[7]="1048576  12582912    26214400"

REC_SYSCTL_VARIABLE[8]="net.ipv4.udp_rmem_min"
REC_SYSCTL_VARIABLE_VALUE[8]="1048576"

REC_SYSCTL_VARIABLE[9]="net.ipv4.udp_wmem_min"
REC_SYSCTL_VARIABLE_VALUE[9]="1048576"

REC_SYSCTL_VARIABLE[10]="net.core.netdev_max_backlog"
REC_SYSCTL_VARIABLE_VALUE[10]="5000"

REC_SYSCTL_VARIABLE[11]="net.ipv4.neigh.default.gc_thresh1"
REC_SYSCTL_VARIABLE_VALUE[11]="1024"

REC_SYSCTL_VARIABLE[12]="net.ipv4.neigh.default.gc_thresh2"
REC_SYSCTL_VARIABLE_VALUE[12]="4096"

REC_SYSCTL_VARIABLE[13]="net.ipv4.neigh.default.gc_thresh3"
REC_SYSCTL_VARIABLE_VALUE[13]="8192"

REC_SYSCTL_VARIABLE[14]="net.ipv6.neigh.default.gc_thresh1"
REC_SYSCTL_VARIABLE_VALUE[14]="1024"

REC_SYSCTL_VARIABLE[15]="net.ipv6.neigh.default.gc_thresh2"
REC_SYSCTL_VARIABLE_VALUE[15]="4096"

REC_SYSCTL_VARIABLE[16]="net.ipv6.neigh.default.gc_thresh3"
REC_SYSCTL_VARIABLE_VALUE[16]="8192"



##### Linux commands used for info collection #####
# Kernel
CMD_KERNEL_INFO="uname -r | cut -d '-' -f 1"
# Glibc
CMD_GLIBC_INFO="ldd --version | sed '1q;d' | awk '{print \$NF}'"
# Binutils
CMD_BINUTILS_INFO="ld -v | grep -Eoh '[0-9]+\.?[0-9]*' | head -1"
# Distribution name and release
CMD_DISTRIBUTION_INFO=("lsb_release -ir" 
					   "cat /etc/*-release")
# Cores
CMD_NUM_CORES_INFO="cat /proc/cpuinfo | grep processor | wc -l"
# CPU Cache
CMD_CPU_CACHE_INFO="cat /proc/cpuinfo | grep -m1 'cache size' | awk '{print \$4}'"
# RAM
CMD_RAM_SIZE_INFO="sudo dmidecode -t 17 | grep 'Size: [0-9]\{1,\}' | awk '{print \$2}'"
# CPU FLags
CMD_CPU_FLAGS_INFO="cat /proc/cpuinfo | grep -m1 -oh " #pass as paramenter the flag to check
# CPU Model
CMD_CPU_MODEL="cat /proc/cpuinfo | grep -m1 'model name' | cut -d ':' -f 2 | cut -c 2-"
# Hyperthreading (threads per core)
CMD_HYPERTHREADING_INFO="lscpu | grep 'Thread(s)' | awk '{print \$NF}'"
# CPU Speed
CMD_CPU_SPEED_INFO="dmesg | grep -m1 'MHz processor' | grep -Eoh '[0-9]+\.?[0-9]* MHz'"



##### VERDICT VARIABLES #####
VERDICT_KERNEL="FAIL"
VERDICT_GLIBC="FAIL"
VERDICT_BINUTILS="FAIL"
VERDICT_NUM_CORES="FAIL"
VERDICT_DISTRIB="FAIL"
VERDICT_CPU_CACHE="FAIL"
VERDICT_RAM="FAIL"
VERDICT_CPU_TYPE="FAIL"
VERDICT_FLAGS="FAIL"
VERDICT_SYSCTL="FAIL"

# OTHER SYSTEM INFO
SYS_CPU_MODEL="N/A"
SYS_THREADS_PER_CORE="N/A"
SYS_HYPERTHREADING_ENABLED="N/A"
SYS_DISK_INFO_ROOT="N/A"
SYS_DISK_INFO_CURR="N/A"

function IS_GREATER_OR_EQUAL(){
	# This function compares versions and returns PASS or FAIL depending on result.
	# Comparison is done from the most significant values (left most) to the least (right most) separated by "."
	# The versions are not floating point numbers, so for example: version 3.12 > version 3.2

	local arg1
	local arg2
	local verdict="FAIL"

	if [ -n "$1" ]; then
		arg1=($(echo $1 | tr '.' ' '))
	fi

	if [ -n "$2" ]; then
		arg2=($(echo $2 | tr '.' ' '))
	fi

	for i in "${!arg2[@]}"; do
		local arg1_val=${arg1[$i]}
		local arg2_val=${arg2[$i]}

		if [ -n "$arg1_val" ]; then
			if ! [[ $arg1_val =~ ^[0-9]+$ ]] && [[ $arg2_val =~ ^[0-9]+$ ]]; then
				verdict="FAIL"
				break;
			fi

			if [ $arg1_val -gt $arg2_val ]; then
				verdict="PASS"
				break
			elif [ $arg1_val -lt $arg2_val ]; then
				verdict="FAIL"
				break
			elif [ $i -eq $((${#arg2[@]}-1)) ]; then
				verdict="PASS"
			fi
		elif [ $i -eq $(( ${#arg2[@]}-1 )) -a $arg2_val -eq 0 ]; then
			verdict="PASS"
		fi
	done

	echo "$verdict" 
}

function PRINT_FORMATTED_VERDICT(){
	# This function will print the verdict with corresponding colors for TERMINAL display. 
	# Green for PASS and Red for FAIL
	
	if [ "$1" = "PASS" ]; then
		if [ -z "$2" ] || [ "$2" == "TERMINAL" ]; then
			echo -e "\e[1;92;40m PASS \e[0;39m"
		elif [ "$2" == "FILE" ]; then
			echo -e " PASS "
		fi
	else
		if [ -z "$2" ] || [ "$2" == "TERMINAL" ]; then
			echo -e "\e[1;91;40m FAIL \e[0;39m"
		elif [ "$2" == "FILE" ]; then
			echo -e " FAIL "
		fi
	fi
}

function EXECUTE_COMMAND(){
	# This function executes the command, hides error messages, 
	# and sets the result to "N/A" for unsuccessful command execution

	cmd_result="N/A"
	if [ -n "$1" ]; then
		#cmd_result=$(eval "$1" 2> /dev/null)
		cmd_result=$(eval "$1" 2> /dev/null)
		if [ $? -ne 0 ] || [ -z "$cmd_result" ]; then
			cmd_result="N/A"
		fi
	fi

	echo "$cmd_result"
}

function PRINT_RESULTS(){
	if [ -n "$1" ]; then
		output_target="$1"
	fi
	
	printf "=========================================================================\n"
	printf "%30s%-20s %-20s\n" " " "SYSTEM" "RECOMMENDED"
	printf "=========================================================================\n"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_KERNEL $output_target)] %-20s %-20s %-20s \n" "KERNEL:" "$SYS_KERNEL" "$REC_KERNEL"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_GLIBC $output_target)] %-20s %-20s %-20s \n" "GLIBC:" "$SYS_GLIBC" "$REC_GLIBC"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_BINUTILS $output_target)] %-20s %-20s %-20s \n" "BINUTILS:" "$SYS_BINUTILS" "$REC_BINUTILS"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_NUM_CORES $output_target)] %-20s %-20s %-20s \n" "NUM OF CORES:" "$SYS_NUM_CORES" "$REC_NUM_CORES"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_DISTRIB $output_target)] %-20s %-20s %-20s \n" "DISTRIBUTION:" "$SYS_DISTRIBUTION_NAME $SYS_DISTRIBUTION_VERSION" "${REC_DISTRIBUTION_NAME[$SYS_DISTRIBUTION_TYPE_INDEX]} ${REC_DISTRIBUTION_VERSION[SYS_DISTRIBUTION_TYPE_INDEX]}"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_CPU_CACHE $output_target)] %-20s %-20s %-20s \n" "CPU CACHE SIZE:" "$SYS_CPU_CACHE KB" "$REC_CPU_CACHE KB"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_RAM $output_target)] %-20s %-20s %-20s \n" "RAM SIZE:" "$SYS_RAM_SIZE MB" "$REC_RAM_SIZE MB"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_CPU_TYPE $output_target)] %-20s %-20s %-20s \n" "CPU TYPE:" "$SYS_CPU_TYPE" "$REC_CPU_TYPE_CORE2|$REC_CPU_TYPE_SANDY"
	printf "=========================================================================\n"
	printf "[$(PRINT_FORMATTED_VERDICT $VERDICT_FLAGS $output_target)] %-20s %-40s \n" "CPU FLAGS:" "Missing:$SYS_MISSING_FLAGS"
	printf "=========================================================================\n"
	printf "\n"
	printf "\n"
	printf "=========================================================================\n"
	printf "         %-35s %-15s %-15s\n" "SYSCTL VARIABLES" "SYSTEM" "RECOMMENDED"
	printf "=========================================================================\n"

	for i in "${!REC_SYSCTL_VARIABLE[@]}"; do
		rec_values=(${REC_SYSCTL_VARIABLE_VALUE[$i]}) # needed to convert to array from string since bash does not 2D arrays
		sys_values=(${SYS_SYSCTL_VARIABLE_VALUE[$i]}) # needed to convert to array from string since bash does not 2D arrays
		printf "[$(PRINT_FORMATTED_VERDICT ${VERDICT_SYSCTL[$i]} $output_target)] %-35s %-15s %-15s \n" "${REC_SYSCTL_VARIABLE[$i]}" "${sys_values[0]}" "${rec_values[0]}"
		for j in $(seq 1 ${#sys_values[@]}); do
			if [ -n "${sys_values[$j]}" ]; then
				printf "%-44s %-15s %-15s \n" " " "${sys_values[$j]}" "${rec_values[$j]}"
			fi
		done
	done

	printf "=========================================================================\n"
	printf "\n"
	printf "\n"
	printf "=========================================================================\n"
	printf "                       OTHER SYSTEM INFORMATION\n"
	printf "=========================================================================\n"
	printf "%-20s%-50s\n" "CPU MODEL:" "$SYS_CPU_MODEL"
	printf "%-20s%-50s\n" "CPU Speed:" "$SYS_CPU_SPEED"
	printf "%-20s%-50s\n" "HYPERTHREADING:" "$SYS_HYPERTHREADING_ENABLED ($SYS_THREADS_PER_CORE thread/s per core)"
	printf "%-20s\n" "DISK INFO (ROOT DIR):"
	printf "   %-70s\n" "${SYS_DISK_INFO_ROOT[0]}"
	printf "   %-70s\n" "${SYS_DISK_INFO_ROOT[1]}"
	printf "\n"
	printf "%-20s\n" "DISK INFO (CURRENT DIR):"
	printf "   %-70s\n" "${SYS_DISK_INFO_CURR[0]}"
	printf "   %-70s\n" "${SYS_DISK_INFO_CURR[1]}"
	printf "\n"
	printf "%-20s\n" "INTERFACES:"

	for i in "${!SYS_INTERFACES[@]}"; do
		printf "   %-15s%-50s\n" "${SYS_INTERFACES[$i]}" "Speed:  ${SYS_ETH_SPEED[$i]}"
		printf "   %-15s%-50s\n" " " "Duplex: ${SYS_ETH_DUPLEX[$i]}"
	done

	printf "=========================================================================\n"
	printf "\n"
}

# KERNEL CHECK #######################################################################
SYS_KERNEL=$(EXECUTE_COMMAND "$CMD_KERNEL_INFO")
VERDICT_KERNEL=$(IS_GREATER_OR_EQUAL $SYS_KERNEL $REC_KERNEL)

# GLIBC CHECK ########################################################################
SYS_GLIBC=$(EXECUTE_COMMAND "$CMD_GLIBC_INFO")
VERDICT_GLIBC=$(IS_GREATER_OR_EQUAL $SYS_GLIBC $REC_GLIBC)

# BINUTILS CHECK #####################################################################
SYS_BINUTILS=$(EXECUTE_COMMAND "$CMD_BINUTILS_INFO")
VERDICT_BINUTILS=$(IS_GREATER_OR_EQUAL $SYS_BINUTILS $REC_BINUTILS)

# CPU CHECK ##########################################################################
SYS_NUM_CORES=$(EXECUTE_COMMAND "$CMD_NUM_CORES_INFO")
VERDICT_NUM_CORES=$(IS_GREATER_OR_EQUAL $SYS_NUM_CORES $REC_NUM_CORES)

# DISTRIBUTION CHECK #################################################################
SYS_DISTRIBUTION_NAME=""
SYS_DISTRIBUTION_VERSION=0
SYS_DISTRIBUTION_TYPE_INDEX=0

for index in "${!CMD_DISTRIBUTION_INFO[@]}"; do
	eval_distrib_info=$(${CMD_DISTRIBUTION_INFO[$index]} 2> /dev/null)
	if [ $? -eq 0 ] && [ -n "$eval_distrib_info" ]; then
		case $index in
			0)
			SYS_DISTRIBUTION_NAME="$(${CMD_DISTRIBUTION_INFO[$index]} | grep "Distributor ID:" | cut -d ':' -f 2 | cut -c 2-)"
			SYS_DISTRIBUTION_VERSION="$(${CMD_DISTRIBUTION_INFO[$index]} | grep "Release:" | cut -d ':' -f 2 | cut -c 2-)"
			;;
			1)
			SYS_DISTRIBUTION_NAME="$(${CMD_DISTRIBUTION_INFO[$index]} | grep "^NAME=" | cut -d "=" -f 2 | cut -d '"' -f 2 | cut -d ' ' -f 1)"
			SYS_DISTRIBUTION_VERSION="$(${CMD_DISTRIBUTION_INFO[$index]} | grep "^VERSION=" | cut -d '=' -f 2 | cut -d '"' -f 2 | cut -d ' ' -f 1)"
			;;
		esac

		for i in "${!REC_DISTRIBUTION_NAME[@]}"; do
			if [[ $SYS_DISTRIBUTION_NAME == *"${REC_DISTRIBUTION_NAME[$i]}"* ]]; then
				SYS_DISTRIBUTION_TYPE_INDEX=$i
				VERDICT_DISTRIB=$(IS_GREATER_OR_EQUAL $SYS_DISTRIBUTION_VERSION ${REC_DISTRIBUTION_VERSION[$i]})
			fi
		done

		break;
	fi
done

# CPU AND FLAGS CHECK ###############################################################
SYS_CPU_TYPE="N/A"
SYS_CPU_FLAGS=""
SYS_MISSING_FLAGS=""
SYS_MISSING_FLAGS_CORE2=""
SYS_MISSING_FLAGS_SANDY=""

# Check for flags from Core 2 flag list
for flag in "${REC_CPU_TYPE_CORE2_FLAGS[@]}"; do
	SYS_CHECK_FLAG=$(EXECUTE_COMMAND "$CMD_CPU_FLAGS_INFO -E ' $flag | $flag$' ")
	if [ "$SYS_CHECK_FLAG" != "N/A" ]; then
		SYS_CPU_FLAGS="$SYS_CPU_FLAGS $SYS_CHECK_FLAG"
		SYS_CPU_TYPE="$REC_CPU_TYPE_CORE2"
	else
		SYS_MISSING_FLAGS_CORE2="$SYS_MISSING_FLAGS_CORE2 $flag"
	fi
done

# Check for flags from Sandy Bridge flag list
for flag in "${REC_CPU_TYPE_SANDY_FLAGS[@]}"; do
	SYS_CHECK_FLAG=$(EXECUTE_COMMAND "$CMD_CPU_FLAGS_INFO -E ' $flag | $flag$' ")
	if [ "$SYS_CHECK_FLAG" != "N/A" ]; then
		SYS_CPU_FLAGS="$SYS_CPU_FLAGS $SYS_CHECK_FLAG"
		SYS_CPU_TYPE="$REC_CPU_TYPE_SANDY"
	else
		SYS_MISSING_FLAGS_SANDY="$SYS_MISSING_FLAGS_SANDY $flag"
	fi
done

SYS_CPU_FLAGS=($SYS_CPU_FLAGS)

# Check flags in system to determine CPU type (Core 2 or Sandy Bridge)
if [ "$SYS_CPU_TYPE" == "$REC_CPU_TYPE_CORE2" ]; then
	rec_core2_flag_count=${#REC_CPU_TYPE_CORE2_FLAGS[@]}
	VERDICT_FLAGS=$(IS_GREATER_OR_EQUAL ${#SYS_CPU_FLAGS[@]} $rec_core2_flag_count)
	VERDICT_CPU_TYPE="PASS"
	SYS_MISSING_FLAGS=$SYS_MISSING_FLAGS_CORE2
elif [ "$SYS_CPU_TYPE" == "$REC_CPU_TYPE_SANDY" ]; then
	rec_sandy_flag_count=$(( ${#REC_CPU_TYPE_CORE2_FLAGS[@]} + ${#REC_CPU_TYPE_SANDY_FLAGS[@]} ))
	VERDICT_FLAGS=$(IS_GREATER_OR_EQUAL ${#SYS_CPU_FLAGS[@]} $rec_sandy_flag_count)
	VERDICT_CPU_TYPE="PASS"
	SYS_MISSING_FLAGS="$SYS_MISSING_FLAGS_CORE2$SYS_MISSING_FLAGS_SANDY"
else
	VERDICT_FLAGS="FAIL"
fi

# CPU CACHE SIZE CHECK ##############################################################
SYS_CPU_CACHE=$(EXECUTE_COMMAND "$CMD_CPU_CACHE_INFO")
VERDICT_CPU_CACHE=$(IS_GREATER_OR_EQUAL $SYS_CPU_CACHE $REC_CPU_CACHE)

# RAM CHECK #########################################################################
SYS_RAM_INFO=($(EXECUTE_COMMAND "$CMD_RAM_SIZE_INFO"))
SYS_RAM_SIZE=0

for ram in "${SYS_RAM_INFO[@]}"; do
	(( SYS_RAM_SIZE += ram ))
done

VERDICT_RAM=$(IS_GREATER_OR_EQUAL $SYS_RAM_SIZE $REC_RAM_SIZE)

# SYSCTL ############################################################################
for i in "${!REC_SYSCTL_VARIABLE[@]}"; do
	rec_values=(${REC_SYSCTL_VARIABLE_VALUE[$i]})
	SYS_SYSCTL_VARIABLE_VALUE[$i]="$(sudo sysctl ${REC_SYSCTL_VARIABLE[$i]} | cut -d '=' -f 2 | cut -c 2- | tr '\t' ' ')"
	sys_values=(${SYS_SYSCTL_VARIABLE_VALUE[$i]})
	VERDICT_SYSCTL[$i]="FAIL"
	for j in "${!rec_values[@]}"; do
		VERDICT_SYSCTL[$i]=$(IS_GREATER_OR_EQUAL ${sys_values[$j]} ${rec_values[$j]})
		if [ "${VERDICT_SYSCTL[$i]}" == "FAIL" ]; then
			break
		fi
	done
done

# CPU MODEL #########################################################################
SYS_CPU_MODEL=$(EXECUTE_COMMAND "$CMD_CPU_MODEL")

# CPU SPEED #########################################################################=
SYS_CPU_SPEED="$(EXECUTE_COMMAND "$CMD_CPU_SPEED_INFO")"

# CPU MODEL #########################################################################
SYS_THREADS_PER_CORE=$(EXECUTE_COMMAND "$CMD_HYPERTHREADING_INFO")

if [ "$SYS_THREADS_PER_CORE" != "N/A" ]; then
	if [ $SYS_THREADS_PER_CORE -gt 1 ]; then
		SYS_HYPERTHREADING_ENABLED="ON"
	else
		SYS_HYPERTHREADING_ENABLED="OFF"
	fi
fi

# DISK INFO #########################################################################
SYS_DISK_INFO_ROOT[0]="$(df -h / | head -1 | tail -1)"
SYS_DISK_INFO_ROOT[1]="$(df -h / | head -2 | tail -1)"

SYS_DISK_INFO_CURR[0]="$(df -h ./ | head -1 | tail -1)"
SYS_DISK_INFO_CURR[1]="$(df -h ./ | head -2 | tail -1)"

# INTERFACES ########################################################################
SYS_INTERFACES=($(sudo ifconfig -a | grep -oh '^[A-Za-z0-9]*' | cut -d ':' -f 1 | egrep -v "lo|virb*" | sort -u))
SYS_ETH_SPEED="N/A"
SYS_ETH_DUPLEX="N/A"
for i in ${!SYS_INTERFACES[@]}; do
	SYS_ETH_SPEED[$i]=$(sudo ethtool ${SYS_INTERFACES[$i]} 2> /dev/null | grep Speed | cut -d ':' -f 2 | cut -c 2-)
	if [ -z "${SYS_ETH_SPEED[$i]}" ]; then
		SYS_ETH_SPEED[$i]="N/A"
	fi
	SYS_ETH_DUPLEX[$i]=$(sudo ethtool ${SYS_INTERFACES[$i]} 2> /dev/null | grep Duplex | cut -d ':' -f 2 | cut -c 2-)
	if [ -z "${SYS_ETH_DUPLEX[$i]}" ]; then
		SYS_ETH_DUPLEX[$i]="N/A"
	fi
done

# PRINT RESULTS TO TERMINAL #########################################################
if [ "$SILENT_MODE" == "OFF" ]; then
	PRINT_RESULTS "TERMINAL"
fi

# PRINT RESULTS TO FILE #############################################################
PRINT_RESULTS "FILE" > $FILENAME
