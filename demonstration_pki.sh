#!/bin/bash

#This script is a demonstration of a local pki. It based on the pki tutorial written by Stefan H. Holek, big thanks to him (link : https://pki-tutorial.readthedocs.io/en/latest/simple/index.html )

echo "Welcome to this presentation about the pki. This is based on the pki tutorial written by Stephan H. Holek ( https://pki-tutorial.readthedocs.io/en/latest/simple/index.html ) "
read -p "Press any key to continue"
clear

#Under all the global variable fir set some different comportement
verbose="enable"
export $verbose

#control structure, check if git, openssl and others softwares are installed
if ( ! test -e `which git` ) #Is git install ?
then
	echo "Git is not installed, would you like to install it ? (not already supported)"
fi
if ( ! test -e `which openssl` ) #Is openssl install ?
then
	echo "Openssl is not installed, would you like to install it ? (not already supported)"
fi

#Clone the repo
if test "$verbose" = "enable" 
then
	echo "Cloneing the repo online..."
fi

#If pki-example-1 exist, we ask for its destruction, else we clone the repo
if test -d "./pki-example-1" 
then
	echo "The pki structure already exist, would you like to rewrite on it ?"
	select choice in "yes" "no"
	do
		if ( test $REPLY = "yes" )
		then
			rm -r "./pki-example-1"
			`git clone -q https://bitbucket.org/stefanholek/pki-example-1`
			break
		elif ( test $REPLY = "no" )
		then
			break	
		fi
	done
	choice="" #Uninit choice var
else
	`git clone -q https://bitbucket.org/stefanholek/pki-example-1`
fi

if test "$verbose" = "enable" && test -d "./pki-example-1"	
then
	echo -e "Repo cloned ! \n"
	echo "Creation of the tree structure..."
fi

#Creation of the pki tree structure
#Creation of the ca/ directory
if ! test -d "./pki-example-1/ca"
then
	mkdir "./pki-example-1/ca"
	if test "$verbose" = "enable" 
	then
		echo -e "The ./pki-example-1/ca/ directory has been created \n"
	fi
fi

#Creation of the crl directory
if ! test -d "./pki-example-1/crl"
then
	mkdir "./pki-example-1/crl"
	if test "$verbose" = "enable" 
	then
		echo -e "The ./pki-example-1/crl/ directory has been created \n"
	fi
fi

#Creation of the certs directory
if ! test -d "./pki-example-1/certs/"
then
	mkdir "./pki-example-1/certs/"
	if test "$verbose" = "enable" 
	then
		echo -e "The ./pki-example-1/certs/ directory has been created \n"
	fi
fi

#Creation of the certificates chaine pem file
if test -f ./pki-example-1/certs/certificateschain.pem 
then
	echo -e "The certificatechain.pem already exist, would you like overwrite them ? (Yes is prefered)"
	select choice in "yes" "no"
	do
		if ( test $REPLY = "yes" )
		then
			rm ./pki-example-1/certs/certificateschain.pem
			touch ./pki-example-1/certs/certificateschain.pem
			break
		elif ( test $REPLY = "no" )
		then
			break	
		fi
	done
	choice="" #Uninit choice var
else
	touch ./pki-example-1/certs/certificateschain.pem
fi

