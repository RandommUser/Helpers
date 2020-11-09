# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    project_init.sh                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: phakakos <phakakos@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/11/12 18:10:52 by phakakos          #+#    #+#              #
#    Updated: 2020/11/09 14:53:12 by phakakos         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Script designed to be used when starting a project.
# Should be added as alias or placed to the root for easy use
# Check LIBFT and MY_USER values before starting!!!
# Made by phakakos @ Hive Helsinki, 2019

PWD=$(pwd)
# change to your own libft folder 
LIBFT=~/libft
LIB_FOLDER=$(echo "${LIBFT##*/}")
# By default $USER is used for the author file
# Change this if your user does not match your intra login
MY_USER=""

write_author()
{
	if [[ $MY_USER == "" ]]
	then MY_USER=$USER
	fi
	echo "$MY_USER" > author; echo ">Created author file"; echo '';
}

# Copying function
# Change to fit your needs
copy(){
	cp -r $LIBFT .
	rm -rf $LIB_FOLDER/.git
	rm -rf $LIB_FOLDER/README.md
}


copy_lib(){
# Test the libft folder setup is done properly
if [[ $LIBFT == "" ]]
then echo "LIBFT is not set. Please edit the script to have your libft path"; exit;
elif [[ ! -d $LIBFT ]]
then echo "LIBFT folder does not exist. Please edi the script to have your libft path"; exit;
fi

# Checks if you already have the folder and if it is up-to-date
# Copies library from $LIBFT folder to the current folder
if [[ -d "libft" ]]
then
	LIBD=$(diff --brief libft $LIBFT)
	if [[ $LIBD == "" ]]
		then echo "Libft up to date $LIBD"
		elif [ -d "libft" ] ; then
		echo "Libft already exists. Do you want to refresh it?"
		read -p "(y/n) " lib
		while true
		do
			if [[ $lib == "y" ]]
			then make -C $LIBFT fclean; rm -r $LIB_FOLDER; copy ; echo ">Copied to current folder"; break
			elif [[ $lib == "n" ]]
			then echo "No re-copy"; break
			else read -p "(y/n) " lib
			fi
		done
	fi
else
	make -C $LIBFT fclean; copy ; echo ">Copied library to current folder"
fi
}

main(){
clear
echo "current folder is '$PWD'"
# Do you want to create an author file? Default value is just your username. WILL OVERWRITE EXISTING FILES
echo "Do you want to make author file?"
read -p "(y/n) " aut
while true
do
	if [[ $aut == "n" ]]
	then echo "Skipping"; echo ''; break
	elif [[ $aut == "y" ]]
	then write_author; echo ''; break
	else read -p "(y/n) " aut
	fi
done

if [[ $LIBFT == "" ]]
then echo "LIBFT is not set. Please edit the script to have your libft path"; exit;
elif [[ ! -d $LIBFT ]]
then echo "LIBFT folder does not exist. Please edi the script to have your libft path"; exit;
fi

# Do you want to export your libft folder. Checks if you already have the folder and if it is up-to-date
# Copies library from '.libft' folder in the same folder as the script.
if [[ -d "libft" ]]
then
	LIBD=$(diff --brief libft $LIBFT)
		if [[ $LIBD == "" ]]
			then echo "Libft up to date $LIBD"
			elif [ -d "libft" ] ; then
			echo "Libft already exists. Do you want to refresh it?"
			read -p "(y/n) " lib
			while true
		do
			if [[ $lib == "y" ]]
			then make -C $LIBFT fclean; rm -r libft; cp -r $LIBFT .; echo ">Copied to current folder"; break
			elif [[ $lib == "n" ]]
			then echo "No re-copy"; break
			else read -p "(y/n) " lib
			fi
		done
	fi
else
	echo "Do you want to copy libft?"
	read -p "(y/n) " lib
	while true
	do
		if [[ $lib == "y" ]]
		then make -C $LIBFT fclean; cp -r $LIBFT .; echo ">Copied library to current folder"; break
		elif [[ $lib == "n" ]]
		then echo "Skipping"; echo ''; break
		else read -p "(y/n) " lib
		fi
	done
fi
echo "Exiting"
}

# Flags to select author file or library individually
if [[ $1 == "-a" ]]
then write_author
elif [[ $1 == "-l" ]]
then copy_lib
elif [[ $1 != "" ]]
	then echo "usage ${0##*/} [-a (author file)| -l (library)]"
else
	main
fi
