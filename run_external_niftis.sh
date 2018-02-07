#! /bin/bash

#Written by Moosa Ahmed 10/01/2017
#Last Edited 01/30/2018

options=`getopt -o n:p:s:h -l study-name:,pipe-name:,sublist:,help -n 'run_external_niftis' -- $@`
eval set -- "$options"

function display_help() {
	echo "Usage: `basename $0` [options...]"
	echo "Runs all the subjects listed in the csv through the pipeline"
	echo "	Required:"
	echo "	-n|--study-name 	Name of your study"
	echo "	-p|--pipe-name 		Name of your pipeline"
	echo "	-s|--sublist 		Full path to csv file with subject ids in the 1st column,"
	echo "				visit name in the 2nd column seperated by comma No headers."
	echo "	Optional:"
	echo "	-h|--help		Display this message"
	exit $1
}

echo "`basename $0` $options"
debug=0

# extract options and thier arguments into variables.
while true ; do
	case "$1" in
		-n|--study-name)
			STUDY_NAME="$2"
			shift 2
			;;
		-p|--pipe-name)
			PIPE_NAME="$2"
			shift 2
			;;
		-s|--sublist)
			SUB_LIST="$2"
			shift 2
			;;
		-h|--help)
			display_help;;
		--) shift ; break ;;
		*) echo "Unexpected error parsing args!" ; display_help 1 ;;
	esac
done

# Check to see if required args are defined
if [ -z ${STUDY_NAME} ] || [ -z ${PIPE_NAME} ] || [ -z ${SUB_LIST} ];
	then display_help 1
fi

# Check to see if sublist was found
if [ ! -e "${SUB_LIST}" ];
	then
	echo "ERROR: sublist not found"
	exit 1
fi

# Loops through each subject in the subject list, creates HcpGenericWrapper and sbatch it.
while IFS=, read SUB_ID VISIT;do			

	mkdir -p /home/exacloud/lustre1/fnl_lab/data/HCP/processed/${STUDY_NAME}/${SUB_ID}/${VISIT}/${PIPE_NAME}/hcponeclick_all/HcpGenericWrapper

	/home/exacloud/lustre1/fnl_lab/code/internal/pipelines/hcponeclick_all/sbatch_maker.sh --script=/home/exacloud/lustre1/fnl_lab/data/HCP/processed/${STUDY_NAME}/${SUB_ID}/${VISIT}/${PIPE_NAME}/hcponeclick_all/HcpGenericWrapper/submit_HcpGenericWrapper.sh --name=HcpGenericWrapper --mem=100M --time=SHORT --cpus-per-task=1 --output=/home/exacloud/lustre1/fnl_lab/data/HCP/processed/${STUDY_NAME}/${SUB_ID}/${VISIT}/${PIPE_NAME}/hcponeclick_all/HcpGenericWrapper/HcpGenericWrapper --error=/home/exacloud/lustre1/fnl_lab/data/HCP/processed/${STUDY_NAME}/${SUB_ID}/${VISIT}/${PIPE_NAME}/hcponeclick_all/HcpGenericWrapper/HcpGenericWrapper --exec=/home/exacloud/lustre1/fnl_lab/code/internal/pipelines/hcponeclick_all/run_node.py -id ${SUB_ID} -s /home/exacloud/lustre1/fnl_lab/data/HCP/processed/${STUDY_NAME}/${SUB_ID}/${VISIT}/${PIPE_NAME} --node HcpGenericWrapper

	pushd /home/exacloud/lustre1/fnl_lab/data/HCP/processed/${STUDY_NAME}/${SUB_ID}/${VISIT}/${PIPE_NAME}/hcponeclick_all/HcpGenericWrapper
	sbatch submit_HcpGenericWrapper.sh
	popd
done < "${SUB_LIST}"
