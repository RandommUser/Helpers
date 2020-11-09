# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    grademe.sh                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: phakakos <phakakos@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/07/25 17:01:25 by phakakos          #+#    #+#              #
#    Updated: 2020/10/28 14:32:28 by phakakos         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Script made to test the folder's status before turning in the project.
# Should be added as alias or placed to the root for easy use
# Made by phakakos @ Hive Helsinki, 2019

# WORK IN PROGRESS
# not working because alias returns nothing

find_alias(){
	HOME_DIR=$(echo ~)
	echo "HOME_DIR $HOME_DIR"
	FILE=$(echo "$1" | grep "$HOME_DIR")
	echo "FILE $FILE"
	HOME_DIR=$(echo "$HOME_DIR" | sed -e 's/\//\\\//g')
	echo "$HOME_DIR"
	if [[ $FILE != "" ]]
	then FILE=$(echo "$1" | sed -e "s/$HOME_DIR//")
	fi
	echo "FILE1 $FILE"
	#$(alias) # | grep $FILE
	ALIAS=$(alias | grep "$FILE")
	echo "alias found '$ALIAS'"
	if [[ $ALIAS == "" ]]
	then echo "$1"
	else ALIAS=$(echo $ALIAS | sed -e 's/^\(.*\)=.*$/\1/')
	echo "$ALIAS"
	fi
}

init(){
clear
# Wait for norm test
echo "Initializing"

NORM=$(norminette * | grep "Error\|Warning" | grep -v " valid")
start
}

start(){
GIT=$(git status 2> /dev/null)
rules=0
clear
# Print out current folder
echo "Current location"
pwd
echo ''
}

gitcheck(){
# Print out git status if in a git root
echo "---git status---"
echo ''
if [[  $GIT != "" ]]
then git status -s -u
else
   	echo "Not in a  git folder"
fi
echo ''
}

norm(){
# Print out Norm errors
echo "...Checking norm..."
echo ''
	if [[ $NORM == "" ]]
	then echo "No norm errors";
	else 
	norminette *
	fi
echo ''
}

makefile(){
# Find rules set by the Norm and the file name
echo ">>>Checking the Makefile<<<"
echo ''
if [ -f "Makefile" ]
then
MNAME=$(cat Makefile | grep "NAME[ ]\{0,1\}=")
ALL=$(cat Makefile | grep "all[ ]\{0,1\}:")
NAME=$(cat Makefile | grep "(NAME)[ ]\{0,1\}:")
CLEAN=$(cat Makefile | grep "clean[ ]\{0,1\}:")
FCLEAN=$(cat Makefile | grep "fclean[ ]\{0,1\}:")
RE=$(cat Makefile | grep "re[ ]\{0,1\}:")
rules=0
	if [ -z "$MNAME" ]
	then echo "NAME is not defined"
	else echo $MNAME;
	fi
	if [ -z "$ALL" ]
	then echo "ALL rule is missing"
	else (( rules+=1 ))
	fi
	if [ -z "$NAME" ]
	then echo "NAME rule is missing"
	else (( rules+=1 ))
	fi
	if [ -z "$CLEAN" ]
	then echo "CLEAN rule is missing"
	else (( rules+=1 ))
	fi
	if [ -z "$FCLEAN" ]
	then echo "FCLEAN rule is missing"
	else (( rules+=1 ))
	fi
	if [ -z "$RE" ]
	then echo "RE rule is missing"
	else (( rules+=1 ))
	fi
	if [ $rules -eq 5 ]
	then echo "All rules found"
	fi
else
	echo "Makefile missing"
fi
echo ''
}

auth(){
# Check author file, prints out the file if there is more than your username
echo "~~~Checking author file~~~"
echo ''
if [ -f "author" ]
then
	file='author'
	while read line ; do
		if [[ $USER == $line ]]
		then echo "current user found";
		else echo $line
		fi
	done < $file
else	echo "no author file"
fi
echo ''
}

rules(){
# test compiling
echo "+++Compile testing+++\n"
if [ $rules -eq 5 ]
then make re; echo "\nMake re\n"; make clean; echo "\nMake clean\n"; make fclean; echo "\nMake fclean\n"; make; echo "\nmake all\n"; make fclean; echo "\nAll make rules tested";
else echo "Not all rules found, skipping make function testing"
fi
echo ''
}

if [[ $1 == "-g" ]]
then start; gitcheck; exit;
elif [[ $1 == "-n" ]]
then init; norm; exit;
elif [[ $1 == "-m" ]]
then start; makefile; exit;
elif [[ $1 == "-u" ]]
then start; auth; exit;
elif [[ $1 == "-r" ]]
then start; makefile; rules; exit;
elif [[ $1 == "-a" ]]
then init; gitcheck; auth; norm; makefile; rules; exit;
else
	#ALIAS=$(find_alias $0 )
	#find_alias $0
	alias
	echo "usage ${0##*/} [ -a -g -n -m -r -u ]"; 
	echo "\t\t-a 'all'";
	echo "\t\t-g 'git status'"
	echo "\t\t-n 'norminette'"
	echo "\t\t-m 'makefile rules'"
	echo "\t\t-r 'makefile functions'"
	echo "\t\t-u 'author file'"
	exit;
fi
