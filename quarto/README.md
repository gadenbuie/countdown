# quarto-countdown: Countdown Timers for Quarto RevealJS slides

The `quarto-countdown` extension for [Quarto](https://quarto.org) allows you to incorporate countdown timers on [Quarto RevealJS slides](https://quarto.org/docs/presentations/revealjs/).

This extension doesn't require the installation of _R_ or the `{countdown}` _R_ Package.

## Installation

To install the `countdown` extension, follow these steps:

1. Open your terminal.

2. Execute the following command:

```bash
quarto add gadenbuie/countdown/quarto
```

This command will download and install the extension under the `_extensions` subdirectory of your Quarto project. If you are using version control, ensure that you include this directory in your repository.

## Usage

To embed a countdown clock, use the `{{< countdown >}}` shortcode. For example, a countdown clock can be created by writing anywhere:

```default
{{< countdown >}}
```

For a longer or shorter countdown, specify the `minutes` and `seconds` options:

```default
{{< countdown minutes=5 seconds=30 >}}
```

Or use a time string formatted in `"MM:SS"`

```default
{{< countdown "5:30" >}}
```

There are many more customizations to choose from. See the next section for more details. 

### Customizations

The extension offers extensive customization options, akin to the features provided by the R package version of `countdown`. These customizations span both functionality and style. They can be configured either at the document level or for each individual timer.

#### In-line options

The `countdown` timer shortcode has a variety of customizations that can be set. The customizations can be split between functionality and style.

The functionality options are:

| Option              | Default Value                   | Description                                                               |
| ------------------- | ------------------------------- | ------------------------------------------------------------------------- |
| `minutes`           | `1`                             | Number of minutes with a total cap of 100 minutes                         |
| `seconds`           | `0`                             | Number of seconds                                                         |
| `id`                | A generated, unique ID          | ID attribute of the HTML element.                                         |
| `class`             | `"countdown"`                   | Class attribute of the HTML element.                                      |
| `warn_when`         | `0`                             | Number of seconds before the countdown displays a warning.                |
| `update_every`      | `1`                             | Frequency at which the countdown should be updated, in seconds.           |
| `play_sound`        | `"false"`                       | Boolean indicating whether to play a sound during the countdown.          |
| `blink_colon`       | `"false"`                       | Boolean indicating whether the colon in the countdown should blink.       |
| `start_immediately` | `"false"`                       | Boolean indicating whether the countdown should start immediately.        |

The style options are: 

| Style Option  | Default Value                | Description                                                               |
| ------------- | ---------------------------- | ------------------------------------------------------------------------- |
| `top`         | `""` (empty)                 | Top position of the HTML element.                                         |
| `right`       | `"0"`                        | Right position of the HTML element.                                       |
| `bottom`      | `"0"`                        | Bottom position of the HTML element.                                      |
| `left`        | `""` (empty)                 | Left position of the HTML element.                                        |
| `margin`      | `"0.6em"`                    | Margin around the HTML element.                                           |
| `padding`     | `"10px 15px"`                | Padding within the HTML element.                                          |
| `font-size`   | `"3rem"`                     | Font size of the HTML element.                                            |
| `line-height` | `"1"`                        | Line height of the HTML element.                                          |
| `style`       | Computed based on attributes | String constructed based on style-related attributes of the HTML element. |

#### Document-level Options

Document-level options can be specified in the document's header using a YAML key-value format:

```yaml
---
title: "Example document-level settings"
countdown:
  option: value
---
```

The following options are implemented:

| Option                      | Default Value                              | Description                                       |
| --------------------------- | ------------------------------------------ | ------------------------------------------------- |
| `font_size`                 | `"3rem"`                                   | Font size for the countdown element               |
| `margin`                    | `"0.6em"`                                  | Margin around the countdown element               |
| `padding`                   | `"10px 15px"`                              | Padding within the countdown element              |
| `box_shadow`                | `"0px 4px 10px 0px rgba(50, 50, 50, 0.4)"` | Shadow applied to the countdown element           |
| `border_width`              | `"0.1875rem"`                              | Border width of the countdown element             |
| `border_radius`             | `"0.9rem"`                                 | Border radius of the countdown element            |
| `line_height`               | `"1"`                                      | Line height of the countdown element              |
| `color_border`              | `"#ddd"`                                   | Border color of the countdown element             |
| `color_background`          | `"inherit"`                                | Background color of the countdown element         |
| `color_text`                | `"inherit"`                                | Text color of the countdown element               |
| `color_running_background`  | `"#43AC6A"`                                | Background color when the countdown is running    |
| `color_running_border`      | `"#2A9B59FF"`                              | Border color when the countdown is running        |
| `color_running_text`        | `"inherit"`                                | Text color when the countdown is running          |
| `color_finished_background` | `"#F04124"`                                | Background color when the countdown is finished   |
| `color_finished_border`     | `"#DE3000FF"`                              | Border color when the countdown is finished       |
| `color_finished_text`       | `"inherit"`                                | Text color when the countdown is finished         |
| `color_warning_background`  | `"#E6C229"`                                | Background color when the countdown has a warning |
| `color_warning_border`      | `"#CEAC04FF"`                              | Border color when the countdown has a warning     |
| `color_warning_text`        | `"inherit"`                                | Text color when the countdown has a warning       |
| `selector`                  | `"root"`                                   | Selector for the countdown element                |


## Example

You can see a minimal example of the extension in action here: [quarto-example.qmd](../docs/quarto-example.qmd).

