#!/bin/bash

set -au

reverse=false
failed=false

while getopts ":rh" opt; do
    case $opt in
        r)
            reverse=true
            ;;
        h)
			echo "usage: $0 [-h | -r]"
            exit 0
            ;;
        \?)
            echo warning: unknown option "-$OPTARG"
            ;;
    esac
done

shift $((OPTIND - 1))

echo "##"
echo "## detected system: $(uname -m) / $(cat /proc/device-tree/module-identity/unit-id | tr -d '\0')"
echo "##"
echo -n "## populating arp records"
cat /etc/hosts | grep -E '^[0-9a-fA-F]' | while read line; do
	ping -c 1 "$(echo $line | awk '{ print $1 }')" >/dev/null 2>&1
	echo -n "."
done

echo
echo "##"

myip="$((ip addr show ethlmp0 2>/dev/null || ip addr show eth0) | grep 'inet ' | awk '{ print $2 }' | cut -d'/' -f1)"
# fetch all the fsp boards
hosts="$(arp -a | grep -v '<incomplete>' | grep -E 'fsp|asp' | sed -E 's/^.*\(([0-9\.]+)\).*$/\1/')"

if which print_bb_hostnames >/dev/null 2>&1; then
	hosts="$hosts $(print_bb_hostnames)"
fi

# add the fct which we are running on
hosts="localhost $hosts"

nsnssh="ssh -q -i /ffs/run/config/toor4nsn/.ssh/id_rsa_toor4nsn \
	-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

if $reverse; then
	echo "## un-patching setup ${myip}"
else
	echo "## patching setup ${myip}"
fi

for host in $hosts; do
    read -r -d '' normal_cmd <<-"NORMAL_CMD"
		echo -n "## patching cpu $(hostname)... "

		if ! cat /proc/mtd | grep -q boot_env; then
			echo " done (doesn't need patching)"
			exit 0
		fi

		if uboot_env get | grep -q disable_flash_logging; then
			echo " done (already patched)"
		else
			if uboot_env -q set disable_flash_logging=1; then
				echo " done (successfully patched)"
			else
				echo " error! failed to patch cpu $(hostname)"
				exit 1
			fi
		fi
NORMAL_CMD

    read -r -d '' reverse_cmd <<-"REVERSE_CMD"
		echo -n "## reverting the patching on cpu $(hostname)... "

		if ! cat /proc/mtd | grep -q boot_env; then
			echo " done (didn't need patching)"
			exit 0
		fi

		if uboot_env get | grep -q disable_flash_logging; then
			if uboot_env -q del disable_flash_logging; then
				echo " done (successfully un-patched)"
			else
				echo "error! failed to revert patch on cpu $(hostname)"
				exit 1
			fi
		else
			echo " done (already un-patched)"
		fi
REVERSE_CMD

	if $reverse; then
		cmd="$reverse_cmd"
	else
		cmd="$normal_cmd"
	fi

	if ! $nsnssh toor4nsn@$host "true"; then
		echo "** warning: cannot connect to host $host"
		continue
	fi

	if ! $nsnssh toor4nsn@$host "$cmd"; then
		failed=true
	fi
done

if $failed; then
	echo "!! some errors occured during the patching"
	echo "!! logs the gathering"
	for host in $hosts; do
		$nsnssh toor4nsn@$host "(which journalctl >/dev/null 2>&1 && journalctl -xe || cat /var/log/messages*) | grep uboot_env"
	done
	echo "!!"
	echo "!! please get in contact with I_EXT_LFS_BOOT@internal.nsn.com and"
	echo "!! provide the above output"
	echo "!!"
else
	echo "##"
	echo "## verifying..."

	for host in $hosts; do
		if ! $nsnssh toor4nsn@$host "true"; then
			echo "** warning: cannot connect to host $host"
			continue
		fi

		echo -n "## verifying cpu $($nsnssh toor4nsn@$host 'hostname')... "
		if $reverse; then
			if $nsnssh toor4nsn@$host "! cat /proc/mtd | grep -q boot_env"; then
				echo "ok (didn't need patching)"
				continue
			fi

			if $nsnssh toor4nsn@$host "uboot_env get disable_flash_logging"; then
				echo "fail!"
				failed=true
			fi
		else
			if $nsnssh toor4nsn@$host "! cat /proc/mtd | grep -q boot_env"; then
				echo "ok (didn't need patching)"
				continue
			fi

			if ! $nsnssh toor4nsn@$host "uboot_env get disable_flash_logging"; then
				echo "fail!"
				failed=true
			fi
		fi
	done

	if $failed; then
		echo "!! fail, some cpus were not patched properly"
		echo "!! logs the gathering"
		for host in $hosts; do
			$nsnssh toor4nsn@$host "(which journalctl >/dev/null 2>&1 && journalctl -xe || cat /var/log/messages*) | grep uboot_env"
		done
		echo "!!"
		echo "!! please get in contact with I_EXT_LFS_BOOT@internal.nsn.com and"
		echo "!! provide the above output"
		echo "!!"
	else
		if $reverse; then
			echo "##"
			echo "## setup ${myip} un-patched properly ##"
			echo "##"
		else
			echo "##"
			echo "## setup ${myip} patched properly ##"
			echo "##"
		fi
	fi
fi
