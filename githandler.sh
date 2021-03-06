# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    githandler.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: phakakos <phakakos@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/03/11 19:39:53 by phakakos          #+#    #+#              #
#    Updated: 2020/10/28 14:36:10 by phakakos         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Shell script to handle multiple git commands in a single line
# Should be added as alias or placed to the root for easy use
# does not edit commit message for already committed files
# can handle multiple different different adds, commits and pushes
# Made by phakakos @ Hive Helsinki, 2020



gitcheck(){
# Check if in a git folder
GIT=$(git status 2> /dev/null);
if [[  $GIT == "" ]]
then echo "Not in a git folder"; exit;
fi
}

if [[ ${@:1} == "" ]]
then echo "usage: ${0##*/} [-s] [-rm] || (files to add) [-m "'"'"message"'"'"] [-p]"; 
echo "\t\t-s\tGit status"
echo "\t\t-rm\tGit rm. Ignores errors"
echo "\t\t-m\tCommit with a message"
echo "\t\t-p\tGit push"
exit
fi
gitcheck;
mess="no";
remove="false"

for arg in "$@"
do
	if [[ $mess == "yes" ]]
	then git commit -m "$arg"; mess="no"; continue
	elif [[ $arg == "-m" ]]
	then mess="yes"; continue
	elif [[ $arg == "-rm" ]]
	then remove="true"; continue
	elif [[ $remove == "true" && ( -f $arg || -d $arg )]]
	then rm $arg; git rm $arg 2> /dev/null; continue
	elif [[ -f $arg ]]
	then git add $arg; continue
	elif [[ -d $arg ]]
	then git add $arg/*; continue
	elif [[ $arg == "-p" ]]
	then git push; continue
	elif [[ $arg == "-s" ]]
	then git status; exit
	else
	echo "input '$arg' was not valid file/folder/flag"; exit;
	fi
done
