set "CMD_CONFIG_ROOT=%~dp0"
set "CMD_CONFIG_SCRIPTS=%CMD_CONFIG_ROOT%scripts"

if exist "%CMD_CONFIG_SCRIPTS%\*.cmd" (
    for %%F in ("%CMD_CONFIG_SCRIPTS%\*.cmd") do call "%%~fF"
)