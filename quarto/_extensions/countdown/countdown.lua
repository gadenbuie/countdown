-- Retrieve countdown configuration data
local configData = require("config")
-- Specify the embedded version
local countdownVersion = configData.countdownVersion

-- Only embed resources once if there are multiple timers present
local needsToExportDependencies = true

-- List CSS default options
local default_style_keys = {
  "font_size",
  "margin",
  "padding",
  "box_shadow",
  "border_width",
  "border_radius",
  "line_height",
  "color_border",
  "color_background",
  "color_text",
  "color_running_background",
  "color_running_border",
  "color_running_text",
  "color_finished_background",
  "color_finished_border",
  "color_finished_text",
  "color_warning_background",
  "color_warning_border",
  "color_warning_text"
}

-- Check if variable missing or an empty string
local function isVariableEmpty(s)
  return s == nil or s == ''
end

-- Check if variable is present
local function isVariablePopulated(s)
  return not isVariableEmpty(s)
end

-- Check if a table is empty
local function isTableEmpty(tbl)
  return next(tbl) == nil
end

-- Check if a table is populated
local function isTablePopulated(tbl)
  return not isTableEmpty(tbl)
end

-- Check whether an argument is present in kwargs
-- If it is, return the value
local function tryOption(options, key)

  -- Protect against an empty options
  if not (options and options[key]) then
    return nil
  end

  -- Retrieve the option
  local option_value = pandoc.utils.stringify(options[key])
  -- Verify the option's value exists, return value otherwise nil.
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

-- Check whether the play_sound parameter contains `"true"`/`"false"` or
-- if it is a custom path
local function tryPlaySound(play_sound)
  if play_sound == "false" or play_sound == "true" then
      return play_sound
  elseif type(play_sound) == "string" and string.len(play_sound) > 0 then
      return play_sound
  else
      return "false"
  end
end

-- Define the infix operator %:?% to handle styling if missing
local function safeStyle(options, key, fmtString)
  -- Attempt to retrieve the style option
  local style_option = tryOption(options, key)
  -- If it is present, format it as a CSS value
  if isVariablePopulated(style_option) then
    return string.format(fmtString, key:gsub("_", "-"), style_option)
  end
  -- Otherwise, return an empty string that when concatenated does nothing.
  return ""
end

-- Construct the CSS style attributes
local function structureCountdownCSSVars(options)
  -- Concatenate style properties with their values using %:?% from kwargs
  local stylePositional = {"top", "right", "bottom", "left"}
  local stylePositionalTable = {}
  local styleDefaultOptionsTable = {}

  -- Build the positional style without prefixing countdown variables
  for i, key in ipairs(stylePositional) do
    stylePositionalTable[i] = safeStyle(options, key, "%s: %s;")
  end

  -- Build the countdown variables for styling
  for i, key in ipairs(default_style_keys) do
    styleDefaultOptionsTable[i] = safeStyle(options, key, "--countdown-%s: %s;")
  end

  -- Concatenate entries together
  return table.concat(stylePositionalTable) .. table.concat(styleDefaultOptionsTable)
end

