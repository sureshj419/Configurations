#!/bin/sh
#Usage:: AddImportText.sh <TargetHeaderFileName.h> <Comma Seperated header files names to be added in import section>
#Sample Usage::  AddImportText.sh sample.h abc.h,def.h

if [ "$#" -eq 2 ]; then
 echo "Correct number of parameters"
 TGT_FILE="$1"
 HDR_FILE_NAMES="$2"
 TGT_TXT=""
 IMP_TXT="#import "
 nwl=$'\n'
#IFS=","
 i=0
#for hdrfile in ${HDR_FILE_NAMES}
#do
#   i=$((++i))
#   eval HDR_FILE_NAMES${i}="${hdrfile}"
# done

#for ((j=0;j<=i;++j))
# do
#   HDR_FILE_NAME="HDR_FILE_NAMES${j}"
#   TGT_TXT=$(echo "${TGT_TXT}${IMP_TXT}\"${!HDR_FILE_NAME}\"")
#  TGT_TXT="${TGT_TXT}${nwl}"
#done

#commented above as it fails for File Names with spaces
echo "$HDR_FILE_NAMES" | awk 'BEGIN{FS=",";OFS="\n"}{$1=$1;print $0}'>tempFile
while read line;
    do
        HDR_FILE_NAMES["$i"]="$line"
        i=$(expr $i + 1)
    done<tempFile

for ((j=0;j<i;++j))
 do
    #HDR_FILE_NAME="HDR_FILE_NAMES[$j]"
    TGT_TXT=$(echo "${TGT_TXT}${IMP_TXT}\"${HDR_FILE_NAMES[${j}]}\"")
    TGT_TXT="${TGT_TXT}${nwl}"
done

 echo "Final TGT_TXT is as below..."
 echo "${TGT_TXT}"

#Moving the content to a temperory file as File Name with spaces has an issue
echo "${TGT_TXT}" | cat - "${TGT_FILE}" > /tmp/out
mv /tmp/out "${TGT_FILE}"
else
  echo "Incorrect number of parameters!"
fi
