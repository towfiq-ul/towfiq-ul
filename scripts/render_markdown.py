"""Render a Markdown file to a styled HTML page and open it in the browser."""
import sys
import tempfile
import webbrowser

from markdown_it import MarkdownIt

PAGE = """<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>{title}</title>
<style>
  body {{ max-width: 860px; margin: 40px auto; padding: 0 20px;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
          line-height: 1.6; color: #1f2328; }}
  img {{ max-width: 100%; }}
  pre, code {{ background: #f6f8fa; border-radius: 6px; }}
  code {{ padding: 0.2em 0.4em; }}
  pre code {{ display: block; padding: 12px; overflow-x: auto; }}
  table {{ border-collapse: collapse; }}
  th, td {{ border: 1px solid #d0d7de; padding: 6px 12px; }}
  a {{ color: #0969da; }}
  hr {{ border: none; border-top: 1px solid #d0d7de; }}
</style>
</head>
<body>
{body}
</body>
</html>
"""


def main():
    md_file = sys.argv[1] if len(sys.argv) > 1 else "README.md"

    with open(md_file, encoding="utf-8") as f:
        text = f.read()

    md = MarkdownIt("commonmark").enable(["table", "strikethrough"])
    html = PAGE.format(title=md_file, body=md.render(text))

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".html", prefix="make_show_", delete=False, encoding="utf-8"
    ) as f:
        f.write(html)
        out_path = f.name

    webbrowser.open(f"file://{out_path}")
    print(f"Opened {md_file} in browser ({out_path})")


if __name__ == "__main__":
    main()
