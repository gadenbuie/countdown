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

-- Utility function to perform whisker-like substitution
local function substituteInFile(contents, substitutions)

  -- Substitute values in the contents of the file
  contents = contents:gsub("{{%s*(.-)%s*}}", substitutions)

  -- Return the contents of the file with substitutions
  return contents
end

-- Define the infix operator %:?% to handle styling if missing
function safeStyle(x, y)
  if isVariablePopulated(x) then
    -- quarto.log.output("Hi!")
    -- quarto.log.output(x)
    return y .. ":" .. pandoc.utils.stringify(x) .. ";"
  end
  return ""
end

-- Obtain a template file
local function readTemplateFile(template)
  -- Create a hard coded path
  local path = quarto.utils.resolve_path(template) 

  -- Open the template file
  local file = io.open(path, "r")

  -- Check if null pointer before grabbing content
  if not file then        
    quarto.log.error(
      "\nWe were unable to read the template file `" .. template .. "` from the extension directory.\n\n" ..
          "Double check that the extension is fully available by comparing the \n" ..
          "`_extensions/gadenbuie/countdown` directory with the main repository:\n" ..
          "https://github.com/gadenbuie/countdown/tree/main/quarto/_extensions/countdown\n\n" ..
          "You may need to modify `.gitignore` to allow the extension files using:\n" ..
          "!_extensions/*/*/*/*\n")

    return nil
  end

  -- *a or *all reads the whole file
  local content = file:read "*a" 

  -- Close the file
  file:close()

  -- Return contents
  return content
end

local function cssVariablesToTable(meta)

  -- Local table to store the modified variables
  local cssVariables = {}

  -- Check if 'countdown' exists in meta, if not create an empty cell
  local countdownMeta = meta['countdown'] or {}

  -- Font size for the countdown digits
  cssVariables.font_size = countdownMeta['font_size'] or '3rem'

  -- Margin for the countdown element
  cssVariables.margin = countdownMeta['margin'] or '0.6em'

  -- Padding for the countdown element
  cssVariables.padding = countdownMeta['padding'] or '10px 15px'

  -- Box shadow for the countdown element (if provided)
  cssVariables.box_shadow = countdownMeta['box_shadow'] or "0px 4px 10px 0px rgba(50, 50, 50, 0.4)"

  -- Border width for the countdown element
  cssVariables.border_width = countdownMeta['border_width'] or '3px'

  -- Border radius for the countdown element
  cssVariables.border_radius = countdownMeta['border_radius'] or '15px'

  -- Line height for the countdown digits
  cssVariables.line_height = countdownMeta['line_height'] or '1'

  -- Border color for the countdown element
  cssVariables.color_border = countdownMeta['color_border'] or '#ddd'

  -- Background color for the countdown element
  cssVariables.color_background = countdownMeta['color_background'] or 'inherit'

  -- Text color for the countdown digits
  cssVariables.color_text = countdownMeta['color_text'] or 'inherit'

  -- Border color for the running countdown element
  cssVariables.color_running_border = countdownMeta['color_running_border'] or '#43AC6A'

  -- Background color for the running countdown element
  cssVariables.color_running_background = countdownMeta['color_running_background'] or '#43AC6A'

  -- Text color for the running countdown digits (if provided)
  cssVariables.color_running_text = countdownMeta['color_running_text'] or nil

  -- Border color for the finished countdown element
  cssVariables.color_finished_border = countdownMeta['color_finished_border'] or '#F04124'

  -- Background color for the finished countdown element
  cssVariables.color_finished_background = countdownMeta['color_finished_background'] or '#F04124'

  -- Text color for the finished countdown digits (if provided)
  cssVariables.color_finished_text = countdownMeta['color_finished_text'] or nil

  -- Border color for the countdown in a warning state
  cssVariables.color_warning_border = countdownMeta['color_warning_border'] or '#E6C229'

  -- Background color for the countdown in a warning state
  cssVariables.color_warning_background = countdownMeta['color_warning_background'] or '#E6C229'

  -- Text color for the countdown digits in a warning state (if provided)
  cssVariables.color_warning_text = countdownMeta['color_warning_text'] or nil

  return cssVariables
end


-- Pass document-level data into the header to initialize the document.
local function renderCountdownCSSAsset(meta)

  -- Setup different WebR specific initialization variables
  local substitutions = cssVariablesToTable(meta)
  
  -- Make sure we perform a copy
  local cssInitializationTemplate = readTemplateFile("assets/countdown.css.in")

  -- Make the necessary substitutions
  local configuredCSS = substituteInFile(cssInitializationTemplate, substitutions)

  -- Embed into the document to avoid rendering to disk and, then, embedding a URL.
  quarto.doc.include_text('in-header', "<style>" .. configuredCSS .. "</style>")	
  -- Note: This feature or using `add_supporting` requires Quarto v1.4 or above

  return true
end


-- Handle embedding/creation of assets once
local function ensureHTMLDependency(meta)
  quarto.doc.addHtmlDependency({
    name = "countdownjs",
    version = countdownEmbeddedVersion,
    scripts = { "assets/countdown.js"}
  })

  renderCountdownCSSAsset(meta)

  -- Disable re-exporting if no-longer needed
  needsToExportDependencies = false
end

local function countdown(args, kwargs, meta)
  
  -- Retrieve named time arguments and fallback on default values if missing
  local minutes = tonumber(pandoc.utils.stringify(kwargs["minutes"])) or 1
  local seconds = tonumber(pandoc.utils.stringify(kwargs["seconds"])) or 0

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

  -- Determine if a warning should be given
  local warn_when = tonumber(pandoc.utils.stringify(kwargs["data-warn-when"])) or 0
    
  -- Retrieve the ID given by the user or attempt to create a unique ID by timestamp (possible switch over to running counter)
  local id = pandoc.utils.stringify(kwargs["id"]) or ("timer_" .. pandoc.utils.sha1(tostring(os.time())))

  -- Construct the 'class' attribute by appending "countdown" to the existing class (if any)
  local class = "countdown " .. (pandoc.utils.stringify(kwargs["class"]) or "")

  -- Retrieve and convert "data-update-every" attribute to a number, default to 1 if not present or invalid
  local update_every = tonumber(pandoc.utils.stringify(kwargs["data-update-every"])) or 1
  
  -- Retrieve "data-play-sound" attribute as a string, default to "false" if not present
  local play_sound = pandoc.utils.stringify(kwargs["data-play-sound"]) or "false"
  
  -- Retrieve "data-blink-colon" attribute and set 'blink_colon' to true if it equals "true", otherwise false
  local blink_colon = pandoc.utils.stringify(kwargs["data-blink-colon"]) or "false"

  -- Retrieve "data-start-immediately" attribute and set 'start_immediately' to true if it equals "true", otherwise false
  local start_immediately = pandoc.utils.stringify(kwargs["data-start-immediately"]) or "true"

  -- Construct the style attribute based on element attributes
  local style = pandoc.utils.stringify(kwargs["style"]) or ""

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
  -- Return a new Div element with modified attributes
  return  pandoc.RawBlock("html", rawHtml)
end



return {
  ['countdown'] = countdown
}
