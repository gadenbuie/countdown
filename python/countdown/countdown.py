import htmltools, uuid

# We're retaining this for the moment.
def example_function():
    return 1 + 1

def make_countdown_css_vars(**kwargs):
    """
    Generate CSS variables for countdown styling.

    Args:
        **kwargs: Keyword arguments for styling.

    Returns:
        dict or None: Dictionary of CSS variables or None if no styling is provided.
    """
    dots = {k: v for k, v in kwargs.items() if v is not None}

    if not dots:
        return None

    css_vars = {f"--countdown-{k.replace('_', '-')}": v for k, v in dots.items()}

    return css_vars

def html_dependency_countdown():
    """
    Package the HTML Dependency for countdown (JS + CSS).

    Returns:
        HTMLDependency: py-htmltools HTMLDependency component.
    """
    return htmltools.HTMLDependency(
        "countdown",
        version= "0.0.1", #countdown.__version__,
        source={"package": "htmltools", "subdir": "assets"},
        script={"src": "countdown.js"},
        stylesheet={"href":"countdown.css"},
        all_files=True
    )


def countdown(
    minutes=1,
    seconds=0,
    id=None,
    class_name=None,
    style=None,
    play_sound=False,
    bottom=None,
    right=None,
    top=None,
    left=None,
    warn_when=0,
    update_every=1,
    blink_colon=True,
    start_immediately=False,
    font_size=None,
    margin=None,
    padding=None,
    box_shadow=None,
    border_width=None,
    border_radius=None,
    line_height=None,
    color_border=None,
    color_background=None,
    color_text=None,
    color_running_background=None,
    color_running_border=None,
    color_running_text=None,
    color_finished_background=None,
    color_finished_border=None,
    color_finished_text=None,
    color_warning_background=None,
    color_warning_border=None,
    color_warning_text=None
):
    """
    Create a countdown timer using py-htmltools.

    Args:
        minutes (int): Initial minutes for the countdown.
        seconds (int): Initial seconds for the countdown.
        id (str): HTML id for the countdown.
        class_name (str): CSS class for styling.
        style (dict): Additional CSS styling for the countdown.
        play_sound (bool or str): Enable sound on timer completion.
        bottom (str): CSS style for bottom position.
        right (str): CSS style for right position.
        top (str): CSS style for top position.
        left (str): CSS style for left position.
        warn_when (int): Time in seconds to trigger a warning.
        update_every (int): Time interval for updating the countdown.
        blink_colon (bool): Enable blinking colon in the countdown.
        start_immediately (bool): Start the countdown immediately.
        font_size (str): CSS style for font size.
        margin (str): CSS style for margin.
        padding (str): CSS style for padding.
        box_shadow (str): CSS style for box shadow.
        border_width (str): CSS style for border width.
        border_radius (str): CSS style for border radius.
        line_height (str): CSS style for line height.
        color_border (str): CSS style for border color.
        color_background (str): CSS style for background color.
        color_text (str): CSS style for text color.
        color_running_background (str): CSS style for running background color.
        color_running_border (str): CSS style for running border color.
        color_running_text (str): CSS style for running text color.
        color_finished_background (str): CSS style for finished background color.
        color_finished_border (str): CSS style for finished border color.
        color_finished_text (str): CSS style for finished text color.
        color_warning_background (str): CSS style for warning background color.
        color_warning_border (str): CSS style for warning border color.
        color_warning_text (str): CSS style for warning text color.

    Returns:
        HTML: py-htmltools HTML component for the countdown.
    """

    # Compute the time
    time = minutes * 60 + seconds
    minutes = int(time // 60)
    seconds = int(time - minutes * 60)


    if minutes > 100:
        raise ValueError("Minutes must be less than 100")
    
    # Ensure integer
    warn_when = int(warn_when)

    # Check if warn_when is negative.
    if warn_when < 0:
        raise ValueError("`warn_when` must be a non-negative integer number of seconds")
    
    # Generate unique ID
    if id is None:
        uid = str(uuid.uuid4())
        id = "timer_" + uid

    # Concatenate class names
    class_name = " ".join(filter(None, ["countdown", class_name]))

    # Play sound
    play_sound = "true" if play_sound else None

    if warn_when > 0:
        warn_when = int(warn_when)

    update_every = int(update_every)

    css_vars = make_countdown_css_vars(
        margin=margin,
        padding=padding,
        font_size=font_size,
        box_shadow=box_shadow,
        border_width=border_width,
        border_radius=border_radius,
        line_height=line_height,
        color_border=color_border,
        color_background=color_background,
        color_text=color_text,
        color_running_background=color_running_background,
        color_running_border=color_running_border,
        color_running_text=color_running_text,
        color_finished_background=color_finished_background,
        color_finished_border=color_finished_border,
        color_finished_text=color_finished_text,
        color_warning_background=color_warning_background,
        color_warning_border=color_warning_border,
        color_warning_text=color_warning_text
    )

    # Create the main HTML structure using py-htmltools version
    x = htmltools.tags.div(
        # Countdown controls with buttons
        htmltools.tags.div(
            htmltools.tags.button("−", class_ ="countdown-bump-down"),
            htmltools.tags.button("+", class_ ="countdown-bump-up"),
            class_ = "countdown-controls",
        ),
        # Countdown time display
        htmltools.tags.code(
                htmltools.tags.span(f"{minutes:02d}", class_ = "countdown-digits minutes"),
                htmltools.tags.span(":", class_ = "countdown-digits colon"),
                htmltools.tags.span(f"{seconds:02d}", class_ = "countdown-digits seconds"),
            class_ ="countdown-time",
        ),
        htmltools.tags.html(html_dependency_countdown()),
        class_ = class_name,
        id=id,
        data_warn_when=warn_when,
        data_update_every=update_every,
        data_play_sound=play_sound,
        data_blink_colon="true" if blink_colon else None,
        data_start_immediately="true" if start_immediately else None,
        tabIndex=0,
        style=htmltools.css(
            top=top,
            right=right,
            bottom=bottom,
            left=left,
            #**css_vars,
            #**style,
        )
    )

    return x

def countdown_style(
    font_size="3rem",
    margin="0.6em",
    padding="10px 15px",
    box_shadow="0px 4px 10px 0px rgba(50, 50, 50, 0.4)",
    border_width="0.1875rem",
    border_radius="0.9rem",
    line_height="1",
    color_border="#ddd",
    color_background="inherit",
    color_text="inherit",
    color_running_background="#43AC6A",
    color_running_border="#2A9B59FF",
    color_running_text='inherit',
    color_finished_background="#F04124",
    color_finished_border="#DE3000FF",
    color_finished_text='inherit',
    color_warning_background="#E6C229",
    color_warning_border="#CEAC04FF",
    color_warning_text='inherit',
    selector=":root"
):
    """
    Generate a header inject CSS style for countdown using py-htmltools.

    Args:
        font_size (str): CSS style for font size.
        margin (str): CSS style for margin.
        padding (str): CSS style for padding.
        box_shadow (str): CSS style for box shadow.
        border_width (str): CSS style for border width.
        border_radius (str): CSS style for border radius.
        line_height (str): CSS style for line height.
        color_border (str): CSS style for border color.
        color_background (str): CSS style for background color.
        color_text (str): CSS style for text color.
        color_running_background (str): CSS style for running background color.
        color_running_border (str): CSS style for running border color.
        color_running_text (str): CSS style for running text color.
        color_finished_background (str): CSS style for finished background color.
        color_finished_border (str): CSS style for finished border color.
        color_finished_text (str): CSS style for finished text color.
        color_warning_background (str): CSS style for warning background color.
        color_warning_border (str): CSS style for warning border color.
        color_warning_text (str): CSS style for warning text color.
        selector (str): CSS selector.

    Returns:
        HTML: py-htmltools HTML component for countdown style.
    """

    # Create a dictionary of CSS variables
    css_vars = make_countdown_css_vars(
        font_size=font_size,
        margin=margin,
        padding=padding,
        box_shadow=box_shadow,
        border_width=border_width,
        border_radius=border_radius,
        line_height=line_height,
        color_border=color_border,
        color_background=color_background,
        color_text=color_text,
        color_running_background=color_running_background,
        color_running_border=color_running_border,
        color_running_text=color_running_text,
        color_finished_background=color_finished_background,
        color_finished_border=color_finished_border,
        color_finished_text=color_finished_text,
        color_warning_background=color_warning_background,
        color_warning_border=color_warning_border,
        color_warning_text=color_warning_text
    )

    if css_vars is None:
        return None

    # Generate CSS declarations
    declarations = htmltools.css(**css_vars)

    # Create the style tag with the generated CSS
    return htmltools.tags.style(htmltools.HTML(f"{selector} {{ {declarations} }}"))
