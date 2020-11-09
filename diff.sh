# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    diff.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: phakakos <phakakos@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/02/10 13:27:32 by phakakos          #+#    #+#              #
#    Updated: 2020/02/14 13:47:24 by phakakos         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Single file compare for test output comparison
# Should be added as alias or placed to the root for easy use
# Done by phakakos, Hive Helsinki 2020

# Example usage would be ft_printf and printf output comparison
# Output should be formatted:
# user output\n
# test output\n
# user output\n
# test output\n
# ...
# Order can be switched around, the comparison will be handled the same
# Handles empty lines

# Replacement value for "" lines.
# Uses current ISO time to make it have randomness to make it almost impossible for
# the test cases to match the replacement
EMPTY_LINE="empty"$(date +%s)

# To compare empty output lines
test_line()
{
	if [[ $1 == "" ]]
	then echo "$EMPTY_LINE"
	else echo "$line"
	fi
}

if [[ -z $1 ]]
then echo "usage: ${0##*/} 'file'"; exit
elif [[ ! -f $1 ]]
then echo "File does not exist"; exit
fi

COMP=""
FILE=$1

while IFS= read -r line
do
	line=$(test_line "$line")
	if [[ $COMP == "" ]]
	then COMP="$line"
	else
		if [[ $COMP != $line ]]
		then echo "Diff: $COMP | $line"
		fi
		COMP=""
	fi
done < $FILE
