#! /bin/bash

###################################################################################################################
######### 	Functions
###################################################################################################################

function Usage {
    cat <<USAGE
    

Usage:

` basename $0 ` -i <input_dir> -o <output_dir> -c <config> [-e <epre>] [-p <pre>] [-s <post> ] [-l <lpost>]

Main arguments:
    
	-i, --inputdir      directory of the dicoms folders of the subjects    
	-o, --outpudir      output directory of the resulting BIDS style dataset
	-c, --config        configurator file specify the naming convention
   
Optional input:

	-p, --pre           pre surgery data unique identifier label 
	-e, --early-pre     early pre surgery unique identifier label
	-s, --early-post    early post surgery unique identifier label     
	-l, --late-post     late post surgery unique identifier label    	

 
USAGE
    exit 1

}

exists () {
                ############# ############# ############# ############# ############# ############# #############
                #############  		      check existsnce of a file or directory            	    ############# 
                ############# ############# ############# ############# ############# ############# #############  		                      			
		if [ $# -lt 1 ]; then
		    echo $0: "usage: exists <filename> "
		    echo "    echo 1 if the file (or folder) exists, 0 otherwise"
		    return 1;		    
		fi 
		
		if [ -d "${1}" ]; then 

			echo 1;
		else
			([ -e "${1}" ] && [ -f "${1}" ]) && { echo 1; } || { echo 0; }	
		fi		
		};

str_index() {    
                
                ############# ############# ############# ############# ############# ############# 
                #########  Find the first index of the substring in the target string   ########### 
                ############# ############# ############# ############# ############# #############   

		if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: "usage: str_index <string> <substring> "
			    return 1;		    
		fi       

                x="${1%%$2*}";   
                [[ $x = $1 ]] && echo -1 || echo ${#x}; 
                };
                
                



###################################################################################################################
######### 	Input Parsing
###################################################################################################################


# Provide output for Help
if [[ "$1" == "-h" || "$1" == "--help" ]];
  then
    Usage >&2
  fi

nargs=$#

if [ $nargs -lt 2   ];
  then
    Usage >&2


  fi



# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        
        -h|--help)        
        Usage >&2
      	exit 0
        ;;    
        -i|--inputdir)
        shift
        input_dir=${1}
        let nargs=$nargs-1
        ;;
        --inputdir=*)
        input_dir="${key#*=}"
        ;;    
        -o|--outputdir)
        shift
        output_dir=${1}
        let nargs=$nargs-1
        ;;
        --outputdir=*)
        output_dir="${key#*=}"
        ;;
        -c|--config)
        shift
        config="${1}"
        let nargs=$nargs-1
        ;;
        --config=*)
        config="${key#*=}"
        ;;
        -p|--pre)
        shift
        oth_="${1}"
        let nargs=$nargs-1
        ;;
        --pre=*)
        oth_="${key#*=}"
        ;;        
        -e|--early-pre)
        shift
        pre_="${1}"
        let nargs=$nargs-1
        ;;
        --early-pre=*)
        pre_="${key#*=}"
        ;;
        -s|--early-post)
        shift
        post_="${1}"
        let nargs=$nargs-1
        ;;
        --early-post=*)
        post_="${key#*=}"
        ;;
        -l|--late-pre)
        shift
        lpost="${1}"
        let nargs=$nargs-1
        ;;
        --late-post=*)
        lpost="${key#*=}"
        ;;
        -n|--nthreads)
        shift 
        nthreads="$1"
        let nargs=$nargs-1
        ;;
        --nthreads=*)
        nthreads="${key#*=}"
        ;;
        -f|--force)        
		force=1	
        ;;
        -v|--verbose)        
		verbose=1	
        ;;       
        *)
        # extra option
        echo "Unknown option '$key'"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done



code_dir=${output_dir}'/code/'
mkdir -p ${code_dir}

config_file=${code_dir}'/'$( basename ${config} )

if [ $( exists ${config_file} ) -eq 0 ]; then 

	cp ${config} ${code_dir}

fi

sub=0

dcm2bids_scaffold -o ${output_dir}


cd ${input_dir}

###################################################################################################################
######### 	Main
###################################################################################################################


for i in $( ls * -d ); 
	do 
	sub=$(( $sub + 1 ))
	[ -d ${i} ] || { continue;  };  
	echo $i ;
	sess0=0 
	sess1=0 
	sess2=0 
	sess3=0 
	sess_n=0
	sub_pad=`printf "%02d" ${sub}`;
	list_=$( ls   ${i}'/'*  -d )
	
	sub_string1='_AAABBCCAABBC'
	sub_string2='_BBBBBCCBBBBC'
	sub_string3='_CCCBBCCCCBBC'
	sub_string4='_DDDBBCCDDBBC'
	
	[ -z ${oth_} ] || { list_=${list_//${oth_}/${sub_string1}};}
	[ -z ${pre_} ] || { list_=${list_//${pre_}/${sub_string2}};}
	[ -z ${post_} ] || { list_=${list_//${post_}/${sub_string3}};}
	[ -z ${lpost_} ] || { list_=${list_//${lpost}/${sub_string4}};}
	
	
	array=( $( echo "${list_}" ) )
	readarray -t list_sorted < <(printf '%s\0' "${array[@]}" | sort -z | xargs -0n1)

	
	for j in ${list_sorted[@]} ; 
		do 
		
		sess=''
		
		if ! [ -z ${oth_} ]; then
			j=${j//${sub_string1}/${oth_}};
			[ $( str_index ${j} ${oth_} ) -eq -1 ] || { sess0=$(( ${sess0}+1 )); sess_pad=`printf "%02d" ${sess0}`;sess="pre"-${sess_pad} ;}
		fi

		if ! [ -z ${pre_} ]; then	
			j=${j//${sub_string2}/${pre_}}	
			[ $( str_index ${j} ${pre_} ) -eq -1 ] || { sess1=$(( ${sess1}+1 )); sess_pad=`printf "%02d" ${sess1}`;sess="earlypre"-${sess_pad} ;}
		fi
		
		if ! [ -z ${post_} ]; then				
			j=${j//${sub_string3}/${post_}}
			[ $( str_index ${j} ${post_} ) -eq -1 ] || { sess2=$(( ${sess2}+1 )); sess_pad=`printf "%02d" ${sess2}`;sess="earlypost"-${sess_pad} ;}
		fi
		
		if ! [ -z ${lpost} ] ; then
			j=${j//${sub_string4}/${lpost}}
			[ $( str_index ${j} ${lpost} ) -eq -1 ] || { sess3=$(( ${sess3}+1 )); sess_pad=`printf "%02d" ${sess3}`;sess="latepost"-${sess_pad} ;}
		fi
		
		if ( [ -z ${oth_} ] && [ -z ${pre_} ] && [ -z ${post_} ] && [ -z ${lpost} ] ) ; then	
		
			sess_n=$(( ${sess_n}+1 )); 
			sess=`printf "%02d" ${sess_n}`
		
		fi
		
		echo  ${j} ; 
		dcm2bids -d ${input_dir}'/'"${j}" \
		-p ${sub_pad}  -s ${sess}  \
		-c ${config} -o ${output_dir} 

	done 
done


