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
SOLOWAN_CONTAINER="solowan/solowan:v0.6"
LOGFILE="/tmp/test.log"

timestamp() {
#  date +"%T"
date +%Y-%m-%d,%H:%M:%S
}

function checkSolowanContainer() {

CHECK_CONTAINER=$(sudo docker ps| grep "$SOLOWAN_CONTAINER")
   if [ -z "$CHECK_CONTAINER" ]; then
        echo "Container not started. Exiting..."
	exit 1
   fi


}

function getStatistics() {
   CID=$(sudo docker ps -a | grep "$SOLOWAN_CONTAINER" | awk '{ print $1 }' | xargs sudo docker inspect -f '{{.Id}}' 2> /dev/null)
   if [[ -z "$CID" ]]; then
# Container docker not pulled
        echo "docker not pulled"
        exit 1
   else
        CID2=$(sudo docker ps | grep "$SOLOWAN_CONTAINER" | awk '{ print $1 }' | xargs sudo docker inspect -f '{{.Id}}' 2> /dev/null)
        if [[ -z "$CID2" ]]; then
# Container docker not started
                echo "docker container not started"
                exit 1
        else
#"Detected solowan docker started."
                COMPRESSOR=`docker exec $CID2 opennop show stats in_dedup | grep -v -e \"-\" -e \"Connecting\" -e \"Connected\" -e \"Decompressor\" | grep bytes `
                DECOMPRESSOR=`docker exec $CID2 opennop show stats out_dedup | grep -v -e \"-\" -e \"Connecting\" -e \"Connected\" -e \"Decompressor\" | grep bytes `
                #echo $COMPRESSOR
                #output=$(echo $COMPRESSOR | grep input_bytes)
                output="$COMPRESSOR $DECOMPRESSOR"

                echo $output
	fi
   fi

}

function calculateStats() {

COMP_INPUT_INI=`echo $INI| awk '{ print $2 }'`
COMP_INPUT_FIN=`echo $FIN| awk '{ print $2 }'`
COMP_INPUT_BYTES=`expr $COMP_INPUT_FIN - $COMP_INPUT_INI`

COMP_OUTPUT_INI=`echo $INI| awk '{ print $4 }'`
COMP_OUTPUT_FIN=`echo $FIN| awk '{ print $4 }'`
COMP_OUTPUT_BYTES=`expr $COMP_OUTPUT_FIN - $COMP_OUTPUT_INI`

DECOMP_INPUT_INI=`echo $INI| awk '{ print $6 }'`
DECOMP_INPUT_FIN=`echo $FIN| awk '{ print $6 }'`
DECOMP_INPUT_BYTES=`expr $DECOMP_INPUT_FIN - $DECOMP_INPUT_INI`

DECOMP_OUTPUT_INI=`echo $INI| awk '{ print $8 }'`
DECOMP_OUTPUT_FIN=`echo $FIN| awk '{ print $8 }'`
DECOMP_OUTPUT_BYTES=`expr $DECOMP_OUTPUT_FIN - $DECOMP_OUTPUT_INI`

LINE_OUTPUT="$2,$(timestamp),$1,$ELAPSED_TIME,$COMP_INPUT_BYTES,$COMP_OUTPUT_BYTES,$DECOMP_INPUT_BYTES,$DECOMP_OUTPUT_BYTES"
echo $LINE_OUTPUT
echo $LINE_OUTPUT >> $LOGFILE

#stats["$1"]=$LINE_OUTPUT

eval ${file_test_res}=$LINE_OUTPUT
#echo "FILE_TEST_RES: "
#echo ${!file_test_res}
#echo "FIN FILE_TEST_RES: "

}

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

USAGE="
-----------------------------------------------------------------------------

solowan-cold-hot-test.sh is as tool to test traffic optimizers by transfering 
all the content of an FTP or HTTP directory several times.

Usage:  solowan-cold-hot-test.sh [options] <url>

