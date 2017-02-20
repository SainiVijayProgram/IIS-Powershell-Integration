#         Script Name : Recycle_iis_app_ppols.ps1
#
#        Developed By : Vijay Saini
#  Scripting Language : PowerShell
#
#                Date : 18th February 2017
#
#             Purpose : To Recycle the iis pools if high memory utilization is due to w3wp prcesses
#
#             Author  : JDA
#
#             
Remove-Variable * -ErrorAction SilentlyContinue

#Setting up variables
$BASE_DIR=(Resolve-Path .\).Path

$host_name=hostname

$CSV_FILE=$BASE_DIR + "\iis_recycle_pools.csv"
$servers_list=$BASE_DIR + "\servers.list"


    foreach ($server in Get-Content $servers_list){

		try{
        $getfreeMemory_inPercentage=gwmi Win32_OperatingSystem -ComputerName $server | % { $_.FreePhysicalMemory * 100 /$_.TotalVisibleMemorySize }
	    #$getfreeMemory_inPercentage

        } catch{
			write-output "$server,ErrorMessage : $ErrorMessage,Failed to determine the % physical memory" | out-file $CSV_FILE -Encoding ASCII;
        }

        if ($getfreeMemory_inPercentage -lt 15){
   
        #Get top 5 process who are consuming mzximum working set memory
        $tmp=Get-Process | Sort-Object WS -desc | Select-Object -first 5
        $processes = $tmp.ProcessName;
        [regex]$regex = 'w3wp'
        $cnt=$regex.matches($processes).count
       # $cnt

            if($cnt -ge 2){
                echo "Recycling the pools"
              }else{
                echo "High memory utilization is not due to IIS"
            }

        } else {
            echo "Normal memory utilization"
        }
    }

