param(
      [switch]$System,
      [switch]$Disks, 
      [switch]$Network
  )
      if ($System -eq $true) {
       OSinfo
       MEMinfo
       GPU
    }
      if ($Disks -eq $true) {
        DISKinfo
    }
      if ($Network -eq $true) {
        NetInfo
    }