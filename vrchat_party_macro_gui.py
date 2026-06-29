from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
import tkinter as tk
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from pathlib import Path
from tkinter import filedialog, messagebox, ttk


ROOT = Path(__file__).resolve().parent
CONFIG_PATH = ROOT / "vrchat_party_macro_common_config.ahk"
SETTING_NAMES = (
    "dungeonClearIntervalMs",
    "ascendIntervalMs",
    "saleIntervalMs",
)
SECONDS_DECIMAL_PLACES = Decimal("0.001")
DUNGEON_BUTTON_PATTERN = re.compile(
    r"^(?P<indent>\s*)(?P<comment>;?)\s*dungeonButtonMove(?P<axis>[XY])\s*:=\s*"
    r"(?P<value>-?\d+)(?P<spacing>\s*;\s*)(?P<label>.+?)\s*$",
    re.MULTILINE,
)
DUNGEON_LEFT_MOVE_X_PATTERN = re.compile(
    r"^\s*dungeonLeftMoveX\s*:=\s*(?P<value>-?\d+)\b",
    re.MULTILINE,
)


@dataclass(frozen=True)
class DungeonButtonOption:
    label: str
    x: int
    y: int
    active: bool


def ms_to_seconds_text(ms: int) -> str:
    seconds = (Decimal(ms) / Decimal(1000)).quantize(SECONDS_DECIMAL_PLACES)
    return format(seconds.normalize(), "f")


def seconds_text_to_ms(text: str, label: str) -> int:
    try:
        seconds = Decimal(text.strip())
    except InvalidOperation as exc:
        raise ValueError(f"{label} は秒数で入力してください。") from exc
    if seconds <= 0:
        raise ValueError(f"{label} は0より大きい値にしてください。")
    ms = int((seconds * Decimal(1000)).to_integral_value())
    if ms <= 0:
        raise ValueError(f"{label} は1ms以上になる値にしてください。")
    return ms


def dungeon_button_options(text: str | None = None) -> list[DungeonButtonOption]:
    if text is None:
        text = CONFIG_PATH.read_text(encoding="utf-8-sig")

    default_x_match = DUNGEON_LEFT_MOVE_X_PATTERN.search(text)
    default_x = int(default_x_match.group("value")) if default_x_match else 80

    option_data: dict[str, dict[str, object]] = {}
    option_order: list[str] = []
    for match in DUNGEON_BUTTON_PATTERN.finditer(text):
        label = match.group("label").strip()
        axis = match.group("axis")
        value = int(match.group("value"))
        if label not in option_data:
            option_data[label] = {}
            option_order.append(label)
        option_data[label][axis] = value
        option_data[label][f"{axis}_active"] = match.group("comment") != ";"

    options: list[DungeonButtonOption] = []
    for label in option_order:
        data = option_data[label]
        if "Y" not in data:
            raise ValueError(f"{CONFIG_PATH.name} の {label} に dungeonButtonMoveY が見つかりません。")
        x = int(data.get("X", default_x))
        y = int(data["Y"])
        if "X" in data:
            active = bool(data.get("X_active")) and bool(data.get("Y_active"))
        else:
            active = bool(data.get("Y_active"))
        options.append(DungeonButtonOption(label, x, y, active))

    if not options:
        raise ValueError(f"{CONFIG_PATH.name} に dungeonButtonMoveX/Y の候補が見つかりません。")
    return options


def find_autohotkey() -> Path | None:
    candidates = [
        os.environ.get("AUTOHOTKEY_EXE"),
        r"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
        r"C:\Program Files\AutoHotkey\v2\AutoHotkey.exe",
        shutil.which("AutoHotkey64.exe"),
        shutil.which("AutoHotkey.exe"),
    ]
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return Path(candidate)
    return None


def macro_files() -> list[Path]:
    return sorted(
        path
        for path in ROOT.glob("vrchat_party_macro*.ahk")
        if not path.name.startswith("vrchat_party_macro_common_")
    )


def read_config() -> dict[str, int]:
    text = CONFIG_PATH.read_text(encoding="utf-8-sig")
    values: dict[str, int] = {}
    for name in SETTING_NAMES:
        match = re.search(rf"^\s*{re.escape(name)}\s*:=\s*(\d+)\b", text, re.MULTILINE)
        if not match:
            raise ValueError(f"{CONFIG_PATH.name} に {name} が見つかりません。")
        values[name] = int(match.group(1))
    active_options = [option for option in dungeon_button_options(text) if option.active]
    if len(active_options) != 1:
        raise ValueError(f"{CONFIG_PATH.name} に有効な dungeonButtonMoveX/Y が1つだけ必要です。")
    values["dungeonButtonMoveX"] = active_options[0].x
    values["dungeonButtonMoveY"] = active_options[0].y
    return values


