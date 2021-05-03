# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    cnorm_v2.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: phakakos <phakakos@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/11/02 15:40:35 by phakakos          #+#    #+#              #
#    Updated: 2020/11/03 14:51:21 by phakakos         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# A formatting wrapper for Norminette 2.0 DEPRECATED
# Inspired by github.com/VictorTennekes on 42 Slack
# Should be added as alias or placed to the root for easy use
# Tested to work on zsh 5.3, bash 3.2.57 on iMac 10.14.6
# Made by phakakos, Hive Helsinki 2020


# expanded aliases to support norminette aliases
# ADD YOUR ALIAS FILE IF NEEDED
shopt -s expand_aliases
source ~/.zshrc

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
LIGHT_YELLOW=$(tput setaf 228)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Coloring for different outputs
ERRORC=$RED
WARNC=$YELLOW
INVAC=$CYAN
GOOD=$GREEN
NAMEC=$BLUE$BRIGHT
ERRORPC=$LIGHT_YELLOW

NORM=""
VERBOSE=""
PRINT=""

# Parts of the norminette output to differenciate the different outputs
NORME="Norme: "
COMP_MSG="may not compile"
INVA_MSG="Not a valid file"
ERR_MSG="Error ("
ERR_MISC="Error"

# in case of "file may not compile" the norminette will not print out norm errors.
WARN_MESSAGE="THIS MAY RESULT IN NORM-ERRORS BEING IGNORED, CHECK MANUALLY"

# different states
NEWFILE="NEWFILE"
WARNING="WARNING"
ERROR="ERROR"
INVALID="INVALID"
ERROR_MISC="ERROR-MISC"