Options:
        -u -> port used for uncompressed transferences
        -c -> port used for compressed transferences
        -t -> dry-run mode, no file transferences made
        -s -> test sequence: a comma separated list of compressed ('c') or
              uncompressed ('u') tests. E.g.: 'u,c,c'

Examples:
	    solowan-cold-hot-test.sh ftp://h2/silesia
	    solowan-cold-hot-test.sh -s u,c,c,c -u 2122 -c 22 ftp://h2/silesia
		
Default values:
        FTP compress port:    21
        FTP uncompress port:  2121
        HTTP compress port:   80
        HTTP uncompress port: 8080

-----------------------------------------------------------------------------
"

# Default port values
ftp_def_umcomp_port=2121
ftp_def_comp_port=21
http_def_umcomp_port=8080
http_def_comp_port=80

# Default test sequence
test_seq="u,c,c"

echo "--"
echo "-- SoloWAN cold-hot testing script"
echo "--"

echo "-- Options:"

#echo "num args=$#"
#if [ "$#" -lt 2 ]; then
#    echo -e "\nERROR: Invalid number of parameters" 
#    echo -e "\n$USAGE\n"
#    exit 1
#fi

while getopts ":tu:c:s:h" opt; do
    #echo "*** processing option $opt"
    case "$opt" in
        s)
            test_seq="$OPTARG" 
            if [[  ! $test_seq =~ ^[cu](,[c|u])*$ ]]; then
                echo -e "\nERROR: incorrect test sequence parameter ($test_seq)."
                echo -e "$USAGE"
                exit 1
            fi
            echo "--   Test sequence: $test_seq"
            ;;
        u)
            cmdline_umcomp_port="$OPTARG" 
            echo "--   Port for uncompressed transferences: $cmdline_umcomp_port"
            ;;
        c)
            cmdline_comp_port="$OPTARG" 
            echo "--   Port for compressed transferences: $cmdline_comp_port"
            ;;
        t)
            dryrun="yes" 
            echo "--   Dry-run mode selected (no files transfered)"
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

checkSolowanContainer

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
echo "--"
echo "--   uri               = $uri"

# main uri components
echo "--   uri_schema        = $uri_schema"
echo "--   uri_address       = $uri_address"
echo "--   uri_user          = $uri_user"
echo "--   uri_password      = $uri_password"
echo "--   uri_host          = $uri_host"
echo "--   uri_port          = $uri_port"
echo "--   uri_path          = $uri_path"
#echo "--   uri_query         = $uri_query"
#echo "--   uri_fragment      = $uri_fragment"

# Get list of files from server
declare -A files
declare -A stats

