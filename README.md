# Connect-ScreenConnectSupportSession

Connect to a ConnectWise ScreenConnect support session from PowerShell.

## Usage

Connect to a new support session using the default session name. By default the
ScreenConnect binaries are required to be in the same directory as the script.

```PowerShell
PS C:\> .\Connect-ScreenConnectSupportSession.ps1 -ScreenConnectUri 'https://instance.screenconnect.com/'
```

## Setup

You need to change some settings on your instance, and download the ScreenConnect
client binaries for this script to work.

1.	Enable the **Guest Session Starter** extension in your ScreenConnect instance
2.	Download an **Access Session** **MSI** installer to your local workstation
3.	Extract the MSI installer with the following command

	```PowerShell
	PS C:\> New-Item -Path C:\ScreenConnect -ItemType Directory > $null
	PS C:\> msiexec.exe /a .\ConnectWiseControl.ClientSetup.msi /qb TARGETDIR=C:\ScreenConnect
	```
	
4.	Inside the folder you you will find a copy of the MSI file and another subfolder specific to your ScreenConnect instance, copy the contents of the **sub-folder** to the same location as your script.

	```PowerShell
	PS C:\> Get-ChildItem -Path C:\ScreenConnect\*\* | Copy-Item -Destination .
	```
	
5.	Test your installation

## Integration with MDT

You can integrate ScreenConnect with the x86 version of your MDT boot disk (x86 can install x86 or x64 windows).

### Configure Extra Files

1.	Create an **Extra Files** directory on your MDT computer
2.	Create an **x86** sub-directory in the Extra Files directory
3.	Create a **Program Files** sub-directory in the x86 directory
4.	Create a **ScreenConnect** sub-directory in the Program Files directory
5.	Copy the script and ScreenConnect files into the ScreenConnect directory
6.	Open the **Deployment Workbench**
7.	Right-click on your deployment share and choose **Properties**
8.	Switch to the **Windows PE** tab
9.	Enter the path to the x86 folder from earlier (Ex: C:\Extra Files\x86) into the **Extra directory to add:** field
10. Press **OK** to close and save your configuration

### Configure Unattend_PE_x86.xml Template

1.	Open the **Unattend_PE_x86.xml** template from the installation location, typically "%ProgramFiles%\Microsoft Deployment Toolkit\Templates\Unattend_PE_x86.xml"
2.	Modify the **RunSynchronous** section, example:

	<RunSynchronous>
		<RunSynchronousCommand wcm:action="add">
			<Description>ConnectWise Control Client</Description>
			<Order>1</Order>
			<Path>powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%ProgramFiles%\ScreenConnect\Connect-ScreenConnectSupportSession.ps1" -ScreenConnectUri "https://instance.screenconnect.com/" -SessionName "MDT Deployment - %COMPUTERNAME%"</Path>
		</RunSynchronousCommand>
		<RunSynchronousCommand wcm:action="add">
			<Description>Lite Touch PE</Description>
			<Order>2</Order>
			<Path>wscript.exe X:\Deploy\Scripts\LiteTouch.wsf</Path>
		</RunSynchronousCommand>
	</RunSynchronous>

*Note: Make sure you change the Order for the Lite Touch PE to "2"*

### Rebuild MDT Images

1.	Open the **Deployment Workbench**
2.	Right-click on your deployment share and choose **Update Deployment Share**
3.	Choose **Completely regenerate teh boot images**
4.	Click **Next**
5.	Click **Next**
6.	Wait for images to be processed
7.	Click **Finish**
