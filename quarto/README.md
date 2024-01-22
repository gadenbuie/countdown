# quarto-countdown: A Quarto Extension for Countdown

The `countdown` extension allows you to incorporate countdown like timers on Quarto HTML Documents and RevealJS slides.

This extension can be used without installing R or the `{countdown}` R Package. 

## Installation

To install the `countdown` extension, follow these steps:

1. Open your terminal.

2. Execute the following command:

```bash
quarto add gadenbuie/countdown/quarto
```

This command will download and install the extension under the `_extensions` subdirectory of your Quarto project. If you are using version control, ensure that you include this directory in your repository.

## Usage

To embed a countdown clock, use the `{{< countdown >}}` shortcode. For example:

```default
{{< countdown >}}
{{< countdown minutes=5 seconds=30 >}}
```

## Example

You can see a minimal example of the extension in action here: [example.qmd](example.qmd).

