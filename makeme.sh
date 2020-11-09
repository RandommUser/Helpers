# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    makeme.sh                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: phakakos <phakakos@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/02/14 13:52:58 by phakakos          #+#    #+#              #
#    Updated: 2020/02/14 20:19:03 by phakakos         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Script to create a Makefile
# Should be added as alias or placed to the root for easy use
# Auto solves .c, .a and folders into right categories
# Made by phakakos, Hive Helsinki 2020


# Set the names of the different variables in the Makefile
CNAME="SRCS"						# all the .c files
ONAME="BIGO"						# all the .o files
INCNAME="INC"						# include folders
LIBNAME="LIB"						# library folders
FRAMEWORKNAM="FRAMEWORK"			# framework name
PREFRAMEWORKNAM="PREFRAMEWORK"		# pre-framework name
FLAGSNAME="FLAGS"					# compile flags

# Parse parameters
FLAGS="-Wall -Wextra -Werror"		# flags
NAME=""								# output name
CFILES=""							# .c files
OFILES="\$($CNAME:.c=.o)"			# set the .c files into .o files
LIB=""								# libraries
INCLUDES=""							# included folders
EMAKE=()							# list of libraries folders to run 'make' in
FRAMEWORK=""						# mlx framework flags
PRE_FRAMEWORK=""					# Flags before gcc -o call. Mainly for pthread

# Booleans
MLX_TAG="FALSE"
PTHREAD_TAG="FALSE"


# Create the makefile
print_make(){
# move old makefile to Makefile1
if [[ -f Makefile ]]
then mv Makefile Makefile-$(date +%s); echo "Renamed old Makefile"
fi

echo "NAME=$NAME" > Makefile					# Write variables to Makefile
echo "$CNAME=$CFILES" >> Makefile
echo "$ONAME=$OFILES" >> Makefile
echo "$INCNAME=$INCLUDES" >> Makefile
echo "$LIBNAME=$LIB" >> Makefile
echo "$FLAGSNAME=$FLAGS" >> Makefile
echo "$FRAMEWORKNAM=$FRAMEWORK" >> Makefile
echo "$PREFRAMEWORKNAM=$PRE_FRAMEWORK" >> Makefile
echo "\n\nall : \$(NAME)" >> Makefile
echo "" >> Makefile
echo "\$(NAME) :" >> Makefile
if [[ $EMAKE != "" ]]							# library make
then 
	for folder in ${EMAKE[@]}
	do
		echo "\tmake -C $folder" >> Makefile	
	done
fi
echo "\tgcc -c \$($FLAGSNAME) \$($CNAME) \$($INCNAME)" >> Makefile
TEST=$(echo "$NAME" | grep "\.a$")
if [[ $TEST == "" ]]							# if the desired output file is an .a file, change the final compilation
then echo "\tgcc \$($FLAGSNAME) \$($PREFRAMEWORKNAM) -o \$(NAME) \$($ONAME) \$($LIBNAME) \$($FRAMEWORKNAM)" >> Makefile
else 
	echo "\tar rc \$(NAME) \$($ONAME)" >> Makefile; echo "\tranlib \$(NAME)" >> Makefile
fi
echo "" >> Makefile
echo "clean :" >> Makefile
if [[ $EMAKE != "" ]]							# library clean
then 
	for folder in ${EMAKE[@]}
	do
		echo "\tmake -C $folder clean" >> Makefile	
	done		
fi
echo "\trm -f \$($ONAME)" >> Makefile
echo "" >> Makefile
echo "fclean : clean" >> Makefile
if [[ $EMAKE != "" ]]							# library fclean
then 
	for folder in ${EMAKE[@]}
	do
		echo "\tmake -C $folder fclean" >> Makefile	
	done
fi
echo "\trm -f \$(NAME)" >> Makefile
echo "" >> Makefile
echo "re: fclean all" >> Makefile
echo "Makefile created"; exit
}

# usage
if [[ ${@:1} == "" ]]
then echo "usage: ${0##*/} 'output name(.a)' Makefile file.c/.a folder [-mlx -pthread]"
	echo "\t\tName\t\t\tName for the program or library to be compiled"
	echo "\t\t*.c files\t\tGive as a parameter"
	echo "\t\tHeader includes\t\tGive as a folder"
	echo "\t\tCompilable library\tGive as a folder or the Makefile"
	echo "\t\tStatic library \t\tGive the .a as a parameter"
	echo "\t\t-mlx\t\t\tAdd iMac flags"
	echo "\t\t-pthread\t\tAdd pthread flags"
	echo "\t\tName first, input order doesn't matter"
	exit
