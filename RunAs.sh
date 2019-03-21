#!/bin/sh

# If we're taking admin rights away from people, we should have a means of running commands as another user.

echo ""

# Get a list of the users in the admin group
userlist=$(dscacheutil -q group -a name admin | grep users | awk -F': ' '{print $NF}')

# If the user list only contains root, no point in us going any urther.
if [[ "$userlist" == "root" ]]; then
	hn=(scutil --get Computername)
	echo "The only admin account present is 'root' which is disabled by default on Macs."
	echo ""
	# If the munki folder is there, we can fix it.  If it's missing, either this is somthing that the user has done or it's something we've done and the user has tried to do away with munki before the changes have taken hold. 
	if [ -d /usr/local/munki ]; then
		echo "You need to contact IT Support with the computer name \"$cn\" to have this fixed."
	else
		echo "This Mac doesn't seem to have our management software on it....."
		echo ""
		echo "                      ¯\_(ツ)_/¯"
	fi
	echo ""
	exit 1
fi

# What command do the want to run?
if [ -z "$1" ]; then
	echo "What command do you want to run? (assuming sudo):"
	read mycmd
	echo ""
else
	mycmd="$1"
fi

# what user do the want to run this as? 
echo "Who do you want to run this command as?:"
read userchoice

# Is this user in the list of admin users we got earlier?  If not let the user choose again.
# At this point, user can also type 'list' to get the list of admin users or 'exit'.
until [[ "$userlist" == *"$userchoice"* ]];
	do
		echo ""
		echo "$userchoice is not in the admin group." 
		echo ""
		echo "Who do you want to run this command as?"
		read userchoice
		if [[ "$userchoice" == "list" ]]; then
			echo ""
			echo "The admin list is :$userlist"
			echo ""
			read userchoice			
		fi
		if [[ "$userchoice" == "exit" ]]; then
			echo ""
			exit 0
		fi
done

# Show the command and run it.  At this point, it should ask for the password for the chosen account.
runcmd="su $userchoice -c \"sudo $mycmd\""

echo ""
echo "Command is: $runcmd"
echo ""
eval $runcmd
