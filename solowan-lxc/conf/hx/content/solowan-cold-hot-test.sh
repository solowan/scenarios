#!/bin/bash



#
# URI parsing function
#
# (taken from http://vpalos.com/537/uri-parsing-using-bash-built-in-features/)
#
# The function creates global variables with the parsed results.
# It returns 0 if parsing was successful or non-zero otherwise.
#
# [schema://][user[:password]@]host[:port][/path][?[arg1=val1]...][#fragment]
#
function uri_parser() {
    # uri capture
    uri="$@"

    # safe escaping
    uri="${uri//\`/%60}"
    uri="${uri//\"/%22}"

    # top level parsing
    pattern='^(([a-z]{3,5})://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]+)(:([0-9]+))?)(\/[^?]*)?(\?[^#]*)?(#.*)?$'
    [[ "$uri" =~ $pattern ]] || return 1;

    # component extraction
    uri=${BASH_REMATCH[0]}
    uri_schema=${BASH_REMATCH[2]}
    uri_address=${BASH_REMATCH[3]}
    uri_user=${BASH_REMATCH[5]}
    uri_password=${BASH_REMATCH[7]}
    uri_host=${BASH_REMATCH[8]}
    uri_port=${BASH_REMATCH[10]}
    uri_path=${BASH_REMATCH[11]}
    uri_query=${BASH_REMATCH[12]}
    uri_fragment=${BASH_REMATCH[13]}

    # path parsing
    count=0
    path="$uri_path"
    pattern='^/+([^/]+)'
    while [[ $path =~ $pattern ]]; do
        eval "uri_parts[$count]=\"${BASH_REMATCH[1]}\""
        path="${path:${#BASH_REMATCH[0]}}"
        let count++
    done

    # query parsing
    count=0
    query="$uri_query"
    pattern='^[?&]+([^= ]+)(=([^&]*))?'
    while [[ $query =~ $pattern ]]; do
        eval "uri_args[$count]=\"${BASH_REMATCH[1]}\""
        eval "uri_arg_${BASH_REMATCH[1]}=\"${BASH_REMATCH[3]}\""
        query="${query:${#BASH_REMATCH[0]}}"
        let count++
    done

    # return success
    return 0
}



# 
# Main
#

USAGE="solowan-cold-hot-test.sh

Usage:  solowan-cold-hot-test.sh  ...
              -u -> port used for uncompressed transferences
              -c -> port used for compressed transferences
              -t -> dry-run mode, no file transferences made
              -z -> 
"

# Default port values
ftp_def_umcomp_port=2121
ftp_def_comp_port=21
http_def_umcomp_port=80
http_def_comp_port=8080



echo "--"
echo "-- SoloWAN cold-hot testing script"
echo "--"

#echo "num args=$#"
#if [ "$#" -lt 2 ]; then
#    echo -e "\nERROR: Invalid number of parameters" 
#    echo -e "\n$USAGE\n"
#    exit 1
#fi

while getopts ":tu:c:h" opt; do
    #echo "*** processing option $opt"
    case "$opt" in
#        f)
#            SCENARIO="$OPTARG" 
#            if [ ! -d $SCENARIO ]; then 
#                echo -e "\nERROR: scenario $SCENARIO does not exist\n"
#                exit 1
#            fi
#            SCENABSNAME=$( readlink -m $SCENARIO )
#            SCENDIRNAME=$( dirname $SCENABSNAME )
#            SCENBASENAME=$( basename $SCENABSNAME )
#            #echo SCENBASENAME=$SCENBASENAME
#            ;;
        u)
            cmdline_umcomp_port="$OPTARG" 
            echo "cmdline_umcomp_port=$cmdline_umcomp_port"
            ;;
        c)
            cmdline_comp_port="$OPTARG" 
            echo "cmdline_comp_port=$cmdline_comp_port"
            ;;
        t)
            dryrun="yes" 
            echo "-- Dry-run mode selected"
            ;;
        h)
            echo -e "\n$USAGE\n"
            exit 0 
            ;;
        \?)
            echo -e "\nERROR: Invalid option '-$OPTARG'\n"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

uri=$@

# perform parsing and handle failure
uri_parser "$uri" || { echo "ERROR: Malformed URI!"; exit 1; }

