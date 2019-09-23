#!/bin/sh
#Usage:: AppDelegateFilesReplace.sh <TargetFolderPath> <ZipFilePath> <ZipFileName>
#Sample Usage::  AppDelegateFilesReplace.sh "Path to VMAppWithKonylib.xcodeproj folder" "Path to zip file containing AppDelegateExtension Files" "Zip File Name"

if [ "$#" -eq 3 ]; then
 echo "Correct number of parameters"
 TGT_FOLDER_PATH="$1"
 ZIP_FILE_PATH="$2"
 ZIP_FILE_NAME="$3"

 if [ -f "$ZIP_FILE_PATH/$ZIP_FILE_NAME" ]; then
   echo "$ZIP_FILE_PATH/$ZIP_FILE_NAME exists"
   echo "Now checking if Target folder exists.."
   if [ -d "$TGT_FOLDER_PATH" ]; then
     echo "$TGT_FOLDER_PATH exists!"
     echo "switching to echo $TGT_FOLDER_PATH"
     cd $TGT_FOLDER_PATH
     echo "Current folder is.."
     pwd
     cp $ZIP_FILE_PATH/$ZIP_FILE_NAME $TGT_FOLDER_PATH
     if [ -f "$TGT_FOLDER_PATH/$ZIP_FILE_NAME" ]; then
       echo "Successfully copied $ZIP_FILE_NAME"
       if [ -d "AppDelegateExtension" ]; then
         echo "Found existing AppDelegateExtension folder... listing.."
         ls AppDelegateExtension
         echo "Removing existing files/folder"
         rm -rf AppDelegateExtension
         echo "Removed AppDelegateExtension folder.."
         ls AppDelegateExtension
       fi
       echo "extracting the new zip file now..."
       tar -vxf $ZIP_FILE_NAME
       rm -f $ZIP_FILE_NAME
       echo "Listing current folder"
       ls
     else
       echo "Failed to copy the zip file"
     fi
   else
     echo "$TGT_FOLDER_PATH not found!"
   fi
 else
   echo "$ZIP_FILE_PATH/$ZIP_FILE_NAME not found!"
 fi
else
  echo "Incorrect number of parameters!"
fi
