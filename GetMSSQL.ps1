#Dmitry Trukhanov 2017.06.19
#Quick MSSQL audit
#Usage GetMSSQL.ps1 filename.csv [-Server servername] [-Username username -Password password]
#filename - path to file to save report to
#servername - optional parameter to collect information remotely, if omitted localhost will be used
#if current user does not have access to MSSQL instance, please provide SQL authentication username and password
param(
	[string] $Server,
	[string] $Username,
	[string] $Password,
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $File
)

if($Server -eq ""){
	$Server="localhost"
}

if($Username -eq ""){
	$connectionString = "Server = $Server; Database = master; Trusted_Connection=Yes;"
}else{
	if($Password -eq ""){
		Write-Host "Please specify -Password parameter"
		exit 1
	}else{
		$connectionString = "Server = $Server; Database = master; User ID = $uid; Password = $pwd;" 
	}
}

Remove-Item $File -ErrorAction SilentlyContinue

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $connectionString

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.Connection = $SqlConnection
$SqlCmd.CommandText = "select 'MS SQL Information 2017/06/19 v.1.0 dmitry@trukhanov.com';"

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet

try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"" | Out-File $File -Append -Encoding UTF8
	exit 1
}
$DataSet.Reset()

$SqlCmd.CommandText = "SELECT @@version"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8 -Encoding UTF8
}
$DataSet.Reset()

