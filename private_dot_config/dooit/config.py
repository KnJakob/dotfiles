from dooit.ui.api import DooitAPI, subscribe
from dooit.api import Workspace, Todo, manager
from dooit.ui.api.events import Startup
from dooit.api.theme import DooitThemeBase
from dooit.ui.api.widgets import TodoWidget
from rich.style import Style
from dooit_extras.formatters import *
from dooit_extras.bar_widgets import *
from dooit_extras.scripts import *
from rich.text import Text
"""
class Everforest(DooitThemeBase):
    _name: str = "dooit-everforest"

    # background colors
    background1: str = "#2b3339"  # Darkest
    background2: str = "#323d43"  # Lighter
    background3: str = "#3a454a"  # Lightest

    # foreground colors
    foreground1: str = "#d3c6aa"  # Darkest
    foreground2: str = "#e9e8d2"  # Lighter
    foreground3: str = "#fdf6e3"  # Lightest

    # other colors
    red: str = "#e67e80"  # Red
    orange: str = "#e69875"  # Orange
    yellow: str = "#dbbc7f"  # Yellow
    green: str = "#a7c080"  # Green
    blue: str = "#7fbbb3"  # Blue
    purple: str = "#d699b6"  # Purple
    magenta: str = "#d699b6"  # Magenta (same as purple in Everforest)
    cyan: str = "#83c092"  # Cyan

    # accent colors
    primary: str = cyan
    secondary: str = green


@subscribe(Startup)
def setup_colorscheme(api: DooitAPI, _):
    api.css.set_theme(Everforest)
"""

class DooitThemeCatppuccin(DooitThemeBase):
    _name: str = "dooit-catppuccin"

    # background colors
    background1: str = "#1e1e2e"  # Darkest
    background2: str = "#313244"
    background3: str = "#45475a"  # Lightest

    # foreground colors
    foreground1: str = "#a6adc8"  # Lightest
    foreground2: str = "#bac2de"
    foreground3: str = "#cdd6f4"  # Darkest

    # other colors
    red: str = "#f38ba8"
    orange: str = "#fab387"
    yellow: str = "#f9e2af"
    green: str = "#a6e3a1"
    blue: str = "#89b4fa"
    purple: str = "#b4befe"
    magenta: str = "#f5c2e7"
    cyan: str = "#89dceb"
    lavender: str = "#856088"
    wisteria: str = "#c9a0dc"

    # accent colors
    primary: str = purple
    secondary: str = blue


@subscribe(Startup)
def setup_colorscheme(api: DooitAPI, _):
    api.css.set_theme(DooitThemeCatppuccin)

@subscribe(Startup)
def setup_formatters(api: DooitAPI, _):
    fmt = api.formatter
    theme = api.vars.theme

    # ------- WORKSPACES -------
    format = Text(" ({}) ", style=theme.primary).markup
    fmt.workspaces.description.add(description_children_count(format))

    # --------- TODOS ---------
    # status formatter
    # fmt.todos.status.add(status_icons(completed="󱓻 ", pending="󱓼 ", overdue="󱓼 "))
    fmt.todos.status.add(status_icons(completed=" ", pending="󰞋 ", overdue="󰅗 "))

    # urgency formatte
    # u_icons = {1: "  󰯬", 2: "  󰯯", 3: "  󰯲", 4: "  󰯵"}
    # fmt.todos.urgency.add(urgency_icons(icons=u_icons))
    # u_icons = {1: "  󰎤", 2: "  󰎧", 3: "  󰎪", 4: "  󰎭"}

    # due formatter
    fmt.todos.due.add(due_casual_format())
    # fmt.todos.due.add(due_icon(completed="󰐅 ", pending="󱢗 ", overdue="󱐚 "))
    fmt.todos.due.add(due_icon(completed=" ", pending=" ", overdue=" "))

    # description formatter
    # format = Text("  {completed_count}/{total_count}", style=theme.green).markup
    # fmt.todos.description.add(todo_description_progress(fmt=format))
    # fmt.todos.description.add(description_highlight_tags(fmt="󰌪 {}"))
    format = Text("  {completed_count}/{total_count}", style=theme.green).markup
    fmt.todos.description.add(todo_description_progress(fmt=format))
    fmt.todos.description.add(description_highlight_tags(fmt=" {}"))
    fmt.todos.description.add(description_strike_completed())

