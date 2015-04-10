## ACCOUNT LOCKED NOTIFICATION
## Written by Fahad Talib 18/7/2014
##
## To be run on Win-DC(n) with administrative privileges in order to access Security Event Log
## To be triggered by a scheduled task triggered by the event 4767

# Enable AD interrogation 
Import-Module ActiveDirectory

# Fetch Last Unlocked Account Event from DC Security Log
$Event = Get-WinEvent -FilterHashtable @{LogName='Security';Id=4767} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending | Select -First 1


# Fetch Variables from AD and Event Log 
[string]$User = $Event.Properties[0].Value
$Usern = Get-ADUser -Identity $User
$userName = $usern.Name

$Domain = $Event.Properties[5].Value
[string]$UnlockBy =  $Event.Properties[4].Value
$UnlockByUserN = Get-ADUser -Identity $UnlockBy
$UnlockByUserName = $UnlockByUserN.Name
$UnlockByDomain = $Event.Properties[5].Value
$Computer = $Event.MachineName

# Build Email Notification
$MailMessage = New-Object system.net.mail.mailmessage

# Email Subject
$MailSubject= "Account Unlocked: " + $Domain + "\" + $User
$MailMessage.Subject = $MailSubject

# Email Message Content
$MailBody = "Account Name: " + $Domain + "\" + $User + "`r`n" + "Unlocked User: " + $Username  + "`r`n" + "Workstation: " + $Computer + "`r`n" + "Time: " + $Event.TimeCreated + "`n`n" + "Unlocked By: " + $UnlockByDomain + "\" + $UnlockBy + "`r`n" + "Unlocked By User: " + $UnlockByUserName + "`n`n" + $Event.Message
$MailMessage.Body = $MailBody

# Email From:
$MailMessage.from = "ICT_IS_Windows_Team@ga.gov.au"

# Email To:
If ($User -like "u*") 
	{
	$MailMessage.To.add("itservicedesk@ga.gov.au")
	}
Else
	{
	$MailMessage.To.add("ICT_IS_Windows_Team@ga.gov.au")
	}
	
# Is Mail HTML?
$MailMessage.IsBodyHtml = 0

# Send Mail Notification
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "mailhost.ga.gov.au"
$SmtpClient.Send($MailMessage)