if [[ $uri_schema == "" ]]; then
  echo "-- Protocol not specified; using http by default"
  uri="http://$uri"
  uri_schema="http"
fi

if [[ $uri_port != "" ]]; then
    echo -e "-- \n-- WARNING: port specified in uri will be ignored. Modify port values using '-u' and '-c' options.\n--"
fi

# main uri
echo "--   uri               = $uri"

# main uri components
echo "--   uri_schema        = $uri_schema"
echo "--   uri_address       = $uri_address"
echo "--   uri_user          = $uri_user"
echo "--   uri_password      = $uri_password"
echo "--   uri_host          = $uri_host"
echo "--   uri_port          = $uri_port"
echo "--   uri_path          = $uri_path"
echo "--   uri_query         = $uri_query"
echo "--   uri_fragment      = $uri_fragment"
echo "--"

# Get list of files from server
declare -A files

if [[ $uri_schema == "ftp" ]]; then
    #echo "Using ftp"

    if [[ ! "$uri" =~ '/'$ ]]; then 
        echo "-- Adding trailing / to uri..."
		uri="$uri/"
    fi 

    # Set ports
	if [ $cmdline_umcomp_port ]; then 
        def_uncomp_port=$cmdline_umcomp_port
    else
        def_uncomp_port=$ftp_def_umcomp_port
    fi
	if [ $cmdline_comp_port ]; then 
        def_comp_port=$cmdline_comp_port
    else
        def_comp_port=$ftp_def_comp_port
    fi
    echo "def_uncomp_port=$def_uncomp_port"  
    echo "def_comp_port=$def_comp_port"  

    uncomp_uri="${uri_schema}://${uri_host}:${def_uncomp_port}"
    comp_uri="${uri_schema}://${uri_host}:${def_comp_port}"
    echo "uncomp_uri=$uncomp_uri"  
    echo "comp_uri=$comp_uri"  

    #file_list=$( curl -s $uri )
    file_list=$( curl -s $uncomp_uri )
    #echo "$file_list"

    while read -r line; do
        #echo "$line"
        fname=$( echo $line | awk '{print $9}' )
        fsize=$( echo $line | awk '{print $5}' )
        # ignore directories by now
        if [ "$fname" ] && [ "$fname" != '.' ] && [ "$fname" != '..' ] && [ "${line:0:1}" != 'd' ] ; then
            files["$fname"]=$fsize
        fi
        #echo "File: $fname (${files[$fname]})"
    done <<< "$file_list"

	#for file in "${!files[@]}"; do 
    #    #echo $file
    #    printf "%s (%s)\n" $file ${files["$file"]}
    #done

elif [[ $uri_schema == "http" ]]; then 
    echo "http not implemented yet...wait till tomorrow..."
    exit 1
def_uncomp_port=$http_def_umcomp_port
def_comp_port=$http_def_comp_port
else
    echo "ERROR: protocol $uri_schema not supported"
    exit 1
fi


test_sequence="uncompress compress compress"
test_num=1

# Main loop

tmpdir=$( mktemp -d ) 
pushd $tmpdir

for test in $test_sequence; do 

    echo "--"
    echo "-- Test #$test_num ($test):"
    echo "--"
    
    if [ $tmpdir ]; then
        rm -rf $tmpdir/*
    fi

    for file in "${!files[@]}"; do 
        #printf "%s (%s)\n" $file ${files["$file"]}
        printf "  Downloading %s (%s bytes)\n" $file ${files["$file"]}
        if [ $test == 'uncompress' ]; then
            cmd="/usr/bin/lftp -c 'get ${uncomp_uri}/$file'"
            printf "    cmd=%s\n" "$cmd"
            if [ ! $dryrun ]; then
				eval "$cmd"

			fi
        elif [ $test == 'compress' ]; then 
            cmd="/usr/bin/lftp -c 'get ${comp_uri}/$file'"
            printf "    cmd=%s\n" "$cmd"
            if [ ! $dryrun ]; then
				eval "$cmd"
			fi
        fi
    done

    test_num=`expr $test_num + 1`

done

exit

if [ $tmpdir ]; then
    rm -rf $tmpdir/*
fi
popd
rmdir $tmpdir

