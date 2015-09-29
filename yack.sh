#!/bin/bash

# Copyright (c) 2015 Grant Sheldon
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

ARGC=$#     # reference to original arg count
ACK_ARGS=() # args to be passed directly to ack

## added options
F_SEL="(--sel)"                 # search by objc selector
F_IMPORTS="(-j|--imports)"      # search imports of a file for string
F_HELP="(--help)"               # help menu
F_ITY_YACK="(--ity-yack)"       # yackity-yack

## generates the appropriate regex from an objc selector string.
_regex_from_selector () {
    local _reg
    local _sel=$1 # selector string

    if [[ $_sel != *"("* && $_sel != *" "* ]]; then
        # general case, a well-styled selector ( e.g. "mySelector:likeThis:" )
        # assume a well-styled selector is one where a paren nor a space appears.
        # TODO: this is prety hacky; a better way would probably be to use a regex to match
        # well-styled selectors.

        _reg=$(echo $_sel | sed 's/\:/\:\.\*?/g')
    else
        # experimental, assume we've been passed a method definition
        # ( e.g. "(void)mySelector:(id)var1 likeThis:(id)var2;" ).

        # in order:
        # 1. remove everything between parens, including parens; also remove spaces next to parens.
        # 2. then remove everything after colon that is not a space.
        # 3. then replace colon (and potentially space) with appropriate wildcards.
        _reg=$(echo $_sel | sed -E -e 's/[[:space:]]*\([^\)]*\)[[:space:]]*//g' \
                                   -e 's/\:[^[:space:]]*/\:/g' \
                                   -e 's/\:[[:space:]]?/\:\.\*?/g')
    fi

    reg=$_reg
}

# check to make sure ack is installed
command -v ack &> /dev/null || { 
    echo "Ack is not installed. Run 'brew install ack' then try again." >&2; exit 1;
}

# iterate through arguments
while [[ $# > 0 ]]; do
    if [[ $1 =~ $F_SEL ]]; then
        SEL="$2" # set selector string
        shift 2; continue
    elif [[ $1 =~ $F_HELP ]]; then
        HELP=1
    elif [[ $1 =~ $F_ITY_YACK ]]; then
        ITY_YACK=1
    elif [[ $1 =~ $F_IMPORTS ]]; then
        IMPORTS=1
    else
        ACK_ARGS+=("$1") # all other arguments will be directly passed to ack
    fi

    shift # shift positional params over by one
done

if [ -n "$SEL" ]; then
    # search by objc selector

    _regex_from_selector "$SEL" # sets reg
    ack $(echo "$reg ${ACK_ARGS[@]}" | xargs)

elif [ $IMPORTS ]; then
    # search imports for string match
    # TODO: consider implementing a recusive version of import search

    ack_argc=${#ACK_ARGS[@]}
    file=${ACK_ARGS[$ack_argc-1]}
    imports=$(cat $file | ack "#import" | awk '{ print $2 }' | ack -o '[\w\+]+\.h')

    h_files=$(echo "$imports" | xargs -I {} find . -name {}) # .h files
    m_files=$(echo "$imports" | sed 's/\.h/\.m/g' | xargs -I {} find . -name {}) # .m files
    
    echo -e "$h_files\n$m_files" | xargs -I {} ack -H "${ACK_ARGS[@]:0:$ack_argc-1}" {}

elif [[ $HELP || $ARGC < 1 ]]; then
    # help menu case
    
    printf "Ready to Yack?\n\n"
    printf "  --sel\t\t\t\tSearch for an ObjC selector.\n"
    printf "  -j, --imports\t\t\tSearch a .h or .m file's imports.\n"
    printf "  --help\t\t\tDisplay yack-specific help menu.\n"
    printf "  --ity-yack\t\t\tDon't talk back.\n"

    printf "\n** Run 'ack --help' to display the general ack help menu.\n"

elif [ $ITY_YACK ]; then
    # its a yack

cat << "YackityYack"

                            _,,,_
                        .-'`  (  '.
                     .-'    ,_  ;  \___      _,
                 __.'    )   \'.__.'(:;'.__.'/
         __..--""       (     '.__{':');}__.'
       .'         (    ;    (   .-|` '  |-.
      /    (       )     )      '-p     q-'
     (    ;     ;          ;    ; |.---.|
     ) (              (      ;    \ o  o)
     |  )     ;       |    )    ) /'.__/  ~~ yack sound ~~
     )    ;  )    ;   | ;       //
     ( )             _,\    ;  //
     ; ( ,_,,-~""~`""   \ (   //
      \_.'\\_            '.  /<_
       \\_)--\             \ \--\
   jgs )--\""`             )--\"`
       `""`                `""`

YackityYack

else
    # default behavior is to pass raw args directly to ack.

    ack "${ACK_ARGS[@]}"
fi
