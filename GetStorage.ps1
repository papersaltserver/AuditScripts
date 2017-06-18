#Dmitry Trukhanov 2017.06.17
#Quick storage audit
#Usage GetStorage.ps1 filename.htm [-Server servername]
#filename - path to file to save report to
#servername - optional parameter to collect information remotely, if omitted localhost will be used
#you need to have administrator rights to collect advanced information and mount points, other way simple info will be collected
param(
	[string] $Server,
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $File
)

if($Server -eq ""){
	$Server='localhost'
}

$html = '<!DOCTYPE html>'
$html += '<html>'
$html += '<head>'
$html += '<title>Storage report</title>'
$html += @"
<style>
body {
  background-color: #3e94ec;
  font-family: "Roboto", helvetica, arial, sans-serif;

}

th {
  color:#D5DDE5;;
  background:#1b1e24;
  border-bottom:4px solid #9ea7af;
  border-right: 1px solid #343a45;
  font-size:15px;
  font-weight: 100;
  padding:14px;
  text-align:left;
  vertical-align:middle;
}

  
tr {
  border-top: 1px solid #C1C3D1;
  border-bottom-: 1px solid #C1C3D1;
  color:#666B85;
  font-size:16px;
  font-weight:normal;
  text-shadow: 0 1px 1px rgba(256, 256, 256, 0.1);
}
 
tr:hover td {
  background:#4E5066;
  color:#FFFFFF;
  border-top: 1px solid #22262e;
  border-bottom: 1px solid #22262e;
}
 

tr:nth-child(odd) td {
  background:#EBEBEB;
}
 
tr:nth-child(odd):hover td {
  background:#4E5066;
}
 
td {
  background:#FFFFFF;
  padding:20px;
  text-align:left;
  vertical-align:middle;
  font-weight:300;
  font-size:13px;
  border-right: 1px solid #C1C3D1;
}

a:link {
    color: green;
    background-color: transparent;
    text-decoration: none;
}

a:visited {
    color: pink;
    background-color: transparent;
    text-decoration: none;
}

a:hover {
    color: red;
    background-color: transparent;
    text-decoration: underline;
}

a:active {
    color: yellow;
    background-color: transparent;
    text-decoration: underline;
}

</style>
"@
$html += '</head>'
$msftexception=""
try{
	$msftP2Vs = Get-WmiObject -ComputerName $Server -Query "Select * from MSFT_PartitionToVolume" -Namespace root\microsoft\windows\storage -ErrorAction Stop
} Catch {
	$msftexception = $_.Exception.Message
}
$html += '<body>'
$html += '<table>'
$html += '<tr>'
$html += '<th>Physical Drive</th>'
$html += '<th>Partitions</th>'
if($msftexception -eq ""){
	$html += '<th>Volumes</th>'
}else{
	$html += '<th>Logical Disks<a href="#NoVolumes">*</a></th>'
}
$html += '</tr>'

