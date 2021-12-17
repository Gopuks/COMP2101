
#Function To Display hardware description
function Gensysinfo {
Write "                        SYSTEM HARDWARE INFORMATION "
get-wmiobject win32_computersystem |Format-List
}


#Function to Display OS information
function OSinfo {
write-host "                        OS INFORMATION  "
get-wmiobject win32_operatingsystem | Format-Table Name, Version
}

#Function to display processor description
function Processinfo {
Write "                      PROCESSOR INFORMATION  "
Get-WmiObject win32_processor | 
foreach {
    new-object -TypeName psobject -Property @{
        "L1 Cache (Mb)  "= if ($_.L1CacheSize) {$_.L1CacheSize}
        else {" data unavailable"}       
        "L2 Cache (Mb)  "= if ($_.L2CacheSize) {$_.L2CacheSize}
        else {"data unavailable"}
        "L3 Cache (Mb)  "= if ($_.L3CacheSize) {$_.L3CacheSize}
        else {"data unavailable"}
        "Name " = $_.Name
        "Core Count  " = $_.NumberOfCores

        }

     }

}
# Function to display Memory information

function MEMinfo{
$total = 0
Write "                    MEMORY INFORMATION "
get-wmiobject -class win32_physicalmemory |  
foreach { 
    new-object -TypeName psobject -Property @{ 
                Manufacturer = $_.manufacturer 
                "Speed(MHz)" = $_.speed 
                "Size(GB)" = $_.capacity/1gb 
                Bank = $_.banklabel 
                Slot = $_.devicelocator 
    } 
    $total += $_.capacity/1gb
    
} | 
ft -auto Manufacturer, "Size(GB)", "Speed(MHz)", Bank, Slot 
"Total RAM: ${total}GB "
}

#Function to display disk drive details

function DISKinfo{
Write "                     DRIVE NFORMATION "
$drives = Get-CIMInstance CIM_diskdrive

foreach ($disk in $drives) {
    $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
    foreach ($partition in $partitions) {
          $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
          foreach ($logicaldisk in $logicaldisks) {
                   new-object -typename psobject -property @{Manufacturer=$disk.Caption
                                                             Location=$partition.deviceid
                                                             Drive=$logicaldisk.deviceid
                                                             "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                                                             "Free Space(GB)" =$logicaldisk.FreeSpace  / 1gb -as [int]
                                                             "% Free"  = [Math]::round((($logicaldisk.freespace/$logicaldisk.size) * 100))
                                                             }
           }
        }
    }
}

# function to display a Network Interface Information
function NetInfo{
Write "                        NETWORK ADAPTER CONFIGURATION "
    get-ciminstance win32_networkadapterconfiguration |
  Where-Object {$_.IPEnabled -eq 'True'} |
    Add-Member -MemberType AliasProperty -Name DNSServer -Value DNSServerSearchOrder -PassThru |
      Add-Member -MemberType AliasProperty -Name SubnetMask -Value IPSubnet -PassThru |
        Select-Object Description,index,IPAddress,SubnetMask,DNSServer,DNSDomain 
          
}

#Function to display Graphics Information
function GPU {
    Write "                        GRAPHICS INFORMATION"
    $controller = Get-WmiObject win32_videocontroller
    $controller = New-Object -TypeName psObject -Property @{
        Name             = $controller.Name
        Description      = $controller.Description
        ScreenResolution = [string]($controller.CurrentHorizontalResolution) + 'px X ' + [string]($controller.CurrentVerticalResolution) + 'px'
    } | fl Name, Description, ScreenResolution
    $controller
}

Gensysinfo
OSinfo
Processinfo
MEMinfo
DISKinfo
NetInfo
GPU