-- Specify embedded version 
local countdownEmbeddedVersion = "0.0.1"

-- Only embed resources once if there are multiple timers present 
local needsToExportDependencies = true

-- Check if variable missing or an empty string
local function isVariableEmpty(s)
  return s == nil or s == ''
end

-- Check if variable is present
local function isVariablePopulated(s)
  return not isVariableEmpty(s)
end

-- Check whether an argument is present in kwargs
-- If it is, return the value
local function tryOption(options, key)
  option_value = pandoc.utils.stringify(options[key])
  if isVariablePopulated(option_value) then
    return option_value
  else
    return nil
  end
end

-- Retrieve the option value or use the default value
local function getOption(options, key, default)
  return tryOption(options, key) or default
end

-- Define the infix operator %:?% to handle styling if missing
local function safeStyle(x, y)
  if isVariablePopulated(x) then
    -- quarto.log.output("Hi!")
    -- quarto.log.output(x)
    return y .. ":" .. pandoc.utils.stringify(x) .. ";"
  end
  return ""
end

local function countdown_style(meta)

  -- Retrieve the countdown options from meta
  local options = meta.countdown

  -- Check if countdown exist; if it doesn't, just exit.
  if isVariableEmpty(options) then
    return nil
  end
  
  local defaults = {
    -- Font size for the countdown element
    font_size = "3rem",
    -- Margin around the countdown element
    margin = "0.6em",
    -- Padding within the countdown element
    padding = "10px 15px",
    -- Shadow applied to the countdown element
    box_shadow = "0px 4px 10px 0px rgba(50, 50, 50, 0.4)",
    -- Border width of the countdown element
    border_width = "0.1875rem",
    -- Border radius of the countdown element
    border_radius = "0.9rem",
    -- Line height of the countdown element
    line_height = "1",
    -- Border color of the countdown element
    color_border = "#ddd",
    -- Background color of the countdown element
    color_background = "inherit",
    -- Text color of the countdown element
    color_text = "inherit",
    -- Background color when the countdown is running
    color_running_background = "#43AC6A",
    -- Border color when the countdown is running
    color_running_border = "#2A9B59FF", -- Needs color_darken()
    -- Text color when the countdown is running
    color_running_text = 'inherit',
    -- Background color when the countdown is finished
    color_finished_background = "#F04124",
    -- Border color when the countdown is finished
    color_finished_border = "#DE3000FF",  -- Needs color_darken()
    -- Text color when the countdown is finished
    color_finished_text = 'inherit',
    -- Background color when the countdown has a warning
    color_warning_background = "#E6C229",
    -- Border color when the countdown has a warning
    color_warning_border = "#CEAC04FF", -- Needs color_darken()
    -- Text color when the countdown has a warning
    color_warning_text = 'inherit',
    -- Selector for the countdown element
    selector = "root"
  }
  

  -- Pass defaults into make_countdown_css
  for key, default_value in pairs(defaults) do
    options[key] = getOption(options, key, default_value)
  end


  -- Embed into the document to avoid rendering to disk and, then, embedding a URL.
  -- quarto.doc.include_text('in-header', "<style>" .. configuredCSS .. "</style>")	
  -- Note: This feature or using `add_supporting` requires Quarto v1.4 or above

end

-- Handle embedding/creation of assets once
local function ensureHTMLDependency(meta)

  -- Register _all_ assets together.
  quarto.doc.addHtmlDependency({
    name = "countdown",
    version = countdownEmbeddedVersion,
    scripts = { "assets/countdown.js"},
    stylesheets = { "assets/countdown.css"},
    resources = {"assets/smb_stage_clear.mp3"}
  })

  -- Embed custom settings into the document based on document-level settings
  countdown_style(meta)

  -- Disable re-exporting if no-longer needed
  needsToExportDependencies = false
end

local function countdown(args, kwargs, meta)
  
  -- Retrieve named time arguments and fallback on default values if missing
  local minutes = tonumber(getOption(kwargs, "minutes", 1))
  local seconds = tonumber(getOption(kwargs, "seconds", 0))

  -- Calculate total time in seconds
  local time = minutes * 60 + seconds

  -- Calculate minutes by dividing total time by 60 and rounding down
  minutes = math.floor(time / 60)

  -- Calculate remaining seconds after extracting minutes
  seconds = time - minutes * 60
  
  -- Check if minutes is greater than or equal to 100 (the maximum possible for display)
  if minutes >= 100 then
    quarto.log.error("The number of minutes must be less than 100.")
    assert("true" == "false")
  end

  if needsToExportDependencies then
    ensureHTMLDependency(meta)
  end

  -- Retrieve the ID given by the user or attempt to create a unique ID by timestamp
  local id = getOption(kwargs, "id", "timer_" .. pandoc.utils.sha1(tostring(os.time())))

  -- Construct the 'class' attribute by appending "countdown" to the existing class (if any)
  local class = getOption(kwargs, "class", "")
  class = class ~= "" and "countdown " .. class or "countdown"

  -- Determine if a warning should be given
  local warn_when = tonumber(getOption(kwargs, "warn_when", 0))
    
  -- Retrieve and convert "update_every" attribute to a number, default to 1 if not present or invalid
  local update_every = tonumber(getOption(kwargs, "update_every", 1))

  -- Retrieve "blink_colon" attribute and set 'blink_colon' to true if it equals "true", otherwise false
  local blink_colon = getOption(kwargs, "blink_colon", update_every > 1) == "true"

  -- Retrieve "start_immediately" attribute and set 'start_immediately' to true if it equals "true", otherwise false
  local start_immediately = getOption(kwargs, "start_immediately", "false") == "true"

  -- Retrieve "play_sound" attribute as a string, default to "false" if not present
  local play_sound = getOption(kwargs, "play_sound", "false")

  -- Construct the style attribute based on element attributes
  -- Concatenate style properties with their values using %:?% from kwargs
  local styleKeys = {"top", "right", "bottom", "left", "margin", "padding", "font_size", "line_height"}
  local style = ""
  
  for _, key in ipairs(styleKeys) do
      style = style .. safeStyle(kwargs[key], key)
  end

  local rawHtml = [[<div id="]] .. id .. [[" class="]] .. class .. [[" 
      data-warn-when="]] .. warn_when .. [["
      data-update-every="]] .. update_every .. [["
      data-play-sound="]] .. tostring(play_sound) .. [["
      data-blink-colon="]] .. tostring(blink_colon) .. [["
      data-start-immediately="]] .. tostring(start_immediately) .. [["
      tabindex="0"
      style="]] .. style .. [[">
<div class="countdown-controls">
<button class="countdown-bump-down">−</button>
<button class="countdown-bump-up">+</button>
</div>
<code class="countdown-time">]] .. 
[[<span class="countdown-digits minutes">]] .. 
string.format("%02d", minutes) .. 
[[</span><span class="countdown-digits colon">:</span>]] ..
[[<span class="countdown-digits seconds">]] .. 
string.format("%02d", seconds) .. 
[[</span></code>
</div>
  ]]

  quarto.log.output(rawHtml)

  -- Return a new Div element with modified attributes
  return  pandoc.RawBlock("html", rawHtml)
end



return {
  ['countdown'] = countdown
}
