# 1.0.8030.24604
Set-Alias -Name nvimq -Value "C:\neovimqt\bin\nvim-qt.exe"


# %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

function wtd { wt -d . }

# touch
function touch ($command) {
    New-Item -Path $command -ItemType File | out-null && Write-Host Created $command
}

function rm ($command) {
    Remove-Item $command -Recurse -Force && Write-Host Removed $command
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

. oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\kali.omp.json" | Invoke-Expression

Import-Module Terminal-Icons

Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

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

function cas {
  # Clear Alternate Screen
  # https://github.com/microsoft/terminal/issues/17739
  [System.Console]::Write("`e[?1049l")
  Clear-Host  # Clears the console
}

function ias {
  # Entering Alternate Screen
  # https://github.com/microsoft/terminal/issues/17739
  [System.Console]::Write("`e[?1049h")
  Clear-Host  # Clears the console
}

function conda_active {
    & 'C:\ProgramData\miniconda3\shell\condabin\conda-hook.ps1'
    conda activate 'C:\ProgramData\miniconda3'
}

$global:originalPrompt = $function:prompt

function DeactivateVenvPrompt {
    $function:prompt = $global:originalPrompt
}
$env:CONDA_CHANGEPS1 = "false"

function fzf-cd {
  $fdArgs = @(
    ".", "$HOME\IdeaProjects", "$HOME\goproject",  # Add your Go project directory here
    "--type", "directory",
    "--max-depth", "1",
    "--exclude", ".git",
    "--exclude", "node_modules"
  )

  $fzfArgs = @(
    "--preview", "dir {}"
    "--bind=ctrl-space:toggle-preview",
    "--exit-0",
    "--exact"   # Add this for exact matching
  )

  $fdOutput = & fd @fdArgs 2>$null

  if (-not $fdOutput) {
    Write-Host "No directories found." -ForegroundColor Yellow
    return
  }

  $target = $fdOutput | fzf @fzfArgs

  if (-not $target) { return }

  if (Test-Path $target -PathType Leaf) {
    $target = Split-Path $target -Parent
  }

  Set-Location $target
}



Set-FzfHistoryKeybind -Chord Ctrl+r

