#Consulta en Virus Total IOC para comprobar que son cubiertos por el AV McAfee
#Autor Agustin Alvarez
#Version 1.0

import sys
import requests
import hashlib
import time
import os
import argparse

#URL de la API de Virus Total
url = "https://www.virustotal.com/vtapi/v2/file/report" 
#API Key de Virus Total
API_Key_VT = '3b0a0051bf2ac5b866b69dd1d07814f774a5053bdf008af041952f7af7771ac1'

parser = argparse.ArgumentParser()
parser.add_argument("-i","--hash",help="pasar el hash por linea de comando y lo consulta a VirtuTotal")
parser.add_argument("-a","--archivo",help="calcula el hash de una archivo y lo consulta a VirtuTotal",action='store_true')
parser.add_argument("-l","--listado",help="toma un archivo con IOCs SHA256/MD5/SHA1 y lo consulta a VirtuTotal",action='store_true')
args = parser.parse_args()

fileHash_lista = []


if args.archivo:
	print("Calcula el hash de un archivo y es enviado a VirusTotal confirmando si lo cubre McAfee")
	file = input("Ingrese el nombre y path del archivo: ")
	file = file.strip('"')
	BLOCKSIZE = 65536
	hasher = hashlib.sha1()

	with open(file, 'rb') as afile:
		buf = afile.read(BLOCKSIZE)
		while len(buf) > 0:
			hasher.update(buf)
			buf = afile.read(BLOCKSIZE)

	fileHash_lista.append(str(hasher.hexdigest()))

if args.hash:
	print("Envia el hash especificado a VirusTotal confirmando si lo cubre McAfee")
	fileHash_lista.append(args.hash)

if args.listado:	
	print("Consulta el listado de IOC en VirusTotal confirmando si lo cubre McAfee")
	while True:
			filename = str(input("Ingrese el nombre del archivo, incluida su extencion: "))
			if len(filename) > 0:
				break
			else:
				print("Debe ingresar al menos 1 caracteres como nombre")


	try:
		with open(filename) as file:
			for line in file: 
				line = line.strip() #or some other preprocessing
				fileHash_lista.append(line) #storing everything in memory!
	except: #En caso de error de lectura de archivo capturo el error y salgo del programa
		print ("Error al leer el archivo de datos")
		sys.exit()			   

#Evaluo si hay algun argumento		
if (args.listado == False) and (args.hash == None) and (args.archivo == False):
	sys.exit()			   
	
print("\n\n")
contador = 0
resultado_txt = open("resultado.txt", "w")

for fileHash in fileHash_lista:
	lista_AV=[]
	if contador > 3: #Restriccion de 4 consultas por minuto en cuenta free
		print("Pausa de un minuto, cuenta gratuita")
		time.sleep(63)
		contador=0

	parameters = {'apikey': API_Key_VT, 'resource': fileHash}

	response = (requests.get(url, params=parameters)).json()
	#print(response['status_code'])
	
	if response['response_code'] == 0 :
		print(response['verbose_msg'])
	elif response['response_code'] == 1 :
		for AV in response['scans']:
			if('McAfee' in AV):
				lista_AV.append(AV)
		#print [response for response in dict if(response['scans'] == 'McAfee')] 
		#prit(response['scans'])
		#print("Detected: " + str(response['positives']) + "/" + str(response['total']))
	else :
		print("Something went wrong.")
	
	if len(lista_AV) > 0:
		flag="OK"
	else:
		flag="NO Cubierto"
	lista_AV.sort()
	print(fileHash+"\t"+str(lista_AV)+"\t"+flag+"\n")
	resultado_txt.write(fileHash+"\t"+str(lista_AV)+"\t"+flag+"\n")
	contador+=1 
	

resultado_txt.close()	
print("Consulta guardada en *resultados.txt*")
print("Fin de Consulta")
