
# Change this to your alias file
ALIAS_FILE=(~/.zshrc)
usage(){
	printf "%s\n" "usage: $0 -l | -rm -mv -add 'name' 'command'"
	printf "\t\t%s\t\t\t%s\n" "-l" "list aliases in the file"
	printf "\t\t%s\t\t%s\n" "-rm 'name'" "remove alias"
	printf "\t\t%s\t\t%s\n" "-mv 'name'" "change alias name"
	printf "\t\t%s\t%s\n" "-add 'name' 'command'" "add an alias"
	exit;
}

if [[ $ALIAS_FILE == "" ]]
then echo "ALIAS_FILE is not setup"; exit
elif [[ $1 == "-l" ]]
then cat $ALIAS_FILE | grep '^alias'
elif [[ $1 == "-rm" && $2 != "" ]]
then
FIND=$(cat $ALIAS_FILE | grep "^alias $2=")
	if [[ $FIND == "" ]]
	then echo "No alias $2 found"; exit
	fi
echo $FIND
read -p "Do you really want to delete this alias? (yes/no) " sure
	if [[ $sure == "yes" ]]
	then sed -i '' "s/^$FIND$//" $ALIAS_FILE
	else
	echo "Not deleting. Exiting..."; exit
	fi
elif [[ $1 == "-mv" && $2 != "" ]]
then
FIND=$(cat $ALIAS_FILE | grep "^alias $2=")
	if [[ $FIND == "" ]]
	then echo "No alias $2 found"; exit
	fi
echo $FIND
read -p "What do you want to rename it to? (empty to cancel) " aname
	if [[ $aname == "" ]]
	then echo "Cancelled, exiting..."; exit
	else
	NEWLINE=$(echo "$FIND" | sed -e "s/^alias $2\(=\".*\"\)$/alias $aname\1/")
	sed -i '' "s/$FIND/$NEWLINE/" $ALIAS_FILE
	echo "Alias renamed to $2"
	fi
elif [[ $1 == "-add" && $2 != "" && $3 != "" ]]
then
FIND=$(cat $ALIAS_FILE | grep "^alias $2=")
	if [[ $FIND != "" ]]
	then echo "Alias already exists: $FIND"; exit
	fi
printf "%s%s%s%s%s\n" "alias " "$2" "=\"" "$3" "\"" >> $ALIAS_FILE
printf "%s\n%s\n" "New alias $1 added to $ALIAS_NAME" "Restart shell for it to take effect"
else usage
fi

