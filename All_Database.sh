#!/bin/bash

echo "Welcome in DBMS .. Please Choose What You Want To Do And Write Your Choice Or Your Choice Number Below :"
function mainMenu {
	select option in 'CREATE DB' 'LIST DBs' 'CONNECT TO DB' 'DROP DB' 'Exit';
	do 
		case $REPLY in 
			1) echo 'CREATE DATABASE' ; createDB;
				;;
			2) echo 'LIST DATABASES'; ListDB ;
				;;
			3) echo 'CONTECT TO DATABASE'; connectDB;
				;;
			4) echo 'DROP DATABASE'; dropDB;
				;;
			5) echo 'EXIT'; cd $HOME/Shell_project; break; 
				;;	
			*) echo 'Pls choose a valid option'
				;;
		esac
	done	

}
   
function createDB {
	
	
	   echo "Enter The Name Of Database :"
	   read database_name
	   mkdir $database_name 2>>$HOME/.error.logi
	   if [[ $? == 0 ]]
  		then
			echo "Database Created Successfully"
			echo "-------------------------------------"
  	  	else
    	echo "Error Creating Database $database_name"
		echo "-------------------------------------"
  	   fi
	
	mainMenu
}

function ListDB {

	   echo "------------------------------------------------"
           ls | tree
	   echo "------------------------------------------------"
	mainMenu

}

function connectDB {

	echo "------------------------------------------------"
	echo "Enter The Name Of Database You Want To Connect :"
	read connect
	if ! [[ -d $connect ]]; then
    		echo "DB Is Not Existed";
			echo "------------------------------------------------"
    		mainMenu;
	else
		cd $connect 2>>$HOME/.error.logi
		clear
		TableOptions 
  	fi

}

function dropDB {
       
	echo "Enter The Name Of Database You Want To Drop :"
	read drop
		if [[ -d $drop ]]; then
			echo "Are You Sure You Want To Drop The Table? Note That The Content Will Be Deleted Too!  Y/N"
			read drop_choice

			if [[ ${drop_choice^^} == "Y" || ${drop_choice^^} == "YES" ]]; then	
				rm -r $drop
				echo "Done"
				echo "---------------------------------------------"
			else 
				echo "Drop is Failed "
				echo "---------------------------------------------"
			fi

		else
			echo "DB Is Not Existed";
			echo "---------------------------------------------"
		fi

	mainMenu

}

###################################################################################################################

	 
	 function TableOptions {
		# clear;
		echo "You Are Connected To $connect Database "
	    echo "Please Choose What You Want To Do And Write Your Choice Or Your Choice Number Below"
	 	echo "----------------------------------------------"

	select option in 'List TABLES' 'CREATE TABLE' 'DROP TABLE' 'SELECT FROM' 'DELETE FROM TABLE' 'INSERT INTO' 'UPDATE TABLE' 'Back to Main Menu' ;
	do
		case $REPLY in
			1)echo 'List Table:'; ListTable;
				;;
			2)echo 'Create Table:'; createTable;
				;;
			3)echo 'Drop Table:'; dropTable;
				;;
			4)echo 'Select from:'; selectFromTable;
				;;
			5)echo 'Delete From Table:';deleteFromTable;
				;;
			6)echo 'Insert into:'; insertIntoTable;
				;;
			7)echo 'Update Table:';updateTable;
				;;
			8) cd $HOME/Shell_project; mainMenu;
			    ;;
			*)echo 'Please choose a valid option';
				;;
		esac

	done
  }
  