$physicaldisks = Get-WmiObject -ComputerName $Server -Class Win32_DiskDrive
foreach($physicaldisk in $physicaldisks){
	$partitions = Get-WmiObject -ComputerName $Server -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($physicaldisk.DeviceID)'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"

	
	$html += "<tr><td rowspan=""$($partitions.Length)"">"
	$html += "Name: " + $physicaldisk.Name
	$html += "<br />"
	$html += "Model: " + $physicaldisk.Model
	$html += "<br />"
	$html += "Interface: " + $physicaldisk.InterfaceType
	$html += "<br />"
	$html += "Serial: " + $physicaldisk.SerialNumber
	$html += "<br />"
	$html += "Status: " + $physicaldisk.Status
	$html += "<br />"
	$html += "Size in GB: " + [Math]::Round($physicaldisk.Size/1GB)
	
	$html += "</td>"
	$num=0
	foreach($partition in $partitions){
		if($num -eq 0){
			$html += '<td>'
		}else{
			$html += '<tr><td>'
		}
		$html += "Name: " + $partition.Name
		$html += "<br />"
		$html += "BootPartition: " + $partition.BootPartition
		$html += "<br />"
		$html += "Type: " + $partition.Type
		$html += "<br />"
		$html += "Size in GB: " + [Math]::Round($partition.Size/1GB)
		$html += '</td>'
		$html += '<td>'
		if($msftexception -eq ""){
			$msftphysicaldisk = Get-WmiObject -ComputerName $Server -Query "Select * from MSFT_Disk where SerialNumber='$($physicaldisk.SerialNumber)'" -Namespace root\microsoft\windows\storage
			$msftpartition = Get-WmiObject -ComputerName $Server -Query "Select * from MSFT_Partition Where DiskNumber='$($msftphysicaldisk.Number)' AND Offset='$($partition.StartingOffset)'" -Namespace root\microsoft\windows\storage
            $msftvol = $null
			foreach($msftP2V in $msftP2Vs){
				if($msftP2V.Partition -eq '\\.\ROOT\microsoft\windows\storage:'+$msftpartition.__RELPATH){
					$msftvol=$msftP2V.Volume.Substring(57,53)
				}
			}
			$volume = Get-WmiObject -ComputerName $Server -Query "Select * from win32_volume where DeviceId='$($msftvol)'"
            if($volume -ne $null){
			    $html += 'Name: '+$volume.Name
			    $html += "<br />"
			    $html += 'Label: '+$volume.Label
			    $html += "<br />"
			    switch ($volume.DriveType) {
				    0 {$drivetypetext = "Unknown"}
				    1 {$drivetypetext = "No Root Directory"}
				    2 {$drivetypetext = "Removable Disk"}
				    3 {$drivetypetext = "Local Disk"}
				    4 {$drivetypetext = "Network Drive"}
				    5 {$drivetypetext = "Compact Disk"}
				    6 {$drivetypetext = "RAM Disk"}
			    }
			    $html += 'DriveType: '+$drivetypetext
			    $html += "<br />"
			    $html += 'Capacity in GB: '+[Math]::Round($volume.Capacity/1GB)
			    $html += "<br />"
			    $html += 'FreeSpace in GB: '+[Math]::Round($volume.FreeSpace/1GB)
			    $html += "<br />"
			    $html += 'FileSystem: '+$volume.FileSystem
			    $html += "<br />"
			    $html += 'BlockSize: '+$volume.BlockSize
			    $html += "<br />"
			    $html += 'Automount: '+$volume.Automount
			    $html += "<br />"
			    $html += 'Compressed: '+$volume.Compressed
			    $html += "<br />"
			    $html += 'PageFilePresent: '+$volume.PageFilePresent
			    $html += "<br />"
			    $html += 'IndexingEnabled: '+$volume.IndexingEnabled
			    $html += "<br />"
			    $html += 'QuotasEnabled: '+$volume.QuotasEnabled
            }else{
                $html += "No volume for this partition"
            }
		}else{
			$logicaldrive = Get-WmiObject -ComputerName $Server -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} WHERE AssocClass = Win32_LogicalDiskToPartition"
			if($logicaldrive -ne $null){
				$html += 'Name: ' + $logicaldrive.Name
				$html += "<br />"
				$html += 'FileSystem: ' + $logicaldrive.FileSystem
				$html += "<br />"
				$html += 'Free Space in GB: ' + [Math]::Round($logicaldrive.FreeSpace/1GB)
				$html += "<br />"
				$html += 'Size in GB: ' + [Math]::Round($logicaldrive.Size/1GB)
			}else{
				$html += 'No logical drive on this partition'
			}
		}
		$html += '</td></tr>'
		$num++
	}
}
$html += '</table>'
if($msftexception -ne ""){
	$html += "<div id=`"NoVolumes`">* Could not get information from MSFT_PartitionToVolume, try to run script as Administrator<br />Exception: '$($msftexception)'</div>"
}
$html += '</body>'
$html += '</html>'

Set-Content $File $html