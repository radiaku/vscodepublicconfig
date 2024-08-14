# 1.0.8030.24604
Set-Alias -Name nvimq -Value "C:\neovimqt\bin\nvim-qt.exe"


function wtd { wt -d . }

# touch
function touch ($command) {
    New-Item -Path $command -ItemType File | out-null && Write-Host Created $command
}

function rm ($command) {
    Remove-Item $command -Recurse && Write-Host Removed $command
}

## $Env:PATH management
Function Add-DirectoryToPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName")]
        [string] $path,
        [string] $variable = "PATH",

        [switch] $clear,
        [switch] $force,
        [switch] $prepend,
        [switch] $whatIf
    )

    BEGIN {

        ## normalize paths

        $count = 0
        $paths = @()

        if (-not $clear.IsPresent) {

            $environ = Invoke-Expression "`$Env:$variable"
            $environ.Split(";") | ForEach-Object {
                if ($_.Length -gt 0) {
                    $count = $count + 1
                    $paths += $_.ToLowerInvariant()
                }
            }

            Write-Verbose "Currently $($count) entries in `$env:$variable"
        }

        Function Array-Contains {
            param(
                [string[]] $array,
                [string] $item
            )

            $any = $array | Where-Object -FilterScript {
                $_ -eq $item
            }

            Write-Output ($null -ne $any)
        }
    }

    PROCESS {

        if ([IO.Directory]::Exists($path) -or $force.IsPresent) {

            $path = $path.Trim()

            $newPath = $path.ToLowerInvariant()
            if (-not (Array-Contains -Array $paths -Item $newPath)) {
                if ($whatIf.IsPresent) {
                    Write-Host $path
                }

                if ($prepend.IsPresent) { $paths = , $path + $paths }
                else { $paths += $path }

                Write-Verbose "Adding $($path) to `$env:$variable"
            }
        }
        else {

            Write-Host "Invalid entry in `$Env:$($variable): ``$path``" -ForegroundColor Yellow

        }
    }

    END {

        ## re-create PATH environment variable

        $separator = [IO.Path]::PathSeparator
        $joinedPaths = [string]::Join($separator, $paths)

        if ($whatIf.IsPresent) {
            Write-Output $joinedPaths
        }
        else {
            Invoke-Expression " `$env:$variable = `"$joinedPaths`" "
        }
    }

}


# Import-Module oh-my-posh
# . oh-my-posh init pwsh --config "~/.poshthemes/oh-my-posh.json" | Invoke-Expression
# . oh-my-posh init pwsh --config "C:\Users\DELL\AppData\Local\Programs\oh-my-posh\themes\kali.omp.json" | Invoke-Expression
. oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\amro.omp.json" | Invoke-Expression

Import-Module Terminal-Icons

Set-PSReadLineOption -BellStyle None

# Set-PSReadLineOption -PredictionViewStyle ListView
# Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
# Set-PSReadlineKeyHandler -Key Tab -Function Complete
 
# Set the prediction view style to List by default
# Set-PSReadLineOption -PredictionViewStyle List

# function Show-HistoryList {
#     Set-PSReadLineOption -PredictionViewStyle ListView
#     Set-PSReadLineOption -PredictionSource History
#     [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
# }
#
# function Navigate-HistoryBackwards {
#     [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchBackward()
# }
#
# function Navigate-HistoryForwards {
#     [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
# }
#
# Set-PSReadLineKeyHandler -Key UpArrow -ScriptBlock {
#     Set-PSReadLineOption -PredictionViewStyle ListView
#     Navigate-HistoryBackwards
# }
#
# Set-PSReadLineKeyHandler -Key DownArrow -ScriptBlock {
#     Set-PSReadLineOption -PredictionViewStyle ListView
#     Navigate-HistoryForwards
# }

# Set-PSReadLineOption -EditMode Vi


#
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function MenuComplete
# Set-PSReadLineKeyHandler -Key Ctrl+P -Function HistorySearchBackward
# Set-PSReadLineKeyHandler -Key Ctrl+N -Function HistorySearchForward

# Set-PSReadlineKeyHandler "Ctrl+Delete" KillWord
# Set-PSReadlineKeyHandler "Ctrl+Backspace" BackwardKillWord
# Set-PSReadlineKeyHandler "Ctrl+LeftArrow" BackwardWord
# Set-PSReadlineKeyHandler "Ctrl+RightArrow" NextWord
# Set-PSReadlineKeyHandler "Tab" MenuComplete

# Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
# Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Set-PSReadLineOption -EditMode Vi
#adding function whereis
# Set-PSReadLineKeyHandler -Chord Ctrl+n -Function CancelLine

function ll {
    Get-ChildItem $Args[0] |
        Format-Table Mode, @{N='Owner';E={(Get-Acl $_.FullName).Owner}}, Length, LastWriteTime, @{N='Name';E={if($_.Target) {$_.Name+' -> '+$_.Target} else {$_.Name}}}
}

function whereis ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function reloadprofile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if(Test-Path $_){
            Write-Verbose "Running $_"
            . $_
        }
    }
}