main(){
STATE=""
NEXT=""
FILE_NAME=""
CLINE=""
CCOL=""
FILE_LINE=""
while IFS= read -r line
do 
	# check norminette output
	# Reformat file name line to only print out the 'path/file'
	NORM_FILE=$(echo "$line" | grep "$NORME" | sed "s/$NORME//" | sed 's/.\/ //');
	WARNING=$(echo "$line"  | grep "$COMP_MSG");
	ERROR=$(echo "$line" | grep "$ERR_MSG");
	ERROR_MISC=$(echo "$line" | grep "$ERR_MISC");
	INVA=$(echo "$line" | grep "$INVA_MSG");
	if [[ $PRINT == "TRUE" && $ERROR != "" ]]
	then # A different sed for with and without the col 'cause regex would ignore the last number for some reason
		LINES=$(echo "$ERROR" | sed -e 's/^Error (line \([0-9]\{1,\}\)): .*$/\1/');
			if [[ $LINES == $ERROR ]]
			then 
			LINES=$(echo "$ERROR" | sed -e 's/^Error (line \([0-9]\{1,\}\)[, col [0-9]\{1,\}]\{0,\}): .*$/\1/');
			COL=$(echo "$ERROR" | sed -e 's/^Error (line [0-9]\{1,\}, col \([0-9]\{1,\}\)): .*$/\1/');
			else COL=""
			fi
	fi

	if [[ $NORM_FILE != "" ]] # Line is the name
	then FILE_NAME=$NORM_FILE; CCOL=""; CLINE=""; NEXT+=$FILE_LINE; FILE_LINE=""
	printf "%s" "$NEXT"; NEXT="" # print out the current file and wipe it for the next one
		if [[ $STATE == $NEWFILE ]] # back to back names == no errors
		then printf -v append "\t%s\n" "${GOOD}All OK${NORMAL}";
		NEXT+=$append
		fi
	printf -v append "%s\n" "${NAMEC}>>  $NORM_FILE${NORMAL}";
	STATE=$NEWFILE; NEXT+=$append;
	elif [[ $ERROR != "" ]] # Error line
	then 
		if [[ $PRINT == "TRUE" ]] # Print, -p, needs to have been called to print out the error line
		then 
			if [[ $COL != "" && ( $COL != $CCOL || $LINES != $CLINE) ]]
			then NEXT+=$FILE_LINE; FILE_LINE=""; CCOL=$COL; CLINE=$LINES
			append=$(awk "FNR==$CLINE" $FILE_NAME)
			printf -v add "\t\t%s\n" " |${ERRORPC}${append:0:$CCOL}${REVERSE}${append:$CCOL}${NORMAL}"
			FILE_LINE+=$add
			elif [[ $LINES != "" && $LINES != $ERROR && $LINES != $CLINE ]]
			then NEXT+=$FILE_LINE; FILE_LINE=""; CLINE=$LINES; CCOL=""
			append=$(awk "FNR==$CLINE" $FILE_NAME)
			printf -v add "\t\t%s\n" " |${ERRORPC}${REVERSE}$append${NORMAL}"
			FILE_LINE+=$add
			fi
		fi
	append=$(echo " $line" | sed "s/$ERR_MSG//" | sed -e 's/\(line [0-9]\{1,\}\)): /\1'$'\t\t''/' | sed $'s/, /\t/' | sed $'s/): /\t/')
	printf -v add "\t%s\t%s\n" "${BRIGHT}${ERRORC}Error${NORMAL}" "$append"
	NEXT+=$add
	STATE=$ERROR
	elif [[ $WARNING != "" ]] # Warning/May not compile line
	then append=$(echo " $line" | sed 's/Warning: //')
	printf -v add "\t%s\t\t%s\n\t%s\n" "${BRIGHT}${WARNC}Warning${NORMAL}" "$append" "${REVERSE}${WARNC}$WARN_MESSAGE${NORMAL}"
	NEXT+=$add
	STATE=$WARNING
	elif [[ $INVA != "" ]] # Invalid file
	then 
		if [[ $VERBOSE == "TRUE" ]] # Verbos, -v, needs to have been called to print
		then append=$(echo " $line" | sed 's/Warning: //')
			printf -v add "\t%s\t\t%s\n" "${INVAC}Warning${NORMAL}" "$append"
			NEXT+=$add
			STATE=$INVALID
		else NEXT=""
		fi
	elif [[ $ERR_MISC != "" ]] # Other errors
	then
	append=$(echo " $line" | sed "s/$ERR_MISC//" | sed "s/^ : //")
	printf -v add "\t%s\t%s\n" "${BRIGHT}${ERRORC}Error${NORMAL}" "$append"
	NEXT+=$add
	STATE=$ERROR
	fi
done <<< "$NORM"

# If the last file does not have errors an extra check is needed
if [[ $STATE == $NEWFILE && $NEXT != "" ]]
	then printf -v append "\t%s\n" "${GOOD}All OK${NORMAL}";
	NEXT+=$append;
elif [[ $FILE_LINE != "" ]]
then NEXT+=$FILE_LINE
fi
# Print out the last output
printf "%s" "$NEXT";
}

# if only script is called, print usage
# -v to not skip invalid files
START=1
if [[ $1 == "-v" ]]
then START=2; VERBOSE="TRUE"
elif [[ $1 == "-p" ]]
then START=2; PRINT="TRUE"
fi

if [[ $1 == "-vp" || $1 == "-pv" ]]
then START=2; VERBOSE="TRUE"; PRINT="TRUE"
elif [[ $START == 2 && $2 == "-v" ]]
then START=3; VERBOSE="TRUE"
elif [[ $START == 2 && $2 == "-p" ]]
then START=3; PRINT="TRUE"
fi

if [[ ${@:$START} == "" ]]
then printf "%s\n\t\t%s\n\t\t%s\n" "${NAMEC}usage:${NORMAL} ${0##*/} [${BRIGHT}-vp${NORMAL}]${BRIGHT} norminette input${NORMAL}" "-v 'Show invalid file output'" "-p 'Print out the marked error'"; exit;
else NORM=$(norminette ${@:$START}); main; exit
fi

# Alternative method to call norminette one by one
# Seriously slower due to Norminette being the slowdown
for arg in "${@:$START}"
do
	NORM=$(norminette $arg)
	main
done

