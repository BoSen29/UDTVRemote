import-module UniversalDashboard.Community

Get-UDDashboard | Stop-UDDashboard

$every10 = New-UDEndpointSchedule -Every 10 -Minute

$adbEndpoint = New-UDEndpoint -Schedule $every10 -Endpoint {

    $phoneUUID = "INSERT PHONEUUID"
	Invoke-Expression -Command "adb start-server" # makes sure the adb server is running

	#validate the phone is connected
	$devices = Invoke-Expression -Command "adb devices"

	if ($devices.Split([Environment]::NewLine)[1].Split("`t")[0] -eq $phoneUUID) {
		$cache:phoneConnected = $true
	}
	else {
		$cache:phoneConnected = $false
	}
}

function Invoke-ScreenTouch {
	param (
		[Parameter (
			Mandatory = $true,
			Position = 0
		)]
		[int]$x,
		[Parameter (
			Mandatory = $true,
			Position = 1
		)]
		[int]$y
	)
	Begin {

	}

	Process {
		Invoke-Expression -Command "adb shell input tap $x $y"
	}

	End {

	}
}

$endpointInit = New-UDEndpointInitialization -Function @("Invoke-ScreenTouch")

$theme = Get-UDTheme -Name "DefaultTight"

$dashboard = New-UDDashboard -Title "RemoteControl" -content {
	New-UDRow -Columns {
		New-UDColumn -SmallSize 3 -Content {
			New-UDButton -Text "Power" -Icon power_off -FontColor white -BackgroundColor red -OnClick {
				Invoke-ScreenTouch -x 150 -y 350
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 3 -Content {
			New-UDButton -Text "Menu" -Icon toolbox -OnClick {
				Invoke-ScreenTouch -x 420 -y 350
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 3 -Content {
			New-UDButton -Text "Back" -Icon backward -OnClick {
				Invoke-ScreenTouch -x 650 -y 350
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 3 -Content {
			New-UDButton -Text "Mute" -Icon volume_mute -OnClick {
				Invoke-ScreenTouch -x 900 -y 350
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
	}
	New-UDRow -Columns {
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "Vol+" -Icon volume_up -OnClick {
				Invoke-ScreenTouch -x 150 -y 650
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "" -Icon arrow_up -BackgroundColor orange -OnClick {
				Invoke-ScreenTouch -x 500 -y 650
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "HDMI1" -Icon television -OnClick {
				Invoke-ScreenTouch -x 900 -y 650
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
	}
	New-UDRow -Columns {
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "" -Icon arrow_left -BackgroundColor orange -OnClick {
				Invoke-ScreenTouch -x 150 -y 1000
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "Ok" -OnClick {
				Invoke-ScreenTouch -x 500 -y 1000
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "" -Icon arrow_right -BackgroundColor orange -OnClick {
				Invoke-ScreenTouch -x 900 -y 1000
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
	}
	New-UDRow -Columns {
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "Vol-" -Icon volume_down -OnClick {
				Invoke-ScreenTouch -x 150 -y 1400
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "" -Icon arrow_down -BackgroundColor orange -OnClick {
				Invoke-ScreenTouch -x 500 -y 1400
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
		New-UDColumn -SmallSize 4 -Content {
			New-UDButton -Text "HDMI2" -Icon television -OnClick {
				Invoke-ScreenTouch -x 900 -y 1400
			} -style @{
				width = "96%"
				height = 70
				"margin" = "2%"
			}
		}
	}
} -Theme $theme -EndpointInitialization $endpointInit -NavbarLinks @((New-UDLink -Text "Setting" -Icon gear -OnClick {
	Show-UDModal -Header {New-UDHeading -Text "Settings"} -Content {
		New-UDElement -Tag span -Endpoint {
			if ($cache:phoneConnected) {
				New-UDHtml -Markup "<strong>Status: </strong> Connected"
			}
			else {
				New-UDHtml -Markup "<strong>Status: </strong> Not connected"
			}
		}
		New-UDMonitor -Title "CPU Temp" -RefreshInterval 3 -Type Line -DataPointHistory 10 -Endpoint {
			(Invoke-Expression -Command " cat /sys/class/thermal/thermal_zone*/temp") / 1000 | Out-UDMonitorData
		}
	}
} ))

Start-UDDashboard -dashboard $dashboard -port 80 -AutoReload -Endpoint $adbEndpoint