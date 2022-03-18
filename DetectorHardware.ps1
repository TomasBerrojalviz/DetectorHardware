# Definimos los objetos WMI
$myComputer = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_ComputerSystem"
$myOS = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_OperatingSystem"
$myCPU = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_Processor"
$myMemory = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_PhysicalMemory"
$myNetwork = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM Win32_NetworkAdapterConfiguration"
$data_user = Get-WmiObject -ComputerName "." -Namespace "root\cimv2" -Query "SELECT * FROM win32_computersystem"

$url = 'https://report.qwe.com.ar/'
$win_old = (($myOS.Version -split "\.")[0] -lt 6)

function type_ram {
    param (
        $type
    )
    $RETURN = "Unknown"
    switch($type){
        21 {$RETURN = "DDR2"}
        24 {$RETURN = "DDR3"}
        26 {$RETURN = "DDR4"}
    }
    return ($RETURN)
}

# ------------------------------ Info - CUENTA --------------------------------------

$user_with_domain = $data_user.UserName -split "\\"
$PC_Usuario = $user_with_domain[1]

# ------------------------------ Info - PC --------------------------------------

$PC_Nombre = $myComputer.name;

# ------------------------------ Info - SO --------------------------------------

$PC_Windows = $myOS.Caption

# ------------------------------ Info - CPU --------------------------------------

$PC_CPU = $myCPU.Name

# ------------------------------ Info - RAM --------------------------------------

$PC_RAM_Cant = 0
foreach ($memory in $myMemory){
	$PC_RAM_Cant = $PC_RAM_Cant + $memory.Capacity/1GB
	$PC_RAM_Tipo = type_ram $memory.SMBIOSMemoryType
}
$PC_RAM_Cant = [math]::round($PC_RAM_Cant)

# ------------------------------ Info - Disco --------------------------------------

$PC_DISCO_Tipo = "HDD"
if($win_old) {
    foreach ($disco in Get-PhysicalDisk){
        if($disco.MediaType -eq "SSD"){
            $PC_DISCO_Tipo = "SSD"
        }
    }
}

	

# ------------------------------ Info - Red --------------------------------------

foreach ($red in $myNetwork){
    If(-Not ($red.IPAddress -eq $null)){
        If(-Not ($red.DefaultIPGateway -eq $null)){
            $PC_IP = $red.IPAddress[0]
            $PC_MAC = $red.MACAddress
         
        }
	}
}


# ------------------------------ Juntar parametros --------------------------------------
#$parametros = $parametrosPC + $parametrosSO + $parametrosCPU + $parametrosDisco + $parametrosRAM + $parametrosRed


$postParams = $url + "?PC="+$PC_Nombre+"&USUARIO="+$PC_Usuario+"&IP="+$PC_IP+"&MAC="+$PC_MAC+"&WINDOWS="+$PC_Windows+
                "&RAM_GB="+$PC_RAM_Cant+"&RAM_TIPO="+$PC_RAM_Tipo+"&PROCESADOR="+$PC_CPU+"&DISCO="+$PC_DISCO_Tipo

if($win_old) {
    $web=Invoke-WebRequest -Uri $postParams -Method Get
    $web.content
}
Else {
    <#
    $path = "\\172.16.5.48\C$\DHW\"+$PC_Nombre
    $postParams | Out-File $path
    #>

    <#
    $restRequest = [System.Net.WebRequest]::Create($url)
    $restRequest.ContentType = "application/json"
    $restRequest.Method = "POST"

    $encoding = [System.Text.Encoding]::UTF8

    $restRequestStream = $restRequest.GetRequestStream()
    $restRequestWriter = New-Object System.IO.StreamWriter($restRequestStream, $encoding)
      
    $restRequestWriter.Write($postParams)
    $restRequestStream.Dispose()
    $restRequestWriter.Dispose()
    #>

    $WebRequest = [System.Net.WebRequest]::Create($postParams)
    $WebRequest.Method = "GET"
    $WebRequest.ContentType = "application/json"
    $Response = $WebRequest.GetResponse()
    $ResponseStream = $Response.GetResponseStream()
    $ReadStream = New-Object System.IO.StreamReader $ResponseStream
    $Data=$ReadStream.ReadToEnd()
    
}

#PC		$PC_Nombre
#USUARIO		$PC_Usuario
#IP		$PC_IP
#MAC		$PC_MAC
#WINDOWS		$PC_Windows
#RAM_GB		$PC_RAM_Cant
#RAM_TIPO	$PC_RAM_Tipo
#PROCESADOR	$PC_CPU
#DISCO		$PC_DISCO_Tipo

#$postParams

# ------------------------------ Borrar variables --------------------------------------
Remove-Variable -Name myComputer
Remove-Variable -Name myOS
Remove-Variable -Name myCPU
Remove-Variable -Name myMemory
Remove-Variable -Name data_user
Remove-Variable -Name user_with_domain
Remove-Variable -Name PC_Usuario
Remove-Variable -Name PC_Nombre
Remove-Variable -Name PC_Windows
Remove-Variable -Name PC_CPU
Remove-Variable -Name PC_RAM_Cant
Remove-Variable -Name PC_RAM_Tipo
Remove-Variable -Name PC_DISCO_Tipo
Remove-Variable -Name PC_MAC
Remove-Variable -Name PC_IP

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)