treeStructureCrea() {
	name=$1
	#Creation of the ./pki-example-1/ca/$name/ directory
	if ! test -d "./pki-example-1/ca/$name/"
	then
		mkdir "./pki-example-1/ca/$name/"
		if test "$verbose" = "enable" 
		then
			echo -e "The ./pki-example-1/ca/$name/ directory has been created \n"
		fi
	fi

	#Creation of the ./pki-example-1/ca/$name/db/ directory
	if ! test -d "./pki-example-1/ca/$name/db/"
	then
		mkdir "./pki-example-1/ca/$name/db/"
		if test "$verbose" = "enable" 
		then
			echo -e "The ./pki-example-1/ca/$name/db directory has been created \n"
		fi
	fi

	#Creation of the ./pki-example-1/ca/$name/private directory
	if ! test -d "./pki-example-1/ca/$name/private/"
	then
		mkdir "./pki-example-1/ca/$name/private/"
		if test "$verbose" = "enable" && chmod 700 ./pki-example-1/ca/$name/private/
		then
			echo -e "The ./pki-example-1/ca/$name/private directory has been created and secured (chmod)\n"
		else
			echo -e "\n \n \n Warning, cannot apply restricted permission on ./pki-example-1/ca/$name/private/\n"
		fi
	fi
	#Creation of the db and srl files if they don't exist
	if ! test `ls -a ./pki-example-1/ca/$name/db/ | sed -e "/\.\$/d" | wc -l` -eq 0 #This is test if the directory is empty
	then
		echo -e "The db and srl files already exist, would you like overwrite them ?"
		select choice in "yes" "no"
		do
			if ( test $REPLY = "yes" )
			then
				rm ./pki-example-1/ca/$name/db/*
				cp /dev/null ./pki-example-1/ca/$name/db/$name.db
				cp /dev/null ./pki-example-1/ca/$name/db/$name.db.attr
				echo 01 > ./pki-example-1/ca/$name/db/$name.crt.srl
				echo 01 > ./pki-example-1/ca/$name/db/$name.crl.srl
				break
			elif ( test $REPLY = "no" )
			then
				break	
			else
				break
			fi
		done
		choice="" #Uninit choice var
	else
		cp /dev/null ./pki-example-1/ca/$name/db/$name.db
		cp /dev/null ./pki-example-1/ca/$name/db/$name.db.attr
		echo 01 > ./pki-example-1/ca/$name/db/$name.crt.srl
		echo 01 > ./pki-example-1/ca/$name/db/$name.crl.srl
	fi

	if test "$verbose" = "enable" 
	then
		echo -e "$name.db, $name.crt.srl and $name.crl.srl has been created\n"
	fi
}

#Create the root-ca and signing-ca tree structure
treeStructureCrea "root-ca"
echo -e "All the root-ca has been created, press any key to continue"
read
clear
treeStructureCrea "signing-ca"
echo -e "All the singing-ca has been created, press any key to continue"
read
clear

read -p "Warning during the certificate process creation, it will you ask for a pass phrase, please enter isep. Press any key to continue..."
clear

signing() {
	authorities=$1
	require=$2
	keypath=$3
	extensions=$4

	#Creation of the csr
	echo -e "Creation of the certificate signing request (csr) of the $require :"
	if test "$verbose" = "enable" 
	then
		echo -e "openssl req -new -config ./pki-example-1/etc/$require.conf -out ./pki-example-1/certs/$require.csr -keyout $keypath/$require.key \n" 
	fi
	openssl req -new -config ./pki-example-1/etc/$require.conf -out ./pki-example-1/certs/$require.csr -keyout $keypath/$require.key
	
	read -p "Press any key to continue"
	clear
	#Print the authorities db before the signing of the certificate
	echo -e "Below you see the content of the $authorities.db file which contains all signed certificates BEFORE signs the new certificates :\n"
	cat ./pki-example-1/ca/$authorities/db/$authorities.db
	read -p "Press any key to continue..."
	clear

	#Check if the require are the root-ca
	if ( test $require = $authorities ) 
	then
		ifSelfsigned="-selfsign"
	else
		ifSelfsigned=""
	fi
	
	#Signing of the csr
	echo -e "The $authorities authority will sign the $require csr :"
	if test "$verbose" = "enable" 
	then
		echo -e "openssl ca $ifSelfsigned -config ./pki-example-1/etc/$authorities.conf -in ./pki-example-1/certs/$require.csr -out ./pki-example-1/certs/$require.crt -extensions $extensions \n" 
	fi
	openssl ca $ifSelfsigned -config ./pki-example-1/etc/$authorities.conf -in ./pki-example-1/certs/$require.csr -out ./pki-example-1/certs/$require.crt -extensions $extensions 

	#Add the certificates to the certificates chain pem file
	cat ./pki-example-1/certs/$require.crt >> ./pki-example-1/certs/certificateschain.pem

	#Print the authorities db after the signing of the certificate
	echo -e "\n Below you see the content of the $authorities.db file which contains all signed certificates AFTER signs the new certificates:\n"
	cat ./pki-example-1/ca/$authorities/db/$authorities.db 

	#Ask if you want to see the certificate
	echo -e "\n Would you like to see the $require certificate ?"
	select choice in "yes" "no"
	do
		if ( test $REPLY = "yes" )
		then
			 
			if test "$verbose" = "enable" 
			then
				echo -e "openssl x509 -text -noout -in ./pki-example-1/certs/$require.crt"
			fi
			openssl x509 -text -noout -in ./pki-example-1/certs/$require.crt
			read -p "Press any key to continue..."
			break
		elif ( test $REPLY = "no" )
		then
			break	
		fi
	done
	choice="" #Uninit choice var
	clear

	#Check the certificates validity
	echo -e "Is the certificate valid ?"
	if test "$verbose" = "enable" 
	then
		echo -e "We check the validity thought openssl verify command and by using pem certificates bundle which contain all certificates chain"
	       echo -e "openssl verify --CAfile ./pki-example-1/certs/certificateschain.pem ./pki-example-1/certs/$require.crt \n"
	fi
	openssl verify --CAfile ./pki-example-1/certs/certificateschain.pem ./pki-example-1/certs/$require.crt
	read -p "\n Press any key to continue..."
	clear
}

#create then sign the certificates
signing "root-ca" "root-ca" "./pki-example-1/ca/root-ca/private" "root_ca_ext"
signing "root-ca" "signing-ca" "./pki-example-1/ca/signing-ca/private" "signing_ca_ext"
signing "signing-ca" "server" "./pki-example-1/certs" "server_ext"

