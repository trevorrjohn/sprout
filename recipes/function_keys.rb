node.default['function_keys']['use_function_keys_as_function_keys'] = true

as_fn_keys = node.default['function_keys']['use_function_keys_as_function_keys'] ? "0" : "1"

# The following won't take effect until the person logs out & logs back in again.
# THE BELT
execute "Turn " + ( as_fn_keys ? "on" : "off" ) + " function-keys-work-as-function keys" do
  command "defaults write .GlobalPreferences com.apple.keyboard.fnState -bool #{node.default['function_keys']['use_function_keys_as_function_keys']}"
  user WS_USER
end

# Attempt an interactive change.  Two req'ts: 1) user must be logged in 2) assistive devices enabled
# THE SUSPENDERS
ruby_block "Fix Function Keys" do
  block do
    # check if we are logged into the console
    if system("ps aux | grep SystemUI | grep -v grep")
      # check if assistive devices is enabled
      if system("osascript -e '
        tell application \"System Events\"
         set UI_enabled to UI elements enabled
        end tell
        if UI_enabled is false then
         error \"access for assistive devices is NOT enabled! (This is not an error, just a warning)\"
        else
         return \"access for assistive devices IS enabled!\"
        end if'")
        system("osascript -e '
          tell application \"System Preferences\"
            set current pane to pane \"com.apple.preference.keyboard\"
          end tell
          tell application \"System Events\"
            tell application process \"System Preferences\"
              click radio button \"Keyboard\" of tab group 1 of window \"Keyboard\"
              if value of checkbox \"Use all F1, F2, etc. keys as standard function keys\" of tab group 1 of window \"Keyboard\" is #{as_fn_keys} then
                click checkbox \"Use all F1, F2, etc. keys as standard function keys\" of tab group 1 of window \"Keyboard\"
              end if
            end tell
            quit application \"System Preferences\"
          end tell'")
      end
    end
  end
end
