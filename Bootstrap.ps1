cls
Function DownloadFileWithProgress {

# Code for this function borrowed from http://poshcode.org/2461
# Thanks Crazy Dave

	param(
		[Parameter(Mandatory=$true)]
		[String] $url,
		[Parameter(Mandatory=$false)]
		[String] $localFile = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/'))) 
	)
		
	begin {
		$client = New-Object System.Net.WebClient
		$Global:downloadComplete = $false
		$eventDataComplete = Register-ObjectEvent $client DownloadFileCompleted `
			-SourceIdentifier WebClient.DownloadFileComplete `
			-Action {$Global:downloadComplete = $true}
		$eventDataProgress = Register-ObjectEvent $client DownloadProgressChanged `
			-SourceIdentifier WebClient.DownloadProgressChanged `
			-Action { $Global:DPCEventArgs = $EventArgs }
	}
	process {
		Write-Progress -Activity 'Downloading file' -Status $url
		$client.DownloadFileAsync($url, $localFile)
		
		while (!($Global:downloadComplete)) {
			$pc = $Global:DPCEventArgs.ProgressPercentage
			if ($pc -ne $null) {
				Write-Progress -Activity 'Downloading file' -Status $url -PercentComplete $pc
			}
		}
		Write-Progress -Activity 'Downloading file' -Status $url -Complete
	}

	end {
		Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
		Unregister-Event -SourceIdentifier WebClient.DownloadFileComplete
		$client.Dispose()
		$Global:downloadComplete = $null
		$Global:DPCEventArgs = $null
		Remove-Variable client
		Remove-Variable eventDataComplete
		Remove-Variable eventDataProgress
		[GC]::Collect()
	} 
}

$strDownloadDir = "$env:Temp\DevSalt"
New-Item $strDownloadDir -Type Directory -Force

$webclient = New-Object System.Net.WebClient

cls
echo "Microsoft Visual C++ 2008 Redistributable"
$url = "http://download.microsoft.com/download/d/2/4/d242c3fb-da5a-4542-ad66-f9661d0a8d19/vcredist_x64.exe"
$file = "$strDownloadDir\vcredist_x64.exe"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process $file -ArgumentList "/q" -Wait -NoNewWindow -PassThru

cls
echo "Microsoft Visual C++ 2008 MFC Security Update Redistributable"
$url = "http://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"
$file = "$strDownloadDir\vcredist_x64.exe"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process $file -ArgumentList "/q" -Wait -NoNewWindow -PassThru

cls
echo "Open SSL for Windows (Light)"
$url = "http://slproweb.com/download/Win64OpenSSL_Light-1_0_1L.exe"
$file = "$strDownloadDir\Win64OpenSSL_Light-1_0_1L.exe"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process $file -ArgumentList "/silent" -Wait -NoNewWindow -PassThru

cls
echo "Microsoft Visual C++ Compiler for Python (this may take a while)"
$url = "http://download.microsoft.com/download/7/9/6/796EF2E4-801B-4FC4-AB28-B59FBF6D907B/VCForPython27.msi"
$file = "$strDownloadDir\VCForPython27.msi"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process msiexec -ArgumentList "/i $file /qb" -Wait -NoNewWindow -PassThru

cls
echo "Git for Windows"
echo "- creating inf"
Set-Content -path $strDownloadDir\git.inf -value "[Setup]"
Add-Content -path $strDownloadDir\git.inf -value "Lang=default"
Add-Content -path $strDownloadDir\git.inf -value "Dir=C:\Program Files (x86)\Git"
Add-Content -path $strDownloadDir\git.inf -value "Group=Git"
Add-Content -path $strDownloadDir\git.inf -value "NoIcons=0"
Add-Content -path $strDownloadDir\git.inf -value "SetupType=default"
Add-Content -path $strDownloadDir\git.inf -value "Components=ext,ext\cheetah,assoc,assoc_sh"
Add-Content -path $strDownloadDir\git.inf -value "Tasks="
Add-Content -path $strDownloadDir\git.inf -value "PathOption=BashOnly"
Add-Content -path $strDownloadDir\git.inf -value "SSHOption=OpenSSH"
Add-Content -path $strDownloadDir\git.inf -value "CRLFOption=LFOnly"
echo "- downloading file"
$url = "https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20141217/Git-1.9.5-preview20141217.exe"
$file = "$strDownloadDir\Git-1.9.5-preview20141217.exe"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process $file -ArgumentList '/SILENT /LOADINF="$strDownloadDir\git.inf"' -Wait -NoNewWindow -PassThru

cls
echo "Python 2.7 (entire package)"
$url = "https://www.python.org/ftp/python/2.7.9/python-2.7.9.amd64.msi"
$file = "$strDownloadDir\python-2.7.9.amd64.msi"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process msiexec -ArgumentList "/i $file /qb ADDLOCAL=ALL" -Wait -NoNewWindow -PassThru

cls
echo "M2Crypto"
$url = "http://chandlerproject.org/pub/Projects/MeTooCrypto/M2Crypto-0.21.1.win-amd64-py2.7.exe"
$file = "$strDownloadDir\M2Crypto-0.21.1.win-amd64-py2.7.exe"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process $file -Wait -NoNewWindow -PassThru

cls
echo "pywin32"
$url = "http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win-amd64-py2.7.exe"
$file = "$strDownloadDir\pywin32-219.win-amd64-py2.7.exe"
DownloadFileWithProgress $url $file
echo "Installing..."
$p = Start-Process $file -Wait -NoNewWindow -PassThru

echo "Setting up the environment"
$p = Start-Process easy_install -ArgumentList "pip" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install pycrypto" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install cython" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install jinja2" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install msgpack-python" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install psutil" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install pyyaml" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install pyzmq" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install wmi" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install requests" -Wait -NoNewWindow -PassThru
$p = Start-Process pip -ArgumentList "install six" -Wait -NoNewWindow -PassThru

echo "Cleaning up downloaded files"
Remove-Item $strDownloadDir -Force -Recurse

echo "Salt Stack Dev Environment Script Complete"