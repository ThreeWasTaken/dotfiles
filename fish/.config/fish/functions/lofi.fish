function lofi
    # Start MPV in background
    mpv --no-video --quiet --ytdl-format=bestaudio https://www.youtube.com/watch?v=jfKfPfyJRdk > /dev/null 2>&1 &
    
    # Save the MPV PID if you want to use it instead of killall
    set mpv_pid $last_pid

    # Trap SIGINT (Ctrl+C) to stop MPV too
    function on_interrupt --on-signal SIGINT
        echo "Caught Ctrl+C, stopping MPV..."
        killall mpv > /dev/null 2>&1
        exit
    end

    # Run CAVA in the foreground
    cava

    # Also try to clean up if CAVA exits normally
    killall mpv > /dev/null 2>&1
end
