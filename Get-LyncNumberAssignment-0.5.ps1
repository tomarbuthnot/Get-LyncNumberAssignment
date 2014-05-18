Function Get-LyncNumberAssignment {
<#
.SYNOPSIS
    Get Lync users/objects assigned to a Telephone number in Lync


.DESCRIPTION
    Get Lync users/objects assigned to a Telephone number in Lync. In Lync many different "objects" can have a number assigned; 
    Users, Private Lines, Analog Devices, Common Area Phones, Exchange UM Contact Objects, Dialin Conference,
    Application Endpoints, Response Groups

    There is no easy way to check if a number is assigned to any of these, or to get back all the objects across Lync assigned
    a number of a subset of a number. It also returns the registrar pool that owns the object.

    This script allows you to get all the objects assigned a number, or all the objects matching a partial number, for example all
    objects assigned a UK number, "+44"

    Critically, it outputs the results as an object you can sort, filter and mainpulate.

    This is a function. You need to dot source it into you session
    PS C:\>. c:\mydownloads\Get-LyncNumberAssignment-0.5.ps1

.LINK
    http://lyncdup.com


.EXAMPLE
    PS C:\> Get-LyncNumberAssignment

.EXAMPLE
    PS C:\> Get-LyncNumberAssignment -Number "+44"

.EXAMPLE
    PS C:\> Get-LyncNumberAssignment -Number "+44" | Sort-Object LineURI | Format-Table -Autosize

.NOTES
    Version: 0.5
    Author: Tom Arbuthnot
    Disclaimer: Use completely at your own risk. 
    Test on non-production systems
    Do not run any script you don't understand.



#>

# Sets that -Whatif and -Confirm should be allowed
[cmdletbinding(SupportsShouldProcess=$true)]

Param 	(
	 	[Parameter(Mandatory=$false,
                   HelpMessage="Input Number or partial number, default is any number")]
    	$Number,

		
		[Parameter(Mandatory=$false,
                   HelpMessage="Error Log location, default C:\<Command Name>_ErrorLog.txt")]
		[string]$ErrorLog = "c:\$($myinvocation.mycommand)_ErrorLog.txt",
        [switch]$LogErrors
		
		) #Close Parameters



Begin 	{
    	Write-Verbose "Starting $($myinvocation.mycommand)"
		Write-Verbose "Error log will be $ErrorLog"
		
		# Set everytihng ok to true, this is used to stop the script if we have an issue
		# Each Try Catch Finally block, or action (within the process block of the function) depends on $EverythingOK being true
		# A dependancy step will set $everything_ok to $false, therefore other steps will be skipped
		$EverythingOK = $true
		
		# Catch Actions Function to avoid repeating code, don't need to . source within a script
                    Function ErrorCatch-Actions 
                    {
					Param 	(
							[Parameter(Mandatory=$false,
							HelpMessage="Switch to Allow Errors to be Caught without setting EverythingOK to False, stopping other aspects of the script running")]
							# By default any errors caught will set $EverythingOK to false causing other parts of the script to be skipped
							[switch]$SetEverythingOKVariabletoTrue
							) # Close Parameters
					# Set Everything OK to false to avoid running dependant actions
				    If($SetEverythingOKVariabletoTrue) {$EverythingOK = $true}
					else {$EverythingOK = $false}
               	    # Print Error to Output
                    Write-Output " "
                    Write-Warning "%%% Error Catch Has Been Triggered (To log errors to text file start script with -LogErrors switch) %%%"
                    Write-Output " "
                    Write-Warning "Last Error was:"
                    Write-Output " "
				    Write-Error $Error[0]
               	       if ($LogErrors) {
									    # Add Date to Error Log File
									
                                        Get-Date -format "dd/MM/yyyy HH:mm" | Out-File $ErrorLog -Append
									    # Output Error to Error Log file
									    $Error | Out-File $ErrorLog -Append
                                        "%%%%%%%%%%%%%%%%%%%%%%%%%% LINE BREAK BETWEEN ERRORS %%%%%%%%%%%%%%%%%%%%%%%%%%" | Out-File $ErrorLog -Append
                                        " " | Out-File $ErrorLog -Append
									    Write-Warning "Errors Logged to $ErrorLog"
                                        # Clear Error Log Variable
                                        $Error.Clear()
                                        } #Close If
                    } # Close Error-CatchActons Function
		    
		} #Close Function Begin Block

Process {
    		
		
		If ($EverythingOK)
		{
		Try 	{
                
		If ($number -ne $null)
		{
                $match = "*$number*"
		}
		else
		{
		$match = "*"
		}




                Write-Verbose "Match Number is $match"

                # Define a new object to gather output
                $OutputCollection=  @()
		


                # For Each one we want to output
                    # LineURI, Name, supuri, Type (USER/RGS etc)

                Write-Verbose "Checking Users"
                Get-CsUser -Filter {LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.SipAddress
                    $output | add-member NoteProperty "Type" -value "User"
		    $output | add-member NoteProperty "RegistrarPool" -value "$($_.RegistrarPool)"
                    $OutputCollection += $output
                    }


                Write-Verbose "Checking User Private Lines"
                Get-CsUser -Filter {PrivateLine -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.SipAddress
                    $output | add-member NoteProperty "Type" -value "PrivateLineUser"
	            $output | add-member NoteProperty "RegistrarPool" -value "$($_.RegistrarPool)"
                    $OutputCollection += $output
                    }


                Write-Verbose "Checking Analog Devices"
                Get-CsAnalogDevice -Filter {LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.SipAddress
                    $output | add-member NoteProperty "Type" -value "AnalogDevice"
                    $output | add-member NoteProperty "RegistrarPool" -value "$($_.RegistrarPool)"
	            $OutputCollection += $output
                    }


                Write-Verbose "Checking Common Area Phones"
                Get-CsCommonAreaPhone -Filter {LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.SipAddress
                    $output | add-member NoteProperty "Type" -value "CommonAreaPhone"
                    $output | add-member NoteProperty "RegistrarPool" -value "$($_.RegistrarPool)"
                    $OutputCollection += $output
                    }

                Write-Verbose "Checking Exchange UM Contact Objects"
                Get-CsExUmContact -Filter {LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.SipAddress
                    $output | add-member NoteProperty "Type" -value "ExUMContact"
                    $output | add-member NoteProperty "RegistrarPool" -value "$($_.RegistrarPool)"
                    $OutputCollection += $output
                    }

                Write-Verbose "Checking Dialin Conference Numbers"
                Get-CsDialInConferencingAccessNumber -Filter {LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.PrimaryUri
                    $output | add-member NoteProperty "Type" -value "DialInConf"
                    $output | add-member NoteProperty "RegistrarPool" -value "$($_.Pool)"
                    $OutputCollection += $output
                    }

                Write-Verbose "Checking Trusted Application Endpoints"
                Get-CsTrustedApplicationEndpoint -Filter {LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.DisplayName
                    $output | add-member NoteProperty "SipUri" -value $_.SipAddress
                    $output | add-member NoteProperty "Type" -value "TrustedAppEndPoint"
                    $output | add-member NoteProperty "RegistrarPool" -value "$($_.RegistrarPool)"
                    $OutputCollection += $output
                    }
                
                
                # No filter on Get-CSRGSworkflow
                Write-Verbose "Checking Response Groups"
                Get-CsRgsWorkflow | Where-Object {$_.LineURI -like $match} | ForEach-Object {
                    $output = New-Object -TypeName PSobject 
                    $output | add-member NoteProperty "LineUri" -value $_.LineURI
                    $output | add-member NoteProperty "DisplayName" -value $_.Name
                    $output | add-member NoteProperty "SipUri" -value $_.PrimaryUri
                    $output | add-member NoteProperty "Type" -value "ResponseGroup"
                    $output | add-member NoteProperty "RegistrarPool" -value "$($_.OwnerPool)"
                    $OutputCollection += $output
                    }


                    # Output collection
                    $OutputCollection



            	} # Close Try Block
			
		Catch 	{ErrorCatch-Actions
			   
            	} # Close Catch Block
		
		} # Close If Everthing OK Block 1
		
		
		# Next Script Action or Try,Catch Block goes here
		
		} #Close Function Process Block

End 	{
    	Write-Verbose "Ending $($myinvocation.mycommand)"
		} #Close Function End Block
 
} #End Function

