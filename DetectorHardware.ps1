# Definimos los objetos WMI
$myComputer = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_ComputerSystem"
$myOS = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_OperatingSystem"
$myCPU = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_Processor"
$myMemory = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_MemoryDevice"
$myDisk = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_LogicalDisk"
$myMotherBoard = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_BaseBoard"


# ------------------------------ Info - PC --------------------------------------

$parametrosPC = @{PC=$myComputer.name;Dominio=$myComputer.Domain;Arquitectura=$myComputer.SystemType}

# ------------------------------ Info - SO --------------------------------------

$parametrosSO = @{SO=$myOS.Caption}

# ------------------------------ Info - CPU --------------------------------------

$parametrosCPU = @{CPU=$myCPU.Name}

# ------------------------------ Info - RAM --------------------------------------
$ram = 0
foreach ($memory in $myMemory){
	$ram = $ram + $memory.EndingAddress
}
$ram = [math]::round($ram / 1024 / 1024)

$ram = "" + $ram + "GB"

$parametrosRAM = @{RAM=$ram}


# ------------------------------ Info - Disco --------------------------------------

$discosAll = Get-PhysicalDisk
$i = 1
foreach ($disco in $discosAll){
    $discSize = [math]::round($disco.Size / 1024 / 1024 / 1024)
	If($discSize -gt 900){
		$discSize = "1TB"
	}
	ElseIf($discSize -gt 400){
		$discSize = "500GB"
	}
	ElseIf($discSize -gt 200){
		$discSize = "240GB"
	}
	ElseIf($discSize -gt 100){
		$discSize = "120GB"
	}
	$nombreDisco = "Disco_" + $i
	$almacenamiento = "Almacenamiento_" + $i
	$tipo = "Tipo_" + $i
	$parametrosDisco = $parametrosDisco + @{$nombreDisco=$disco.FriendlyName;$almacenamiento=$discSize;$tipo=$disco.MediaType}
	$i = $i + 1
}

$parametrosDisco = $parametrosDisco + @{Cantidad=$discosAll.Count}
	
# ------------------------------ Info - Mother --------------------------------------

$parametrosMother = @{MotherBoard=$myMotherBoard.Product;Fabricante_MotherBoard=$myMotherBoard.Manufacturer}


# ------------------------------ Juntar parametros --------------------------------------
$parametros = $parametrosPC + $parametrosSO + $parametrosCPU + $parametrosDisco + $parametrosRAM + $parametrosMother



# ------------------------------ Imprimir parametros --------------------------------------
echo " "
echo "------------------------------------------------------------------"
echo "------------------------- INFO - PC ------------------------------"
echo "------------------------------------------------------------------"
echo " "
$parametros

# ------------------------------ Borrar variables --------------------------------------
Remove-Variable -Name myComputer
Remove-Variable -Name myOS
Remove-Variable -Name myCPU
Remove-Variable -Name myMemory
Remove-Variable -Name myDisk
Remove-Variable -Name myMotherBoard
Remove-Variable -Name parametrosPC
Remove-Variable -Name parametrosSO
Remove-Variable -Name parametrosCPU
Remove-Variable -Name discSize
Remove-Variable -Name discosAll
Remove-Variable -Name parametrosDisco
Remove-Variable -Name ram
Remove-Variable -Name parametrosRAM
Remove-Variable -Name parametrosMother
Remove-Variable -Name parametros

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)


#$postParams = @{$pcNombre + ";" + $pcDominio + ";" + pcArquitectura}
#$web=Invoke-WebRequest -Uri 'https://localhost/examplepost.php' -Method Post -Body $postParams
#$web.content






