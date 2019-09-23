#!/bin/sh
#Usage:: AddFiles.sh <TargetFolderPath> <ZipFileType-true/false> <ZipFileOrSingleFilePath> <ZipFileOrSingleFileName>
#Sample Usage::  AddFiles.sh "Path to folder above VMAppWithKonylib folder" "VMAppWithKonylib" "true" "Path to zip file containing AppDelegateExtension Files" "Zip File Name"

if [ "$#" -eq 5 ]; then
 echo "Correct number of parameters"
 TGT_FOLDER_PATH="$1"
 TGT_FOLDER="$2"
 ZIP_FILE_TYPE="$3"
 FILE_PATH="$4"
 FILE_NAME="$5"
 echo "TGT_FOLDER_PATH => $TGT_FOLDER_PATH"
 echo "TGT_FOLDER => $TGT_FOLDER"
 echo "ZIP_FILE_TYPE => $ZIP_FILE_TYPE"
 echo "FILE_PATH => $FILE_PATH"
 echo "FILE_NAME => $FILE_NAME"

   if [ -f "$FILE_PATH/$FILE_NAME" ]; then
       echo "$FILE_PATH/$FILE_NAME exists"
       echo "Now checking if Target folder exists.."
       if [ -d "$TGT_FOLDER_PATH/$TGT_FOLDER" ]; then
           echo "$TGT_FOLDER_PATH/$TGT_FOLDER exists!"
           echo "Switching to $TGT_FOLDER_PATH/$TGT_FOLDER"
           cd $TGT_FOLDER_PATH/$TGT_FOLDER
           echo "Current folder is.."
           pwd
           echo "ZIP_FILE_TYPE is $ZIP_FILE_TYPE"
           if [ $ZIP_FILE_TYPE = "true" ]; then
              echo "Copying $FILE_PATH/$FILE_NAME to $TGT_FOLDER_PATH/$TGT_FOLDER"
              cp -rf $FILE_PATH/$FILE_NAME $TGT_FOLDER_PATH/$TGT_FOLDER
              if [ -f "$TGT_FOLDER_PATH/$TGT_FOLDER/$FILE_NAME" ]; then
                echo "Successfully copied $FILE_NAME"
                echo "Extracting $FILE_NAME"
                tar -xf $FILE_NAME
                echo "Removing $FILE_NAME"
                rm -f $FILE_NAME
              else
                echo "Failed to copy the file $FILE_NAME"
              fi
           else
            echo "Since ZIP_FILE_TYPE is $ZIP_FILE_TYPE so input file $FILE_NAME is an individual file to be copied to $TGT_FOLDER_PATH/$TGT_FOLDER"
            cp -rf $FILE_PATH/$FILE_NAME $TGT_FOLDER_PATH/$TGT_FOLDER
            if [ -f "$TGT_FOLDER_PATH/$TGT_FOLDER/$FILE_NAME" ]; then
              echo "Successfully copied $FILE_NAME"
            else
              echo "Failed to copy the file $FILE_NAME"
            fi
           fi
       else
         echo "$TGT_FOLDER_PATH not found!"
       fi
   else
     echo "$FILE_PATH/$FILE_NAME not found!"
   fi
else
 echo "Incorrect number of parameters!"
fi
