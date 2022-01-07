# Definimos los objetos WMI
$myComputer = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_ComputerSystem"
$myOS = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_OperatingSystem"
$myCPU = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_Processor"
$myMemory = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_MemoryDevice"
$myDisk = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_LogicalDisk"
$myMotherBoard = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_BaseBoard"
$myNetwork = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_NetworkAdapterConfiguration"
$myBios = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_BIOS"
$myVideo = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_VideoController"

# Definimos funciones utils
function bytes_to_GB {
    param (
        $bytes
    )
    return (bytes_to_MB $bytes) / 1024
}

function bytes_to_MB {
    param (
        $bytes
    )
    return (bytes_to_KB $bytes) / 1024
}

function bytes_to_KB {
    param (
        $bytes
    )
    return ($bytes / 1024)
}


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
$ram = [math]::round((bytes_to_MB $ram))

$ram = "" + $ram + "GB"

$parametrosRAM = @{RAM=$ram}


# ------------------------------ Info - Disco --------------------------------------

$discosAll = Get-PhysicalDisk
$i = 1
foreach ($disco in $discosAll){
    $tamDisco = [math]::round( (bytes_to_GB $disco.Size) )
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

$parametrosVideo = @{GPU=$myVideo.Name;RAM_Dedicada="" + (bytes_to_GB $myVideo.AdapterRAM) + "GB"}

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
Remove-Variable -Name myDisk
Remove-Variable -Name myMotherBoard
Remove-Variable -Name parametrosPC
Remove-Variable -Name parametrosSO
Remove-Variable -Name parametrosCPU
Remove-Variable -Name disco
Remove-Variable -Name tamDisco
Remove-Variable -Name discosAll
Remove-Variable -Name parametrosDisco
Remove-Variable -Name ram
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

Remove-Item -Path Function:bytes_to_GB
Remove-Item -Path Function:bytes_to_MB
Remove-Item -Path Function:bytes_to_KB

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)







