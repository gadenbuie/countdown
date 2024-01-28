-- Specify embedded version 
local countdownEmbeddedVersion = "0.0.1"

-- Only embed resources once if there are multiple timers present 
local needsToExportDependencies = true

-- List CSS default options
local default_style = {
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

-- Extract names from default style table
local function tableKeyNames(namedTable)

  -- Table to store keys
  local keysTable = {}

  -- Iterate over keys and store them
  for key, _ in pairs(namedTable) do
    table.insert(keysTable, key)
  end

  return keysTable
end

-- Store names for default styles
local default_style_names = tableKeyNames(default_style)

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

  local option_value = pandoc.utils.stringify(options[key])
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

-- Function that deletes entries that contain 'nil'
function removeEmptyEntries(tableWithNilEntries)

  -- Define a table to keep full entries
  local cleanedTable = {}

  -- Iterate across the table, retain full entries
  for key, value in pairs(tableWithNilEntries) do
      if isVariablePopulated(value) then
          cleanedTable[key] = value
      end
  end

  -- Return cleaned tables
  return cleanedTable
end

-- Define the infix operator %:?% to handle styling if missing
local function safeStyle(options, key)
  -- Attempt to retrieve the style option
  local style_option = tryOption(options, key)
  -- If it is present, format it as a CSS value
  if isVariablePopulated(style_option) then
    return table.concat({key, ":" , pandoc.utils.stringify(style_option), ";"})
  end
  -- Otherwise, return an empty string that when concatenated does nothing.
  return ""
end

-- Construct the inline CSS style attributes
local function cssInline(options) 
  -- Concatenate style properties with their values using %:?% from kwargs
  local styleKeys = {"top", "right", "bottom", "left", "margin", "padding", "font_size", "line_height"}
  local styleTable = {}
  
  -- Build the style
  for i, key in ipairs(styleKeys) do
    styleTable[i] = safeStyle(options, key)
  end

  -- Concatenate entries together
  return table.concat(styleTable)
end

local function structureCountdownCSSVars(options)
  local dots = {}

  for key, value in pairs(options) do
      table.insert(dots, string.format("--countdown-%s: %s;", key:gsub("_", "-"), value))
  end

  return dots
end

local function countdown_style(options, defaults)

  -- Check if options have values; if it is empty, just exit.
  if isVariableEmpty(options) or isTableEmpty(options) then
    return nil
  end

  -- Determine the selector value
  local possibleSelector = getOption(options, "selector", defaults.selector)

  -- Begin CSS Variables
  local cssTable = {}

  -- Pass defaults into make_countdown_css
  for key, defaultValue in pairs(defaults) do
    -- Assign into the CSS table if key is present
    cssTable[key] = getOption(options, key, defaultValue)
  end

  -- Delete the selector key (after the fact)
  cssTable["selector"] = nil

  -- Restructure options to ("--countdown-<key>: <value>;)
  local structuredCSS = structureCountdownCSSVars(cssTable)

  -- Embed into the document to avoid rendering to disk and, then, embedding a URL.
  quarto.doc.include_text('in-header', 
    string.format(
      "<!-- Countdown Global CSS -->\n<style text='text/css'>:%s {%s}</style>", 
      possibleSelector,
      table.concat(structuredCSS)
    )
  )
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
  countdown_style(meta.countdown, default_style)

  -- Disable re-exporting if no-longer needed
  needsToExportDependencies = false
end

-- Process unnamed time string format
local function parseTimeString(args)
  if #args == 0 or type(args[1]) ~= "string" then
    return nil
  end

  local minutes, seconds = args[1]:match("(%d+):(%d+)")
  if minutes == nil or seconds == nil then
    quarto.log.error("The quartodown time string must be in the format 'MM:SS'.")
  end

  return { minutes = tonumber(minutes), seconds = tonumber(seconds) }
end

local function countdown(args, kwargs, meta)
  local minutes, seconds

  -- Retrieve named time arguments and fallback on default values if missing
  arg_time = parseTimeString(args)
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

  -- Retrieve positional outcome and handle custom value substitution to ensure appropriate positioning
  kwargs["bottom"] = tryOption(kwargs, "bottom") or getOption(kwargs, "top", "0")
  kwargs["right"]  = tryOption(kwargs, "right") or getOption(kwargs, "left", "0")

  local style = cssInline(kwargs) 

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

  quarto.log.output(rawHtml)

  -- Return a new Div element with modified attributes
  return  pandoc.RawBlock("html", rawHtml)
end



return {
  ['countdown'] = countdown
}
