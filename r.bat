
setlocal enabledelayedexpansion

set "directory=C:\Users\Vikas\Downloads\Telegram Desktop"
set "max_size=20480"  :: 20 KB in bytes

:loop
echo Checking images in %directory%

:: Loop through all image files in the directory
for %%f in ("%directory%\*.jpg") do (
    set "file=%%f"
    set "size=0"

    :: Get file size in bytes
    for %%a in ("%file%") do set size=%%~za

    :: Check if file size is greater than max_size
    if !size! gtr %max_size% (
        echo Resizing !file! to be under 20 KB

        :: Resize image
        magick "%file%" -resize 1024x1024 -quality 10 "%directory%\temp_output.jpg"
        
        :: Check size of the resized image
        for %%b in ("%directory%\temp_output.jpg") do set new_size=%%~zb
        
        :: If resized image is still too large, adjust quality and retry
        if !new_size! gtr %max_size% (
            echo Quality adjustment needed
            set /a quality=10
            :resize_loop
            set /a quality-=1
            if !quality! lss 1 goto :end_resize
            magick "%file%" -resize 1024x1024 -quality !quality! "%directory%\temp_output.jpg"
            for %%c in ("%directory%\temp_output.jpg") do set new_size=%%~zc
            if !new_size! lss %max_size% goto :end_resize
            goto :resize_loop
        )

        :end_resize
        :: Replace original file with resized image
        move /Y "%directory%\temp_output.jpg" "%file%"
    )
)

:: Wait 3 seconds before checking again
timeout /t 3 /nobreak >nul
goto loop