# Key Bindings
@subscribe(Startup)
def setup_keys(api: DooitAPI,_):
    api.keys.set("D", custom_action)

@subscribe(Startup)
def setup_layout(api: DooitAPI, _):
    api.layouts.todo_layout = [
        TodoWidget.status,
        # TodoWidget.urgency,
        TodoWidget.description,
        TodoWidget.due,
        TodoWidget.effort,
    ]


@subscribe(Startup)
def setup_bar(api: DooitAPI, _):
    theme = api.vars.theme
    mode_style = Style(color=theme.background1, bgcolor=theme.primary, bold=True)

    widgets = [
        Mode(
            api,
            format_normal="NOR",
            format_insert="INS",
            fmt=Text(" 󰌪 {} ", style=mode_style).markup,
        ),
        Spacer(api, width=1),
        Ticker(api, fmt=" 󱎫 {} ", bg=theme.magenta),
        Spacer(api, width=0),
        StatusIcons(api, bg=theme.background2),
        Spacer(api, width=1),
        WorkspaceProgress(api, fmt=" 󰞯 {}% ", bg=theme.magenta),
        Spacer(api, width=1),
        Clock(api, format="%H:%M", fmt=" 󰥔 {} ", bg=theme.cyan),
        Spacer(api, width=1),
        Date(api, fmt=" 󰃰 {} ", bg=theme.wisteria),
    ]
    api.bar.set(widgets)


@subscribe(Startup)
def setup_dashboard(api: DooitAPI, _):
    theme = api.vars.theme

    # ascii_art = r"""
                                                    # ____
                                         # v        _(    )
        # _ ^ _                          v         (___(__)
       # '_\V/ `
       # ' oX`
          # X                             
          # X            Help, I can't finish! 
          # X          -                                      .
          # X        \O/                                      |\
          # X.a##a.   M                                       |_\
       # .aa########a.>>                                 _____|_____
    # .a################aa.                              \  DOOIT  /
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# """
    # ascii_art.highlight_words([" Help, I can't finish! "], style="reverse")
    # ascii_art.highlight_words([" DOOIT "], style=theme.secondary)

    # ascii_art = Text(ascii_art, style=theme.primary)
    # header = Text(
        # "Welcome again to your daily life, piled with unfinished tasks!",
        # style=Style(color=theme.secondary, bold=True, italic=True),
    # )

    # items = [
        # header,
        # ascii_art,
        # "",
        # "",
        # Text("Will you finish your tasks today?", style=theme.secondary),
    # ]
    ascii_art = r"""
   ,-.       _,---._ __  / \
 /  )    .-'       `./ /   \
(  (   ,'            `/    /|
 \  `-"             \'\   / |
  `.              ,  \ \ /  |
   /`.          ,'-`----Y   |
  (            ;        |   '
  |  ,-.    ,-'         |  /
  |  | (   |      TODOS | /
  )  |  \  `.___________|/
  `--'   `--'
    """

    due_today = sum([1 for i in Todo.all() if i.is_due_today and i.is_pending])
    overdue = sum([1 for i in Todo.all() if i.is_overdue])

    header = Text(
        "Another day, another opportunity to organize my todos and then procrastinate",
        style=Style(color=theme.secondary, bold=True, italic=True),
    )

    items = [
        header,
        ascii_art,
        "",
        "",
        Text("󰠠 Tasks pending today: {}".format(due_today), style=theme.green),
        Text("󰁇 Tasks still overdue: {}".format(overdue), style=theme.red),
    ]
    api.dashboard.set(items)


@subscribe(Startup)
def additional_setup(api: DooitAPI, _):
    dim_unfocused(api, "60%") 

def custom_action():
    """This will run when 'D' key is pressed."""
    # Your logic here
    print("dumb logic")
    return "something" 