# SIG # Begin signature block
# MIIQGQYJKoZIhvcNAQcCoIIQCjCCEAYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrzt1UKY3KBal7KoQ2Km4wtpq
# JTGggg1eMIIGozCCBYugAwIBAgIQD6hJBhXXAKC+IXb9xextvTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTEwMjExMTIwMDAwWhcNMjYwMjEwMTIwMDAwWjBvMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVkIElEIENvZGUg
# U2lnbmluZyBDQS0xMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnHz5
# oI8KyolLU5o87BkifwzL90hE0D8ibppP+s7fxtMkkf+oUpPncvjxRoaUxasX9Hh/
# y3q+kCYcfFMv5YPnu2oFKMygFxFLGCDzt73y3Mu4hkBFH0/5OZjTO+tvaaRcAS6x
# ZummuNwG3q6NYv5EJ4KpA8P+5iYLk0lx5ThtTv6AXGd3tdVvZmSUa7uISWjY0fR+
# IcHmxR7J4Ja4CZX5S56uzDG9alpCp8QFR31gK9mhXb37VpPvG/xy+d8+Mv3dKiwy
# RtpeY7zQuMtMEDX8UF+sQ0R8/oREULSMKj10DPR6i3JL4Fa1E7Zj6T9OSSPnBhbw
# JasB+ChB5sfUZDtdqwIDAQABo4IDQzCCAz8wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMIIBwwYDVR0gBIIBujCCAbYwggGyBghghkgBhv1sAzCC
# AaQwOgYIKwYBBQUHAgEWLmh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL3NzbC1jcHMt
# cmVwb3NpdG9yeS5odG0wggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBz
# AGUAIABvAGYAIAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBv
# AG4AcwB0AGkAdAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAg
# AHQAaABlACAARABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAg
# AHQAaABlACAAUgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBt
# AGUAbgB0ACAAdwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0
# AHkAIABhAG4AZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABo
# AGUAcgBlAGkAbgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wEgYDVR0TAQH/
# BAgwBgEB/wIBADB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHow
# eDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAdBgNVHQ4EFgQUe2jOKarAF75JeuHl
# P9an90WPNTIwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZI
# hvcNAQEFBQADggEBAHtyHWT/iMg6wbfp56nEh7vblJLXkFkz+iuH3qhbgCU/E4+b
# gxt8Q8TmjN85PsMV7LDaOyEleyTBcl24R5GBE0b6nD9qUTjetCXL8KvfxSgBVHkQ
# RiTROA8moWGQTbq9KOY/8cSqm/baNVNPyfI902zcI+2qoE1nCfM6gD08+zZMkOd2
# pN3yOr9WNS+iTGXo4NTa0cfIkWotI083OxmUGNTVnBA81bEcGf+PyGubnviunJmW
# eNHNnFEVW0ImclqNCkojkkDoht4iwpM61Jtopt8pfwa5PA69n8SGnIJHQnEyhgmZ
# cgl5S51xafVB/385d2TxhI2+ix6yfWijpZCxDP8wggazMIIFm6ADAgECAhAHg+Of
# aoJDPCCKgFvnHm/HMA0GCSqGSIb3DQEBBQUAMG8xCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xLjAs
# BgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBLTEwHhcN
# MTMwNzAxMDAwMDAwWhcNMTQwNzA5MTIwMDAwWjB/MQswCQYDVQQGEwJHQjEWMBQG
# A1UECBMNSGVydGZvcmRzaGlyZTESMBAGA1UEBxMJU3RldmVuYWdlMSEwHwYDVQQK
# ExhUaG9tYXMgQ2hhcmxlcyBBcmJ1dGhub3QxITAfBgNVBAMTGFRob21hcyBDaGFy
# bGVzIEFyYnV0aG5vdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALHE
# 1KWj6eAh2E54UiDcHmcmw817ohO4sZ5zMirY5CFJx4G/IIfEg6JHneIXtNrY9QbH
# 2gBvoCJ/j+rMLUiG0G8jw2n0mOAyWEcBDga57SDzI6OHyKM3n+OkC5D6wQSS0lH5
# e90Suegs5bxLfZFTSFWVRKsHhoCtKFVevaEKIbt2S8wE5Fdss2BCsmgf7RcIrj4r
# Zcxg3OZ1UDtDwCPIncryM0j/BC+81j/QPTJ4fu2rfSVEKELHR89JN+MAdrcJbWLH
# Zl9SgsVGDWG15wQUiVYB+A1Mz6ZwT+3St7/iJgWGFvZdcI+A7sEWZZSIyJMre8/s
# CYEeO1bRImqVbbS1RX8CAwEAAaOCAzkwggM1MB8GA1UdIwQYMBaAFHtozimqwBe+
# SXrh5T/Wp/dFjzUyMB0GA1UdDgQWBBQ4SFcQ1DpIYCaa1vJbAgMEUO7/UTAOBgNV
# HQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwcwYDVR0fBGwwajAzoDGg
# L4YtaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL2Fzc3VyZWQtY3MtMjAxMWEuY3Js
# MDOgMaAvhi1odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vYXNzdXJlZC1jcy0yMDEx
# YS5jcmwwggHEBgNVHSAEggG7MIIBtzCCAbMGCWCGSAGG/WwDATCCAaQwOgYIKwYB
# BQUHAgEWLmh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL3NzbC1jcHMtcmVwb3NpdG9y
# eS5odG0wggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYA
# IAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkA
# dAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAA
# RABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAA
# UgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAA
# dwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4A
# ZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkA
# bgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wgYIGCCsGAQUFBwEBBHYwdDAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEwGCCsGAQUFBzAC
# hkBodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURD
# b2RlU2lnbmluZ0NBLTEuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQAD
# ggEBAHgP9yvgRLYzST2TX1EyULaVCbCHskIGU492MMofP18wz0V6+k1xJ0oql+Oy
# Ph5gJBOnAeKOio1dyzxy6UHYTCEmFHgvI58KpJzy930szpCWCoaOIUBegy2zoYd+
# EKB0H1pA4FD93bkt3T48HlP/54FBkSeiDL/Q8Hw1ar7acZx0GOAfHOLa2QjUhzJK
# W1Zp9S2nWX2FSvM5HotQeQDp0UVqIgPd7d7FD16GiRZkPdSWoQ/bQcS+kpQzG9n6
# ePMe1HpHx0FFB78MBYd3LDpPs4XnZlw9pQGuAoL7T4lsoUNMH+SA0io+jRgtLUzB
# XUEZC8y0ESYBXxTteMmbzmUkxT8xggIlMIICIQIBATCBgzBvMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBD
# QS0xAhAHg+OfaoJDPCCKgFvnHm/HMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRrYvlDh/CHJq+j
# 2Ho6Pn6mcXit2DANBgkqhkiG9w0BAQEFAASCAQCiYAIibjqUmzk/TcQLmMWb0FIm
# WdoPzRNnoYfoKWeVW/nHppOmZhptjmdfDSwpyWYE035e/YTWSu/6cemqgjHfNs6f
# d62UQUogWsbgzgoFrkjVgmpQu5YU9XLqyY4rG/GrycBlQu36Zt7Ptwx5w5fUqGAn
# QNtwPbgjq1rDfutgItMgSLXltH/LCZinRQqJuLO+LNumnyAsz5810m54bLncb6Ca
# TYG5n6EHnrud0nnNlVC3b6zk0NyEC9xAWKBFCtd0HCnCnwAzhjMu3YM7Vuhjd7GP
# Xn0NpZKKslmaQ5pMEwIYuxd5Jg1LdM0tm+59BrxazcARcfm5pnQyvu6Fsyt5
# SIG # End signature block
