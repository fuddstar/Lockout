## ACCOUNT LOCKED NOTIFICATION
## Written by Fahad Talib 18/7/2014
##
## To be run on Win-DC(n) with administrative privileges in order to access Security Event Log
## To be triggered by a scheduled task triggered by the event 4767

# Enable AD interrogation 
Import-Module ActiveDirectory

# Fetch Last Unlocked Account Event from DC Security Log
$Event=get-eventlog -log security | where {$_.eventID -eq 4767} | Sort-Object index -Descending | select -first 1

# Fetch Variables from AD and Event Log 
$User = $Event.ReplacementStrings[0]
$Usern = Get-ADUser -Filter 'samAccountName -like $User' 
$userName = $usern.Name
$Domain = $Event.ReplacementStrings[1]
$UnlockBy =  $Event.ReplacementStrings[4]
$UnlockByUserN = Get-ADUser -Filter 'samAccountName -like $UnlockBy' 
$UnlockByUserName = $UnlockByUserN.Name
$UnlockByDomain = $Event.ReplacementStrings[5]
$Computer = $Event.MachineName

# Build Email Notification
$MailMessage = New-Object system.net.mail.mailmessage

# Email Subject
$MailSubject= "Account Unlocked: " + $Domain + "\" + $User
$MailMessage.Subject = $MailSubject

# Email Message Content
$MailBody = "Account Name: " + $Domain + "\" + $User + "`r`n" + "Unlocked User: " + $Username  + "`r`n" + "Workstation: " + $Computer + "`r`n" + "Time: " + $Event.TimeGenerated + "`n`n" + "Unlocked By: " + $UnlockByDomain + "\" + $UnlockBy + "`r`n" + "Unlocked By User: " + $UnlockByUserName + "`n`n" + $Event.Message
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
