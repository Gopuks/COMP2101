 
 function welcome {
>> Write-output "Welcome to planet $env:computername Overlord $env:username"
>> $now = get-date -format 'HH:MM tt on dddd'
>> write-output "It is $now."
>> }


 function get-mydisks {
>> Get-Ciminstance Win32_DiskDrive | Format-list Name , Model, Size, Manufacturer, FirmwareRevision, SerialNumber
>> }


function get-cpuinfo {
>> Get-Ciminstance cim_processor | Format-list Name , Manufacturer, MaxClockSpeed, NumberOfCores
>> }


welcome
get-mydisks
get-cpuinfo