fi

# Loop thru all the parameters
for arg in "${@:1}"
do
	TEST=""
	if [[ $NAME == "" ]]
	then NAME="$arg"; continue;
	fi
	if [[ $arg == "-mlx" && $MLX_TAG != "TRUE" ]]						# mlx framework tag
	then FRAMEWORK+="-framework OpenGL -framework AppKit "; MLX_TAG="TRUE"; continue;
	elif [[ $arg == "-pthread" && $PTHREAD_TAG != "TRUE" ]]				# pthread framework tag
	then PRE_FRAMEWORK+="-lpthread -pthread "; PTHREAD_TAG="TRUE"; continue;
	fi
	TEST=$(echo "$arg" | grep ".c")
	if [[ $TEST	!= "" ]] 						# Input is a .c file
		then 
			if [[ -f $arg ]] 					# It exists
			then 
				if [[ $CFILES != "" ]]
				then printf -v add "%s\n\t" "\\"
				CFILES+=$add;
				fi
			CFILES+=$arg; continue
			else echo "$arg is not an existing .c file"; continue
		fi
	fi
	if [[ -d $arg ]]										# Input is a folder
	then INCLUDES+="-I $arg "
		if [[ -f $arg/Makefile ]]							# If there is a Makefile inside the folder
		then TEST=$(cat $arg/Makefile | grep "NAME" | grep "\.a$")
			if [[ $TEST  != "" ]]							# The Makefile compiles an .a file, add it to EMAKE to make before compling
			then
				TEST=$(echo "$arg" | grep "^[\.]\{1,2\}\/\|^~\/")
				if [[ $TEST != "" ]]						# if the arg has './' , '../'  or '~/' at the end of the argument, otherwise add "./"
				then LIB+="-L $arg "; EMAKE+=( "$arg" );
				else
					LIB+="-L ./$arg "; EMAKE+=( "./$arg" );
				fi
				TEST=$(cat $arg/Makefile | grep "\.a$" | sed -E "s/^.*=(.*)\.a/\1/g" | sed 's/ //g' | sed 's/^lib//g') # get the library name
				LIB+="-l$TEST "
				continue
			fi
		fi
	continue
	fi
	TEST=$(echo "$arg" | grep "\.a")
	if [[ $TEST != "" ]]						# Input is an a-file
	then
		if [[ -f $arg ]]						# it exists
		then 
			TEST=$(echo "$arg" | grep "^[\.]\{1,2\}\/\|^~\/")						# starts with './', '../' or '~/'
			if [[ $TEST == "" ]]													# add the start ^ if needed
			then arg="./$arg"
			fi
			TEST=$(echo "$arg" | sed -E "s/(^.*)\/.*\.a$/\1/g") 					# get the folder for the library
			INCLUDES+="-I $TEST "
			LIB+="-L $TEST "
			TEST=$(echo "$arg" | sed -E "s/^.*\/(.*)\.a$/\1/g" | sed "s/^lib//g")	# get the library name
			LIB+="-l$TEST "
		else echo "$arg is not an existing .a file"
		fi
		continue
	fi
	TEST=$(echo "$arg" | grep "Makefile$")
	if [[ $TEST != "" && -f $arg ]]							# Input is a Makefile
	then TEST=$(cat $arg | grep "NAME" | grep "\.a$")
		if [[ $TEST  != "" ]]								# The Makefile compiles an .a file, add it to EMAKE to make before compling
		then
			TEST=$(echo "$arg" | grep "^[\.]\{1,2\}\/\|^~\/");
			ADD=$(echo "$arg" | sed 's/\/Makefile$//');		# Remove the 'Makefile'
			if [[ $TEST != "" ]]							# if the arg has './' , '../'  or '~/' at the end of the argument, otherwise add "./"
			then LIB+="-L $ADD "; EMAKE+=( "$ADD" ); INCLUDES+="-I $ADD "
			else
				LIB+="-L ./$ADD "; EMAKE+=( "./$ADD" ); INCLUDES+="-I ./$ADD "
			fi
			TEST=$(cat $arg | grep "\.a$" | sed -E "s/^.*=(.*)\.a/\1/g" | sed 's/ //g' | sed 's/^lib//g') # get the library name
			LIB+="-l$TEST "
			continue
		fi
	fi
done
print_make