def write_config(values: dict[str, int]) -> None:
    text = CONFIG_PATH.read_text(encoding="utf-8-sig")
    for name in SETTING_NAMES:
        value = values[name]
        text, count = re.subn(
            rf"^(\s*{re.escape(name)}\s*:=\s*)\d+(\b.*)$",
            rf"\g<1>{value}\2",
            text,
            count=1,
            flags=re.MULTILINE,
        )
        if count != 1:
            raise ValueError(f"{CONFIG_PATH.name} の {name} を更新できませんでした。")

    dungeon_value = (values["dungeonButtonMoveX"], values["dungeonButtonMoveY"])
    options = dungeon_button_options(text)
    option_values = {(option.x, option.y) for option in options}
    if dungeon_value not in option_values:
        raise ValueError("ダンジョンボタン位置の値が不正です。")
    options_by_label = {option.label: option for option in options}

    def replace_dungeon_button(match: re.Match[str]) -> str:
        label = match.group("label").strip()
        option = options_by_label[label]
        comment = "" if (option.x, option.y) == dungeon_value else ";"
        return (
            f"{match.group('indent')}{comment}dungeonButtonMove{match.group('axis')} := {match.group('value')}"
            f"{match.group('spacing')}{match.group('label').strip()}"
        )

    text, count = DUNGEON_BUTTON_PATTERN.subn(replace_dungeon_button, text)
    if count == 0:
        raise ValueError(f"{CONFIG_PATH.name} の dungeonButtonMoveX/Y を更新できませんでした。")
    CONFIG_PATH.write_text(text, encoding="utf-8-sig")


def close_known_macro_scripts(autohotkey_exe: Path) -> None:
    close_lines = [
        "#Requires AutoHotkey v2.0",
        "DetectHiddenWindows True",
        "SetTitleMatchMode 2",
    ]
    for path in macro_files():
        escaped = str(path).replace('"', '""')
        close_lines.append(f'try WinClose "{escaped} ahk_class AutoHotkey"')
    close_lines.append("Sleep 300")

    with tempfile.NamedTemporaryFile(
        "w",
        suffix=".ahk",
        delete=False,
        encoding="utf-8-sig",
        newline="\r\n",
    ) as temp_file:
        temp_file.write("\n".join(close_lines))
        helper_path = Path(temp_file.name)

    try:
        subprocess.run(
            [str(autohotkey_exe), str(helper_path)],
            cwd=str(ROOT),
            timeout=5,
            check=False,
        )
    finally:
        try:
            helper_path.unlink()
        except OSError:
            pass


class MacroConfigApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("VRChat Party Macro Config")
        self.resizable(False, False)

        self.autohotkey_exe = find_autohotkey()
        self.macro_paths = macro_files()
        self.macro_by_name = {path.name: path for path in self.macro_paths}
        self.dungeon_button_options: dict[str, tuple[int, int]] = {}

        self.dungeon_var = tk.StringVar()
        self.ascend_var = tk.StringVar()
        self.sale_var = tk.StringVar()
        self.dungeon_button_var = tk.StringVar()
        self.ahk_var = tk.StringVar()
        self.selected_ahk_path: Path | None = None
        self.status_var = tk.StringVar()

        self._build_ui()
        self.reload_config()
        if self.macro_paths:
            self.set_selected_ahk(self.macro_paths[0])

        if self.autohotkey_exe:
            self.status_var.set(f"AutoHotkey: {self.autohotkey_exe}")
        else:
            self.status_var.set("AutoHotkeyが見つかりません。")

    def _build_ui(self) -> None:
        padding = {"padx": 10, "pady": 6}
        root = ttk.Frame(self, padding=12)
        root.grid(row=0, column=0, sticky="nsew")

        ttk.Label(root, text="ダンジョンクリア間隔 (秒)").grid(row=0, column=0, sticky="w", **padding)
        ttk.Entry(root, textvariable=self.dungeon_var, width=18).grid(row=0, column=1, sticky="ew", **padding)

        ttk.Label(root, text="転生間隔 (秒)").grid(row=1, column=0, sticky="w", **padding)
        ttk.Entry(root, textvariable=self.ascend_var, width=18).grid(row=1, column=1, sticky="ew", **padding)

        ttk.Label(root, text="売却間隔 (秒)").grid(row=2, column=0, sticky="w", **padding)
        ttk.Entry(root, textvariable=self.sale_var, width=18).grid(row=2, column=1, sticky="ew", **padding)

        ttk.Label(root, text="ダンジョンボタン位置").grid(row=3, column=0, sticky="w", **padding)
        self.dungeon_button_combo = ttk.Combobox(
            root,
            textvariable=self.dungeon_button_var,
            values=[],
            width=18,
            state="readonly",
        )
        self.dungeon_button_combo.grid(row=3, column=1, sticky="ew", **padding)

        ttk.Label(root, text="実行するAHK").grid(row=4, column=0, sticky="w", **padding)
        combo = ttk.Combobox(
            root,
            textvariable=self.ahk_var,
            values=[path.name for path in self.macro_paths],
            width=40,
            state="readonly",
        )
        combo.grid(row=4, column=1, sticky="ew", **padding)
        combo.bind("<<ComboboxSelected>>", self.on_ahk_selected)
        ttk.Button(root, text="選択", command=self.browse_ahk).grid(row=4, column=2, sticky="ew", **padding)

        buttons = ttk.Frame(root)
        buttons.grid(row=5, column=0, columnspan=3, sticky="e", pady=(10, 4))
        ttk.Button(buttons, text="再読込", command=self.reload_config).grid(row=0, column=0, padx=4)
        ttk.Button(buttons, text="保存のみ", command=self.save_only).grid(row=0, column=1, padx=4)
        ttk.Button(buttons, text="適用して実行", command=self.apply_and_run).grid(row=0, column=2, padx=4)

        ttk.Label(root, textvariable=self.status_var, foreground="#444").grid(
            row=6,
            column=0,
            columnspan=3,
            sticky="w",
            padx=10,
            pady=(8, 0),
        )

    def set_selected_ahk(self, path: Path) -> None:
        self.selected_ahk_path = path
        self.ahk_var.set(path.name)

    def on_ahk_selected(self, _event: object | None = None) -> None:
        path = self.macro_by_name.get(self.ahk_var.get())
        if path:
            self.selected_ahk_path = path

    def browse_ahk(self) -> None:
        selected = filedialog.askopenfilename(
            initialdir=str(ROOT),
            title="実行するAHKファイルを選択",
            filetypes=[("AutoHotkey scripts", "*.ahk"), ("All files", "*.*")],
        )
        if selected:
            self.set_selected_ahk(Path(selected))

    def reload_config(self) -> None:
        try:
            values = read_config()
        except Exception as exc:
            messagebox.showerror("読み込みエラー", str(exc))
            return
        self.dungeon_var.set(ms_to_seconds_text(values["dungeonClearIntervalMs"]))
        self.ascend_var.set(ms_to_seconds_text(values["ascendIntervalMs"]))
        self.sale_var.set(ms_to_seconds_text(values["saleIntervalMs"]))
        self.refresh_dungeon_button_options()
        self.dungeon_button_var.set(
            self.dungeon_button_label(
                values["dungeonButtonMoveX"],
                values["dungeonButtonMoveY"],
            )
        )
        self.status_var.set("設定を読み込みました。")

    def refresh_dungeon_button_options(self) -> None:
        self.dungeon_button_options = {
            option.label: (option.x, option.y)
            for option in dungeon_button_options()
        }
        self.dungeon_button_combo.configure(values=list(self.dungeon_button_options.keys()))

    def dungeon_button_label(self, x: int, y: int) -> str:
        for label, option_value in self.dungeon_button_options.items():
            if option_value == (x, y):
                return label
        raise ValueError(f"未対応のダンジョンボタン位置です: {x}, {y}")

    def collect_values(self) -> dict[str, int]:
        labels = {
            "dungeonClearIntervalMs": "ダンジョンクリア間隔",
            "ascendIntervalMs": "転生間隔",
            "saleIntervalMs": "売却間隔",
        }
        raw_values = {
            "dungeonClearIntervalMs": self.dungeon_var.get(),
            "ascendIntervalMs": self.ascend_var.get(),
            "saleIntervalMs": self.sale_var.get(),
        }
        values = {
            name: seconds_text_to_ms(raw, labels[name])
            for name, raw in raw_values.items()
        }
        selected_label = self.dungeon_button_var.get()
        if selected_label not in self.dungeon_button_options:
            raise ValueError("ダンジョンボタン位置を選択してください。")
        values["dungeonButtonMoveX"], values["dungeonButtonMoveY"] = (
            self.dungeon_button_options[selected_label]
        )
        return values

    def save_only(self) -> bool:
        try:
            write_config(self.collect_values())
        except Exception as exc:
            messagebox.showerror("保存エラー", str(exc))
            return False
        self.status_var.set("設定を保存しました。")
        return True

    def apply_and_run(self) -> None:
        if not self.save_only():
            return

        selected = self.selected_ahk_path
        if not selected or not selected.is_file():
            messagebox.showerror("実行エラー", "実行するAHKファイルを選択してください。")
            return

        if not self.autohotkey_exe:
            messagebox.showerror("実行エラー", "AutoHotkey v2 が見つかりません。")
            return

        try:
            close_known_macro_scripts(self.autohotkey_exe)
            subprocess.Popen(
                [str(self.autohotkey_exe), str(selected)],
                cwd=str(ROOT),
                creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
            )
        except Exception as exc:
            messagebox.showerror("実行エラー", str(exc))
            return

        self.status_var.set(f"設定を保存し、{selected.name} を起動しました。")


if __name__ == "__main__":
    MacroConfigApp().mainloop()
