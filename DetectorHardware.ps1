# Definimos los objetos WMI
$myComputer = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_ComputerSystem"
$myOS = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_OperatingSystem"
$myCPU = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_Processor"
$myMemory = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_PhysicalMemory"
$myMotherBoard = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_BaseBoard"
$myNetwork = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_NetworkAdapterConfiguration"
$myBios = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_BIOS"
$myVideo = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_VideoController"
 
 #               TYPES RAM
#Unknown (0)
#Other (1)
#DRAM (2)
#Synchronous DRAM (3)
#Cache DRAM (4)
#EDO (5)
#EDRAM (6)
#VRAM (7)
#SRAM (8)
#RAM (9)
#ROM (10)
#Flash (11)
#EEPROM (12)
#EPROM (13)
#PROM (14)
#CDRAM (15)
#3DRAM (16)
#SDRAM (17)
#SGRAM (18)
#RDRAM (19)
#DDR (20)
#DDR2 (21)
#DDR2�May not be available.
#DDR2 FB-DIMM (22) DDR2�FB-DIMM,May not be available.
#24 DDR3�May not be available.
#25 FBD2
#DDR4 (26)

function type_ram {
    param (
        $type
    )
    switch($type){
    0 {return "Unknown"}
    2 {return "DRAM"}
    7 {return "VRAM"}
    11 {return "Flash"}
    20 {return "DDR"}
    21 {return "DDR2"}
    22 {return "DDR2�FB-DIMM"}
    24 {return "DDR3"}
    26 {return "DDR4"}
    }
    #return ("Other")
}


# ------------------------------ Info - PC --------------------------------------

$parametrosPC = @{PC=$myComputer.name;Dominio=$myComputer.Domain;Arquitectura=$myComputer.SystemType}

# ------------------------------ Info - SO --------------------------------------

$parametrosSO = @{SO=$myOS.Caption}

# ------------------------------ Info - CPU --------------------------------------

$parametrosCPU = @{CPU=$myCPU.Name}

# ------------------------------ Info - RAM --------------------------------------
$ram_tam = 0
$i = 1
foreach ($memory in $myMemory){
	$ram_tam = $ram_tam + $memory.Capacity/1GB
	$fabricanteRAM = "RAM_" + $i
	$tamRAM = "Tam_RAM_" + $i
	$tipoRAM = "Tipo_RAM_" + $i
	$parametrosRAM = $parametrosRAM + @{$fabricanteRAM=$memory.Manufacturer;$tamRAM="" + $memory.Capacity/1GB + "GB";$tipoRAM= type_ram $memory.SMBIOSMemoryType}
    $cantRAM = $i
	$i = $i + 1
}

$ram_tam = [math]::round($ram_tam)

$ram_tam = "" + $ram_tam + "GB"

$parametrosRAM = $parametrosRAM + @{RAM_total=$ram_tam; CantidadRAM=$cantRAM}


# ------------------------------ Info - Disco --------------------------------------

$discosAll = Get-PhysicalDisk
$i = 1
foreach ($disco in $discosAll){
    $tamDisco = [math]::round($disco.Size/1GB)
	If($tamDisco -gt 900){
		$tamDisco = "1TB"
	}
	ElseIf($tamDisco -gt 400){
		$tamDisco = "500GB"
	}
	ElseIf($tamDisco -gt 200){
		$tamDisco = "240GB"
	}
	ElseIf($tamDisco -gt 100){
		$tamDisco = "120GB"
	}
	ElseIf($tamDisco -gt 68){
		$tamDisco = "75GB"
	}
	ElseIf($tamDisco -gt 55){
		$tamDisco = "64GB"
	}
	ElseIf($tamDisco -gt 25){
		$tamDisco = "32GB"
	}
	$nombreDisco = "Disco_" + $i
	$almacenamiento = "Almacenamiento_" + $i
	$tipo = "Tipo_" + $i
	$parametrosDisco = $parametrosDisco + @{$nombreDisco=$disco.FriendlyName;$almacenamiento=$tamDisco;$tipo=$disco.MediaType}
	$i = $i + 1
}
$cantDiscos = 0
If($discosAll.Count -eq $null){
	$cantDiscos = 1
}
ElseIf($discosAll.Count -gt 1){
    $cantDiscos = $discosAll.Count
}

$parametrosDisco = $parametrosDisco + @{CantidadDiscos=$cantDiscos}
	

# ------------------------------ Info - Mother --------------------------------------

$parametrosMother = @{MotherBoard=$myMotherBoard.Product;Fabricante_MotherBoard=$myMotherBoard.Manufacturer}


# ------------------------------ Info - Red --------------------------------------

foreach ($red in $myNetwork){
    If(-Not ($red.IPAddress -eq $null)){
        If(-Not ($red.DefaultIPGateway -eq $null)){
            $parametrosRed = @{IP=$red.IPAddress[0];MAC=$red.MACAddress;Placa=$red.Description}
        }
	}
}


# ------------------------------ Info - Red --------------------------------------

$parametrosBios = @{BIOS=$myBios.Version;Fabricante_BIOS=$myBios.Manufacturer}



# ------------------------------ Info - Video --------------------------------------

$parametrosVideo = @{GPU=$myVideo.Name;RAM_Dedicada="" + ([math]::round($myVideo.AdapterRAM/1GB)) + "GB"}

# ------------------------------ Juntar parametros --------------------------------------
$parametros = $parametrosPC + $parametrosSO + $parametrosCPU + $parametrosDisco + $parametrosRAM + $parametrosMother + $parametrosRed + $parametrosBios + $parametrosVideo



# ------------------------------ Imprimir parametros --------------------------------------
echo " "
echo "------------------------------------------------------------------"
echo "------------------------- INFO - PC ------------------------------"
echo "------------------------------------------------------------------"
echo " "
$parametros


#$postParams = @{$pcNombre + ";" + $pcDominio + ";" + pcArquitectura}
#$web=Invoke-WebRequest -Uri 'https://localhost/examplepost.php' -Method Post -Body $postParams
#$web.content

# ------------------------------ Borrar variables --------------------------------------
Remove-Variable -Name myComputer
Remove-Variable -Name myOS
Remove-Variable -Name myCPU
Remove-Variable -Name myMemory
Remove-Variable -Name myMotherBoard
Remove-Variable -Name parametrosPC
Remove-Variable -Name parametrosSO
Remove-Variable -Name parametrosCPU
Remove-Variable -Name disco
Remove-Variable -Name tamDisco
Remove-Variable -Name discosAll
Remove-Variable -Name parametrosDisco
Remove-Variable -Name ram_tam
Remove-Variable -Name parametrosRAM
Remove-Variable -Name parametrosMother
Remove-Variable -Name parametrosRed
Remove-Variable -Name myNetwork
Remove-Variable -Name red
Remove-Variable -Name parametrosBios
Remove-Variable -Name myBios
Remove-Variable -Name parametrosVideo
Remove-Variable -Name myVideo
Remove-Variable -Name parametros

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)