-- Handle global styling options by reading options set in the meta key
local function countdown_style(options)

  -- Check if options have values; if it is empty, just exit.
  if isVariableEmpty(options) or isTableEmpty(options) then
    return nil
  end

  -- Determine the selector value
  local possibleSelector = getOption(options, "selector", ":root")

  -- Restructure options to ("key:value;--countdown-<key>: <value>;) string
  local structuredCSS = structureCountdownCSSVars(options)

  -- Embed into the document to avoid rendering to disk and, then, embedding a URL.
  quarto.doc.include_text('in-header',
    string.format(
      "<!-- Countdown Global CSS -->\n<style text='text/css'>%s {%s}</style>",
      possibleSelector,
      structuredCSS
    )
  )
  -- Note: This feature or using `add_supporting` requires Quarto v1.4 or above

end

-- Handle embedding/creation of assets once
local function ensureHTMLDependency(meta)
  -- Register _all_ assets together.
  quarto.doc.addHtmlDependency({
    name = "countdown",
    version = countdownVersion,
    scripts = { "assets/countdown.js"},
    stylesheets = { "assets/countdown.css"},
    resources = {"assets/smb_stage_clear.mp3"}
  })

  -- Embed custom settings into the document based on document-level settings
  countdown_style(meta.countdown)

  -- Disable re-exporting if no-longer needed
  needsToExportDependencies = false
end

-- Function to parse an unnamed time string argument supplied
-- in the format of 'MM:SS'
local function parseTimeString(args)
  -- Check if the input argument is provided and is of type string
  if #args == 0 or type(args[1]) ~= "string" then
    return nil
  end

  -- Attempt to extract minutes and seconds from the time string
  local minutes, seconds = args[1]:match("(%d+):(%d+)")

  -- Check if the pattern matching was successful
  if isVariableEmpty(minutes) or isVariableEmpty(seconds) then
    -- Log an error message if the format is incorrect
    quarto.log.error(
      "The quartodown time string must be in the format 'MM:SS'.\n" ..
      "Please correct countdown timer with time string given as `" .. args[1] .. "`"
    )
    -- Raise an assertion error to stop further execution (optional, depending on your requirements)
    assert("true" == "false")
  end

  -- Return a table containing minutes and seconds as numbers
  return { minutes = tonumber(minutes), seconds = tonumber(seconds) }
end

local function countdown(args, kwargs, meta)
  local minutes, seconds

  -- Retrieve named time arguments and fallback on default values if missing
  local arg_time = parseTimeString(args)
  if isVariablePopulated(arg_time) then
    minutes = arg_time.minutes
    seconds = arg_time.seconds
    if isVariablePopulated(tryOption(kwargs, "minutes")) or
       isVariablePopulated(tryOption(kwargs, "seconds")) then
      quarto.log.warning(
        "Please do not specify `minutes` or `seconds` parameters" ..
        "when using the time string format.")
    end
  else
    minutes = tonumber(getOption(kwargs, "minutes", 1))
    seconds = tonumber(getOption(kwargs, "seconds", 0))
  end

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
  local play_sound = tryPlaySound(getOption(kwargs, "play_sound", "false"))

  -- Check to see if positional outcomes are set; if not, default both bottom and right to 0.
  if isVariableEmpty(tryOption(kwargs, "top")) and
     isVariableEmpty(tryOption(kwargs, "bottom")) then
    kwargs["bottom"] = 0
  end

  if isVariableEmpty(tryOption(kwargs, "left"))  and
     isVariableEmpty(tryOption(kwargs, "right")) then
    kwargs["right"] = 0
  end

  local style = structureCountdownCSSVars(kwargs)

  local rawHtml = table.concat({
    '<div ',
    '\n  id="', id, '"',
    '\n  class="', class, '"',
    '\n  data-warn-when="', warn_when,'"',
    '\n  data-update-every="', update_every,'"',
    '\n  data-play-sound="', tostring(play_sound),'"',
    '\n  data-blink-colon="', tostring(blink_colon),'"',
    '\n  data-start-immediately="', tostring(start_immediately),'"',
    '\n  tabindex="0"',
    '\n  style="', style ,'">',
    '\n  <div class="countdown-controls">',
    '\n    <button class="countdown-bump-down">−</button>',
    '\n    <button class="countdown-bump-up">+</button>',
    '\n </div>',
    '\n <code class="countdown-time">',
    '<span class="countdown-digits minutes">', string.format("%02d", minutes),
    '</span><span class="countdown-digits colon">:</span>',
    '<span class="countdown-digits seconds">', string.format("%02d", seconds), '</span></code>',
    '\n </div>'
  })

  -- Return a new Div element with modified attributes
  return  pandoc.RawBlock("html", rawHtml)
end



return {
  ['countdown'] = countdown
}
