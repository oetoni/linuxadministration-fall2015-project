#!/bin/bash
# Linux Administration - FSHN.edu.al - Fall 2015, Semestral Project
# Team Members: Roberta B., Nikolin N., Elton N.

#Script that finds files that have recently been modified and emails the results


#Directory to search
myDir=~/public_html

#Set frequency of command in minutes, this should match how often you run the cron job
myFrequency=30 * * * *

#email address for mailing the results
myEmail=n.ngjela@gmail.com

#Create datestamp for subject line
#This makes each subject line unique to prevent message collapsing in Gmail
myDate=`date +%y-%m-%d`
myTime=`date +%H:%M`

#Test if files have been edited
fileCount=`find $myDir -mmin $myFrequency -type f | wc -l`
if [ $fileCount -gt 0 ]
then
	#Write the subject line and set correct form of the word "files" (singular or plural)
	if [ $fileCount -eq 1 ]
	then
		mySubject="Attention! $fileCount File Modified on $myDate at $myTime"
	else
		mySubject="Attention! $fileCount Files Modified on $myDate at $myTime"
	fi
	
	#execute find command and email the results
	find $myDir -mmin $myFrequency -type f | mail -s "$mySubject" $myEmail
#else nothing happens
fi