if [[ $uri_schema == "ftp" ]]; then
    #echo "Using ftp"

    if [[ ! "$uri" =~ '/'$ ]]; then 
        #echo "-- Adding trailing / to uri..."
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
    #echo "def_uncomp_port=$def_uncomp_port"  
    #echo "def_comp_port=$def_comp_port"  

    uncomp_uri="${uri_schema}://${uri_host}:${def_uncomp_port}"
    comp_uri="${uri_schema}://${uri_host}:${def_comp_port}"

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

    # Set ports
	if [ $cmdline_umcomp_port ]; then 
        def_uncomp_port=$cmdline_umcomp_port
    else
        def_uncomp_port=$http_def_umcomp_port
    fi
	if [ $cmdline_comp_port ]; then 
        def_comp_port=$cmdline_comp_port
    else
        def_comp_port=$http_def_comp_port
    fi
    #echo "def_uncomp_port=$def_uncomp_port"  
    #echo "def_comp_port=$def_comp_port"  

    uncomp_uri="${uri_schema}://${uri_host}:${def_uncomp_port}"
    comp_uri="${uri_schema}://${uri_host}:${def_comp_port}"

    file_list=$( curl -s http://h2 | w3m -dump -T text/html | sed '1,/━━━━/d' | sed -n '/━━━━/q;p' | sed 's/\[ \]/[]/')
    #echo "$file_list"

    while read -r line; do
        #echo "$line"
        fname=$( echo $line | awk '{print $2}' )
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

else
    echo "ERROR: protocol $uri_schema not supported"
    exit 1
fi



#
# Main test loop
#
test_num=1

# Create a temporal dir to store files transfered
tmpdir=$( mktemp -d ) 
pushd $tmpdir > /dev/null

echo "--"
echo "-- Executing testing sequence: $test_seq"
echo "--   uncomp_uri=$uncomp_uri"  
echo "--   comp_uri=$comp_uri"  

# Eliminate ',' from test_seq
test_seq=${test_seq//,/ }

START_TIME=$SECONDS

for test in $test_seq; do 

    TEST_START=$SECONDS
    echo "--"
    echo "-- Test #$test_num ($test):"
    echo "--"

    test_res="test${test_num}_res"
        declare -A "$test_res"  # Create associative array to store results
    
    if [ $tmpdir ]; then
        rm -rf $tmpdir/*
    fi

    for file in "${!files[@]}"; do 

        # Create a reference to textX_res results array for this file
        file_test_res="$test_res['$file']"

        #printf "%s (%s)\n" $file ${files["$file"]}
        printf "  Downloading %s (%s bytes)\n" $file ${files["$file"]}
        if [ $test == 'u' ]; then
            cmd="/usr/bin/lftp -c 'get ${uncomp_uri}/$file'"
            printf "    cmd=%s\n" "$cmd"
        elif [ $test == 'c' ]; then 
            cmd="/usr/bin/lftp -c 'get ${comp_uri}/$file'"
            printf "    cmd=%s\n" "$cmd"
        fi

        if [ ! $dryrun ]; then
	    FILE_START_TIME=$SECONDS
	    INI=$(getStatistics)
	    # Execute the command
	    eval "$cmd"
	    FIN=$(getStatistics)
	    ELAPSED_TIME=$(($SECONDS - $FILE_START_TIME))
	    calculateStats $file $test_num
        fi

    done

    ELAPSED_TEST_TIME=$(($SECONDS - $TEST_START))
    duration_test["$test_num"]=$ELAPSED_TEST_TIME

    test_num=`expr $test_num + 1`

done

TOTAL_TIME=$(($SECONDS - $START_TIME))

#echo "----------------------- stats ARRAY -------------------"
#    for filestats in "${!stats[@]}"; do
#	printf "  Stats key %s: %s\n" $filestats ${stats["$filestats"]}
#    done
#echo "----------------------- END stats ARRAY -------------------"

if [ $tmpdir ]; then
    rm -rf $tmpdir/*
fi
popd > /dev/null
rmdir $tmpdir

#
# Show results
#

echo "--"
echo "-- Results: TOTAL TEST DURATION: $TOTAL_TIME seconds"
echo "--"

test_num=1

for test in $test_seq; do

    echo "--"
    echo "-- Test #$test_num ($test): ${duration_test["$test_num"]} seconds"
    echo "--"

    test_res="test${test_num}_res"

    for file in "${!files[@]}"; do
        # Create a reference to textX_res results array for this file
        file_test_res="$test_res['$file']"

        # Get results from ${!file_test_res} 
        # and process them 
        duration=$(echo ${!file_test_res} | awk -F "," '{print $5}')
        inBytesDecom=$(echo ${!file_test_res} | awk -F "," '{print $8}')
        outBytesDecom=$(echo ${!file_test_res} | awk -F "," '{print $9}')
        inRateDecom=$(echo "scale=2; $inBytesDecom / $duration / 1048576 * 8" | bc)
        outRateDecom=$(echo "scale=2; $outBytesDecom / $duration / 1048576 * 8" | bc)
        comprRatio=$(echo "scale=2; $outBytesDecom / $inBytesDecom" | bc)

	# Show results
        echo "File $file results: $outBytesDecom bytes in $duration sec. , Transfer rate: $outRateDecom Mbps , Bandwidth used: $inRateDecom Mbps , Compression ratio: $comprRatio"

    done

    test_num=`expr $test_num + 1`

done

echo "--"
echo "-- Global results:"
echo "--"

# Calculate and show global results
echo "...to be provided..."