function createTable {
	echo  " Enter table name:";
  	read tName
		while [[ -f $tName || $tName == "" ]]
		do
			echo "Please Enter A Vaild Name";
			read tName
		done

	echo  "Enter number of Columns:"
	read colNumber
			while ! [[ $colNumber =~ ^[0-9]+$ ]]
			do
				echo "This is Not A Number , Please Enter A Vaild Number";
				read colNumber
			done

  	flag=1
  	FS="|"
  	RS="\n"
  	PK=""
  	metaData="Field"$FS"Type"$FS"key"
	tData=""

  	while [ $flag -le $colNumber ]
  	do
  		echo  "Enter name of Column Number $flag: "
    	read colName
			while [[ $colName == "" ]]
			do
				echo "please Enter A Valid Name :"
				read colName
			done


    		echo  "Enter type of column $colName: "
    		select type in "int" "str"
    		do
    			case $type in
        			int ) colType="int";break
						;;
        			str ) colType="str";break
						;;
        			* ) echo "Not a valid option , Choose Again:" 
						;;
      			esac
    		done

			if [[ $PK == "" ]]; 
			then
      			echo  "Do you want to make that column as a Primary Key ? "
      			select choice in "yes" "no"
      			do
        			case $choice in
          				yes ) PK="PK";
          				metaData+=$RS$colName$FS$colType$FS$PK;
          					break;;
							  
          				no )
          				metaData+=$RS$colName$FS$colType$FS""
          					break;;
          				* ) echo "Not a valid option" ;;
        			esac
      			done

    		else
      			metaData+=$RS$colName$FS$colType$FS""
    		fi

    		if [[ $flag == $colNumber ]]; 
    		then
    			tData=$tData$colName
    		else
      			tData=$tData$colName$FS
    		fi
			((flag++))
	done

	touch .$tName
  	echo $metaData  >> .$tName
  	touch $tName
  	echo  $tData >> $tName
  	if [[ $? == 0 ]]
  	then
    		echo "Table Created Successfully"
			echo "---------------------------------------------"
    		TableOptions;
  	else
    		echo "Error Creating Table $tName"
    		TableOptions;
  	fi
}

function ListTable {
       echo "------------------------------------------------"
       ls | tree
       echo "------------------------------------------------"
		
	 
}
function dropTable {
       echo "---------------------------------------------"
          	echo "Enter The Name Of table You Want To Drop :"
          	read drop_table
			if [[ ! -f $drop_table || $drop_table == "" ]]; then
    	     	echo "table not existed";
	        else
         	echo "Are You Sure You Want To Drop The Table ? Y/N"
          	read drop_table_choice

          		if [[ ${drop_table_choice^^} == "Y" || ${drop_table_choice^^} == "YES" ]]
          		then
              		rm $drop_table
					echo "Done"
          		else
					echo "Drop is Failed "
          		fi
			fi
	 
}

function insertIntoTable {
	echo "Table Name: "
  	read tName
  	if ! [[ -f $tName ]]; 
	then
		echo "Table $tName isn't existed"
		echo "---------------------------------------------"
		TableOptions;
  	fi
  	colsNum=`awk 'END{print NR}' .$tName`
  	sep="|"
  	rSep="\n"
	row=""
		for (( i = 2; i <= $colsNum; i++ )); 
		do
			colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tName)
			colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tName)
			colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}'  .$tName)
			echo "$colName ($colType) = "
			read data

				# Validate Input
			if [[ $colType == "str" ]];
			then
				while [[ ! $data =~ ^[a-zA-Z]*$ || $data == "" ]];
				do
					echo "DataType should be string"
					echo "$colName ($colType) = "
					read data
				done
			fi

				if [[ $colType == "int" ]]; 
				then
					while [[ ! $data =~ ^[0-9]*$ || $data == "" ]]; 
					do
						echo "DataType should be integer"
						echo "$colName ($colType) = "
						read data
					done
				fi
				# check existance of PK
				if [[ $colKey == "PK" ]]; 
				then
					while [[ true ]]; 
					do
					existedVal=$(awk 'BEGIN{FS="|"}{if ($(('$i'-1)) =="'$data'") print $(('$i'-1))}' $tName 2>>./.error.log)
							if [[ $existedVal == "" ]]
							then
								break;
							else
								echo "$existedVal is existed choose another value for the PK"
								echo "$colName ($colType) = "
								read data
							fi
					done
				fi

				#Creating a row (record)
				if [[ $i == $colsNum ]]; 
				then
					row=$row$data
				else
					row=$row$data$sep
				fi
		done
	  
  	echo  $row >> $tName
  	if [[ $? == 0 ]]
  	then
		echo "Data Inserted Successfully"
  	else
		echo "Error Inserting Data into Table $tName"
  	fi  
  	TableOptions;
}



