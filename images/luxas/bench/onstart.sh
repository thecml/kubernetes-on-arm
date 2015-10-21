#!/bin/bash

whets(){
	cat $1 | grep "MWIPS" | awk '{print "WHETSTONE " $2 "\n"}'
}
dhrystone(){
	cat $1 | grep "MIPS rating" | grep -o "[0-9.]*" | awk '{print "DHRYSTONE " $1 "\n"}'
}
linpackdp(){
	cat $1 | grep "Speed" | awk '{print "LINPACKDP " $2 "\n"}'
	mv $1 linpackdp.txt
}
linpacksp(){
	cat $1 | grep "Speed" | awk '{print "LINPACKSP " $2 "\n"}'
	mv $1 linpacksp.txt
}
memspeed(){
	cat $1 | grep " 8 " | awk '{print "L1 " $2 " " $3 " " $5 " " $6 "\n"}'
	cat $1 | grep " 32 " | awk '{print "L2 " $2 " " $3 " " $5 " " $6 "\n"}' | grep "[a-z]" -v
	cat $1 | grep " 256 " | awk '{print "RAMLOW " $2 " " $3 " " $5 " " $6 "\n"}'
	cat $1 | grep " 262144 " | awk '{print "RAMHIGH " $2 " " $3 " " $5 " " $6 "\n"}'

	cat $1 | grep " 256 " | awk '{print "MIPSLOW " $4 " " $7 " " $10  "\n"}'
	cat $1 | grep " 262144 " | awk '{print "MIPSHIGH " $4 " " $7 " " $10  "\n"}'
}

liverloops(){
	cat $1 | grep -A2 "Overall Ratings" | grep "[0-9]" | awk '{print "LIVERLOOPS " $3 "\n"}'
}

busspeed(){
	cat $1 | grep " 16 " | awk '{print "BUSLOW " $7 "\n"}'
	cat $1 | grep " 65536 " | awk '{print "BUSHIGH " $7 "\n"}'
}


cd "/bench/Source Code"


OPTS=
case "$(uname -m)" in
  armv7*)
    OPTS="-lm -O3 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard";;
  armv6*)
	OPTS="-lm -O3 -march=armv6 -mfpu=vfp -mfloat-abi=hard"
	
esac


TESTS=(
	"whets.c:cpuidc.c, whets, whets.txt"
	"linpack.c:cpuidc.c, linpackdp, Linpack.txt"
	"linpacksp.c:cpuidc.c, linpacksp, Linpack.txt"
	"dhry.h:dhry_1.c:dhry_2.c:cpuidc.c, dhrystone, Dhry.txt"
	"memspeed.c:cpuidc.c, memspeed, memSpeed.txt, MB:256"
	"lloops2.c:cpuidc.c, liverloops, LLloops.txt"
	"busspeed.c:cpuidc.c, busspeed, busSpeed.txt"
)

for TESTSTR in "${TESTS[@]}"; do
	IFS=', ' read -a TEST <<< "$TESTSTR"
	FILES="${TEST[0]}"
	FILES="${FILES//:/ }"
	OUTPUT="${TEST[1]}"
	LOG="${TEST[2]}"
	ARG="${TEST[3]}"
	ARG="${ARG//:/ }"

	if [[ -z $NORMAL ]]; then
 		{ time gcc $FILES $OPTS -o $OUTPUT; } 2>> /perf/compiletid.log

		./$OUTPUT $ARG <<EOF

EOF
	fi

	echo -e "$($OUTPUT $LOG)" >> /perf/perf.log
	echo "" >> /perf/perf.log
	echo "Done with $OUTPUT"
done

cd /perf

# Compile the program
{ g++ -std=c++11 main.cpp -o compute 2>&1; } 2>> /perf/compiletid.log

cat compiletid.log | grep "real" | grep -o "[0-9]m[0-9]*" >> tid.log

cat tid.log | tr '\n' ' '

# Calculate the results of the benchmarks
./compute

echo "Results is in /perf/results.json"

cat /perf/results.json

exit 0