#!/bin/sh -x

ITYPE=`curl -s http://169.254.169.254/latest/meta-data/instance-type`
KFACTOR=`cat $HOME/voltwrangler_params.dat | awk '{ print $2 }'`
CMDLOGGING=`cat $HOME/voltwrangler_params.dat | awk '{ print $3 }'`
DEMONAME=`cat $HOME/voltwrangler_params.dat | awk '{ print $5 }'`
SPH=`cat $HOME/voltwrangler_params.dat | awk '{ print $7 }'`
NODECOUNT=`cat $HOME/voltwrangler_params.dat | awk '{ print $10 }'`

TNAME=$1
AMI=$2
echo -n AMI:TESTNAME:INSTANCE:KFACTOR:CMDLOGGING:DEMONAME:SPH:NODECOUNT:



JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

if 
	[ ! -d ${JAVA_HOME} ]
then
	sudo apt update
	sudo apt install -y openjdk-8-jdk
fi

export JAVA_HOME

PATH=${JAVA_HOME}/bin:${PATH}
export PATH

java -version

cd

if
        [ ! -r YCSB ]
then
        git clone https://github.com/brianfrankcooper/YCSB.git
fi

cd YCSB

RECCOUNT=1000000
TC=50

echo recordcount=${RECCOUNT}> volt.properties
echo operationcount=10000000 >> volt.properties
echo voltdb.servers=`cat $HOME/.vdbhostnames` >> volt.properties
echo threadcount=${TC}>> volt.properties
echo maxexecutiontime=300 >> volt.properties

bin/ycsb.sh load voltdb -P workloads/workloada -P volt.properties
bin/ycsb.sh load voltdb -P workloads/workloada -P volt.properties


MAX_TC=25
for i in a b c d e
#for i in e
do
	DATAFILE=${HOME}/`date +'%Y%M%d_%H%m'`_${i}.txt
	echo $LOGFILE
	HEADER=""
	TC=1
	while
		[ "${TC}" -le "${MAX_TC}" ]
	do

	        LOGFILE=${HOME}/`date +'%Y%M%d_%H%m'`_${i}_${TC}.lst


		echo recordcount=${RECCOUNT}> volt.properties
		echo operationcount=1000000000 >> volt.properties
		echo voltdb.servers=`cat $HOME/.vdbhostnames` >> volt.properties
		echo threadcount=${TC}>> volt.properties
		echo maxexecutiontime=300 >> volt.properties
	
		echo RUN_STARTING `date` TC=${TC} Workload=${i} 
	        bin/ycsb.sh run voltdb -P workloads/workload${i} -P volt.properties | tee -a $LOGFILE

		if
			[ "$HEADER" = "" ]
		then
			HEADER=`sh $HOME/volt-run-ycsb/gather_stats.sh ${LOGFILE} HDR`
			echo  AMI:TESTNAME:INSTANCE:KFACTOR:CMDLOGGING:DEMONAME:SPH:NODECOUNT:${TC}:$HEADER > $DATAFILE
		fi 

		BODY=`sh $HOME/volt-run-ycsb/gather_stats.sh ${LOGFILE} `
		echo ${AMI}:${TNAME}:${ITYPE}:${KFACTOR}:${CMDLOGGING}:${DEMONAME}:${SPH}:${NODECOUNT}:${TC}:$BODY >> $DATAFILE

		sh $HOME/volt-run-ycsb/check_aws_network_limits.sh 

	        sleep 30
		TC=`expr $TC + 1`
	done
	
	sleep 300

done