$SqlCmd.CommandText = @"
SELECT 'BuildClrVersion' ColumnName, SERVERPROPERTY('BuildClrVersion') ColumnValue
UNION ALL
SELECT 'Collation', SERVERPROPERTY('Collation')
UNION ALL
SELECT 'CollationID', SERVERPROPERTY('CollationID')
UNION ALL
SELECT 'ComparisonStyle', SERVERPROPERTY('ComparisonStyle')
UNION ALL
SELECT 'ComputerNamePhysicalNetBIOS', SERVERPROPERTY('ComputerNamePhysicalNetBIOS')
UNION ALL
SELECT 'Edition', SERVERPROPERTY('Edition')
UNION ALL
SELECT 'EditionID', SERVERPROPERTY('EditionID')
UNION ALL
SELECT 'EngineEdition', SERVERPROPERTY('EngineEdition')
UNION ALL
SELECT 'InstanceName', SERVERPROPERTY('InstanceName')
UNION ALL
SELECT 'IsClustered', SERVERPROPERTY('IsClustered')
UNION ALL
SELECT 'IsFullTextInstalled', SERVERPROPERTY('IsFullTextInstalled')
UNION ALL
SELECT 'IsIntegratedSecurityOnly', SERVERPROPERTY('IsIntegratedSecurityOnly')
UNION ALL
SELECT 'IsSingleUser', SERVERPROPERTY('IsSingleUser')
UNION ALL
SELECT 'LCID', SERVERPROPERTY('LCID')
UNION ALL
SELECT 'LicenseType', SERVERPROPERTY('LicenseType')
UNION ALL
SELECT 'MachineName', SERVERPROPERTY('MachineName')
UNION ALL
SELECT 'NumLicenses', SERVERPROPERTY('NumLicenses')
UNION ALL
SELECT 'ProcessID', SERVERPROPERTY('ProcessID')
UNION ALL
SELECT 'ProductVersion', SERVERPROPERTY('ProductVersion')
UNION ALL
SELECT 'ProductLevel', SERVERPROPERTY('ProductLevel')
UNION ALL
SELECT 'ResourceLastUpdateDateTime', SERVERPROPERTY('ResourceLastUpdateDateTime')
UNION ALL
SELECT 'ResourceVersion', SERVERPROPERTY('ResourceVersion')
UNION ALL
SELECT 'ServerName', SERVERPROPERTY('ServerName')
UNION ALL
SELECT 'SqlCharSet', SERVERPROPERTY('SqlCharSet')
UNION ALL
SELECT 'SqlCharSetName', SERVERPROPERTY('SqlCharSetName')
UNION ALL
SELECT 'SqlSortOrder', SERVERPROPERTY('SqlSortOrder')
UNION ALL
SELECT 'SqlSortOrderName', SERVERPROPERTY('SqlSortOrderName')
"@
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8 -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.databases`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "SELECT * FROM sys.databases;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()


"`r`n`r`nsys.database_files`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "SELECT * FROM sys.database_files;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.master_files`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "SELECT * FROM sys.master_files;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_databases`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_databases;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_helpdb`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_helpdb;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_io_virtual_file_stats(NULL, NULL)`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "SELECT * FROM sys.dm_io_virtual_file_stats(NULL, NULL);"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmsdb.dbo.sp_help_job`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC msdb.dbo.sp_help_job" #			--http://technet.microsoft.com/en-us/library/ms186722(v=sql.110).aspx  
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmsdb.dbo.sp_help_jobactivity`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC msdb.dbo.sp_help_jobactivity" #	--http://technet.microsoft.com/en-us/library/ms188766(v=sql.110).aspx
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_linkedservers`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_linkedservers" #	--http://technet.microsoft.com/en-us/library/ms189519.aspx
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nselect 'master.dbo.sp_helplinkedsrvlogin`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_helplinkedsrvlogin;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_helpserver`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_helpserver" #		--http://technet.microsoft.com/en-us/library/ms189804.aspx
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_get_distributor`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_get_distributor" #	--http://technet.microsoft.com/en-us/library/ms190339(v=sql.110).aspx
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_helpdistributiondb`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_helpdistributiondb" #	--http://technet.microsoft.com/en-us/library/ms187725(v=sql.110).aspx
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	if($DataSet.Tables.Length -gt 0){
		$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
	}
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_who`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_who"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmaster.dbo.sp_who2`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "EXEC master.dbo.sp_who2"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`n-----Availability Groups + Failover Cluster`r`n" | Out-File $File -Append -Encoding UTF8

$SqlCmd.CommandText = @"
select 
	'IsHadrEnabled', 
	case SERVERPROPERTY('IsHadrEnabled')
		when 0 then 'The Always On availability groups feature is disabled'
		when 1 then 'The Always On availability groups feature is enabled'
		else 'Unknown value' 
	end
union all
select 
	'HadrManagerStatus', 
	case SERVERPROPERTY('HadrManagerStatus')
		when 0 then 'Not started, pending communication'
		when 1 then 'Started and running'
		when 2 then 'Not started and failed'
		else 'Unknown value'
	end
"@
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_hadr_cluster`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_hadr_cluster;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_hadr_cluster_members`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_hadr_cluster_members;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_hadr_cluster_networks`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_hadr_cluster_networks;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.availability_groups`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.availability_groups;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.availability_groups_cluster`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.availability_groups_cluster;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_hadr_availability_group_states`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_hadr_availability_group_states;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.availability_replicas`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.availability_replicas;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.availability_group_listener_ip_addresses `r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.availability_group_listener_ip_addresses;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.availability_group_listeners`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.availability_group_listeners;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_tcp_listener_states`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_tcp_listener_states;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.availability_databases_cluster`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.availability_databases_cluster;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_os_cluster_nodes`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select NodeName, status, status_description, is_current_owner from sys.dm_os_cluster_nodes;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_server_services`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_server_services;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`n----- Mirroring`r`n" | Out-File $File -Append -Encoding UTF8

"`r`n`r`nsys.database_mirroring`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.database_mirroring;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.database_mirroring_endpoints`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.database_mirroring_endpoints;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.database_mirroring_witnesses`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.database_mirroring_witnesses;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nsys.dm_db_mirroring_connections`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from sys.dm_db_mirroring_connections;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()


"`r`n`r`n----- Log Shipping`r`n" | Out-File $File -Append -Encoding UTF8

"`r`n`r`nmsdb.dbo.log_shipping_primary_databases`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from msdb.dbo.log_shipping_primary_databases;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmsdb.dbo.log_shipping_primary_secondaries`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from  msdb.dbo.log_shipping_primary_secondaries;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmsdb.dbo.log_shipping_secondary`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from msdb.dbo.log_shipping_secondary;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()

"`r`n`r`nmsdb.dbo.log_shipping_secondary_databases`r`n" | Out-File $File -Append -Encoding UTF8
$SqlCmd.CommandText = "select * from msdb.dbo.log_shipping_secondary_databases;"
try{
	$SqlAdapter.Fill($DataSet) | Out-Null
	$DataSet.Tables[0] | ConvertTo-Csv -NoTypeInformation | Out-File $File -Append -Encoding UTF8
}catch{
	$_.Exception.Message+"`r`n`r`n`r`n" | Out-File $File -Append -Encoding UTF8
}
$DataSet.Reset()