function selectFromTable {
	
	echo 'SELECT OPTIONS:';
	select option in 'Select All' 'Select Where' 'Back to table Menu' 
	do
		case $REPLY in 
			1)echo " SELECT ALL "; selectAll;
				;;
			2)echo " SELECT USING WHERE CLAUSE"; selectWhere;
				;;
			3)echo "BACK TO TABLES MENUE"; TableOptions;
				;;
			*)echo "Pls Enter a valid Option :"
				;;
		esac
	done

}

function selectAll {
  	echo "Enter Table Name: ";
	read tableName
		if ! [[ -f $tableName ]];
			then
				echo "Table $tableName isn't existed ,choose another Table";
		else
			column -t -s '|' $tableName 2>>./.error.log;
			echo "------------------------------------------"
			TableOptions				
				if [[ $? != 0 ]]
				then
					echo "Error Displaying Table $tName"
				fi
       	fi
}

function selectWhere {
  	echo "SELECT FROM TABLE: "
  	read tName

		if ! [[ -f $tName ]];
		then
			echo "Table $tName isn't existed ,choose another Table";
			selectFromTable;
		fi

	echo  "WHERE (COL): "
  	read field
  	fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  	if [[ $fid == "" ]]
  	then
    		echo "Column $field not found";
    		selectFromTable;	
  	else
  		echo "Operators: [==, !=, >, <, >=, <=] Select OPERATOR: "
		read op
    		if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
    		then
      			echo "Select all where $field $op (Enter The VALUE)  "
      			read val
      			res=$(awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log)
      			if [[ $res == "" ]]
      			then
        			echo "No Results";
        			selectFromTable;
      			else
        			echo "---------------------------------------------------- "
				awk 'BEGIN{FS="|"}{if ($'$fid$op$val' || NR == 1) print $0}' $tName 2>>./.error.log |  column -t -s '|';
        			echo "---------------------------------------------------- "
      			fi
    		else
      			echo "Unsupported Operator";
      			selectFromTable
    		fi
  	fi
}

function deleteFromTable {
  	echo "Enter Table Name:"
  	read tName

	if ! [[ -f $tName ]];
        then
                echo "Table $tName isn't existed";
                TableOptions;
        fi

	echo "Delete WHERE (Col)"
  	read field
  	fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  	if [[ $fid == "" ]]
  	then
    		echo "Not Found"
    		TableOptions;
  	else
    		echo  "Enter WHERE $field ="
    		read val
    		res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    		if [[ $res == "" ]]
    		then
      			echo "Value Not Found"
      			TableOptions;
    		else
      			NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
      			sed -i ''$NR'd' $tName 2>>./.error.log
				if [[ $? == 0 ]]
				then
      				echo "Record Deleted Successfully"
				else
					echo "Error IN DELETING THAT REDORD"
				fi
      			TableOptions;
    		fi
  	fi
}


function updateTable {
  	echo "Enter Table Name:"
  	read tName

  	if ! [[ -f $tName ]];
        then
                echo "Table $tName isn't existed ";
		TableOptions;
	fi

	echo "UPDATE WHERE CONDITION (COL)"
  	read field
  	fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  	
	if [[ $fid == "" ]]
  	then
    		echo "Not Found"
    		TableOptions;
  	else
		echo "UPDATE WHERE CONDITION (VAL)"
    		read val
    		res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    		if [[ $res == "" ]]
    		then
      			echo "Value Not Found"
      			TableOptions;
    		else
			echo "UPDATE TO (COL)"
      			read setField
      			setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tName)
      			if [[ $setFid == "" ]]
      			then
        			echo "Not Found"
        			TableOptions;
     		 	else
				echo "UPDATE TO (VAL):"
        			read newValue
        			NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tName 2>>./.error.log)
        			oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tName 2>>./.error.log)
        			sed -i "$NR s/$oldValue/$newValue/g" $tName 2>>./.error.log
        			echo "Row Updated Successfully"
        			TableOptions;
      			fi
    		fi
  	fi
}
	 
mainMenu	 
$SHELL

