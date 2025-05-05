#!/usr/bin/env fish

set dotrepo ~/three-dotfiles
set oldrepo ~/dotfiles
set config_root ~/.config
set timestamp (date "+%Y%m%d_%H%M%S")
set report ~/stow_report_$timestamp.log

cd $dotrepo

#!/usr/bin/env fish

set dotrepo ~/three-dotfiles
set config_root ~/.config
set report ~/stow_report_(date "+%Y%m%d_%H%M%S").log
set use_adopt 0  # Set to 1 to enable --adopt

echo "📦 Starting safe stow process..." | tee $report

for dir in $dotrepo/*
    set name (basename $dir)
    echo "🔧 Checking: $name" | tee -a $report

    # If you want to use --adopt to take over existing files, set the flag
    if test $use_adopt -eq 1
        stow --adopt --dir=$dotrepo --target=$HOME --verbose $name >>$report 2>&1
    else
        stow --dir=$dotrepo --target=$HOME --verbose $name >>$report 2>&1
    end

    if test $status -eq 0
        echo "✅ Successfully stowed: $name" | tee -a $report
    else
        echo "❌ Failed to stow: $name (check log for details)" | tee -a $report
    end
end

echo "📄 Report saved to: $report"
